import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/money.dart';
import '../../data/db/database.dart';
import '../../data/repositories/workers_repo.dart';
import '../common/labels.dart';
import '../common/widgets.dart';

class WorkerFormScreen extends ConsumerStatefulWidget {
  const WorkerFormScreen({super.key, this.workerId, this.initialName});

  final String? workerId;
  final String? initialName;

  @override
  ConsumerState<WorkerFormScreen> createState() => _WorkerFormScreenState();
}

class _WorkerFormScreenState extends ConsumerState<WorkerFormScreen> {
  final _form = GlobalKey<FormState>();
  late final _nameKn = TextEditingController(text: widget.initialName ?? '');
  final _nameEn = TextEditingController();
  final _phone = TextEditingController();
  final _wage = TextEditingController();
  final _notes = TextEditingController();
  bool _leader = false;
  bool _busy = false;
  Worker? _existing;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.workerId != null) {
      final w = await ref.read(workersRepoProvider).getWorker(widget.workerId!);
      if (w != null) {
        _existing = w;
        _nameKn.text = w.nameKn;
        _nameEn.text = w.nameEn ?? '';
        _phone.text = w.phone ?? '';
        _wage.text = Money.toInput(w.defaultWagePaise);
        _notes.text = w.notes ?? '';
        _leader = w.isLeader;
      }
    }
    if (mounted) setState(() => _loaded = true);
  }

  Future<void> _save({String? status}) async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(workersRepoProvider)
          .saveWorker(
            WorkerDraft(
              id: _existing?.id,
              nameKn: _nameKn.text,
              nameEn: _nameEn.text,
              phone: _phone.text,
              defaultWagePaise: Money.parseRupees(_wage.text)!,
              notes: _notes.text,
              isLeader: _leader,
              status: status ?? _existing?.status ?? 'active',
            ),
          );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final isAdmin = ref.watch(isAdminProvider);
    final editing = _existing != null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? l.editWorker : l.addWorker)),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _form,
              child: ListView(
                padding: pagePadding,
                children: [
                  TextFormField(
                    controller: _nameKn,
                    autofocus: !editing,
                    style: const TextStyle(fontSize: 20),
                    decoration: InputDecoration(labelText: l.nameKannada),
                    validator: (v) => (v ?? '').trim().isEmpty ? l.errInvalidName : null,
                  ),
                  gap16,
                  AmountField(controller: _wage, label: l.dailyWageRupees, helper: editing ? l.wageChangeNote : null),
                  gap16,
                  TextFormField(
                    controller: _nameEn,
                    decoration: InputDecoration(labelText: l.nameEnglish),
                  ),
                  gap16,
                  TextFormField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(labelText: l.phoneOptional),
                    validator: (v) {
                      final t = (v ?? '').trim();
                      return t.isEmpty || RegExp(r'^[0-9+ -]{5,20}$').hasMatch(t) ? null : l.errInvalidPhone;
                    },
                  ),
                  gap8,
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l.isLeader),
                    subtitle: Text(l.isLeaderHelp),
                    value: _leader,
                    onChanged: (v) => setState(() => _leader = v),
                  ),
                  gap8,
                  TextFormField(
                    controller: _notes,
                    maxLines: 3,
                    decoration: InputDecoration(labelText: l.notes),
                  ),
                  gap24,
                  Builder(
                    builder: (context) {
                      return PrimaryButton(
                        label: l.save,
                        busy: _busy,
                        onPressed: () {
                          if (Money.parseRupees(_wage.text) == null) {
                            showSnack(context, l.errInvalidAmount, error: true);
                            return;
                          }
                          _save();
                        },
                      );
                    },
                  ),
                  if (editing && isAdmin) ...[
                    gap16,
                    OutlinedButton.icon(
                      icon: Icon(_existing!.status == 'archived' ? Icons.unarchive : Icons.archive_outlined),
                      label: Text(_existing!.status == 'archived' ? l.unarchiveWorker : l.archiveWorker),
                      onPressed: _busy
                          ? null
                          : () async {
                              final archive = _existing!.status != 'archived';
                              if (archive &&
                                  !await confirmDialog(
                                    context,
                                    message: l.archiveHelp,
                                    confirmLabel: l.archiveWorker,
                                  )) {
                                return;
                              }
                              await _save(status: archive ? 'archived' : 'active');
                            },
                    ),
                    gap8,
                    Text(l.archiveHelp, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ],
              ),
            ),
    );
  }
}
