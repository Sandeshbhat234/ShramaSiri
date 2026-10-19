import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/dates.dart';
import '../../core/money.dart';
import '../../data/db/database.dart';
import '../../data/repositories/ledger_repo.dart';
import '../../domain/ledger.dart';
import '../common/labels.dart';
import '../common/pickers.dart';
import '../common/widgets.dart';
import '../home/home_screen.dart';
import '../money/give_money_screen.dart';
import '../workers/worker_detail_screen.dart';
import '../workers/worker_list_screen.dart';

final leaderEntriesProvider = StreamProvider.autoDispose.family<List<LedgerEntry>, String>(
  (ref, id) => ref.watch(ledgerRepoProvider).watchLeaderEntries(id),
);
final leadersProvider = StreamProvider.autoDispose<List<Worker>>(
  (ref) => ref.watch(workersRepoProvider).watchLeaders(),
);

/// Every leader with money entrusted for distribution.
class LeaderFundsScreen extends ConsumerWidget {
  const LeaderFundsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final leaders = ref.watch(leadersProvider).value ?? const <Worker>[];
    final funds = {for (final f in ref.watch(leaderFundsProvider).value ?? const <LeaderFund>[]) f.leaderId: f};
    final workers = ref.watch(workerIndexProvider).value ?? const {};
    final ids = {...leaders.map((w) => w.id), ...funds.keys};
    return Scaffold(
      appBar: AppBar(title: Text(l.leaderFunds)),
      body: ids.isEmpty
          ? EmptyState(icon: Icons.groups_outlined, text: l.noLeaders)
          : ListView(
              padding: pagePadding,
              children: [
                Banner2(text: l.leaderPersonalNote),
                gap12,
                for (final id in ids)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => LeaderLedgerScreen(leaderId: id)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: _FundSummary(
                            name: workerName(workers[id]),
                            fund: funds[id] ?? LeaderFund(leaderId: id),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _FundSummary extends StatelessWidget {
  const _FundSummary({required this.name, required this.fund});

  final String name;
  final LeaderFund fund;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    Widget line(String label, int paise, {bool bold = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: bold ? Theme.of(context).textTheme.titleSmall : null)),
          AmountText(
            paise,
            style: bold ? Theme.of(context).textTheme.titleMedium : Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(name, style: Theme.of(context).textTheme.titleMedium),
        gap8,
        line(l.entrusted, fund.entrustedPaise),
        line(l.distributed, fund.distributedPaise),
        line(l.returned, fund.returnedPaise),
        const Divider(),
        line(l.unreconciled, fund.unreconciledPaise, bold: true),
        if (fund.pendingDistributedPaise != 0)
          Text(
            l.pendingVerificationAmount(Money.format(fund.pendingDistributedPaise)),
            style: const TextStyle(color: AppColors.amber),
          ),
        if (fund.ownPocketOwedPaise != 0) ...[gap8, line(l.ownPocketOwed, fund.ownPocketOwedPaise)],
      ],
    );
  }
}

class LeaderLedgerScreen extends ConsumerWidget {
  const LeaderLedgerScreen({super.key, required this.leaderId});

  final String leaderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final workers = ref.watch(workerIndexProvider).value ?? const {};
    final fund =
        (ref.watch(leaderFundsProvider).value ?? const <LeaderFund>[])
            .where((f) => f.leaderId == leaderId)
            .firstOrNull ??
        LeaderFund(leaderId: leaderId);
    final entries = ref.watch(leaderEntriesProvider(leaderId)).value ?? const [];
    final reversed = ref.watch(reversedIdsProvider).value ?? const {};
    void push(Widget w) => Navigator.push(context, MaterialPageRoute(builder: (_) => w));

    return Scaffold(
      appBar: AppBar(title: Text(workerName(workers[leaderId]))),
      body: ListView(
        padding: pagePadding,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: _FundSummary(name: l.leaderFunds, fund: fund),
            ),
          ),
          gap12,
          Banner2(text: l.helpLeaderTransfer, color: AppColors.amberSoft, icon: Icons.groups),
          gap16,
          PrimaryButton(
            label: l.recordDistribution,
            icon: Icons.call_split,
            onPressed: fund.unreconciledPaise > 0 ? () => push(DistributeScreen(leaderId: leaderId)) : null,
          ),
          gap12,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.payments),
                label: Text(l.giveToLeader),
                onPressed: () => push(GiveMoneyScreen(workerId: leaderId, type: EntryType.leaderTransfer)),
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.undo),
                label: Text(l.recordReturn),
                onPressed: fund.unreconciledPaise > 0 ? () => _recordReturn(context, ref, fund) : null,
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.account_balance_wallet_outlined),
                label: Text(l.recordOwnPocket),
                onPressed: () => push(DistributeScreen(leaderId: leaderId, ownMoney: true)),
              ),
              if (fund.ownPocketOwedPaise > 0)
                OutlinedButton.icon(
                  icon: const Icon(Icons.reply),
                  label: Text(l.repayLeader),
                  onPressed: () => _repay(context, ref, fund, entries),
                ),
            ],
          ),
          SectionHeader(l.history),
          if (entries.isEmpty) Card(child: ListTile(title: Text(l.noEntries))),
          if (entries.isNotEmpty)
            Card(
              child: Column(
                children: [
                  for (final e in entries) LedgerTile(entry: e, workers: workers, reversed: reversed.contains(e.id)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _recordReturn(BuildContext context, WidgetRef ref, LeaderFund fund) async {
    final l = context.l;
    final amount = await _askAmount(context, l.recordReturn, max: fund.unreconciledPaise);
    if (amount == null) return;
    try {
      await ref
          .read(ledgerRepoProvider)
          .create(
            EntryDraft(
              type: EntryType.leaderReturn,
              workerId: leaderId,
              amountPaise: amount,
              businessDate: AppClock.today().toIso(),
              paidBy: ref.read(sessionProvider).userId,
            ),
          );
      if (context.mounted) showSnack(context, l.savedOnDeviceToast);
    } catch (e) {
      if (context.mounted) showErrorSnack(context, e);
    }
  }

  Future<void> _repay(BuildContext context, WidgetRef ref, LeaderFund fund, List<LedgerEntry> entries) async {
    final l = context.l;
    final selfFunded = entries
        .where((e) => e.entryType == EntryType.leaderSelfFunded.code && !e.isReversal)
        .firstOrNull;
    if (selfFunded == null) return;
    final amount = await _askAmount(
      context,
      l.repayLeader,
      max: fund.ownPocketOwedPaise,
      initial: fund.ownPocketOwedPaise,
    );
    if (amount == null) return;
    try {
      await ref
          .read(ledgerRepoProvider)
          .create(
            EntryDraft(
              type: EntryType.reimbursement,
              workerId: leaderId,
              amountPaise: amount,
              businessDate: AppClock.today().toIso(),
              paidBy: ref.read(sessionProvider).userId,
              relatedEntryId: selfFunded.id,
            ),
          );
      if (context.mounted) showSnack(context, l.savedOnDeviceToast);
    } catch (e) {
      if (context.mounted) showErrorSnack(context, e);
    }
  }
}

Future<int?> _askAmount(BuildContext context, String title, {required int max, int? initial}) async {
  final l = context.l;
  final controller = TextEditingController(text: initial == null ? '' : Money.toInput(initial));
  return showDialog<int>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: AmountField(controller: controller, autofocus: true, helper: '≤ ${Money.format(max)}'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.cancel)),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(88, 48)),
          onPressed: () {
            final v = Money.parseRupees(controller.text);
            if (v == null || v <= 0 || v > max) {
              showSnack(ctx, v != null && v > max ? l.exceedsAvailable : l.errInvalidAmount, error: true);
              return;
            }
            Navigator.pop(ctx, v);
          },
          child: Text(l.save),
        ),
      ],
    ),
  );
}

/// Records how a leader handed money to workers: either from the money the
/// family entrusted (distribution) or from the leader's own pocket.
class DistributeScreen extends ConsumerStatefulWidget {
  const DistributeScreen({super.key, required this.leaderId, this.ownMoney = false});

  final String leaderId;
  final bool ownMoney;

  @override
  ConsumerState<DistributeScreen> createState() => _DistributeScreenState();
}

class _DistributeScreenState extends ConsumerState<DistributeScreen> {
  final _amounts = <String, TextEditingController>{};
  final _order = <String>[];
  bool _busy = false;
  bool _seeded = false;

  void _ensure(String id) {
    if (_amounts.containsKey(id)) return;
    _amounts[id] = TextEditingController();
    _order.add(id);
  }

  int get _total => _amounts.values.fold(0, (s, c) => s + (Money.parseRupees(c.text) ?? 0));

  Future<void> _save(int available) async {
    final l = context.l;
    final lines = <(String, int)>[];
    for (final id in _order) {
      final text = _amounts[id]!.text.trim();
      if (text.isEmpty) continue;
      final v = Money.parseRupees(text);
      if (v == null || v <= 0) {
        showSnack(context, l.errInvalidAmount, error: true);
        return;
      }
      lines.add((id, v));
    }
    if (lines.isEmpty) return;
    if (!widget.ownMoney && _total > available) {
      showSnack(context, l.exceedsAvailable, error: true);
      return;
    }
    setState(() => _busy = true);
    var saved = 0;
    try {
      final repo = ref.read(ledgerRepoProvider);
      final today = AppClock.today().toIso();
      for (final (id, amount) in lines) {
        await repo.create(
          EntryDraft(
            type: widget.ownMoney ? EntryType.leaderSelfFunded : EntryType.leaderAllocation,
            workerId: id,
            leaderWorkerId: widget.leaderId,
            amountPaise: amount,
            businessDate: today,
          ),
        );
        saved++;
        _amounts[id]!.clear();
      }
      if (mounted) {
        showSnack(context, l.distributionSaved(saved));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        if (saved > 0) setState(() {});
        showErrorSnack(context, e);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final workers = ref.watch(workerIndexProvider).value ?? const {};
    final groups = ref.watch(groupsProvider).value ?? const <WorkerGroup>[];
    final members = ref.watch(groupMembersProvider).value ?? const {};
    final fund =
        (ref.watch(leaderFundsProvider).value ?? const <LeaderFund>[])
            .where((f) => f.leaderId == widget.leaderId)
            .firstOrNull ??
        LeaderFund(leaderId: widget.leaderId);
    if (!_seeded && workers.isNotEmpty) {
      _seeded = true;
      for (final g in groups.where((g) => g.leaderWorkerId == widget.leaderId)) {
        for (final id in members[g.id] ?? const <String>{}) {
          if (id != widget.leaderId) _ensure(id);
        }
      }
    }
    final available = fund.unreconciledPaise;
    final over = !widget.ownMoney && _total > available;

    return Scaffold(
      appBar: AppBar(title: Text(widget.ownMoney ? l.recordOwnPocket : l.recordDistribution)),
      body: ListView(
        padding: pagePadding,
        children: [
          Text(workerName(workers[widget.leaderId]), style: Theme.of(context).textTheme.titleLarge),
          gap8,
          Banner2(text: widget.ownMoney ? l.ownPocketHelp : l.distributeHelp),
          gap12,
          if (!widget.ownMoney)
            Text(
              l.distributionTotal(Money.format(_total), Money.format(available)),
              style: Theme.of(context).textTheme.titleMedium!.copyWith(color: over ? AppColors.red : null),
            ),
          if (over) Text(l.exceedsAvailable, style: const TextStyle(color: AppColors.red)),
          gap12,
          for (final id in _order)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      id == widget.leaderId
                          ? '${workerName(workers[id])} ${l.leaderSelfShare}'
                          : workerName(workers[id]),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: AmountField(controller: _amounts[id]!, label: l.amount, onChanged: (_) => setState(() {})),
                  ),
                ],
              ),
            ),
          OutlinedButton.icon(
            icon: const Icon(Icons.person_add),
            label: Text(l.selectWorker),
            onPressed: () async {
              final w = await pickWorker(context);
              if (w != null) setState(() => _ensure(w.id));
            },
          ),
          if (!widget.ownMoney && !_amounts.containsKey(widget.leaderId)) ...[
            gap8,
            TextButton(
              onPressed: () => setState(() => _ensure(widget.leaderId)),
              child: Text('+ ${l.leaderSelfShare}'),
            ),
          ],
        ],
      ),
      bottomNavigationBar: BottomActionBar(
        child: PrimaryButton(label: l.save, busy: _busy, onPressed: over ? null : () => _save(available)),
      ),
    );
  }
}
