import 'package:drift/drift.dart';

import '../../core/ids.dart';
import '../db/database.dart';
import '../sync/outbox.dart';
import 'repo_base.dart';

abstract final class Roles {
  static const owner = 'owner';
  static const admin = 'admin';
  static const member = 'member';
}

class MembersRepo {
  MembersRepo(this.r);

  final RepoContext r;
  AppDatabase get db => r.db;

  Stream<Farm?> watchFarm() => (db.select(db.farms)..where((f) => f.id.equals(r.farmId))).watchSingleOrNull();

  Stream<FarmMember?> watchMe() => (db.select(
    db.farmMembers,
  )..where((m) => m.farmId.equals(r.farmId) & m.userId.equals(r.userId))).watchSingleOrNull();

  Stream<List<FarmMember>> watchMembers() =>
      (db.select(db.farmMembers)
            ..where((m) => m.farmId.equals(r.farmId))
            ..orderBy([(m) => OrderingTerm.asc(m.fullName)]))
          .watch();

  /// Members who can be chosen as "paid by": joined family members.
  Stream<List<FarmMember>> watchPayers() =>
      (db.select(db.farmMembers)
            ..where((m) => m.farmId.equals(r.farmId) & m.userId.isNotNull() & m.status.isNotValue('invited'))
            ..orderBy([(m) => OrderingTerm.asc(m.fullName)]))
          .watch();

  /// Names by user id, for "recorded by" lines.
  Stream<Map<String, FarmMember>> watchByUserId() =>
      (db.select(db.farmMembers)..where((m) => m.farmId.equals(r.farmId) & m.userId.isNotNull())).watch().map(
        (list) => {for (final m in list) m.userId!: m},
      );

  Future<void> updateProfile({required String fullName, String? displayNameKn}) async {
    final name = fullName.trim();
    if (name.isEmpty || name.length > 100) throw const AppException('invalid_name');
    await r.write((ctx) async {
      final me = await r.me();
      if (me == null) throw const AppException('access_revoked');
      await (db.update(db.farmMembers)..where((m) => m.id.equals(me.id))).write(
        FarmMembersCompanion(
          fullName: Value(name),
          displayNameKn: Value(r.clean(displayNameKn, max: 100)),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
      await r.outbox.enqueue(
        ctx,
        opType: OpTypes.profileUpdate,
        entityTable: 'farm_members',
        entityId: me.id,
        coalesce: true,
        payload: {'full_name': name, 'display_name_kn': r.clean(displayNameKn, max: 100)},
      );
    });
  }

  Future<void> updateFarm({required String name, required int weekStartDay}) async {
    final n = name.trim();
    if (n.isEmpty || n.length > 120) throw const AppException('invalid_name');
    if (weekStartDay < 1 || weekStartDay > 7) throw const AppException('invalid_week');
    await r.write((ctx) async {
      if (!ctx.isAdmin) throw const AppException('forbidden');
      await (db.update(db.farms)..where((f) => f.id.equals(r.farmId))).write(
        FarmsCompanion(name: Value(n), weekStartDay: Value(weekStartDay), updatedAt: Value(DateTime.now().toUtc())),
      );
      await r.outbox.enqueue(
        ctx,
        opType: OpTypes.farmUpdate,
        entityTable: 'farms',
        entityId: r.farmId,
        coalesce: true,
        payload: {'name': n, 'week_start_day': weekStartDay},
      );
    });
  }

  Future<void> invite({required String email, required String fullName, String role = Roles.member}) async {
    final e = email.trim().toLowerCase();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(e)) throw const AppException('invalid_email');
    final name = fullName.trim();
    if (name.isEmpty || name.length > 100) throw const AppException('invalid_name');
    await r.write((ctx) async {
      if (!ctx.isAdmin) throw const AppException('forbidden');
      if (role == Roles.admin && ctx.role != Roles.owner) throw const AppException('forbidden');
      final dup = await (db.select(
        db.farmMembers,
      )..where((m) => m.farmId.equals(r.farmId) & m.email.equals(e))).getSingleOrNull();
      if (dup != null) throw const AppException('already_invited');
      final id = newId();
      final now = DateTime.now().toUtc();
      await db
          .into(db.farmMembers)
          .insert(
            FarmMembersCompanion.insert(
              id: id,
              farmId: r.farmId,
              email: e,
              role: role,
              status: 'invited',
              fullName: name,
              invitedBy: Value(ctx.userId),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await r.outbox.enqueue(
        ctx,
        opType: OpTypes.memberInvite,
        entityTable: 'farm_members',
        entityId: id,
        payload: {'id': id, 'email': e, 'full_name': name, 'role': role},
      );
    });
  }

  Future<void> updateMember(FarmMember m, {String? role, String? status}) async {
    await r.write((ctx) async {
      if (!ctx.isAdmin) throw const AppException('forbidden');
      if (m.userId == ctx.userId || m.role == Roles.owner) throw const AppException('cannot_change_owner_or_self');
      if ((role == Roles.admin || m.role == Roles.admin) && ctx.role != Roles.owner) {
        throw const AppException('forbidden');
      }
      await (db.update(db.farmMembers)..where((x) => x.id.equals(m.id))).write(
        FarmMembersCompanion(
          role: Value(role ?? m.role),
          status: Value(status ?? m.status),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
      await r.outbox.enqueue(
        ctx,
        opType: OpTypes.memberUpdate,
        entityTable: 'farm_members',
        entityId: m.id,
        coalesce: true,
        payload: {'id': m.id, 'role': role ?? m.role, 'status': status ?? m.status},
      );
    });
  }

  Stream<List<AuditEvent>> watchAudit({String? entityId, int limit = 100, int offset = 0}) {
    final q = db.select(db.auditEvents)..where((a) => a.farmId.equals(r.farmId));
    if (entityId != null) q.where((a) => a.entityId.equals(entityId));
    q
      ..orderBy([(a) => OrderingTerm.desc(a.createdAt)])
      ..limit(limit, offset: offset);
    return q.watch();
  }
}
