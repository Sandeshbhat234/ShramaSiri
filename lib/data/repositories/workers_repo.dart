import 'package:drift/drift.dart';

import '../../core/ids.dart';
import '../../core/money.dart';
import '../db/database.dart';
import '../sync/outbox.dart';
import 'repo_base.dart';

class WorkerDraft {
  WorkerDraft({
    this.id,
    required this.nameKn,
    this.nameEn,
    this.phone,
    required this.defaultWagePaise,
    this.notes,
    this.isLeader = false,
    this.status = 'active',
  });

  final String? id;
  final String nameKn;
  final String? nameEn;
  final String? phone;
  final int defaultWagePaise;
  final String? notes;
  final bool isLeader;
  final String status;
}

class GroupDraft {
  GroupDraft({this.id, required this.name, this.leaderWorkerId, required this.memberIds, this.status = 'active'});

  final String? id;
  final String name;
  final String? leaderWorkerId;
  final Set<String> memberIds;
  final String status;
}

class WorkersRepo {
  WorkersRepo(this.r);

  final RepoContext r;
  AppDatabase get db => r.db;

  /// Active workers (optionally archived too), Kannada-name order, filtered by
  /// [search] on either name or phone.
  Stream<List<Worker>> watchWorkers({bool includeArchived = false, String search = ''}) {
    final q = db.select(db.workers)..where((w) => w.farmId.equals(r.farmId));
    if (!includeArchived) q.where((w) => w.status.equals('active'));
    final s = search.trim();
    if (s.isNotEmpty) {
      final like = '%$s%';
      q.where((w) => w.nameKn.like(like) | w.nameEn.like(like) | w.phone.like(like));
    }
    q.orderBy([(w) => OrderingTerm.asc(w.nameKn)]);
    return q.watch();
  }

  Stream<List<Worker>> watchLeaders() =>
      (db.select(db.workers)
            ..where((w) => w.farmId.equals(r.farmId) & w.isLeader.equals(true) & w.status.equals('active'))
            ..orderBy([(w) => OrderingTerm.asc(w.nameKn)]))
          .watch();

  Stream<Worker?> watchWorker(String id) => (db.select(db.workers)..where((w) => w.id.equals(id))).watchSingleOrNull();

  Future<Worker?> getWorker(String id) => (db.select(db.workers)..where((w) => w.id.equals(id))).getSingleOrNull();

  /// All workers keyed by id, including archived (for names in history).
  Stream<Map<String, Worker>> watchWorkerIndex() => (db.select(
    db.workers,
  )..where((w) => w.farmId.equals(r.farmId))).watch().map((list) => {for (final w in list) w.id: w});

  Future<String> saveWorker(WorkerDraft d) {
    final name = d.nameKn.trim();
    if (name.isEmpty || name.length > 100) throw const AppException('invalid_name');
    if (d.defaultWagePaise < 0 || d.defaultWagePaise > 10000000) throw const AppException('invalid_amount');
    final phone = r.clean(d.phone, max: 20);
    if (phone != null && !RegExp(r'^[0-9+ -]{5,20}$').hasMatch(phone)) throw const AppException('invalid_phone');

    return r.write((ctx) async {
      final now = DateTime.now().toUtc();
      final id = d.id ?? newId();
      final existing = d.id == null ? null : await getWorker(id);
      if (existing != null && existing.status != d.status && !ctx.isAdmin) {
        throw const AppException('forbidden');
      }
      final row = WorkersCompanion(
        id: Value(id),
        farmId: Value(r.farmId),
        nameKn: Value(name),
        nameEn: Value(r.clean(d.nameEn, max: 100)),
        phone: Value(phone),
        defaultWagePaise: Value(d.defaultWagePaise),
        notes: Value(r.clean(d.notes)),
        isLeader: Value(d.isLeader),
        status: Value(d.status),
        updatedBy: Value(ctx.userId),
        updatedAt: Value(now),
      );
      if (existing == null) {
        await db.into(db.workers).insert(row.copyWith(createdBy: Value(ctx.userId), createdAt: Value(now)));
      } else {
        await (db.update(db.workers)..where((w) => w.id.equals(id))).write(row);
      }
      await r.outbox.enqueue(
        ctx,
        opType: OpTypes.workerUpsert,
        entityTable: 'workers',
        entityId: id,
        coalesce: true,
        payload: {
          'id': id,
          'name_kn': name,
          'name_en': r.clean(d.nameEn, max: 100),
          'phone': phone,
          'default_wage_paise': d.defaultWagePaise,
          'notes': r.clean(d.notes),
          'is_leader': d.isLeader,
          'status': d.status,
        },
      );
      return id;
    });
  }

  /// Quick add from the attendance screen: name and wage only.
  Future<String> quickAdd(String nameKn, int wagePaise) =>
      saveWorker(WorkerDraft(nameKn: nameKn, defaultWagePaise: wagePaise));

  Future<void> setArchived(Worker w, bool archived) => saveWorker(
    WorkerDraft(
      id: w.id,
      nameKn: w.nameKn,
      nameEn: w.nameEn,
      phone: w.phone,
      defaultWagePaise: w.defaultWagePaise,
      notes: w.notes,
      isLeader: w.isLeader,
      status: archived ? 'archived' : 'active',
    ),
  );

  // ---------------------------------------------------------------------------
  // Groups
  // ---------------------------------------------------------------------------

  Stream<List<WorkerGroup>> watchGroups({bool includeArchived = false}) {
    final q = db.select(db.workerGroups)..where((g) => g.farmId.equals(r.farmId));
    if (!includeArchived) q.where((g) => g.status.equals('active'));
    q.orderBy([(g) => OrderingTerm.asc(g.name)]);
    return q.watch();
  }

  Stream<WorkerGroup?> watchGroup(String id) =>
      (db.select(db.workerGroups)..where((g) => g.id.equals(id))).watchSingleOrNull();

  /// Active member ids per group.
  Stream<Map<String, Set<String>>> watchGroupMembers() =>
      (db.select(
        db.workerGroupMemberships,
      )..where((m) => m.farmId.equals(r.farmId) & m.active.equals(true))).watch().map((rows) {
        final out = <String, Set<String>>{};
        for (final m in rows) {
          out.putIfAbsent(m.groupId, () => {}).add(m.workerId);
        }
        return out;
      });

  Future<String> saveGroup(GroupDraft d) {
    final name = d.name.trim();
    if (name.isEmpty || name.length > 100) throw const AppException('invalid_name');
    return r.write((ctx) async {
      final now = DateTime.now().toUtc();
      final id = d.id ?? newId();
      final existing = d.id == null
          ? null
          : await (db.select(db.workerGroups)..where((g) => g.id.equals(id))).getSingleOrNull();
      final members = {...d.memberIds, if (d.leaderWorkerId != null) d.leaderWorkerId!};
      final row = WorkerGroupsCompanion(
        id: Value(id),
        farmId: Value(r.farmId),
        name: Value(name),
        leaderWorkerId: Value(d.leaderWorkerId),
        status: Value(d.status),
        updatedBy: Value(ctx.userId),
        updatedAt: Value(now),
      );
      if (existing == null) {
        await db.into(db.workerGroups).insert(row.copyWith(createdBy: Value(ctx.userId), createdAt: Value(now)));
      } else {
        await (db.update(db.workerGroups)..where((g) => g.id.equals(id))).write(row);
      }
      final current = await (db.select(db.workerGroupMemberships)..where((m) => m.groupId.equals(id))).get();
      for (final m in current) {
        final shouldBeActive = members.contains(m.workerId);
        if (m.active != shouldBeActive) {
          await (db.update(
            db.workerGroupMemberships,
          )..where((x) => x.groupId.equals(id) & x.workerId.equals(m.workerId))).write(
            WorkerGroupMembershipsCompanion(
              active: Value(shouldBeActive),
              updatedBy: Value(ctx.userId),
              updatedAt: Value(now),
            ),
          );
        }
      }
      final known = current.map((m) => m.workerId).toSet();
      for (final w in members.difference(known)) {
        await db
            .into(db.workerGroupMemberships)
            .insert(
              WorkerGroupMembershipsCompanion.insert(
                farmId: r.farmId,
                groupId: id,
                workerId: w,
                updatedBy: ctx.userId,
                updatedAt: now,
                syncStatus: const Value(RowSync.pending),
              ),
            );
      }
      await r.outbox.enqueue(
        ctx,
        opType: OpTypes.groupUpsert,
        entityTable: 'worker_groups',
        entityId: id,
        coalesce: true,
        payload: {
          'id': id,
          'name': name,
          'leader_worker_id': d.leaderWorkerId,
          'status': d.status,
          'member_ids': members.toList(),
        },
      );
      return id;
    });
  }

  /// Default daily wage formatted for prefilling forms.
  static String wageInput(Worker w) => Money.toInput(w.defaultWagePaise);
}
