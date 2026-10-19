import 'package:flutter_test/flutter_test.dart';
import 'package:shramasiri/core/dates.dart';
import 'package:shramasiri/data/db/database.dart';
import 'package:shramasiri/data/repositories/attendance_repo.dart';
import 'package:shramasiri/data/repositories/ledger_repo.dart';
import 'package:shramasiri/data/repositories/repo_base.dart';
import 'package:shramasiri/data/repositories/workers_repo.dart';
import 'package:shramasiri/data/sync/outbox.dart';
import 'package:shramasiri/data/sync/sync_engine.dart';
import 'package:shramasiri/domain/ledger.dart';

import 'support/device.dart';
import 'support/fake_server.dart';

const farm = 'farm-1';
const sandesh = 'user-sandesh';
const dad = 'user-dad';
const mom = 'user-mom';

void main() {
  late FakeServer server;
  late TestDevice phoneDad;
  late TestDevice phoneMom;
  late TestDevice phoneSandesh;
  late String workerA;
  late String workerB;
  late String leader;
  final today = AppClock.today().toIso();

  setUp(() async {
    server = FakeServer(farmId: farm)
      ..seedFarm(ownerId: sandesh)
      ..seedMember(userId: sandesh, fullName: 'Sandesh Bhat', role: 'owner')
      ..seedMember(userId: dad, fullName: 'Ramesh Bhat')
      ..seedMember(userId: mom, fullName: 'Shobha Bhat');
    phoneSandesh = await TestDevice.create('sandesh', server, sandesh);
    phoneDad = await TestDevice.create('dad', server, dad);
    phoneMom = await TestDevice.create('mom', server, mom);

    await phoneSandesh.sync();
    workerA = await phoneSandesh.workers.saveWorker(WorkerDraft(nameKn: 'ಮಂಜುನಾಥ', defaultWagePaise: 50000));
    workerB = await phoneSandesh.workers.saveWorker(WorkerDraft(nameKn: 'ಗಣೇಶ', defaultWagePaise: 50000));
    leader = await phoneSandesh.workers.saveWorker(
      WorkerDraft(nameKn: 'ನಾಯಕ', defaultWagePaise: 60000, isLeader: true),
    );
    await phoneSandesh.sync();
    await phoneDad.sync();
    await phoneMom.sync();
  });

  tearDown(() async {
    await phoneSandesh.dispose();
    await phoneDad.dispose();
    await phoneMom.dispose();
  });

  EntryDraft pay(String worker, int rupees, {EntryType type = EntryType.advance, String? paidBy}) =>
      EntryDraft(type: type, workerId: worker, amountPaise: rupees * 100, businessDate: today, paidBy: paidBy);

  test('initial download brings farm, members and workers', () async {
    expect((await phoneDad.db.select(phoneDad.db.workers).get()).length, 3);
    expect((await phoneDad.db.select(phoneDad.db.farmMembers).get()).length, 3);
    expect(await phoneDad.unsynced(), 0);
  });

  test('Scenario A: offline payment survives restart and uploads exactly once', () async {
    phoneDad.online = false;
    final id = await phoneDad.ledger.create(pay(workerA, 500));

    final local = await phoneDad.entries();
    expect(local.single.id, id);
    expect(local.single.syncStatus, RowSync.pending);
    expect(await phoneDad.unsynced(), 1);

    await phoneDad.sync();
    expect(phoneDad.engine.state.phase, SyncPhase.offline);
    expect(await phoneDad.unsynced(), 1, reason: 'still waiting, nothing lost');

    await phoneDad.restart();
    expect((await phoneDad.entries()).single.id, id, reason: 'record survives restart');
    expect(await phoneDad.unsynced(), 1, reason: 'outbox survives restart');

    phoneDad.online = true;
    await phoneDad.sync();
    expect(phoneDad.engine.state.phase, SyncPhase.idle);
    expect(server.count('financial_transactions', (r) => r['id'] == id), 1);
    expect((await phoneDad.entries()).single.syncStatus, RowSync.synced);
    expect(await phoneDad.unsynced(), 0);

    await phoneDad.sync();
    expect(server.count('financial_transactions', (_) => true), 1, reason: 'no duplicate on later syncs');

    await phoneMom.sync();
    final onMom = await phoneMom.entries();
    expect(onMom.single.id, id);
    expect(onMom.single.amountPaise, 50000);
  });

  test('Scenario B: simultaneous offline advances from two people both count', () async {
    phoneDad.online = false;
    phoneMom.online = false;
    await phoneDad.ledger.create(pay(workerA, 500));
    await phoneMom.ledger.create(pay(workerA, 300));

    phoneDad.online = true;
    phoneMom.online = true;
    await phoneDad.sync();
    await phoneMom.sync();
    await phoneDad.sync();

    expect(server.count('financial_transactions', (r) => r['worker_id'] == workerA), 2);
    for (final phone in [phoneDad, phoneMom]) {
      final balance = await phone.ledger.watchBalance(workerA).first;
      expect(balance.wagePaise, -80000, reason: '${phone.name}: 800 advanced, nothing earned yet');
      expect((await phone.entries()).length, 2);
    }
  });

  test('Scenario C: lost acknowledgement does not duplicate the payment', () async {
    phoneDad.remote.dropNextAck = true;
    final id = await phoneDad.ledger.create(pay(workerA, 1000, type: EntryType.wagePayment));
    await phoneDad.sync();

    expect(server.count('financial_transactions', (r) => r['id'] == id), 1, reason: 'server committed');
    expect(await phoneDad.unsynced(), 1, reason: 'device did not get the answer');

    await phoneDad.sync();
    expect(server.count('financial_transactions', (r) => r['id'] == id), 1, reason: 'retry deduplicated');
    expect(await phoneDad.unsynced(), 0);
    expect((await phoneDad.ops(OpStatus.synced)).length, 1);
  });

  test('Scenario D: leader distribution is reconciliation, not new cash', () async {
    await phoneSandesh.ledger.create(pay(leader, 4000, type: EntryType.leaderTransfer));
    for (final (w, amt) in [(workerA, 1000), (workerB, 1500), (leader, 1000)]) {
      await phoneSandesh.ledger.create(
        EntryDraft(
          type: EntryType.leaderAllocation,
          workerId: w,
          leaderWorkerId: leader,
          amountPaise: amt * 100,
          businessDate: today,
        ),
      );
    }
    await phoneSandesh.sync();

    final fund = await phoneSandesh.ledger.leaderFund(leader);
    expect(fund.entrustedPaise, 400000);
    expect(fund.distributedPaise, 350000);
    expect(fund.returnedPaise, 0);
    expect(fund.unreconciledPaise, 50000);
    expect(fund.pendingDistributedPaise, 0);

    final lines = (await phoneSandesh.entries())
        .map(
          (e) => LedgerLine(
            type: EntryType.fromCode(e.entryType),
            amountPaise: e.amountPaise,
            workerId: e.workerId,
            leaderWorkerId: e.leaderWorkerId,
            businessDate: e.businessDate,
          ),
        )
        .toList();
    expect(LedgerMath.cashOut(lines), 400000, reason: 'farm cash outflow is only the hand-over');

    final balances = await phoneSandesh.ledger.watchBalances().first;
    expect(balances[workerA]!.wagePaise, -100000, reason: 'only the confirmed allocation counts for worker A');
    expect(balances[workerB]!.wagePaise, -150000);
  });

  test('Scenario E: two offline allocations of the same 500 - second is rejected and reviewable', () async {
    await phoneSandesh.ledger.create(pay(leader, 500, type: EntryType.leaderTransfer));
    await phoneSandesh.sync();
    await phoneDad.sync();
    await phoneMom.sync();

    phoneDad.online = false;
    phoneMom.online = false;
    EntryDraft alloc(String w) => EntryDraft(
      type: EntryType.leaderAllocation,
      workerId: w,
      leaderWorkerId: leader,
      amountPaise: 50000,
      businessDate: today,
    );
    await phoneDad.ledger.create(alloc(workerA));
    final momEntry = await phoneMom.ledger.create(alloc(workerB));

    final provisional = await phoneMom.ledger.leaderFund(leader);
    expect(provisional.pendingDistributedPaise, 50000, reason: 'shown as pending verification');

    phoneDad.online = true;
    phoneMom.online = true;
    await phoneDad.sync();
    await phoneMom.sync();

    expect(server.leaderPool(leader), 0, reason: 'no overspending');
    expect(server.count('financial_transactions', (r) => r['entry_type'] == 'leader_allocation'), 1);

    final attention = await phoneMom.resolver.watchAttention().first;
    expect(attention.single.code, 'insufficient_leader_funds');
    final momRow = (await phoneMom.entries()).firstWhere((e) => e.id == momEntry);
    expect(momRow.syncStatus, RowSync.rejected, reason: 'kept for review, excluded from totals');
    final momBalances = await phoneMom.ledger.watchBalances().first;
    expect(momBalances[workerB]!.wagePaise, 0);
    expect((await phoneMom.ledger.leaderFund(leader)).unreconciledPaise, 0);

    await phoneMom.resolver.discardMine(attention.single);
    expect((await phoneMom.entries()).any((e) => e.id == momEntry), isFalse);
    expect(await phoneMom.unsynced(), 0);
  });

  test('Scenario F: same worker/day marked on two offline phones - conflict, no double count', () async {
    phoneDad.online = false;
    phoneMom.online = false;
    await phoneDad.attendance.saveDay(today, [AttendanceMark(workerId: workerA, unitsMilli: 1000, ratePaise: 50000)]);
    await phoneMom.attendance.saveDay(today, [AttendanceMark(workerId: workerA, unitsMilli: 500, ratePaise: 50000)]);

    phoneDad.online = true;
    phoneMom.online = true;
    await phoneDad.sync();
    await phoneMom.sync();

    expect(server.count('attendance', (r) => r['worker_id'] == workerA), 1);
    final attention = await phoneMom.resolver.watchAttention().first;
    expect(attention.single.code, 'attendance_exists');
    final momRows = await phoneMom.attendanceRows();
    expect(momRows.length, 1, reason: 'never two rows for the same worker/day');
    expect(momRows.single.syncStatus, RowSync.needsReview);

    // Mom keeps her version (half day); it replaces dad's on the server.
    await phoneMom.resolver.keepMine(attention.single);
    await phoneMom.sync();
    await phoneDad.sync();

    final serverRow = server.table('attendance').values.single;
    expect(serverRow['units_milli'], 500);
    expect(serverRow['revision'], 2);
    for (final phone in [phoneDad, phoneMom]) {
      final rows = await phone.attendanceRows();
      expect(rows.length, 1);
      expect(rows.single.unitsMilli, 500);
      expect(rows.single.earnedPaise, 25000);
      expect(rows.single.syncStatus, RowSync.synced);
    }
  });

  test('Scenario F: choosing the other version discards mine cleanly', () async {
    phoneDad.online = false;
    await phoneDad.attendance.saveDay(today, [AttendanceMark(workerId: workerA, unitsMilli: 1000, ratePaise: 50000)]);
    await phoneMom.attendance.saveDay(today, [AttendanceMark(workerId: workerA, unitsMilli: 500, ratePaise: 50000)]);
    await phoneMom.sync();

    phoneDad.online = true;
    await phoneDad.sync();
    final attention = await phoneDad.resolver.watchAttention().first;
    await phoneDad.resolver.discardMine(attention.single);
    await phoneDad.sync();

    final rows = await phoneDad.attendanceRows();
    expect(rows.single.unitsMilli, 500);
    expect(rows.single.syncStatus, RowSync.synced);
    expect(await phoneDad.unsynced(), 0);
  });

  test('stale edit of the same worker is a conflict, never a silent overwrite', () async {
    final w = (await phoneDad.workers.getWorker(workerA))!;
    phoneMom.online = false;
    await phoneDad.workers.saveWorker(WorkerDraft(id: w.id, nameKn: 'ಮಂಜುನಾಥ ಕೆ', defaultWagePaise: 55000));
    await phoneMom.workers.saveWorker(WorkerDraft(id: w.id, nameKn: 'ಮಂಜು', defaultWagePaise: 50000));
    await phoneDad.sync();
    phoneMom.online = true;
    await phoneMom.sync();

    expect(server.table('workers')[w.id]!['name_kn'], 'ಮಂಜುನಾಥ ಕೆ', reason: 'first edit kept');
    final attention = await phoneMom.resolver.watchAttention().first;
    expect(attention.single.code, 'stale_revision');
    expect((await phoneMom.workers.getWorker(w.id))!.nameKn, 'ಮಂಜು', reason: 'my unsent version still shown');

    await phoneMom.resolver.keepMine(attention.single);
    await phoneMom.sync();
    expect(server.table('workers')[w.id]!['name_kn'], 'ಮಂಜು');
    expect(server.table('workers')[w.id]!['revision'], 3);
  });

  test('Scenario G: wage change keeps old attendance at the old rate', () async {
    final d1 = AppClock.today().addDays(-2).toIso();
    await phoneSandesh.attendance.saveDay(d1, [AttendanceMark(workerId: workerA, unitsMilli: 1000, ratePaise: 50000)]);
    final w = (await phoneSandesh.workers.getWorker(workerA))!;
    await phoneSandesh.workers.saveWorker(WorkerDraft(id: w.id, nameKn: w.nameKn, defaultWagePaise: 60000));
    final newRate = (await phoneSandesh.workers.getWorker(workerA))!.defaultWagePaise;
    await phoneSandesh.attendance.saveDay(today, [
      AttendanceMark(workerId: workerA, unitsMilli: 1000, ratePaise: newRate),
    ]);
    await phoneSandesh.sync();

    final rows = {for (final a in await phoneSandesh.attendanceRows()) a.workDate: a};
    expect(rows[d1]!.earnedPaise, 50000);
    expect(rows[today]!.earnedPaise, 60000);
    expect((await phoneSandesh.ledger.watchBalance(workerA).first).wagePaise, 110000);
  });

  test('Scenario H: partial settlement leaves 500 and carries it forward once', () async {
    final weekStart = AppClock.today().weekStart(1).addDays(-7);
    final days = [for (var i = 0; i < 4; i++) weekStart.addDays(i).toIso()];
    for (final d in days) {
      await phoneSandesh.attendance.saveDay(d, [AttendanceMark(workerId: workerA, unitsMilli: 1000, ratePaise: 50000)]);
    }
    await phoneSandesh.ledger.create(
      EntryDraft(type: EntryType.advance, workerId: workerA, amountPaise: 50000, businessDate: days[1]),
    );
    await phoneSandesh.ledger.create(
      EntryDraft(
        type: EntryType.wagePayment,
        workerId: workerA,
        amountPaise: 100000,
        businessDate: weekStart.addDays(6).toIso(),
      ),
    );

    final week = await phoneSandesh.settlements.period(weekStart, weekStart.addDays(6));
    final s = week.firstWhere((x) => x.workerId == workerA);
    expect(s.unitsMilli, 4000);
    expect(s.grossPaise, 200000);
    expect(s.advancesPaise, 50000);
    expect(s.directPaidPaise, 100000);
    expect(s.closingPaise, 50000);

    final next = await phoneSandesh.settlements.period(weekStart.addDays(7), weekStart.addDays(13));
    final n = next.firstWhere((x) => x.workerId == workerA);
    expect(n.openingPaise, 50000, reason: 'carried forward once, advance not deducted again');
    expect(n.advancesPaise, 0);
  });

  test('Scenario I: paid by dad, recorded by Sandesh - both names kept', () async {
    final id = await phoneSandesh.ledger.create(pay(workerA, 500, paidBy: dad));
    final local = (await phoneSandesh.entries()).firstWhere((e) => e.id == id);
    expect(local.paidBy, dad);
    expect(local.paidByName, 'Ramesh Bhat');
    expect(local.recordedBy, sandesh);
    expect(local.recordedByName, 'Sandesh Bhat');

    await phoneSandesh.sync();
    final row = server.table('financial_transactions')[id]!;
    expect(row['paid_by'], dad);
    expect(row['paid_by_name'], 'Ramesh Bhat');
    expect(row['recorded_by'], sandesh);
  });

  test('Scenario J: days offline with restarts - nothing lost, nothing duplicated', () async {
    phoneDad.online = false;
    final ids = <String>[];
    for (var day = 0; day < 3; day++) {
      final date = AppClock.today().addDays(-3 + day).toIso();
      await phoneDad.attendance.saveDay(date, [
        AttendanceMark(workerId: workerA, unitsMilli: 1000, ratePaise: 50000),
        AttendanceMark(workerId: workerB, unitsMilli: 500, ratePaise: 50000),
      ]);
      ids.add(
        await phoneDad.ledger.create(
          EntryDraft(type: EntryType.advance, workerId: workerA, amountPaise: 10000, businessDate: date),
        ),
      );
      await phoneDad.sync();
      await phoneDad.restart();
      phoneDad.online = false;
    }
    expect(await phoneDad.unsynced(), 9);
    expect((await phoneDad.attendanceRows()).length, 6);

    phoneDad.online = true;
    await phoneDad.sync();
    expect(await phoneDad.unsynced(), 0);
    expect(server.count('attendance', (_) => true), 6);
    expect(server.count('financial_transactions', (r) => ids.contains(r['id'])), 3);

    await phoneDad.sync();
    expect(server.count('financial_transactions', (_) => true), 3);
  });

  test('editing the same day again updates one record and coalesces unsent changes', () async {
    phoneDad.online = false;
    await phoneDad.attendance.saveDay(today, [AttendanceMark(workerId: workerA, unitsMilli: 1000, ratePaise: 50000)]);
    await phoneDad.attendance.saveDay(today, [AttendanceMark(workerId: workerA, unitsMilli: 500, ratePaise: 50000)]);
    expect((await phoneDad.ops()).where((o) => o.opType == OpTypes.attendanceUpsert).length, 1);
    phoneDad.online = true;
    await phoneDad.sync();
    expect(server.table('attendance').values.single['units_milli'], 500);
  });

  test('concurrent sync requests never run parallel uploads', () async {
    for (var i = 0; i < 30; i++) {
      await phoneDad.ledger.create(pay(workerA, 10 + i));
    }
    await Future.wait([phoneDad.sync(), phoneDad.sync(), phoneDad.sync()]);
    expect(server.maxConcurrentCalls, 1);
    expect(server.count('financial_transactions', (_) => true), 30);
    expect(await phoneDad.unsynced(), 0);
  });

  test('revoked membership: uploads stop, records are kept, new entries blocked', () async {
    phoneDad.online = false;
    final id = await phoneDad.ledger.create(pay(workerA, 500));
    server.setMemberStatus(dad, 'disabled');
    phoneDad.online = true;
    await phoneDad.sync();

    expect(phoneDad.engine.state.phase, SyncPhase.accessRevoked);
    expect(server.count('financial_transactions', (_) => true), 0);
    expect((await phoneDad.entries()).single.id, id, reason: 'never silently discarded');
    expect(() => phoneDad.ledger.create(pay(workerA, 100)), throwsA(isA<AppException>()));
  });

  test('members cannot change a closed week locally', () async {
    final weekStart = AppClock.today().weekStart(1).addDays(-7);
    await phoneSandesh.settlements.closeWeek(weekStart);
    await phoneSandesh.sync();
    await phoneDad.sync();
    expect(
      () => phoneDad.attendance.saveDay(weekStart.toIso(), [
        AttendanceMark(workerId: workerA, unitsMilli: 1000, ratePaise: 50000),
      ]),
      throwsA(isA<AppException>().having((e) => e.code, 'code', 'week_closed')),
    );
    // The owner may correct it; the week is flagged for review locally.
    await phoneSandesh.attendance.saveDay(weekStart.toIso(), [
      AttendanceMark(workerId: workerA, unitsMilli: 1000, ratePaise: 50000),
    ]);
    final s = await phoneSandesh.settlements.watchSettlement(weekStart).first;
    expect(s!.needsReview, isTrue);
  });

  test('reversal keeps the original and cancels its effect', () async {
    final id = await phoneSandesh.ledger.create(pay(workerA, 500));
    await phoneSandesh.sync();
    final original = (await phoneSandesh.entries()).single;
    expect(original.id, id);
    await phoneSandesh.ledger.reverse(original, 'entered twice');
    expect(() => phoneSandesh.ledger.reverse(original, 'again'), throwsA(isA<AppException>()));
    await phoneSandesh.sync();

    expect(server.count('financial_transactions', (_) => true), 2);
    expect((await phoneSandesh.ledger.watchBalance(workerA).first).wagePaise, 0);
  });

  test('allocation beyond locally known leader funds is refused before saving', () async {
    await phoneSandesh.ledger.create(pay(leader, 300, type: EntryType.leaderTransfer));
    expect(
      () => phoneSandesh.ledger.create(
        EntryDraft(
          type: EntryType.leaderAllocation,
          workerId: workerA,
          leaderWorkerId: leader,
          amountPaise: 40000,
          businessDate: today,
        ),
      ),
      throwsA(isA<AppException>().having((e) => e.code, 'code', 'insufficient_leader_funds')),
    );
  });
}
