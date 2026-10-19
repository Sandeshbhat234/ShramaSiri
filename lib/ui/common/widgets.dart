import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../core/money.dart';
import '../../data/db/database.dart';
import 'labels.dart';

const pagePadding = EdgeInsets.fromLTRB(16, 12, 16, 24);
const gap8 = SizedBox(height: 8, width: 8);
const gap12 = SizedBox(height: 12, width: 12);
const gap16 = SizedBox(height: 16, width: 16);
const gap24 = SizedBox(height: 24, width: 24);

/// Rupee amount. With [signed], negative values are shown in red-brown.
class AmountText extends StatelessWidget {
  const AmountText(this.paise, {super.key, this.style, this.signed = false, this.strike = false});

  final int paise;
  final TextStyle? style;
  final bool signed;
  final bool strike;

  @override
  Widget build(BuildContext context) {
    final base = style ?? Theme.of(context).textTheme.titleMedium!;
    return Text(
      Money.format(paise),
      style: base.copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
        color: signed && paise < 0 ? AppColors.red : base.color,
        decoration: strike ? TextDecoration.lineThrough : null,
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      // Wraps the action under the title when both don't fit on one line.
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        children: [
          Text(text, style: Theme.of(context).textTheme.titleMedium),
          ?trailing,
        ],
      ),
    );
  }
}

/// A labelled figure. [caption] explains what the number means.
class StatTile extends StatelessWidget {
  const StatTile({super.key, required this.label, required this.value, this.caption, this.onTap, this.tone});

  final String label;
  final Widget value;
  final String? caption;
  final VoidCallback? onTap;
  final Color? tone;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Card(
      color: tone,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: t.bodyMedium!.copyWith(color: AppColors.textMuted)),
              const SizedBox(height: 4),
              DefaultTextStyle.merge(style: t.titleLarge, child: value),
              if (caption != null) ...[const SizedBox(height: 2), Text(caption!, style: t.bodySmall)],
            ],
          ),
        ),
      ),
    );
  }
}

/// Two tiles side by side that wrap to one per row on narrow screens or
/// large font settings.
class TileRow extends StatelessWidget {
  const TileRow({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final scale = MediaQuery.textScalerOf(context).scale(1);
        final perRow = c.maxWidth / scale >= 300 ? 2 : 1;
        final width = (c.maxWidth - (perRow - 1) * 12) / perRow;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [for (final w in children) SizedBox(width: width, child: w)],
        );
      },
    );
  }
}

class BigActionButton extends StatelessWidget {
  const BigActionButton({super.key, required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.greenSoft,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 92),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 32, color: AppColors.green),
                const SizedBox(height: 6),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.text),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Big action buttons, two per row; each row grows to fit the longest
/// label (Kannada labels and large system fonts wrap instead of overflowing).
class ActionGrid extends StatelessWidget {
  const ActionGrid({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += 2) {
      if (rows.isNotEmpty) rows.add(gap12);
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: children[i]),
              gap12,
              Expanded(child: i + 1 < children.length ? children[i + 1] : const SizedBox()),
            ],
          ),
        ),
      );
    }
    return Column(children: rows);
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.text, this.action});

  final IconData icon;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: AppColors.textMuted),
          gap12,
          Text(text, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
          if (action != null) ...[gap16, action!],
        ],
      ),
    );
    // Scroll when the available height is small (large fonts, short screens).
    return LayoutBuilder(
      builder: (context, c) => c.hasBoundedHeight ? Center(child: SingleChildScrollView(child: content)) : content,
    );
  }
}

/// Small coloured note (info, warning, error).
class Banner2 extends StatelessWidget {
  const Banner2({
    super.key,
    required this.text,
    this.icon = Icons.info_outline,
    this.color = AppColors.blueSoft,
    this.onTap,
  });

  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 22, color: AppColors.text),
              gap12,
              Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
              if (onTap != null) const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

/// Row-level sync marker; hidden when synced.
class SyncChip extends StatelessWidget {
  const SyncChip(this.syncStatus, {super.key, this.pendingVerification = false});

  final int syncStatus;

  /// Leader distributions are provisional until the server confirms funds.
  final bool pendingVerification;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final (text, color, icon) = switch (syncStatus) {
      RowSync.pending => (
        pendingVerification ? l.statusPendingVerification : l.statusSaved,
        AppColors.amberSoft,
        Icons.phone_android,
      ),
      RowSync.needsReview => (l.statusConflict, AppColors.amberSoft, Icons.warning_amber),
      RowSync.rejected => (l.statusRejected, AppColors.redSoft, Icons.error_outline),
      _ => ('', Colors.transparent, Icons.check),
    };
    if (syncStatus == RowSync.synced) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15),
          const SizedBox(width: 4),
          Flexible(
            child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

/// Full-width primary button that ignores taps while [busy] (prevents
/// accidental double submission).
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, required this.onPressed, this.busy = false, this.icon});

  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: busy ? null : onPressed,
      icon: busy
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5))
          : Icon(icon ?? Icons.check),
      label: Text(label),
    );
  }
}

/// Primary action pinned above the system navigation so it is always
/// reachable on small phones without scrolling.
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Padding(padding: const EdgeInsets.fromLTRB(16, 10, 16, 12), child: child),
      ),
    );
  }
}

/// Renders an AsyncValue with consistent loading and error states.
class AsyncView<T> extends StatelessWidget {
  const AsyncView(this.value, {super.key, required this.builder});

  final AsyncValue<T> value;
  final Widget Function(T data) builder;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: builder,
      loading: () => const Center(
        child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()),
      ),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(errorText(context.l, e), textAlign: TextAlign.center),
        ),
      ),
    );
  }
}

/// Amount input in rupees (digits and one decimal point).
class AmountField extends StatelessWidget {
  const AmountField({
    super.key,
    required this.controller,
    this.label,
    this.autofocus = false,
    this.allowNegative = false,
    this.onChanged,
    this.helper,
  });

  final TextEditingController controller;
  final String? label;
  final bool autofocus;
  final bool allowNegative;
  final ValueChanged<String>? onChanged;
  final String? helper;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      autofocus: autofocus,
      keyboardType: TextInputType.numberWithOptions(decimal: true, signed: allowNegative),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(allowNegative ? r'[-0-9.,]' : r'[0-9.,]'))],
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        labelText: label ?? context.l.amountRupees,
        prefixText: '₹ ',
        helperText: helper,
        helperMaxLines: 3,
      ),
      onChanged: onChanged,
    );
  }
}

/// Parses an [AmountField]'s text (optionally signed) into paise.
int? parseAmountInput(String text, {bool allowNegative = false}) {
  final t = text.trim();
  if (allowNegative && t.startsWith('-')) {
    final v = Money.parseRupees(t.substring(1));
    return v == null ? null : -v;
  }
  return Money.parseRupees(t);
}

Future<bool> confirmDialog(
  BuildContext context, {
  required String message,
  String? title,
  String? confirmLabel,
  String? cancelLabel,
  bool destructive = false,
}) async {
  final l = context.l;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: title == null ? null : Text(title),
      content: Text(message, style: Theme.of(ctx).textTheme.bodyLarge),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(cancelLabel ?? l.cancel)),
        FilledButton(
          style: destructive
              ? FilledButton.styleFrom(backgroundColor: AppColors.red, minimumSize: const Size(88, 48))
              : FilledButton.styleFrom(minimumSize: const Size(88, 48)),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(confirmLabel ?? l.ok),
        ),
      ],
    ),
  );
  return ok ?? false;
}

void showSnack(BuildContext context, String text, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text), backgroundColor: error ? AppColors.red : null));
}

void showErrorSnack(BuildContext context, Object e) => showSnack(context, errorText(context.l, e), error: true);

/// Asks for a short text (e.g. a reason). Returns null if cancelled.
Future<String?> promptText(BuildContext context, {required String title, required String label, String? help}) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (help != null) ...[Text(help), gap12],
          TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(labelText: label),
            maxLength: 300,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(context.l.cancel)),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(88, 48)),
          onPressed: () {
            if (controller.text.trim().isEmpty) return;
            Navigator.pop(ctx, controller.text.trim());
          },
          child: Text(context.l.ok),
        ),
      ],
    ),
  );
}

/// "Paid by X · Recorded by Y" style caption.
String peopleLine(BuildContext context, LedgerEntry e) {
  final l = context.l;
  final parts = <String>[];
  if (e.paidByName != null) {
    final inbound = e.entryType == 'loan_repayment' || e.entryType == 'leader_return';
    parts.add(inbound ? l.receivedByLine(e.paidByName!) : l.paidByLine(e.paidByName!));
  }
  if (e.recordedBy != e.paidBy || e.paidByName == null) parts.add(l.recordedByLine(e.recordedByName));
  return parts.join(' · ');
}
