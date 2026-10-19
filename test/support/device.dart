import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:shramasiri/core/dates.dart';
import 'package:shramasiri/data/db/database.dart';
import 'package:shramasiri/data/repositories/attendance_repo.dart';
import 'package:shramasiri/data/repositories/ledger_repo.dart';
import 'package:shramasiri/data/repositories/repo_base.dart';
import 'package:shramasiri/data/repositories/settlement_repo.dart';
import 'package:shramasiri/data/repositories/workers_repo.dart';
import 'package:shramasiri/data/sync/conflict_resolver.dart';
import 'package:shramasiri/data/sync/outbox.dart';
import 'package:shramasiri/data/sync/sync_engine.dart';

import 'fake_server.dart';

/// A simulated phone: its own SQLite file, outbox and sync engine.
class TestDevice {
  TestDevice._(this.name, this.server, this.userId, this.file);

  static Future<TestDevice> create(String name, FakeServer server, String userId) async {
    // Several simulated phones, each with its own file, is intentional here.
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final dir = await Directory.systemTemp.createTemp('shramasiri_$name');
    final d = TestDevice._(name, server, userId, File('${dir.path}/db.sqlite'));
    d.remote = FakeRemote(server, userId);
    await d._open();
    await d.db.setKv(KvKeys.deviceId, 'device-$name');
    await d.db.setKv(KvKeys.boundUserId, userId);
    await d.db.setKv(KvKeys.farmId, server.farmId);
    await d.db.setKv(KvKeys.lastVerifiedAt, AppClock.nowUtc().toIso8601String());
    return d;
  }

  final String name;
  final FakeServer server;
  final String userId;
  final File file;
  late FakeRemote remote;
  late AppDatabase db;
  late SyncEngine engine;
  late RepoContext ctx;

  Future<void> _open() async {
    db = AppDatabase(NativeDatabase(file));
    final outbox = Outbox(db);
    ctx = RepoContext(db: db, outbox: outbox, farmId: server.farmId, userId: userId, deviceId: 'device-$name');
    engine = SyncEngine(
      db: db,
      remote: remote,
      farmId: server.farmId,
      userId: userId,
      outbox: outbox,
      autoRetry: false,
    );
    await engine.init();
  }

  /// Simulates the app being killed and started again.
  Future<void> restart() async {
    engine.dispose();
    await db.close();
    await _open();
  }

  Future<void> dispose() async {
    engine.dispose();
    await db.close();
    try {
      await file.parent.delete(recursive: true);
    } on FileSystemException {
      // Windows may hold the file briefly; temp cleanup is best effort.
    }
  }

  set online(bool v) => remote.online = v;

  Future<void> sync() => engine.sync();

  WorkersRepo get workers => WorkersRepo(ctx);
  AttendanceRepo get attendance => AttendanceRepo(ctx);
  LedgerRepo get ledger => LedgerRepo(ctx);
  SettlementRepo get settlements => SettlementRepo(ctx);
  ConflictResolver get resolver => ConflictResolver(db, ctx.outbox);

  Future<List<OutboxOp>> ops([String? status]) {
    final q = db.select(db.outboxOps);
    if (status != null) q.where((o) => o.status.equals(status));
    return q.get();
  }

  Future<int> unsynced() => ctx.outbox.unsyncedCount();

  Future<List<LedgerEntry>> entries() => db.select(db.financialTransactions).get();

  Future<List<AttendanceRow>> attendanceRows() => db.select(db.attendance).get();
}
