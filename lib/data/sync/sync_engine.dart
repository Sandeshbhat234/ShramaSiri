import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../../core/dates.dart';
import '../db/database.dart';
import '../remote/remote_api.dart';
import 'change_applier.dart';
import 'outbox.dart';

enum SyncPhase {
  /// Everything known has been exchanged (or nothing to do yet).
  idle,
  syncing,

  /// Server not reachable; changes stay saved on the device.
  offline,

  /// Session expired; the user must sign in again to upload.
  signInRequired,

  /// The farm membership was disabled or removed.
  accessRevoked,

  /// Server error; retrying automatically.
  error,
}

@immutable
class SyncState {
  const SyncState({this.phase = SyncPhase.idle, this.lastSyncAt, this.lastError});

  final SyncPhase phase;
  final DateTime? lastSyncAt;
  final String? lastError;

  SyncState copyWith({SyncPhase? phase, DateTime? lastSyncAt, String? lastError, bool clearError = false}) => SyncState(
    phase: phase ?? this.phase,
    lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    lastError: clearError ? null : (lastError ?? this.lastError),
  );
}

/// Uploads the outbox and downloads farm changes. Only one cycle runs at a
/// time per engine; requests made while a cycle runs are folded into one
/// follow-up cycle.
class SyncEngine {
  SyncEngine({
    required this.db,
    required this.remote,
    required this.farmId,
    required this.userId,
    Outbox? outbox,
    this.batchSize = 25,
    this.pullLimit = 500,
    this.autoRetry = true,
    Random? random,
  }) : outbox = outbox ?? Outbox(db),
       _random = random ?? Random() {
    applier = ChangeApplier(db, this.outbox);
  }

  final AppDatabase db;
  final RemoteApi remote;
  final String farmId;
  final String userId;
  final Outbox outbox;
  late final ChangeApplier applier;
  final int batchSize;
  final int pullLimit;
  final bool autoRetry;
  final Random _random;

  final _states = StreamController<SyncState>.broadcast();
  SyncState _state = const SyncState();
  Future<void>? _running;
  bool _again = false;
  bool _disposed = false;
  int _failureStreak = 0;
  Timer? _retryTimer;

  SyncState get state => _state;
  Stream<SyncState> get states => _states.stream;
  bool get isRunning => _running != null;

  Future<void> init() async {
    await outbox.resetInterrupted();
    final last = await db.getKv(KvKeys.lastSyncAt);
    final skew = int.tryParse(await db.getKv(KvKeys.serverSkewMs) ?? '');
    if (skew != null) AppClock.skew = Duration(milliseconds: skew);
    _emit(_state.copyWith(lastSyncAt: last == null ? null : DateTime.parse(last)));
  }

  void dispose() {
    _disposed = true;
    _retryTimer?.cancel();
    _states.close();
  }

  /// Runs a sync cycle now (or right after the current one).
  Future<void> sync() {
    if (_disposed) return Future.value();
    _retryTimer?.cancel();
    final running = _running;
    if (running != null) {
      _again = true;
      return running;
    }
    final future = _loop();
    _running = future;
    return future.whenComplete(() => _running = null);
  }

  Future<void> _loop() async {
    do {
      _again = false;
      await _cycle();
    } while (_again && !_disposed);
  }

  void _emit(SyncState s) {
    _state = s;
    if (!_disposed) _states.add(s);
  }

  Future<void> _cycle() async {
    _emit(_state.copyWith(phase: SyncPhase.syncing, clearError: true));
    try {
      // Only one cycle runs at a time, so anything still marked syncing was
      // interrupted and is safe to resend.
      await outbox.resetInterrupted();
      final verified = await _verifyAccess();
      if (!verified) {
        _emit(_state.copyWith(phase: SyncPhase.accessRevoked));
        return;
      }
      await _push();
      await _pull();
      await db.transaction(() => applier.reconcileShadows());
      await _processRefetches();
      await outbox.trimSynced();
      final now = AppClock.nowUtc();
      await db.setKv(KvKeys.lastSyncAt, now.toIso8601String());
      _failureStreak = 0;
      _emit(SyncState(phase: SyncPhase.idle, lastSyncAt: now));
    } on RemoteError catch (e) {
      await _handleCycleError(e);
    } catch (e, st) {
      debugPrint('sync failed: $e\n$st');
      _emit(_state.copyWith(phase: SyncPhase.error, lastError: 'unexpected'));
      _scheduleRetry();
    }
  }

  Future<void> _handleCycleError(RemoteError e) async {
    switch (e.kind) {
      case RemoteErrorKind.auth:
        bool refreshed;
        try {
          refreshed = await remote.refreshSession();
        } on RemoteError {
          _emit(_state.copyWith(phase: SyncPhase.offline));
          _scheduleRetry();
          return;
        }
        if (refreshed && _failureStreak < 2) {
          _failureStreak++;
          _again = true;
        } else {
          _emit(_state.copyWith(phase: SyncPhase.signInRequired, lastError: e.code ?? 'auth'));
        }
      case RemoteErrorKind.forbidden:
        // Membership changed between verification and the request: re-verify.
        await db.setKv(KvKeys.accessRevoked, '1');
        _emit(_state.copyWith(phase: SyncPhase.accessRevoked));
      case RemoteErrorKind.network:
        _emit(_state.copyWith(phase: SyncPhase.offline));
        _scheduleRetry();
      case RemoteErrorKind.server:
      case RemoteErrorKind.invalid:
        _emit(_state.copyWith(phase: SyncPhase.error, lastError: e.code ?? e.kind.name));
        _scheduleRetry();
    }
  }

  void _scheduleRetry() {
    if (!autoRetry || _disposed) return;
    _failureStreak++;
    final seconds = min(600, 10 * pow(2, min(_failureStreak - 1, 6)).toInt());
    final jittered = (seconds * (0.5 + _random.nextDouble())).round();
    _retryTimer?.cancel();
    _retryTimer = Timer(Duration(seconds: jittered), () => sync());
  }

  /// Revalidates membership before any upload. Returns false when this user
  /// may no longer write to (or read) the farm.
  Future<bool> _verifyAccess() async {
    final sent = DateTime.now().toUtc();
    final ctx = await remote.getMyContext();
    final received = DateTime.now().toUtc();
    final serverTime = DateTime.tryParse(ctx['server_time'] as String? ?? '');
    if (serverTime != null) {
      final localMid = sent.add(received.difference(sent) ~/ 2);
      final skew = serverTime.toUtc().difference(localMid);
      AppClock.skew = skew;
      await db.setKv(KvKeys.serverSkewMs, skew.inMilliseconds.toString());
    }
    if (ctx['user_id'] != userId) return false;
    final memberships = (ctx['memberships'] as List? ?? const []).cast<Map<String, dynamic>>();
    final mine = memberships.where((m) => m['farm_id'] == farmId).firstOrNull;
    final ok = mine != null && mine['status'] == 'active' && const ['owner', 'admin', 'member'].contains(mine['role']);
    await db.setKv(KvKeys.accessRevoked, ok ? null : '1');
    if (ok) await db.setKv(KvKeys.lastVerifiedAt, AppClock.nowUtc().toIso8601String());
    return ok;
  }

  // ---------------------------------------------------------------------------
  // Upload
  // ---------------------------------------------------------------------------

  Future<void> _push() async {
    for (var i = 0; i < 200; i++) {
      final batch = await _nextBatch();
      if (batch.isEmpty) return;
      final wire = <Map<String, dynamic>>[];
      await db.transaction(() async {
        final now = DateTime.now().toUtc();
        for (final op in batch) {
          await (db.update(db.outboxOps)..where((o) => o.seq.equals(op.seq))).write(
            OutboxOpsCompanion(
              status: const Value(OpStatus.syncing),
              attempts: Value(op.attempts + 1),
              updatedAt: Value(now),
            ),
          );
          wire.add(await _toWire(op));
        }
      });

      List<Map<String, dynamic>> results;
      try {
        results = await remote.applyOps(wire);
      } on RemoteError catch (e) {
        // The server may or may not have committed: the ops stay queued and
        // are resent with the same op ids, which the server deduplicates.
        await db.transaction(() async {
          for (final op in batch) {
            await _markRetry(
              op,
              e.kind == RemoteErrorKind.network ? null : e.code ?? e.kind.name,
              backoff: e.kind != RemoteErrorKind.network,
            );
          }
        });
        rethrow;
      }

      final byId = {for (final r in results) r['op_id']?.toString(): r};
      var stop = false;
      await db.transaction(() async {
        for (final op in batch) {
          final r = byId[op.opId];
          if (r == null) {
            await _markRetry(op, 'no_result', backoff: true);
            continue;
          }
          if (await _handleResult(op, r)) stop = true;
        }
      });
      if (stop) return;
    }
  }

  /// Next ops to send, in creation order. Ops for entities waiting on a
  /// conflict/rejection decision are skipped. The batch stops (rather than
  /// skipping ahead) at an op that must wait, so dependent operations never
  /// overtake the operations they depend on. At most one op per entity is
  /// sent per batch so its base revision is always current.
  Future<List<OutboxOp>> _nextBatch() async {
    final blockedRows = await db
        .customSelect(
          "SELECT DISTINCT entity_table, entity_id FROM outbox_ops WHERE status IN ('needs_review','rejected')",
        )
        .get();
    final blocked = {for (final r in blockedRows) '${r.read<String>('entity_table')}/${r.read<String>('entity_id')}'};
    final candidates =
        await (db.select(db.outboxOps)
              ..where((o) => o.farmId.equals(farmId) & o.actorId.equals(userId) & o.status.isIn(OpStatus.uploadable))
              ..orderBy([(o) => OrderingTerm.asc(o.seq)])
              ..limit(batchSize * 4))
            .get();
    final now = DateTime.now().toUtc();
    final picked = <OutboxOp>[];
    final inBatch = <String>{};
    for (final op in candidates) {
      final key = '${op.entityTable}/${op.entityId}';
      if (blocked.contains(key)) continue;
      if (inBatch.contains(key)) break;
      if (op.status == OpStatus.failed && op.nextAttemptAt != null && op.nextAttemptAt!.isAfter(now)) break;
      picked.add(op);
      inBatch.add(key);
      if (picked.length >= batchSize) break;
    }
    return picked;
  }

  Future<Map<String, dynamic>> _toWire(OutboxOp op) async {
    return {
      'op_id': op.opId,
      'farm_id': op.farmId,
      'op_type': op.opType,
      'entity_id': op.entityId,
      'device_id': op.deviceId,
      'base_revision': await _baseRevision(op),
      'payload': jsonDecode(op.payload),
      'client_created_at': op.createdAt.toIso8601String(),
    };
  }

  /// The server revision the local edit was made against, read at send time
  /// (earlier ops for the entity have been confirmed by then).
  Future<int> _baseRevision(OutboxOp op) async {
    const versioned = {
      'farms',
      'farm_members',
      'workers',
      'worker_groups',
      'attendance',
      'work_types',
      'work_assignments',
    };
    if (!versioned.contains(op.entityTable)) return 0;
    final row = await db
        .customSelect('SELECT revision FROM ${op.entityTable} WHERE id = ?', variables: [Variable(op.entityId)])
        .getSingleOrNull();
    return row?.read<int>('revision') ?? 0;
  }

  Duration _backoff(int attempts) {
    final seconds = min(900, 5 * pow(2, min(attempts, 10)).toInt());
    return Duration(milliseconds: (seconds * 1000 * (0.5 + _random.nextDouble())).round());
  }

  Future<void> _markRetry(OutboxOp op, String? code, {required bool backoff}) async {
    final attempts = op.attempts + 1;
    await (db.update(db.outboxOps)..where((o) => o.seq.equals(op.seq))).write(
      OutboxOpsCompanion(
        status: Value(backoff ? OpStatus.failed : OpStatus.pending),
        nextAttemptAt: Value(backoff ? DateTime.now().toUtc().add(_backoff(attempts)) : null),
        lastErrorCode: Value(code),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  /// Records the server's answer for one op. Returns true when uploading
  /// should stop for this cycle.
  Future<bool> _handleResult(OutboxOp op, Map<String, dynamic> r) async {
    final status = r['status'] as String?;
    final code = r['code'] as String?;
    final rows = ((r['rows'] as List?) ?? const [])
        .cast<Map>()
        .map((m) => ServerRow.fromJson(Map<String, dynamic>.from(m)))
        .toList();
    final now = DateTime.now().toUtc();
    final where = db.update(db.outboxOps)..where((o) => o.seq.equals(op.seq));

    switch (status) {
      case 'applied':
        await where.write(
          OutboxOpsCompanion(
            status: const Value(OpStatus.synced),
            syncedAt: Value(now),
            updatedAt: Value(now),
            lastErrorCode: const Value(null),
            conflictData: const Value(null),
            nextAttemptAt: const Value(null),
          ),
        );
        await _refreshStatuses(op);
        await applier.applyRows(rows, fromOwnOp: true);
        return false;
      case 'conflict':
        await where.write(
          OutboxOpsCompanion(
            status: const Value(OpStatus.needsReview),
            lastErrorCode: Value(code),
            conflictData: Value(jsonEncode({'code': code, 'rows': r['rows'] ?? const [], 'data': r['data']})),
            updatedAt: Value(now),
          ),
        );
        await _refreshStatuses(op);
        await applier.applyRows(rows);
        return false;
      case 'rejected':
        if (code == 'not_a_member') {
          await _markRetry(op, code, backoff: false);
          await db.setKv(KvKeys.accessRevoked, '1');
          return true;
        }
        await where.write(
          OutboxOpsCompanion(
            status: const Value(OpStatus.rejected),
            lastErrorCode: Value(code),
            conflictData: Value(jsonEncode({'code': code, 'rows': r['rows'] ?? const [], 'data': r['data']})),
            updatedAt: Value(now),
          ),
        );
        await _refreshStatuses(op);
        return false;
      default:
        await _markRetry(op, code ?? 'server_error', backoff: true);
        return false;
    }
  }

  Future<void> _refreshStatuses(OutboxOp op) async {
    await outbox.refreshEntityStatus(op.entityTable, op.entityId);
    if (op.opType == OpTypes.ledgerCorrect) {
      final p = jsonDecode(op.payload) as Map<String, dynamic>;
      final reversalId = (p['reverse'] as Map?)?['id'] as String?;
      if (reversalId != null) await outbox.mirrorStatus('financial_transactions', op.entityId, reversalId);
    }
  }

  // ---------------------------------------------------------------------------
  // Download
  // ---------------------------------------------------------------------------

  Future<void> _pull() async {
    var cursor = int.tryParse(await db.getKv(KvKeys.pullCursor) ?? '') ?? 0;
    for (var i = 0; i < 10000; i++) {
      final page = await remote.pullChanges(farmId, cursor, limit: pullLimit);
      await db.transaction(() async {
        await applier.applyRows(
          page.changes.map((c) => ServerRow(c['t'] as String, Map<String, dynamic>.from(c['d'] as Map))),
        );
        await db.setKv(KvKeys.pullCursor, page.lastSeq.toString());
      });
      cursor = page.lastSeq;
      if (!page.hasMore) break;
    }
    await db.setKv(KvKeys.initialSyncDone, '1');
  }

  /// Restores server copies of rows whose local change was discarded while
  /// no server copy was available on the device.
  Future<void> _processRefetches() async {
    final raw = await db.getKv(refetchQueueKey);
    if (raw == null) return;
    final queue = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    for (final item in queue) {
      final table = item['table'] as String;
      final column = item['column'] as String;
      final value = item['value'] as String;
      final rows = await remote.fetchRows(table, column, value);
      await db.transaction(() async {
        for (final row in rows) {
          await applier.forceApply(ServerRow(table, row));
        }
      });
    }
    await db.setKv(refetchQueueKey, null);
  }

  static const refetchQueueKey = 'refetch_queue';
}
