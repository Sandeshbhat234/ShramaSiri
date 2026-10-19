import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/dates.dart';
import '../../core/ids.dart';
import '../db/database.dart';

/// Outbox operation states.
abstract final class OpStatus {
  /// Saved on device, waiting to upload.
  static const pending = 'pending';

  /// Upload in progress (reset to pending if the app dies mid-upload).
  static const syncing = 'syncing';

  /// Server confirmed.
  static const synced = 'synced';

  /// Server reported a conflict with someone else's change.
  static const needsReview = 'needs_review';

  /// Transient failure; retried automatically with backoff.
  static const failed = 'failed';

  /// Server refused it; the user must decide what to do.
  static const rejected = 'rejected';

  /// The user resolved a conflict/rejection by dropping this change.
  static const discarded = 'discarded';

  /// Not yet confirmed and not dropped: the local change still matters.
  static const open = [pending, syncing, failed, needsReview, rejected];

  /// Eligible for upload.
  static const uploadable = [pending, failed];
}

abstract final class OpTypes {
  static const farmUpdate = 'farm_update';
  static const profileUpdate = 'profile_update';
  static const memberInvite = 'member_invite';
  static const memberUpdate = 'member_update';
  static const workerUpsert = 'worker_upsert';
  static const groupUpsert = 'group_upsert';
  static const attendanceUpsert = 'attendance_upsert';
  static const workTypeUpsert = 'work_type_upsert';
  static const workAssignmentUpsert = 'work_assignment_upsert';
  static const ledgerCreate = 'ledger_create';
  static const ledgerReverse = 'ledger_reverse';
  static const ledgerCorrect = 'ledger_correct';
  static const settlementClose = 'settlement_close';
  static const settlementReopen = 'settlement_reopen';
}

/// Who is writing, from which device, for which farm.
class WriteContext {
  const WriteContext({
    required this.farmId,
    required this.userId,
    required this.deviceId,
    required this.actorName,
    required this.role,
  });

  final String farmId;
  final String userId;
  final String deviceId;
  final String actorName;
  final String role;

  bool get isAdmin => role == 'owner' || role == 'admin';
}

class OutboxCounts {
  const OutboxCounts({this.pending = 0, this.needsAttention = 0, this.failed = 0});

  /// Waiting to upload (pending, syncing or retrying).
  final int pending;

  /// Conflicts and rejections the user must look at.
  final int needsAttention;

  /// Transient failures among [pending].
  final int failed;

  int get unsynced => pending + needsAttention;
}

class Outbox {
  Outbox(this.db);

  final AppDatabase db;

  /// Adds an operation. Call inside the same `db.transaction` as the local
  /// change so both commit or neither does.
  ///
  /// With [coalesce], a still-unattempted pending op of the same type for the
  /// same entity gets the new payload instead of adding another op. Ops that
  /// were attempted are never changed: the server may already have them.
  Future<String> enqueue(
    WriteContext ctx, {
    required String opType,
    required String entityTable,
    required String entityId,
    required Map<String, dynamic> payload,
    bool coalesce = false,
  }) async {
    final now = DateTime.now().toUtc();
    if (coalesce) {
      final existing =
          await (db.select(db.outboxOps)..where(
                (o) =>
                    o.opType.equals(opType) &
                    o.entityTable.equals(entityTable) &
                    o.entityId.equals(entityId) &
                    o.status.equals(OpStatus.pending) &
                    o.attempts.equals(0),
              ))
              .getSingleOrNull();
      if (existing != null) {
        await (db.update(db.outboxOps)..where((o) => o.seq.equals(existing.seq))).write(
          OutboxOpsCompanion(payload: Value(jsonEncode(payload)), updatedAt: Value(now)),
        );
        await refreshEntityStatus(entityTable, entityId);
        return existing.opId;
      }
    }
    final opId = newId();
    await db
        .into(db.outboxOps)
        .insert(
          OutboxOpsCompanion.insert(
            opId: opId,
            farmId: ctx.farmId,
            actorId: ctx.userId,
            deviceId: ctx.deviceId,
            opType: opType,
            entityTable: entityTable,
            entityId: entityId,
            payload: jsonEncode(payload),
            status: OpStatus.pending,
            createdAt: now,
            updatedAt: now,
          ),
        );
    await refreshEntityStatus(entityTable, entityId);
    return opId;
  }

  /// Whether this entity has local changes the server has not confirmed.
  Future<bool> hasOpenOps(String entityTable, String entityId, {int? exceptSeq}) async {
    final rows = await db
        .customSelect(
          'SELECT 1 FROM outbox_ops WHERE entity_table = ? AND entity_id = ? '
          "AND status IN ('pending','syncing','failed','needs_review','rejected') "
          '${exceptSeq != null ? 'AND seq <> ? ' : ''}LIMIT 1',
          variables: [Variable(entityTable), Variable(entityId), if (exceptSeq != null) Variable(exceptSeq)],
          readsFrom: {db.outboxOps},
        )
        .get();
    return rows.isNotEmpty;
  }

  /// Recomputes the row-level sync_status from the entity's open operations.
  Future<void> refreshEntityStatus(String entityTable, String entityId) async {
    final rows = await db
        .customSelect(
          'SELECT status FROM outbox_ops WHERE entity_table = ? AND entity_id = ? '
          "AND status IN ('pending','syncing','failed','needs_review','rejected')",
          variables: [Variable(entityTable), Variable(entityId)],
          readsFrom: {db.outboxOps},
        )
        .get();
    final statuses = rows.map((r) => r.read<String>('status')).toSet();
    final value = statuses.contains(OpStatus.rejected)
        ? RowSync.rejected
        : statuses.contains(OpStatus.needsReview)
        ? RowSync.needsReview
        : statuses.isNotEmpty
        ? RowSync.pending
        : RowSync.synced;
    final keyColumn = _keyColumn(entityTable);
    if (keyColumn == null) return;
    await db.customUpdate(
      'UPDATE $entityTable SET sync_status = ? WHERE $keyColumn = ? AND sync_status <> ?',
      variables: [Variable(value), Variable(entityId), Variable(value)],
      updates: {_tableInfo(entityTable)},
    );
  }

  /// Gives [toId] the same sync_status as [fromId] (a correction's reversal
  /// row follows the single operation that carries both rows).
  Future<void> mirrorStatus(String table, String fromId, String toId) async {
    await db.customUpdate(
      'UPDATE $table SET sync_status = (SELECT sync_status FROM $table WHERE id = ?) WHERE id = ?',
      variables: [Variable(fromId), Variable(toId)],
      updates: {_tableInfo(table)},
    );
  }

  String? _keyColumn(String table) => const {
    'farms': 'id',
    'farm_members': 'id',
    'workers': 'id',
    'worker_groups': 'id',
    'attendance': 'id',
    'work_types': 'id',
    'work_assignments': 'id',
    'financial_transactions': 'id',
    'settlements': 'id',
  }[table];

  TableInfo _tableInfo(String table) => db.allTables.firstWhere((t) => t.actualTableName == table);

  Stream<OutboxCounts> watchCounts() {
    return db
        .customSelect(
          "SELECT status, COUNT(*) AS c FROM outbox_ops WHERE status IN ('pending','syncing','failed','needs_review','rejected') GROUP BY status",
          readsFrom: {db.outboxOps},
        )
        .watch()
        .map((rows) {
          var pending = 0, attention = 0, failed = 0;
          for (final r in rows) {
            final s = r.read<String>('status');
            final c = r.read<int>('c');
            if (s == OpStatus.needsReview || s == OpStatus.rejected) {
              attention += c;
            } else {
              pending += c;
              if (s == OpStatus.failed) failed += c;
            }
          }
          return OutboxCounts(pending: pending, needsAttention: attention, failed: failed);
        });
  }

  Future<int> unsyncedCount() async {
    final row = await db
        .customSelect(
          "SELECT COUNT(*) AS c FROM outbox_ops WHERE status IN ('pending','syncing','failed','needs_review','rejected')",
        )
        .getSingle();
    return row.read<int>('c');
  }

  /// Ops interrupted by an app kill are safe to resend (server is idempotent).
  Future<void> resetInterrupted() async {
    await (db.update(db.outboxOps)..where((o) => o.status.equals(OpStatus.syncing))).write(
      const OutboxOpsCompanion(status: Value(OpStatus.pending)),
    );
  }

  /// Synced ops are kept for diagnostics, then trimmed. Unsynced ops are never
  /// removed automatically.
  Future<void> trimSynced({Duration keep = const Duration(days: 30)}) async {
    final cutoff = AppClock.nowUtc().subtract(keep);
    await (db.delete(db.outboxOps)
          ..where((o) => o.status.isIn([OpStatus.synced, OpStatus.discarded]) & o.updatedAt.isSmallerThanValue(cutoff)))
        .go();
  }
}
