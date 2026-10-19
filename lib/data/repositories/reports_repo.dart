import 'package:drift/drift.dart';

import '../../core/money.dart';
import '../../domain/ledger.dart';
import '../db/database.dart';
import 'repo_base.dart';

class WorkerCost {
  const WorkerCost({
    required this.workerId,
    required this.unitsMilli,
    required this.attendancePaise,
    required this.adjustmentPaise,
  });

  final String workerId;
  final int unitsMilli;
  final int attendancePaise;
  final int adjustmentPaise;

  int get totalPaise => attendancePaise + adjustmentPaise;
}

class CashSummary {
  const CashSummary({required this.byType, required this.byPayer});

  /// Signed cash per entry type (returns/repayments are negative).
  final Map<EntryType, int> byType;

  /// Cash handed over per family member name (outflows only).
  final Map<String, int> byPayer;

  int get netOutPaise => byType.entries.fold(0, (s, e) => s + e.value * e.key.effects.cashOut);
  int get cashInPaise => byType.entries.where((e) => e.key.effects.cashOut < 0).fold(0, (s, e) => s + e.value);
  int get grossOutPaise => byType.entries.where((e) => e.key.effects.cashOut > 0).fold(0, (s, e) => s + e.value);
}

class WorkTypeCost {
  const WorkTypeCost({required this.workTypeId, required this.paise});

  /// Null for attendance days without a recorded task.
  final String? workTypeId;
  final int paise;
}

class ReportsRepo {
  ReportsRepo(this.r);

  final RepoContext r;
  AppDatabase get db => r.db;

  /// Earned labour cost per worker for [from]..[to] (attendance + bonuses and
  /// additions - deductions). Opening balances are not a period expense.
  Future<List<WorkerCost>> labourCost(String from, String to) async {
    final rows = await db
        .customSelect(
          '''
SELECT worker_id, SUM(units) AS units, SUM(att) AS att, SUM(adj) AS adj FROM (
  SELECT worker_id, SUM(units_milli) AS units, SUM(earned_paise) AS att, 0 AS adj FROM attendance
    WHERE farm_id = ?1 AND work_date BETWEEN ?2 AND ?3 AND sync_status <> 3 GROUP BY worker_id
  UNION ALL
  SELECT worker_id, 0, 0, SUM(${LedgerSql.effect((e) => e.expense)}) FROM financial_transactions
    WHERE farm_id = ?1 AND business_date BETWEEN ?2 AND ?3 AND sync_status <> 3 GROUP BY worker_id
) GROUP BY worker_id ORDER BY SUM(att) + SUM(adj) DESC''',
          variables: [Variable(r.farmId), Variable(from), Variable(to)],
        )
        .get();
    return rows
        .map(
          (row) => WorkerCost(
            workerId: row.read<String>('worker_id'),
            unitsMilli: row.read<int>('units'),
            attendancePaise: row.read<int>('att'),
            adjustmentPaise: row.read<int>('adj'),
          ),
        )
        .where((c) => c.unitsMilli != 0 || c.totalPaise != 0)
        .toList();
  }

  /// Total labour expense (earned wages) for [from]..[to], live.
  Stream<int> watchEarned(String from, String to) => db
      .customSelect(
        '''
SELECT
  (SELECT COALESCE(SUM(earned_paise), 0) FROM attendance
     WHERE farm_id = ?1 AND work_date BETWEEN ?2 AND ?3 AND sync_status <> 3)
  + (SELECT COALESCE(SUM(${LedgerSql.effect((e) => e.expense)}), 0) FROM financial_transactions
     WHERE farm_id = ?1 AND business_date BETWEEN ?2 AND ?3 AND sync_status <> 3) AS v''',
        variables: [Variable(r.farmId), Variable(from), Variable(to)],
        readsFrom: {db.attendance, db.financialTransactions},
      )
      .watchSingle()
      .map((row) => row.read<int>('v'));

  Future<CashSummary> cash(String from, String to) async {
    final byTypeRows = await db
        .customSelect(
          '''
SELECT entry_type, SUM(${LedgerSql.signed}) AS amt FROM financial_transactions
WHERE farm_id = ?1 AND business_date BETWEEN ?2 AND ?3 AND method <> 'none' AND sync_status <> 3
GROUP BY entry_type''',
          variables: [Variable(r.farmId), Variable(from), Variable(to)],
        )
        .get();
    final cashOutTypes = EntryType.values.where((t) => t.effects.cashOut > 0).map((t) => "'${t.code}'").join(',');
    final byPayerRows = await db
        .customSelect(
          '''
SELECT COALESCE(paid_by_name, '') AS payer, SUM(${LedgerSql.signed}) AS amt FROM financial_transactions
WHERE farm_id = ?1 AND business_date BETWEEN ?2 AND ?3 AND entry_type IN ($cashOutTypes) AND sync_status <> 3
GROUP BY paid_by_name ORDER BY amt DESC''',
          variables: [Variable(r.farmId), Variable(from), Variable(to)],
        )
        .get();
    return CashSummary(
      byType: {for (final row in byTypeRows) EntryType.fromCode(row.read<String>('entry_type')): row.read<int>('amt')},
      byPayer: {for (final row in byPayerRows) row.read<String>('payer'): row.read<int>('amt')},
    );
  }

  /// Approximate labour cost per work type: each attendance day's wage is
  /// split evenly across the tasks recorded for that worker on that day.
  /// Days without a task are reported under a null work type.
  Future<List<WorkTypeCost>> workTypeCost(String from, String to) async {
    final rows = await db
        .customSelect(
          '''
WITH att AS (
  SELECT worker_id, work_date, earned_paise FROM attendance
  WHERE farm_id = ?1 AND work_date BETWEEN ?2 AND ?3 AND units_milli > 0 AND sync_status <> 3
),
asg AS (
  SELECT w.worker_id, a.work_date, a.work_type_id FROM work_assignment_workers w
  JOIN work_assignments a ON a.id = w.assignment_id
  WHERE a.farm_id = ?1 AND a.work_date BETWEEN ?2 AND ?3 AND a.status <> 'cancelled' AND w.removed = 0
),
cnt AS (SELECT worker_id, work_date, COUNT(*) AS n FROM asg GROUP BY worker_id, work_date)
SELECT asg.work_type_id AS type_id, SUM(att.earned_paise / cnt.n) AS paise
FROM att JOIN asg ON asg.worker_id = att.worker_id AND asg.work_date = att.work_date
JOIN cnt ON cnt.worker_id = att.worker_id AND cnt.work_date = att.work_date
GROUP BY asg.work_type_id
UNION ALL
SELECT NULL, COALESCE(SUM(att.earned_paise), 0) FROM att
WHERE NOT EXISTS (SELECT 1 FROM asg WHERE asg.worker_id = att.worker_id AND asg.work_date = att.work_date)
''',
          variables: [Variable(r.farmId), Variable(from), Variable(to)],
        )
        .get();
    return rows
        .map((row) => WorkTypeCost(workTypeId: row.readNullable<String>('type_id'), paise: row.read<int>('paise')))
        .where((c) => c.paise != 0)
        .toList()
      ..sort((a, b) => b.paise.compareTo(a.paise));
  }

  /// Ledger and attendance rows for [from]..[to] as CSV (amounts in rupees).
  Future<String> exportCsv(String from, String to, Map<String, Worker> workers) async {
    String name(String? id) => id == null ? '' : (workers[id]?.nameKn ?? id);
    String q(Object? v) {
      final s = v?.toString() ?? '';
      return s.contains(RegExp(r'[",\n]')) ? '"${s.replaceAll('"', '""')}"' : s;
    }

    final buf = StringBuffer()
      ..writeln(
        'section,date,worker,type,amount_rupees,units,rate_rupees,leader,method,paid_by,recorded_by,reversal,notes,id',
      );
    final entries =
        await (db.select(db.financialTransactions)
              ..where((f) => f.farmId.equals(r.farmId) & f.businessDate.isBetweenValues(from, to))
              ..orderBy([(f) => OrderingTerm.asc(f.businessDate), (f) => OrderingTerm.asc(f.occurredAt)]))
            .get();
    for (final e in entries) {
      buf.writeln(
        [
          'money',
          e.businessDate,
          q(name(e.workerId)),
          e.entryType,
          Money.format(e.isReversal ? -e.amountPaise : e.amountPaise, symbol: false).replaceAll(',', ''),
          '',
          '',
          q(name(e.leaderWorkerId)),
          e.method,
          q(e.paidByName),
          q(e.recordedByName),
          e.isReversal ? 'yes' : '',
          q(e.notes),
          e.id,
        ].join(','),
      );
    }
    final att =
        await (db.select(db.attendance)
              ..where(
                (a) =>
                    a.farmId.equals(r.farmId) &
                    a.workDate.isBetweenValues(from, to) &
                    a.unitsMilli.isBiggerThanValue(0),
              )
              ..orderBy([(a) => OrderingTerm.asc(a.workDate)]))
            .get();
    for (final a in att) {
      buf.writeln(
        [
          'attendance',
          a.workDate,
          q(name(a.workerId)),
          'attendance',
          Money.format(a.earnedPaise, symbol: false).replaceAll(',', ''),
          Units.format(a.unitsMilli),
          Money.format(a.ratePaise, symbol: false).replaceAll(',', ''),
          '',
          '',
          '',
          '',
          '',
          q(a.notes),
          a.id,
        ].join(','),
      );
    }
    return buf.toString();
  }
}
