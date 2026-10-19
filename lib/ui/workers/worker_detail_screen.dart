import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/dates.dart';
import '../../core/money.dart';
import '../../data/db/database.dart';
import '../../data/repositories/ledger_repo.dart';
import '../../data/repositories/work_repo.dart';
import '../common/labels.dart';
import '../common/widgets.dart';
import '../home/home_screen.dart';
import '../money/adjustment_screen.dart';
import '../money/give_money_screen.dart';
import '../settlement/statement_screen.dart';
import '../work/work_form_screen.dart';
import 'worker_form_screen.dart';
import 'worker_list_screen.dart';

final workerProvider = StreamProvider.autoDispose.family<Worker?, String>(
  (ref, id) => ref.watch(workersRepoProvider).watchWorker(id),
);
final workerBalanceProvider = StreamProvider.autoDispose.family<WorkerBalance, String>(
  (ref, id) => ref.watch(ledgerRepoProvider).watchBalance(id),
);
final workerAttendanceProvider = StreamProvider.autoDispose.family<List<AttendanceRow>, (String, int)>(
  (ref, a) => ref.watch(attendanceRepoProvider).watchWorkerHistory(a.$1, limit: a.$2),
);
final workerEntriesProvider = StreamProvider.autoDispose.family<List<LedgerEntry>, (String, int)>(
  (ref, a) => ref.watch(ledgerRepoProvider).watchEntries(LedgerFilter(workerId: a.$1), limit: a.$2),
);
final workerWorkProvider = StreamProvider.autoDispose.family<List<AssignmentView>, String>((ref, id) {
  final today = AppClock.today();
  return ref
      .watch(workRepoProvider)
      .watchAssignments(from: today.addDays(-90).toIso(), to: today.addDays(30).toIso(), workerId: id);
});
final reversedIdsProvider = StreamProvider<Set<String>>((ref) => ref.watch(ledgerRepoProvider).watchReversedIds());

class WorkerDetailScreen extends ConsumerStatefulWidget {
  const WorkerDetailScreen({super.key, required this.workerId});

  final String workerId;

  @override
  ConsumerState<WorkerDetailScreen> createState() => _WorkerDetailScreenState();
}

class _WorkerDetailScreenState extends ConsumerState<WorkerDetailScreen> {
  int _attLimit = 30;
  int _moneyLimit = 30;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final worker = ref.watch(workerProvider(widget.workerId)).value;
    final balance = ref.watch(workerBalanceProvider(widget.workerId)).value;
    void push(Widget w) => Navigator.push(context, MaterialPageRoute(builder: (_) => w));
    if (worker == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final groups = ref.watch(groupsProvider).value ?? const [];
    final members = ref.watch(groupMembersProvider).value ?? const {};
    final myGroups = groups.where((g) => members[g.id]?.contains(worker.id) ?? false).toList();
    final wage = balance?.wagePaise ?? 0;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(worker.nameKn),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: l.edit,
              onPressed: () => push(WorkerFormScreen(workerId: worker.id)),
            ),
          ],
        ),
        body: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              sliver: SliverList.list(
                children: [
                  Text(
                    [
                      if (worker.nameEn != null) worker.nameEn!,
                      '${l.dailyWage}: ${Money.format(worker.defaultWagePaise)}',
                      if (worker.phone != null) worker.phone!,
                      if (worker.status == 'archived') l.archived,
                    ].join(' · '),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  if (worker.isLeader || myGroups.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      children: [
                        if (worker.isLeader)
                          Chip(label: Text(l.groupLeaderBadge), avatar: const Icon(Icons.star, size: 18)),
                        for (final g in myGroups) Chip(label: Text(g.name), avatar: const Icon(Icons.groups, size: 18)),
                      ],
                    ),
                  if (worker.notes != null) Text(worker.notes!, style: Theme.of(context).textTheme.bodySmall),
                  gap12,
                  TileRow(
                    children: [
                      StatTile(
                        label: wage >= 0 ? l.wageDue : l.advanceAhead,
                        tone: wage < 0 ? AppColors.amberSoft : null,
                        value: AmountText(wage.abs(), style: Theme.of(context).textTheme.titleLarge),
                        caption: balance?.hasPending == true ? l.statusSaved : null,
                      ),
                      if ((balance?.loanPaise ?? 0) != 0)
                        StatTile(
                          label: l.loanDue,
                          value: AmountText(balance!.loanPaise, style: Theme.of(context).textTheme.titleLarge),
                        ),
                    ],
                  ),
                  gap12,
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          icon: const Icon(Icons.payments),
                          label: Text(l.giveMoney),
                          onPressed: () => push(GiveMoneyScreen(workerId: worker.id)),
                        ),
                      ),
                      gap8,
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.receipt_long),
                          label: Text(l.statement),
                          onPressed: () => push(StatementScreen(workerId: worker.id)),
                        ),
                      ),
                    ],
                  ),
                  gap8,
                  OutlinedButton.icon(
                    icon: const Icon(Icons.tune),
                    label: Text(l.addAdjustment),
                    onPressed: () => push(AdjustmentScreen(workerId: worker.id)),
                  ),
                ],
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabsHeader(
                TabBar(
                  tabs: [
                    Tab(text: l.tabAttendance),
                    Tab(text: l.tabWork),
                    Tab(text: l.tabMoney),
                  ],
                ),
              ),
            ),
          ],
          body: TabBarView(children: [_attendanceTab(context), _workTab(context), _moneyTab(context)]),
        ),
      ),
    );
  }

  Widget _attendanceTab(BuildContext context) {
    final l = context.l;
    final rows = ref.watch(workerAttendanceProvider((widget.workerId, _attLimit))).value ?? const [];
    if (rows.isEmpty) return EmptyState(icon: Icons.event_busy, text: l.noEntries);
    return ListView(
      children: [
        for (final a in rows)
          ListTile(
            title: Text(context.dates.shortDay(LocalDate.parse(a.workDate))),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${l.daysShort(Units.format(a.unitsMilli))} ${l.atRate(Money.format(a.ratePaise))}'),
                SyncChip(a.syncStatus),
              ],
            ),
            trailing: AmountText(a.earnedPaise),
          ),
        if (rows.length >= _attLimit)
          TextButton(onPressed: () => setState(() => _attLimit += 60), child: Text(l.loadMore)),
      ],
    );
  }

  Widget _workTab(BuildContext context) {
    final l = context.l;
    final items = ref.watch(workerWorkProvider(widget.workerId)).value ?? const [];
    final types = {for (final t in ref.watch(workTypesProvider).value ?? const <WorkType>[]) t.id: t};
    if (items.isEmpty) return EmptyState(icon: Icons.assignment_outlined, text: l.noWork);
    return ListView(
      children: [
        for (final v in items)
          ListTile(
            title: Text(workTypeName(l, types[v.assignment.workTypeId])),
            subtitle: Text(
              [
                context.dates.shortDay(LocalDate.parse(v.assignment.workDate)),
                workStatusLabel(l, v.assignment.status),
                if (v.assignment.fieldName != null) v.assignment.fieldName!,
              ].join(' · '),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => WorkFormScreen(assignmentId: v.assignment.id)),
            ),
          ),
      ],
    );
  }

  Widget _moneyTab(BuildContext context) {
    final l = context.l;
    final entries = ref.watch(workerEntriesProvider((widget.workerId, _moneyLimit))).value ?? const [];
    final workers = ref.watch(workerIndexProvider).value ?? const {};
    final reversed = ref.watch(reversedIdsProvider).value ?? const {};
    if (entries.isEmpty) return EmptyState(icon: Icons.payments_outlined, text: l.noEntries);
    return ListView(
      children: [
        for (final e in entries) LedgerTile(entry: e, workers: workers, reversed: reversed.contains(e.id)),
        if (entries.length >= _moneyLimit)
          TextButton(onPressed: () => setState(() => _moneyLimit += 50), child: Text(l.loadMore)),
      ],
    );
  }
}

class _TabsHeader extends SliverPersistentHeaderDelegate {
  _TabsHeader(this.tabBar);

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) =>
      Container(color: AppColors.background, child: tabBar);

  @override
  bool shouldRebuild(covariant _TabsHeader oldDelegate) => oldDelegate.tabBar != tabBar;
}
