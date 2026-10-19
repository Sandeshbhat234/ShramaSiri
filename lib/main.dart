import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'core/config.dart';
import 'core/ids.dart';
import 'data/db/database.dart';
import 'data/remote/secure_session_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kReleaseMode) debugPrint = (String? message, {int? wrapWidth}) {};

  final AppDatabase db;
  try {
    db = AppDatabase.open();
    // Touch the schema so a damaged or incompatible file fails here.
    await db.customSelect('SELECT COUNT(*) FROM outbox_ops').get();
  } catch (e) {
    runApp(DatabaseErrorApp(error: e));
    return;
  }

  var deviceId = await db.getKv(KvKeys.deviceId);
  if (deviceId == null) {
    deviceId = newId();
    await db.setKv(KvKeys.deviceId, deviceId);
  }
  final locale = await db.getKv(KvKeys.locale) ?? 'kn';

  SupabaseClient? client;
  if (AppConfig.isConfigured) {
    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        publishableKey: AppConfig.supabaseKey,
        authOptions: const FlutterAuthClientOptions(localStorage: SecureSessionStorage(), detectSessionInUri: false),
        debug: false,
      );
      client = Supabase.instance.client;
    } catch (e) {
      debugPrint('Supabase init failed: $e');
    }
  }

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        supabaseProvider.overrideWithValue(client),
        deviceIdProvider.overrideWithValue(deviceId),
        initialLocaleProvider.overrideWithValue(locale),
      ],
      child: const ShramaSiriApp(),
    ),
  );
}

/// Shown when the local database cannot be opened. Offers to move the
/// damaged file aside (it is kept, not deleted) and start fresh; synced data
/// downloads again after sign-in.
class DatabaseErrorApp extends StatefulWidget {
  const DatabaseErrorApp({super.key, required this.error});

  final Object error;

  @override
  State<DatabaseErrorApp> createState() => _DatabaseErrorAppState();
}

class _DatabaseErrorAppState extends State<DatabaseErrorApp> {
  bool _busy = false;
  String? _done;

  Future<void> _backupAndReset() async {
    setState(() => _busy = true);
    final dir = await getApplicationDocumentsDirectory();
    final stamp = DateTime.now().toUtc().toIso8601String().replaceAll(':', '-');
    for (final suffix in ['', '-wal', '-shm']) {
      final f = File('${dir.path}/shramasiri.sqlite$suffix');
      if (await f.exists()) await f.rename('${dir.path}/shramasiri-damaged-$stamp.sqlite$suffix');
    }
    setState(() {
      _busy = false;
      _done = '${dir.path}/shramasiri-damaged-$stamp.sqlite';
    });
  }

  @override
  Widget build(BuildContext context) {
    // Shown before localization is available: bilingual on purpose.
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Icon(Icons.storage, size: 56),
              const SizedBox(height: 16),
              const Text(
                'ಉಳಿಸಿದ ಮಾಹಿತಿ ತೆರೆಯಲಾಗಲಿಲ್ಲ\nCould not open saved data',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              const Text(
                'ಫೈಲಿನ ಬ್ಯಾಕಪ್ ಇಟ್ಟು ಹೊಸದಾಗಿ ಆರಂಭಿಸಬಹುದು. ಸಿಂಕ್ ಆದ ದಾಖಲೆಗಳು ಮತ್ತೆ ಬರುತ್ತವೆ.\n'
                'You can keep a backup of the file and start fresh. Synced records will download again.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17),
              ),
              const SizedBox(height: 12),
              Text('${widget.error}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
              const SizedBox(height: 24),
              if (_done == null)
                FilledButton(
                  onPressed: _busy ? null : _backupAndReset,
                  child: const Text('ಬ್ಯಾಕಪ್ ಇಟ್ಟು ಹೊಸದಾಗಿ ಆರಂಭಿಸಿ / Back up and start fresh'),
                )
              else ...[
                Text('Backup: $_done', style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 12),
                const FilledButton(onPressed: main, child: Text('ಮುಂದುವರಿಸಿ / Continue')),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
