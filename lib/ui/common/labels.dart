import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;

import '../../core/dates.dart';
import '../../core/money.dart';
import '../../data/db/database.dart';
import '../../data/remote/remote_api.dart';
import '../../data/repositories/ledger_repo.dart';
import '../../data/repositories/repo_base.dart';
import '../../data/repositories/work_repo.dart';
import '../../domain/ledger.dart';
import '../../l10n/app_localizations.dart';

extension L10nX on BuildContext {
  AppLocalizations get l => AppLocalizations.of(this);
  DateFormats get dates => DateFormats(AppLocalizations.of(this).localeName);
}

String entryTypeLabel(AppLocalizations l, EntryType t) => switch (t) {
  EntryType.advance => l.typeAdvance,
  EntryType.wagePayment => l.typeWagePayment,
  EntryType.bonus => l.typeBonus,
  EntryType.addition => l.typeAddition,
  EntryType.deduction => l.typeDeduction,
  EntryType.openingBalance => l.typeOpeningBalance,
  EntryType.loan => l.typeLoan,
  EntryType.loanRepayment => l.typeLoanRepayment,
  EntryType.loanOffset => l.typeLoanOffset,
  EntryType.reimbursement => l.typeReimbursement,
  EntryType.leaderTransfer => l.typeLeaderTransfer,
  EntryType.leaderAllocation => l.typeLeaderAllocation,
  EntryType.leaderReturn => l.typeLeaderReturn,
  EntryType.leaderSelfFunded => l.typeLeaderSelfFunded,
};

String? entryTypeHelp(AppLocalizations l, EntryType t) => switch (t) {
  EntryType.advance => l.helpAdvance,
  EntryType.wagePayment => l.helpWagePayment,
  EntryType.bonus => l.helpBonus,
  EntryType.loan => l.helpLoan,
  EntryType.reimbursement => l.helpReimbursement,
  EntryType.leaderTransfer => l.helpLeaderTransfer,
  EntryType.addition => l.helpAddition,
  EntryType.deduction => l.helpDeduction,
  EntryType.loanOffset => l.helpLoanOffset,
  EntryType.openingBalance => l.openingBalanceHelp,
  _ => null,
};

String methodLabel(AppLocalizations l, String m) => switch (m) {
  PayMethod.cash => l.methodCash,
  PayMethod.upi => l.methodUpi,
  PayMethod.bank => l.methodBank,
  _ => l.methodOther,
};

String workStatusLabel(AppLocalizations l, String s) => switch (s) {
  WorkStatus.planned => l.statusPlanned,
  WorkStatus.inProgress => l.statusInProgress,
  WorkStatus.completed => l.statusCompleted,
  _ => l.statusCancelled,
};

String roleLabel(AppLocalizations l, String role) => switch (role) {
  'owner' => l.roleOwner,
  'admin' => l.roleAdmin,
  _ => l.roleMember,
};

String workerName(Worker? w) => w == null ? '—' : w.nameKn;

String workTypeName(AppLocalizations l, WorkType? t) => t == null ? '—' : (l.localeName == 'kn' ? t.nameKn : t.nameEn);

String opLabel(AppLocalizations l, String entityTable) => switch (entityTable) {
  'attendance' => l.opAttendance,
  'workers' => l.opWorker,
  'worker_groups' => l.opGroup,
  'work_assignments' || 'work_types' => l.opWork,
  'financial_transactions' => l.opMoney,
  'settlements' => l.opSettlement,
  'farm_members' => l.opMember,
  _ => l.opFarm,
};

String auditLabel(AppLocalizations l, String action) {
  if (action.startsWith('ledger.') && action != 'ledger.reversed') {
    final code = action.substring(7);
    try {
      return l.auditMoney(entryTypeLabel(l, EntryType.fromCode(code)));
    } on ArgumentError {
      return l.auditOther(action);
    }
  }
  return switch (action) {
    'worker.created' => l.auditWorkerCreated,
    'worker.updated' || 'worker.active' => l.auditWorkerUpdated,
    'worker.archived' => l.auditWorkerArchived,
    'attendance.marked' => l.auditAttendanceMarked,
    'attendance.corrected' => l.auditAttendanceCorrected,
    'work.assigned' => l.auditWorkAssigned,
    'work.updated' => l.auditWorkUpdated,
    'ledger.reversed' => l.auditReversed,
    'settlement.closed' => l.auditSettlementClosed,
    'settlement.reviewed' => l.auditSettlementReviewed,
    'settlement.reopened' => l.auditSettlementReopened,
    'member.invited' => l.auditMemberInvited,
    'member.joined' => l.auditMemberJoined,
    'member.updated' => l.auditMemberUpdated,
    _ => l.auditOther(action),
  };
}

/// Human message for an error code from the app or the server.
String errorCodeText(AppLocalizations l, String? code, [Map<String, Object?> args = const {}]) {
  String amount() {
    final v = args['available'] ?? args['available_paise'];
    return v is int ? Money.format(v) : '';
  }

  return switch (code) {
    'insufficient_leader_funds' => l.errInsufficientLeaderFunds(amount()),
    'week_closed' => l.errWeekClosed,
    'forbidden' => l.errForbidden,
    'access_revoked' || 'not_a_member' => l.errAccessRevoked,
    'verification_expired' => l.errVerificationExpired,
    'invalid_amount' => l.errInvalidAmount,
    'invalid_name' => l.errInvalidName,
    'invalid_phone' => l.errInvalidPhone,
    'invalid_date' => l.errInvalidDate,
    'invalid_units' => l.errInvalidUnits,
    'already_reversed' => l.errAlreadyReversed,
    'exceeds_loan_balance' => l.errExceedsLoan(amount()),
    'exceeds_leader_payable' => l.errExceedsLeaderPayable(amount()),
    'leader_funds_already_used' => l.errLeaderFundsUsed(amount()),
    'loan_already_repaid' => l.errLoanRepaid,
    'leader_payable_already_settled' => l.errLeaderPayableSettled,
    'not_a_leader' || 'leader_required' => l.errNotALeader,
    'invalid_payer' => l.errInvalidPayer,
    'reason_required' => l.errReasonRequired,
    'already_invited' => l.errAlreadyInvited,
    'invalid_email' => l.invalidEmail,
    'cannot_change_owner_or_self' => l.errCannotChangeOwner,
    'invalid_week' => l.errInvalidWeek,
    'week_in_future' => l.errWeekInFuture,
    'text_too_long' => l.errTextTooLong,
    'invalid_data' ||
    'invalid_worker' ||
    'invalid_entry_type' ||
    'invalid_method' ||
    'immutable_key' => l.errInvalidData,
    'not_found' => l.errNotFound,
    'attendance_exists' => l.conflictAttendanceExists,
    'stale_revision' || 'already_exists' => l.conflictStale,
    _ => l.errGeneric,
  };
}

String errorText(AppLocalizations l, Object e) {
  if (e is AppException) return errorCodeText(l, e.code, e.args);
  if (e is RemoteError) {
    return switch (e.kind) {
      RemoteErrorKind.network => l.needInternet,
      RemoteErrorKind.forbidden => l.errForbidden,
      _ => l.errGeneric,
    };
  }
  if (e is AuthException) {
    final code = e.code ?? '';
    if (code == 'invalid_credentials') return l.signInFailed;
    if (code == 'otp_expired' || code.contains('otp')) return l.codeInvalid;
    if (code == 'weak_password') return l.passwordTooShort;
    if (e.statusCode == null) return l.needInternet;
    return e.message;
  }
  return l.errGeneric;
}
