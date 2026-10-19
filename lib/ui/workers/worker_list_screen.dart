import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/money.dart';
import '../../data/db/database.dart';
import '../../data/repositories/ledger_repo.dart';
import '../common/labels.dart';
import '../common/widgets.dart';
import '../shell.dart';
import 'group_form_screen.dart';
import 'worker_detail_screen.dart';
import 'worker_form_screen.dart';

final workerListProvider = StreamProvider.autoDispose.family<List<Worker>, (bool, String)>(
  (ref, args) => ref.watch(workersRepoProvider).watchWorkers(includeArchived: args.$1, search: args.$2),
);

final groupsProvider = StreamProvider<List<WorkerGroup>>((ref) => ref.watch(workersRepoProvider).watchGroups());

final groupMembersProvider = StreamProvider<Map<String, Set<String>>>(
  (ref) => ref.watch(workersRepoProvider).watchGroupMembers(),
);

/// "Wages due ₹1,500" / "Advance given ₹300" / "Settled".
String balanceCaption(BuildContext context, WorkerBalance? b) {
  final l = context.l;
  if (b == null || b.wagePaise == 0) return l.settledUp;
  return b.wagePaise > 0
      ? '${l.wageDue} ${Money.format(b.wagePaise)}'
      : '${l.advanceAhead} ${Money.format(-b.wagePaise)}';
}

class WorkerListScreen extends ConsumerStatefulWidget {
  const WorkerListScreen({super.key});

  @override
  ConsumerState<WorkerListScreen> createState() => _WorkerListScreenState();
}

class _WorkerListScreenState extends ConsumerState<WorkerListScreen> {
  String _search = '';
  bool _archived = false;
  bool _groups = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    void push(Widget w) => Navigator.push(context, MaterialPageRoute(builder: (_) => w));
    return Scaffold(
      appBar: AppBar(title: Text(l.navWorkers), actions: appBarActions(context)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => push(_groups ? const GroupFormScreen() : const WorkerFormScreen()),
        icon: const Icon(Icons.add),
        label: Text(_groups ? l.addGroup : l.addWorker),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SegmentedButton<bool>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: false, label: Text(l.navWorkers), icon: const Icon(Icons.person)),
                ButtonSegment(value: true, label: Text(l.groups), icon: const Icon(Icons.groups)),
              ],
              selected: {_groups},
              onSelectionChanged: (s) => setState(() => _groups = s.first),
            ),
          ),
          Expanded(child: _groups ? const _GroupList() : _workers(context)),
        ],
      ),
    );
  }

  Widget _workers(BuildContext context) {
    final l = context.l;
    final list = ref.watch(workerListProvider((_archived, _search)));
    final balances = ref.watch(balancesProvider).value ?? const {};
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: l.search),
            onChanged: (v) => setState(() => _search = v),
          ),
        ),
        SwitchListTile(
          title: Text(l.showArchived, style: Theme.of(context).textTheme.bodyMedium),
          value: _archived,
          onChanged: (v) => setState(() => _archived = v),
        ),
        Expanded(
          child: AsyncView(
            list,
            builder: (workers) {
              if (workers.isEmpty) {
                return EmptyState(icon: Icons.person_add_alt, text: _search.isEmpty ? l.noWorkers : l.noMatches);
              }
              return ListView.separated(
                padding: const EdgeInsets.only(bottom: 96),
                itemCount: workers.length,
                separatorBuilder: (_, _) => const Divider(height: 1, indent: 16, endIndent: 16),
                itemBuilder: (context, i) {
                  final w = workers[i];
                  final b = balances[w.id];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: w.status == 'archived' ? AppColors.border : AppColors.greenSoft,
                      child: Text(
                        w.nameKn.characters.first,
                        style: const TextStyle(fontSize: 20, color: AppColors.text),
                      ),
                    ),
                    title: Text(w.nameKn),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          [
                            l.atRate(Money.format(w.defaultWagePaise)),
                            if (w.status == 'archived') l.archived,
                          ].join(' · '),
                        ),
                        Text(
                          balanceCaption(context, b),
                          style: TextStyle(color: (b?.wagePaise ?? 0) < 0 ? AppColors.red : AppColors.textMuted),
                        ),
                        SyncChip(w.syncStatus),
                      ],
                    ),
                    trailing: w.isLeader ? Chip(label: Text(l.groupLeaderBadge)) : const Icon(Icons.chevron_right),
                    onTap: () =>
                        Navigator.push(context, MaterialPageRoute(builder: (_) => WorkerDetailScreen(workerId: w.id))),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _GroupList extends ConsumerWidget {
  const _GroupList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final groups = ref.watch(groupsProvider);
    final members = ref.watch(groupMembersProvider).value ?? const {};
    final workers = ref.watch(workerIndexProvider).value ?? const {};
    return AsyncView(
      groups,
      builder: (list) {
        if (list.isEmpty) return EmptyState(icon: Icons.groups_outlined, text: l.noGroups);
        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 96),
          itemCount: list.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final g = list[i];
            final ids = members[g.id] ?? const {};
            return ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.greenSoft,
                child: Icon(Icons.groups, color: AppColors.green),
              ),
              title: Text(g.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    [
                      l.memberCount(ids.length),
                      '${l.leader}: ${g.leaderWorkerId == null ? l.noLeader : workerName(workers[g.leaderWorkerId])}',
                    ].join(' · '),
                  ),
                  SyncChip(g.syncStatus),
                ],
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GroupFormScreen(groupId: g.id))),
            );
          },
        );
      },
    );
  }
}
