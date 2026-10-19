import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/dates.dart';
import '../../core/money.dart';
import '../../data/repositories/ledger_repo.dart';
import '../../domain/ledger.dart';
import '../common/labels.dart';
import '../common/pickers.dart';
import '../common/widgets.dart';
import '../workers/worker_detail_screen.dart';

/// Less common entries for one worker: extra earnings, deductions, previous
/// balance, loan repaid in cash, loan cut from wages.
class AdjustmentScreen extends ConsumerStatefulWidget {
  const AdjustmentScreen({super.key, required this.workerId});

  final String workerId;

  @override
  ConsumerState<AdjustmentScreen> createState() => _AdjustmentScreenState();
}

class _AdjustmentScreenState extends ConsumerState<AdjustmentScreen> {
  static const _types = [
    EntryType.addition,
    EntryType.deduction,
    EntryType.openingBalance,
    EntryType.loanRepayment,
    EntryType.loanOffset,
  ];

  EntryType _type = EntryType.addition;
  final _amount = TextEditingController();
  final _notes = TextEditingController();
  LocalDate _date = AppClock.today();
  String? _receivedBy;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _receivedBy = ref.read(sessionProvider).userId;
  }

  Future<void> _save() async {
    final l = context.l;
    final amount = parseAmountInput(_amount.text, allowNegative: _type == EntryType.openingBalance);
    if (amount == null || amount == 0) {
      showSnack(context, l.errInvalidAmount, error: true);
      return;
    }
    setState(() => _busy = true);
    try {
      await ref
          .read(ledgerRepoProvider)
          .create(
            EntryDraft(
              type: _type,
              workerId: widget.workerId,
              amountPaise: amount,
              businessDate: _date.toIso(),
              paidBy: _type.isCash ? _receivedBy : null,
              notes: _notes.text,
            ),
          );
      if (mounted) {
        showSnack(context, l.savedOnDeviceToast);
        Navigator.pop(context);
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
    final worker = ref.watch(workerProvider(widget.workerId)).value;
    final balance = ref.watch(workerBalanceProvider(widget.workerId)).value;
    final help = entryTypeHelp(l, _type);
    return Scaffold(
      appBar: AppBar(title: Text(l.addAdjustment)),
      body: ListView(
        padding: pagePadding,
        children: [
          Text(workerName(worker), style: Theme.of(context).textTheme.titleLarge),
          Text(l.adjustmentHelp, style: Theme.of(context).textTheme.bodySmall),
          if ((balance?.loanPaise ?? 0) != 0) Text('${l.loanDue}: ${Money.format(balance!.loanPaise)}'),
          gap16,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in _types)
                ChoiceChip(
                  label: Text(entryTypeLabel(l, t)),
                  selected: _type == t,
                  onSelected: (_) => setState(() => _type = t),
                ),
            ],
          ),
          if (help != null) ...[gap8, Banner2(text: help)],
          gap16,
          AmountField(controller: _amount, allowNegative: _type == EntryType.openingBalance, autofocus: true),
          gap16,
          DateSelector(date: _date, onChanged: (d) => setState(() => _date = d)),
          if (_type.isCash) ...[
            gap16,
            PayerField(value: _receivedBy, label: l.receivedBy, onChanged: (v) => setState(() => _receivedBy = v)),
          ],
          gap16,
          TextField(
            controller: _notes,
            decoration: InputDecoration(labelText: l.notes),
          ),
          gap24,
          PrimaryButton(label: l.save, busy: _busy, onPressed: _save),
        ],
      ),
    );
  }
}
