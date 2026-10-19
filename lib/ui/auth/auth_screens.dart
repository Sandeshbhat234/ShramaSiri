import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/boot.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../data/repositories/repo_base.dart';
import '../common/labels.dart';
import '../common/widgets.dart';

final _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// Language switch shown before sign-in so a first-time user can choose.
class LanguageToggle extends ConsumerWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final code = ref.watch(localeProvider).languageCode;
    return TextButton.icon(
      icon: const Icon(Icons.translate),
      label: Text(code == 'kn' ? 'English' : 'ಕನ್ನಡ'),
      onPressed: () => ref.read(localeProvider.notifier).set(code == 'kn' ? 'en' : 'kn'),
    );
  }
}

class _AuthScaffold extends StatelessWidget {
  const _AuthScaffold({required this.title, required this.children, this.showBack = false});

  final String title;
  final List<Widget> children;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: showBack, actions: const [LanguageToggle()]),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                Text(
                  context.l.appTitle,
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: AppColors.green),
                ),
                gap8,
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                gap24,
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _signUp = false;
  bool _busy = false;
  bool _hide = true;

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    final boot = ref.read(bootProvider.notifier);
    try {
      if (_signUp) {
        final needsConfirm = await boot.signUp(_email.text, _password.text);
        if (needsConfirm && mounted) {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => VerifyEmailScreen(email: _email.text.trim())),
          );
        }
      } else {
        await boot.signIn(_email.text, _password.text);
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
    return _AuthScaffold(
      title: _signUp ? l.signUp : l.signIn,
      children: [
        Form(
          key: _form,
          child: Column(
            children: [
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                decoration: InputDecoration(labelText: l.email, prefixIcon: const Icon(Icons.email_outlined)),
                validator: (v) => _emailRe.hasMatch(v?.trim() ?? '') ? null : l.invalidEmail,
              ),
              gap16,
              TextFormField(
                controller: _password,
                obscureText: _hide,
                autofillHints: [_signUp ? AutofillHints.newPassword : AutofillHints.password],
                decoration: InputDecoration(
                  labelText: l.password,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_hide ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _hide = !_hide),
                  ),
                ),
                validator: (v) => (v ?? '').length >= 8 ? null : l.passwordTooShort,
                onFieldSubmitted: (_) => _submit(),
              ),
            ],
          ),
        ),
        gap24,
        PrimaryButton(label: _signUp ? l.signUp : l.signIn, icon: Icons.login, busy: _busy, onPressed: _submit),
        gap12,
        TextButton(
          onPressed: () => setState(() => _signUp = !_signUp),
          child: Text(_signUp ? l.haveAccountSignIn : l.newHereCreate, textAlign: TextAlign.center),
        ),
        if (!_signUp)
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ResetPasswordScreen(initialEmail: _email.text.trim())),
            ),
            child: Text(l.forgotPassword),
          ),
      ],
    );
  }
}

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  final _code = TextEditingController();
  bool _busy = false;

  Future<void> _verify() async {
    if (_code.text.trim().length < 6) return;
    setState(() => _busy = true);
    try {
      await ref.read(bootProvider.notifier).verifySignupCode(widget.email, _code.text);
      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return _AuthScaffold(
      title: l.checkEmailTitle,
      showBack: true,
      children: [
        Text(l.checkEmailBody(widget.email), style: Theme.of(context).textTheme.bodyLarge),
        gap16,
        TextField(
          controller: _code,
          keyboardType: TextInputType.number,
          maxLength: 10,
          style: const TextStyle(fontSize: 24, letterSpacing: 4),
          decoration: InputDecoration(labelText: l.emailCode),
        ),
        gap16,
        PrimaryButton(label: l.verify, busy: _busy, onPressed: _verify),
        gap12,
        OutlinedButton(onPressed: () => Navigator.pop(context), child: Text(l.signIn)),
      ],
    );
  }
}

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key, this.initialEmail = ''});

  final String initialEmail;

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  late final _email = TextEditingController(text: widget.initialEmail);
  final _code = TextEditingController();
  final _password = TextEditingController();
  bool _sent = false;
  bool _busy = false;

  Future<void> _run(Future<void> Function() body) async {
    setState(() => _busy = true);
    try {
      await body();
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final boot = ref.read(bootProvider.notifier);
    return _AuthScaffold(
      title: l.resetTitle,
      showBack: true,
      children: [
        Text(l.resetHelp, style: Theme.of(context).textTheme.bodyLarge),
        gap16,
        TextField(
          controller: _email,
          enabled: !_sent,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(labelText: l.email, prefixIcon: const Icon(Icons.email_outlined)),
        ),
        gap16,
        if (!_sent)
          PrimaryButton(
            label: l.sendCode,
            icon: Icons.send,
            busy: _busy,
            onPressed: () => _run(() async {
              if (!_emailRe.hasMatch(_email.text.trim())) {
                showSnack(context, l.invalidEmail, error: true);
                return;
              }
              await boot.sendPasswordReset(_email.text);
              setState(() => _sent = true);
            }),
          )
        else ...[
          TextField(
            controller: _code,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l.emailCode),
          ),
          gap16,
          TextField(
            controller: _password,
            obscureText: true,
            decoration: InputDecoration(labelText: l.newPassword),
          ),
          gap16,
          PrimaryButton(
            label: l.save,
            busy: _busy,
            onPressed: () => _run(() async {
              if (_password.text.length < 8) {
                showSnack(context, l.passwordTooShort, error: true);
                return;
              }
              await boot.completePasswordReset(_email.text, _code.text, _password.text);
              if (context.mounted) {
                showSnack(context, l.resetDone);
                Navigator.of(context).popUntil((r) => r.isFirst);
              }
            }),
          ),
        ],
      ],
    );
  }
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, required this.state});

  final BootOnboarding state;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _farm = TextEditingController();
  final _name = TextEditingController();
  final _kn = TextEditingController();
  bool _busy = false;
  bool _createOwn = false;

  Future<void> _run(Future<void> Function() body) async {
    if (_name.text.trim().isEmpty) {
      showSnack(context, context.l.errInvalidName, error: true);
      return;
    }
    setState(() => _busy = true);
    try {
      await body();
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final boot = ref.read(bootProvider.notifier);
    final invites = widget.state.invitations;
    final showCreate = invites.isEmpty || _createOwn;
    return _AuthScaffold(
      title: showCreate ? l.setupFarmTitle : l.invitationsTitle,
      children: [
        TextField(
          controller: _name,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(labelText: l.yourFullName),
        ),
        gap16,
        TextField(
          controller: _kn,
          decoration: InputDecoration(labelText: l.yourKannadaName),
        ),
        gap24,
        if (!showCreate) ...[
          for (final inv in invites) ...[
            PrimaryButton(
              label: l.joinFarm(inv.farmName),
              icon: Icons.group_add,
              busy: _busy,
              onPressed: () => _run(
                () => boot.acceptInvitation(
                  inv,
                  fullName: _name.text,
                  displayNameKn: _kn.text.trim().isEmpty ? null : _kn.text.trim(),
                ),
              ),
            ),
            gap12,
          ],
          TextButton(onPressed: () => setState(() => _createOwn = true), child: Text(l.orCreateOwn)),
        ] else ...[
          Text(l.setupFarmHelp),
          gap16,
          TextField(
            controller: _farm,
            decoration: InputDecoration(labelText: l.farmName),
          ),
          gap24,
          PrimaryButton(
            label: l.startFarm,
            busy: _busy,
            onPressed: () => _run(() async {
              if (_farm.text.trim().isEmpty) throw const AppException('invalid_name');
              await boot.createFarm(
                farmName: _farm.text,
                fullName: _name.text,
                displayNameKn: _kn.text.trim().isEmpty ? null : _kn.text.trim(),
              );
            }),
          ),
        ],
        gap24,
        TextButton(onPressed: () => boot.signOut(), child: Text(l.signOut)),
      ],
    );
  }
}

/// Full-screen message with optional actions (setup, offline, blocked...).
class MessageScreen extends StatelessWidget {
  const MessageScreen({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.actions = const [],
  });

  final IconData icon;
  final String title;
  final String body;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: const [LanguageToggle()]),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(24),
              children: [
                Icon(icon, size: 56, color: AppColors.green),
                gap16,
                Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
                gap12,
                Text(body, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
                gap24,
                for (final a in actions) Padding(padding: const EdgeInsets.only(bottom: 12), child: a),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
