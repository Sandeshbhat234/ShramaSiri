// Renders every screen on a small phone (360x640 dp) in Kannada with large
// system text (1.3x) over seeded data. Fails on layout overflow or any
// exception thrown while building. On Windows the Nirmala UI font is loaded
// so Kannada text has realistic widths.
import 'dart:io';

import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shramasiri/app/boot.dart';
import 'package:shramasiri/app/providers.dart';
import 'package:shramasiri/app/sync_controller.dart';
import 'package:shramasiri/app/theme.dart';
import 'package:shramasiri/core/dates.dart';
import 'package:shramasiri/data/db/database.dart';
import 'package:shramasiri/data/remote/remote_api.dart';
import 'package:shramasiri/data/repositories/attendance_repo.dart';
import 'package:shramasiri/data/repositories/ledger_repo.dart';
import 'package:shramasiri/data/repositories/repo_base.dart';
import 'package:shramasiri/data/repositories/settlement_repo.dart';
import 'package:shramasiri/data/repositories/work_repo.dart';
import 'package:shramasiri/data/repositories/workers_repo.dart';
import 'package:shramasiri/data/sync/outbox.dart';
import 'package:shramasiri/data/sync/sync_engine.dart';
import 'package:shramasiri/domain/ledger.dart';
import 'package:shramasiri/l10n/app_localizations.dart';
import 'package:shramasiri/ui/accounts/accounts_screen.dart';
import 'package:shramasiri/ui/attendance/attendance_history_screen.dart';
import 'package:shramasiri/ui/attendance/attendance_screen.dart';
import 'package:shramasiri/ui/auth/auth_screens.dart';
import 'package:shramasiri/ui/home/home_screen.dart';
import 'package:shramasiri/ui/leader/leader_screens.dart';
import 'package:shramasiri/ui/money/adjustment_screen.dart';
import 'package:shramasiri/ui/money/entry_detail_screen.dart';
import 'package:shramasiri/ui/money/give_money_screen.dart';
import 'package:shramasiri/ui/money/payment_history_screen.dart';
import 'package:shramasiri/ui/reports/reports_screen.dart';
import 'package:shramasiri/ui/settings/audit_screen.dart';
import 'package:shramasiri/ui/settings/members_screen.dart';
import 'package:shramasiri/ui/settings/settings_screen.dart';
import 'package:shramasiri/ui/settlement/statement_screen.dart';
import 'package:shramasiri/ui/settlement/weekly_screen.dart';
import 'package:shramasiri/ui/sync/sync_screen.dart';
import 'package:shramasiri/ui/work/work_diary_screen.dart';
import 'package:shramasiri/ui/work/work_form_screen.dart';
import 'package:shramasiri/ui/workers/group_form_screen.dart';
import 'package:shramasiri/ui/workers/worker_detail_screen.dart';
import 'package:shramasiri/ui/workers/worker_form_screen.dart';
import 'package:shramasiri/ui/workers/worker_list_screen.dart';

const farmId = 'farm-ui';
const userId = 'user-ui';

class _OfflineRemote implements RemoteApi {
  Never _off() => throw RemoteError(RemoteErrorKind.network, 'offline');
  @override
  Future<List<Map<String, dynamic>>> applyOps(List<Map<String, dynamic>> ops) async => _off();
  @override
  Future<PullPage> pullChanges(String farmId, int afterSeq, {int limit = 500}) async => _off();
  @override
  Future<Map<String, dynamic>> getMyContext() async => _off();
  @override
  Future<Map<String, dynamic>> createFarm({
    required String farmId,
    required String farmName,
    required String fullName,
    String? displayNameKn,
  }) async => _off();
  @override
  Future<Map<String, dynamic>> acceptInvitation({
    required String memberId,
    required String fullName,
    String? displayNameKn,
  }) async => _off();
  @override
  Future<List<Map<String, dynamic>>> fetchRows(String table, String column, String value) async => _off();
  @override
  Future<bool> refreshSession() async => false;
}

class _ReadyBoot extends BootController {
  @override
  BootState build() => const BootReady(AppSession(userId: userId, email: 'sandesh@example.com', farmId: farmId));
}

class _QuietSync extends SyncController {
  _QuietSync(SyncEngine engine) : super(engine: engine, client: null, farmId: farmId);
  @override
  Future<void> start() async {}
  @override
  void nudge() {}
}

late AppDatabase db;
late Map<String, String> ids;

Future<void> seed() async {
  final now = DateTime.now().toUtc();
  await db
      .into(db.farms)
      .insert(FarmsCompanion.insert(id: farmId, name: 'ಭಟ್ ತೋಟ', createdBy: userId, createdAt: now, updatedAt: now));
  await db
      .into(db.farmMembers)
      .insert(
        FarmMembersCompanion.insert(
          id: 'm1',
          farmId: farmId,
          userId: const Value(userId),
          email: 'sandesh@example.com',
          role: 'owner',
          status: 'active',
          fullName: 'Sandesh Bhat',
          createdAt: now,
          updatedAt: now,
        ),
      );
  await db
      .into(db.farmMembers)
      .insert(
        FarmMembersCompanion.insert(
          id: 'm2',
          farmId: farmId,
          userId: const Value('user-dad'),
          email: 'ramesh@example.com',
          role: 'member',
          status: 'active',
          fullName: 'Ramesh Bhat',
          createdAt: now,
          updatedAt: now,
        ),
      );
  await db
      .into(db.workTypes)
      .insert(
        WorkTypesCompanion.insert(
          id: 't1',
          farmId: farmId,
          code: 'arecanut_harvest',
          nameKn: 'ಅಡಿಕೆ ಕೊಯ್ಲು',
          nameEn: 'Arecanut harvesting',
          createdAt: now,
          updatedAt: now,
        ),
      );
  await db.setKv(KvKeys.lastVerifiedAt, now.toIso8601String());

  final ctx = RepoContext(db: db, outbox: Outbox(db), farmId: farmId, userId: userId, deviceId: 'd');
  final workers = WorkersRepo(ctx);
  final a = await workers.saveWorker(
    WorkerDraft(nameKn: 'ಮಂಜುನಾಥ ಗೌಡ', nameEn: 'Manjunath Gowda', defaultWagePaise: 50000),
  );
  final b = await workers.saveWorker(WorkerDraft(nameKn: 'ಗಣೇಶ', defaultWagePaise: 55000, phone: '9876543210'));
  final l = await workers.saveWorker(WorkerDraft(nameKn: 'ರಾಜು ನಾಯಕ', defaultWagePaise: 60000, isLeader: true));
  final g = await workers.saveGroup(GroupDraft(name: 'ರಾಜು ಗುಂಪು', leaderWorkerId: l, memberIds: {a, b}));
  final today = AppClock.today();
  final week = today.weekStart(1).addDays(-7);
  for (var i = 0; i < 4; i++) {
    await AttendanceRepo(ctx).saveDay(week.addDays(i).toIso(), [
      AttendanceMark(workerId: a, unitsMilli: 1000, ratePaise: 50000),
      AttendanceMark(workerId: b, unitsMilli: 500, ratePaise: 55000),
    ]);
  }
  await AttendanceRepo(ctx).saveDay(today.toIso(), [AttendanceMark(workerId: a, unitsMilli: 750, ratePaise: 50000)]);
  final ledger = LedgerRepo(ctx);
  final adv = await ledger.create(
    EntryDraft(type: EntryType.advance, workerId: a, amountPaise: 50000, businessDate: week.addDays(1).toIso()),
  );
  await ledger.create(
    EntryDraft(
      type: EntryType.wagePayment,
      workerId: b,
      amountPaise: 30000,
      businessDate: today.toIso(),
      paidBy: 'user-dad',
    ),
  );
  await ledger.create(
    EntryDraft(type: EntryType.leaderTransfer, workerId: l, amountPaise: 400000, businessDate: today.toIso()),
  );
  await ledger.create(
    EntryDraft(
      type: EntryType.leaderAllocation,
      workerId: a,
      leaderWorkerId: l,
      amountPaise: 100000,
      businessDate: today.toIso(),
    ),
  );
  await ledger.create(EntryDraft(type: EntryType.loan, workerId: b, amountPaise: 200000, businessDate: today.toIso()));
  await WorkRepo(ctx).saveAssignment(
    AssignmentDraft(workDate: today.toIso(), workTypeId: 't1', workerIds: {a, b}, fieldName: 'ಮೇಲಿನ ತೋಟ'),
  );
  await SettlementRepo(ctx).closeWeek(week);
  ids = {'a': a, 'b': b, 'l': l, 'g': g, 'adv': adv};
}

Widget app(Widget home) {
  return ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      deviceIdProvider.overrideWithValue('d'),
      initialLocaleProvider.overrideWithValue('kn'),
      remoteApiProvider.overrideWithValue(_OfflineRemote()),
      bootProvider.overrideWith(_ReadyBoot.new),
      syncControllerProvider.overrideWith((ref) => _QuietSync(ref.watch(syncEngineProvider))),
    ],
    child: MaterialApp(
      theme: buildTheme(),
      locale: const Locale('kn'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: home,
    ),
  );
}

void main() {
  setUpAll(() async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final font = File(r'C:\Windows\Fonts\Nirmala.ttc');
    if (font.existsSync()) {
      final loader = FontLoader('Roboto')..addFont(Future.value(ByteData.view(font.readAsBytesSync().buffer)));
      await loader.load();
    }
  });

  final screens = <String, Widget Function()>{
    'home': () => const HomeScreen(),
    'workers': () => const WorkerListScreen(),
    'attendance': () => const AttendanceScreen(),
    'accounts': () => const AccountsScreen(),
    'attendance history': () => const AttendanceHistoryScreen(),
    'worker detail': () => WorkerDetailScreen(workerId: ids['a']!),
    'worker form': () => WorkerFormScreen(workerId: ids['a']),
    'group form': () => GroupFormScreen(groupId: ids['g']),
    'give money': () => GiveMoneyScreen(workerId: ids['l'], type: EntryType.leaderTransfer),
    'adjustment': () => AdjustmentScreen(workerId: ids['b']!),
    'payment history': () => const PaymentHistoryScreen(),
    'entry detail': () => EntryDetailScreen(entryId: ids['adv']!),
    'leader funds': () => const LeaderFundsScreen(),
    'leader ledger': () => LeaderLedgerScreen(leaderId: ids['l']!),
    'distribute': () => DistributeScreen(leaderId: ids['l']!),
    'weekly (closed week)': () => WeeklyScreen(weekStart: AppClock.today().weekStart(1).addDays(-7)),
    'weekly (this week)': () => const WeeklyScreen(),
    'statement': () => StatementScreen(workerId: ids['a']!, weekStart: AppClock.today().weekStart(1).addDays(-7)),
    'work diary': () => const WorkDiaryScreen(),
    'work form': () => const WorkFormScreen(),
    'work types': () => const WorkTypesScreen(),
    'reports': () => const ReportsScreen(),
    'sync': () => const SyncScreen(),
    'diagnostics': () => const DiagnosticsScreen(),
    'settings': () => const SettingsScreen(),
    'members': () => const MembersScreen(),
    'audit': () => const AuditScreen(),
    'profile': () => const ProfileScreen(),
    'sign in': () => const SignInScreen(),
    'onboarding': () => OnboardingScreen(
      state: BootOnboarding(email: 'x@example.com', invitations: [Invitation('m', 'ಭಟ್ ತೋಟ', 'Ramesh')]),
    ),
  };

  for (final entry in screens.entries) {
    testWidgets('renders on a small phone with large text: ${entry.key}', (tester) async {
      tester.view.physicalSize = const Size(720, 1280);
      tester.view.devicePixelRatio = 2;
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      // Report layout errors immediately, while the widget tree still exists.
      final original = FlutterError.onError;
      FlutterError.onError = (details) {
        FlutterError.dumpErrorToConsole(details, forceReport: true);
        original?.call(details);
      };
      addTearDown(() => FlutterError.onError = original);

      await tester.runAsync(() async {
        db = AppDatabase(NativeDatabase.memory());
        await seed();
      });
      await tester.pumpWidget(app(entry.value()));
      for (var i = 0; i < 6; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
        await tester.pump(const Duration(milliseconds: 50));
      }
      // Scroll through to lay out everything below the fold too.
      final scrollables = find.byType(Scrollable);
      if (scrollables.evaluate().isNotEmpty) {
        await tester.drag(scrollables.first, const Offset(0, -2000), warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 100));
      }

      // In-memory database: dropped with the test; closing it while stream
      // queries wind down only blocks the fake-async clock.
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    });
  }
}
