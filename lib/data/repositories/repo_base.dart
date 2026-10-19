import 'package:drift/drift.dart';

import '../../core/dates.dart';
import '../db/database.dart';
import '../sync/outbox.dart';

/// A write was refused before touching the database. [code] maps to a
/// localized message in the UI.
class AppException implements Exception {
  const AppException(this.code, [this.args = const {}]);

  final String code;
  final Map<String, Object?> args;

  @override
  String toString() => 'AppException($code)';
}

/// After this long without confirming membership with the server, the app
/// keeps showing data but stops accepting new entries until it reconnects.
const maxOfflineVerificationAge = Duration(days: 30);

class RepoContext {
  RepoContext({
    required this.db,
    required this.outbox,
    required this.farmId,
    required this.userId,
    required this.deviceId,
    this.onWrite,
  });

  final AppDatabase db;
  final Outbox outbox;
  final String farmId;
  final String userId;
  final String deviceId;

  /// Called after every committed local write (used to nudge sync).
  final void Function()? onWrite;

  Future<FarmMember?> me() =>
      (db.select(db.farmMembers)..where((m) => m.farmId.equals(farmId) & m.userId.equals(userId))).getSingleOrNull();

  Future<WriteContext> writeContext() async {
    final m = await me();
    return WriteContext(
      farmId: farmId,
      userId: userId,
      deviceId: deviceId,
      actorName: m?.fullName ?? '',
      role: m?.role ?? 'member',
    );
  }

  Future<void> guardWrite() async {
    if (await db.getKv(KvKeys.accessRevoked) != null) throw const AppException('access_revoked');
    final verified = DateTime.tryParse(await db.getKv(KvKeys.lastVerifiedAt) ?? '');
    if (verified == null || AppClock.nowUtc().difference(verified) > maxOfflineVerificationAge) {
      throw const AppException('verification_expired');
    }
    final m = await me();
    if (m == null || m.status != 'active') throw const AppException('access_revoked');
  }

  /// Validates permissions, then runs [body] in one transaction (local change
  /// plus outbox entry), then nudges sync.
  Future<T> write<T>(Future<T> Function(WriteContext ctx) body) async {
    await guardWrite();
    final ctx = await writeContext();
    final result = await db.transaction(() => body(ctx));
    onWrite?.call();
    return result;
  }

  /// Members cannot change a closed week; owners/admins can (the settlement
  /// is then flagged for review by the server).
  Future<void> guardPeriod(WriteContext ctx, String date) async {
    final closed =
        await (db.select(db.settlements)..where(
              (s) =>
                  s.farmId.equals(farmId) &
                  s.status.equals('closed') &
                  s.weekStart.isSmallerOrEqualValue(date) &
                  s.weekEnd.isBiggerOrEqualValue(date),
            ))
            .get();
    if (closed.isEmpty) return;
    if (!ctx.isAdmin) throw AppException('week_closed', {'date': date});
    for (final s in closed) {
      await (db.update(
        db.settlements,
      )..where((x) => x.id.equals(s.id))).write(const SettlementsCompanion(needsReview: Value(true)));
    }
  }

  void validateDate(String iso, {int maxDaysAhead = 1}) {
    final LocalDate d;
    try {
      d = LocalDate.parse(iso);
    } on FormatException {
      throw const AppException('invalid_date');
    }
    if (d.isBefore(const LocalDate(2000, 1, 1)) || d.isAfter(AppClock.today().addDays(maxDaysAhead))) {
      throw const AppException('invalid_date');
    }
  }

  String? clean(String? s, {int max = 500}) {
    final t = s?.trim();
    if (t == null || t.isEmpty) return null;
    if (t.length > max) throw AppException('text_too_long', {'max': max});
    return t;
  }
}
