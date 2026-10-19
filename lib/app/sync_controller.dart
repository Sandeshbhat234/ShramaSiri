import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config.dart';
import '../data/sync/sync_engine.dart';

/// Decides *when* to sync: on start, on resume, when connectivity returns,
/// shortly after local writes, on Realtime change signals, and periodically
/// while the app is in the foreground. The engine guarantees only one cycle
/// runs at a time; bursts are debounced here.
///
/// Realtime is only a hint to pull sooner. Missing a Realtime message is
/// harmless because every cycle pulls from the persisted cursor.
class SyncController {
  SyncController({required this.engine, required this.client, required this.farmId});

  final SyncEngine engine;
  final SupabaseClient? client;
  final String farmId;

  AppLifecycleListener? _lifecycle;
  StreamSubscription<List<ConnectivityResult>>? _connectivity;
  RealtimeChannel? _channel;
  Timer? _periodic;
  Timer? _debounce;
  bool _started = false;
  bool _foreground = true;

  Future<void> start() async {
    if (_started) return;
    _started = true;
    await engine.init();
    _lifecycle = AppLifecycleListener(
      onResume: () {
        _foreground = true;
        _startPeriodic();
        _subscribeRealtime();
        engine.sync();
      },
      onPause: () {
        _foreground = false;
        _periodic?.cancel();
      },
    );
    _connectivity = Connectivity().onConnectivityChanged.listen((results) {
      // Connectivity is only a hint; the engine verifies the server itself.
      if (results.any((r) => r != ConnectivityResult.none)) _schedule(const Duration(seconds: 2));
    });
    _startPeriodic();
    _subscribeRealtime();
    unawaited(engine.sync());
  }

  /// Called after each local write.
  void nudge() => _schedule(const Duration(milliseconds: 1500));

  void _schedule(Duration delay) {
    _debounce?.cancel();
    _debounce = Timer(delay, () => engine.sync());
  }

  void _startPeriodic() {
    _periodic?.cancel();
    _periodic = Timer.periodic(AppConfig.periodicSync, (_) {
      if (_foreground) engine.sync();
    });
  }

  void _subscribeRealtime() {
    final c = client;
    if (c == null || _channel != null) return;
    _channel = c
        .channel('farm-sync-$farmId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'farm_sync_state',
          filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'farm_id', value: farmId),
          callback: (_) => _schedule(const Duration(seconds: 1)),
        )
        .subscribe();
  }

  void dispose() {
    _lifecycle?.dispose();
    _connectivity?.cancel();
    _periodic?.cancel();
    _debounce?.cancel();
    final ch = _channel;
    if (ch != null) client?.removeChannel(ch);
  }
}
