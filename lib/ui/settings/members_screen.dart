import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../data/db/database.dart';
import '../../data/repositories/members_repo.dart';
import '../common/labels.dart';
import '../common/widgets.dart';

final membersProvider = StreamProvider.autoDispose<List<FarmMember>>(
  (ref) => ref.watch(membersRepoProvider).watchMembers(),
);

/// Owner/admin: invite family members, change roles, remove or restore
/// access. Members are never deleted, so their history keeps their name.
class MembersScreen extends ConsumerWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final members = ref.watch(membersProvider);
    final me = ref.watch(meProvider).value;
    final repo = ref.read(membersRepoProvider);

    Future<void> run(Future<void> Function() f) async {
      try {
        await f();
      } catch (e) {
        if (context.mounted) showErrorSnack(context, e);
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.familyMembers)),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.person_add),
        label: Text(l.inviteMember),
        onPressed: () => showDialog<void>(context: context, builder: (_) => const _InviteDialog()),
      ),
      body: AsyncView(
        members,
        builder: (list) {
          return ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Banner2(text: l.inviteHelp),
              ),
              for (final m in list)
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: m.status == 'active' ? AppColors.greenSoft : AppColors.border,
                    child: Text(m.fullName.characters.first),
                  ),
                  title: Text(m.fullName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${roleLabel(l, m.role)} · ${m.email}'),
                      if (m.status == 'invited') Text(l.memberInvited, style: const TextStyle(color: AppColors.amber)),
                      if (m.status == 'disabled') Text(l.memberDisabled, style: const TextStyle(color: AppColors.red)),
                      SyncChip(m.syncStatus),
                    ],
                  ),
                  trailing: m.role == Roles.owner || m.userId == me?.userId
                      ? null
                      : PopupMenuButton<String>(
                          onSelected: (v) async {
                            switch (v) {
                              case 'disable':
                                if (await confirmDialog(
                                  context,
                                  message: l.disableConfirm(m.fullName),
                                  confirmLabel: l.disableAccess,
                                  destructive: true,
                                )) {
                                  await run(() => repo.updateMember(m, status: 'disabled'));
                                }
                              case 'enable':
                                await run(() => repo.updateMember(m, status: m.userId == null ? 'invited' : 'active'));
                              case 'admin':
                                await run(() => repo.updateMember(m, role: Roles.admin));
                              case 'member':
                                await run(() => repo.updateMember(m, role: Roles.member));
                            }
                          },
                          itemBuilder: (_) => [
                            if (m.status != 'disabled') PopupMenuItem(value: 'disable', child: Text(l.disableAccess)),
                            if (m.status == 'disabled') PopupMenuItem(value: 'enable', child: Text(l.enableAccess)),
                            if (me?.role == Roles.owner && m.role == Roles.member)
                              PopupMenuItem(value: 'admin', child: Text(l.makeAdmin)),
                            if (me?.role == Roles.owner && m.role == Roles.admin)
                              PopupMenuItem(value: 'member', child: Text(l.makeMember)),
                          ],
                        ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _InviteDialog extends ConsumerStatefulWidget {
  const _InviteDialog();

  @override
  ConsumerState<_InviteDialog> createState() => _InviteDialogState();
}

class _InviteDialogState extends ConsumerState<_InviteDialog> {
  final _email = TextEditingController();
  final _name = TextEditingController();
  String _role = Roles.member;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final isOwner = ref.watch(meProvider).value?.role == Roles.owner;
    return AlertDialog(
      title: Text(l.inviteMember),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _name,
              decoration: InputDecoration(labelText: l.fullName),
            ),
            gap12,
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: l.email),
            ),
            if (isOwner) ...[
              gap12,
              SegmentedButton<String>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(value: Roles.member, label: Text(l.roleMember)),
                  ButtonSegment(value: Roles.admin, label: Text(l.roleAdmin)),
                ],
                selected: {_role},
                onSelectionChanged: (s) => setState(() => _role = s.first),
              ),
            ],
            gap12,
            Text(l.inviteHelp, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(88, 48)),
          onPressed: _busy
              ? null
              : () async {
                  setState(() => _busy = true);
                  try {
                    await ref.read(membersRepoProvider).invite(email: _email.text, fullName: _name.text, role: _role);
                    if (context.mounted) Navigator.pop(context);
                  } catch (e) {
                    if (context.mounted) showErrorSnack(context, e);
                  } finally {
                    if (mounted) setState(() => _busy = false);
                  }
                },
          child: Text(l.inviteMember),
        ),
      ],
    );
  }
}
