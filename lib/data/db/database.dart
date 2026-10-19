import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

export 'tables.dart';

part 'database.g.dart';

/// Row sync states stored in each mirrored table's `sync_status` column.
abstract final class RowSync {
  static const synced = 0;
  static const pending = 1;
  static const needsReview = 2;
  static const rejected = 3;
}

/// Parses server JSON (ISO timestamps, numbers that may arrive as strings for
/// very large bigints) and writes JSON the same way.
class ServerJsonSerializer extends ValueSerializer {
  const ServerJsonSerializer();

  @override
  T fromJson<T>(dynamic json) {
    if (json == null) return null as T;
    final typeList = <T>[];
    if (typeList is List<DateTime?>) {
      if (json is int) return DateTime.fromMillisecondsSinceEpoch(json, isUtc: true) as T;
      return DateTime.parse(json as String).toUtc() as T;
    }
    if (typeList is List<int?>) {
      if (json is int) return json as T;
      if (json is num) return json.toInt() as T;
      return int.parse(json.toString()) as T;
    }
    if (typeList is List<bool?>) {
      if (json is bool) return json as T;
      if (json is int) return (json != 0) as T;
      return (json.toString() == 'true') as T;
    }
    if (typeList is List<String?>) {
      if (json is String) return json as T;
      // jsonb columns (audit before/after) are stored locally as text.
      return jsonEncode(json) as T;
    }
    return json as T;
  }

  @override
  dynamic toJson<T>(T value) {
    if (value is DateTime) return value.toUtc().toIso8601String();
    return value;
  }
}

const serverJson = ServerJsonSerializer();

@DriftDatabase(
  tables: [
    Farms,
    FarmMembers,
    Workers,
    WorkerGroups,
    WorkerGroupMemberships,
    Attendance,
    WorkTypes,
    WorkAssignments,
    WorkAssignmentWorkers,
    FinancialTransactions,
    Settlements,
    SettlementItems,
    AuditEvents,
    OutboxOps,
    ServerShadows,
    KvEntries,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// Opens the on-device database file.
  factory AppDatabase.open() => AppDatabase(driftDatabase(name: 'shramasiri'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // Add stepwise migrations here when schemaVersion increases.
      // Never drop outbox_ops or rows with sync_status != 0.
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = OFF');
    },
  );

  // ---------------------------------------------------------------------------
  // Key/value settings
  // ---------------------------------------------------------------------------

  Future<String?> getKv(String key) async {
    final row = await (select(kvEntries)..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> setKv(String key, String? value) async {
    if (value == null) {
      await (delete(kvEntries)..where((t) => t.key.equals(key))).go();
    } else {
      await into(kvEntries).insertOnConflictUpdate(KvEntry(key: key, value: value));
    }
  }

  Stream<String?> watchKv(String key) {
    return (select(kvEntries)..where((t) => t.key.equals(key))).watchSingleOrNull().map((r) => r?.value);
  }

  /// Removes all farm data and sync state. Used only after confirming there
  /// are no unsynced operations (or after explicit user confirmation).
  Future<void> wipeAll({bool keepDeviceSettings = true}) async {
    await transaction(() async {
      for (final table in allTables) {
        if (table == kvEntries) continue;
        await delete(table).go();
      }
      if (keepDeviceSettings) {
        await (delete(kvEntries)..where((t) => t.key.isNotIn(KvKeys.deviceScoped))).go();
      } else {
        await delete(kvEntries).go();
      }
    });
  }
}

abstract final class KvKeys {
  static const deviceId = 'device_id';
  static const locale = 'locale';
  static const boundUserId = 'bound_user_id';
  static const boundEmail = 'bound_email';
  static const farmId = 'farm_id';
  static const pullCursor = 'pull_cursor';
  static const initialSyncDone = 'initial_sync_done';
  static const lastSyncAt = 'last_sync_at';
  static const lastVerifiedAt = 'last_verified_at';
  static const accessRevoked = 'access_revoked';
  static const serverSkewMs = 'server_skew_ms';

  /// Survive a data wipe (sign-out) because they describe the device itself.
  static const deviceScoped = [deviceId, locale];
}
