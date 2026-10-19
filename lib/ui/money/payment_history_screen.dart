import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/dates.dart';
import '../../data/db/database.dart';
import '../../data/repositories/ledger_repo.dart';
import '../../domain/ledger.dart';
import '../common/labels.dart';
import '../common/pickers.dart';
import '../common/widgets.dart';
import '../home/home_screen.dart';
import '../workers/worker_detail_screen.dart';

final historyProvider = StreamProvider.autoDispose.family<List<LedgerEntry>, (LedgerFilter, int)>(
  (ref, a) => ref.watch(ledgerRepoProvider).watchEntries(a.$1, limit: a.$2),
);

enum _Period { any, week, month, custom }

/// All family members' payments, newest first, with filters.
class PaymentHistoryScreen extends ConsumerStatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  ConsumerState<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends ConsumerState<PaymentHistoryScreen> {
  Worker? _worker;
  String? _payer;
  EntryType? _type;
  _Period _period = _Period.any;
  LocalDate? _from;
  LocalDate? _to;
  int _limit = 50;

  LedgerFilter get _filter {
    final today = AppClock.today();
    final weekDay = ref.read(farmProvider).value?.weekStartDay ?? 1;
    final (from, to) = switch (_period) {
      _Period.any => (null, null),
      _Period.week => (today.weekStart(weekDay), today),
      _Period.month => (LocalDate(today.year, today.month, 1), today),
      _Period.custom => (_from, _to),
    };
    return LedgerFilter(
      workerId: _worker?.id,
      paidBy: _payer,
      types: _type == null ? null : [_type!],
      from: from?.toIso(),
      to: to?.toIso(),
    );
  }

  Future<void> _chooseDates() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: AppClock.today().addDays(1).toDateTime(),
    );
    if (range != null) {
      setState(() {
        _period = _Period.custom;
        _from = LocalDate.fromDateTime(range.start);
        _to = LocalDate.fromDateTime(range.end);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final entries = ref.watch(historyProvider((_filter, _limit)));
    final workers = ref.watch(workerIndexProvider).value ?? const {};
    final reversed = ref.watch(reversedIdsProvider).value ?? const {};
    final payers = (ref.watch(membersByUserProvider).value ?? const <String, FarmMember>{}).values.toList();

    return Scaffold(
      appBar: AppBar(title: Text(l.paymentHistory)),
      body: Column(
        children: [
          SizedBox(
            height: 62,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                _FilterChip(
                  label: _worker == null ? l.filterWorker : _worker!.nameKn,
                  active: _worker != null,
                  onTap: () async {
                    if (_worker != null) return setState(() => _worker = null);
                    final w = await pickWorker(context);
                    if (w != null) setState(() => _worker = w);
                  },
                ),
                PopupMenuButton<String?>(
                  onSelected: (v) => setState(() => _payer = v),
                  itemBuilder: (_) => [
                    PopupMenuItem(value: null, child: Text(l.everyone)),
                    for (final m in payers) PopupMenuItem(value: m.userId, child: Text(m.fullName)),
                  ],
                  child: _FilterChip(
                    label: _payer == null
                        ? l.filterPayer
                        : (payers.where((m) => m.userId == _payer).firstOrNull?.fullName ?? l.filterPayer),
                    active: _payer != null,
                  ),
                ),
                PopupMenuButton<EntryType?>(
                  onSelected: (v) => setState(() => _type = v),
                  itemBuilder: (_) => [
                    PopupMenuItem(value: null, child: Text(l.allTypes)),
                    for (final t in EntryType.values) PopupMenuItem(value: t, child: Text(entryTypeLabel(l, t))),
                  ],
                  child: _FilterChip(
                    label: _type == null ? l.filterType : entryTypeLabel(l, _type!),
                    active: _type != null,
                  ),
                ),
                PopupMenuButton<_Period>(
                  onSelected: (v) => v == _Period.custom ? _chooseDates() : setState(() => _period = v),
                  itemBuilder: (_) => [
                    PopupMenuItem(value: _Period.any, child: Text(l.anyDate)),
                    PopupMenuItem(value: _Period.week, child: Text(l.thisWeek)),
                    PopupMenuItem(value: _Period.month, child: Text(l.thisMonth)),
                    PopupMenuItem(value: _Period.custom, child: Text(l.chooseDates)),
                  ],
                  child: _FilterChip(
                    label: switch (_period) {
                      _Period.any => l.anyDate,
                      _Period.week => l.thisWeek,
                      _Period.month => l.thisMonth,
                      _Period.custom => _from == null ? l.chooseDates : context.dates.range(_from!, _to!),
                    },
                    active: _period != _Period.any,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: AsyncView(
              entries,
              builder: (list) {
                if (list.isEmpty) return EmptyState(icon: Icons.receipt_long, text: l.noEntries);
                final byDate = <String, List<LedgerEntry>>{};
                for (final e in list) {
                  byDate.putIfAbsent(e.businessDate, () => []).add(e);
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: [
                    for (final g in byDate.entries) ...[
                      SectionHeader(context.dates.longDate(LocalDate.parse(g.key))),
                      Card(
                        child: Column(
                          children: [
                            for (final e in g.value)
                              LedgerTile(entry: e, workers: workers, reversed: reversed.contains(e.id)),
                          ],
                        ),
                      ),
                    ],
                    if (list.length >= _limit)
                      TextButton(onPressed: () => setState(() => _limit += 50), child: Text(l.loadMore)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.active, this.onTap});

  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final chip = Chip(
      avatar: Icon(active ? Icons.filter_alt : Icons.filter_alt_outlined, size: 18),
      label: Text(label),
      backgroundColor: active ? Theme.of(context).colorScheme.primaryContainer : null,
    );
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: onTap == null ? chip : InkWell(onTap: onTap, borderRadius: BorderRadius.circular(20), child: chip),
    );
  }
}
