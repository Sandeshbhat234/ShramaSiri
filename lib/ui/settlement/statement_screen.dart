import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/providers.dart';
import '../../core/dates.dart';
import '../../domain/ledger.dart';
import '../common/labels.dart';
import '../common/widgets.dart';
import '../workers/worker_detail_screen.dart';
import 'statement_text.dart';
import 'weekly_screen.dart';

/// One worker's weekly statement, shareable as Kannada text.
class StatementScreen extends ConsumerStatefulWidget {
  const StatementScreen({super.key, required this.workerId, this.weekStart});

  final String workerId;
  final LocalDate? weekStart;

  @override
  ConsumerState<StatementScreen> createState() => _StatementScreenState();
}

class _StatementScreenState extends ConsumerState<StatementScreen> {
  LocalDate? _start;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final weekDay = ref.watch(farmProvider).value?.weekStartDay ?? 1;
    final start = _start ?? widget.weekStart ?? AppClock.today().weekStart(weekDay);
    final end = start.addDays(6);
    final worker = ref.watch(workerProvider(widget.workerId)).value;
    final list = ref.watch(periodProvider((start, end))).value;
    final me = ref.watch(meProvider).value;
    final farm = ref.watch(farmProvider).value;
    final s = list?.where((x) => x.workerId == widget.workerId).firstOrNull ?? PeriodSummary(workerId: widget.workerId);
    final text = worker == null
        ? ''
        : buildWorkerStatement(
            l: kannada,
            farmName: farm?.name ?? '',
            workerName: worker.nameKn,
            start: start,
            end: end,
            s: s,
            preparedBy: me?.fullName ?? '',
          );
    return Scaffold(
      appBar: AppBar(title: Text(l.statement)),
      body: ListView(
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
                  child: Text(
                    context.dates.range(start, end),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, size: 30),
                  onPressed: end.isBefore(AppClock.today()) ? () => setState(() => _start = start.addDays(7)) : null,
                ),
              ],
            ),
          ),
          gap12,
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SelectableText(text, style: const TextStyle(fontSize: 17, height: 1.5)),
            ),
          ),
          gap16,
          PrimaryButton(
            label: l.share,
            icon: Icons.share,
            onPressed: text.isEmpty ? null : () => SharePlus.instance.share(ShareParams(text: text)),
          ),
        ],
      ),
    );
  }
}
