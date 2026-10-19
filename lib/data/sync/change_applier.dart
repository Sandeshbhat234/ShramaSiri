import 'dart:convert';

import 'package:drift/drift.dart';

import '../db/database.dart';
import 'outbox.dart';

/// How a synced table maps between server JSON and the local mirror.
class TableSpec {
  const TableSpec({
    required this.name,
    required this.fromJson,
    required this.keyColumns,
    required this.entity,
    this.hasRevision = true,
    this.naturalKey,
  });

  final String name;
  final Insertable<dynamic> Function(Map<String, dynamic> json) fromJson;
  final List<String> keyColumns;

  /// The outbox entity whose pending changes protect this row.
  final (String, String) Function(Map<String, dynamic> json) entity;
  final bool hasRevision;

  /// Extra unique key (besides the primary key) that another row could hold.
  final List<String>? naturalKey;

  String rowKey(Map<String, dynamic> json) => keyColumns.map((c) => json[c].toString()).join('|');
}

(String, String) _self(String table) => (table, '');

final Map<String, TableSpec> tableSpecs = {
  for (final s in <TableSpec>[
    TableSpec(
      name: 'farms',
      fromJson: (j) => Farm.fromJson(j, serializer: serverJson),
      keyColumns: const ['id'],
      entity: (j) => ('farms', j['id'] as String),
    ),
    TableSpec(
      name: 'farm_members',
      fromJson: (j) => FarmMember.fromJson(j, serializer: serverJson),
      keyColumns: const ['id'],
      entity: (j) => ('farm_members', j['id'] as String),
    ),
    TableSpec(
      name: 'workers',
      fromJson: (j) => Worker.fromJson(j, serializer: serverJson),
      keyColumns: const ['id'],
      entity: (j) => ('workers', j['id'] as String),
    ),
    TableSpec(
      name: 'worker_groups',
      fromJson: (j) => WorkerGroup.fromJson(j, serializer: serverJson),
      keyColumns: const ['id'],
      entity: (j) => ('worker_groups', j['id'] as String),
    ),
    TableSpec(
      name: 'worker_group_memberships',
      fromJson: (j) => GroupMembership.fromJson(j, serializer: serverJson),
      keyColumns: const ['group_id', 'worker_id'],
      entity: (j) => ('worker_groups', j['group_id'] as String),
      hasRevision: false,
    ),
    TableSpec(
      name: 'attendance',
      fromJson: (j) => AttendanceRow.fromJson(j, serializer: serverJson),
      keyColumns: const ['id'],
      entity: (j) => ('attendance', j['id'] as String),
      naturalKey: const ['farm_id', 'worker_id', 'work_date'],
    ),
    TableSpec(
      name: 'work_types',
      fromJson: (j) => WorkType.fromJson(j, serializer: serverJson),
      keyColumns: const ['id'],
      entity: (j) => ('work_types', j['id'] as String),
    ),
    TableSpec(
      name: 'work_assignments',
      fromJson: (j) => WorkAssignment.fromJson(j, serializer: serverJson),
      keyColumns: const ['id'],
      entity: (j) => ('work_assignments', j['id'] as String),
    ),
    TableSpec(
      name: 'work_assignment_workers',
      fromJson: (j) => AssignmentWorker.fromJson(j, serializer: serverJson),
      keyColumns: const ['assignment_id', 'worker_id'],
      entity: (j) => ('work_assignments', j['assignment_id'] as String),
      hasRevision: false,
    ),
    TableSpec(
      name: 'financial_transactions',
      fromJson: (j) => LedgerEntry.fromJson(j, serializer: serverJson),
      keyColumns: const ['id'],
      entity: (j) => ('financial_transactions', j['id'] as String),
      hasRevision: false,
    ),
    TableSpec(
      name: 'settlements',
      fromJson: (j) => Settlement.fromJson(j, serializer: serverJson),
      keyColumns: const ['id'],
      entity: (j) => ('settlements', j['id'] as String),
      naturalKey: const ['farm_id', 'week_start'],
    ),
    TableSpec(
      name: 'settlement_items',
      fromJson: (j) => SettlementItem.fromJson(j, serializer: serverJson),
      keyColumns: const ['settlement_id', 'worker_id'],
      entity: (j) => ('settlements', j['settlement_id'] as String),
      hasRevision: false,
    ),
    TableSpec(
      name: 'audit_events',
      fromJson: (j) => AuditEvent.fromJson(j, serializer: serverJson),
      keyColumns: const ['id'],
      entity: (j) => _self('audit_events'),
      hasRevision: false,
    ),
  ])
    s.name: s,
};

class ServerRow {
  ServerRow(this.table, this.data);

  factory ServerRow.fromJson(Map<String, dynamic> j) =>
      ServerRow(j['t'] as String, Map<String, dynamic>.from(j['d'] as Map));

  final String table;
  final Map<String, dynamic> data;

  int get serverSeq => (data['server_seq'] as num?)?.toInt() ?? 0;
}

/// Applies server rows to the local database without ever overwriting
/// changes this device has not uploaded yet.
class ChangeApplier {
  ChangeApplier(this.db, this.outbox);

  final AppDatabase db;
  final Outbox outbox;

  TableInfo _info(String table) => db.allTables.firstWhere((t) => t.actualTableName == table);

  /// Applies [rows]. Call inside a transaction.
  ///
  /// [fromOwnOp]: the rows are the server's answer to one of our operations
  /// (so their revision is the base for any later local edits).
  Future<void> applyRows(Iterable<ServerRow> rows, {bool fromOwnOp = false}) async {
    for (final row in rows) {
      await _applyOne(row, fromOwnOp: fromOwnOp);
    }
  }

  Future<void> _applyOne(ServerRow row, {required bool fromOwnOp}) async {
    final spec = tableSpecs[row.table];
    if (spec == null) return; // table from a newer server version; ignore safely
    final json = Map<String, dynamic>.from(row.data)..['sync_status'] = RowSync.synced;
    final key = spec.rowKey(json);
    final (entityTable, entityId) = spec.entity(json);
    final protected = entityId.isNotEmpty && await outbox.hasOpenOps(entityTable, entityId);
    final localSeq = await _localSeq(spec, json);

    if (protected) {
      if (fromOwnOp && spec.hasRevision && localSeq != null && row.serverSeq > localSeq) {
        // Our earlier op was accepted; later local edits now build on this revision.
        await db.customUpdate(
          'UPDATE ${spec.name} SET revision = ?, server_seq = ? WHERE id = ?',
          variables: [Variable(json['revision'] as int), Variable(row.serverSeq), Variable(json['id'] as String)],
          updates: {_info(spec.name)},
        );
      }
      await _saveShadow(spec, key, json, row.serverSeq);
      return;
    }

    if (localSeq != null && localSeq > row.serverSeq) return; // stale copy

    if (spec.naturalKey != null) {
      final blocked = await _clearNaturalKeyCollision(spec, json);
      if (blocked) {
        await _saveShadow(spec, key, json, row.serverSeq);
        return;
      }
    }

    await db.into(_info(spec.name)).insertOnConflictUpdate(spec.fromJson(json));
    await _exec('DELETE FROM server_shadows WHERE tbl = ? AND row_key = ? AND server_seq <= ?', [
      spec.name,
      key,
      row.serverSeq,
    ], 'server_shadows');
  }

  Future<int?> _localSeq(TableSpec spec, Map<String, dynamic> json) async {
    final where = spec.keyColumns.map((c) => '$c = ?').join(' AND ');
    final res = await db
        .customSelect(
          'SELECT server_seq FROM ${spec.name} WHERE $where',
          variables: [for (final c in spec.keyColumns) Variable(json[c].toString())],
        )
        .getSingleOrNull();
    return res?.read<int>('server_seq');
  }

  /// Another local row may hold the same natural key (e.g. this device marked
  /// attendance for the same worker and day offline). If that row still has
  /// unsynced changes, the server row is held back (returns true) so the
  /// conflict can be resolved; otherwise the stale local row is replaced.
  Future<bool> _clearNaturalKeyCollision(TableSpec spec, Map<String, dynamic> json) async {
    final cols = spec.naturalKey!;
    final where = cols.map((c) => '$c = ?').join(' AND ');
    final others = await db
        .customSelect(
          'SELECT id FROM ${spec.name} WHERE $where AND id <> ?',
          variables: [for (final c in cols) Variable(json[c].toString()), Variable(json['id'] as String)],
        )
        .get();
    for (final other in others) {
      final otherId = other.read<String>('id');
      if (await outbox.hasOpenOps(spec.name, otherId)) return true;
      await _exec('DELETE FROM ${spec.name} WHERE id = ?', [otherId], spec.name);
      if (spec.name == 'settlements') {
        await _exec('DELETE FROM settlement_items WHERE settlement_id = ?', [otherId], 'settlement_items');
      }
    }
    return false;
  }

  Future<void> _saveShadow(TableSpec spec, String key, Map<String, dynamic> json, int seq) async {
    final existing = await (db.select(
      db.serverShadows,
    )..where((s) => s.tbl.equals(spec.name) & s.rowKey.equals(key))).getSingleOrNull();
    if (existing != null && existing.serverSeq >= seq) return;
    await db
        .into(db.serverShadows)
        .insertOnConflictUpdate(ServerShadow(tbl: spec.name, rowKey: key, data: jsonEncode(json), serverSeq: seq));
  }

  /// Applies held-back server rows whose entities no longer have unsynced
  /// local changes. Call inside a transaction.
  Future<void> reconcileShadows() async {
    final shadows = await db.select(db.serverShadows).get();
    for (final s in shadows) {
      final spec = tableSpecs[s.tbl];
      if (spec == null) {
        await (db.delete(db.serverShadows)..where((x) => x.tbl.equals(s.tbl) & x.rowKey.equals(s.rowKey))).go();
        continue;
      }
      final json = jsonDecode(s.data) as Map<String, dynamic>;
      final (entityTable, entityId) = spec.entity(json);
      if (entityId.isNotEmpty && await outbox.hasOpenOps(entityTable, entityId)) continue;
      if (spec.naturalKey != null) {
        // Natural-key holder may still be pending under another id.
        final where = spec.naturalKey!.map((c) => '$c = ?').join(' AND ');
        final others = await db
            .customSelect(
              'SELECT id FROM ${spec.name} WHERE $where AND id <> ?',
              variables: [
                for (final c in spec.naturalKey!) Variable(json[c].toString()),
                Variable(json['id'] as String),
              ],
            )
            .get();
        var blocked = false;
        for (final o in others) {
          if (await outbox.hasOpenOps(spec.name, o.read<String>('id'))) blocked = true;
        }
        if (blocked) continue;
      }
      await (db.delete(db.serverShadows)..where((x) => x.tbl.equals(s.tbl) & x.rowKey.equals(s.rowKey))).go();
      await _applyOne(ServerRow(s.tbl, json), fromOwnOp: false);
    }
  }

  /// Server copy held back for an entity, if any.
  Future<Map<String, dynamic>?> shadowFor(String table, String rowKey) async {
    final s = await (db.select(
      db.serverShadows,
    )..where((x) => x.tbl.equals(table) & x.rowKey.equals(rowKey))).getSingleOrNull();
    return s == null ? null : jsonDecode(s.data) as Map<String, dynamic>;
  }

  /// Applies a server row unconditionally (used when the user chooses the
  /// server version while resolving a conflict). Call inside a transaction.
  Future<void> forceApply(ServerRow row) async {
    final spec = tableSpecs[row.table];
    if (spec == null) return;
    final json = Map<String, dynamic>.from(row.data)..['sync_status'] = RowSync.synced;
    if (spec.naturalKey != null) {
      final where = spec.naturalKey!.map((c) => '$c = ?').join(' AND ');
      await _exec('DELETE FROM ${spec.name} WHERE $where AND id <> ?', [
        for (final c in spec.naturalKey!) json[c].toString(),
        json['id'] as String,
      ], spec.name);
    }
    await db.into(_info(spec.name)).insertOnConflictUpdate(spec.fromJson(json));
    await _exec('DELETE FROM server_shadows WHERE tbl = ? AND row_key = ?', [
      spec.name,
      spec.rowKey(json),
    ], 'server_shadows');
  }

  Future<void> _exec(String sql, List<Object> args, String table) => db.customUpdate(
    sql,
    variables: [for (final a in args) Variable(a)],
    updates: {_info(table)},
    updateKind: UpdateKind.delete,
  );
}
