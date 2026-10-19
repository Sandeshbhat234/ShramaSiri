import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/dates.dart';
import '../../core/money.dart';
import '../../data/db/database.dart';
import '../../data/repositories/attendance_repo.dart';
import '../common/labels.dart';
import '../common/pickers.dart';
import '../common/widgets.dart';
import '../shell.dart';
import '../workers/worker_list_screen.dart';
import 'attendance_history_screen.dart';

final dayAttendanceProvider = StreamProvider.autoDispose.family<List<AttendanceRow>, String>(
  (ref, date) => ref.watch(attendanceRepoProvider).watchDay(date),
);

final settlementForDateProvider = StreamProvider.autoDispose.family<Settlement?, String>((ref, date) {
  final weekDay = ref.watch(farmProvider).value?.weekStartDay ?? 1;
  return ref.watch(settlementRepoProvider).watchSettlement(LocalDate.parse(date).weekStart(weekDay));
});

class _Mark {
  const _Mark(this.units, this.rate);

  final int units;
  final int rate;

  @override
  bool operator ==(Object other) => other is _Mark && other.units == units && other.rate == rate;

  @override
  int get hashCode => Object.hash(units, rate);
}

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key, this.initialDate, this.standalone = false});

  final LocalDate? initialDate;

  /// Opened from history (has a back button) rather than as the tab.
  final bool standalone;

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  late LocalDate _date = widget.initialDate ?? AppClock.today();
  String? _groupId;
  String _search = '';
  Map<String, _Mark> _saved = {};
  Map<String, _Mark> _draft = {};
  bool _dirty = false;
  bool _busy = false;
  bool _initializing = true;
  ProviderSubscription<AsyncValue<List<AttendanceRow>>>? _sub;

  @override
  void initState() {
    super.initState();
    _listen();
    _initializing = false;
  }

  @override
  void dispose() {
    _sub?.close();
    super.dispose();
  }

  /// Follows the saved rows for the selected date (they change after saving
  /// and when other phones' changes arrive) without losing unsaved edits.
  void _listen() {
    _sub?.close();
    _sub = ref.listenManual(dayAttendanceProvider(_date.toIso()), (_, next) {
      final rows = next.value;
      if (rows == null) return;
      if (_initializing || !mounted) {
        _syncFromSaved(rows);
      } else {
        setState(() => _syncFromSaved(rows));
      }
    }, fireImmediately: true);
  }

  void _syncFromSaved(List<AttendanceRow> rows) {
    final saved = {for (final a in rows) a.workerId: _Mark(a.unitsMilli, a.ratePaise)};
    _saved = saved;
    if (!_dirty) _draft = {...saved};
  }

  void _set(Worker w, int units, {int? rate}) {
    setState(() {
      final current = _draft[w.id] ?? _saved[w.id];
      _draft[w.id] = _Mark(units, rate ?? current?.rate ?? w.defaultWagePaise);
      _dirty = _draft.entries.any((e) => _saved[e.key] != e.value && !(e.value.units == 0 && _saved[e.key] == null));
    });
  }

  Future<bool> _confirmDiscard() async {
    if (!_dirty) return true;
    return confirmDialog(context, message: context.l.unsavedChanges, confirmLabel: context.l.leave);
  }

  Future<void> _changeDate(LocalDate d) async {
    if (!await _confirmDiscard()) return;
    setState(() {
      _date = d;
      _dirty = false;
      _draft = {};
      _saved = {};
    });
    _listen();
  }

  Future<void> _save() async {
    final l = context.l;
    setState(() => _busy = true);
    try {
      final marks = [
        for (final e in _draft.entries)
          AttendanceMark(workerId: e.key, unitsMilli: e.value.units, ratePaise: e.value.rate),
      ];
      final changed = await ref.read(attendanceRepoProvider).saveDay(_date.toIso(), marks);
      setState(() => _dirty = false);
      if (mounted) showSnack(context, changed == 0 ? l.noChanges : l.attendanceSaved(changed));
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _custom(Worker w) async {
    final l = context.l;
    final current = _draft[w.id] ?? _saved[w.id];
    final units = TextEditingController(text: current == null || current.units == 0 ? '' : Units.format(current.units));
    final rate = TextEditingController(text: Money.toInput(current?.rate ?? w.defaultWagePaise));
    final result = await showDialog<_Mark>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(w.nameKn),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: units,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
              decoration: InputDecoration(labelText: l.customUnits),
            ),
            gap12,
            AmountField(controller: rate, label: l.rateForDay),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(88, 48)),
            onPressed: () {
              final u = Units.parse(units.text);
              final r = Money.parseRupees(rate.text);
              if (u == null || r == null) {
                showSnack(ctx, u == null ? l.errInvalidUnits : l.errInvalidAmount, error: true);
                return;
              }
              Navigator.pop(ctx, _Mark(u, r));
            },
            child: Text(l.ok),
          ),
        ],
      ),
    );
    if (result != null) _set(w, result.units, rate: result.rate);
  }

  Future<void> _addWorker() async {
    final l = context.l;
    final name = TextEditingController(text: _search);
    final wage = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.addNewWorker),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              autofocus: true,
              decoration: InputDecoration(labelText: l.nameKannada),
            ),
            gap12,
            AmountField(controller: wage, label: l.dailyWageRupees),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(88, 48)),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.save),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final paise = Money.parseRupees(wage.text);
    if (name.text.trim().isEmpty || paise == null) {
      if (mounted) showSnack(context, name.text.trim().isEmpty ? l.errInvalidName : l.errInvalidAmount, error: true);
      return;
    }
    try {
      final id = await ref.read(workersRepoProvider).quickAdd(name.text, paise);
      setState(() {
        _draft[id] = _Mark(Units.fullDay, paise);
        _dirty = true;
      });
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final dateIso = _date.toIso();
    final settlement = ref.watch(settlementForDateProvider(dateIso)).value;
    final activeAsync = ref.watch(workerListProvider((false, '')));
    final active = activeAsync.value ?? const <Worker>[];
    final index = ref.watch(workerIndexProvider).value ?? const {};
    final groups = ref.watch(groupsProvider).value ?? const <WorkerGroup>[];
    final members = ref.watch(groupMembersProvider).value ?? const {};

    // Active workers plus anyone (e.g. archived) already marked for this day.
    final ids = {...active.map((w) => w.id), ..._draft.keys};
    var list = ids.map((id) => index[id]).whereType<Worker>().toList()..sort((a, b) => a.nameKn.compareTo(b.nameKn));
    final groupIds = _groupId == null ? null : members[_groupId] ?? const <String>{};
    if (groupIds != null) list = list.where((w) => groupIds.contains(w.id)).toList();
    if (_search.trim().isNotEmpty) {
      final s = _search.trim().toLowerCase();
      list = list
          .where((w) => w.nameKn.contains(_search.trim()) || (w.nameEn ?? '').toLowerCase().contains(s))
          .toList();
    }

    final present = _draft.values.where((m) => m.units > 0).toList();
    final total = present.fold<int>(0, (s, m) => s + Units.earned(m.rate, m.units));
    final groupName = groups.where((g) => g.id == _groupId).firstOrNull?.name;

    return PopScope(
      canPop: !_dirty || !widget.standalone,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && await _confirmDiscard() && context.mounted) Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.navAttendance),
          automaticallyImplyLeading: widget.standalone,
          actions: [
            IconButton(
              tooltip: l.attendanceHistory,
              icon: const Icon(Icons.history),
              onPressed: () =>
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceHistoryScreen())),
            ),
            ...appBarActions(context),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                children: [
                  DateSelector(date: _date, onChanged: _changeDate),
                  if (settlement?.status == 'closed') ...[
                    gap8,
                    Banner2(text: l.weekClosedNote, icon: Icons.lock_outline, color: AppColors.amberSoft),
                  ],
                ],
              ),
            ),
            if (groups.isNotEmpty)
              SizedBox(
                height: 60,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(l.filterAll),
                        selected: _groupId == null,
                        onSelected: (_) => setState(() => _groupId = null),
                      ),
                    ),
                    for (final g in groups)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(g.name),
                          selected: _groupId == g.id,
                          onSelected: (_) => setState(() => _groupId = g.id),
                        ),
                      ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: Column(
                children: [
                  if (ids.length > 6) ...[
                    TextField(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: l.search,
                        isDense: true,
                      ),
                      onChanged: (v) => setState(() => _search = v),
                    ),
                    gap8,
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.done_all),
                      onPressed: list.isEmpty
                          ? null
                          : () {
                              for (final w in list) {
                                _set(w, Units.fullDay);
                              }
                            },
                      label: Text(groupName == null ? l.markAllFull : l.markGroup(groupName)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: !activeAsync.hasValue
                  ? const Center(child: CircularProgressIndicator())
                  : active.isEmpty && _draft.isEmpty
                  ? EmptyState(
                      icon: Icons.person_add_alt,
                      text: l.noActiveWorkers,
                      action: FilledButton.icon(
                        onPressed: _addWorker,
                        icon: const Icon(Icons.add),
                        label: Text(l.addNewWorker),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: list.length + 1,
                      itemBuilder: (context, i) {
                        if (i == list.length) {
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: OutlinedButton.icon(
                              onPressed: _addWorker,
                              icon: const Icon(Icons.person_add),
                              label: Text(l.addNewWorker),
                            ),
                          );
                        }
                        final w = list[i];
                        return _WorkerRow(
                          worker: w,
                          mark: _draft[w.id],
                          changed: _draft[w.id] != _saved[w.id],
                          onSet: (u) => _set(w, u),
                          onCustom: () => _custom(w),
                        );
                      },
                    ),
            ),
            Material(
              elevation: 8,
              color: AppColors.surface,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(l.presentCount(present.length), style: Theme.of(context).textTheme.titleSmall),
                          ),
                          Text('${l.total}: ', style: Theme.of(context).textTheme.titleSmall),
                          AmountText(total),
                        ],
                      ),
                      gap8,
                      PrimaryButton(
                        label: l.saveAttendance,
                        busy: _busy,
                        onPressed: _dirty ? _save : null,
                        icon: Icons.save,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkerRow extends StatelessWidget {
  const _WorkerRow({
    required this.worker,
    required this.mark,
    required this.changed,
    required this.onSet,
    required this.onCustom,
  });

  final Worker worker;
  final _Mark? mark;
  final bool changed;
  final ValueChanged<int> onSet;
  final VoidCallback onCustom;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final units = mark?.units ?? 0;
    final isCustom = units != 0 && units != Units.fullDay && units != Units.halfDay;
    final rate = mark?.rate ?? worker.defaultWagePaise;
    final selected = units == Units.fullDay
        ? 'full'
        : units == Units.halfDay
        ? 'half'
        : isCustom
        ? 'custom'
        : (mark == null ? null : 'absent');
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: units > 0 ? AppColors.greenSoft.withValues(alpha: 0.55) : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: changed ? AppColors.green : AppColors.border, width: changed ? 1.6 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(worker.nameKn, style: Theme.of(context).textTheme.titleSmall),
                    Text(l.atRate(Money.format(rate)), style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              if (units > 0) AmountText(Units.earned(rate, units)),
            ],
          ),
          gap8,
          Row(
            children: [
              _UnitButton(label: l.fullDayShort, selected: selected == 'full', onTap: () => onSet(Units.fullDay)),
              _UnitButton(label: l.halfDayShort, selected: selected == 'half', onTap: () => onSet(Units.halfDay)),
              _UnitButton(label: l.absent, selected: selected == 'absent', onTap: () => onSet(0), muted: true),
              _UnitButton(
                label: isCustom ? Units.format(units) : l.customUnitsShort,
                selected: selected == 'custom',
                onTap: onCustom,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One of the four big attendance choices. Labels shrink rather than
/// truncate on narrow phones or with large system fonts.
class _UnitButton extends StatelessWidget {
  const _UnitButton({required this.label, required this.selected, required this.onTap, this.muted = false});

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? (muted ? AppColors.border : AppColors.green) : AppColors.surface;
    final fg = selected && !muted ? Colors.white : AppColors.text;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Semantics(
          selected: selected,
          button: true,
          child: Material(
            color: bg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: selected ? bg : AppColors.border),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onTap,
              child: SizedBox(
                height: 52,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        label,
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: fg),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
