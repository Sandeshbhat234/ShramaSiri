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
import '../settings/audit_screen.dart';

final entryProvider = StreamProvider.autoDispose.family<LedgerEntry?, String>(
  (ref, id) => ref.watch(ledgerRepoProvider).watchEntry(id),
);
final reversalOfProvider = StreamProvider.autoDispose.family<LedgerEntry?, String>(
  (ref, id) => ref.watch(ledgerRepoProvider).watchReversalOf(id),
);

/// One money entry with who paid / who recorded, its sync state, and the
/// ways to correct it (explicit cancellation or correction - never editing).
class EntryDetailScreen extends ConsumerWidget {
  const EntryDetailScreen({super.key, required this.entryId});

  final String entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final entry = ref.watch(entryProvider(entryId)).value;
    if (entry == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final reversal = ref.watch(reversalOfProvider(entryId)).value;
    final workers = ref.watch(workerIndexProvider).value ?? const {};
    final me = ref.watch(sessionProvider).userId;
    final isAdmin = ref.watch(isAdminProvider);
    final type = EntryType.fromCode(entry.entryType);
    final canChange =
        !entry.isReversal &&
        reversal == null &&
        entry.syncStatus != RowSync.rejected &&
        (isAdmin || entry.recordedBy == me);

    Widget row(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.textMuted)),
          ),
          Expanded(child: Text(value, style: Theme.of(context).textTheme.bodyLarge)),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l.entryDetails)),
      body: ListView(
        padding: pagePadding,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.isReversal ? '${l.reversalLabel}: ${entryTypeLabel(l, type)}' : entryTypeLabel(l, type),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  gap8,
                  AmountText(
                    entry.isReversal ? -entry.amountPaise : entry.amountPaise,
                    signed: true,
                    strike: reversal != null,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  if (reversal != null)
                    Text(
                      l.reversedLabel,
                      style: const TextStyle(color: AppColors.red, fontWeight: FontWeight.w700),
                    ),
                  SyncChip(entry.syncStatus, pendingVerification: type == EntryType.leaderAllocation),
                  const Divider(height: 24),
                  row(l.worker, workerName(workers[entry.workerId])),
                  if (entry.leaderWorkerId != null) row(l.leader, workerName(workers[entry.leaderWorkerId])),
                  row(l.date, context.dates.date(LocalDate.parse(entry.businessDate))),
                  row(l.dateTime, context.dates.instant(entry.occurredAt)),
                  if (entry.method != PayMethod.none) row(l.method, methodLabel(l, entry.method)),
                  if (entry.paidByName != null)
                    row(
                      entry.entryType == 'loan_repayment' || entry.entryType == 'leader_return'
                          ? l.receivedBy
                          : l.paidBy,
                      entry.paidByName!,
                    ),
                  row(l.recordedBy, entry.recordedByName),
                  if (entry.reference != null) row(l.reference, entry.reference!),
                  if (entry.notes != null) row(entry.isReversal ? l.reason : l.notes, entry.notes!),
                ],
              ),
            ),
          ),
          if (entryTypeHelp(l, type) != null) ...[gap12, Banner2(text: entryTypeHelp(l, type)!)],
          if (reversal != null) ...[
            SectionHeader(l.reversedLabel),
            Card(
              child: ListTile(
                title: Text(reversal.notes ?? ''),
                subtitle: Text(
                  '${l.recordedByLine(reversal.recordedByName)} · ${context.dates.instant(reversal.occurredAt)}',
                ),
                trailing: SyncChip(reversal.syncStatus),
              ),
            ),
          ],
          if (canChange) ...[
            gap24,
            OutlinedButton.icon(
              icon: const Icon(Icons.edit_note),
              label: Text(l.correctEntry),
              onPressed: () =>
                  Navigator.push(context, MaterialPageRoute(builder: (_) => CorrectEntryScreen(original: entry))),
            ),
            gap12,
            OutlinedButton.icon(
              icon: const Icon(Icons.block, color: AppColors.red),
              label: Text(l.reverseEntry),
              onPressed: () async {
                final reason = await promptText(
                  context,
                  title: l.reverseEntry,
                  label: l.reason,
                  help: l.reverseExplain,
                );
                if (reason == null) return;
                try {
                  await ref.read(ledgerRepoProvider).reverse(entry, reason);
                  if (context.mounted) showSnack(context, l.savedOnDeviceToast);
                } catch (e) {
                  if (context.mounted) showErrorSnack(context, e);
                }
              },
            ),
          ],
          SectionHeader(l.changeHistory),
          AuditList(entityId: entry.isReversal ? entry.reversesId : entry.id),
        ],
      ),
    );
  }
}

/// Replace an entry with a corrected one (amount, date, worker, payer,
/// notes). Recorded as cancellation + new entry in one operation.
class CorrectEntryScreen extends ConsumerStatefulWidget {
  const CorrectEntryScreen({super.key, required this.original});

  final LedgerEntry original;

  @override
  ConsumerState<CorrectEntryScreen> createState() => _CorrectEntryScreenState();
}

class _CorrectEntryScreenState extends ConsumerState<CorrectEntryScreen> {
  late final _amount = TextEditingController(text: Money.toInput(widget.original.amountPaise.abs()));
  late final _notes = TextEditingController(text: widget.original.notes ?? '');
  late LocalDate _date = LocalDate.parse(widget.original.businessDate);
  late String? _paidBy = widget.original.paidBy;
  late String _workerId = widget.original.workerId;
  bool _busy = false;

  Future<void> _save() async {
    final l = context.l;
    final type = EntryType.fromCode(widget.original.entryType);
    var amount = Money.parseRupees(_amount.text);
    if (amount == null || amount == 0) {
      showSnack(context, l.errInvalidAmount, error: true);
      return;
    }
    if (type == EntryType.openingBalance && widget.original.amountPaise < 0) amount = -amount;
    final reason = await promptText(context, title: l.correctEntry, label: l.reason, help: l.correctExplain);
    if (reason == null) return;
    setState(() => _busy = true);
    try {
      final o = widget.original;
      await ref
          .read(ledgerRepoProvider)
          .correct(
            o,
            EntryDraft(
              type: type,
              workerId: _workerId,
              leaderWorkerId: o.leaderWorkerId,
              amountPaise: amount,
              businessDate: _date.toIso(),
              occurredAt: o.occurredAt,
              method: o.method == PayMethod.none ? PayMethod.cash : o.method,
              paidBy: _paidBy,
              notes: _notes.text,
              reference: o.reference,
              relatedEntryId: o.relatedEntryId,
            ),
            reason,
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
    final workers = ref.watch(workerIndexProvider).value ?? const {};
    final type = EntryType.fromCode(widget.original.entryType);
    return Scaffold(
      appBar: AppBar(title: Text(l.correctEntry)),
      body: ListView(
        padding: pagePadding,
        children: [
          Banner2(text: l.correctExplain),
          gap16,
          Text(entryTypeLabel(l, type), style: Theme.of(context).textTheme.titleMedium),
          gap12,
          if (!type.needsLeader && type != EntryType.leaderTransfer && type != EntryType.leaderReturn)
            Card(
              child: ListTile(
                title: Text(workerName(workers[_workerId])),
                subtitle: Text(l.worker),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final w = await pickWorker(context);
                  if (w != null) setState(() => _workerId = w.id);
                },
              ),
            ),
          gap12,
          AmountField(controller: _amount),
          gap12,
          DateSelector(date: _date, onChanged: (d) => setState(() => _date = d)),
          if (type.isCash) ...[gap12, PayerField(value: _paidBy, onChanged: (v) => setState(() => _paidBy = v))],
          gap12,
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
