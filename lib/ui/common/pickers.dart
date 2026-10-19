import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/dates.dart';
import '../../core/money.dart';
import '../../data/db/database.dart';
import 'labels.dart';
import 'widgets.dart';

/// Searchable list of active workers in a bottom sheet.
Future<Worker?> pickWorker(BuildContext context, {bool leadersOnly = false, String? title}) {
  return showModalBottomSheet<Worker>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => _WorkerPickerSheet(leadersOnly: leadersOnly, title: title),
  );
}

/// Multi-select of workers; returns the chosen ids or null if cancelled.
Future<Set<String>?> pickWorkers(BuildContext context, {required Set<String> selected, String? title}) {
  return showModalBottomSheet<Set<String>>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => _WorkerPickerSheet(multi: true, initial: selected, title: title),
  );
}

class _WorkerPickerSheet extends ConsumerStatefulWidget {
  const _WorkerPickerSheet({this.leadersOnly = false, this.multi = false, this.initial = const {}, this.title});

  final bool leadersOnly;
  final bool multi;
  final Set<String> initial;
  final String? title;

  @override
  ConsumerState<_WorkerPickerSheet> createState() => _WorkerPickerSheetState();
}

class _WorkerPickerSheetState extends ConsumerState<_WorkerPickerSheet> {
  String _search = '';
  late final Set<String> _selected = {...widget.initial};

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final repo = ref.watch(workersRepoProvider);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (context, scroll) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.title ?? (widget.leadersOnly ? l.selectLeader : l.selectWorker),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                gap12,
                TextField(
                  autofocus: false,
                  decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: l.search),
                  onChanged: (v) => setState(() => _search = v),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Worker>>(
              stream: widget.leadersOnly ? repo.watchLeaders() : repo.watchWorkers(search: _search),
              builder: (context, snap) {
                var list = snap.data ?? const <Worker>[];
                if (widget.leadersOnly && _search.isNotEmpty) {
                  list = list
                      .where(
                        (w) =>
                            w.nameKn.contains(_search) ||
                            (w.nameEn ?? '').toLowerCase().contains(_search.toLowerCase()),
                      )
                      .toList();
                }
                if (snap.hasData && list.isEmpty) {
                  return EmptyState(icon: Icons.person_search, text: widget.leadersOnly ? l.noLeaders : l.noMatches);
                }
                return ListView.separated(
                  controller: scroll,
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final w = list[i];
                    final subtitle = [
                      if (w.nameEn != null) w.nameEn!,
                      l.atRate(Money.format(w.defaultWagePaise)),
                    ].join(' · ');
                    if (widget.multi) {
                      return CheckboxListTile(
                        value: _selected.contains(w.id),
                        title: Text(w.nameKn),
                        subtitle: Text(subtitle),
                        onChanged: (v) => setState(() => v == true ? _selected.add(w.id) : _selected.remove(w.id)),
                      );
                    }
                    return ListTile(
                      title: Text(w.nameKn),
                      subtitle: Text(subtitle),
                      trailing: w.isLeader ? Chip(label: Text(l.groupLeaderBadge)) : null,
                      onTap: () => Navigator.pop(context, w),
                    );
                  },
                );
              },
            ),
          ),
          if (widget.multi)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: PrimaryButton(
                  label: '${l.done} (${_selected.length})',
                  onPressed: () => Navigator.pop(context, _selected),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

Future<LocalDate?> pickDate(BuildContext context, LocalDate initial, {LocalDate? last}) async {
  final today = AppClock.today();
  final picked = await showDatePicker(
    context: context,
    initialDate: initial.toDateTime(),
    firstDate: DateTime(2020),
    lastDate: (last ?? today.addDays(1)).toDateTime(),
  );
  return picked == null ? null : LocalDate.fromDateTime(picked);
}

/// Tappable date line with "Today"/"Yesterday" quick labels.
class DateSelector extends StatelessWidget {
  const DateSelector({super.key, required this.date, required this.onChanged, this.last});

  final LocalDate date;
  final ValueChanged<LocalDate> onChanged;
  final LocalDate? last;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final today = AppClock.today();
    final label = date == today
        ? '${l.today} · ${context.dates.date(date)}'
        : date == today.addDays(-1)
        ? '${l.yesterday} · ${context.dates.date(date)}'
        : context.dates.longDate(date);
    final canGoForward = date.isBefore(last ?? today);
    return Card(
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.chevron_left, size: 30), onPressed: () => onChanged(date.addDays(-1))),
          Expanded(
            child: InkWell(
              onTap: () async {
                final d = await pickDate(context, date, last: last);
                if (d != null) onChanged(d);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today, size: 20, color: AppColors.green),
                    gap8,
                    Flexible(
                      child: Text(label, style: Theme.of(context).textTheme.titleSmall, textAlign: TextAlign.center),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 30),
            onPressed: canGoForward ? () => onChanged(date.addDays(1)) : null,
          ),
        ],
      ),
    );
  }
}

/// Dropdown of family members who can be "paid by", defaulting to me.
class PayerField extends ConsumerWidget {
  const PayerField({super.key, required this.value, required this.onChanged, this.label});

  final String? value;
  final ValueChanged<String> onChanged;
  final String? label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    return StreamBuilder<List<FarmMember>>(
      stream: ref.watch(membersRepoProvider).watchPayers(),
      builder: (context, snap) {
        final members = snap.data ?? const <FarmMember>[];
        final ids = members.map((m) => m.userId!).toList();
        return DropdownButtonFormField<String>(
          initialValue: ids.contains(value) ? value : null,
          isExpanded: true,
          decoration: InputDecoration(labelText: label ?? l.paidBy, prefixIcon: const Icon(Icons.person_outline)),
          items: [
            for (final m in members)
              DropdownMenuItem(
                value: m.userId,
                child: Text(m.fullName, overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        );
      },
    );
  }
}
