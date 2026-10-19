import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/db/database.dart';
import '../common/labels.dart';
import '../common/widgets.dart';

final auditProvider = StreamProvider.autoDispose.family<List<AuditEvent>, (String?, int)>(
  (ref, a) => ref.watch(membersRepoProvider).watchAudit(entityId: a.$1, limit: a.$2),
);

/// Who did what, when, from the server's audit trail (synced to the device).
class AuditScreen extends StatefulWidget {
  const AuditScreen({super.key});

  @override
  State<AuditScreen> createState() => _AuditScreenState();
}

class _AuditScreenState extends State<AuditScreen> {
  int _limit = 100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l.auditHistory)),
      body: SingleChildScrollView(
        padding: pagePadding,
        child: Column(
          children: [
            AuditList(limit: _limit),
            TextButton(onPressed: () => setState(() => _limit += 100), child: Text(context.l.loadMore)),
          ],
        ),
      ),
    );
  }
}

class AuditList extends ConsumerWidget {
  const AuditList({super.key, this.entityId, this.limit = 50});

  final String? entityId;
  final int limit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final events = ref.watch(auditProvider((entityId, limit))).value ?? const <AuditEvent>[];
    final workers = ref.watch(workerIndexProvider).value ?? const {};
    if (events.isEmpty) return Card(child: ListTile(title: Text(l.noEntries)));
    return Card(
      child: Column(
        children: [
          for (final e in events)
            ListTile(
              title: Text(auditLabel(l, e.action)),
              subtitle: Text(
                [
                  e.actorName ?? '',
                  context.dates.instant(e.createdAt),
                  if (e.entityType == 'worker' && workers[e.entityId] != null) workers[e.entityId]!.nameKn,
                ].where((s) => s.isNotEmpty).join(' · '),
              ),
            ),
        ],
      ),
    );
  }
}
