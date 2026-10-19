import 'package:drift/drift.dart';

import '../../core/dates.dart';
import '../../core/ids.dart';
import '../../core/money.dart';
import '../../domain/ledger.dart';
import '../db/database.dart';
import '../sync/outbox.dart';
import 'repo_base.dart';

abstract final class PayMethod {
  static const cash = 'cash';
  static const upi = 'upi';
  static const bank = 'bank';
  static const other = 'other';
  static const none = 'none';
  static const all = [cash, upi, bank, other];
}

class EntryDraft {
  EntryDraft({
    required this.type,
    required this.workerId,
    required this.amountPaise,
    required this.businessDate,
    this.occurredAt,
    this.leaderWorkerId,
    this.method = PayMethod.cash,
    this.paidBy,
    this.notes,
    this.reference,
    this.relatedEntryId,
  });

  final EntryType type;
  final String workerId;
  final int amountPaise;
  final String businessDate;
  final DateTime? occurredAt;
  final String? leaderWorkerId;
  final String method;

  /// Family member (user id) who physically handed over / received the cash.
  /// Defaults to the person recording.
  final String? paidBy;
  final String? notes;
  final String? reference;
  final String? relatedEntryId;
}

class WorkerBalance {
  const WorkerBalance({required this.workerId, this.wagePaise = 0, this.loanPaise = 0, this.hasPending = false});

  final String workerId;

  /// Positive: farm owes wages. Negative: worker has been paid ahead (advance).
  final int wagePaise;

  /// Personal loan still owed by the worker.
  final int loanPaise;

  /// Includes entries not yet confirmed by the server.
  final bool hasPending;
}

class LeaderFund {
  const LeaderFund({
    required this.leaderId,
    this.entrustedPaise = 0,
    this.distributedPaise = 0,
    this.returnedPaise = 0,
    this.pendingDistributedPaise = 0,
    this.ownPocketOwedPaise = 0,
  });

  final String leaderId;
  final int entrustedPaise;
  final int distributedPaise;
  final int returnedPaise;

  /// Distributions saved on this device and not yet verified by the server.
  final int pendingDistributedPaise;

  /// Wages the leader paid others from their own money, not yet repaid.
  final int ownPocketOwedPaise;

  /// Money still with the leader that is not yet accounted for.
  int get unreconciledPaise => entrustedPaise - distributedPaise - returnedPaise;
}

class LedgerFilter {
  const LedgerFilter({this.workerId, this.from, this.to, this.paidBy, this.types, this.cashOnly = false});

  final String? workerId;
  final String? from;
  final String? to;
  final String? paidBy;
  final List<EntryType>? types;
  final bool cashOnly;

  @override
  bool operator ==(Object other) =>
      other is LedgerFilter &&
      other.workerId == workerId &&
      other.from == from &&
      other.to == to &&
      other.paidBy == paidBy &&
      other.cashOnly == cashOnly &&
      (other.types?.join(',') ?? '') == (types?.join(',') ?? '');

  @override
  int get hashCode => Object.hash(workerId, from, to, paidBy, cashOnly, types?.join(','));
}

class LedgerRepo {
  LedgerRepo(this.r);

  final RepoContext r;
  AppDatabase get db => r.db;

  // ---------------------------------------------------------------------------
  // Writes
  // ---------------------------------------------------------------------------

  Future<String> create(EntryDraft d) async {
    _validateShape(d);
    return r.write((ctx) async {
      final id = newId();
      final row = await _prepare(ctx, id, d);
      await db.into(db.financialTransactions).insert(row);
      await r.outbox.enqueue(
        ctx,
        opType: OpTypes.ledgerCreate,
        entityTable: 'financial_transactions',
        entityId: id,
        payload: _payload(row),
      );
      return id;
    });
  }

  /// Cancels an entry with an explicit reversal; the original stays visible.
  Future<String> reverse(LedgerEntry original, String reason) async {
    final why = r.clean(reason);
    if (why == null) throw const AppException('reason_required');
    return r.write((ctx) async {
      final reversal = await _prepareReversal(ctx, original, why);
      await db.into(db.financialTransactions).insert(reversal);
      await r.outbox.enqueue(
        ctx,
        opType: OpTypes.ledgerReverse,
        entityTable: 'financial_transactions',
        entityId: reversal.id,
        payload: {'id': reversal.id, 'reverses_id': original.id, 'reason': why},
      );
      return reversal.id;
    });
  }

  /// Reverses [original] and records [replacement] atomically.
  Future<String> correct(LedgerEntry original, EntryDraft replacement, String reason) async {
    final why = r.clean(reason);
    if (why == null) throw const AppException('reason_required');
    _validateShape(replacement);
    return r.write((ctx) async {
      final reversal = await _prepareReversal(ctx, original, why);
      await db.into(db.financialTransactions).insert(reversal);
      final id = newId();
      final row = await _prepare(ctx, id, replacement);
      await db.into(db.financialTransactions).insert(row);
      await r.outbox.enqueue(
        ctx,
        opType: OpTypes.ledgerCorrect,
        entityTable: 'financial_transactions',
        entityId: id,
        payload: {
          'reverse': {'id': reversal.id, 'reverses_id': original.id, 'reason': why},
          'create': _payload(row),
        },
      );
      await r.outbox.mirrorStatus('financial_transactions', id, reversal.id);
      return id;
    });
  }

  void _validateShape(EntryDraft d) {
    final opening = d.type == EntryType.openingBalance;
    if (d.amountPaise == 0 || d.amountPaise.abs() > Money.maxEntryPaise || (!opening && d.amountPaise < 0)) {
      throw const AppException('invalid_amount');
    }
    r.validateDate(d.businessDate);
    if (d.type.needsLeader && d.leaderWorkerId == null) throw const AppException('leader_required');
    if (d.type.isCash && !PayMethod.all.contains(d.method)) throw const AppException('invalid_method');
  }

  Future<FinancialTransactionsCompanion> _prepare(WriteContext ctx, String id, EntryDraft d) async {
    final worker = await (db.select(
      db.workers,
    )..where((w) => w.id.equals(d.workerId) & w.farmId.equals(r.farmId))).getSingleOrNull();
    if (worker == null) throw const AppException('invalid_worker');

    String? paidBy;
    String? paidByName;
    if (d.type.isCash) {
      paidBy = d.paidBy ?? ctx.userId;
      final payer = await (db.select(
        db.farmMembers,
      )..where((m) => m.farmId.equals(r.farmId) & m.userId.equals(paidBy!))).getSingleOrNull();
      if (payer == null) throw const AppException('invalid_payer');
      paidByName = payer.fullName;
    }

    final leaderId = d.type.needsLeader ? d.leaderWorkerId : null;
    final mustBeLeader = switch (d.type) {
      EntryType.leaderTransfer || EntryType.leaderReturn => d.workerId,
      EntryType.leaderAllocation || EntryType.leaderSelfFunded => leaderId,
      _ => null,
    };
    if (mustBeLeader != null) {
      final leader = await (db.select(db.workers)..where((w) => w.id.equals(mustBeLeader))).getSingleOrNull();
      if (leader == null || !leader.isLeader) throw const AppException('not_a_leader');
    }

    switch (d.type) {
      case EntryType.leaderAllocation:
      case EntryType.leaderReturn:
        final leader = d.type == EntryType.leaderAllocation ? leaderId! : d.workerId;
        final available = (await leaderFund(leader)).unreconciledPaise;
        if (d.amountPaise > available) {
          throw AppException('insufficient_leader_funds', {'available': available});
        }
      case EntryType.loanRepayment:
      case EntryType.loanOffset:
        final loan = await loanBalance(d.workerId);
        if (d.amountPaise > loan) throw AppException('exceeds_loan_balance', {'available': loan});
      case EntryType.reimbursement when d.relatedEntryId != null:
        final owed = (await leaderFund(d.workerId)).ownPocketOwedPaise;
        if (d.amountPaise > owed) throw AppException('exceeds_leader_payable', {'available': owed});
      default:
        break;
    }

    if (d.type.affectsWages) await r.guardPeriod(ctx, d.businessDate);

    final now = DateTime.now().toUtc();
    return FinancialTransactionsCompanion.insert(
      id: id,
      farmId: r.farmId,
      entryType: d.type.code,
      workerId: d.workerId,
      leaderWorkerId: Value(leaderId),
      amountPaise: d.amountPaise,
      relatedEntryId: Value(d.relatedEntryId),
      businessDate: d.businessDate,
      occurredAt: (d.occurredAt ?? AppClock.nowUtc()).toUtc(),
      method: d.type.isCash ? d.method : PayMethod.none,
      reference: Value(r.clean(d.reference, max: 100)),
      notes: Value(r.clean(d.notes)),
      paidBy: Value(paidBy),
      paidByName: Value(paidByName),
      recordedBy: ctx.userId,
      recordedByName: ctx.actorName,
      sourceDeviceId: Value(ctx.deviceId),
      createdAt: now,
      syncStatus: const Value(RowSync.pending),
    );
  }

  Map<String, dynamic> _payload(FinancialTransactionsCompanion c) => {
    'id': c.id.value,
    'entry_type': c.entryType.value,
    'worker_id': c.workerId.value,
    'leader_worker_id': c.leaderWorkerId.value,
    'amount_paise': c.amountPaise.value,
    'business_date': c.businessDate.value,
    'occurred_at': c.occurredAt.value.toIso8601String(),
    'method': c.method.value,
    'reference': c.reference.value,
    'notes': c.notes.value,
    'paid_by': c.paidBy.value,
    'related_entry_id': c.relatedEntryId.value,
  };

  Future<LedgerEntry> _prepareReversal(WriteContext ctx, LedgerEntry original, String reason) async {
    if (original.isReversal) throw const AppException('cannot_reverse_reversal');
    final already = await (db.select(
      db.financialTransactions,
    )..where((f) => f.reversesId.equals(original.id) & f.syncStatus.isNotValue(RowSync.rejected))).getSingleOrNull();
    if (already != null) throw const AppException('already_reversed');
    if (!ctx.isAdmin && original.recordedBy != ctx.userId) throw const AppException('forbidden');

    final type = EntryType.fromCode(original.entryType);
    switch (type) {
      case EntryType.leaderTransfer:
        final fund = await leaderFund(original.workerId);
        if (fund.unreconciledPaise < original.amountPaise) {
          throw AppException('leader_funds_already_used', {'available': fund.unreconciledPaise});
        }
      case EntryType.loan:
        if (await loanBalance(original.workerId) < original.amountPaise) {
          throw const AppException('loan_already_repaid');
        }
      case EntryType.leaderSelfFunded:
        if ((await leaderFund(original.leaderWorkerId!)).ownPocketOwedPaise < original.amountPaise) {
          throw const AppException('leader_payable_already_settled');
        }
      default:
        break;
    }
    if (type.affectsWages) await r.guardPeriod(ctx, original.businessDate);

    final now = DateTime.now().toUtc();
    return LedgerEntry(
      id: newId(),
      farmId: r.farmId,
      entryType: original.entryType,
      workerId: original.workerId,
      leaderWorkerId: original.leaderWorkerId,
      amountPaise: original.amountPaise,
      isReversal: true,
      reversesId: original.id,
      relatedEntryId: original.relatedEntryId,
      businessDate: original.businessDate,
      occurredAt: AppClock.nowUtc(),
      method: original.method,
      reference: original.reference,
      notes: reason,
      paidBy: original.paidBy,
      paidByName: original.paidByName,
      recordedBy: ctx.userId,
      recordedByName: ctx.actorName,
      sourceDeviceId: ctx.deviceId,
      createdAt: now,
      serverSeq: 0,
      syncStatus: RowSync.pending,
    );
  }

  // ---------------------------------------------------------------------------
  // Reads
  // ---------------------------------------------------------------------------

  Stream<LedgerEntry?> watchEntry(String id) =>
      (db.select(db.financialTransactions)..where((f) => f.id.equals(id))).watchSingleOrNull();

  /// The reversal of [id], if any (excluding ones the server rejected).
  Stream<LedgerEntry?> watchReversalOf(String id) => (db.select(
    db.financialTransactions,
  )..where((f) => f.reversesId.equals(id) & f.syncStatus.isNotValue(RowSync.rejected))).watchSingleOrNull();

  Stream<List<LedgerEntry>> watchEntries(LedgerFilter f, {int limit = 50, int offset = 0}) {
    final q = db.select(db.financialTransactions)..where((x) => x.farmId.equals(r.farmId));
    if (f.workerId != null) {
      q.where((x) => x.workerId.equals(f.workerId!) | x.leaderWorkerId.equals(f.workerId!));
    }
    if (f.from != null) q.where((x) => x.businessDate.isBiggerOrEqualValue(f.from!));
    if (f.to != null) q.where((x) => x.businessDate.isSmallerOrEqualValue(f.to!));
    if (f.paidBy != null) q.where((x) => x.paidBy.equals(f.paidBy!));
    if (f.types != null) q.where((x) => x.entryType.isIn(f.types!.map((t) => t.code)));
    if (f.cashOnly) q.where((x) => x.method.isNotValue(PayMethod.none));
    q
      ..orderBy([(x) => OrderingTerm.desc(x.businessDate), (x) => OrderingTerm.desc(x.occurredAt)])
      ..limit(limit, offset: offset);
    return q.watch();
  }

  /// Ids of entries that have a (non-rejected) reversal.
  Stream<Set<String>> watchReversedIds() => db
      .customSelect(
        'SELECT reverses_id FROM financial_transactions WHERE farm_id = ? AND reverses_id IS NOT NULL AND sync_status <> 3',
        variables: [Variable(r.farmId)],
        readsFrom: {db.financialTransactions},
      )
      .watch()
      .map((rows) => rows.map((row) => row.read<String>('reverses_id')).toSet());

  /// A similar entry recorded recently: same worker, type and amount, in the
  /// last 30 minutes or on the same business date.
  Future<LedgerEntry?> findSimilarRecent(EntryDraft d) async {
    final since = DateTime.now().toUtc().subtract(const Duration(minutes: 30));
    return (db.select(db.financialTransactions)
          ..where(
            (f) =>
                f.farmId.equals(r.farmId) &
                f.workerId.equals(d.workerId) &
                f.entryType.equals(d.type.code) &
                f.amountPaise.equals(d.amountPaise) &
                f.isReversal.equals(false) &
                (f.createdAt.isBiggerOrEqualValue(since) | f.businessDate.equals(d.businessDate)),
          )
          ..limit(1))
        .getSingleOrNull();
  }

  static final _wageNet = LedgerSql.wageNet;
  static final _loan = LedgerSql.effect((e) => e.loan);

  String _balanceSql({required bool single}) =>
      '''
SELECT w.id AS worker_id,
  (SELECT COALESCE(SUM(a.earned_paise), 0) FROM attendance a
     WHERE a.farm_id = w.farm_id AND a.worker_id = w.id AND a.work_date <= ?1 AND a.sync_status <> 3)
  + (SELECT COALESCE(SUM($_wageNet), 0) FROM financial_transactions
     WHERE farm_id = w.farm_id AND worker_id = w.id AND business_date <= ?1 AND sync_status <> 3) AS wage,
  (SELECT COALESCE(SUM($_loan), 0) FROM financial_transactions
     WHERE farm_id = w.farm_id AND worker_id = w.id AND sync_status <> 3) AS loan,
  (EXISTS (SELECT 1 FROM financial_transactions WHERE worker_id = w.id AND sync_status IN (1, 2))
   OR EXISTS (SELECT 1 FROM attendance WHERE worker_id = w.id AND sync_status IN (1, 2))) AS pending
FROM workers w WHERE w.farm_id = ?2 ${single ? 'AND w.id = ?3' : ''}''';

  WorkerBalance _readBalance(QueryRow row) => WorkerBalance(
    workerId: row.read<String>('worker_id'),
    wagePaise: row.read<int>('wage'),
    loanPaise: row.read<int>('loan'),
    hasPending: row.read<int>('pending') != 0,
  );

  /// Balances for every worker as of [asOf] (inclusive), default today.
  Stream<Map<String, WorkerBalance>> watchBalances({String? asOf}) => db
      .customSelect(
        _balanceSql(single: false),
        variables: [Variable(asOf ?? '9999-12-31'), Variable(r.farmId)],
        readsFrom: {db.attendance, db.financialTransactions, db.workers},
      )
      .watch()
      .map((rows) => {for (final row in rows) row.read<String>('worker_id'): _readBalance(row)});

  Stream<WorkerBalance> watchBalance(String workerId) => db
      .customSelect(
        _balanceSql(single: true),
        variables: [const Variable('9999-12-31'), Variable(r.farmId), Variable(workerId)],
        readsFrom: {db.attendance, db.financialTransactions, db.workers},
      )
      .watchSingleOrNull()
      .map((row) => row == null ? WorkerBalance(workerId: workerId) : _readBalance(row));

  Future<int> loanBalance(String workerId) async {
    final row = await db
        .customSelect(
          'SELECT COALESCE(SUM($_loan), 0) AS v FROM financial_transactions WHERE farm_id = ? AND worker_id = ? AND sync_status <> 3',
          variables: [Variable(r.farmId), Variable(workerId)],
        )
        .getSingle();
    return row.read<int>('v');
  }

  static const _signed = LedgerSql.signed;

  static const _leaderSql =
      '''
SELECT leader_id,
  SUM(CASE WHEN kind = 'transfer' THEN amt ELSE 0 END) AS entrusted,
  SUM(CASE WHEN kind = 'allocation' THEN amt ELSE 0 END) AS distributed,
  SUM(CASE WHEN kind = 'return' THEN amt ELSE 0 END) AS returned,
  SUM(CASE WHEN kind = 'allocation' AND sync_status <> 0 THEN amt ELSE 0 END) AS pending_distributed,
  SUM(CASE WHEN kind = 'self_funded' THEN amt WHEN kind = 'repaid' THEN -amt ELSE 0 END) AS own_pocket
FROM (
  SELECT worker_id AS leader_id, 'transfer' AS kind, $_signed AS amt, sync_status FROM financial_transactions
    WHERE farm_id = ?1 AND entry_type = 'leader_transfer' AND sync_status <> 3
  UNION ALL
  SELECT worker_id, 'return', $_signed, sync_status FROM financial_transactions
    WHERE farm_id = ?1 AND entry_type = 'leader_return' AND sync_status <> 3
  UNION ALL
  SELECT leader_worker_id, 'allocation', $_signed, sync_status FROM financial_transactions
    WHERE farm_id = ?1 AND entry_type = 'leader_allocation' AND sync_status <> 3
  UNION ALL
  SELECT leader_worker_id, 'self_funded', $_signed, sync_status FROM financial_transactions
    WHERE farm_id = ?1 AND entry_type = 'leader_self_funded' AND sync_status <> 3
  UNION ALL
  SELECT worker_id, 'repaid', $_signed, sync_status FROM financial_transactions
    WHERE farm_id = ?1 AND entry_type = 'reimbursement' AND related_entry_id IS NOT NULL AND sync_status <> 3
) GROUP BY leader_id''';

  LeaderFund _readFund(QueryRow row) => LeaderFund(
    leaderId: row.read<String>('leader_id'),
    entrustedPaise: row.read<int>('entrusted'),
    distributedPaise: row.read<int>('distributed'),
    returnedPaise: row.read<int>('returned'),
    pendingDistributedPaise: row.read<int>('pending_distributed'),
    ownPocketOwedPaise: row.read<int>('own_pocket'),
  );

  Stream<List<LeaderFund>> watchLeaderFunds() => db
      .customSelect(_leaderSql, variables: [Variable(r.farmId)], readsFrom: {db.financialTransactions})
      .watch()
      .map((rows) => rows.map(_readFund).toList());

  Future<LeaderFund> leaderFund(String leaderId) async {
    final rows = await db.customSelect(_leaderSql, variables: [Variable(r.farmId)]).get();
    for (final row in rows) {
      if (row.read<String>('leader_id') == leaderId) return _readFund(row);
    }
    return LeaderFund(leaderId: leaderId);
  }

  /// Leader-related entries for one leader: transfers, returns and
  /// distributions they made (newest first).
  Stream<List<LedgerEntry>> watchLeaderEntries(String leaderId, {int limit = 100}) =>
      (db.select(db.financialTransactions)
            ..where(
              (f) =>
                  f.farmId.equals(r.farmId) &
                  ((f.workerId.equals(leaderId) &
                          f.entryType.isIn([
                            EntryType.leaderTransfer.code,
                            EntryType.leaderReturn.code,
                            EntryType.reimbursement.code,
                          ])) |
                      f.leaderWorkerId.equals(leaderId)),
            )
            ..orderBy([(f) => OrderingTerm.desc(f.businessDate), (f) => OrderingTerm.desc(f.occurredAt)])
            ..limit(limit))
          .watch();

  /// Recent cash movements for the dashboard.
  Stream<List<LedgerEntry>> watchRecentCash({int limit = 5}) =>
      (db.select(db.financialTransactions)
            ..where((f) => f.farmId.equals(r.farmId) & f.method.isNotValue(PayMethod.none))
            ..orderBy([(f) => OrderingTerm.desc(f.createdAt)])
            ..limit(limit))
          .watch();
}
