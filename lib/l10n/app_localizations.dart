import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_kn.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('kn')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'ShramaSiri'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navWorkers.
  ///
  /// In en, this message translates to:
  /// **'Workers'**
  String get navWorkers;

  /// No description provided for @navAttendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get navAttendance;

  /// No description provided for @navAccounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get navAccounts;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @moreDetails.
  ///
  /// In en, this message translates to:
  /// **'More details'**
  String get moreDetails;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notes;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @amountRupees.
  ///
  /// In en, this message translates to:
  /// **'Amount (₹)'**
  String get amountRupees;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get loadMore;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Change date'**
  String get selectDate;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signUp;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @newHereCreate.
  ///
  /// In en, this message translates to:
  /// **'New here? Create an account'**
  String get newHereCreate;

  /// No description provided for @haveAccountSignIn.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get haveAccountSignIn;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordTooShort;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get invalidEmail;

  /// No description provided for @checkEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get checkEmailTitle;

  /// No description provided for @checkEmailBody.
  ///
  /// In en, this message translates to:
  /// **'We sent a confirmation to {email}. Enter the code from that email, or open its link and then sign in.'**
  String checkEmailBody(String email);

  /// No description provided for @emailCode.
  ///
  /// In en, this message translates to:
  /// **'Code from email'**
  String get emailCode;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @resetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetTitle;

  /// No description provided for @resetHelp.
  ///
  /// In en, this message translates to:
  /// **'We will email you a code to set a new password.'**
  String get resetHelp;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCode;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @resetDone.
  ///
  /// In en, this message translates to:
  /// **'Password changed.'**
  String get resetDone;

  /// No description provided for @signInFailed.
  ///
  /// In en, this message translates to:
  /// **'Email or password is wrong'**
  String get signInFailed;

  /// No description provided for @codeInvalid.
  ///
  /// In en, this message translates to:
  /// **'The code is wrong or has expired'**
  String get codeInvalid;

  /// No description provided for @needInternet.
  ///
  /// In en, this message translates to:
  /// **'This step needs internet. Please connect and try again.'**
  String get needInternet;

  /// No description provided for @setupFarmTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your farm'**
  String get setupFarmTitle;

  /// No description provided for @setupFarmHelp.
  ///
  /// In en, this message translates to:
  /// **'You will be the owner. You can invite family members later.'**
  String get setupFarmHelp;

  /// No description provided for @farmName.
  ///
  /// In en, this message translates to:
  /// **'Farm name'**
  String get farmName;

  /// No description provided for @yourFullName.
  ///
  /// In en, this message translates to:
  /// **'Your full name'**
  String get yourFullName;

  /// No description provided for @yourKannadaName.
  ///
  /// In en, this message translates to:
  /// **'Your name in Kannada (optional)'**
  String get yourKannadaName;

  /// No description provided for @startFarm.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startFarm;

  /// No description provided for @invitationsTitle.
  ///
  /// In en, this message translates to:
  /// **'You have been invited'**
  String get invitationsTitle;

  /// No description provided for @joinFarm.
  ///
  /// In en, this message translates to:
  /// **'Join {farm}'**
  String joinFarm(String farm);

  /// No description provided for @orCreateOwn.
  ///
  /// In en, this message translates to:
  /// **'Or start your own farm'**
  String get orCreateOwn;

  /// No description provided for @preparing.
  ///
  /// In en, this message translates to:
  /// **'Downloading farm records…'**
  String get preparing;

  /// No description provided for @setupRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Server not configured'**
  String get setupRequiredTitle;

  /// No description provided for @setupRequiredBody.
  ///
  /// In en, this message translates to:
  /// **'This copy of the app was built without the Supabase address and key. Rebuild it with --dart-define-from-file (see README).'**
  String get setupRequiredBody;

  /// No description provided for @otherUserPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'This phone has unsent records'**
  String get otherUserPendingTitle;

  /// No description provided for @otherUserPendingBody.
  ///
  /// In en, this message translates to:
  /// **'Records saved by {email} have not reached the cloud yet. Sign in as {email} first so that nothing is lost.'**
  String otherUserPendingBody(String email);

  /// No description provided for @accessRevokedTitle.
  ///
  /// In en, this message translates to:
  /// **'Access removed'**
  String get accessRevokedTitle;

  /// No description provided for @accessRevokedBody.
  ///
  /// In en, this message translates to:
  /// **'Your access to this farm was removed. Please ask the owner. Records on this phone are kept and will upload if access is restored.'**
  String get accessRevokedBody;

  /// No description provided for @checkAgain.
  ///
  /// In en, this message translates to:
  /// **'Check again'**
  String get checkAgain;

  /// No description provided for @dbErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not open saved data'**
  String get dbErrorTitle;

  /// No description provided for @dbErrorBody.
  ///
  /// In en, this message translates to:
  /// **'The records stored on this phone could not be opened. You can keep a backup copy of the file and start fresh; synced records will download again.'**
  String get dbErrorBody;

  /// No description provided for @resetLocalData.
  ///
  /// In en, this message translates to:
  /// **'Keep a backup and start fresh'**
  String get resetLocalData;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @signOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Sign out of this phone?'**
  String get signOutConfirm;

  /// No description provided for @signOutPendingWarning.
  ///
  /// In en, this message translates to:
  /// **'{count} records are not in the cloud yet. They stay on this phone and will upload when you sign in again with the same account.'**
  String signOutPendingWarning(int count);

  /// No description provided for @syncAllSynced.
  ///
  /// In en, this message translates to:
  /// **'All changes synced'**
  String get syncAllSynced;

  /// No description provided for @syncSavedOnDevice.
  ///
  /// In en, this message translates to:
  /// **'Saved on device — waiting for internet'**
  String get syncSavedOnDevice;

  /// No description provided for @syncInProgress.
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get syncInProgress;

  /// No description provided for @syncNeedsAttention.
  ///
  /// In en, this message translates to:
  /// **'{count} records need attention'**
  String syncNeedsAttention(int count);

  /// No description provided for @syncOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get syncOffline;

  /// No description provided for @syncSignInAgain.
  ///
  /// In en, this message translates to:
  /// **'Sign in again to sync'**
  String get syncSignInAgain;

  /// No description provided for @syncServerProblem.
  ///
  /// In en, this message translates to:
  /// **'Server problem — will try again'**
  String get syncServerProblem;

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get syncNow;

  /// No description provided for @lastSynced.
  ///
  /// In en, this message translates to:
  /// **'Last synced: {time}'**
  String lastSynced(String time);

  /// No description provided for @neverSynced.
  ///
  /// In en, this message translates to:
  /// **'Not synced yet'**
  String get neverSynced;

  /// No description provided for @pendingCount.
  ///
  /// In en, this message translates to:
  /// **'Waiting to upload: {count}'**
  String pendingCount(int count);

  /// No description provided for @syncTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get syncTitle;

  /// No description provided for @statusSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved on device'**
  String get statusSaved;

  /// No description provided for @statusSynced.
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get statusSynced;

  /// No description provided for @statusPendingVerification.
  ///
  /// In en, this message translates to:
  /// **'Pending verification'**
  String get statusPendingVerification;

  /// No description provided for @statusConflict.
  ///
  /// In en, this message translates to:
  /// **'Needs review'**
  String get statusConflict;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Not accepted'**
  String get statusRejected;

  /// No description provided for @attentionTitle.
  ///
  /// In en, this message translates to:
  /// **'Needs your attention'**
  String get attentionTitle;

  /// No description provided for @keepMine.
  ///
  /// In en, this message translates to:
  /// **'Keep my version'**
  String get keepMine;

  /// No description provided for @keepTheirs.
  ///
  /// In en, this message translates to:
  /// **'Use the other version'**
  String get keepTheirs;

  /// No description provided for @discardMine.
  ///
  /// In en, this message translates to:
  /// **'Remove my entry'**
  String get discardMine;

  /// No description provided for @retryUpload.
  ///
  /// In en, this message translates to:
  /// **'Send again'**
  String get retryUpload;

  /// No description provided for @myVersion.
  ///
  /// In en, this message translates to:
  /// **'My version'**
  String get myVersion;

  /// No description provided for @otherVersion.
  ///
  /// In en, this message translates to:
  /// **'Saved by someone else'**
  String get otherVersion;

  /// No description provided for @diagnostics.
  ///
  /// In en, this message translates to:
  /// **'Sync details'**
  String get diagnostics;

  /// No description provided for @noAttention.
  ///
  /// In en, this message translates to:
  /// **'Nothing needs attention'**
  String get noAttention;

  /// No description provided for @clockWrong.
  ///
  /// In en, this message translates to:
  /// **'The phone date or time looks wrong. The app uses internet time for dates.'**
  String get clockWrong;

  /// No description provided for @readOnlyBanner.
  ///
  /// In en, this message translates to:
  /// **'Not checked with the server for 30 days. Connect to the internet to keep adding records.'**
  String get readOnlyBanner;

  /// No description provided for @opFailedRetrying.
  ///
  /// In en, this message translates to:
  /// **'Could not send yet — retrying'**
  String get opFailedRetrying;

  /// No description provided for @opAttendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get opAttendance;

  /// No description provided for @opWorker.
  ///
  /// In en, this message translates to:
  /// **'Worker details'**
  String get opWorker;

  /// No description provided for @opGroup.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get opGroup;

  /// No description provided for @opWork.
  ///
  /// In en, this message translates to:
  /// **'Work entry'**
  String get opWork;

  /// No description provided for @opMoney.
  ///
  /// In en, this message translates to:
  /// **'Money entry'**
  String get opMoney;

  /// No description provided for @opSettlement.
  ///
  /// In en, this message translates to:
  /// **'Weekly accounts'**
  String get opSettlement;

  /// No description provided for @opMember.
  ///
  /// In en, this message translates to:
  /// **'Family member'**
  String get opMember;

  /// No description provided for @opFarm.
  ///
  /// In en, this message translates to:
  /// **'Farm settings'**
  String get opFarm;

  /// No description provided for @conflictAttendanceExists.
  ///
  /// In en, this message translates to:
  /// **'Attendance for this worker on this day was already marked on another phone.'**
  String get conflictAttendanceExists;

  /// No description provided for @conflictStale.
  ///
  /// In en, this message translates to:
  /// **'Someone else changed this record at the same time.'**
  String get conflictStale;

  /// No description provided for @errInsufficientLeaderFunds.
  ///
  /// In en, this message translates to:
  /// **'The leader has only {amount} left to distribute.'**
  String errInsufficientLeaderFunds(String amount);

  /// No description provided for @errWeekClosed.
  ///
  /// In en, this message translates to:
  /// **'This week\'s accounts are closed. Ask the owner to correct it.'**
  String get errWeekClosed;

  /// No description provided for @errForbidden.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission for this.'**
  String get errForbidden;

  /// No description provided for @errAccessRevoked.
  ///
  /// In en, this message translates to:
  /// **'Your access to this farm was removed.'**
  String get errAccessRevoked;

  /// No description provided for @errVerificationExpired.
  ///
  /// In en, this message translates to:
  /// **'Please connect to the internet once so the app can confirm your access.'**
  String get errVerificationExpired;

  /// No description provided for @errInvalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount'**
  String get errInvalidAmount;

  /// No description provided for @errInvalidName.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get errInvalidName;

  /// No description provided for @errInvalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get errInvalidPhone;

  /// No description provided for @errInvalidDate.
  ///
  /// In en, this message translates to:
  /// **'Choose a valid date'**
  String get errInvalidDate;

  /// No description provided for @errInvalidUnits.
  ///
  /// In en, this message translates to:
  /// **'Enter days between 0 and 3 (e.g. 0.75)'**
  String get errInvalidUnits;

  /// No description provided for @errAlreadyReversed.
  ///
  /// In en, this message translates to:
  /// **'This entry is already cancelled.'**
  String get errAlreadyReversed;

  /// No description provided for @errExceedsLoan.
  ///
  /// In en, this message translates to:
  /// **'More than the loan still owed ({amount}).'**
  String errExceedsLoan(String amount);

  /// No description provided for @errExceedsLeaderPayable.
  ///
  /// In en, this message translates to:
  /// **'More than what is owed to the leader ({amount}).'**
  String errExceedsLeaderPayable(String amount);

  /// No description provided for @errLeaderFundsUsed.
  ///
  /// In en, this message translates to:
  /// **'This money was already distributed. Only {amount} is left with the leader.'**
  String errLeaderFundsUsed(String amount);

  /// No description provided for @errLoanRepaid.
  ///
  /// In en, this message translates to:
  /// **'Part of this loan was already repaid.'**
  String get errLoanRepaid;

  /// No description provided for @errLeaderPayableSettled.
  ///
  /// In en, this message translates to:
  /// **'This was already repaid to the leader.'**
  String get errLeaderPayableSettled;

  /// No description provided for @errNotALeader.
  ///
  /// In en, this message translates to:
  /// **'Choose a worker marked as group leader.'**
  String get errNotALeader;

  /// No description provided for @errInvalidPayer.
  ///
  /// In en, this message translates to:
  /// **'Choose the family member who paid.'**
  String get errInvalidPayer;

  /// No description provided for @errReasonRequired.
  ///
  /// In en, this message translates to:
  /// **'Please write a reason.'**
  String get errReasonRequired;

  /// No description provided for @errAlreadyInvited.
  ///
  /// In en, this message translates to:
  /// **'This email is already invited.'**
  String get errAlreadyInvited;

  /// No description provided for @errCannotChangeOwner.
  ///
  /// In en, this message translates to:
  /// **'The owner\'s access cannot be changed here.'**
  String get errCannotChangeOwner;

  /// No description provided for @errInvalidWeek.
  ///
  /// In en, this message translates to:
  /// **'Choose a valid week.'**
  String get errInvalidWeek;

  /// No description provided for @errWeekInFuture.
  ///
  /// In en, this message translates to:
  /// **'This week has not started yet.'**
  String get errWeekInFuture;

  /// No description provided for @errTextTooLong.
  ///
  /// In en, this message translates to:
  /// **'Text is too long'**
  String get errTextTooLong;

  /// No description provided for @errInvalidData.
  ///
  /// In en, this message translates to:
  /// **'Some details were not valid.'**
  String get errInvalidData;

  /// No description provided for @errNotFound.
  ///
  /// In en, this message translates to:
  /// **'This record no longer exists.'**
  String get errNotFound;

  /// No description provided for @errGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errGeneric;

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'Namaskara, {name}'**
  String greeting(String name);

  /// No description provided for @todayWorkers.
  ///
  /// In en, this message translates to:
  /// **'Today\'s workers'**
  String get todayWorkers;

  /// No description provided for @peopleCount.
  ///
  /// In en, this message translates to:
  /// **'{count} workers'**
  String peopleCount(int count);

  /// No description provided for @todayWages.
  ///
  /// In en, this message translates to:
  /// **'Today\'s wages (earned)'**
  String get todayWages;

  /// No description provided for @weekEarned.
  ///
  /// In en, this message translates to:
  /// **'This week — wages earned'**
  String get weekEarned;

  /// No description provided for @wagesToPay.
  ///
  /// In en, this message translates to:
  /// **'Wages still to pay'**
  String get wagesToPay;

  /// No description provided for @advancesAhead.
  ///
  /// In en, this message translates to:
  /// **'Paid ahead of earnings (advance)'**
  String get advancesAhead;

  /// No description provided for @loansOutstanding.
  ///
  /// In en, this message translates to:
  /// **'Loans to recover'**
  String get loansOutstanding;

  /// No description provided for @leaderCashHeld.
  ///
  /// In en, this message translates to:
  /// **'With group leaders, not yet accounted'**
  String get leaderCashHeld;

  /// No description provided for @markAttendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get markAttendance;

  /// No description provided for @giveMoney.
  ///
  /// In en, this message translates to:
  /// **'Give Money'**
  String get giveMoney;

  /// No description provided for @assignWork.
  ///
  /// In en, this message translates to:
  /// **'Assign Work'**
  String get assignWork;

  /// No description provided for @weeklyAccounts.
  ///
  /// In en, this message translates to:
  /// **'Weekly Accounts'**
  String get weeklyAccounts;

  /// No description provided for @recentPayments.
  ///
  /// In en, this message translates to:
  /// **'Recent payments'**
  String get recentPayments;

  /// No description provided for @todaysWork.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Work'**
  String get todaysWork;

  /// No description provided for @noWorkToday.
  ///
  /// In en, this message translates to:
  /// **'No work recorded for today'**
  String get noWorkToday;

  /// No description provided for @noPayments.
  ///
  /// In en, this message translates to:
  /// **'No payments yet'**
  String get noPayments;

  /// No description provided for @paidByLine.
  ///
  /// In en, this message translates to:
  /// **'Paid by {name}'**
  String paidByLine(String name);

  /// No description provided for @recordedByLine.
  ///
  /// In en, this message translates to:
  /// **'Recorded by {name}'**
  String recordedByLine(String name);

  /// No description provided for @receivedByLine.
  ///
  /// In en, this message translates to:
  /// **'Received by {name}'**
  String receivedByLine(String name);

  /// No description provided for @updatedByLine.
  ///
  /// In en, this message translates to:
  /// **'Updated by {name}'**
  String updatedByLine(String name);

  /// No description provided for @earningsNote.
  ///
  /// In en, this message translates to:
  /// **'Earned = work done. Paid = money handed over. Kept separate.'**
  String get earningsNote;

  /// No description provided for @workDiary.
  ///
  /// In en, this message translates to:
  /// **'Work diary'**
  String get workDiary;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @addWorker.
  ///
  /// In en, this message translates to:
  /// **'Add worker'**
  String get addWorker;

  /// No description provided for @editWorker.
  ///
  /// In en, this message translates to:
  /// **'Edit worker'**
  String get editWorker;

  /// No description provided for @nameKannada.
  ///
  /// In en, this message translates to:
  /// **'Name (in Kannada)'**
  String get nameKannada;

  /// No description provided for @nameEnglish.
  ///
  /// In en, this message translates to:
  /// **'Name in English (optional)'**
  String get nameEnglish;

  /// No description provided for @phoneOptional.
  ///
  /// In en, this message translates to:
  /// **'Phone (optional)'**
  String get phoneOptional;

  /// No description provided for @dailyWage.
  ///
  /// In en, this message translates to:
  /// **'Daily Wage'**
  String get dailyWage;

  /// No description provided for @dailyWageRupees.
  ///
  /// In en, this message translates to:
  /// **'Daily Wage (₹)'**
  String get dailyWageRupees;

  /// No description provided for @isLeader.
  ///
  /// In en, this message translates to:
  /// **'Group leader'**
  String get isLeader;

  /// No description provided for @isLeaderHelp.
  ///
  /// In en, this message translates to:
  /// **'Can receive money to distribute to others'**
  String get isLeaderHelp;

  /// No description provided for @archiveWorker.
  ///
  /// In en, this message translates to:
  /// **'Hide from list'**
  String get archiveWorker;

  /// No description provided for @unarchiveWorker.
  ///
  /// In en, this message translates to:
  /// **'Show in list again'**
  String get unarchiveWorker;

  /// No description provided for @archiveHelp.
  ///
  /// In en, this message translates to:
  /// **'History and accounts are kept.'**
  String get archiveHelp;

  /// No description provided for @archived.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get archived;

  /// No description provided for @showArchived.
  ///
  /// In en, this message translates to:
  /// **'Show hidden workers'**
  String get showArchived;

  /// No description provided for @noWorkers.
  ///
  /// In en, this message translates to:
  /// **'No workers yet. Add your first worker.'**
  String get noWorkers;

  /// No description provided for @noMatches.
  ///
  /// In en, this message translates to:
  /// **'No one matches'**
  String get noMatches;

  /// No description provided for @wageDue.
  ///
  /// In en, this message translates to:
  /// **'Wages due'**
  String get wageDue;

  /// No description provided for @advanceAhead.
  ///
  /// In en, this message translates to:
  /// **'Advance given'**
  String get advanceAhead;

  /// No description provided for @settledUp.
  ///
  /// In en, this message translates to:
  /// **'Settled'**
  String get settledUp;

  /// No description provided for @loanDue.
  ///
  /// In en, this message translates to:
  /// **'Loan'**
  String get loanDue;

  /// No description provided for @tabAttendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get tabAttendance;

  /// No description provided for @tabWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get tabWork;

  /// No description provided for @tabMoney.
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get tabMoney;

  /// No description provided for @groups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groups;

  /// No description provided for @addGroup.
  ///
  /// In en, this message translates to:
  /// **'Add group'**
  String get addGroup;

  /// No description provided for @editGroup.
  ///
  /// In en, this message translates to:
  /// **'Edit group'**
  String get editGroup;

  /// No description provided for @groupName.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get groupName;

  /// No description provided for @leader.
  ///
  /// In en, this message translates to:
  /// **'Leader'**
  String get leader;

  /// No description provided for @noLeader.
  ///
  /// In en, this message translates to:
  /// **'No leader'**
  String get noLeader;

  /// No description provided for @members.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get members;

  /// No description provided for @selectWorkers.
  ///
  /// In en, this message translates to:
  /// **'Select workers'**
  String get selectWorkers;

  /// No description provided for @noGroups.
  ///
  /// In en, this message translates to:
  /// **'No groups yet. Groups help mark attendance for a crew quickly.'**
  String get noGroups;

  /// No description provided for @memberCount.
  ///
  /// In en, this message translates to:
  /// **'{count} members'**
  String memberCount(int count);

  /// No description provided for @wageChangeNote.
  ///
  /// In en, this message translates to:
  /// **'A new wage applies to new attendance only. Past days keep their rate.'**
  String get wageChangeNote;

  /// No description provided for @workerDetails.
  ///
  /// In en, this message translates to:
  /// **'Worker'**
  String get workerDetails;

  /// No description provided for @groupLeaderBadge.
  ///
  /// In en, this message translates to:
  /// **'Leader'**
  String get groupLeaderBadge;

  /// No description provided for @addAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Add adjustment'**
  String get addAdjustment;

  /// No description provided for @adjustmentHelp.
  ///
  /// In en, this message translates to:
  /// **'Extra earnings, deductions, previous balance or loan repayments.'**
  String get adjustmentHelp;

  /// No description provided for @openingBalanceHelp.
  ///
  /// In en, this message translates to:
  /// **'Use a minus sign if the worker owed the farm (e.g. -500).'**
  String get openingBalanceHelp;

  /// No description provided for @statement.
  ///
  /// In en, this message translates to:
  /// **'Statement'**
  String get statement;

  /// No description provided for @fullDay.
  ///
  /// In en, this message translates to:
  /// **'Full day'**
  String get fullDay;

  /// No description provided for @halfDay.
  ///
  /// In en, this message translates to:
  /// **'Half day'**
  String get halfDay;

  /// No description provided for @absent.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get absent;

  /// No description provided for @customUnitsShort.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get customUnitsShort;

  /// No description provided for @customUnits.
  ///
  /// In en, this message translates to:
  /// **'Days worked (e.g. 0.75)'**
  String get customUnits;

  /// No description provided for @rateForDay.
  ///
  /// In en, this message translates to:
  /// **'Wage for this day (₹)'**
  String get rateForDay;

  /// No description provided for @markAllFull.
  ///
  /// In en, this message translates to:
  /// **'All full day'**
  String get markAllFull;

  /// No description provided for @presentCount.
  ///
  /// In en, this message translates to:
  /// **'Present: {count}'**
  String presentCount(int count);

  /// No description provided for @saveAttendance.
  ///
  /// In en, this message translates to:
  /// **'Save attendance'**
  String get saveAttendance;

  /// No description provided for @attendanceSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved {count} changes'**
  String attendanceSaved(int count);

  /// No description provided for @noChanges.
  ///
  /// In en, this message translates to:
  /// **'No changes to save'**
  String get noChanges;

  /// No description provided for @addNewWorker.
  ///
  /// In en, this message translates to:
  /// **'Add a new worker'**
  String get addNewWorker;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @attendanceHistory.
  ///
  /// In en, this message translates to:
  /// **'Attendance history'**
  String get attendanceHistory;

  /// No description provided for @unsavedChanges.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Leave without saving?'**
  String get unsavedChanges;

  /// No description provided for @leave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// No description provided for @weekClosedNote.
  ///
  /// In en, this message translates to:
  /// **'This week\'s accounts are closed.'**
  String get weekClosedNote;

  /// No description provided for @noActiveWorkers.
  ///
  /// In en, this message translates to:
  /// **'Add workers first'**
  String get noActiveWorkers;

  /// No description provided for @daysShort.
  ///
  /// In en, this message translates to:
  /// **'{days} d'**
  String daysShort(String days);

  /// No description provided for @atRate.
  ///
  /// In en, this message translates to:
  /// **'@ {amount}/day'**
  String atRate(String amount);

  /// No description provided for @changeGroup.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get changeGroup;

  /// No description provided for @markGroup.
  ///
  /// In en, this message translates to:
  /// **'Mark {group} full day'**
  String markGroup(String group);

  /// No description provided for @addWork.
  ///
  /// In en, this message translates to:
  /// **'Add work'**
  String get addWork;

  /// No description provided for @editWork.
  ///
  /// In en, this message translates to:
  /// **'Edit work'**
  String get editWork;

  /// No description provided for @workType.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get workType;

  /// No description provided for @fieldName.
  ///
  /// In en, this message translates to:
  /// **'Field / plot (optional)'**
  String get fieldName;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get description;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @statusPlanned.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get statusPlanned;

  /// No description provided for @statusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get statusInProgress;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @assignedBy.
  ///
  /// In en, this message translates to:
  /// **'Assigned by {name}'**
  String assignedBy(String name);

  /// No description provided for @noWork.
  ///
  /// In en, this message translates to:
  /// **'No work recorded'**
  String get noWork;

  /// No description provided for @tasksDontMultiply.
  ///
  /// In en, this message translates to:
  /// **'Tasks do not change wages — wages come from attendance.'**
  String get tasksDontMultiply;

  /// No description provided for @addWorkType.
  ///
  /// In en, this message translates to:
  /// **'New type of work'**
  String get addWorkType;

  /// No description provided for @workTypeName.
  ///
  /// In en, this message translates to:
  /// **'Name of the work'**
  String get workTypeName;

  /// No description provided for @chooseWorkType.
  ///
  /// In en, this message translates to:
  /// **'Choose work'**
  String get chooseWorkType;

  /// No description provided for @last30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get last30Days;

  /// No description provided for @recipient.
  ///
  /// In en, this message translates to:
  /// **'To whom'**
  String get recipient;

  /// No description provided for @selectWorker.
  ///
  /// In en, this message translates to:
  /// **'Select worker'**
  String get selectWorker;

  /// No description provided for @selectLeader.
  ///
  /// In en, this message translates to:
  /// **'Select group leader'**
  String get selectLeader;

  /// No description provided for @purpose.
  ///
  /// In en, this message translates to:
  /// **'Purpose'**
  String get purpose;

  /// No description provided for @paidBy.
  ///
  /// In en, this message translates to:
  /// **'Paid By'**
  String get paidBy;

  /// No description provided for @receivedBy.
  ///
  /// In en, this message translates to:
  /// **'Received by'**
  String get receivedBy;

  /// No description provided for @method.
  ///
  /// In en, this message translates to:
  /// **'How paid'**
  String get method;

  /// No description provided for @methodCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get methodCash;

  /// No description provided for @methodUpi.
  ///
  /// In en, this message translates to:
  /// **'UPI'**
  String get methodUpi;

  /// No description provided for @methodBank.
  ///
  /// In en, this message translates to:
  /// **'Bank transfer'**
  String get methodBank;

  /// No description provided for @methodOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get methodOther;

  /// No description provided for @reference.
  ///
  /// In en, this message translates to:
  /// **'Reference no. (optional)'**
  String get reference;

  /// No description provided for @typeAdvance.
  ///
  /// In en, this message translates to:
  /// **'Advance'**
  String get typeAdvance;

  /// No description provided for @typeWagePayment.
  ///
  /// In en, this message translates to:
  /// **'Wage payment'**
  String get typeWagePayment;

  /// No description provided for @typeBonus.
  ///
  /// In en, this message translates to:
  /// **'Bonus'**
  String get typeBonus;

  /// No description provided for @typeAddition.
  ///
  /// In en, this message translates to:
  /// **'Extra earning'**
  String get typeAddition;

  /// No description provided for @typeDeduction.
  ///
  /// In en, this message translates to:
  /// **'Deduction'**
  String get typeDeduction;

  /// No description provided for @typeOpeningBalance.
  ///
  /// In en, this message translates to:
  /// **'Previous balance'**
  String get typeOpeningBalance;

  /// No description provided for @typeLoan.
  ///
  /// In en, this message translates to:
  /// **'Personal loan'**
  String get typeLoan;

  /// No description provided for @typeLoanRepayment.
  ///
  /// In en, this message translates to:
  /// **'Loan repaid in cash'**
  String get typeLoanRepayment;

  /// No description provided for @typeLoanOffset.
  ///
  /// In en, this message translates to:
  /// **'Loan cut from wages'**
  String get typeLoanOffset;

  /// No description provided for @typeReimbursement.
  ///
  /// In en, this message translates to:
  /// **'Expense paid back'**
  String get typeReimbursement;

  /// No description provided for @typeLeaderTransfer.
  ///
  /// In en, this message translates to:
  /// **'Money for leader to distribute'**
  String get typeLeaderTransfer;

  /// No description provided for @typeLeaderAllocation.
  ///
  /// In en, this message translates to:
  /// **'Paid through leader'**
  String get typeLeaderAllocation;

  /// No description provided for @typeLeaderReturn.
  ///
  /// In en, this message translates to:
  /// **'Returned by leader'**
  String get typeLeaderReturn;

  /// No description provided for @typeLeaderSelfFunded.
  ///
  /// In en, this message translates to:
  /// **'Leader paid from own money'**
  String get typeLeaderSelfFunded;

  /// No description provided for @helpAdvance.
  ///
  /// In en, this message translates to:
  /// **'Given before wages are due. Deducted in the weekly accounts.'**
  String get helpAdvance;

  /// No description provided for @helpWagePayment.
  ///
  /// In en, this message translates to:
  /// **'Paying wages already earned.'**
  String get helpWagePayment;

  /// No description provided for @helpLeaderTransfer.
  ///
  /// In en, this message translates to:
  /// **'This money is entrusted to the leader to give to other workers. It is not the leader\'s own wages.'**
  String get helpLeaderTransfer;

  /// No description provided for @helpLoan.
  ///
  /// In en, this message translates to:
  /// **'Kept separate from wages. Not deducted unless you choose to.'**
  String get helpLoan;

  /// No description provided for @helpBonus.
  ///
  /// In en, this message translates to:
  /// **'Extra pay given now. Counted as wages earned and paid.'**
  String get helpBonus;

  /// No description provided for @helpReimbursement.
  ///
  /// In en, this message translates to:
  /// **'Paying back money they spent for the farm. Not wages.'**
  String get helpReimbursement;

  /// No description provided for @helpAddition.
  ///
  /// In en, this message translates to:
  /// **'Extra wages earned (paid later).'**
  String get helpAddition;

  /// No description provided for @helpDeduction.
  ///
  /// In en, this message translates to:
  /// **'Reduces wages earned.'**
  String get helpDeduction;

  /// No description provided for @helpLoanOffset.
  ///
  /// In en, this message translates to:
  /// **'Part of the wages is kept to repay the loan. No cash changes hands.'**
  String get helpLoanOffset;

  /// No description provided for @leaderHolds.
  ///
  /// In en, this message translates to:
  /// **'Now with leader to distribute: {amount}'**
  String leaderHolds(String amount);

  /// No description provided for @largeAmountConfirm.
  ///
  /// In en, this message translates to:
  /// **'{amount} is a large amount. Is it correct?'**
  String largeAmountConfirm(String amount);

  /// No description provided for @duplicateConfirm.
  ///
  /// In en, this message translates to:
  /// **'{amount} to {worker} was already recorded recently. Record another one?'**
  String duplicateConfirm(String amount, String worker);

  /// No description provided for @yesRecord.
  ///
  /// In en, this message translates to:
  /// **'Yes, record it'**
  String get yesRecord;

  /// No description provided for @checkAgainBtn.
  ///
  /// In en, this message translates to:
  /// **'Let me check'**
  String get checkAgainBtn;

  /// No description provided for @savedOnDeviceToast.
  ///
  /// In en, this message translates to:
  /// **'Saved on device'**
  String get savedOnDeviceToast;

  /// No description provided for @savedAndSyncedToast.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get savedAndSyncedToast;

  /// No description provided for @nowBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance now: {amount}'**
  String nowBalance(String amount);

  /// No description provided for @paymentHistory.
  ///
  /// In en, this message translates to:
  /// **'Payment history'**
  String get paymentHistory;

  /// No description provided for @filterWorker.
  ///
  /// In en, this message translates to:
  /// **'Worker'**
  String get filterWorker;

  /// No description provided for @filterPayer.
  ///
  /// In en, this message translates to:
  /// **'Paid by'**
  String get filterPayer;

  /// No description provided for @filterType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get filterType;

  /// No description provided for @noEntries.
  ///
  /// In en, this message translates to:
  /// **'No entries'**
  String get noEntries;

  /// No description provided for @entryDetails.
  ///
  /// In en, this message translates to:
  /// **'Entry details'**
  String get entryDetails;

  /// No description provided for @reverseEntry.
  ///
  /// In en, this message translates to:
  /// **'Cancel this entry'**
  String get reverseEntry;

  /// No description provided for @correctEntry.
  ///
  /// In en, this message translates to:
  /// **'Correct this entry'**
  String get correctEntry;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// No description provided for @reversedLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get reversedLabel;

  /// No description provided for @reversalLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancellation of an earlier entry'**
  String get reversalLabel;

  /// No description provided for @reverseExplain.
  ///
  /// In en, this message translates to:
  /// **'The original stays in history and a cancelling entry is added.'**
  String get reverseExplain;

  /// No description provided for @correctExplain.
  ///
  /// In en, this message translates to:
  /// **'The old entry is cancelled and this corrected one is recorded.'**
  String get correctExplain;

  /// No description provided for @changeHistory.
  ///
  /// In en, this message translates to:
  /// **'Change history'**
  String get changeHistory;

  /// No description provided for @worker.
  ///
  /// In en, this message translates to:
  /// **'Worker'**
  String get worker;

  /// No description provided for @dateTime.
  ///
  /// In en, this message translates to:
  /// **'Date and time'**
  String get dateTime;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @allTypes.
  ///
  /// In en, this message translates to:
  /// **'All types'**
  String get allTypes;

  /// No description provided for @everyone.
  ///
  /// In en, this message translates to:
  /// **'Everyone'**
  String get everyone;

  /// No description provided for @anyDate.
  ///
  /// In en, this message translates to:
  /// **'Any date'**
  String get anyDate;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @chooseDates.
  ///
  /// In en, this message translates to:
  /// **'Choose dates'**
  String get chooseDates;

  /// No description provided for @accountsTitle.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get accountsTitle;

  /// No description provided for @balancesTitle.
  ///
  /// In en, this message translates to:
  /// **'Balances'**
  String get balancesTitle;

  /// No description provided for @leaderFunds.
  ///
  /// In en, this message translates to:
  /// **'Group leader money'**
  String get leaderFunds;

  /// No description provided for @entrusted.
  ///
  /// In en, this message translates to:
  /// **'Entrusted'**
  String get entrusted;

  /// No description provided for @distributed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed distributed'**
  String get distributed;

  /// No description provided for @returned.
  ///
  /// In en, this message translates to:
  /// **'Returned'**
  String get returned;

  /// No description provided for @unreconciled.
  ///
  /// In en, this message translates to:
  /// **'Not yet accounted'**
  String get unreconciled;

  /// No description provided for @pendingVerificationAmount.
  ///
  /// In en, this message translates to:
  /// **'{amount} waiting for verification'**
  String pendingVerificationAmount(String amount);

  /// No description provided for @ownPocketOwed.
  ///
  /// In en, this message translates to:
  /// **'Owed to leader (paid from own money)'**
  String get ownPocketOwed;

  /// No description provided for @recordDistribution.
  ///
  /// In en, this message translates to:
  /// **'Record distribution'**
  String get recordDistribution;

  /// No description provided for @recordReturn.
  ///
  /// In en, this message translates to:
  /// **'Leader returned cash'**
  String get recordReturn;

  /// No description provided for @recordOwnPocket.
  ///
  /// In en, this message translates to:
  /// **'Leader paid from own money'**
  String get recordOwnPocket;

  /// No description provided for @repayLeader.
  ///
  /// In en, this message translates to:
  /// **'Repay leader'**
  String get repayLeader;

  /// No description provided for @giveToLeader.
  ///
  /// In en, this message translates to:
  /// **'Give money to leader'**
  String get giveToLeader;

  /// No description provided for @distributeHelp.
  ///
  /// In en, this message translates to:
  /// **'Enter how much the leader gave each worker.'**
  String get distributeHelp;

  /// No description provided for @ownPocketHelp.
  ///
  /// In en, this message translates to:
  /// **'Wages the leader paid to workers from their own money. The farm owes this to the leader.'**
  String get ownPocketHelp;

  /// No description provided for @distributionTotal.
  ///
  /// In en, this message translates to:
  /// **'Total {amount} of {available}'**
  String distributionTotal(String amount, String available);

  /// No description provided for @exceedsAvailable.
  ///
  /// In en, this message translates to:
  /// **'More than the leader holds'**
  String get exceedsAvailable;

  /// No description provided for @noLeaders.
  ///
  /// In en, this message translates to:
  /// **'No group leaders. Mark a worker as group leader in their details.'**
  String get noLeaders;

  /// No description provided for @leaderSelfShare.
  ///
  /// In en, this message translates to:
  /// **'(leader\'s own wages)'**
  String get leaderSelfShare;

  /// No description provided for @leaderPersonalNote.
  ///
  /// In en, this message translates to:
  /// **'The leader\'s own wages and advances are in their worker page, separate from this money.'**
  String get leaderPersonalNote;

  /// No description provided for @distributionSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved {count} distributions'**
  String distributionSaved(int count);

  /// No description provided for @weeklySettlement.
  ///
  /// In en, this message translates to:
  /// **'Weekly Settlement'**
  String get weeklySettlement;

  /// No description provided for @openingBalance.
  ///
  /// In en, this message translates to:
  /// **'Previous balance'**
  String get openingBalance;

  /// No description provided for @daysWorked.
  ///
  /// In en, this message translates to:
  /// **'Days worked'**
  String get daysWorked;

  /// No description provided for @earned.
  ///
  /// In en, this message translates to:
  /// **'Earned'**
  String get earned;

  /// No description provided for @additions.
  ///
  /// In en, this message translates to:
  /// **'Extra / adjustments'**
  String get additions;

  /// No description provided for @advanceGiven.
  ///
  /// In en, this message translates to:
  /// **'Advance'**
  String get advanceGiven;

  /// No description provided for @paidDirect.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paidDirect;

  /// No description provided for @paidViaLeader.
  ///
  /// In en, this message translates to:
  /// **'Paid through leader'**
  String get paidViaLeader;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @overpaid.
  ///
  /// In en, this message translates to:
  /// **'Paid extra (carried forward as advance)'**
  String get overpaid;

  /// No description provided for @payAmount.
  ///
  /// In en, this message translates to:
  /// **'Pay {amount}'**
  String payAmount(String amount);

  /// No description provided for @payPart.
  ///
  /// In en, this message translates to:
  /// **'Pay part'**
  String get payPart;

  /// No description provided for @closeWeek.
  ///
  /// In en, this message translates to:
  /// **'Close week'**
  String get closeWeek;

  /// No description provided for @closeWeekHelp.
  ///
  /// In en, this message translates to:
  /// **'Closing marks the week as checked. Unpaid balances carry to next week. Records stay correctable.'**
  String get closeWeekHelp;

  /// No description provided for @weekClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get weekClosed;

  /// No description provided for @weekOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get weekOpen;

  /// No description provided for @needsReview.
  ///
  /// In en, this message translates to:
  /// **'Changed after closing — please review'**
  String get needsReview;

  /// No description provided for @markReviewed.
  ///
  /// In en, this message translates to:
  /// **'Mark reviewed'**
  String get markReviewed;

  /// No description provided for @reopenWeek.
  ///
  /// In en, this message translates to:
  /// **'Reopen week'**
  String get reopenWeek;

  /// No description provided for @closedBy.
  ///
  /// In en, this message translates to:
  /// **'Closed by {name}'**
  String closedBy(String name);

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @weekTotalDue.
  ///
  /// In en, this message translates to:
  /// **'Total remaining'**
  String get weekTotalDue;

  /// No description provided for @weekTotalEarned.
  ///
  /// In en, this message translates to:
  /// **'Total earned'**
  String get weekTotalEarned;

  /// No description provided for @previousWeek.
  ///
  /// In en, this message translates to:
  /// **'Previous week'**
  String get previousWeek;

  /// No description provided for @nextWeek.
  ///
  /// In en, this message translates to:
  /// **'Next week'**
  String get nextWeek;

  /// No description provided for @noActivityWeek.
  ///
  /// In en, this message translates to:
  /// **'No work or payments this week'**
  String get noActivityWeek;

  /// No description provided for @atClosing.
  ///
  /// In en, this message translates to:
  /// **'At closing: {amount}'**
  String atClosing(String amount);

  /// No description provided for @payConfirm.
  ///
  /// In en, this message translates to:
  /// **'Record {amount} paid to {worker}?'**
  String payConfirm(String amount, String worker);

  /// No description provided for @pastWeeks.
  ///
  /// In en, this message translates to:
  /// **'Past weeks'**
  String get pastWeeks;

  /// No description provided for @stmtHeader.
  ///
  /// In en, this message translates to:
  /// **'ShramaSiri — wage statement'**
  String get stmtHeader;

  /// No description provided for @stmtWeek.
  ///
  /// In en, this message translates to:
  /// **'Week: {range}'**
  String stmtWeek(String range);

  /// No description provided for @stmtFarm.
  ///
  /// In en, this message translates to:
  /// **'Farm: {farm}'**
  String stmtFarm(String farm);

  /// No description provided for @stmtDays.
  ///
  /// In en, this message translates to:
  /// **'Days worked: {days}'**
  String stmtDays(String days);

  /// No description provided for @stmtRate.
  ///
  /// In en, this message translates to:
  /// **'Daily wage: {amount}'**
  String stmtRate(String amount);

  /// No description provided for @stmtLine.
  ///
  /// In en, this message translates to:
  /// **'{label}: {amount}'**
  String stmtLine(String label, String amount);

  /// No description provided for @stmtFooter.
  ///
  /// In en, this message translates to:
  /// **'Prepared by {name}'**
  String stmtFooter(String name);

  /// No description provided for @workersInWeek.
  ///
  /// In en, this message translates to:
  /// **'{count} workers'**
  String workersInWeek(int count);

  /// No description provided for @labourCost.
  ///
  /// In en, this message translates to:
  /// **'Labour cost (wages earned)'**
  String get labourCost;

  /// No description provided for @cashPaidOut.
  ///
  /// In en, this message translates to:
  /// **'Cash paid out'**
  String get cashPaidOut;

  /// No description provided for @cashReturned.
  ///
  /// In en, this message translates to:
  /// **'Cash returned to farm'**
  String get cashReturned;

  /// No description provided for @netCash.
  ///
  /// In en, this message translates to:
  /// **'Net cash out'**
  String get netCash;

  /// No description provided for @outstandingNow.
  ///
  /// In en, this message translates to:
  /// **'Outstanding now'**
  String get outstandingNow;

  /// No description provided for @byWorker.
  ///
  /// In en, this message translates to:
  /// **'By worker'**
  String get byWorker;

  /// No description provided for @byFamilyMember.
  ///
  /// In en, this message translates to:
  /// **'Paid by family member'**
  String get byFamilyMember;

  /// No description provided for @byWorkType.
  ///
  /// In en, this message translates to:
  /// **'By work (approximate)'**
  String get byWorkType;

  /// No description provided for @byPaymentType.
  ///
  /// In en, this message translates to:
  /// **'By type'**
  String get byPaymentType;

  /// No description provided for @noTask.
  ///
  /// In en, this message translates to:
  /// **'No task recorded'**
  String get noTask;

  /// No description provided for @attendanceSummary.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get attendanceSummary;

  /// No description provided for @periodToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get periodToday;

  /// No description provided for @periodWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get periodWeek;

  /// No description provided for @periodMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get periodMonth;

  /// No description provided for @periodCustom.
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get periodCustom;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get exportCsv;

  /// No description provided for @shareSummary.
  ///
  /// In en, this message translates to:
  /// **'Share summary'**
  String get shareSummary;

  /// No description provided for @settlementHistory.
  ///
  /// In en, this message translates to:
  /// **'Weekly settlements'**
  String get settlementHistory;

  /// No description provided for @reportNote.
  ///
  /// In en, this message translates to:
  /// **'Earned wages, cash paid, balances and leader money are shown separately on purpose.'**
  String get reportNote;

  /// No description provided for @summaryTitle.
  ///
  /// In en, this message translates to:
  /// **'ShramaSiri summary {range}'**
  String summaryTitle(String range);

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @weekStartsOn.
  ///
  /// In en, this message translates to:
  /// **'Wage week starts on'**
  String get weekStartsOn;

  /// No description provided for @currencyNote.
  ///
  /// In en, this message translates to:
  /// **'Currency: Indian Rupee (₹)'**
  String get currencyNote;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'My details'**
  String get profile;

  /// No description provided for @familyMembers.
  ///
  /// In en, this message translates to:
  /// **'Family members'**
  String get familyMembers;

  /// No description provided for @inviteMember.
  ///
  /// In en, this message translates to:
  /// **'Invite family member'**
  String get inviteMember;

  /// No description provided for @inviteHelp.
  ///
  /// In en, this message translates to:
  /// **'They should install the app and create an account with this same email.'**
  String get inviteHelp;

  /// No description provided for @roleOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get roleOwner;

  /// No description provided for @roleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get roleAdmin;

  /// No description provided for @roleMember.
  ///
  /// In en, this message translates to:
  /// **'Family member'**
  String get roleMember;

  /// No description provided for @memberInvited.
  ///
  /// In en, this message translates to:
  /// **'Invited — not joined yet'**
  String get memberInvited;

  /// No description provided for @memberDisabled.
  ///
  /// In en, this message translates to:
  /// **'Access removed'**
  String get memberDisabled;

  /// No description provided for @disableAccess.
  ///
  /// In en, this message translates to:
  /// **'Remove access'**
  String get disableAccess;

  /// No description provided for @enableAccess.
  ///
  /// In en, this message translates to:
  /// **'Restore access'**
  String get enableAccess;

  /// No description provided for @makeAdmin.
  ///
  /// In en, this message translates to:
  /// **'Make admin'**
  String get makeAdmin;

  /// No description provided for @makeMember.
  ///
  /// In en, this message translates to:
  /// **'Make regular member'**
  String get makeMember;

  /// No description provided for @disableConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}\'s access? Their past records stay.'**
  String disableConfirm(String name);

  /// No description provided for @auditHistory.
  ///
  /// In en, this message translates to:
  /// **'Activity history'**
  String get auditHistory;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String version(String version);

  /// No description provided for @aboutText.
  ///
  /// In en, this message translates to:
  /// **'ShramaSiri is a simple notebook for farm labour, wages and payments. It works without internet and syncs safely between family phones.'**
  String get aboutText;

  /// No description provided for @farmSection.
  ///
  /// In en, this message translates to:
  /// **'Farm'**
  String get farmSection;

  /// No description provided for @accountSection.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountSection;

  /// No description provided for @workTypes.
  ///
  /// In en, this message translates to:
  /// **'Types of work'**
  String get workTypes;

  /// No description provided for @ownerOnly.
  ///
  /// In en, this message translates to:
  /// **'Only the owner or admin can change this.'**
  String get ownerOnly;

  /// No description provided for @loggedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {email}'**
  String loggedInAs(String email);

  /// No description provided for @auditWorkerCreated.
  ///
  /// In en, this message translates to:
  /// **'Worker added'**
  String get auditWorkerCreated;

  /// No description provided for @auditWorkerUpdated.
  ///
  /// In en, this message translates to:
  /// **'Worker details changed'**
  String get auditWorkerUpdated;

  /// No description provided for @auditWorkerArchived.
  ///
  /// In en, this message translates to:
  /// **'Worker hidden'**
  String get auditWorkerArchived;

  /// No description provided for @auditAttendanceMarked.
  ///
  /// In en, this message translates to:
  /// **'Attendance marked'**
  String get auditAttendanceMarked;

  /// No description provided for @auditAttendanceCorrected.
  ///
  /// In en, this message translates to:
  /// **'Attendance corrected'**
  String get auditAttendanceCorrected;

  /// No description provided for @auditWorkAssigned.
  ///
  /// In en, this message translates to:
  /// **'Work assigned'**
  String get auditWorkAssigned;

  /// No description provided for @auditWorkUpdated.
  ///
  /// In en, this message translates to:
  /// **'Work changed'**
  String get auditWorkUpdated;

  /// No description provided for @auditMoney.
  ///
  /// In en, this message translates to:
  /// **'Money recorded: {type}'**
  String auditMoney(String type);

  /// No description provided for @auditReversed.
  ///
  /// In en, this message translates to:
  /// **'Entry cancelled'**
  String get auditReversed;

  /// No description provided for @auditSettlementClosed.
  ///
  /// In en, this message translates to:
  /// **'Week closed'**
  String get auditSettlementClosed;

  /// No description provided for @auditSettlementReviewed.
  ///
  /// In en, this message translates to:
  /// **'Week reviewed'**
  String get auditSettlementReviewed;

  /// No description provided for @auditSettlementReopened.
  ///
  /// In en, this message translates to:
  /// **'Week reopened'**
  String get auditSettlementReopened;

  /// No description provided for @auditMemberInvited.
  ///
  /// In en, this message translates to:
  /// **'Family member invited'**
  String get auditMemberInvited;

  /// No description provided for @auditMemberJoined.
  ///
  /// In en, this message translates to:
  /// **'Family member joined'**
  String get auditMemberJoined;

  /// No description provided for @auditMemberUpdated.
  ///
  /// In en, this message translates to:
  /// **'Access changed'**
  String get auditMemberUpdated;

  /// No description provided for @auditOther.
  ///
  /// In en, this message translates to:
  /// **'Change: {action}'**
  String auditOther(String action);

  /// No description provided for @addPresentWorkers.
  ///
  /// In en, this message translates to:
  /// **'Add everyone present that day'**
  String get addPresentWorkers;

  /// No description provided for @recordedBy.
  ///
  /// In en, this message translates to:
  /// **'Recorded by'**
  String get recordedBy;

  /// No description provided for @daysUnit.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get daysUnit;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @fullDayShort.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get fullDayShort;

  /// No description provided for @halfDayShort.
  ///
  /// In en, this message translates to:
  /// **'Half'**
  String get halfDayShort;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'kn'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'kn':
      return AppLocalizationsKn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
