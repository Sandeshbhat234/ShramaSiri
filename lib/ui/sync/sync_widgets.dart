import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../data/sync/outbox.dart';
import '../../data/sync/sync_engine.dart';
import '../common/labels.dart';
import 'sync_screen.dart';

enum SyncLook { synced, savedLocally, syncing, attention, signIn }

SyncLook syncLook(SyncState? state, OutboxCounts counts) {
  if (counts.needsAttention > 0) return SyncLook.attention;
  if (state?.phase == SyncPhase.signInRequired) return SyncLook.signIn;
  if (state?.phase == SyncPhase.syncing && counts.pending > 0) return SyncLook.syncing;
  if (counts.pending > 0) return SyncLook.savedLocally;
  return SyncLook.synced;
}

String syncLookText(BuildContext context, SyncLook look, SyncState? state, OutboxCounts counts) {
  final l = context.l;
  return switch (look) {
    SyncLook.attention => l.syncNeedsAttention(counts.needsAttention),
    SyncLook.signIn => l.syncSignInAgain,
    SyncLook.syncing => l.syncInProgress,
    SyncLook.savedLocally => '${l.syncSavedOnDevice} (${counts.pending})',
    SyncLook.synced => state?.phase == SyncPhase.offline ? l.syncOffline : l.syncAllSynced,
  };
}

/// Compact app-bar indicator. Normal offline use is shown calmly; only
/// conflicts/rejections use a warning colour.
class SyncIndicator extends ConsumerWidget {
  const SyncIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(syncStateProvider).value;
    final countsAsync = ref.watch(outboxCountsProvider);
    // Never claim "all synced" before the outbox has been read.
    if (!countsAsync.hasValue) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 18),
        child: Icon(Icons.sync, color: AppColors.textMuted),
      );
    }
    final counts = countsAsync.value!;
    final look = syncLook(state, counts);
    final (icon, color, bg) = switch (look) {
      SyncLook.synced => (
        state?.phase == SyncPhase.offline ? Icons.cloud_off_outlined : Icons.cloud_done_outlined,
        AppColors.green,
        AppColors.greenSoft,
      ),
      SyncLook.savedLocally => (Icons.phone_android, AppColors.amber, AppColors.amberSoft),
      SyncLook.syncing => (Icons.sync, AppColors.blue, AppColors.blueSoft),
      SyncLook.attention => (Icons.warning_amber_rounded, AppColors.red, AppColors.redSoft),
      SyncLook.signIn => (Icons.lock_clock, AppColors.red, AppColors.redSoft),
    };
    final badge = switch (look) {
      SyncLook.attention => '${counts.needsAttention}',
      SyncLook.savedLocally || SyncLook.syncing => '${counts.pending}',
      _ => null,
    };
    return Semantics(
      button: true,
      label: syncLookText(context, look, state, counts),
      child: Tooltip(
        message: syncLookText(context, look, state, counts),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SyncScreen())),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 22, color: color),
                if (badge != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    badge,
                    style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 15),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
