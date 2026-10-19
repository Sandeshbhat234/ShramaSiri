import 'package:drift/drift.dart';

// Mirrors of the server tables. Column names (and therefore JSON keys) match
// Postgres exactly. Business dates are TEXT 'YYYY-MM-DD'; money is INTEGER
// paise. Every mirrored row also carries:
//   revision    - the server revision this local row is based on (0 = never synced)
//   server_seq  - the server sequence number of the version we hold
//   sync_status - local only: 0 synced, 1 pending, 2 needs review, 3 rejected

mixin SyncedRow on Table {
  IntColumn get revision => integer().withDefault(const Constant(0))();
  IntColumn get serverSeq => integer().withDefault(const Constant(0))();
  IntColumn get syncStatus => integer().withDefault(const Constant(0))();
}

mixin SyncedChildRow on Table {
  IntColumn get serverSeq => integer().withDefault(const Constant(0))();
  IntColumn get syncStatus => integer().withDefault(const Constant(0))();
}

@DataClassName('Farm')
class Farms extends Table with SyncedRow {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get weekStartDay => integer().withDefault(const Constant(1))();
  TextColumn get timezone => text().withDefault(const Constant('Asia/Kolkata'))();
  TextColumn get createdBy => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('FarmMember')
class FarmMembers extends Table with SyncedRow {
  TextColumn get id => text()();
  TextColumn get farmId => text()();
  TextColumn get userId => text().nullable()();
  TextColumn get email => text()();
  TextColumn get role => text()();
  TextColumn get status => text()();
  TextColumn get fullName => text()();
  TextColumn get displayNameKn => text().nullable()();
  TextColumn get linkedWorkerId => text().nullable()();
  TextColumn get invitedBy => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Worker')
@TableIndex(name: 'workers_farm_status_idx', columns: {#farmId, #status})
class Workers extends Table with SyncedRow {
  TextColumn get id => text()();
  TextColumn get farmId => text()();
  TextColumn get nameKn => text()();
  TextColumn get nameEn => text().nullable()();
  TextColumn get phone => text().nullable()();
  IntColumn get defaultWagePaise => integer()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isLeader => boolean().withDefault(const Constant(false))();
  TextColumn get status => text().withDefault(const Constant('active'))();
  TextColumn get createdBy => text()();
  TextColumn get updatedBy => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('WorkerGroup')
class WorkerGroups extends Table with SyncedRow {
  TextColumn get id => text()();
  TextColumn get farmId => text()();
  TextColumn get name => text()();
  TextColumn get leaderWorkerId => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  TextColumn get createdBy => text()();
  TextColumn get updatedBy => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('GroupMembership')
@TableIndex(name: 'wgm_worker_idx', columns: {#workerId})
class WorkerGroupMemberships extends Table with SyncedChildRow {
  TextColumn get farmId => text()();
  TextColumn get groupId => text()();
  TextColumn get workerId => text()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  TextColumn get updatedBy => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {groupId, workerId};
}

@DataClassName('AttendanceRow')
@TableIndex(name: 'attendance_date_idx', columns: {#farmId, #workDate})
@TableIndex(name: 'attendance_worker_idx', columns: {#workerId, #workDate})
class Attendance extends Table with SyncedRow {
  TextColumn get id => text()();
  TextColumn get farmId => text()();
  TextColumn get workerId => text()();
  TextColumn get workDate => text()();
  IntColumn get unitsMilli => integer()();
  IntColumn get ratePaise => integer()();
  IntColumn get earnedPaise => integer()();
  TextColumn get notes => text().nullable()();
  TextColumn get recordedBy => text()();
  TextColumn get updatedBy => text()();
  TextColumn get sourceDeviceId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {farmId, workerId, workDate},
  ];
}

@DataClassName('WorkType')
class WorkTypes extends Table with SyncedRow {
  TextColumn get id => text()();
  TextColumn get farmId => text()();
  TextColumn get code => text()();
  TextColumn get nameKn => text()();
  TextColumn get nameEn => text()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  IntColumn get sortOrder => integer().withDefault(const Constant(100))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('WorkAssignment')
@TableIndex(name: 'work_assignments_date_idx', columns: {#farmId, #workDate})
class WorkAssignments extends Table with SyncedRow {
  TextColumn get id => text()();
  TextColumn get farmId => text()();
  TextColumn get workDate => text()();
  TextColumn get workTypeId => text()();
  TextColumn get fieldName => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get status => text()();
  TextColumn get notes => text().nullable()();
  TextColumn get assignedBy => text()();
  TextColumn get updatedBy => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('AssignmentWorker')
@TableIndex(name: 'waw_worker_idx', columns: {#workerId})
class WorkAssignmentWorkers extends Table with SyncedChildRow {
  TextColumn get farmId => text()();
  TextColumn get assignmentId => text()();
  TextColumn get workerId => text()();
  BoolColumn get removed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {assignmentId, workerId};
}

@DataClassName('LedgerEntry')
@TableIndex(name: 'ft_worker_date_idx', columns: {#farmId, #workerId, #businessDate})
@TableIndex(name: 'ft_date_idx', columns: {#farmId, #businessDate})
@TableIndex(name: 'ft_leader_idx', columns: {#leaderWorkerId})
@TableIndex(name: 'ft_reverses_idx', columns: {#reversesId})
class FinancialTransactions extends Table with SyncedChildRow {
  TextColumn get id => text()();
  TextColumn get farmId => text()();
  TextColumn get entryType => text()();
  TextColumn get workerId => text()();
  TextColumn get leaderWorkerId => text().nullable()();
  IntColumn get amountPaise => integer()();
  BoolColumn get isReversal => boolean().withDefault(const Constant(false))();
  TextColumn get reversesId => text().nullable()();
  TextColumn get relatedEntryId => text().nullable()();
  TextColumn get businessDate => text()();
  DateTimeColumn get occurredAt => dateTime()();
  TextColumn get method => text()();
  TextColumn get reference => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get paidBy => text().nullable()();
  TextColumn get paidByName => text().nullable()();
  TextColumn get recordedBy => text()();
  TextColumn get recordedByName => text()();
  TextColumn get sourceDeviceId => text().nullable()();
  TextColumn get opId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Settlement')
class Settlements extends Table with SyncedRow {
  TextColumn get id => text()();
  TextColumn get farmId => text()();
  TextColumn get weekStart => text()();
  TextColumn get weekEnd => text()();
  TextColumn get status => text()();
  BoolColumn get needsReview => boolean().withDefault(const Constant(false))();
  TextColumn get closedBy => text().nullable()();
  TextColumn get closedByName => text().nullable()();
  DateTimeColumn get closedAt => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {farmId, weekStart},
  ];
}

@DataClassName('SettlementItem')
class SettlementItems extends Table with SyncedChildRow {
  TextColumn get farmId => text()();
  TextColumn get settlementId => text()();
  TextColumn get workerId => text()();
  IntColumn get unitsMilli => integer().withDefault(const Constant(0))();
  IntColumn get openingPaise => integer().withDefault(const Constant(0))();
  IntColumn get grossPaise => integer().withDefault(const Constant(0))();
  IntColumn get additionsPaise => integer().withDefault(const Constant(0))();
  IntColumn get advancesPaise => integer().withDefault(const Constant(0))();
  IntColumn get directPaidPaise => integer().withDefault(const Constant(0))();
  IntColumn get leaderPaidPaise => integer().withDefault(const Constant(0))();
  IntColumn get closingPaise => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {settlementId, workerId};
}

@DataClassName('AuditEvent')
@TableIndex(name: 'audit_entity_idx', columns: {#entityId})
class AuditEvents extends Table with SyncedChildRow {
  TextColumn get id => text()();
  TextColumn get farmId => text()();
  TextColumn get action => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text().nullable()();
  TextColumn get actorId => text()();
  TextColumn get actorName => text().nullable()();
  TextColumn get beforeData => text().nullable()();
  TextColumn get afterData => text().nullable()();
  TextColumn get sourceDeviceId => text().nullable()();
  TextColumn get opId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Local-only tables
// ---------------------------------------------------------------------------

/// Durable synchronization outbox. Rows are written in the same transaction as
/// the local change they describe and are never deleted while unsynced.
@DataClassName('OutboxOp')
@TableIndex(name: 'outbox_status_idx', columns: {#status, #seq})
@TableIndex(name: 'outbox_entity_idx', columns: {#entityTable, #entityId})
class OutboxOps extends Table {
  IntColumn get seq => integer().autoIncrement()();
  TextColumn get opId => text().unique()();
  TextColumn get farmId => text()();
  TextColumn get actorId => text()();
  TextColumn get deviceId => text()();
  TextColumn get opType => text()();
  TextColumn get entityTable => text()();
  TextColumn get entityId => text()();
  TextColumn get payload => text()();
  TextColumn get status => text()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextAttemptAt => dateTime().nullable()();
  TextColumn get lastErrorCode => text().nullable()();
  TextColumn get conflictData => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
}

/// Latest server version of a row that could not be applied because this
/// device still has unsynced changes to it.
@DataClassName('ServerShadow')
class ServerShadows extends Table {
  TextColumn get tbl => text()();
  TextColumn get rowKey => text()();
  TextColumn get data => text()();
  IntColumn get serverSeq => integer()();

  @override
  Set<Column> get primaryKey => {tbl, rowKey};
}

@DataClassName('KvEntry')
class KvEntries extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
