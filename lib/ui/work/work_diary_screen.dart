import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/dates.dart';
import '../../data/db/database.dart';
import '../../data/repositories/work_repo.dart';
import '../common/labels.dart';
import '../common/widgets.dart';
import '../home/home_screen.dart';
import 'work_form_screen.dart';

final diaryProvider = StreamProvider.autoDispose.family<List<AssignmentView>, int>((ref, days) {
  final today = AppClock.today();
  return ref
      .watch(workRepoProvider)
      .watchAssignments(from: today.addDays(-days).toIso(), to: today.addDays(60).toIso());
});

class WorkDiaryScreen extends ConsumerStatefulWidget {
  const WorkDiaryScreen({super.key});

  @override
  ConsumerState<WorkDiaryScreen> createState() => _WorkDiaryScreenState();
}

class _WorkDiaryScreenState extends ConsumerState<WorkDiaryScreen> {
  int _days = 30;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final items = ref.watch(diaryProvider(_days));
    final types = {for (final t in ref.watch(workTypesProvider).value ?? const <WorkType>[]) t.id: t};
    final workers = ref.watch(workerIndexProvider).value ?? const {};
    final members = ref.watch(membersByUserProvider).value ?? const {};
    return Scaffold(
      appBar: AppBar(title: Text(l.workDiary)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkFormScreen())),
        icon: const Icon(Icons.add),
        label: Text(l.addWork),
      ),
      body: AsyncView(
        items,
        builder: (list) {
          if (list.isEmpty) return EmptyState(icon: Icons.assignment_outlined, text: l.noWork);
          final byDate = <String, List<AssignmentView>>{};
          for (final v in list) {
            byDate.putIfAbsent(v.assignment.workDate, () => []).add(v);
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              for (final e in byDate.entries) ...[
                SectionHeader(context.dates.longDate(LocalDate.parse(e.key))),
                Card(
                  child: Column(
                    children: [
                      for (final v in e.value)
                        ListTile(
                          title: Text(workTypeName(l, types[v.assignment.workTypeId])),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                [
                                  workStatusLabel(l, v.assignment.status),
                                  if (v.assignment.fieldName != null) v.assignment.fieldName!,
                                ].join(' · '),
                              ),
                              if (v.workerIds.isNotEmpty)
                                Text(v.workerIds.map((id) => workerName(workers[id])).join(', ')),
                              Text(l.assignedBy(members[v.assignment.assignedBy]?.fullName ?? '—')),
                              SyncChip(v.assignment.syncStatus),
                            ],
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => WorkFormScreen(assignmentId: v.assignment.id)),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              TextButton(onPressed: () => setState(() => _days += 60), child: Text(l.loadMore)),
            ],
          );
        },
      ),
    );
  }
}
