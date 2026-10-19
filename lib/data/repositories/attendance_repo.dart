import 'package:drift/drift.dart';

import '../../core/ids.dart';
import '../../core/money.dart';
import '../db/database.dart';
import '../sync/outbox.dart';
import 'repo_base.dart';

/// What the user chose for one worker on one day.
class AttendanceMark {
  const AttendanceMark({required this.workerId, required this.unitsMilli, required this.ratePaise, this.notes});

  final String workerId;
  final int unitsMilli;
  final int ratePaise;
  final String? notes;
}

class DaySummary {
  const DaySummary({required this.date, required this.workers, required this.unitsMilli, required this.earnedPaise});

  final String date;
  final int workers;
  final int unitsMilli;
  final int earnedPaise;
}

class AttendanceRepo {
  AttendanceRepo(this.r);

  final RepoContext r;
  AppDatabase get db => r.db;

  Stream<List<AttendanceRow>> watchDay(String date) =>
      (db.select(db.attendance)..where((a) => a.farmId.equals(r.farmId) & a.workDate.equals(date))).watch();

  Future<List<AttendanceRow>> getDay(String date) =>
      (db.select(db.attendance)..where((a) => a.farmId.equals(r.farmId) & a.workDate.equals(date))).get();

  /// Saves the marks for a day. Only changed workers produce operations.
  /// Unmarking a previously present worker records 0 units (absent) rather
  /// than deleting, so the change syncs and stays auditable.
  /// Returns the number of changed records.
  Future<int> saveDay(String date, List<AttendanceMark> marks) async {
    r.validateDate(date);
    for (final m in marks) {
      if (m.unitsMilli < 0 || m.unitsMilli > Units.max) throw const AppException('invalid_units');
      if (m.ratePaise < 0 || m.ratePaise > 10000000) throw const AppException('invalid_amount');
    }
    return r.write((ctx) async {
      final existing = {for (final a in await getDay(date)) a.workerId: a};
      final now = DateTime.now().toUtc();
      var changed = 0;
      for (final m in marks) {
        final old = existing[m.workerId];
        final notes = r.clean(m.notes, max: 300);
        if (old == null && m.unitsMilli == 0) continue;
        if (old != null && old.unitsMilli == m.unitsMilli && old.ratePaise == m.ratePaise && old.notes == notes) {
          continue;
        }
        if (changed == 0) await r.guardPeriod(ctx, date);
        final earned = Units.earned(m.ratePaise, m.unitsMilli);
        final String id;
        if (old == null) {
          id = newId();
          await db
              .into(db.attendance)
              .insert(
                AttendanceCompanion.insert(
                  id: id,
                  farmId: r.farmId,
                  workerId: m.workerId,
                  workDate: date,
                  unitsMilli: m.unitsMilli,
                  ratePaise: m.ratePaise,
                  earnedPaise: earned,
                  notes: Value(notes),
                  recordedBy: ctx.userId,
                  updatedBy: ctx.userId,
                  sourceDeviceId: Value(ctx.deviceId),
                  createdAt: now,
                  updatedAt: now,
                ),
              );
        } else {
          id = old.id;
          await (db.update(db.attendance)..where((a) => a.id.equals(id))).write(
            AttendanceCompanion(
              unitsMilli: Value(m.unitsMilli),
              ratePaise: Value(m.ratePaise),
              earnedPaise: Value(earned),
              notes: Value(notes),
              updatedBy: Value(ctx.userId),
              sourceDeviceId: Value(ctx.deviceId),
              updatedAt: Value(now),
            ),
          );
        }
        await r.outbox.enqueue(
          ctx,
          opType: OpTypes.attendanceUpsert,
          entityTable: 'attendance',
          entityId: id,
          coalesce: true,
          payload: {
            'id': id,
            'worker_id': m.workerId,
            'work_date': date,
            'units_milli': m.unitsMilli,
            'rate_paise': m.ratePaise,
            'notes': notes,
          },
        );
        changed++;
      }
      return changed;
    });
  }

  /// Recent days with attendance, newest first (paged).
  Stream<List<DaySummary>> watchRecentDays({int limit = 30, int offset = 0}) {
    return db
        .customSelect(
          'SELECT work_date, COUNT(*) AS workers, SUM(units_milli) AS units, SUM(earned_paise) AS earned '
          'FROM attendance WHERE farm_id = ? AND units_milli > 0 AND sync_status <> 3 '
          'GROUP BY work_date ORDER BY work_date DESC LIMIT ? OFFSET ?',
          variables: [Variable(r.farmId), Variable(limit), Variable(offset)],
          readsFrom: {db.attendance},
        )
        .watch()
        .map(
          (rows) => rows
              .map(
                (row) => DaySummary(
                  date: row.read<String>('work_date'),
                  workers: row.read<int>('workers'),
                  unitsMilli: row.read<int>('units'),
                  earnedPaise: row.read<int>('earned'),
                ),
              )
              .toList(),
        );
  }

  /// A worker's attendance, newest first (paged).
  Stream<List<AttendanceRow>> watchWorkerHistory(String workerId, {int limit = 60, int offset = 0}) =>
      (db.select(db.attendance)
            ..where((a) => a.workerId.equals(workerId) & a.unitsMilli.isBiggerThanValue(0))
            ..orderBy([(a) => OrderingTerm.desc(a.workDate)])
            ..limit(limit, offset: offset))
          .watch();
}
