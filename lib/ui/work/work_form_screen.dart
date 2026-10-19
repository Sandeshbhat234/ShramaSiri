import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/dates.dart';
import '../../data/db/database.dart';
import '../../data/repositories/work_repo.dart';
import '../common/labels.dart';
import '../common/pickers.dart';
import '../common/widgets.dart';
import '../home/home_screen.dart';

class WorkFormScreen extends ConsumerStatefulWidget {
  const WorkFormScreen({super.key, this.assignmentId});

  final String? assignmentId;

  @override
  ConsumerState<WorkFormScreen> createState() => _WorkFormScreenState();
}

class _WorkFormScreenState extends ConsumerState<WorkFormScreen> {
  LocalDate _date = AppClock.today();
  String? _typeId;
  String _status = WorkStatus.planned;
  Set<String> _workers = {};
  final _field = TextEditingController();
  final _description = TextEditingController();
  final _notes = TextEditingController();
  AssignmentView? _existing;
  bool _loaded = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.assignmentId != null) {
      final v = await ref.read(workRepoProvider).getAssignment(widget.assignmentId!);
      if (v != null) {
        _existing = v;
        _date = LocalDate.parse(v.assignment.workDate);
        _typeId = v.assignment.workTypeId;
        _status = v.assignment.status;
        _workers = v.workerIds.toSet();
        _field.text = v.assignment.fieldName ?? '';
        _description.text = v.assignment.description ?? '';
        _notes.text = v.assignment.notes ?? '';
      }
    }
    if (mounted) setState(() => _loaded = true);
  }

  Future<void> _save() async {
    final l = context.l;
    if (_typeId == null) {
      showSnack(context, l.chooseWorkType, error: true);
      return;
    }
    setState(() => _busy = true);
    try {
      await ref
          .read(workRepoProvider)
          .saveAssignment(
            AssignmentDraft(
              id: _existing?.assignment.id,
              workDate: _date.toIso(),
              workTypeId: _typeId!,
              fieldName: _field.text,
              description: _description.text,
              status: _status,
              notes: _notes.text,
              workerIds: _workers,
            ),
          );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _newType() async {
    final l = context.l;
    final name = await promptText(context, title: l.addWorkType, label: l.workTypeName);
    if (name == null) return;
    try {
      final id = await ref.read(workRepoProvider).saveWorkType(nameKn: name, nameEn: name);
      setState(() => _typeId = id);
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    }
  }

  Future<void> _addPresentToday() async {
    final rows = await ref.read(attendanceRepoProvider).getDay(_date.toIso());
    setState(() => _workers.addAll(rows.where((a) => a.unitsMilli > 0).map((a) => a.workerId)));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final types = (ref.watch(workTypesProvider).value ?? const <WorkType>[])
        .where((t) => t.active || t.id == _typeId)
        .toList();
    final workers = ref.watch(workerIndexProvider).value ?? const {};
    final chosen = _workers.map((id) => workers[id]).whereType<Worker>().toList()
      ..sort((a, b) => a.nameKn.compareTo(b.nameKn));

    return Scaffold(
      appBar: AppBar(title: Text(_existing == null ? l.addWork : l.editWork)),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: pagePadding,
              children: [
                DateSelector(
                  date: _date,
                  onChanged: (d) => setState(() => _date = d),
                  last: AppClock.today().addDays(60),
                ),
                gap16,
                Text(l.workType, style: Theme.of(context).textTheme.titleSmall),
                gap8,
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final t in types)
                      ChoiceChip(
                        label: Text(workTypeName(l, t)),
                        selected: _typeId == t.id,
                        onSelected: (_) => setState(() => _typeId = t.id),
                      ),
                    ActionChip(
                      avatar: const Icon(Icons.add, size: 18),
                      label: Text(l.addWorkType),
                      onPressed: _newType,
                    ),
                  ],
                ),
                gap16,
                Text(l.status, style: Theme.of(context).textTheme.titleSmall),
                gap8,
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final s in WorkStatus.all)
                      ChoiceChip(
                        label: Text(workStatusLabel(l, s)),
                        selected: _status == s,
                        onSelected: (_) => setState(() => _status = s),
                      ),
                  ],
                ),
                SectionHeader(
                  '${l.navWorkers} (${chosen.length})',
                  trailing: TextButton.icon(
                    icon: const Icon(Icons.edit),
                    label: Text(l.selectWorkers),
                    onPressed: () async {
                      final ids = await pickWorkers(context, selected: _workers);
                      if (ids != null) setState(() => _workers = ids);
                    },
                  ),
                ),
                if (chosen.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final w in chosen)
                        InputChip(label: Text(w.nameKn), onDeleted: () => setState(() => _workers.remove(w.id))),
                    ],
                  ),
                TextButton.icon(
                  onPressed: _addPresentToday,
                  icon: const Icon(Icons.fact_check),
                  label: Text(l.addPresentWorkers),
                ),
                Text(l.tasksDontMultiply, style: Theme.of(context).textTheme.bodySmall),
                gap16,
                TextField(
                  controller: _field,
                  decoration: InputDecoration(labelText: l.fieldName),
                ),
                gap16,
                TextField(
                  controller: _description,
                  maxLines: 2,
                  decoration: InputDecoration(labelText: l.description),
                ),
                gap16,
                TextField(
                  controller: _notes,
                  maxLines: 2,
                  decoration: InputDecoration(labelText: l.notes),
                ),
                gap24,
                PrimaryButton(label: l.save, busy: _busy, onPressed: _save),
              ],
            ),
    );
  }
}

/// Manage the farm's list of work types (rename, hide, add).
class WorkTypesScreen extends ConsumerWidget {
  const WorkTypesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final types = ref.watch(workTypesProvider).value ?? const <WorkType>[];
    final repo = ref.read(workRepoProvider);
    Future<void> run(Future<void> Function() f) async {
      try {
        await f();
      } catch (e) {
        if (context.mounted) showErrorSnack(context, e);
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.workTypes)),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: Text(l.addWorkType),
        onPressed: () async {
          final name = await promptText(context, title: l.addWorkType, label: l.workTypeName);
          if (name != null) await run(() => repo.saveWorkType(nameKn: name, nameEn: name));
        },
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          for (final t in types)
            SwitchListTile(
              title: Text(t.nameKn),
              subtitle: Text(t.nameEn),
              value: t.active,
              onChanged: (v) => run(() => repo.saveWorkType(id: t.id, nameKn: t.nameKn, nameEn: t.nameEn, active: v)),
              secondary: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  final name = await promptText(context, title: l.edit, label: l.workTypeName);
                  if (name != null) {
                    await run(() => repo.saveWorkType(id: t.id, nameKn: name, nameEn: t.nameEn, active: t.active));
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}
