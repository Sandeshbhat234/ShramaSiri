import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/boot.dart';
import '../app/providers.dart';
import '../app/theme.dart';
import '../core/dates.dart';
import '../data/repositories/repo_base.dart';
import 'accounts/accounts_screen.dart';
import 'attendance/attendance_screen.dart';
import 'auth/auth_screens.dart';
import 'common/labels.dart';
import 'common/widgets.dart';
import 'home/home_screen.dart';
import 'settings/settings_screen.dart';
import 'sync/sync_widgets.dart';
import 'workers/worker_list_screen.dart';

/// Selected bottom tab; screens can switch tabs (e.g. Home -> Attendance).
final tabProvider = NotifierProvider<TabController2, int>(TabController2.new);

class TabController2 extends Notifier<int> {
  @override
  int build() => 0;

  void go(int index) => state = index;
}

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => ref.read(syncControllerProvider).start());
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final revoked = ref.watch(accessRevokedProvider).value ?? false;
    if (revoked) {
      return MessageScreen(
        icon: Icons.no_accounts,
        title: l.accessRevokedTitle,
        body: l.accessRevokedBody,
        actions: [
          FilledButton(onPressed: () => ref.read(syncEngineProvider).sync(), child: Text(l.checkAgain)),
          TextButton(onPressed: () => ref.read(bootProvider.notifier).signOut(), child: Text(l.signOut)),
        ],
      );
    }
    final index = ref.watch(tabProvider);
    return PopScope(
      canPop: index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) ref.read(tabProvider.notifier).go(0);
      },
      child: Scaffold(
        body: IndexedStack(
          index: index,
          children: const [HomeScreen(), WorkerListScreen(), AttendanceScreen(), AccountsScreen()],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: ref.read(tabProvider.notifier).go,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: l.navHome,
            ),
            NavigationDestination(
              icon: const Icon(Icons.people_outline),
              selectedIcon: const Icon(Icons.people),
              label: l.navWorkers,
            ),
            NavigationDestination(
              icon: const Icon(Icons.fact_check_outlined),
              selectedIcon: const Icon(Icons.fact_check),
              label: l.navAttendance,
            ),
            NavigationDestination(
              icon: const Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: const Icon(Icons.account_balance_wallet),
              label: l.navAccounts,
            ),
          ],
        ),
      ),
    );
  }
}

/// Standard app bar actions: sync indicator and settings.
List<Widget> appBarActions(BuildContext context) => [
  const SyncIndicator(),
  IconButton(
    tooltip: context.l.settings,
    icon: const Icon(Icons.settings_outlined),
    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
  ),
];

/// Notices shown at the top of the main tabs when relevant.
class StatusBanners extends ConsumerWidget {
  const StatusBanners({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final verifiedAsync = ref.watch(lastVerifiedProvider);
    // Stay quiet until loaded, so a slow start never flashes a false warning.
    final verified = verifiedAsync.value;
    final readOnly =
        verifiedAsync.hasValue &&
        (verified == null || AppClock.nowUtc().difference(verified) > maxOfflineVerificationAge);
    return Column(
      children: [
        if (readOnly)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Banner2(text: l.readOnlyBanner, icon: Icons.lock_clock, color: AppColors.amberSoft),
          ),
        if (AppClock.deviceClockLooksWrong)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Banner2(text: l.clockWrong, icon: Icons.schedule, color: AppColors.amberSoft),
          ),
      ],
    );
  }
}
