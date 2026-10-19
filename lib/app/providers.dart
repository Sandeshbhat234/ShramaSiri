import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/db/database.dart';
import '../data/remote/remote_api.dart';
import '../data/repositories/attendance_repo.dart';
import '../data/repositories/ledger_repo.dart';
import '../data/repositories/members_repo.dart';
import '../data/repositories/reports_repo.dart';
import '../data/repositories/repo_base.dart';
import '../data/repositories/settlement_repo.dart';
import '../data/repositories/work_repo.dart';
import '../data/repositories/workers_repo.dart';
import '../data/sync/conflict_resolver.dart';
import '../data/sync/outbox.dart';
import '../data/sync/sync_engine.dart';
import 'boot.dart';
import 'sync_controller.dart';

/// Opened in main() and injected with an override.
final databaseProvider = Provider<AppDatabase>((ref) => throw UnimplementedError('databaseProvider not overridden'));

/// Null when the build has no Supabase configuration.
final supabaseProvider = Provider<SupabaseClient?>((ref) => null);

final deviceIdProvider = Provider<String>((ref) => throw UnimplementedError('deviceIdProvider not overridden'));

final remoteApiProvider = Provider<RemoteApi?>((ref) {
  final client = ref.watch(supabaseProvider);
  return client == null ? null : SupabaseRemoteApi(client);
});

final outboxProvider = Provider<Outbox>((ref) => Outbox(ref.watch(databaseProvider)));

// ---------------------------------------------------------------------------
// Locale (Kannada by default)
// ---------------------------------------------------------------------------

final initialLocaleProvider = Provider<String>((ref) => 'kn');

final localeProvider = NotifierProvider<LocaleController, Locale>(LocaleController.new);

class LocaleController extends Notifier<Locale> {
  @override
  Locale build() => Locale(ref.watch(initialLocaleProvider));

  Future<void> set(String code) async {
    state = Locale(code);
    await ref.read(databaseProvider).setKv(KvKeys.locale, code);
  }
}

// ---------------------------------------------------------------------------
// Session-scoped services (only valid once boot reached BootReady)
// ---------------------------------------------------------------------------

final sessionProvider = Provider<AppSession>((ref) {
  final boot = ref.watch(bootProvider);
  if (boot is BootReady) return boot.session;
  throw StateError('No active session');
});

final syncEngineProvider = Provider<SyncEngine>((ref) {
  final session = ref.watch(sessionProvider);
  final remote = ref.watch(remoteApiProvider)!;
  final engine = SyncEngine(
    db: ref.watch(databaseProvider),
    remote: remote,
    farmId: session.farmId,
    userId: session.userId,
    outbox: ref.watch(outboxProvider),
  );
  ref.onDispose(engine.dispose);
  return engine;
});

final syncControllerProvider = Provider<SyncController>((ref) {
  final session = ref.watch(sessionProvider);
  final controller = SyncController(
    engine: ref.watch(syncEngineProvider),
    client: ref.watch(supabaseProvider),
    farmId: session.farmId,
  );
  ref.onDispose(controller.dispose);
  return controller;
});

final repoContextProvider = Provider<RepoContext>((ref) {
  final session = ref.watch(sessionProvider);
  return RepoContext(
    db: ref.watch(databaseProvider),
    outbox: ref.watch(outboxProvider),
    farmId: session.farmId,
    userId: session.userId,
    deviceId: ref.watch(deviceIdProvider),
    onWrite: () => ref.read(syncControllerProvider).nudge(),
  );
});

final workersRepoProvider = Provider((ref) => WorkersRepo(ref.watch(repoContextProvider)));
final attendanceRepoProvider = Provider((ref) => AttendanceRepo(ref.watch(repoContextProvider)));
final workRepoProvider = Provider((ref) => WorkRepo(ref.watch(repoContextProvider)));
final ledgerRepoProvider = Provider((ref) => LedgerRepo(ref.watch(repoContextProvider)));
final settlementRepoProvider = Provider((ref) => SettlementRepo(ref.watch(repoContextProvider)));
final membersRepoProvider = Provider((ref) => MembersRepo(ref.watch(repoContextProvider)));
final reportsRepoProvider = Provider((ref) => ReportsRepo(ref.watch(repoContextProvider)));
final conflictResolverProvider = Provider(
  (ref) => ConflictResolver(ref.watch(databaseProvider), ref.watch(outboxProvider)),
);

// ---------------------------------------------------------------------------
// Frequently used streams
// ---------------------------------------------------------------------------

final syncStateProvider = StreamProvider<SyncState>((ref) async* {
  final engine = ref.watch(syncEngineProvider);
  yield engine.state;
  yield* engine.states;
});

final outboxCountsProvider = StreamProvider<OutboxCounts>((ref) => ref.watch(outboxProvider).watchCounts());

final meProvider = StreamProvider<FarmMember?>((ref) => ref.watch(membersRepoProvider).watchMe());

final farmProvider = StreamProvider<Farm?>((ref) => ref.watch(membersRepoProvider).watchFarm());

final isAdminProvider = Provider<bool>((ref) {
  final role = ref.watch(meProvider).value?.role;
  return role == 'owner' || role == 'admin';
});

final workerIndexProvider = StreamProvider<Map<String, Worker>>(
  (ref) => ref.watch(workersRepoProvider).watchWorkerIndex(),
);

final membersByUserProvider = StreamProvider<Map<String, FarmMember>>(
  (ref) => ref.watch(membersRepoProvider).watchByUserId(),
);

final balancesProvider = StreamProvider<Map<String, WorkerBalance>>(
  (ref) => ref.watch(ledgerRepoProvider).watchBalances(),
);

final leaderFundsProvider = StreamProvider<List<LeaderFund>>((ref) => ref.watch(ledgerRepoProvider).watchLeaderFunds());

final accessRevokedProvider = StreamProvider<bool>(
  (ref) => ref.watch(databaseProvider).watchKv(KvKeys.accessRevoked).map((v) => v != null),
);

final lastVerifiedProvider = StreamProvider<DateTime?>(
  (ref) =>
      ref.watch(databaseProvider).watchKv(KvKeys.lastVerifiedAt).map((v) => v == null ? null : DateTime.tryParse(v)),
);
