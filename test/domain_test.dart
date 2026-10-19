import 'dart:math';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shramasiri/core/dates.dart';
import 'package:shramasiri/core/money.dart';
import 'package:shramasiri/data/db/database.dart';
import 'package:shramasiri/data/repositories/ledger_repo.dart';
import 'package:shramasiri/data/repositories/repo_base.dart';
import 'package:shramasiri/data/repositories/settlement_repo.dart';
import 'package:shramasiri/data/sync/outbox.dart';
import 'package:shramasiri/domain/ledger.dart';

void main() {
  group('Money', () {
    test('formats with Indian grouping', () {
      expect(Money.format(275000), '₹2,750');
      expect(Money.format(275050), '₹2,750.50');
      expect(Money.format(123456789), '₹12,34,567.89');
      expect(Money.format(-50000), '-₹500');
      expect(Money.format(0), '₹0');
      expect(Money.format(100000000000), '₹1,00,00,00,000');
    });

    test('parses rupees to paise without floating point', () {
      expect(Money.parseRupees('500'), 50000);
      expect(Money.parseRupees('1,250.5'), 125050);
      expect(Money.parseRupees('₹ 0.07'), 7);
      expect(Money.parseRupees('0.1'), 10);
      expect(Money.parseRupees('-5'), isNull);
      expect(Money.parseRupees('1.234'), isNull);
      expect(Money.parseRupees('abc'), isNull);
      expect(Money.parseRupees(''), isNull);
      expect(Money.toInput(50050), '500.50');
      expect(Money.toInput(50000), '500');
    });
  });

  group('Units', () {
    test('wage for fractions rounds half up like the server column', () {
      expect(Units.earned(50000, 1000), 50000);
      expect(Units.earned(50000, 500), 25000);
      expect(Units.earned(33333, 500), 16667);
      expect(Units.earned(50001, 333), 16650);
      expect(Units.format(1250), '1.25');
      expect(Units.format(500), '0.5');
      expect(Units.parse('0.75'), 750);
      expect(Units.parse('3.5'), isNull);
    });
  });

  group('Dates', () {
    test('IST date crosses midnight at 18:30 UTC', () {
      expect(LocalDate.inIst(DateTime.utc(2026, 10, 18, 18, 29)).toIso(), '2026-10-18');
      expect(LocalDate.inIst(DateTime.utc(2026, 10, 18, 18, 30)).toIso(), '2026-10-19');
    });

    test('week start honours the configured day', () {
      final sunday = LocalDate.parse('2026-10-18');
      expect(sunday.weekStart(1).toIso(), '2026-10-12');
      expect(sunday.weekStart(7).toIso(), '2026-10-18');
      expect(LocalDate.parse('2026-10-12').weekStart(1).toIso(), '2026-10-12');
      expect(LocalDate.parse('2026-01-01').addDays(-1).toIso(), '2025-12-31');
    });
  });

  group('LedgerMath', () {
    const w = 'w1';
    const leader = 'L';
    LedgerLine line(
      EntryType t,
      int rupees, {
      String worker = w,
      String? leaderId,
      String date = '2026-10-12',
      bool rev = false,
    }) => LedgerLine(
      type: t,
      amountPaise: rupees * 100,
      workerId: worker,
      leaderWorkerId: leaderId,
      businessDate: date,
      isReversal: rev,
    );

    test('Scenario D in pure math', () {
      final lines = [
        line(EntryType.leaderTransfer, 4000, worker: leader),
        line(EntryType.leaderAllocation, 1000, worker: 'a', leaderId: leader),
        line(EntryType.leaderAllocation, 1500, worker: 'b', leaderId: leader),
        line(EntryType.leaderAllocation, 1000, worker: 'c', leaderId: leader),
      ];
      expect(LedgerMath.leaderPool(leader, lines), 50000);
      expect(LedgerMath.cashOut(lines), 400000);
      expect(LedgerMath.wageBalance('a', const [], lines), -100000);
    });

    test('bonus is earned and paid; loans do not touch wages', () {
      final lines = [line(EntryType.bonus, 200), line(EntryType.loan, 1000)];
      expect(LedgerMath.wageBalance(w, const [], lines), 0);
      expect(LedgerMath.loanBalance(w, lines), 100000);
      expect(LedgerMath.labourExpense(const [], lines), 20000);
      expect(LedgerMath.cashOut(lines), 120000);
    });

    test('loan offset pays wages from the loan without cash', () {
      final att = [const AttendanceLine(workerId: w, workDate: '2026-10-12', unitsMilli: 1000, earnedPaise: 50000)];
      final lines = [line(EntryType.loan, 1000), line(EntryType.loanOffset, 500)];
      expect(LedgerMath.wageBalance(w, att, lines), 0);
      expect(LedgerMath.loanBalance(w, lines), 50000);
      expect(LedgerMath.cashOut(lines), 100000);
    });

    test('reversal cancels exactly', () {
      final lines = [line(EntryType.advance, 500), line(EntryType.advance, 500, rev: true)];
      expect(LedgerMath.wageBalance(w, const [], lines), 0);
      expect(LedgerMath.cashOut(lines), 0);
    });

    test('negative balances carry forward with sign', () {
      final s = LedgerMath.periodSummaries(
        attendance: const [AttendanceLine(workerId: w, workDate: '2026-10-05', unitsMilli: 1000, earnedPaise: 50000)],
        ledger: [line(EntryType.advance, 800, date: '2026-10-06')],
        start: '2026-10-12',
        end: '2026-10-18',
      );
      expect(s[w]!.openingPaise, -30000);
      expect(s[w]!.closingPaise, -30000);
    });

    test('reimbursements are cash out but not labour expense', () {
      final lines = [line(EntryType.reimbursement, 300)];
      expect(LedgerMath.labourExpense(const [], lines), 0);
      expect(LedgerMath.cashOut(lines), 30000);
      expect(LedgerMath.wageBalance(w, const [], lines), 0);
    });
  });

  test('SQLite period summaries match the reference math on random data', () async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    const farm = 'f';
    final r = RepoContext(db: db, outbox: Outbox(db), farmId: farm, userId: 'u', deviceId: 'd');
    final repo = SettlementRepo(r);
    final rnd = Random(42);
    final workers = ['w1', 'w2', 'w3', 'L'];
    final start = LocalDate.parse('2026-09-01');
    final att = <AttendanceLine>[];
    final lines = <LedgerLine>[];
    final now = DateTime.utc(2026);

    for (var i = 0; i < 300; i++) {
      final worker = workers[rnd.nextInt(3)];
      final date = start.addDays(rnd.nextInt(60)).toIso();
      final units = [500, 1000, 750][rnd.nextInt(3)];
      final rate = 40000 + rnd.nextInt(30000);
      try {
        await db
            .into(db.attendance)
            .insert(
              AttendanceCompanion.insert(
                id: 'a$i',
                farmId: farm,
                workerId: worker,
                workDate: date,
                unitsMilli: units,
                ratePaise: rate,
                earnedPaise: Units.earned(rate, units),
                recordedBy: 'u',
                updatedBy: 'u',
                createdAt: now,
                updatedAt: now,
              ),
            );
        att.add(
          AttendanceLine(workerId: worker, workDate: date, unitsMilli: units, earnedPaise: Units.earned(rate, units)),
        );
      } on SqliteException {
        // same worker/day drawn twice: unique key holds, skip
      }
    }
    for (var i = 0; i < 300; i++) {
      final type = EntryType.values[rnd.nextInt(EntryType.values.length)];
      final worker = workers[rnd.nextInt(4)];
      final amount = (1 + rnd.nextInt(2000)) * 100 * (type == EntryType.openingBalance && rnd.nextBool() ? -1 : 1);
      final date = start.addDays(rnd.nextInt(60)).toIso();
      final rev = rnd.nextInt(8) == 0;
      final leaderId = type.needsLeader ? 'L' : null;
      await db
          .into(db.financialTransactions)
          .insert(
            FinancialTransactionsCompanion.insert(
              id: 'f$i',
              farmId: farm,
              entryType: type.code,
              workerId: worker,
              leaderWorkerId: Value(leaderId),
              amountPaise: amount,
              isReversal: Value(rev),
              reversesId: Value(rev ? 'x$i' : null),
              businessDate: date,
              occurredAt: now,
              method: type.isCash ? PayMethod.cash : PayMethod.none,
              recordedBy: 'u',
              recordedByName: 'U',
              createdAt: now,
              syncStatus: Value(rnd.nextInt(10) == 0 ? RowSync.rejected : RowSync.synced),
            ),
          );
      final row = await (db.select(db.financialTransactions)..where((f) => f.id.equals('f$i'))).getSingle();
      if (row.syncStatus != RowSync.rejected) {
        lines.add(
          LedgerLine(
            type: type,
            amountPaise: amount,
            workerId: worker,
            leaderWorkerId: leaderId,
            businessDate: date,
            isReversal: rev,
          ),
        );
      }
    }

    for (final (s, e) in [('2026-09-14', '2026-09-20'), ('2026-10-05', '2026-10-11'), ('2026-08-01', '2026-08-07')]) {
      final expected = LedgerMath.periodSummaries(attendance: att, ledger: lines, start: s, end: e);
      final actual = {for (final p in await repo.period(LocalDate.parse(s), LocalDate.parse(e))) p.workerId: p};
      expect(actual.keys.toSet(), expected.keys.toSet(), reason: 'week $s');
      for (final w in expected.keys) {
        final a = actual[w]!, x = expected[w]!;
        expect(
          [
            a.unitsMilli,
            a.openingPaise,
            a.grossPaise,
            a.additionsPaise,
            a.advancesPaise,
            a.directPaidPaise,
            a.leaderPaidPaise,
          ],
          [
            x.unitsMilli,
            x.openingPaise,
            x.grossPaise,
            x.additionsPaise,
            x.advancesPaise,
            x.directPaidPaise,
            x.leaderPaidPaise,
          ],
          reason: '$w week $s',
        );
      }
    }

    final ledger = LedgerRepo(r);
    final balances = await ledger.watchBalances().first;
    for (final w in workers) {
      if (balances[w] == null) continue;
      expect(balances[w]!.wagePaise, LedgerMath.wageBalance(w, att, lines), reason: 'wage balance $w');
      expect(balances[w]!.loanPaise, LedgerMath.loanBalance(w, lines), reason: 'loan balance $w');
    }
    final fund = await ledger.leaderFund('L');
    expect(fund.unreconciledPaise, LedgerMath.leaderPool('L', lines));
    expect(fund.ownPocketOwedPaise, LedgerMath.leaderPayable('L', lines));
  });
}
