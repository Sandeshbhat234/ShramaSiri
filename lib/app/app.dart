import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../ui/auth/auth_screens.dart';
import '../ui/common/labels.dart';
import '../ui/shell.dart';
import 'boot.dart';
import 'providers.dart';
import 'theme.dart';

class ShramaSiriApp extends ConsumerWidget {
  const ShramaSiriApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return MaterialApp(
      onGenerateTitle: (context) => context.l.appTitle,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const _Root(),
    );
  }
}

class _Root extends ConsumerWidget {
  const _Root();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final boot = ref.watch(bootProvider);
    final controller = ref.read(bootProvider.notifier);
    return switch (boot) {
      BootLoading(:final preparing) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(preparing ? l.preparing : l.loading, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      ),
      BootNotConfigured() => MessageScreen(
        icon: Icons.settings_suggest,
        title: l.setupRequiredTitle,
        body: l.setupRequiredBody,
      ),
      BootSignedOut() => const SignInScreen(),
      BootOnboarding() => OnboardingScreen(state: boot),
      BootNeedsInternet() => MessageScreen(
        icon: Icons.wifi_off,
        title: l.syncOffline,
        body: l.needInternet,
        actions: [
          FilledButton(onPressed: controller.evaluate, child: Text(l.retry)),
          TextButton(onPressed: controller.signOut, child: Text(l.signOut)),
        ],
      ),
      BootOtherUserPending(:final email) => MessageScreen(
        icon: Icons.phonelink_lock,
        title: l.otherUserPendingTitle,
        body: l.otherUserPendingBody(email),
        actions: [FilledButton(onPressed: controller.evaluate, child: Text(l.signIn))],
      ),
      BootReady() => const MainShell(),
    };
  }
}
