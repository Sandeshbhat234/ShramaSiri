import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/config.dart';
import '../../core/dates.dart';
import '../../core/money.dart';
import '../../data/db/database.dart';
import '../../data/repositories/ledger_repo.dart';
import '../../domain/ledger.dart';
import '../common/labels.dart';
import '../common/pickers.dart';
import '../common/widgets.dart';
import '../workers/worker_detail_screen.dart';

/// The main "Give Money" form: worker, amount, purpose, paid by, save.
/// Date, method, notes and reference are tucked under "More details".
class GiveMoneyScreen extends ConsumerStatefulWidget {
  const GiveMoneyScreen({super.key, this.workerId, this.type, this.amountPaise});

  final String? workerId;
  final EntryType? type;
  final int? amountPaise;

  @override
  ConsumerState<GiveMoneyScreen> createState() => _GiveMoneyScreenState();
}

class _GiveMoneyScreenState extends ConsumerState<GiveMoneyScreen> {
  Worker? _worker;
  late EntryType _type = widget.type ?? EntryType.advance;
  late final _amount = TextEditingController(
    text: widget.amountPaise == null ? '' : Money.toInput(widget.amountPaise!),
  );
  final _notes = TextEditingController();
  final _reference = TextEditingController();
  String? _paidBy;
  String _method = PayMethod.cash;
  LocalDate _date = AppClock.today();
  bool _more = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _paidBy = ref.read(sessionProvider).userId;
    if (widget.workerId != null) {
      ref.read(workersRepoProvider).getWorker(widget.workerId!).then((w) {
        if (mounted) setState(() => _worker = w);
      });
    }
  }

  Future<void> _chooseWorker() async {
    final w = await pickWorker(context, leadersOnly: _type == EntryType.leaderTransfer);
    if (w != null) setState(() => _worker = w);
  }

  Future<void> _save() async {
    final l = context.l;
    final worker = _worker;
    final amount = Money.parseRupees(_amount.text);
    if (worker == null) {
      showSnack(context, l.selectWorker, error: true);
      return;
    }
    if (amount == null || amount <= 0 || amount > Money.maxEntryPaise) {
      showSnack(context, l.errInvalidAmount, error: true);
      return;
    }
    if (_type == EntryType.leaderTransfer && !worker.isLeader) {
      showSnack(context, l.errNotALeader, error: true);
      return;
    }
    final draft = EntryDraft(
      type: _type,
      workerId: worker.id,
      amountPaise: amount,
      businessDate: _date.toIso(),
      occurredAt: _date == AppClock.today() ? AppClock.nowUtc() : Ist.toUtc(_date, hour: 12),
      method: _method,
      paidBy: _paidBy,
      notes: _notes.text,
      reference: _reference.text,
    );
    setState(() => _busy = true);
    try {
      final repo = ref.read(ledgerRepoProvider);
      if (amount >= AppConfig.largeAmountPaise &&
          !await confirmDialog(
            context,
            message: l.largeAmountConfirm(Money.format(amount)),
            confirmLabel: l.yesRecord,
            cancelLabel: l.checkAgainBtn,
          )) {
        return;
      }
      final similar = await repo.findSimilarRecent(draft);
      if (similar != null &&
          mounted &&
          !await confirmDialog(
            context,
            message: l.duplicateConfirm(Money.format(amount), worker.nameKn),
            confirmLabel: l.yesRecord,
            cancelLabel: l.checkAgainBtn,
          )) {
        return;
      }
      await repo.create(draft);
      if (mounted) {
        showSnack(context, l.savedOnDeviceToast);
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final balance = _worker == null ? null : ref.watch(workerBalanceProvider(_worker!.id)).value;
    final funds = ref.watch(leaderFundsProvider).value ?? const <LeaderFund>[];
    final leaderFund = _worker == null ? null : funds.where((f) => f.leaderId == _worker!.id).firstOrNull;
    final help = entryTypeHelp(l, _type);

    return Scaffold(
      appBar: AppBar(title: Text(l.giveMoney)),
      body: ListView(
        padding: pagePadding,
        children: [
          // 1. Worker
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: const Icon(Icons.person, size: 32, color: AppColors.green),
              title: Text(
                _worker?.nameKn ?? (_type == EntryType.leaderTransfer ? l.selectLeader : l.selectWorker),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              subtitle: _worker == null
                  ? Text(l.recipient)
                  : Text(
                      _type == EntryType.leaderTransfer
                          ? l.leaderHolds(Money.format(leaderFund?.unreconciledPaise ?? 0))
                          : l.nowBalance(_balanceText(context, balance)),
                    ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _chooseWorker,
            ),
          ),
          gap16,
          // 2. Amount
          AmountField(controller: _amount, autofocus: widget.workerId != null && widget.amountPaise == null),
          gap16,
          // 3. Purpose
          Text(l.purpose, style: Theme.of(context).textTheme.titleSmall),
          gap8,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in givingPurposes)
                ChoiceChip(
                  label: Text(entryTypeLabel(l, t)),
                  selected: _type == t,
                  onSelected: (_) => setState(() {
                    _type = t;
                    if (t == EntryType.leaderTransfer && _worker != null && !_worker!.isLeader) _worker = null;
                  }),
                ),
            ],
          ),
          if (help != null) ...[
            gap8,
            Banner2(
              text: help,
              color: _type == EntryType.leaderTransfer ? AppColors.amberSoft : AppColors.blueSoft,
              icon: _type == EntryType.leaderTransfer ? Icons.groups : Icons.info_outline,
            ),
          ],
          gap16,
          // 4. Paid by
          PayerField(value: _paidBy, onChanged: (v) => setState(() => _paidBy = v)),
          gap8,
          // Optional details
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            initiallyExpanded: _more,
            onExpansionChanged: (v) => setState(() => _more = v),
            title: Text(l.moreDetails),
            children: [
              DateSelector(date: _date, onChanged: (d) => setState(() => _date = d)),
              gap12,
              Wrap(
                spacing: 8,
                children: [
                  for (final m in PayMethod.all)
                    ChoiceChip(
                      label: Text(methodLabel(l, m)),
                      selected: _method == m,
                      onSelected: (_) => setState(() => _method = m),
                    ),
                ],
              ),
              gap12,
              TextField(
                controller: _notes,
                decoration: InputDecoration(labelText: l.notes),
              ),
              gap12,
              TextField(
                controller: _reference,
                decoration: InputDecoration(labelText: l.reference),
              ),
              gap12,
            ],
          ),
        ],
      ),
      // 5. Save (always visible)
      bottomNavigationBar: BottomActionBar(
        child: PrimaryButton(label: l.save, busy: _busy, onPressed: _save, icon: Icons.save),
      ),
    );
  }

  String _balanceText(BuildContext context, WorkerBalance? b) {
    final l = context.l;
    if (b == null || b.wagePaise == 0) return l.settledUp;
    return b.wagePaise > 0
        ? '${l.wageDue} ${Money.format(b.wagePaise)}'
        : '${l.advanceAhead} ${Money.format(-b.wagePaise)}';
  }
}
