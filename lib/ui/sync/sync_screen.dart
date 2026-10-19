import 'dart:convert';

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/boot.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/dates.dart';
import '../../core/money.dart';
import '../../data/db/database.dart';
import '../../data/sync/conflict_resolver.dart';
import '../../data/sync/outbox.dart';
import '../../data/sync/sync_engine.dart';
import '../../l10n/app_localizations.dart';
import '../common/labels.dart';
import '../common/widgets.dart';
import 'sync_widgets.dart';

final attentionProvider = StreamProvider<List<AttentionItem>>(
  (ref) => ref.watch(conflictResolverProvider).watchAttention(),
);

class SyncScreen extends ConsumerStatefulWidget {
  const SyncScreen({super.key});

  @override
  ConsumerState<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends ConsumerState<SyncScreen> {
  bool _busy = false;

  Future<void> _syncNow() async {
    setState(() => _busy = true);
    try {
      await ref.read(syncEngineProvider).sync();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final state = ref.watch(syncStateProvider).value;
    final counts = ref.watch(outboxCountsProvider).value ?? const OutboxCounts();
    final attention = ref.watch(attentionProvider);
    final look = syncLook(state, counts);
    final last = state?.lastSyncAt;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.syncTitle),
        actions: [
          IconButton(
            tooltip: l.diagnostics,
            icon: const Icon(Icons.list_alt),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DiagnosticsScreen())),
          ),
        ],
      ),
      body: ListView(
        padding: pagePadding,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(syncLookText(context, look, state, counts), style: Theme.of(context).textTheme.titleMedium),
                  gap8,
                  Text(last == null ? l.neverSynced : l.lastSynced(context.dates.instant(last))),
                  Text(l.pendingCount(counts.pending)),
                  if (state?.phase == SyncPhase.offline) Text(l.syncOffline),
                  if (state?.phase == SyncPhase.error) Text(l.syncServerProblem),
                  if (AppClock.deviceClockLooksWrong) ...[
                    gap8,
                    Banner2(text: l.clockWrong, color: AppColors.amberSoft),
                  ],
                  gap16,
                  if (state?.phase == SyncPhase.signInRequired)
                    PrimaryButton(
                      label: l.signIn,
                      icon: Icons.login,
                      onPressed: () async {
                        await ref.read(bootProvider.notifier).signOut();
                        if (context.mounted) Navigator.of(context).popUntil((r) => r.isFirst);
                      },
                    )
                  else
                    PrimaryButton(
                      label: l.syncNow,
                      icon: Icons.sync,
                      busy: _busy || state?.phase == SyncPhase.syncing,
                      onPressed: _syncNow,
                    ),
                ],
              ),
            ),
          ),
          SectionHeader(l.attentionTitle),
          AsyncView(
            attention,
            builder: (items) {
              if (items.isEmpty) return EmptyState(icon: Icons.check_circle_outline, text: l.noAttention);
              return Column(
                children: [
                  for (final item in items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AttentionCard(item: item),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class AttentionCard extends ConsumerStatefulWidget {
  const AttentionCard({super.key, required this.item});

  final AttentionItem item;

  @override
  ConsumerState<AttentionCard> createState() => _AttentionCardState();
}

class _AttentionCardState extends ConsumerState<AttentionCard> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
      ref.read(syncControllerProvider).nudge();
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final item = widget.item;
    final resolver = ref.read(conflictResolverProvider);
    final workers = ref.watch(workerIndexProvider).value ?? const <String, Worker>{};
    final p = item.payload;
    final data = Map<String, Object?>.from((item.conflict['data'] as Map?) ?? const {});
    final failedOnly = item.op.status == OpStatus.failed;

    final subject = <String>[
      opLabel(l, item.op.entityTable),
      if (p['worker_id'] is String) workerName(workers[p['worker_id']]),
      if (p['name_kn'] is String) p['name_kn'] as String,
      if (p['amount_paise'] is int) Money.format(p['amount_paise'] as int),
      if (p['work_date'] is String) context.dates.date(LocalDate.parse(p['work_date'] as String)),
      if (p['business_date'] is String) context.dates.date(LocalDate.parse(p['business_date'] as String)),
    ].join(' · ');

    final server = item.serverRows.where((r) => r.table == item.op.entityTable).firstOrNull?.data;

    return Card(
      color: item.isConflict ? AppColors.amberSoft : (failedOnly ? AppColors.blueSoft : AppColors.redSoft),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subject, style: Theme.of(context).textTheme.titleSmall),
            gap8,
            Text(failedOnly ? l.opFailedRetrying : errorCodeText(l, item.code, data)),
            if (server != null) ...[gap12, _VersionsTable(mine: p, theirs: server, table: item.op.entityTable)],
            gap12,
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (item.canKeepMine)
                  FilledButton(
                    style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
                    onPressed: _busy ? null : () => _run(() => resolver.keepMine(item)),
                    child: Text(l.keepMine),
                  ),
                if (!failedOnly)
                  OutlinedButton(
                    onPressed: _busy ? null : () => _run(() => resolver.discardMine(item)),
                    child: Text(item.isConflict ? l.keepTheirs : l.discardMine),
                  ),
                if (item.canRetry)
                  OutlinedButton(
                    onPressed: _busy ? null : () => _run(() => resolver.retry(item)),
                    child: Text(l.retryUpload),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Side-by-side view of the fields that differ between my change and the
/// server's version.
class _VersionsTable extends ConsumerWidget {
  const _VersionsTable({required this.mine, required this.theirs, required this.table});

  final Map<String, dynamic> mine;
  final Map<String, dynamic> theirs;
  final String table;

  static const _hidden = {
    'id',
    'farm_id',
    'revision',
    'server_seq',
    'created_at',
    'updated_at',
    'sync_status',
    'source_device_id',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final members = ref.watch(membersByUserProvider).value ?? const <String, FarmMember>{};
    String fmt(String key, Object? v) {
      if (v == null) return '—';
      if (key.endsWith('_paise') && v is int) return Money.format(v);
      if (key == 'units_milli' && v is int) return Units.format(v);
      return v.toString();
    }

    final keys = mine.keys
        .where((k) => !_hidden.contains(k) && theirs.containsKey(k) && '${mine[k]}' != '${theirs[k]}')
        .toList();
    final who = members[theirs['updated_by'] ?? theirs['recorded_by']]?.fullName;
    return Table(
      columnWidths: const {0: FlexColumnWidth(1.2), 1: FlexColumnWidth(1), 2: FlexColumnWidth(1)},
      children: [
        TableRow(
          children: [
            const SizedBox(),
            Text(l.myVersion, style: const TextStyle(fontWeight: FontWeight.w700)),
            Text(
              who == null ? l.otherVersion : '${l.otherVersion} ($who)',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        for (final k in keys)
          TableRow(
            children: [
              Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Text(_fieldLabel(l, k))),
              Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Text(fmt(k, mine[k]))),
              Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Text(fmt(k, theirs[k]))),
            ],
          ),
      ],
    );
  }

  String _fieldLabel(AppLocalizations l, String key) => switch (key) {
    'units_milli' => l.daysWorked,
    'rate_paise' || 'default_wage_paise' => l.dailyWage,
    'name_kn' => l.nameKannada,
    'name_en' => l.nameEnglish,
    'phone' => l.phoneOptional,
    'notes' => l.notes,
    'status' => l.status,
    'is_leader' => l.isLeader,
    'name' => l.groupName,
    'role' => l.familyMembers,
    'work_type_id' => l.workType,
    _ => key,
  };
}

/// Read-only view of the outbox for troubleshooting. Payloads (which contain
/// amounts and names) are only shown in debug builds.
class DiagnosticsScreen extends ConsumerWidget {
  const DiagnosticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final db = ref.watch(databaseProvider);
    final stream =
        (db.select(db.outboxOps)
              ..orderBy([(o) => OrderingTerm.desc(o.seq)])
              ..limit(300))
            .watch();
    return Scaffold(
      appBar: AppBar(title: Text(l.diagnostics)),
      body: StreamBuilder<List<OutboxOp>>(
        stream: stream,
        builder: (context, snap) {
          final ops = snap.data ?? const <OutboxOp>[];
          if (snap.hasData && ops.isEmpty) return EmptyState(icon: Icons.inbox, text: l.noEntries);
          return ListView.separated(
            itemCount: ops.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final o = ops[i];
              return ListTile(
                dense: true,
                title: Text('#${o.seq} ${o.opType} · ${o.status}'),
                subtitle: Text(
                  [
                    '${o.entityTable}/${o.entityId.substring(0, 8)}',
                    'tries ${o.attempts}',
                    if (o.lastErrorCode != null) o.lastErrorCode!,
                    context.dates.instant(o.createdAt),
                    if (o.syncedAt != null) '✓ ${context.dates.instant(o.syncedAt!)}',
                  ].join(' · '),
                ),
                onTap: kDebugMode
                    ? () => showDialog<void>(
                        context: context,
                        builder: (_) => AlertDialog(
                          content: SingleChildScrollView(
                            child: SelectableText(
                              const JsonEncoder.withIndent('  ').convert({
                                'op_id': o.opId,
                                'payload': jsonDecode(o.payload),
                                if (o.conflictData != null) 'conflict': jsonDecode(o.conflictData!),
                              }),
                            ),
                          ),
                        ),
                      )
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}
