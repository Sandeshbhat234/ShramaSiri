import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/ids.dart';
import '../db/database.dart';
import 'change_applier.dart';
import 'outbox.dart';
import 'sync_engine.dart';

/// An operation the user must look at, with both versions when available.
class AttentionItem {
  AttentionItem(this.op);

  final OutboxOp op;

  Map<String, dynamic> get payload => jsonDecode(op.payload) as Map<String, dynamic>;

  Map<String, dynamic> get conflict =>
      op.conflictData == null ? const {} : jsonDecode(op.conflictData!) as Map<String, dynamic>;

  String? get code => op.lastErrorCode;

  bool get isConflict => op.status == OpStatus.needsReview;

  /// Server rows returned with the conflict (the other person's version).
  List<ServerRow> get serverRows => ((conflict['rows'] as List?) ?? const [])
      .cast<Map>()
      .map((m) => ServerRow.fromJson(Map<String, dynamic>.from(m)))
      .toList();

  /// "Keep mine" is meaningful when someone else changed the same record.
  bool get canKeepMine => isConflict && (code == 'stale_revision' || code == 'attendance_exists');

  /// Rejections may succeed later (e.g. after more money is entrusted).
  bool get canRetry => op.status == OpStatus.rejected || op.status == OpStatus.failed;
}

class ConflictResolver {
  ConflictResolver(this.db, this.outbox) : applier = ChangeApplier(db, outbox);

  final AppDatabase db;
  final Outbox outbox;
  final ChangeApplier applier;

  Stream<List<AttentionItem>> watchAttention() {
    return (db.select(db.outboxOps)
          ..where(
            (o) =>
                o.status.isIn([OpStatus.needsReview, OpStatus.rejected]) |
                (o.status.equals(OpStatus.failed) & o.attempts.isBiggerOrEqualValue(3)),
          )
          ..orderBy([(o) => OrderingTerm.asc(o.seq)]))
        .watch()
        .map((ops) => ops.map(AttentionItem.new).toList());
  }

  /// Re-send my version on top of the other person's (they stay in the audit
  /// trail on the server).
  Future<void> keepMine(AttentionItem item) async {
    if (!item.canKeepMine) throw StateError('Cannot keep mine for ${item.code}');
    final server = item.serverRows.where((r) => r.table == item.op.entityTable).firstOrNull;
    if (server == null) throw StateError('Missing server version');
    final now = DateTime.now().toUtc();

    await db.transaction(() async {
      var entityId = item.op.entityId;
      var payload = item.payload;
      if (item.code == 'attendance_exists') {
        // Adopt the existing server record's id, keep my values.
        final serverId = server.data['id'] as String;
        await db.customUpdate(
          'DELETE FROM attendance WHERE id = ?',
          variables: [Variable(entityId)],
          updates: {db.attendance},
          updateKind: UpdateKind.delete,
        );
        await applier.forceApply(server);
        final units = payload['units_milli'] as int;
        final rate = payload['rate_paise'] as int;
        await (db.update(db.attendance)..where((a) => a.id.equals(serverId))).write(
          AttendanceCompanion(
            unitsMilli: Value(units),
            ratePaise: Value(rate),
            earnedPaise: Value((rate * units + 500) ~/ 1000),
            notes: Value(payload['notes'] as String?),
          ),
        );
        payload = {...payload, 'id': serverId};
        entityId = serverId;
      } else {
        // Same record changed elsewhere: rebase my change on their revision.
        await db.customUpdate(
          'UPDATE ${item.op.entityTable} SET revision = ?, server_seq = ? WHERE id = ?',
          variables: [Variable(server.data['revision'] as int), Variable(server.serverSeq), Variable(entityId)],
          updates: {_info(item.op.entityTable)},
        );
        await db.customUpdate(
          'DELETE FROM server_shadows WHERE tbl = ? AND row_key = ?',
          variables: [Variable(item.op.entityTable), Variable(entityId)],
          updates: {db.serverShadows},
        );
      }
      // Same queue position, new op id (the old id's outcome is final on the server).
      await (db.update(db.outboxOps)..where((o) => o.seq.equals(item.op.seq))).write(
        OutboxOpsCompanion(
          opId: Value(newId()),
          entityId: Value(entityId),
          payload: Value(jsonEncode(payload)),
          status: const Value(OpStatus.pending),
          attempts: const Value(0),
          nextAttemptAt: const Value(null),
          lastErrorCode: const Value(null),
          conflictData: const Value(null),
          updatedAt: Value(now),
        ),
      );
      await outbox.refreshEntityStatus(item.op.entityTable, entityId);
    });
  }

  /// Try a rejected or repeatedly failing operation again.
  Future<void> retry(AttentionItem item) async {
    await db.transaction(() async {
      await (db.update(db.outboxOps)..where((o) => o.seq.equals(item.op.seq))).write(
        OutboxOpsCompanion(
          opId: item.op.status == OpStatus.rejected ? Value(newId()) : const Value.absent(),
          status: const Value(OpStatus.pending),
          attempts: const Value(0),
          nextAttemptAt: const Value(null),
          conflictData: const Value(null),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
      await outbox.refreshEntityStatus(item.op.entityTable, item.op.entityId);
    });
  }

  /// Drop my change and use the server's version. Later local changes to the
  /// same record were built on top of the dropped one, so they are dropped too.
  Future<void> discardMine(AttentionItem item) async {
    final now = DateTime.now().toUtc();
    final refetch = <Map<String, String>>[];
    await db.transaction(() async {
      final related =
          await (db.select(db.outboxOps)..where(
                (o) =>
                    o.entityTable.equals(item.op.entityTable) &
                    o.entityId.equals(item.op.entityId) &
                    o.seq.isBiggerOrEqualValue(item.op.seq) &
                    o.status.isIn(OpStatus.open),
              ))
              .get();
      for (final op in related) {
        await (db.update(db.outboxOps)..where((o) => o.seq.equals(op.seq))).write(
          OutboxOpsCompanion(status: const Value(OpStatus.discarded), updatedAt: Value(now)),
        );
      }

      for (final row in item.serverRows) {
        await applier.forceApply(row);
      }

      final table = item.op.entityTable;
      final id = item.op.entityId;
      final ids = <String>[id];
      if (item.op.opType == OpTypes.ledgerCorrect) {
        final reversalId = (item.payload['reverse'] as Map?)?['id'] as String?;
        if (reversalId != null) ids.add(reversalId);
      }
      for (final entityId in ids) {
        final local = await db
            .customSelect('SELECT server_seq FROM $table WHERE id = ?', variables: [Variable(entityId)])
            .getSingleOrNull();
        final neverSynced = local != null && local.read<int>('server_seq') == 0;
        final coveredByConflict = item.serverRows.any((r) => r.table == table && r.data['id'] == entityId);
        if (neverSynced && !coveredByConflict) {
          await _deleteLocal(table, entityId);
        } else if (!coveredByConflict) {
          final shadow = await applier.shadowFor(table, entityId);
          if (shadow != null) {
            await applier.forceApply(ServerRow(table, shadow));
          } else if (local != null) {
            refetch.add({'table': table, 'column': 'id', 'value': entityId});
          }
        }
        final child = _childTable[table];
        if (child != null && local != null && !neverSynced) {
          refetch.add({'table': child.$1, 'column': child.$2, 'value': entityId});
        }
        await outbox.refreshEntityStatus(table, entityId);
      }
      await applier.reconcileShadows();

      if (refetch.isNotEmpty) {
        final raw = await db.getKv(SyncEngine.refetchQueueKey);
        final queue = raw == null ? <dynamic>[] : jsonDecode(raw) as List;
        queue.addAll(refetch);
        await db.setKv(SyncEngine.refetchQueueKey, jsonEncode(queue));
      }
    });
  }

  static const _childTable = {
    'worker_groups': ('worker_group_memberships', 'group_id'),
    'work_assignments': ('work_assignment_workers', 'assignment_id'),
  };

  Future<void> _deleteLocal(String table, String id) async {
    await db.customUpdate(
      'DELETE FROM $table WHERE id = ?',
      variables: [Variable(id)],
      updates: {_info(table)},
      updateKind: UpdateKind.delete,
    );
    final child = _childTable[table];
    if (child != null) {
      await db.customUpdate(
        'DELETE FROM ${child.$1} WHERE ${child.$2} = ?',
        variables: [Variable(id)],
        updates: {_info(child.$1)},
        updateKind: UpdateKind.delete,
      );
    }
  }

  TableInfo _info(String table) => db.allTables.firstWhere((t) => t.actualTableName == table);
}
