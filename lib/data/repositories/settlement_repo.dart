import 'package:drift/drift.dart';

import '../../core/dates.dart';
import '../../core/ids.dart';
import '../../domain/ledger.dart';
import '../db/database.dart';
import '../sync/outbox.dart';
import 'repo_base.dart';

class SettlementRepo {
  SettlementRepo(this.r);

  final RepoContext r;
  AppDatabase get db => r.db;

  static String get _wageNet => LedgerSql.wageNet;

  /// Same formula as private.period_summary on the server. Opening balances
  /// are derived from the full ledger history up to the day before [start],
  /// so nothing is copied between weeks and nothing is counted twice.
  String get _summarySql =>
      '''
SELECT worker_id,
  SUM(units) AS units, SUM(opening) AS opening, SUM(gross) AS gross, SUM(additions) AS additions,
  SUM(advances) AS advances, SUM(direct) AS direct, SUM(via_leader) AS via_leader
FROM (
  SELECT worker_id,
    SUM(CASE WHEN work_date >= ?2 THEN units_milli ELSE 0 END) AS units,
    SUM(CASE WHEN work_date < ?2 THEN earned_paise ELSE 0 END) AS opening,
    SUM(CASE WHEN work_date >= ?2 THEN earned_paise ELSE 0 END) AS gross,
    0 AS additions, 0 AS advances, 0 AS direct, 0 AS via_leader
  FROM attendance WHERE farm_id = ?1 AND work_date <= ?3 AND sync_status <> 3
  GROUP BY worker_id
  UNION ALL
  SELECT worker_id, 0,
    SUM(CASE WHEN business_date < ?2 THEN $_wageNet ELSE 0 END),
    0,
    SUM(CASE WHEN business_date >= ?2 THEN ${LedgerSql.effect((e) => e.earned)} ELSE 0 END),
    SUM(CASE WHEN business_date >= ?2 THEN ${LedgerSql.effect((e) => e.advance)} ELSE 0 END),
    SUM(CASE WHEN business_date >= ?2 THEN ${LedgerSql.effect((e) => e.direct)} ELSE 0 END),
    SUM(CASE WHEN business_date >= ?2 THEN ${LedgerSql.effect((e) => e.viaLeader)} ELSE 0 END)
  FROM financial_transactions WHERE farm_id = ?1 AND business_date <= ?3 AND sync_status <> 3
  GROUP BY worker_id
) GROUP BY worker_id''';

  PeriodSummary _read(QueryRow row) => PeriodSummary(
    workerId: row.read<String>('worker_id'),
    unitsMilli: row.read<int>('units'),
    openingPaise: row.read<int>('opening'),
    grossPaise: row.read<int>('gross'),
    additionsPaise: row.read<int>('additions'),
    advancesPaise: row.read<int>('advances'),
    directPaidPaise: row.read<int>('direct'),
    leaderPaidPaise: row.read<int>('via_leader'),
  );

  /// Per-worker statement for the period; workers with no activity and a
  /// zero balance are omitted.
  Stream<List<PeriodSummary>> watchPeriod(LocalDate start, LocalDate end) => db
      .customSelect(
        _summarySql,
        variables: [Variable(r.farmId), Variable(start.toIso()), Variable(end.toIso())],
        readsFrom: {db.attendance, db.financialTransactions},
      )
      .watch()
      .map((rows) => rows.map(_read).where((s) => !s.isEmpty).toList());

  Future<List<PeriodSummary>> period(LocalDate start, LocalDate end) async {
    final rows = await db
        .customSelect(_summarySql, variables: [Variable(r.farmId), Variable(start.toIso()), Variable(end.toIso())])
        .get();
    return rows.map(_read).where((s) => !s.isEmpty).toList();
  }

  Stream<Settlement?> watchSettlement(LocalDate weekStart) => (db.select(
    db.settlements,
  )..where((s) => s.farmId.equals(r.farmId) & s.weekStart.equals(weekStart.toIso()))).watchSingleOrNull();

  Stream<List<Settlement>> watchSettlements({int limit = 52}) =>
      (db.select(db.settlements)
            ..where((s) => s.farmId.equals(r.farmId))
            ..orderBy([(s) => OrderingTerm.desc(s.weekStart)])
            ..limit(limit))
          .watch();

  Stream<Map<String, SettlementItem>> watchItems(String settlementId) => (db.select(
    db.settlementItems,
  )..where((i) => i.settlementId.equals(settlementId))).watch().map((items) => {for (final i in items) i.workerId: i});

  /// Marks a week as reviewed/closed. Transactions stay correctable; the
  /// server snapshots each worker's figures so later changes can be spotted.
  Future<void> closeWeek(LocalDate weekStart, {String? notes}) async {
    final farm = await (db.select(db.farms)..where((f) => f.id.equals(r.farmId))).getSingle();
    if (weekStart.weekday != farm.weekStartDay) throw const AppException('invalid_week');
    if (weekStart.isAfter(AppClock.today())) throw const AppException('week_in_future');
    await r.write((ctx) async {
      final now = DateTime.now().toUtc();
      final existing = await (db.select(
        db.settlements,
      )..where((s) => s.farmId.equals(r.farmId) & s.weekStart.equals(weekStart.toIso()))).getSingleOrNull();
      final id = existing?.id ?? newId();
      final row = SettlementsCompanion(
        id: Value(id),
        farmId: Value(r.farmId),
        weekStart: Value(weekStart.toIso()),
        weekEnd: Value(weekStart.addDays(6).toIso()),
        status: const Value('closed'),
        needsReview: const Value(false),
        closedBy: Value(ctx.userId),
        closedByName: Value(ctx.actorName),
        closedAt: Value(now),
        notes: Value(r.clean(notes) ?? existing?.notes),
        updatedAt: Value(now),
      );
      if (existing == null) {
        await db.into(db.settlements).insert(row.copyWith(createdAt: Value(now)));
      } else {
        await (db.update(db.settlements)..where((s) => s.id.equals(id))).write(row);
      }
      await r.outbox.enqueue(
        ctx,
        opType: OpTypes.settlementClose,
        entityTable: 'settlements',
        entityId: id,
        payload: {'id': id, 'week_start': weekStart.toIso(), 'notes': r.clean(notes)},
      );
    });
  }

  Future<void> reopenWeek(Settlement s) async {
    await r.write((ctx) async {
      if (!ctx.isAdmin) throw const AppException('forbidden');
      await (db.update(db.settlements)..where((x) => x.id.equals(s.id))).write(
        SettlementsCompanion(
          status: const Value('open'),
          needsReview: const Value(false),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
      await r.outbox.enqueue(
        ctx,
        opType: OpTypes.settlementReopen,
        entityTable: 'settlements',
        entityId: s.id,
        payload: {'week_start': s.weekStart},
      );
    });
  }
}
