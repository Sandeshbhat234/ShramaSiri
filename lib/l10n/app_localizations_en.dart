// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ShramaSiri';

  @override
  String get navHome => 'Home';

  @override
  String get navWorkers => 'Workers';

  @override
  String get navAttendance => 'Attendance';

  @override
  String get navAccounts => 'Accounts';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get edit => 'Edit';

  @override
  String get search => 'Search';

  @override
  String get retry => 'Try again';

  @override
  String get close => 'Close';

  @override
  String get done => 'Done';

  @override
  String get loading => 'Loading…';

  @override
  String get moreDetails => 'More details';

  @override
  String get date => 'Date';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get notes => 'Notes (optional)';

  @override
  String get amount => 'Amount';

  @override
  String get amountRupees => 'Amount (₹)';

  @override
  String get balance => 'Balance';

  @override
  String get total => 'Total';

  @override
  String get loadMore => 'Show more';

  @override
  String get filterAll => 'All';

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String get required => 'Required';

  @override
  String get selectDate => 'Change date';

  @override
  String get signIn => 'Sign in';

  @override
  String get signUp => 'Create account';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get newHereCreate => 'New here? Create an account';

  @override
  String get haveAccountSignIn => 'Already have an account? Sign in';

  @override
  String get passwordTooShort => 'Password must be at least 8 characters';

  @override
  String get invalidEmail => 'Enter a valid email';

  @override
  String get checkEmailTitle => 'Check your email';

  @override
  String checkEmailBody(String email) {
    return 'We sent a confirmation to $email. Enter the code from that email, or open its link and then sign in.';
  }

  @override
  String get emailCode => 'Code from email';

  @override
  String get verify => 'Verify';

  @override
  String get resetTitle => 'Reset password';

  @override
  String get resetHelp => 'We will email you a code to set a new password.';

  @override
  String get sendCode => 'Send code';

  @override
  String get newPassword => 'New password';

  @override
  String get resetDone => 'Password changed.';

  @override
  String get signInFailed => 'Email or password is wrong';

  @override
  String get codeInvalid => 'The code is wrong or has expired';

  @override
  String get needInternet => 'This step needs internet. Please connect and try again.';

  @override
  String get setupFarmTitle => 'Set up your farm';

  @override
  String get setupFarmHelp => 'You will be the owner. You can invite family members later.';

  @override
  String get farmName => 'Farm name';

  @override
  String get yourFullName => 'Your full name';

  @override
  String get yourKannadaName => 'Your name in Kannada (optional)';

  @override
  String get startFarm => 'Start';

  @override
  String get invitationsTitle => 'You have been invited';

  @override
  String joinFarm(String farm) {
    return 'Join $farm';
  }

  @override
  String get orCreateOwn => 'Or start your own farm';

  @override
  String get preparing => 'Downloading farm records…';

  @override
  String get setupRequiredTitle => 'Server not configured';

  @override
  String get setupRequiredBody =>
      'This copy of the app was built without the Supabase address and key. Rebuild it with --dart-define-from-file (see README).';

  @override
  String get otherUserPendingTitle => 'This phone has unsent records';

  @override
  String otherUserPendingBody(String email) {
    return 'Records saved by $email have not reached the cloud yet. Sign in as $email first so that nothing is lost.';
  }

  @override
  String get accessRevokedTitle => 'Access removed';

  @override
  String get accessRevokedBody =>
      'Your access to this farm was removed. Please ask the owner. Records on this phone are kept and will upload if access is restored.';

  @override
  String get checkAgain => 'Check again';

  @override
  String get dbErrorTitle => 'Could not open saved data';

  @override
  String get dbErrorBody =>
      'The records stored on this phone could not be opened. You can keep a backup copy of the file and start fresh; synced records will download again.';

  @override
  String get resetLocalData => 'Keep a backup and start fresh';

  @override
  String get signOut => 'Sign out';

  @override
  String get signOutConfirm => 'Sign out of this phone?';

  @override
  String signOutPendingWarning(int count) {
    return '$count records are not in the cloud yet. They stay on this phone and will upload when you sign in again with the same account.';
  }

  @override
  String get syncAllSynced => 'All changes synced';

  @override
  String get syncSavedOnDevice => 'Saved on device — waiting for internet';

  @override
  String get syncInProgress => 'Syncing…';

  @override
  String syncNeedsAttention(int count) {
    return '$count records need attention';
  }

  @override
  String get syncOffline => 'Offline';

  @override
  String get syncSignInAgain => 'Sign in again to sync';

  @override
  String get syncServerProblem => 'Server problem — will try again';

  @override
  String get syncNow => 'Sync now';

  @override
  String lastSynced(String time) {
    return 'Last synced: $time';
  }

  @override
  String get neverSynced => 'Not synced yet';

  @override
  String pendingCount(int count) {
    return 'Waiting to upload: $count';
  }

  @override
  String get syncTitle => 'Sync';

  @override
  String get statusSaved => 'Saved on device';

  @override
  String get statusSynced => 'Synced';

  @override
  String get statusPendingVerification => 'Pending verification';

  @override
  String get statusConflict => 'Needs review';

  @override
  String get statusRejected => 'Not accepted';

  @override
  String get attentionTitle => 'Needs your attention';

  @override
  String get keepMine => 'Keep my version';

  @override
  String get keepTheirs => 'Use the other version';

  @override
  String get discardMine => 'Remove my entry';

  @override
  String get retryUpload => 'Send again';

  @override
  String get myVersion => 'My version';

  @override
  String get otherVersion => 'Saved by someone else';

  @override
  String get diagnostics => 'Sync details';

  @override
  String get noAttention => 'Nothing needs attention';

  @override
  String get clockWrong => 'The phone date or time looks wrong. The app uses internet time for dates.';

  @override
  String get readOnlyBanner =>
      'Not checked with the server for 30 days. Connect to the internet to keep adding records.';

  @override
  String get opFailedRetrying => 'Could not send yet — retrying';

  @override
  String get opAttendance => 'Attendance';

  @override
  String get opWorker => 'Worker details';

  @override
  String get opGroup => 'Group';

  @override
  String get opWork => 'Work entry';

  @override
  String get opMoney => 'Money entry';

  @override
  String get opSettlement => 'Weekly accounts';

  @override
  String get opMember => 'Family member';

  @override
  String get opFarm => 'Farm settings';

  @override
  String get conflictAttendanceExists => 'Attendance for this worker on this day was already marked on another phone.';

  @override
  String get conflictStale => 'Someone else changed this record at the same time.';

  @override
  String errInsufficientLeaderFunds(String amount) {
    return 'The leader has only $amount left to distribute.';
  }

  @override
  String get errWeekClosed => 'This week\'s accounts are closed. Ask the owner to correct it.';

  @override
  String get errForbidden => 'You do not have permission for this.';

  @override
  String get errAccessRevoked => 'Your access to this farm was removed.';

  @override
  String get errVerificationExpired => 'Please connect to the internet once so the app can confirm your access.';

  @override
  String get errInvalidAmount => 'Enter a valid amount';

  @override
  String get errInvalidName => 'Enter a name';

  @override
  String get errInvalidPhone => 'Enter a valid phone number';

  @override
  String get errInvalidDate => 'Choose a valid date';

  @override
  String get errInvalidUnits => 'Enter days between 0 and 3 (e.g. 0.75)';

  @override
  String get errAlreadyReversed => 'This entry is already cancelled.';

  @override
  String errExceedsLoan(String amount) {
    return 'More than the loan still owed ($amount).';
  }

  @override
  String errExceedsLeaderPayable(String amount) {
    return 'More than what is owed to the leader ($amount).';
  }

  @override
  String errLeaderFundsUsed(String amount) {
    return 'This money was already distributed. Only $amount is left with the leader.';
  }

  @override
  String get errLoanRepaid => 'Part of this loan was already repaid.';

  @override
  String get errLeaderPayableSettled => 'This was already repaid to the leader.';

  @override
  String get errNotALeader => 'Choose a worker marked as group leader.';

  @override
  String get errInvalidPayer => 'Choose the family member who paid.';

  @override
  String get errReasonRequired => 'Please write a reason.';

  @override
  String get errAlreadyInvited => 'This email is already invited.';

  @override
  String get errCannotChangeOwner => 'The owner\'s access cannot be changed here.';

  @override
  String get errInvalidWeek => 'Choose a valid week.';

  @override
  String get errWeekInFuture => 'This week has not started yet.';

  @override
  String get errTextTooLong => 'Text is too long';

  @override
  String get errInvalidData => 'Some details were not valid.';

  @override
  String get errNotFound => 'This record no longer exists.';

  @override
  String get errGeneric => 'Something went wrong. Please try again.';

  @override
  String greeting(String name) {
    return 'Namaskara, $name';
  }

  @override
  String get todayWorkers => 'Today\'s workers';

  @override
  String peopleCount(int count) {
    return '$count workers';
  }

  @override
  String get todayWages => 'Today\'s wages (earned)';

  @override
  String get weekEarned => 'This week — wages earned';

  @override
  String get wagesToPay => 'Wages still to pay';

  @override
  String get advancesAhead => 'Paid ahead of earnings (advance)';

  @override
  String get loansOutstanding => 'Loans to recover';

  @override
  String get leaderCashHeld => 'With group leaders, not yet accounted';

  @override
  String get markAttendance => 'Attendance';

  @override
  String get giveMoney => 'Give Money';

  @override
  String get assignWork => 'Assign Work';

  @override
  String get weeklyAccounts => 'Weekly Accounts';

  @override
  String get recentPayments => 'Recent payments';

  @override
  String get todaysWork => 'Today\'s Work';

  @override
  String get noWorkToday => 'No work recorded for today';

  @override
  String get noPayments => 'No payments yet';

  @override
  String paidByLine(String name) {
    return 'Paid by $name';
  }

  @override
  String recordedByLine(String name) {
    return 'Recorded by $name';
  }

  @override
  String receivedByLine(String name) {
    return 'Received by $name';
  }

  @override
  String updatedByLine(String name) {
    return 'Updated by $name';
  }

  @override
  String get earningsNote => 'Earned = work done. Paid = money handed over. Kept separate.';

  @override
  String get workDiary => 'Work diary';

  @override
  String get reports => 'Reports';

  @override
  String get addWorker => 'Add worker';

  @override
  String get editWorker => 'Edit worker';

  @override
  String get nameKannada => 'Name (in Kannada)';

  @override
  String get nameEnglish => 'Name in English (optional)';

  @override
  String get phoneOptional => 'Phone (optional)';

  @override
  String get dailyWage => 'Daily Wage';

  @override
  String get dailyWageRupees => 'Daily Wage (₹)';

  @override
  String get isLeader => 'Group leader';

  @override
  String get isLeaderHelp => 'Can receive money to distribute to others';

  @override
  String get archiveWorker => 'Hide from list';

  @override
  String get unarchiveWorker => 'Show in list again';

  @override
  String get archiveHelp => 'History and accounts are kept.';

  @override
  String get archived => 'Hidden';

  @override
  String get showArchived => 'Show hidden workers';

  @override
  String get noWorkers => 'No workers yet. Add your first worker.';

  @override
  String get noMatches => 'No one matches';

  @override
  String get wageDue => 'Wages due';

  @override
  String get advanceAhead => 'Advance given';

  @override
  String get settledUp => 'Settled';

  @override
  String get loanDue => 'Loan';

  @override
  String get tabAttendance => 'Attendance';

  @override
  String get tabWork => 'Work';

  @override
  String get tabMoney => 'Money';

  @override
  String get groups => 'Groups';

  @override
  String get addGroup => 'Add group';

  @override
  String get editGroup => 'Edit group';

  @override
  String get groupName => 'Group name';

  @override
  String get leader => 'Leader';

  @override
  String get noLeader => 'No leader';

  @override
  String get members => 'Members';

  @override
  String get selectWorkers => 'Select workers';

  @override
  String get noGroups => 'No groups yet. Groups help mark attendance for a crew quickly.';

  @override
  String memberCount(int count) {
    return '$count members';
  }

  @override
  String get wageChangeNote => 'A new wage applies to new attendance only. Past days keep their rate.';

  @override
  String get workerDetails => 'Worker';

  @override
  String get groupLeaderBadge => 'Leader';

  @override
  String get addAdjustment => 'Add adjustment';

  @override
  String get adjustmentHelp => 'Extra earnings, deductions, previous balance or loan repayments.';

  @override
  String get openingBalanceHelp => 'Use a minus sign if the worker owed the farm (e.g. -500).';

  @override
  String get statement => 'Statement';

  @override
  String get fullDay => 'Full day';

  @override
  String get halfDay => 'Half day';

  @override
  String get absent => 'Absent';

  @override
  String get customUnitsShort => 'Other';

  @override
  String get customUnits => 'Days worked (e.g. 0.75)';

  @override
  String get rateForDay => 'Wage for this day (₹)';

  @override
  String get markAllFull => 'All full day';

  @override
  String presentCount(int count) {
    return 'Present: $count';
  }

  @override
  String get saveAttendance => 'Save attendance';

  @override
  String attendanceSaved(int count) {
    return 'Saved $count changes';
  }

  @override
  String get noChanges => 'No changes to save';

  @override
  String get addNewWorker => 'Add a new worker';

  @override
  String get history => 'History';

  @override
  String get attendanceHistory => 'Attendance history';

  @override
  String get unsavedChanges => 'You have unsaved changes. Leave without saving?';

  @override
  String get leave => 'Leave';

  @override
  String get weekClosedNote => 'This week\'s accounts are closed.';

  @override
  String get noActiveWorkers => 'Add workers first';

  @override
  String daysShort(String days) {
    return '$days d';
  }

  @override
  String atRate(String amount) {
    return '@ $amount/day';
  }

  @override
  String get changeGroup => 'Group';

  @override
  String markGroup(String group) {
    return 'Mark $group full day';
  }

  @override
  String get addWork => 'Add work';

  @override
  String get editWork => 'Edit work';

  @override
  String get workType => 'Work';

  @override
  String get fieldName => 'Field / plot (optional)';

  @override
  String get description => 'Description (optional)';

  @override
  String get status => 'Status';

  @override
  String get statusPlanned => 'Planned';

  @override
  String get statusInProgress => 'In progress';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String assignedBy(String name) {
    return 'Assigned by $name';
  }

  @override
  String get noWork => 'No work recorded';

  @override
  String get tasksDontMultiply => 'Tasks do not change wages — wages come from attendance.';

  @override
  String get addWorkType => 'New type of work';

  @override
  String get workTypeName => 'Name of the work';

  @override
  String get chooseWorkType => 'Choose work';

  @override
  String get last30Days => 'Last 30 days';

  @override
  String get recipient => 'To whom';

  @override
  String get selectWorker => 'Select worker';

  @override
  String get selectLeader => 'Select group leader';

  @override
  String get purpose => 'Purpose';

  @override
  String get paidBy => 'Paid By';

  @override
  String get receivedBy => 'Received by';

  @override
  String get method => 'How paid';

  @override
  String get methodCash => 'Cash';

  @override
  String get methodUpi => 'UPI';

  @override
  String get methodBank => 'Bank transfer';

  @override
  String get methodOther => 'Other';

  @override
  String get reference => 'Reference no. (optional)';

  @override
  String get typeAdvance => 'Advance';

  @override
  String get typeWagePayment => 'Wage payment';

  @override
  String get typeBonus => 'Bonus';

  @override
  String get typeAddition => 'Extra earning';

  @override
  String get typeDeduction => 'Deduction';

  @override
  String get typeOpeningBalance => 'Previous balance';

  @override
  String get typeLoan => 'Personal loan';

  @override
  String get typeLoanRepayment => 'Loan repaid in cash';

  @override
  String get typeLoanOffset => 'Loan cut from wages';

  @override
  String get typeReimbursement => 'Expense paid back';

  @override
  String get typeLeaderTransfer => 'Money for leader to distribute';

  @override
  String get typeLeaderAllocation => 'Paid through leader';

  @override
  String get typeLeaderReturn => 'Returned by leader';

  @override
  String get typeLeaderSelfFunded => 'Leader paid from own money';

  @override
  String get helpAdvance => 'Given before wages are due. Deducted in the weekly accounts.';

  @override
  String get helpWagePayment => 'Paying wages already earned.';

  @override
  String get helpLeaderTransfer =>
      'This money is entrusted to the leader to give to other workers. It is not the leader\'s own wages.';

  @override
  String get helpLoan => 'Kept separate from wages. Not deducted unless you choose to.';

  @override
  String get helpBonus => 'Extra pay given now. Counted as wages earned and paid.';

  @override
  String get helpReimbursement => 'Paying back money they spent for the farm. Not wages.';

  @override
  String get helpAddition => 'Extra wages earned (paid later).';

  @override
  String get helpDeduction => 'Reduces wages earned.';

  @override
  String get helpLoanOffset => 'Part of the wages is kept to repay the loan. No cash changes hands.';

  @override
  String leaderHolds(String amount) {
    return 'Now with leader to distribute: $amount';
  }

  @override
  String largeAmountConfirm(String amount) {
    return '$amount is a large amount. Is it correct?';
  }

  @override
  String duplicateConfirm(String amount, String worker) {
    return '$amount to $worker was already recorded recently. Record another one?';
  }

  @override
  String get yesRecord => 'Yes, record it';

  @override
  String get checkAgainBtn => 'Let me check';

  @override
  String get savedOnDeviceToast => 'Saved on device';

  @override
  String get savedAndSyncedToast => 'Saved';

  @override
  String nowBalance(String amount) {
    return 'Balance now: $amount';
  }

  @override
  String get paymentHistory => 'Payment history';

  @override
  String get filterWorker => 'Worker';

  @override
  String get filterPayer => 'Paid by';

  @override
  String get filterType => 'Type';

  @override
  String get noEntries => 'No entries';

  @override
  String get entryDetails => 'Entry details';

  @override
  String get reverseEntry => 'Cancel this entry';

  @override
  String get correctEntry => 'Correct this entry';

  @override
  String get reason => 'Reason';

  @override
  String get reversedLabel => 'Cancelled';

  @override
  String get reversalLabel => 'Cancellation of an earlier entry';

  @override
  String get reverseExplain => 'The original stays in history and a cancelling entry is added.';

  @override
  String get correctExplain => 'The old entry is cancelled and this corrected one is recorded.';

  @override
  String get changeHistory => 'Change history';

  @override
  String get worker => 'Worker';

  @override
  String get dateTime => 'Date and time';

  @override
  String get type => 'Type';

  @override
  String get allTypes => 'All types';

  @override
  String get everyone => 'Everyone';

  @override
  String get anyDate => 'Any date';

  @override
  String get thisWeek => 'This week';

  @override
  String get thisMonth => 'This month';

  @override
  String get chooseDates => 'Choose dates';

  @override
  String get accountsTitle => 'Accounts';

  @override
  String get balancesTitle => 'Balances';

  @override
  String get leaderFunds => 'Group leader money';

  @override
  String get entrusted => 'Entrusted';

  @override
  String get distributed => 'Confirmed distributed';

  @override
  String get returned => 'Returned';

  @override
  String get unreconciled => 'Not yet accounted';

  @override
  String pendingVerificationAmount(String amount) {
    return '$amount waiting for verification';
  }

  @override
  String get ownPocketOwed => 'Owed to leader (paid from own money)';

  @override
  String get recordDistribution => 'Record distribution';

  @override
  String get recordReturn => 'Leader returned cash';

  @override
  String get recordOwnPocket => 'Leader paid from own money';

  @override
  String get repayLeader => 'Repay leader';

  @override
  String get giveToLeader => 'Give money to leader';

  @override
  String get distributeHelp => 'Enter how much the leader gave each worker.';

  @override
  String get ownPocketHelp =>
      'Wages the leader paid to workers from their own money. The farm owes this to the leader.';

  @override
  String distributionTotal(String amount, String available) {
    return 'Total $amount of $available';
  }

  @override
  String get exceedsAvailable => 'More than the leader holds';

  @override
  String get noLeaders => 'No group leaders. Mark a worker as group leader in their details.';

  @override
  String get leaderSelfShare => '(leader\'s own wages)';

  @override
  String get leaderPersonalNote =>
      'The leader\'s own wages and advances are in their worker page, separate from this money.';

  @override
  String distributionSaved(int count) {
    return 'Saved $count distributions';
  }

  @override
  String get weeklySettlement => 'Weekly Settlement';

  @override
  String get openingBalance => 'Previous balance';

  @override
  String get daysWorked => 'Days worked';

  @override
  String get earned => 'Earned';

  @override
  String get additions => 'Extra / adjustments';

  @override
  String get advanceGiven => 'Advance';

  @override
  String get paidDirect => 'Paid';

  @override
  String get paidViaLeader => 'Paid through leader';

  @override
  String get remaining => 'Remaining';

  @override
  String get overpaid => 'Paid extra (carried forward as advance)';

  @override
  String payAmount(String amount) {
    return 'Pay $amount';
  }

  @override
  String get payPart => 'Pay part';

  @override
  String get closeWeek => 'Close week';

  @override
  String get closeWeekHelp =>
      'Closing marks the week as checked. Unpaid balances carry to next week. Records stay correctable.';

  @override
  String get weekClosed => 'Closed';

  @override
  String get weekOpen => 'Open';

  @override
  String get needsReview => 'Changed after closing — please review';

  @override
  String get markReviewed => 'Mark reviewed';

  @override
  String get reopenWeek => 'Reopen week';

  @override
  String closedBy(String name) {
    return 'Closed by $name';
  }

  @override
  String get share => 'Share';

  @override
  String get weekTotalDue => 'Total remaining';

  @override
  String get weekTotalEarned => 'Total earned';

  @override
  String get previousWeek => 'Previous week';

  @override
  String get nextWeek => 'Next week';

  @override
  String get noActivityWeek => 'No work or payments this week';

  @override
  String atClosing(String amount) {
    return 'At closing: $amount';
  }

  @override
  String payConfirm(String amount, String worker) {
    return 'Record $amount paid to $worker?';
  }

  @override
  String get pastWeeks => 'Past weeks';

  @override
  String get stmtHeader => 'ShramaSiri — wage statement';

  @override
  String stmtWeek(String range) {
    return 'Week: $range';
  }

  @override
  String stmtFarm(String farm) {
    return 'Farm: $farm';
  }

  @override
  String stmtDays(String days) {
    return 'Days worked: $days';
  }

  @override
  String stmtRate(String amount) {
    return 'Daily wage: $amount';
  }

  @override
  String stmtLine(String label, String amount) {
    return '$label: $amount';
  }

  @override
  String stmtFooter(String name) {
    return 'Prepared by $name';
  }

  @override
  String workersInWeek(int count) {
    return '$count workers';
  }

  @override
  String get labourCost => 'Labour cost (wages earned)';

  @override
  String get cashPaidOut => 'Cash paid out';

  @override
  String get cashReturned => 'Cash returned to farm';

  @override
  String get netCash => 'Net cash out';

  @override
  String get outstandingNow => 'Outstanding now';

  @override
  String get byWorker => 'By worker';

  @override
  String get byFamilyMember => 'Paid by family member';

  @override
  String get byWorkType => 'By work (approximate)';

  @override
  String get byPaymentType => 'By type';

  @override
  String get noTask => 'No task recorded';

  @override
  String get attendanceSummary => 'Attendance';

  @override
  String get periodToday => 'Today';

  @override
  String get periodWeek => 'This week';

  @override
  String get periodMonth => 'This month';

  @override
  String get periodCustom => 'Choose';

  @override
  String get exportCsv => 'Export CSV';

  @override
  String get shareSummary => 'Share summary';

  @override
  String get settlementHistory => 'Weekly settlements';

  @override
  String get reportNote => 'Earned wages, cash paid, balances and leader money are shown separately on purpose.';

  @override
  String summaryTitle(String range) {
    return 'ShramaSiri summary $range';
  }

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get weekStartsOn => 'Wage week starts on';

  @override
  String get currencyNote => 'Currency: Indian Rupee (₹)';

  @override
  String get profile => 'My details';

  @override
  String get familyMembers => 'Family members';

  @override
  String get inviteMember => 'Invite family member';

  @override
  String get inviteHelp => 'They should install the app and create an account with this same email.';

  @override
  String get roleOwner => 'Owner';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get roleMember => 'Family member';

  @override
  String get memberInvited => 'Invited — not joined yet';

  @override
  String get memberDisabled => 'Access removed';

  @override
  String get disableAccess => 'Remove access';

  @override
  String get enableAccess => 'Restore access';

  @override
  String get makeAdmin => 'Make admin';

  @override
  String get makeMember => 'Make regular member';

  @override
  String disableConfirm(String name) {
    return 'Remove $name\'s access? Their past records stay.';
  }

  @override
  String get auditHistory => 'Activity history';

  @override
  String get about => 'About';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get aboutText =>
      'ShramaSiri is a simple notebook for farm labour, wages and payments. It works without internet and syncs safely between family phones.';

  @override
  String get farmSection => 'Farm';

  @override
  String get accountSection => 'Account';

  @override
  String get workTypes => 'Types of work';

  @override
  String get ownerOnly => 'Only the owner or admin can change this.';

  @override
  String loggedInAs(String email) {
    return 'Signed in as $email';
  }

  @override
  String get auditWorkerCreated => 'Worker added';

  @override
  String get auditWorkerUpdated => 'Worker details changed';

  @override
  String get auditWorkerArchived => 'Worker hidden';

  @override
  String get auditAttendanceMarked => 'Attendance marked';

  @override
  String get auditAttendanceCorrected => 'Attendance corrected';

  @override
  String get auditWorkAssigned => 'Work assigned';

  @override
  String get auditWorkUpdated => 'Work changed';

  @override
  String auditMoney(String type) {
    return 'Money recorded: $type';
  }

  @override
  String get auditReversed => 'Entry cancelled';

  @override
  String get auditSettlementClosed => 'Week closed';

  @override
  String get auditSettlementReviewed => 'Week reviewed';

  @override
  String get auditSettlementReopened => 'Week reopened';

  @override
  String get auditMemberInvited => 'Family member invited';

  @override
  String get auditMemberJoined => 'Family member joined';

  @override
  String get auditMemberUpdated => 'Access changed';

  @override
  String auditOther(String action) {
    return 'Change: $action';
  }

  @override
  String get addPresentWorkers => 'Add everyone present that day';

  @override
  String get recordedBy => 'Recorded by';

  @override
  String get daysUnit => 'days';

  @override
  String get fullName => 'Full name';

  @override
  String get fullDayShort => 'Full';

  @override
  String get halfDayShort => 'Half';
}
