import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config.dart';
import '../core/dates.dart';
import '../core/ids.dart';
import '../data/db/database.dart';
import '../data/remote/remote_api.dart';
import '../data/sync/outbox.dart';
import '../data/sync/sync_engine.dart';
import 'providers.dart';

/// Identity of the signed-in user on this device.
@immutable
class AppSession {
  const AppSession({required this.userId, required this.email, required this.farmId});

  final String userId;
  final String email;
  final String farmId;
}

class Invitation {
  Invitation(this.memberId, this.farmName, this.fullName);

  final String memberId;
  final String farmName;
  final String fullName;
}

sealed class BootState {
  const BootState();
}

class BootLoading extends BootState {
  const BootLoading({this.preparing = false});

  /// True while the first full download of farm records is running.
  final bool preparing;
}

class BootNotConfigured extends BootState {
  const BootNotConfigured();
}

class BootSignedOut extends BootState {
  const BootSignedOut();
}

/// Signed in, but no farm yet: create one or accept an invitation.
class BootOnboarding extends BootState {
  const BootOnboarding({required this.email, required this.invitations});

  final String email;
  final List<Invitation> invitations;
}

/// First-time setup needs internet.
class BootNeedsInternet extends BootState {
  const BootNeedsInternet();
}

/// Another account's unsynced records are on this phone.
class BootOtherUserPending extends BootState {
  const BootOtherUserPending(this.email);

  final String email;
}

class BootReady extends BootState {
  const BootReady(this.session);

  final AppSession session;
}

final bootProvider = NotifierProvider<BootController, BootState>(BootController.new);

class BootController extends Notifier<BootState> {
  Future<void>? _running;
  bool _again = false;

  AppDatabase get _db => ref.read(databaseProvider);
  SupabaseClient? get _client => ref.read(supabaseProvider);
  RemoteApi? get _remote => ref.read(remoteApiProvider);

  @override
  BootState build() {
    final client = ref.watch(supabaseProvider);
    if (client != null) {
      final sub = client.auth.onAuthStateChange.listen((data) {
        if (data.event == AuthChangeEvent.signedIn || data.event == AuthChangeEvent.signedOut) {
          evaluate();
        }
      });
      ref.onDispose(sub.cancel);
    }
    Future.microtask(evaluate);
    return const BootLoading();
  }

  void _set(BootState s) {
    if (ref.mounted) state = s;
  }

  /// Re-derives the boot state. Calls made while one runs are coalesced.
  Future<void> evaluate() {
    final running = _running;
    if (running != null) {
      _again = true;
      return running;
    }
    final f = _loop();
    _running = f;
    return f.whenComplete(() => _running = null);
  }

  Future<void> _loop() async {
    do {
      _again = false;
      try {
        await _evaluateOnce();
      } catch (e, st) {
        debugPrint('boot evaluation failed: $e\n$st');
        _set(const BootNeedsInternet());
      }
    } while (_again && ref.mounted);
  }

  Future<void> _evaluateOnce() async {
    final client = _client;
    if (!AppConfig.isConfigured || client == null) {
      _set(const BootNotConfigured());
      return;
    }
    final user = client.auth.currentUser;
    if (user == null) {
      _set(const BootSignedOut());
      return;
    }

    final boundUser = await _db.getKv(KvKeys.boundUserId);
    if (boundUser != null && boundUser != user.id) {
      final pending = await Outbox(_db).unsyncedCount();
      if (pending > 0) {
        // Never mix accounts and never drop another person's unsent records.
        final email = await _db.getKv(KvKeys.boundEmail) ?? '';
        await _signOutQuietly();
        _set(BootOtherUserPending(email));
        return;
      }
      await _db.wipeAll();
    }

    final farmId = await _db.getKv(KvKeys.farmId);
    final initialized = await _db.getKv(KvKeys.initialSyncDone) != null;
    if (farmId != null && initialized && boundUser == user.id) {
      final skew = int.tryParse(await _db.getKv(KvKeys.serverSkewMs) ?? '');
      if (skew != null) AppClock.skew = Duration(milliseconds: skew);
      _set(BootReady(AppSession(userId: user.id, email: user.email ?? '', farmId: farmId)));
      return;
    }

    // First-time setup on this device: requires the server.
    final Map<String, dynamic> ctx;
    try {
      ctx = await _remote!.getMyContext();
    } on RemoteError catch (e) {
      if (e.kind == RemoteErrorKind.auth) {
        await _signOutQuietly();
        _set(const BootSignedOut());
      } else {
        _set(const BootNeedsInternet());
      }
      return;
    }
    final memberships = (ctx['memberships'] as List).cast<Map<String, dynamic>>();
    final active = memberships
        .where((m) => m['status'] == 'active' && const ['owner', 'admin', 'member'].contains(m['role']))
        .toList();
    if (active.isEmpty) {
      final invitations = (ctx['invitations'] as List)
          .cast<Map<String, dynamic>>()
          .map((i) => Invitation(i['member_id'] as String, i['farm_name'] as String, i['full_name'] as String))
          .toList();
      _set(BootOnboarding(email: user.email ?? '', invitations: invitations));
      return;
    }

    final chosenFarm = active.first['farm_id'] as String;
    await _db.setKv(KvKeys.boundUserId, user.id);
    await _db.setKv(KvKeys.boundEmail, user.email);
    await _db.setKv(KvKeys.farmId, chosenFarm);
    _set(const BootLoading(preparing: true));

    final engine = SyncEngine(db: _db, remote: _remote!, farmId: chosenFarm, userId: user.id, autoRetry: false);
    try {
      await engine.init();
      await engine.sync();
    } finally {
      engine.dispose();
    }
    if (await _db.getKv(KvKeys.initialSyncDone) == null) {
      _set(const BootNeedsInternet());
      return;
    }
    _set(BootReady(AppSession(userId: user.id, email: user.email ?? '', farmId: chosenFarm)));
  }

  Future<void> _signOutQuietly() async {
    try {
      await _client?.auth.signOut(scope: SignOutScope.local);
    } catch (_) {
      // The local session is removed before the network call; offline is fine.
    }
  }

  // ---------------------------------------------------------------------------
  // Actions used by the auth/onboarding screens
  // ---------------------------------------------------------------------------

  Future<void> signIn(String email, String password) async {
    await _client!.auth.signInWithPassword(email: email.trim(), password: password);
    await evaluate();
  }

  /// Returns true when the account still needs email confirmation.
  Future<bool> signUp(String email, String password) async {
    final res = await _client!.auth.signUp(email: email.trim(), password: password);
    if (res.session != null) {
      await evaluate();
      return false;
    }
    return true;
  }

  Future<void> verifySignupCode(String email, String code) async {
    await _client!.auth.verifyOTP(type: OtpType.signup, email: email.trim(), token: code.trim());
    await evaluate();
  }

  Future<void> sendPasswordReset(String email) => _client!.auth.resetPasswordForEmail(email.trim());

  Future<void> completePasswordReset(String email, String code, String newPassword) async {
    await _client!.auth.verifyOTP(type: OtpType.recovery, email: email.trim(), token: code.trim());
    await _client!.auth.updateUser(UserAttributes(password: newPassword));
    await evaluate();
  }

  Future<void> createFarm({required String farmName, required String fullName, String? displayNameKn}) async {
    await _remote!.createFarm(
      farmId: newId(),
      farmName: farmName.trim(),
      fullName: fullName.trim(),
      displayNameKn: displayNameKn,
    );
    await evaluate();
  }

  Future<void> acceptInvitation(Invitation inv, {required String fullName, String? displayNameKn}) async {
    await _remote!.acceptInvitation(memberId: inv.memberId, fullName: fullName.trim(), displayNameKn: displayNameKn);
    await evaluate();
  }

  /// Signs out. Data is wiped only when everything has reached the cloud;
  /// otherwise it stays (bound to this account) for the next sign-in.
  Future<void> signOut() async {
    final pending = await Outbox(_db).unsyncedCount();
    if (pending == 0) await _db.wipeAll();
    await _signOutQuietly();
    _set(const BootSignedOut());
  }
}
