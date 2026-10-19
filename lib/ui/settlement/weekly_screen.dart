import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/dates.dart';
import '../../core/money.dart';
import '../../data/db/database.dart';
import '../../data/repositories/ledger_repo.dart';
import '../../domain/ledger.dart';
import '../common/labels.dart';
import '../common/widgets.dart';
import '../money/give_money_screen.dart';
import 'statement_screen.dart';
import 'statement_text.dart';

final periodProvider = StreamProvider.autoDispose.family<List<PeriodSummary>, (LocalDate, LocalDate)>(
  (ref, p) => ref.watch(settlementRepoProvider).watchPeriod(p.$1, p.$2),
);
final settlementProvider = StreamProvider.autoDispose.family<Settlement?, LocalDate>(
  (ref, w) => ref.watch(settlementRepoProvider).watchSettlement(w),
);
final settlementItemsProvider = StreamProvider.autoDispose.family<Map<String, SettlementItem>, String>(
  (ref, id) => ref.watch(settlementRepoProvider).watchItems(id),
);
final settlementsListProvider = StreamProvider.autoDispose<List<Settlement>>(
  (ref) => ref.watch(settlementRepoProvider).watchSettlements(),
);

class WeeklyScreen extends ConsumerStatefulWidget {
  const WeeklyScreen({super.key, this.weekStart});

  final LocalDate? weekStart;

  @override
  ConsumerState<WeeklyScreen> createState() => _WeeklyScreenState();
}

class _WeeklyScreenState extends ConsumerState<WeeklyScreen> {
  LocalDate? _start;
  final _paying = <String>{};
  bool _busy = false;

  LocalDate _weekStart() {
    final day = ref.watch(farmProvider).value?.weekStartDay ?? 1;
    return _start ?? widget.weekStart ?? AppClock.today().weekStart(day);
  }

  Future<void> _payRemaining(Worker w, PeriodSummary s, LocalDate end) async {
    final l = context.l;
    if (!await confirmDialog(
      context,
      message: l.payConfirm(Money.format(s.closingPaise), w.nameKn),
      confirmLabel: l.yesRecord,
    )) {
      return;
    }
    setState(() => _paying.add(w.id));
    try {
      final today = AppClock.today();
      // A settlement paid after the week ends is attributed to that week;
      // the actual time is kept in occurred_at.
      await ref
          .read(ledgerRepoProvider)
          .create(
            EntryDraft(
              type: EntryType.wagePayment,
              workerId: w.id,
              amountPaise: s.closingPaise,
              businessDate: (today.isAfter(end) ? end : today).toIso(),
              occurredAt: AppClock.nowUtc(),
              paidBy: ref.read(sessionProvider).userId,
            ),
          );
      if (mounted) showSnack(context, l.savedOnDeviceToast);
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _paying.remove(w.id));
    }
  }

  Future<void> _run(Future<void> Function() f) async {
    setState(() => _busy = true);
    try {
      await f();
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final start = _weekStart();
    final end = start.addDays(6);
    final summaries = ref.watch(periodProvider((start, end)));
    final settlement = ref.watch(settlementProvider(start)).value;
    final items = settlement == null
        ? const <String, SettlementItem>{}
        : ref.watch(settlementItemsProvider(settlement.id)).value ?? const {};
    final workers = ref.watch(workerIndexProvider).value ?? const {};
    final isAdmin = ref.watch(isAdminProvider);
    final farm = ref.watch(farmProvider).value;
    final closed = settlement?.status == 'closed';
    final started = !start.isAfter(AppClock.today());

    return Scaffold(
      appBar: AppBar(
        title: Text(l.weeklySettlement),
        actions: [
          IconButton(
            tooltip: l.pastWeeks,
            icon: const Icon(Icons.history),
            onPressed: () async {
              final picked = await Navigator.push<LocalDate>(
                context,
                MaterialPageRoute(builder: (_) => const PastWeeksScreen()),
              );
              if (picked != null) setState(() => _start = picked);
            },
          ),
        ],
      ),
      body: AsyncView(
        summaries,
        builder: (list) {
          final rows = list.map((s) => (workers[s.workerId], s)).where((r) => r.$1 != null).toList()
            ..sort((a, b) => a.$1!.nameKn.compareTo(b.$1!.nameKn));
          final earned = list.fold<int>(0, (s, x) => s + x.earnedPaise);
          final due = list.fold<int>(0, (s, x) => s + (x.closingPaise > 0 ? x.closingPaise : 0));
          return ListView(
            padding: pagePadding,
            children: [
              Card(
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, size: 30),
                      onPressed: () => setState(() => _start = start.addDays(-7)),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(context.dates.range(start, end), style: Theme.of(context).textTheme.titleMedium),
                          Text(
                            closed ? l.weekClosed : l.weekOpen,
                            style: TextStyle(color: closed ? AppColors.green : AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, size: 30),
                      onPressed: end.isBefore(AppClock.today())
                          ? () => setState(() => _start = start.addDays(7))
                          : null,
                    ),
                  ],
                ),
              ),
              if (settlement?.needsReview == true) ...[
                gap12,
                Banner2(text: l.needsReview, icon: Icons.warning_amber, color: AppColors.amberSoft),
              ],
              if (closed && settlement!.closedByName != null) ...[
                gap8,
                Text(l.closedBy(settlement.closedByName!), style: Theme.of(context).textTheme.bodySmall),
              ],
              gap12,
              TileRow(
                children: [
                  StatTile(
                    label: l.weekTotalEarned,
                    value: AmountText(earned, style: Theme.of(context).textTheme.titleLarge),
                  ),
                  StatTile(
                    label: l.weekTotalDue,
                    value: AmountText(due, style: Theme.of(context).textTheme.titleLarge),
                  ),
                ],
              ),
              if (rows.isEmpty) EmptyState(icon: Icons.event_available, text: l.noActivityWeek),
              for (final (w, s) in rows)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: _WorkerWeekCard(
                    worker: w!,
                    summary: s,
                    snapshot: settlement?.needsReview == true ? items[w.id] : null,
                    paying: _paying.contains(w.id),
                    onPay: () => _payRemaining(w, s, end),
                    onPart: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GiveMoneyScreen(workerId: w.id, type: EntryType.wagePayment),
                      ),
                    ),
                    onStatement: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StatementScreen(workerId: w.id, weekStart: start),
                      ),
                    ),
                  ),
                ),
              gap24,
              if (started && !closed) ...[
                Text(l.closeWeekHelp, style: Theme.of(context).textTheme.bodySmall),
                gap8,
                PrimaryButton(
                  label: l.closeWeek,
                  icon: Icons.lock_outline,
                  busy: _busy,
                  onPressed: () => _run(() => ref.read(settlementRepoProvider).closeWeek(start)),
                ),
              ],
              if (closed && settlement!.needsReview)
                PrimaryButton(
                  label: l.markReviewed,
                  icon: Icons.fact_check,
                  busy: _busy,
                  onPressed: () => _run(() => ref.read(settlementRepoProvider).closeWeek(start)),
                ),
              if (closed && isAdmin) ...[
                gap12,
                OutlinedButton(
                  onPressed: _busy ? null : () => _run(() => ref.read(settlementRepoProvider).reopenWeek(settlement!)),
                  child: Text(l.reopenWeek),
                ),
              ],
              if (rows.isNotEmpty) ...[
                gap12,
                OutlinedButton.icon(
                  icon: const Icon(Icons.share),
                  label: Text(l.share),
                  onPressed: () => SharePlus.instance.share(
                    ShareParams(
                      text: buildWeekSummary(
                        l: kannada,
                        farmName: farm?.name ?? '',
                        start: start,
                        end: end,
                        rows: [for (final (w, s) in rows) (w!.nameKn, s)],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _WorkerWeekCard extends StatelessWidget {
  const _WorkerWeekCard({
    required this.worker,
    required this.summary,
    required this.snapshot,
    required this.paying,
    required this.onPay,
    required this.onPart,
    required this.onStatement,
  });

  final Worker worker;
  final PeriodSummary summary;
  final SettlementItem? snapshot;
  final bool paying;
  final VoidCallback onPay;
  final VoidCallback onPart;
  final VoidCallback onStatement;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final s = summary;
    Widget line(String label, int paise, {bool minus = false}) => paise == 0
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 1),
            child: Row(
              children: [
                Expanded(child: Text(label)),
                Text(minus ? '-${Money.format(paise)}' : Money.format(paise), style: const TextStyle(fontSize: 16)),
              ],
            ),
          );
    final changed = snapshot != null && snapshot!.closingPaise != s.closingPaise;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(worker.nameKn, style: Theme.of(context).textTheme.titleMedium),
            Text('${l.daysWorked}: ${Units.format(s.unitsMilli)}', style: Theme.of(context).textTheme.bodyMedium),
            gap8,
            line(l.openingBalance, s.openingPaise),
            line(l.earned, s.grossPaise),
            line(l.additions, s.additionsPaise),
            line(l.advanceGiven, s.advancesPaise, minus: true),
            line(l.paidDirect, s.directPaidPaise, minus: true),
            line(l.paidViaLeader, s.leaderPaidPaise, minus: true),
            const Divider(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    s.closingPaise >= 0 ? l.remaining : l.overpaid,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                AmountText(
                  s.closingPaise.abs(),
                  style: Theme.of(context).textTheme.titleLarge!
                      .copyWith(color: s.closingPaise < 0 ? AppColors.amber : null),
                ),
              ],
            ),
            if (changed)
              Text(l.atClosing(Money.format(snapshot!.closingPaise)), style: const TextStyle(color: AppColors.amber)),
            gap8,
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (s.closingPaise > 0)
                  FilledButton.icon(
                    style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
                    onPressed: paying ? null : onPay,
                    icon: const Icon(Icons.payments),
                    label: Text(l.payAmount(Money.format(s.closingPaise))),
                  ),
                OutlinedButton(onPressed: onPart, child: Text(l.payPart)),
                TextButton.icon(onPressed: onStatement, icon: const Icon(Icons.receipt_long), label: Text(l.statement)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PastWeeksScreen extends ConsumerWidget {
  const PastWeeksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final list = ref.watch(settlementsListProvider);
    final weekDay = ref.watch(farmProvider).value?.weekStartDay ?? 1;
    final current = AppClock.today().weekStart(weekDay);
    return Scaffold(
      appBar: AppBar(title: Text(l.pastWeeks)),
      body: AsyncView(
        list,
        builder: (settlements) {
          final byStart = {for (final s in settlements) s.weekStart: s};
          return ListView(
            children: [
              for (var i = 0; i < 26; i++)
                Builder(
                  builder: (context) {
                    final start = current.addDays(-7 * i);
                    final s = byStart[start.toIso()];
                    return ListTile(
                      title: Text(context.dates.range(start, start.addDays(6))),
                      subtitle: Text(
                        s == null
                            ? l.weekOpen
                            : [
                                s.status == 'closed' ? l.weekClosed : l.weekOpen,
                                if (s.needsReview) l.needsReview,
                                if (s.closedByName != null) l.closedBy(s.closedByName!),
                              ].join(' · '),
                      ),
                      leading: Icon(
                        s?.status == 'closed' ? Icons.lock : Icons.lock_open,
                        color: s?.needsReview == true ? AppColors.amber : AppColors.green,
                      ),
                      onTap: () => Navigator.pop(context, start),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}
