import 'package:drift/drift.dart';

import '../../core/ids.dart';
import '../db/database.dart';
import '../sync/outbox.dart';
import 'repo_base.dart';

abstract final class WorkStatus {
  static const planned = 'planned';
  static const inProgress = 'in_progress';
  static const completed = 'completed';
  static const cancelled = 'cancelled';
  static const all = [planned, inProgress, completed, cancelled];
}

class AssignmentDraft {
  AssignmentDraft({
    this.id,
    required this.workDate,
    required this.workTypeId,
    this.fieldName,
    this.description,
    this.status = WorkStatus.planned,
    this.notes,
    required this.workerIds,
  });

  final String? id;
  final String workDate;
  final String workTypeId;
  final String? fieldName;
  final String? description;
  final String status;
  final String? notes;
  final Set<String> workerIds;
}

/// An assignment with its (non-removed) workers.
class AssignmentView {
  AssignmentView(this.assignment, this.workerIds);

  final WorkAssignment assignment;
  final List<String> workerIds;
}

class WorkRepo {
  WorkRepo(this.r);

  final RepoContext r;
  AppDatabase get db => r.db;

  Stream<List<WorkType>> watchWorkTypes({bool includeInactive = false}) {
    final q = db.select(db.workTypes)..where((t) => t.farmId.equals(r.farmId));
    if (!includeInactive) q.where((t) => t.active.equals(true));
    q.orderBy([(t) => OrderingTerm.asc(t.sortOrder), (t) => OrderingTerm.asc(t.nameKn)]);
    return q.watch();
  }

  Future<String> saveWorkType({String? id, required String nameKn, String? nameEn, bool active = true}) {
    final name = nameKn.trim();
    if (name.isEmpty || name.length > 80) throw const AppException('invalid_name');
    return r.write((ctx) async {
      final now = DateTime.now().toUtc();
      final typeId = id ?? newId();
      final existing = id == null
          ? null
          : await (db.select(db.workTypes)..where((t) => t.id.equals(typeId))).getSingleOrNull();
      final code = existing?.code ?? 'custom_${typeId.replaceAll('-', '').substring(0, 8)}';
      final en = r.clean(nameEn, max: 80) ?? name;
      if (existing == null) {
        await db
            .into(db.workTypes)
            .insert(
              WorkTypesCompanion.insert(
                id: typeId,
                farmId: r.farmId,
                code: code,
                nameKn: name,
                nameEn: en,
                active: Value(active),
                createdAt: now,
                updatedAt: now,
              ),
            );
      } else {
        await (db.update(db.workTypes)..where((t) => t.id.equals(typeId))).write(
          WorkTypesCompanion(nameKn: Value(name), nameEn: Value(en), active: Value(active), updatedAt: Value(now)),
        );
      }
      await r.outbox.enqueue(
        ctx,
        opType: OpTypes.workTypeUpsert,
        entityTable: 'work_types',
        entityId: typeId,
        coalesce: true,
        payload: {
          'id': typeId,
          'code': code,
          'name_kn': name,
          'name_en': en,
          'active': active,
          'sort_order': existing?.sortOrder ?? 100,
        },
      );
      return typeId;
    });
  }

  Stream<List<AssignmentView>> watchAssignments({required String from, required String to, String? workerId}) {
    final q =
        db.select(db.workAssignments).join([
            leftOuterJoin(
              db.workAssignmentWorkers,
              db.workAssignmentWorkers.assignmentId.equalsExp(db.workAssignments.id) &
                  db.workAssignmentWorkers.removed.equals(false),
            ),
          ])
          ..where(db.workAssignments.farmId.equals(r.farmId) & db.workAssignments.workDate.isBetweenValues(from, to))
          ..orderBy([OrderingTerm.desc(db.workAssignments.workDate), OrderingTerm.asc(db.workAssignments.createdAt)]);
    return q.watch().map((rows) {
      final byId = <String, AssignmentView>{};
      for (final row in rows) {
        final a = row.readTable(db.workAssignments);
        final view = byId.putIfAbsent(a.id, () => AssignmentView(a, []));
        final w = row.readTableOrNull(db.workAssignmentWorkers);
        if (w != null) view.workerIds.add(w.workerId);
      }
      final list = byId.values.toList();
      if (workerId == null) return list;
      return list.where((v) => v.workerIds.contains(workerId)).toList();
    });
  }

  Future<AssignmentView?> getAssignment(String id) async {
    final a = await (db.select(db.workAssignments)..where((x) => x.id.equals(id))).getSingleOrNull();
    if (a == null) return null;
    final workers = await (db.select(
      db.workAssignmentWorkers,
    )..where((w) => w.assignmentId.equals(id) & w.removed.equals(false))).get();
    return AssignmentView(a, workers.map((w) => w.workerId).toList());
  }

  Future<String> saveAssignment(AssignmentDraft d) {
    r.validateDate(d.workDate, maxDaysAhead: 366);
    if (!WorkStatus.all.contains(d.status)) throw const AppException('invalid_status');
    return r.write((ctx) async {
      final now = DateTime.now().toUtc();
      final id = d.id ?? newId();
      final existing = d.id == null
          ? null
          : await (db.select(db.workAssignments)..where((a) => a.id.equals(id))).getSingleOrNull();
      final row = WorkAssignmentsCompanion(
        id: Value(id),
        farmId: Value(r.farmId),
        workDate: Value(d.workDate),
        workTypeId: Value(d.workTypeId),
        fieldName: Value(r.clean(d.fieldName, max: 100)),
        description: Value(r.clean(d.description)),
        status: Value(d.status),
        notes: Value(r.clean(d.notes)),
        updatedBy: Value(ctx.userId),
        updatedAt: Value(now),
      );
      if (existing == null) {
        await db.into(db.workAssignments).insert(row.copyWith(assignedBy: Value(ctx.userId), createdAt: Value(now)));
      } else {
        await (db.update(db.workAssignments)..where((a) => a.id.equals(id))).write(row);
      }
      final current = await (db.select(db.workAssignmentWorkers)..where((w) => w.assignmentId.equals(id))).get();
      for (final w in current) {
        final removed = !d.workerIds.contains(w.workerId);
        if (w.removed != removed) {
          await (db.update(db.workAssignmentWorkers)
                ..where((x) => x.assignmentId.equals(id) & x.workerId.equals(w.workerId)))
              .write(WorkAssignmentWorkersCompanion(removed: Value(removed), updatedAt: Value(now)));
        }
      }
      final known = current.map((w) => w.workerId).toSet();
      for (final w in d.workerIds.difference(known)) {
        await db
            .into(db.workAssignmentWorkers)
            .insert(
              WorkAssignmentWorkersCompanion.insert(
                farmId: r.farmId,
                assignmentId: id,
                workerId: w,
                updatedAt: now,
                syncStatus: const Value(RowSync.pending),
              ),
            );
      }
      await r.outbox.enqueue(
        ctx,
        opType: OpTypes.workAssignmentUpsert,
        entityTable: 'work_assignments',
        entityId: id,
        coalesce: true,
        payload: {
          'id': id,
          'work_date': d.workDate,
          'work_type_id': d.workTypeId,
          'field_name': r.clean(d.fieldName, max: 100),
          'description': r.clean(d.description),
          'status': d.status,
          'notes': r.clean(d.notes),
          'worker_ids': d.workerIds.toList(),
        },
      );
      return id;
    });
  }
}
