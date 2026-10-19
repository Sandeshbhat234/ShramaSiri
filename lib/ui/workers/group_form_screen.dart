import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/db/database.dart';
import '../../data/repositories/workers_repo.dart';
import '../common/labels.dart';
import '../common/pickers.dart';
import '../common/widgets.dart';

class GroupFormScreen extends ConsumerStatefulWidget {
  const GroupFormScreen({super.key, this.groupId});

  final String? groupId;

  @override
  ConsumerState<GroupFormScreen> createState() => _GroupFormScreenState();
}

class _GroupFormScreenState extends ConsumerState<GroupFormScreen> {
  final _name = TextEditingController();
  String? _leaderId;
  Set<String> _members = {};
  WorkerGroup? _existing;
  bool _loaded = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(workersRepoProvider);
    if (widget.groupId != null) {
      final g = await repo.watchGroup(widget.groupId!).first;
      final members = await repo.watchGroupMembers().first;
      if (g != null) {
        _existing = g;
        _name.text = g.name;
        _leaderId = g.leaderWorkerId;
        _members = {...?members[g.id]};
      }
    }
    if (mounted) setState(() => _loaded = true);
  }

  Future<void> _save({String? status}) async {
    setState(() => _busy = true);
    try {
      await ref
          .read(workersRepoProvider)
          .saveGroup(
            GroupDraft(
              id: _existing?.id,
              name: _name.text,
              leaderWorkerId: _leaderId,
              memberIds: _members,
              status: status ?? _existing?.status ?? 'active',
            ),
          );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final workers = ref.watch(workerIndexProvider).value ?? const {};
    final memberList = _members.map((id) => workers[id]).whereType<Worker>().toList()
      ..sort((a, b) => a.nameKn.compareTo(b.nameKn));
    return Scaffold(
      appBar: AppBar(title: Text(_existing == null ? l.addGroup : l.editGroup)),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: pagePadding,
              children: [
                TextField(
                  controller: _name,
                  decoration: InputDecoration(labelText: l.groupName),
                ),
                gap16,
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.star_outline),
                    title: Text(l.leader),
                    subtitle: Text(_leaderId == null ? l.noLeader : workerName(workers[_leaderId])),
                    trailing: _leaderId == null
                        ? const Icon(Icons.chevron_right)
                        : IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _leaderId = null)),
                    onTap: () async {
                      final w = await pickWorker(context, leadersOnly: true);
                      if (w != null) setState(() => _leaderId = w.id);
                    },
                  ),
                ),
                SectionHeader(
                  '${l.members} (${memberList.length})',
                  trailing: TextButton.icon(
                    icon: const Icon(Icons.edit),
                    label: Text(l.selectWorkers),
                    onPressed: () async {
                      final ids = await pickWorkers(context, selected: _members);
                      if (ids != null) setState(() => _members = ids);
                    },
                  ),
                ),
                Card(
                  child: Column(
                    children: [
                      if (memberList.isEmpty) ListTile(title: Text(l.selectWorkers)),
                      for (final w in memberList)
                        ListTile(
                          title: Text(w.nameKn),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () => setState(() => _members.remove(w.id)),
                          ),
                        ),
                    ],
                  ),
                ),
                gap24,
                PrimaryButton(label: l.save, busy: _busy, onPressed: _save),
                if (_existing != null) ...[
                  gap12,
                  OutlinedButton(
                    onPressed: _busy
                        ? null
                        : () => _save(status: _existing!.status == 'archived' ? 'active' : 'archived'),
                    child: Text(_existing!.status == 'archived' ? l.unarchiveWorker : l.archiveWorker),
                  ),
                ],
              ],
            ),
    );
  }
}
