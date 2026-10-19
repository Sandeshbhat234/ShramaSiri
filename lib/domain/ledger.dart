// The accounting model. One coefficient table defines what every ledger entry
// type does; both the pure-Dart calculations below and the SQL aggregates in
// the repositories are generated from it. It mirrors the comment block on
// public.financial_transactions and private.period_summary on the server.

enum EntryType {
  advance('advance'),
  wagePayment('wage_payment'),
  bonus('bonus'),
  addition('addition'),
  deduction('deduction'),
  openingBalance('opening_balance'),
  loan('loan'),
  loanRepayment('loan_repayment'),
  loanOffset('loan_offset'),
  reimbursement('reimbursement'),
  leaderTransfer('leader_transfer'),
  leaderAllocation('leader_allocation'),
  leaderReturn('leader_return'),
  leaderSelfFunded('leader_self_funded');

  const EntryType(this.code);

  final String code;

  static EntryType fromCode(String code) =>
      values.firstWhere((t) => t.code == code, orElse: () => throw ArgumentError('Unknown entry type $code'));

  Effects get effects => _effects[this]!;

  /// Physical cash moves between the farm and someone: needs payer and method.
  bool get isCash => effects.cashOut != 0;

  /// Requires a leader in addition to the worker.
  bool get needsLeader => this == leaderAllocation || this == leaderSelfFunded;

  /// Changes a worker's wage balance (and so is guarded by closed weeks).
  bool get affectsWages {
    final e = effects;
    return e.earned != 0 || e.advance != 0 || e.direct != 0 || e.viaLeader != 0;
  }
}

/// Per-unit effect of an entry on the buckets keyed by the entry's worker_id.
/// Leader pool/payable are keyed differently and handled explicitly.
class Effects {
  const Effects({
    this.earned = 0,
    this.expense = 0,
    this.advance = 0,
    this.direct = 0,
    this.viaLeader = 0,
    this.loan = 0,
    this.cashOut = 0,
  });

  /// Added to what the worker has earned (wage balance +).
  final int earned;

  /// Counted as labour expense for the period (opening balances are not).
  final int expense;

  /// Wage advance given (wage balance -).
  final int advance;

  /// Wages paid directly by the family (wage balance -).
  final int direct;

  /// Wages paid through a group leader (wage balance -).
  final int viaLeader;

  /// Personal loan the worker owes the farm.
  final int loan;

  /// Farm cash out (+) or cash returned to the farm (-).
  final int cashOut;
}

const _effects = <EntryType, Effects>{
  EntryType.advance: Effects(advance: 1, cashOut: 1),
  EntryType.wagePayment: Effects(direct: 1, cashOut: 1),
  // A bonus is extra earned pay that is paid out in the same entry.
  EntryType.bonus: Effects(earned: 1, expense: 1, direct: 1, cashOut: 1),
  EntryType.addition: Effects(earned: 1, expense: 1),
  EntryType.deduction: Effects(earned: -1, expense: -1),
  // Signed amount: positive = farm owed the worker, negative = worker owed the farm.
  EntryType.openingBalance: Effects(earned: 1),
  EntryType.loan: Effects(loan: 1, cashOut: 1),
  EntryType.loanRepayment: Effects(loan: -1, cashOut: -1),
  // Wages applied to a loan: wages count as paid, loan goes down, no cash.
  EntryType.loanOffset: Effects(loan: -1, direct: 1),
  // Expense reimbursement: cash out, but not a wage expense.
  EntryType.reimbursement: Effects(cashOut: 1),
  // Cash handed to a leader for distribution is the farm's cash outflow...
  EntryType.leaderTransfer: Effects(cashOut: 1),
  // ...and a confirmed distribution is reconciliation, not new cash.
  EntryType.leaderAllocation: Effects(viaLeader: 1),
  EntryType.leaderReturn: Effects(cashOut: -1),
  EntryType.leaderSelfFunded: Effects(viaLeader: 1),
};

/// Entry types offered in the Give Money form, in display order.
const givingPurposes = [
  EntryType.advance,
  EntryType.wagePayment,
  EntryType.leaderTransfer,
  EntryType.loan,
  EntryType.bonus,
  EntryType.reimbursement,
];

/// Minimal view of a ledger row used by the calculations.
class LedgerLine {
  const LedgerLine({
    required this.type,
    required this.amountPaise,
    required this.workerId,
    required this.businessDate,
    this.leaderWorkerId,
    this.isReversal = false,
    this.relatedEntryId,
  });

  final EntryType type;
  final int amountPaise;
  final String workerId;
  final String? leaderWorkerId;
  final String businessDate;
  final bool isReversal;
  final String? relatedEntryId;

  int get signedAmount => isReversal ? -amountPaise : amountPaise;
}

class AttendanceLine {
  const AttendanceLine({
    required this.workerId,
    required this.workDate,
    required this.unitsMilli,
    required this.earnedPaise,
  });

  final String workerId;
  final String workDate;
  final int unitsMilli;
  final int earnedPaise;
}

/// Weekly (or any period) wage statement for one worker.
/// closing = opening + gross + additions - advances - directPaid - leaderPaid
class PeriodSummary {
  const PeriodSummary({
    required this.workerId,
    this.unitsMilli = 0,
    this.openingPaise = 0,
    this.grossPaise = 0,
    this.additionsPaise = 0,
    this.advancesPaise = 0,
    this.directPaidPaise = 0,
    this.leaderPaidPaise = 0,
  });

  final String workerId;
  final int unitsMilli;
  final int openingPaise;
  final int grossPaise;
  final int additionsPaise;
  final int advancesPaise;
  final int directPaidPaise;
  final int leaderPaidPaise;

  int get earnedPaise => grossPaise + additionsPaise;
  int get paidPaise => advancesPaise + directPaidPaise + leaderPaidPaise;

  /// Positive: the farm still owes the worker. Negative: the worker has been
  /// paid more than earned (carried forward as an advance).
  int get closingPaise => openingPaise + earnedPaise - paidPaise;

  bool get isEmpty =>
      unitsMilli == 0 &&
      openingPaise == 0 &&
      grossPaise == 0 &&
      additionsPaise == 0 &&
      advancesPaise == 0 &&
      directPaidPaise == 0 &&
      leaderPaidPaise == 0;
}

/// Pure-Dart reference implementation, used by tests and as the definition
/// the SQL in [LedgerSql] must agree with.
abstract final class LedgerMath {
  static Map<String, PeriodSummary> periodSummaries({
    required Iterable<AttendanceLine> attendance,
    required Iterable<LedgerLine> ledger,
    required String start,
    required String end,
  }) {
    final acc = <String, List<int>>{};
    List<int> row(String w) => acc.putIfAbsent(w, () => List.filled(7, 0));

    for (final a in attendance) {
      if (a.workDate.compareTo(end) > 0) continue;
      final r = row(a.workerId);
      if (a.workDate.compareTo(start) < 0) {
        r[1] += a.earnedPaise;
      } else {
        r[0] += a.unitsMilli;
        r[2] += a.earnedPaise;
      }
    }
    for (final l in ledger) {
      if (l.businessDate.compareTo(end) > 0) continue;
      final e = l.type.effects;
      if (e.earned == 0 && e.advance == 0 && e.direct == 0 && e.viaLeader == 0) continue;
      final r = row(l.workerId);
      final amt = l.signedAmount;
      if (l.businessDate.compareTo(start) < 0) {
        r[1] += amt * (e.earned - e.advance - e.direct - e.viaLeader);
      } else {
        r[3] += amt * e.earned;
        r[4] += amt * e.advance;
        r[5] += amt * e.direct;
        r[6] += amt * e.viaLeader;
      }
    }
    final out = <String, PeriodSummary>{};
    acc.forEach((w, r) {
      final s = PeriodSummary(
        workerId: w,
        unitsMilli: r[0],
        openingPaise: r[1],
        grossPaise: r[2],
        additionsPaise: r[3],
        advancesPaise: r[4],
        directPaidPaise: r[5],
        leaderPaidPaise: r[6],
      );
      if (!s.isEmpty) out[w] = s;
    });
    return out;
  }

  /// Wage balance (farm owes worker) as of [asOf], inclusive.
  static int wageBalance(
    String workerId,
    Iterable<AttendanceLine> attendance,
    Iterable<LedgerLine> ledger, {
    String asOf = '9999-12-31',
  }) {
    return periodSummaries(
          attendance: attendance.where((a) => a.workerId == workerId),
          ledger: ledger.where((l) => l.workerId == workerId),
          start: '9999-12-31',
          end: asOf,
        )[workerId]?.openingPaise ??
        0;
  }

  static int loanBalance(String workerId, Iterable<LedgerLine> ledger) =>
      ledger.where((l) => l.workerId == workerId).fold(0, (sum, l) => sum + l.signedAmount * l.type.effects.loan);

  /// Money currently held by [leaderId] for distribution.
  static int leaderPool(String leaderId, Iterable<LedgerLine> ledger) {
    var total = 0;
    for (final l in ledger) {
      if ((l.type == EntryType.leaderTransfer) && l.workerId == leaderId) total += l.signedAmount;
      if ((l.type == EntryType.leaderReturn) && l.workerId == leaderId) total -= l.signedAmount;
      if ((l.type == EntryType.leaderAllocation) && l.leaderWorkerId == leaderId) total -= l.signedAmount;
    }
    return total;
  }

  /// What the farm owes [leaderId] for wages paid from the leader's own pocket.
  static int leaderPayable(String leaderId, Iterable<LedgerLine> ledger) {
    var total = 0;
    for (final l in ledger) {
      if (l.type == EntryType.leaderSelfFunded && l.leaderWorkerId == leaderId) total += l.signedAmount;
      if (l.type == EntryType.reimbursement && l.workerId == leaderId && l.relatedEntryId != null) {
        total -= l.signedAmount;
      }
    }
    return total;
  }

  /// Net farm cash outflow (cash given minus cash returned).
  static int cashOut(Iterable<LedgerLine> ledger) =>
      ledger.fold(0, (sum, l) => sum + l.signedAmount * l.type.effects.cashOut);

  /// Labour expense (earned wages) for the lines given.
  static int labourExpense(Iterable<AttendanceLine> attendance, Iterable<LedgerLine> ledger) =>
      attendance.fold(0, (s, a) => s + a.earnedPaise) +
      ledger.fold(0, (s, l) => s + l.signedAmount * l.type.effects.expense);
}

/// SQL fragments for SQLite generated from the coefficient table.
abstract final class LedgerSql {
  /// `CASE entry_type WHEN 'advance' THEN 1 ... ELSE 0 END` for one bucket.
  static String coeff(int Function(Effects e) pick, {String column = 'entry_type'}) {
    final whens = EntryType.values
        .where((t) => pick(t.effects) != 0)
        .map((t) => "WHEN '${t.code}' THEN ${pick(t.effects)}")
        .join(' ');
    if (whens.isEmpty) return '0';
    return '(CASE $column $whens ELSE 0 END)';
  }

  /// Signed amount of a row, negated for reversals.
  static const signed = '(CASE WHEN is_reversal THEN -amount_paise ELSE amount_paise END)';

  /// Effect on a bucket: signed amount times the coefficient.
  static String effect(int Function(Effects e) pick) => '($signed * ${coeff(pick)})';

  /// Net change to the worker's wage balance.
  static String get wageNet => effect((e) => e.earned - e.advance - e.direct - e.viaLeader);

  /// Rows rejected by the server are excluded from all totals.
  static const notRejected = 'sync_status <> 3';
}
