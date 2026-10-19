// End-to-end tests against a real Supabase stack (local `npx supabase start`).
//
//   SHRAMASIRI_E2E_URL=http://127.0.0.1:55421 \
//   SHRAMASIRI_E2E_KEY=<local publishable key> \
//   flutter test test/integration/supabase_e2e_test.dart
//
// Skipped when the variables are not set. Uses unique throwaway accounts.
import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shramasiri/core/dates.dart';
import 'package:shramasiri/core/ids.dart';
import 'package:shramasiri/data/db/database.dart';
import 'package:shramasiri/data/remote/remote_api.dart';
import 'package:shramasiri/data/repositories/attendance_repo.dart';
import 'package:shramasiri/data/repositories/ledger_repo.dart';
import 'package:shramasiri/data/repositories/members_repo.dart';
import 'package:shramasiri/data/repositories/repo_base.dart';
import 'package:shramasiri/data/repositories/settlement_repo.dart';
import 'package:shramasiri/data/repositories/workers_repo.dart';
import 'package:shramasiri/data/sync/conflict_resolver.dart';
import 'package:shramasiri/data/sync/outbox.dart';
import 'package:shramasiri/data/sync/sync_engine.dart';
import 'package:shramasiri/domain/ledger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _url = Platform.environment['SHRAMASIRI_E2E_URL'];
final _key = Platform.environment['SHRAMASIRI_E2E_KEY'];

/// Real remote with switches to simulate no network and a lost response.
class FlakyRemote implements RemoteApi {
  FlakyRemote(this.inner);

  final RemoteApi inner;
  bool online = true;
  bool dropNextAck = false;

  void _check() {
    if (!online) throw RemoteError(RemoteErrorKind.network, 'offline (simulated)');
  }

  @override
  Future<List<Map<String, dynamic>>> applyOps(List<Map<String, dynamic>> ops) async {
    _check();
    final r = await inner.applyOps(ops);
    if (dropNextAck) {
      dropNextAck = false;
      throw RemoteError(RemoteErrorKind.network, 'response lost (simulated)');
    }
    return r;
  }

  @override
  Future<PullPage> pullChanges(String farmId, int afterSeq, {int limit = 500}) {
    _check();
    return inner.pullChanges(farmId, afterSeq, limit: limit);
  }

  @override
  Future<Map<String, dynamic>> getMyContext() {
    _check();
    return inner.getMyContext();
  }

  @override
  Future<Map<String, dynamic>> createFarm({
    required String farmId,
    required String farmName,
    required String fullName,
    String? displayNameKn,
  }) => inner.createFarm(farmId: farmId, farmName: farmName, fullName: fullName, displayNameKn: displayNameKn);

  @override
  Future<Map<String, dynamic>> acceptInvitation({
    required String memberId,
    required String fullName,
    String? displayNameKn,
  }) => inner.acceptInvitation(memberId: memberId, fullName: fullName, displayNameKn: displayNameKn);

  @override
  Future<List<Map<String, dynamic>>> fetchRows(String table, String column, String value) {
    _check();
    return inner.fetchRows(table, column, value);
  }

  @override
  Future<bool> refreshSession() => inner.refreshSession();
}

class Phone {
  Phone(this.name, this.client, this.farmId);

  final String name;
  final SupabaseClient client;
  final String farmId;
  late final FlakyRemote remote = FlakyRemote(SupabaseRemoteApi(client));
  late final Directory dir;
  late AppDatabase db;
  late RepoContext ctx;
  late SyncEngine engine;

  String get userId => client.auth.currentUser!.id;

  Future<void> open() async {
    dir = await Directory.systemTemp.createTemp('e2e_$name');
    await _open();
    await db.setKv(KvKeys.deviceId, 'e2e-$name');
    await db.setKv(KvKeys.boundUserId, userId);
    await db.setKv(KvKeys.farmId, farmId);
  }

  Future<void> _open() async {
    db = AppDatabase(NativeDatabase(File('${dir.path}/db.sqlite')));
    final outbox = Outbox(db);
    ctx = RepoContext(db: db, outbox: outbox, farmId: farmId, userId: userId, deviceId: 'e2e-$name');
    engine = SyncEngine(db: db, remote: remote, farmId: farmId, userId: userId, outbox: outbox, autoRetry: false);
    await engine.init();
  }

  Future<void> restart() async {
    engine.dispose();
    await db.close();
    await _open();
  }

  Future<void> sync() async {
    await engine.sync();
    expect(
      engine.state.phase,
      anyOf(SyncPhase.idle, SyncPhase.offline, SyncPhase.accessRevoked),
      reason: '$name: ${engine.state.lastError}',
    );
  }

  WorkersRepo get workers => WorkersRepo(ctx);
  AttendanceRepo get attendance => AttendanceRepo(ctx);
  LedgerRepo get ledger => LedgerRepo(ctx);
  SettlementRepo get settlements => SettlementRepo(ctx);
  MembersRepo get members => MembersRepo(ctx);
  ConflictResolver get resolver => ConflictResolver(db, ctx.outbox);

  Future<int> unsynced() => ctx.outbox.unsyncedCount();

  Future<void> dispose() async {
    engine.dispose();
    await db.close();
    await client.dispose();
  }
}

Future<SupabaseClient> newUser(String email) async {
  final c = SupabaseClient(
    _url!,
    _key!,
    authOptions: const AuthClientOptions(autoRefreshToken: false, authFlowType: AuthFlowType.implicit),
  );
  final res = await c.auth.signUp(email: email, password: 'password-123');
  expect(res.session, isNotNull, reason: 'local stack must have email confirmations disabled');
  return c;
}

void main() {
  final enabled = _url != null && _key != null;
  final stamp = DateTime.now().millisecondsSinceEpoch;
  final farmId = newId();
  late Phone owner;
  late Phone dad;
  late SupabaseClient stranger;
  late String workerA;
  late String workerB;
  late String leader;
  final today = AppClock.today().toIso();

  setUpAll(() async {
    if (!enabled) return;
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final ownerClient = await newUser('owner-$stamp@example.com');
    await SupabaseRemoteApi(ownerClient).createFarm(farmId: farmId, farmName: 'E2E Farm', fullName: 'Sandesh Bhat');
    owner = Phone('owner', ownerClient, farmId);
    await owner.open();
    await owner.sync();
    await owner.members.invite(email: 'dad-$stamp@example.com', fullName: 'Ramesh Bhat');
    workerA = await owner.workers.saveWorker(WorkerDraft(nameKn: 'ಮಂಜುನಾಥ', defaultWagePaise: 50000));
    workerB = await owner.workers.saveWorker(WorkerDraft(nameKn: 'ಗಣೇಶ', defaultWagePaise: 50000));
    leader = await owner.workers.saveWorker(WorkerDraft(nameKn: 'ನಾಯಕ', defaultWagePaise: 60000, isLeader: true));
    await owner.sync();
    expect(await owner.unsynced(), 0);

    final dadClient = await newUser('dad-$stamp@example.com');
    final ctx = await SupabaseRemoteApi(dadClient).getMyContext();
    final invite = (ctx['invitations'] as List).single as Map;
    await SupabaseRemoteApi(dadClient)
        .acceptInvitation(memberId: invite['member_id'] as String, fullName: 'Ramesh Bhat');
    dad = Phone('dad', dadClient, farmId);
    await dad.open();
    await dad.sync();

    stranger = await newUser('stranger-$stamp@example.com');
    await SupabaseRemoteApi(stranger).createFarm(farmId: newId(), farmName: 'Other', fullName: 'Stranger');
  });

  tearDownAll(() async {
    if (!enabled) return;
    await owner.dispose();
    await dad.dispose();
    await stranger.dispose();
  });

  group('real Supabase', skip: enabled ? false : 'set SHRAMASIRI_E2E_URL and SHRAMASIRI_E2E_KEY', () {
    test('invited member downloads the farm', () async {
      final workers = await dad.db.select(dad.db.workers).get();
      expect(workers.length, 3);
      final members = await dad.db.select(dad.db.farmMembers).get();
      expect(members.map((m) => m.fullName), containsAll(['Sandesh Bhat', 'Ramesh Bhat']));
    });

    test('Scenario A: offline payment, restart, single upload, visible on the other phone', () async {
      dad.remote.online = false;
      final id = await dad.ledger.create(
        EntryDraft(type: EntryType.advance, workerId: workerA, amountPaise: 50000, businessDate: today),
      );
      await dad.sync();
      expect(dad.engine.state.phase, SyncPhase.offline);
      await dad.restart();
      expect(await dad.unsynced(), 1);
      dad.remote.online = true;
      await dad.sync();
      await dad.sync();
      expect(await dad.unsynced(), 0);
      final rows = await dad.remote.fetchRows('financial_transactions', 'id', id);
      expect(rows.length, 1);
      await owner.sync();
      expect((await owner.db.select(owner.db.financialTransactions).get()).where((e) => e.id == id).length, 1);
    });

    test('Scenario B and I: two people, both offline; both count; payer and recorder kept', () async {
      dad.remote.online = false;
      owner.remote.online = false;
      final a = await dad.ledger.create(
        EntryDraft(type: EntryType.advance, workerId: workerB, amountPaise: 50000, businessDate: today),
      );
      final b = await owner.ledger.create(
        EntryDraft(
          type: EntryType.advance,
          workerId: workerB,
          amountPaise: 30000,
          businessDate: today,
          paidBy: dad.userId,
        ),
      );
      dad.remote.online = true;
      owner.remote.online = true;
      await dad.sync();
      await owner.sync();
      await dad.sync();
      for (final p in [dad, owner]) {
        expect((await p.ledger.watchBalance(workerB).first).wagePaise, -80000, reason: p.name);
      }
      final row = (await owner.remote.fetchRows('financial_transactions', 'id', b)).single;
      expect(row['paid_by'], dad.userId);
      expect(row['paid_by_name'], 'Ramesh Bhat');
      expect(row['recorded_by'], owner.userId);
      expect(row['recorded_by_name'], 'Sandesh Bhat');
      expect(
        (await owner.remote.fetchRows('financial_transactions', 'id', a)).single['recorded_by_name'],
        'Ramesh Bhat',
      );
    });

    test('Scenario C: response lost after commit; retry does not duplicate', () async {
      owner.remote.dropNextAck = true;
      final id = await owner.ledger.create(
        EntryDraft(type: EntryType.wagePayment, workerId: workerA, amountPaise: 100000, businessDate: today),
      );
      await owner.engine.sync();
      expect(await owner.unsynced(), 1);
      await owner.sync();
      expect(await owner.unsynced(), 0);
      expect((await owner.remote.fetchRows('financial_transactions', 'id', id)).length, 1);
      final ops = await (owner.db.select(owner.db.outboxOps)..where((o) => o.entityId.equals(id))).get();
      expect(ops.single.status, OpStatus.synced);
    });

    test('Scenario D and E: leader funds; concurrent offline allocations never overspend', () async {
      await owner.ledger.create(
        EntryDraft(type: EntryType.leaderTransfer, workerId: leader, amountPaise: 400000, businessDate: today),
      );
      for (final (w, amt) in [(workerA, 100000), (workerB, 150000), (leader, 100000)]) {
        await owner.ledger.create(
          EntryDraft(
            type: EntryType.leaderAllocation,
            workerId: w,
            leaderWorkerId: leader,
            amountPaise: amt,
            businessDate: today,
          ),
        );
      }
      await owner.sync();
      await dad.sync();
      final fund = await dad.ledger.leaderFund(leader);
      expect(
        [fund.entrustedPaise, fund.distributedPaise, fund.returnedPaise, fund.unreconciledPaise],
        [400000, 350000, 0, 50000],
      );

      owner.remote.online = false;
      dad.remote.online = false;
      await owner.ledger.create(
        EntryDraft(
          type: EntryType.leaderAllocation,
          workerId: workerA,
          leaderWorkerId: leader,
          amountPaise: 50000,
          businessDate: today,
        ),
      );
      final dadAlloc = await dad.ledger.create(
        EntryDraft(
          type: EntryType.leaderAllocation,
          workerId: workerB,
          leaderWorkerId: leader,
          amountPaise: 50000,
          businessDate: today,
        ),
      );
      owner.remote.online = true;
      dad.remote.online = true;
      await owner.sync();
      await dad.sync();

      final attention = await dad.resolver.watchAttention().first;
      expect(attention.single.code, 'insufficient_leader_funds');
      expect((await dad.ledger.leaderFund(leader)).unreconciledPaise, 0);
      await dad.resolver.discardMine(attention.single);
      expect((await dad.db.select(dad.db.financialTransactions).get()).any((e) => e.id == dadAlloc), isFalse);
      expect(await dad.unsynced(), 0);
    });

    test('Scenario F: attendance conflict on a real server; keep mine', () async {
      final d = AppClock.today().addDays(-1).toIso();
      owner.remote.online = false;
      dad.remote.online = false;
      await owner.attendance.saveDay(d, [AttendanceMark(workerId: workerA, unitsMilli: 1000, ratePaise: 50000)]);
      await dad.attendance.saveDay(d, [AttendanceMark(workerId: workerA, unitsMilli: 500, ratePaise: 50000)]);
      owner.remote.online = true;
      dad.remote.online = true;
      await owner.sync();
      await dad.sync();
      final attention = await dad.resolver.watchAttention().first;
      expect(attention.single.code, 'attendance_exists');
      await dad.resolver.keepMine(attention.single);
      await dad.sync();
      await owner.sync();
      for (final p in [owner, dad]) {
        final rows = (await p.db.select(p.db.attendance).get())
            .where((a) => a.workerId == workerA && a.workDate == d)
            .toList();
        expect(rows.length, 1, reason: p.name);
        expect(rows.single.unitsMilli, 500, reason: p.name);
        expect(rows.single.syncStatus, RowSync.synced, reason: p.name);
      }
    });

    test('Scenario L: owner corrects a closed week; member blocked; week flagged on other phone', () async {
      final weekStart = AppClock.today().weekStart(1).addDays(-7);
      await owner.attendance.saveDay(weekStart.toIso(), [
        AttendanceMark(workerId: workerB, unitsMilli: 1000, ratePaise: 50000),
      ]);
      await owner.settlements.closeWeek(weekStart);
      await owner.sync();
      await dad.sync();
      expect(
        () => dad.attendance.saveDay(weekStart.toIso(), [
          AttendanceMark(workerId: workerB, unitsMilli: 500, ratePaise: 50000),
        ]),
        throwsA(isA<AppException>().having((e) => e.code, 'code', 'week_closed')),
      );
      await owner.attendance.saveDay(weekStart.toIso(), [
        AttendanceMark(workerId: workerB, unitsMilli: 500, ratePaise: 50000),
      ]);
      await owner.sync();
      await dad.sync();
      final s = await dad.settlements.watchSettlement(weekStart).first;
      expect(s!.needsReview, isTrue);
      final items = await (dad.db.select(dad.db.settlementItems)..where((i) => i.settlementId.equals(s.id))).get();
      expect(items.firstWhere((i) => i.workerId == workerB).grossPaise, 50000, reason: 'snapshot kept until reviewed');
    });

    test('Scenario K: another farm\'s user sees nothing and cannot pull', () async {
      final api = SupabaseRemoteApi(stranger);
      expect(await api.fetchRows('financial_transactions', 'farm_id', farmId), isEmpty);
      expect(await api.fetchRows('workers', 'farm_id', farmId), isEmpty);
      expect(await api.fetchRows('farm_members', 'farm_id', farmId), isEmpty);
      await expectLater(
        api.pullChanges(farmId, 0),
        throwsA(isA<RemoteError>().having((e) => e.kind, 'kind', RemoteErrorKind.forbidden)),
      );
      final res = await api.applyOps([
        {
          'op_id': newId(),
          'farm_id': farmId,
          'op_type': 'ledger_create',
          'base_revision': 0,
          'payload': {
            'id': newId(),
            'entry_type': 'advance',
            'worker_id': workerA,
            'amount_paise': 100,
            'business_date': today,
          },
        },
      ]);
      expect(res.single['code'], 'not_a_member');
      await expectLater(
        stranger.from('financial_transactions').insert({'id': newId()}),
        throwsA(isA<PostgrestException>()),
      );
    });

    test('Realtime signals another phone when the farm changes', () async {
      final got = Completer<void>();
      final channel = dad.client
          .channel('e2e-$stamp')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'farm_sync_state',
            filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'farm_id', value: farmId),
            callback: (_) {
              if (!got.isCompleted) got.complete();
            },
          );
      final subscribed = Completer<void>();
      channel.subscribe((status, [error]) {
        if (status == RealtimeSubscribeStatus.subscribed && !subscribed.isCompleted) subscribed.complete();
      });
      await subscribed.future.timeout(const Duration(seconds: 20));
      // A freshly started Realtime service creates its replication slot on
      // the first subscription and can miss changes made meanwhile (the app
      // never relies on Realtime alone). Allow a few attempts for warm-up.
      for (var attempt = 0; attempt < 3 && !got.isCompleted; attempt++) {
        await Future<void>.delayed(const Duration(seconds: 2));
        await owner.ledger.create(
          EntryDraft(type: EntryType.advance, workerId: workerA, amountPaise: 1000 + attempt, businessDate: today),
        );
        await owner.sync();
        await Future.any([got.future, Future<void>.delayed(const Duration(seconds: 10))]);
      }
      expect(got.isCompleted, isTrue, reason: 'no Realtime change signal received');
      await dad.client.removeChannel(channel);
    });

    test('revoked member: access stops on the next sync, records kept', () async {
      dad.remote.online = false;
      final id = await dad.ledger.create(
        EntryDraft(type: EntryType.advance, workerId: workerA, amountPaise: 2000, businessDate: today),
      );
      final m = (await owner.db.select(owner.db.farmMembers).get()).firstWhere((m) => m.userId == dad.userId);
      await owner.members.updateMember(m, status: 'disabled');
      await owner.sync();
      dad.remote.online = true;
      await dad.engine.sync();
      expect(dad.engine.state.phase, SyncPhase.accessRevoked);
      expect((await dad.db.select(dad.db.financialTransactions).get()).any((e) => e.id == id), isTrue);
      expect(await owner.remote.fetchRows('financial_transactions', 'id', id), isEmpty);
    });
  });
}
