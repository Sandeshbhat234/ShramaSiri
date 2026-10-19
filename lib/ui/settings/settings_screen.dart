import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../app/boot.dart';
import '../../app/providers.dart';
import '../../core/dates.dart';
import '../../data/sync/outbox.dart';
import '../common/labels.dart';
import '../common/widgets.dart';
import '../sync/sync_screen.dart';
import '../work/work_form_screen.dart';
import 'audit_screen.dart';
import 'members_screen.dart';

final packageInfoProvider = FutureProvider<PackageInfo>((ref) => PackageInfo.fromPlatform());

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final farm = ref.watch(farmProvider).value;
    final me = ref.watch(meProvider).value;
    final session = ref.watch(sessionProvider);
    final isAdmin = ref.watch(isAdminProvider);
    final locale = ref.watch(localeProvider).languageCode;
    final counts = ref.watch(outboxCountsProvider).value ?? const OutboxCounts();
    final version = ref.watch(packageInfoProvider).value;
    void push(Widget w) => Navigator.push(context, MaterialPageRoute(builder: (_) => w));

    // ISO weekday 1..7 -> localized name (2024-01-01 was a Monday).
    String dayName(int d) => DateFormat('EEEE', l.localeName).format(DateTime(2024, 1, d));

    return Scaffold(
      appBar: AppBar(title: Text(l.settings)),
      body: ListView(
        children: [
          _Header(l.farmSection),
          ListTile(
            leading: const Icon(Icons.agriculture),
            title: Text(farm?.name ?? ''),
            subtitle: Text(l.farmName),
            trailing: isAdmin ? const Icon(Icons.edit) : null,
            onTap: !isAdmin || farm == null
                ? null
                : () async {
                    final name = await promptText(context, title: l.farmName, label: l.farmName);
                    if (name == null) return;
                    try {
                      await ref.read(membersRepoProvider).updateFarm(name: name, weekStartDay: farm.weekStartDay);
                    } catch (e) {
                      if (context.mounted) showErrorSnack(context, e);
                    }
                  },
          ),
          ListTile(
            leading: const Icon(Icons.date_range),
            title: Text(l.weekStartsOn),
            subtitle: Text(farm == null ? '' : dayName(farm.weekStartDay)),
            trailing: isAdmin ? const Icon(Icons.chevron_right) : null,
            onTap: !isAdmin || farm == null
                ? () => showSnack(context, l.ownerOnly)
                : () async {
                    final day = await showDialog<int>(
                      context: context,
                      builder: (ctx) => SimpleDialog(
                        title: Text(l.weekStartsOn),
                        children: [
                          for (var d = 1; d <= 7; d++)
                            ListTile(
                              title: Text(dayName(d)),
                              trailing: d == farm.weekStartDay ? const Icon(Icons.check) : null,
                              onTap: () => Navigator.pop(ctx, d),
                            ),
                        ],
                      ),
                    );
                    if (day == null || day == farm.weekStartDay) return;
                    try {
                      await ref.read(membersRepoProvider).updateFarm(name: farm.name, weekStartDay: day);
                    } catch (e) {
                      if (context.mounted) showErrorSnack(context, e);
                    }
                  },
          ),
          ListTile(leading: const Icon(Icons.currency_rupee), title: Text(l.currencyNote)),
          ListTile(
            leading: const Icon(Icons.category_outlined),
            title: Text(l.workTypes),
            onTap: () => push(const WorkTypesScreen()),
          ),
          if (isAdmin)
            ListTile(
              leading: const Icon(Icons.family_restroom),
              title: Text(l.familyMembers),
              onTap: () => push(const MembersScreen()),
            ),
          if (isAdmin)
            ListTile(
              leading: const Icon(Icons.history),
              title: Text(l.auditHistory),
              onTap: () => push(const AuditScreen()),
            ),
          _Header(l.accountSection),
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(me?.fullName ?? ''),
            subtitle: Text([if (me != null) roleLabel(l, me.role), l.loggedInAs(session.email)].join(' · ')),
            trailing: const Icon(Icons.edit),
            onTap: () => push(const ProfileScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.translate),
            title: Text(l.language),
            trailing: SegmentedButton<String>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: 'kn', label: Text('ಕನ್ನಡ')),
                ButtonSegment(value: 'en', label: Text('English')),
              ],
              selected: {locale},
              onSelectionChanged: (s) => ref.read(localeProvider.notifier).set(s.first),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.sync),
            title: Text(l.syncTitle),
            subtitle: Text(l.pendingCount(counts.pending)),
            onTap: () => push(const SyncScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(l.signOut),
            onTap: () async {
              final pending = await ref.read(outboxProvider).unsyncedCount();
              if (!context.mounted) return;
              final ok = await confirmDialog(
                context,
                title: l.signOutConfirm,
                message: pending > 0 ? l.signOutPendingWarning(pending) : l.signOutConfirm,
                confirmLabel: l.signOut,
                destructive: pending > 0,
              );
              if (!ok || !context.mounted) return;
              Navigator.of(context).popUntil((r) => r.isFirst);
              await ref.read(bootProvider.notifier).signOut();
            },
          ),
          _Header(l.about),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l.appTitle),
            subtitle: Text(
              '${l.aboutText}\n${l.version(version == null ? '' : '${version.version}+${version.buildNumber}')}',
            ),
            isThreeLine: true,
          ),
          if (AppClock.deviceClockLooksWrong)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Banner2(text: l.clockWrong),
            ),
          gap24,
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
    child: Text(
      text,
      style: Theme.of(context).textTheme.titleSmall!.copyWith(color: Theme.of(context).colorScheme.primary),
    ),
  );
}

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _name = TextEditingController();
  final _kn = TextEditingController();
  bool _loaded = false;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final me = ref.watch(meProvider).value;
    if (!_loaded && me != null) {
      _loaded = true;
      _name.text = me.fullName;
      _kn.text = me.displayNameKn ?? '';
    }
    return Scaffold(
      appBar: AppBar(title: Text(l.profile)),
      body: ListView(
        padding: pagePadding,
        children: [
          TextField(
            controller: _name,
            decoration: InputDecoration(labelText: l.yourFullName),
          ),
          gap16,
          TextField(
            controller: _kn,
            decoration: InputDecoration(labelText: l.yourKannadaName),
          ),
          gap8,
          Text(l.loggedInAs(ref.watch(sessionProvider).email), style: Theme.of(context).textTheme.bodySmall),
          gap24,
          PrimaryButton(
            label: l.save,
            busy: _busy,
            onPressed: () async {
              setState(() => _busy = true);
              try {
                await ref.read(membersRepoProvider).updateProfile(fullName: _name.text, displayNameKn: _kn.text);
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                if (context.mounted) showErrorSnack(context, e);
              } finally {
                if (mounted) setState(() => _busy = false);
              }
            },
          ),
        ],
      ),
    );
  }
}
