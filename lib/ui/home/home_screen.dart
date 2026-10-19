import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/dates.dart';
import '../../data/db/database.dart';
import '../../data/repositories/work_repo.dart';
import '../../domain/ledger.dart';
import '../common/labels.dart';
import '../common/widgets.dart';
import '../money/entry_detail_screen.dart';
import '../money/give_money_screen.dart';
import '../reports/reports_screen.dart';
import '../settlement/weekly_screen.dart';
import '../shell.dart';
import '../work/work_diary_screen.dart';
import '../work/work_form_screen.dart';

final todayAttendanceProvider = StreamProvider.autoDispose<List<AttendanceRow>>(
  (ref) => ref.watch(attendanceRepoProvider).watchDay(AppClock.today().toIso()),
);

final weekEarnedProvider = StreamProvider.autoDispose<int>((ref) {
  final weekDay = ref.watch(farmProvider).value?.weekStartDay ?? 1;
  final today = AppClock.today();
  return ref.watch(reportsRepoProvider).watchEarned(today.weekStart(weekDay).toIso(), today.toIso());
});

final recentCashProvider = StreamProvider.autoDispose<List<LedgerEntry>>(
  (ref) => ref.watch(ledgerRepoProvider).watchRecentCash(limit: 5),
);

final todayWorkProvider = StreamProvider.autoDispose<List<AssignmentView>>((ref) {
  final today = AppClock.today().toIso();
  return ref.watch(workRepoProvider).watchAssignments(from: today, to: today);
});

final workTypesProvider = StreamProvider<List<WorkType>>(
  (ref) => ref.watch(workRepoProvider).watchWorkTypes(includeInactive: true),
);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final me = ref.watch(meProvider).value;
    final farm = ref.watch(farmProvider).value;
    final today = AppClock.today();
    final att = (ref.watch(todayAttendanceProvider).value ?? const []).where((a) => a.unitsMilli > 0).toList();
    final todayWages = att.fold<int>(0, (s, a) => s + a.earnedPaise);
    final weekEarned = ref.watch(weekEarnedProvider).value ?? 0;
    final balances = ref.watch(balancesProvider).value ?? const {};
    final due = balances.values.where((b) => b.wagePaise > 0).fold<int>(0, (s, b) => s + b.wagePaise);
    final ahead = balances.values.where((b) => b.wagePaise < 0).fold<int>(0, (s, b) => s - b.wagePaise);
    final loans = balances.values.fold<int>(0, (s, b) => s + (b.loanPaise > 0 ? b.loanPaise : 0));
    final leaderHeld = (ref.watch(leaderFundsProvider).value ?? const []).fold<int>(
      0,
      (s, f) => s + f.unreconciledPaise,
    );

    void push(Widget w) => Navigator.push(context, MaterialPageRoute(builder: (_) => w));

    return Scaffold(
      appBar: AppBar(title: Text(farm?.name ?? l.appTitle), actions: appBarActions(context)),
      body: ListView(
        padding: pagePadding,
        children: [
          const StatusBanners(),
          Text(l.greeting(me?.displayNameKn ?? me?.fullName ?? ''), style: Theme.of(context).textTheme.titleLarge),
          Text(
            context.dates.longDate(today),
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: AppColors.textMuted),
          ),
          gap16,
          ActionGrid(
            children: [
              BigActionButton(
                icon: Icons.fact_check,
                label: l.markAttendance,
                onTap: () => ref.read(tabProvider.notifier).go(2),
              ),
              BigActionButton(icon: Icons.payments, label: l.giveMoney, onTap: () => push(const GiveMoneyScreen())),
              BigActionButton(
                icon: Icons.assignment_add,
                label: l.assignWork,
                onTap: () => push(const WorkFormScreen()),
              ),
              BigActionButton(
                icon: Icons.calendar_view_week,
                label: l.weeklyAccounts,
                onTap: () => push(const WeeklyScreen()),
              ),
            ],
          ),
          SectionHeader(l.today),
          TileRow(
            children: [
              StatTile(
                label: l.todayWorkers,
                value: Text(l.peopleCount(att.length)),
                onTap: () => ref.read(tabProvider.notifier).go(2),
              ),
              StatTile(
                label: l.todayWages,
                value: AmountText(todayWages, style: Theme.of(context).textTheme.titleLarge),
              ),
            ],
          ),
          SectionHeader(l.balancesTitle),
          TileRow(
            children: [
              StatTile(
                label: l.weekEarned,
                value: AmountText(weekEarned, style: Theme.of(context).textTheme.titleLarge),
                onTap: () => push(const WeeklyScreen()),
              ),
              StatTile(
                label: l.wagesToPay,
                value: AmountText(due, style: Theme.of(context).textTheme.titleLarge),
                onTap: () => push(const WeeklyScreen()),
              ),
              if (ahead > 0)
                StatTile(
                  label: l.advancesAhead,
                  value: AmountText(ahead, style: Theme.of(context).textTheme.titleLarge),
                ),
              if (loans > 0)
                StatTile(
                  label: l.loansOutstanding,
                  value: AmountText(loans, style: Theme.of(context).textTheme.titleLarge),
                ),
              if (leaderHeld != 0)
                StatTile(
                  label: l.leaderCashHeld,
                  tone: AppColors.amberSoft,
                  value: AmountText(leaderHeld, style: Theme.of(context).textTheme.titleLarge),
                  onTap: () => push(const ReportsScreen()),
                ),
            ],
          ),
          gap8,
          Text(l.earningsNote, style: Theme.of(context).textTheme.bodySmall),
          SectionHeader(
            l.todaysWork,
            trailing: TextButton(onPressed: () => push(const WorkDiaryScreen()), child: Text(l.workDiary)),
          ),
          const _TodayWork(),
          SectionHeader(l.recentPayments),
          const _RecentPayments(),
          gap16,
          OutlinedButton.icon(
            onPressed: () => push(const ReportsScreen()),
            icon: const Icon(Icons.bar_chart),
            label: Text(l.reports),
          ),
        ],
      ),
    );
  }
}

class _TodayWork extends ConsumerWidget {
  const _TodayWork();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final work = ref.watch(todayWorkProvider).value ?? const [];
    final types = {for (final t in ref.watch(workTypesProvider).value ?? const <WorkType>[]) t.id: t};
    final workers = ref.watch(workerIndexProvider).value ?? const {};
    if (work.isEmpty) {
      return Card(
        child: ListTile(
          title: Text(l.noWorkToday),
          trailing: const Icon(Icons.add),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkFormScreen())),
        ),
      );
    }
    return Card(
      child: Column(
        children: [
          for (final v in work)
            ListTile(
              title: Text(workTypeName(l, types[v.assignment.workTypeId])),
              subtitle: Text(
                [
                  workStatusLabel(l, v.assignment.status),
                  if (v.workerIds.isNotEmpty) v.workerIds.map((id) => workerName(workers[id])).join(', '),
                ].join(' · '),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => WorkFormScreen(assignmentId: v.assignment.id)),
              ),
            ),
        ],
      ),
    );
  }
}

class _RecentPayments extends ConsumerWidget {
  const _RecentPayments();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final list = ref.watch(recentCashProvider).value ?? const [];
    final workers = ref.watch(workerIndexProvider).value ?? const {};
    if (list.isEmpty) return Card(child: ListTile(title: Text(l.noPayments)));
    return Card(
      child: Column(
        children: [for (final e in list) LedgerTile(entry: e, workers: workers)],
      ),
    );
  }
}

/// One ledger entry in a list: who, what, how much, who paid/recorded, sync.
class LedgerTile extends StatelessWidget {
  const LedgerTile({super.key, required this.entry, required this.workers, this.reversed = false});

  final LedgerEntry entry;
  final Map<String, Worker> workers;
  final bool reversed;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final type = EntryType.fromCode(entry.entryType);
    final amount = entry.isReversal ? -entry.amountPaise : entry.amountPaise;
    final leaderLine = entry.leaderWorkerId != null && type.needsLeader
        ? ' ← ${workerName(workers[entry.leaderWorkerId])}'
        : '';
    return ListTile(
      title: Text('${workerName(workers[entry.workerId])}$leaderLine'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            [
              entry.isReversal ? '${l.reversalLabel}: ${entryTypeLabel(l, type)}' : entryTypeLabel(l, type),
              context.dates.date(LocalDate.parse(entry.businessDate)),
              if (reversed) l.reversedLabel,
            ].join(' · '),
          ),
          Text(peopleLine(context, entry)),
          SyncChip(entry.syncStatus, pendingVerification: type == EntryType.leaderAllocation),
        ],
      ),
      trailing: AmountText(amount, signed: true, strike: reversed),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EntryDetailScreen(entryId: entry.id))),
    );
  }
}
