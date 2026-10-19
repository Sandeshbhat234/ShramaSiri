import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/dates.dart';
import '../../core/money.dart';
import '../../data/db/database.dart';
import '../../data/repositories/ledger_repo.dart';
import '../../data/repositories/reports_repo.dart';
import '../common/labels.dart';
import '../common/widgets.dart';
import '../home/home_screen.dart';
import '../leader/leader_screens.dart';
import '../settlement/statement_text.dart';
import '../settlement/weekly_screen.dart';

class ReportData {
  ReportData(this.cost, this.cash, this.workTypes);

  final List<WorkerCost> cost;
  final CashSummary cash;
  final List<WorkTypeCost> workTypes;
}

final reportProvider = FutureProvider.autoDispose.family<ReportData, (String, String)>((ref, range) async {
  // Recompute when ledger/attendance change.
  ref.watch(balancesProvider);
  final repo = ref.watch(reportsRepoProvider);
  return ReportData(
    await repo.labourCost(range.$1, range.$2),
    await repo.cash(range.$1, range.$2),
    await repo.workTypeCost(range.$1, range.$2),
  );
});

enum _Period { today, week, month, custom }

/// Lightweight reports. Earned wages, cash paid, balances and leader money
/// are always separate figures.
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  _Period _period = _Period.week;
  LocalDate? _from;
  LocalDate? _to;

  (LocalDate, LocalDate) _range() {
    final today = AppClock.today();
    final weekDay = ref.watch(farmProvider).value?.weekStartDay ?? 1;
    return switch (_period) {
      _Period.today => (today, today),
      _Period.week => (today.weekStart(weekDay), today),
      _Period.month => (LocalDate(today.year, today.month, 1), today),
      _Period.custom => (_from ?? today, _to ?? today),
    };
  }

  Future<void> _custom() async {
    final r = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: AppClock.today().toDateTime(),
    );
    if (r != null) {
      setState(() {
        _period = _Period.custom;
        _from = LocalDate.fromDateTime(r.start);
        _to = LocalDate.fromDateTime(r.end);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final (from, to) = _range();
    final data = ref.watch(reportProvider((from.toIso(), to.toIso())));
    final workers = ref.watch(workerIndexProvider).value ?? const <String, Worker>{};
    final types = {for (final t in ref.watch(workTypesProvider).value ?? const <WorkType>[]) t.id: t};
    final balances = ref.watch(balancesProvider).value ?? const <String, WorkerBalance>{};
    final funds = ref.watch(leaderFundsProvider).value ?? const <LeaderFund>[];
    final due = balances.values.fold<int>(0, (s, b) => s + (b.wagePaise > 0 ? b.wagePaise : 0));
    final ahead = balances.values.fold<int>(0, (s, b) => s + (b.wagePaise < 0 ? -b.wagePaise : 0));
    final loans = balances.values.fold<int>(0, (s, b) => s + (b.loanPaise > 0 ? b.loanPaise : 0));
    final held = funds.fold<int>(0, (s, f) => s + f.unreconciledPaise);

    Widget kv(String k, int v, {bool bold = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(k, style: bold ? Theme.of(context).textTheme.titleSmall : null)),
          AmountText(
            v,
            signed: true,
            style: bold ? Theme.of(context).textTheme.titleMedium : Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l.reports),
        actions: [
          if (data.hasValue)
            PopupMenuButton<String>(
              onSelected: (v) =>
                  v == 'csv' ? _exportCsv(from, to, workers) : _shareSummary(from, to, data.value!, workers, due, held),
              itemBuilder: (_) => [
                PopupMenuItem(value: 'share', child: Text(l.shareSummary)),
                PopupMenuItem(value: 'csv', child: Text(l.exportCsv)),
              ],
            ),
        ],
      ),
      body: ListView(
        padding: pagePadding,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (p, label) in [
                (_Period.today, l.periodToday),
                (_Period.week, l.periodWeek),
                (_Period.month, l.periodMonth),
              ])
                ChoiceChip(label: Text(label), selected: _period == p, onSelected: (_) => setState(() => _period = p)),
              ChoiceChip(
                label: Text(_period == _Period.custom ? context.dates.range(from, to) : l.periodCustom),
                selected: _period == _Period.custom,
                onSelected: (_) => _custom(),
              ),
            ],
          ),
          gap8,
          Text(context.dates.range(from, to), style: Theme.of(context).textTheme.bodySmall),
          gap8,
          Banner2(text: l.reportNote),
          AsyncView(
            data,
            builder: (d) {
              final labour = d.cost.fold<int>(0, (s, c) => s + c.totalPaise);
              final units = d.cost.fold<int>(0, (s, c) => s + c.unitsMilli);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SectionHeader(l.labourCost),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: [
                          kv(l.total, labour, bold: true),
                          Row(
                            children: [
                              Expanded(child: Text(l.daysWorked)),
                              Text(Units.format(units)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SectionHeader(l.cashPaidOut),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: [
                          for (final e in d.cash.byType.entries.where((e) => e.key.effects.cashOut > 0))
                            kv(entryTypeLabel(l, e.key), e.value),
                          if (d.cash.cashInPaise != 0) ...[const Divider(), kv(l.cashReturned, d.cash.cashInPaise)],
                          const Divider(),
                          kv(l.netCash, d.cash.netOutPaise, bold: true),
                        ],
                      ),
                    ),
                  ),
                  if (d.cash.byPayer.isNotEmpty) ...[
                    SectionHeader(l.byFamilyMember),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          children: [for (final e in d.cash.byPayer.entries) kv(e.key.isEmpty ? '—' : e.key, e.value)],
                        ),
                      ),
                    ),
                  ],
                  SectionHeader(l.outstandingNow),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: [
                          kv(l.wagesToPay, due),
                          kv(l.advancesAhead, ahead),
                          kv(l.loansOutstanding, loans),
                          kv(l.leaderCashHeld, held),
                        ],
                      ),
                    ),
                  ),
                  if (held != 0)
                    TextButton(
                      onPressed: () =>
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaderFundsScreen())),
                      child: Text(l.leaderFunds),
                    ),
                  SectionHeader(l.byWorker),
                  Card(
                    child: Column(
                      children: [
                        if (d.cost.isEmpty) ListTile(title: Text(l.noEntries)),
                        for (final c in d.cost)
                          ListTile(
                            title: Text(workerName(workers[c.workerId])),
                            subtitle: Text('${l.daysWorked}: ${Units.format(c.unitsMilli)}'),
                            trailing: AmountText(c.totalPaise),
                          ),
                      ],
                    ),
                  ),
                  if (d.workTypes.isNotEmpty) ...[
                    SectionHeader(l.byWorkType),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          children: [
                            for (final w in d.workTypes)
                              kv(w.workTypeId == null ? l.noTask : workTypeName(l, types[w.workTypeId]), w.paise),
                          ],
                        ),
                      ),
                    ),
                  ],
                  gap16,
                  OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_view_week),
                    label: Text(l.settlementHistory),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WeeklyScreen())),
                  ),
                  if (held > 0) ...[gap8, Banner2(text: l.leaderPersonalNote, color: AppColors.amberSoft)],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _shareSummary(
    LocalDate from,
    LocalDate to,
    ReportData d,
    Map<String, Worker> workers,
    int due,
    int held,
  ) async {
    final k = kannada;
    final dates = DateFormats('kn');
    final b = StringBuffer()
      ..writeln(k.summaryTitle(dates.range(from, to)))
      ..writeln()
      ..writeln(k.stmtLine(k.labourCost, Money.format(d.cost.fold<int>(0, (s, c) => s + c.totalPaise))))
      ..writeln(k.stmtLine(k.netCash, Money.format(d.cash.netOutPaise)))
      ..writeln(k.stmtLine(k.wagesToPay, Money.format(due)))
      ..writeln(k.stmtLine(k.leaderCashHeld, Money.format(held)))
      ..writeln()
      ..writeln(k.byWorker);
    for (final c in d.cost) {
      b.writeln(
        '${workerName(workers[c.workerId])}: ${Units.format(c.unitsMilli)} ${k.daysUnit} — ${Money.format(c.totalPaise)}',
      );
    }
    await SharePlus.instance.share(ShareParams(text: b.toString()));
  }

  Future<void> _exportCsv(LocalDate from, LocalDate to, Map<String, Worker> workers) async {
    try {
      final csv = await ref.read(reportsRepoProvider).exportCsv(from.toIso(), to.toIso(), workers);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/shramasiri_${from.toIso()}_${to.toIso()}.csv');
      // BOM so spreadsheet apps read Kannada names correctly.
      await file.writeAsString('﻿$csv');
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path, mimeType: 'text/csv')]));
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    }
  }
}
