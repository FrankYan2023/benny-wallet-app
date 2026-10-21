import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('ja'),
    Locale('ko'),
    Locale('ru'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Benny Wallet'**
  String get appTitle;

  /// No description provided for @brandShortName.
  ///
  /// In en, this message translates to:
  /// **'Benny'**
  String get brandShortName;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @commonCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get commonCopied;

  /// No description provided for @commonCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get commonCopy;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @commonLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get commonLater;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get commonLoading;

  /// No description provided for @commonMax.
  ///
  /// In en, this message translates to:
  /// **'MAX'**
  String get commonMax;

  /// No description provided for @commonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get commonSettings;

  /// No description provided for @commonShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get commonShare;

  /// No description provided for @commonUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get commonUpdate;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageTraditionalChinese.
  ///
  /// In en, this message translates to:
  /// **'Traditional Chinese'**
  String get languageTraditionalChinese;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// No description provided for @languageJapanese.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get languageJapanese;

  /// No description provided for @languageRussian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get languageRussian;

  /// No description provided for @languageKorean.
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get languageKorean;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Benny'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the app language'**
  String get settingsLanguageSubtitle;

  /// No description provided for @settingsLanguageSystemDescription.
  ///
  /// In en, this message translates to:
  /// **'Follow this device'**
  String get settingsLanguageSystemDescription;

  /// No description provided for @settingsLanguageSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageSheetTitle;

  /// No description provided for @settingsLanguageSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the language used in Benny.'**
  String get settingsLanguageSheetSubtitle;

  /// No description provided for @settingsBiometricUnlock.
  ///
  /// In en, this message translates to:
  /// **'Biometric unlock'**
  String get settingsBiometricUnlock;

  /// No description provided for @settingsUseFingerprint.
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint'**
  String get settingsUseFingerprint;

  /// No description provided for @settingsUnlockWalletToEnable.
  ///
  /// In en, this message translates to:
  /// **'Unlock wallet to enable'**
  String get settingsUnlockWalletToEnable;

  /// No description provided for @settingsAutoLock.
  ///
  /// In en, this message translates to:
  /// **'Auto lock'**
  String get settingsAutoLock;

  /// No description provided for @settingsAutoLockSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose when Benny locks again.'**
  String get settingsAutoLockSheetSubtitle;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Receive notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get an alert when funds arrive'**
  String get settingsNotificationsSubtitle;

  /// No description provided for @settingsChildMode.
  ///
  /// In en, this message translates to:
  /// **'Child mode'**
  String get settingsChildMode;

  /// No description provided for @settingsChildModeActive.
  ///
  /// In en, this message translates to:
  /// **'Child mode is active'**
  String get settingsChildModeActive;

  /// No description provided for @settingsChildModeActiveDescription.
  ///
  /// In en, this message translates to:
  /// **'The wallet stays in receive-only mode until the 4-digit child mode PIN is entered.'**
  String get settingsChildModeActiveDescription;

  /// No description provided for @settingsChildModeProtected.
  ///
  /// In en, this message translates to:
  /// **'Protected by a 4-digit child mode PIN'**
  String get settingsChildModeProtected;

  /// No description provided for @settingsChildModeRemoveAccounts.
  ///
  /// In en, this message translates to:
  /// **'Remove all child accounts before enabling'**
  String get settingsChildModeRemoveAccounts;

  /// No description provided for @settingsChildModeSetPin.
  ///
  /// In en, this message translates to:
  /// **'Set a separate 4-digit PIN for child mode'**
  String get settingsChildModeSetPin;

  /// No description provided for @settingsChildAccounts.
  ///
  /// In en, this message translates to:
  /// **'Child accounts'**
  String get settingsChildAccounts;

  /// No description provided for @settingsRentReclaim.
  ///
  /// In en, this message translates to:
  /// **'Rent reclaim'**
  String get settingsRentReclaim;

  /// No description provided for @settingsRentReclaimSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Close empty token accounts and recover SOL'**
  String get settingsRentReclaimSubtitle;

  /// No description provided for @settingsFeedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get settingsFeedback;

  /// No description provided for @settingsFeedbackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Report a problem or ask a question'**
  String get settingsFeedbackSubtitle;

  /// No description provided for @settingsLogOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get settingsLogOut;

  /// No description provided for @settingsLogOutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Return to the home screen'**
  String get settingsLogOutSubtitle;

  /// No description provided for @settingsIncorrectPin.
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN'**
  String get settingsIncorrectPin;

  /// No description provided for @settingsPersistentBiometricUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Persistent biometric unlock is not supported on this device.'**
  String get settingsPersistentBiometricUnsupported;

  /// No description provided for @settingsBiometricsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Biometrics are not available on this device.'**
  String get settingsBiometricsUnavailable;

  /// No description provided for @settingsBiometricEnabled.
  ///
  /// In en, this message translates to:
  /// **'Biometric enabled'**
  String get settingsBiometricEnabled;

  /// No description provided for @settingsBiometricDisabled.
  ///
  /// In en, this message translates to:
  /// **'Biometric disabled'**
  String get settingsBiometricDisabled;

  /// No description provided for @settingsUnlockBeforeBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Unlock the wallet before enabling biometrics.'**
  String get settingsUnlockBeforeBiometrics;

  /// No description provided for @settingsNotificationsSystemDisabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications are disabled. Enable them in system settings.'**
  String get settingsNotificationsSystemDisabled;

  /// No description provided for @settingsNotificationsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Receive notifications enabled'**
  String get settingsNotificationsEnabled;

  /// No description provided for @settingsNotificationsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Receive notifications disabled'**
  String get settingsNotificationsDisabled;

  /// No description provided for @settingsNotificationsUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update notifications: {error}'**
  String settingsNotificationsUpdateFailed(String error);

  /// No description provided for @settingsRemoveChildAccountsFirst.
  ///
  /// In en, this message translates to:
  /// **'Remove all child accounts before enabling child mode.'**
  String get settingsRemoveChildAccountsFirst;

  /// No description provided for @settingsChildModeEnabled.
  ///
  /// In en, this message translates to:
  /// **'Child mode enabled'**
  String get settingsChildModeEnabled;

  /// No description provided for @settingsChildModeDisabled.
  ///
  /// In en, this message translates to:
  /// **'Child mode disabled'**
  String get settingsChildModeDisabled;

  /// No description provided for @settingsChildModeUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update child mode: {error}'**
  String settingsChildModeUpdateFailed(String error);

  /// No description provided for @settingsCopyRecoveryPhraseFirst.
  ///
  /// In en, this message translates to:
  /// **'Copy your recovery phrase first.'**
  String get settingsCopyRecoveryPhraseFirst;

  /// No description provided for @settingsLogOutWarning.
  ///
  /// In en, this message translates to:
  /// **'Logging out will clear all local app data on this device.'**
  String get settingsLogOutWarning;

  /// No description provided for @settingsWalletUpToDate.
  ///
  /// In en, this message translates to:
  /// **'Benny Wallet is up to date.'**
  String get settingsWalletUpToDate;

  /// No description provided for @settingsUpdateCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'Update Check Failed'**
  String get settingsUpdateCheckFailed;

  /// No description provided for @settingsUnableToCheckUpdates.
  ///
  /// In en, this message translates to:
  /// **'Unable to check for updates right now.'**
  String get settingsUnableToCheckUpdates;

  /// No description provided for @settingsSeedPhraseBackup.
  ///
  /// In en, this message translates to:
  /// **'Seed Phrase Backup'**
  String get settingsSeedPhraseBackup;

  /// No description provided for @settingsSeedPhraseBackupDescription.
  ///
  /// In en, this message translates to:
  /// **'We recommend a physical copy stored in a secure spot.'**
  String get settingsSeedPhraseBackupDescription;

  /// No description provided for @settingsSecureNow.
  ///
  /// In en, this message translates to:
  /// **'Secure Now'**
  String get settingsSecureNow;

  /// No description provided for @settingsCheckingUpdates.
  ///
  /// In en, this message translates to:
  /// **'Checking...'**
  String get settingsCheckingUpdates;

  /// No description provided for @settingsFullFeaturesUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Full features unlocked'**
  String get settingsFullFeaturesUnlocked;

  /// No description provided for @settingsCheckForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get settingsCheckForUpdates;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String settingsVersion(String version);

  /// No description provided for @settingsVersionBuild.
  ///
  /// In en, this message translates to:
  /// **'Version {version}+{buildNumber}'**
  String settingsVersionBuild(String version, String buildNumber);

  /// No description provided for @autoLockImmediate.
  ///
  /// In en, this message translates to:
  /// **'Immediately'**
  String get autoLockImmediate;

  /// No description provided for @autoLockOneMinute.
  ///
  /// In en, this message translates to:
  /// **'1 minute'**
  String get autoLockOneMinute;

  /// No description provided for @autoLockFiveMinutes.
  ///
  /// In en, this message translates to:
  /// **'5 minutes'**
  String get autoLockFiveMinutes;

  /// No description provided for @autoLockTenMinutes.
  ///
  /// In en, this message translates to:
  /// **'10 minutes'**
  String get autoLockTenMinutes;

  /// No description provided for @autoLockThirtyMinutes.
  ///
  /// In en, this message translates to:
  /// **'30 minutes'**
  String get autoLockThirtyMinutes;

  /// No description provided for @biometricUnlockReason.
  ///
  /// In en, this message translates to:
  /// **'Use biometrics to unlock your Benny Wallet.'**
  String get biometricUnlockReason;

  /// No description provided for @biometricSetupReason.
  ///
  /// In en, this message translates to:
  /// **'Verify with biometrics to enable this security feature.'**
  String get biometricSetupReason;

  /// No description provided for @unlockFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock Failed'**
  String get unlockFailedTitle;

  /// No description provided for @unlockIncorrectPin.
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN.'**
  String get unlockIncorrectPin;

  /// No description provided for @unlockBiometricCancelled.
  ///
  /// In en, this message translates to:
  /// **'Biometric cancelled'**
  String get unlockBiometricCancelled;

  /// No description provided for @unlockBiometricFailed.
  ///
  /// In en, this message translates to:
  /// **'Biometric unlock failed. Try again.'**
  String get unlockBiometricFailed;

  /// No description provided for @unlockSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired, use PIN'**
  String get unlockSessionExpired;

  /// No description provided for @unlockBiometricUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Biometric unavailable'**
  String get unlockBiometricUnavailable;

  /// No description provided for @unlockUseFingerprint.
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint'**
  String get unlockUseFingerprint;

  /// No description provided for @unlockEnterPin.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN'**
  String get unlockEnterPin;

  /// No description provided for @pinConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get pinConfirm;

  /// No description provided for @pinSet.
  ///
  /// In en, this message translates to:
  /// **'Set Benny PIN'**
  String get pinSet;

  /// No description provided for @pinMismatch.
  ///
  /// In en, this message translates to:
  /// **'PINs do not match'**
  String get pinMismatch;

  /// No description provided for @pinImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed'**
  String get pinImportFailed;

  /// No description provided for @pinExternalWalletSetupDescription.
  ///
  /// In en, this message translates to:
  /// **'This protects Benny settings and child accounts. Seeker keeps signing keys in Seeker Wallet.'**
  String get pinExternalWalletSetupDescription;

  /// No description provided for @childModeConfirmPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Child Mode PIN'**
  String get childModeConfirmPinTitle;

  /// No description provided for @childModeSetPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Child Mode PIN'**
  String get childModeSetPinTitle;

  /// No description provided for @childModeEnterPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter Child Mode PIN'**
  String get childModeEnterPinTitle;

  /// No description provided for @childModeConfirmPinSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Re-enter the 4-digit PIN used only for child mode.'**
  String get childModeConfirmPinSubtitle;

  /// No description provided for @childModeSetPinSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a 4-digit PIN used only for child mode.'**
  String get childModeSetPinSubtitle;

  /// No description provided for @childModeEnterPinSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the 4-digit PIN used only for child mode to turn it off.'**
  String get childModeEnterPinSubtitle;

  /// No description provided for @childModeOnlyUsed.
  ///
  /// In en, this message translates to:
  /// **'Only used for child mode'**
  String get childModeOnlyUsed;

  /// No description provided for @welcomeReplaceWalletTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace current wallet'**
  String get welcomeReplaceWalletTitle;

  /// No description provided for @welcomeReplaceWalletMessage.
  ///
  /// In en, this message translates to:
  /// **'Continuing will delete the current wallet.'**
  String get welcomeReplaceWalletMessage;

  /// No description provided for @welcomeConfirmAgainTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm again'**
  String get welcomeConfirmAgainTitle;

  /// No description provided for @welcomeConfirmAgainMessage.
  ///
  /// In en, this message translates to:
  /// **'After deletion you may lose access to the phrase. Save it first.'**
  String get welcomeConfirmAgainMessage;

  /// No description provided for @welcomeNewWalletSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start a fresh default wallet'**
  String get welcomeNewWalletSubtitle;

  /// No description provided for @welcomeImportWalletSubtitleSeeker.
  ///
  /// In en, this message translates to:
  /// **'Phrase or Seeker Vault'**
  String get welcomeImportWalletSubtitleSeeker;

  /// No description provided for @welcomeImportWalletSubtitlePhrase.
  ///
  /// In en, this message translates to:
  /// **'Restore from recovery phrase'**
  String get welcomeImportWalletSubtitlePhrase;

  /// No description provided for @welcomeHeroSemantics.
  ///
  /// In en, this message translates to:
  /// **'Benny Wallet'**
  String get welcomeHeroSemantics;

  /// No description provided for @welcomeHeroPrelude.
  ///
  /// In en, this message translates to:
  /// **'A new wallet is here.'**
  String get welcomeHeroPrelude;

  /// No description provided for @welcomeHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Benny Wallet'**
  String get welcomeHeroTitle;

  /// No description provided for @welcomeHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start fresh or restore your recovery phrase.'**
  String get welcomeHeroSubtitle;

  /// No description provided for @welcomeNewWallet.
  ///
  /// In en, this message translates to:
  /// **'New wallet'**
  String get welcomeNewWallet;

  /// No description provided for @welcomeImportWallet.
  ///
  /// In en, this message translates to:
  /// **'Import wallet'**
  String get welcomeImportWallet;

  /// No description provided for @createWalletTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Wallet'**
  String get createWalletTitle;

  /// No description provided for @createWalletRecoveryTitle.
  ///
  /// In en, this message translates to:
  /// **'Write down your recovery phrase.'**
  String get createWalletRecoveryTitle;

  /// No description provided for @createWalletRecoverySubtitle.
  ///
  /// In en, this message translates to:
  /// **'This is the only way to recover your wallet.'**
  String get createWalletRecoverySubtitle;

  /// No description provided for @webTestingOnly.
  ///
  /// In en, this message translates to:
  /// **'Web is for testing only.'**
  String get webTestingOnly;

  /// No description provided for @recoveryPhraseCopied.
  ///
  /// In en, this message translates to:
  /// **'Recovery phrase copied (will clear in 15s)'**
  String get recoveryPhraseCopied;

  /// No description provided for @copyPhrase.
  ///
  /// In en, this message translates to:
  /// **'Copy phrase'**
  String get copyPhrase;

  /// No description provided for @importWalletTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Wallet'**
  String get importWalletTitle;

  /// No description provided for @importRecoveryPhraseTitle.
  ///
  /// In en, this message translates to:
  /// **'Import recovery phrase'**
  String get importRecoveryPhraseTitle;

  /// No description provided for @importRecoveryPhraseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use 12 or 24 English words.'**
  String get importRecoveryPhraseSubtitle;

  /// No description provided for @importPasteHint.
  ///
  /// In en, this message translates to:
  /// **'Paste your recovery phrase here'**
  String get importPasteHint;

  /// No description provided for @importInvalidPhrase.
  ///
  /// In en, this message translates to:
  /// **'Invalid recovery phrase'**
  String get importInvalidPhrase;

  /// No description provided for @importEnterWords.
  ///
  /// In en, this message translates to:
  /// **'Enter or paste 12 or 24 words.'**
  String get importEnterWords;

  /// No description provided for @importWordsDetected.
  ///
  /// In en, this message translates to:
  /// **'{count} words detected'**
  String importWordsDetected(int count);

  /// No description provided for @importClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get importClear;

  /// No description provided for @seekerVaultConnectDescription.
  ///
  /// In en, this message translates to:
  /// **'Connect the hardware-backed wallet on this Seeker.'**
  String get seekerVaultConnectDescription;

  /// No description provided for @seekerVaultConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get seekerVaultConnect;

  /// No description provided for @seekerVaultInstallOrEnable.
  ///
  /// In en, this message translates to:
  /// **'Install or enable Seeker Wallet, then try again.'**
  String get seekerVaultInstallOrEnable;

  /// No description provided for @seekerVaultAndroidOnly.
  ///
  /// In en, this message translates to:
  /// **'Seeker Vault import is available on Android only.'**
  String get seekerVaultAndroidOnly;

  /// No description provided for @seekerVaultNoAccounts.
  ///
  /// In en, this message translates to:
  /// **'No existing Seed Vault wallet accounts were returned for this seed.'**
  String get seekerVaultNoAccounts;

  /// No description provided for @seekerVaultUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Seed Vault is not available on this device.'**
  String get seekerVaultUnavailable;

  /// No description provided for @seekerVaultCancelled.
  ///
  /// In en, this message translates to:
  /// **'Seeker Vault connection was cancelled.'**
  String get seekerVaultCancelled;

  /// No description provided for @seekerVaultConnectFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to connect Seeker Vault right now. Please try again.'**
  String get seekerVaultConnectFailed;

  /// No description provided for @receiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Receive'**
  String get receiveTitle;

  /// No description provided for @receivedHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Received history'**
  String get receivedHistoryTitle;

  /// No description provided for @receiveShareAddressTitle.
  ///
  /// In en, this message translates to:
  /// **'Share this address'**
  String get receiveShareAddressTitle;

  /// No description provided for @receiveShareAddressSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scan or copy it.'**
  String get receiveShareAddressSubtitle;

  /// No description provided for @receiveNoAddress.
  ///
  /// In en, this message translates to:
  /// **'No wallet address available'**
  String get receiveNoAddress;

  /// No description provided for @receiveNoAddressSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create or unlock a wallet to receive funds.'**
  String get receiveNoAddressSubtitle;

  /// No description provided for @receiveAddressCopied.
  ///
  /// In en, this message translates to:
  /// **'Address copied (will clear in 60s)'**
  String get receiveAddressCopied;

  /// No description provided for @receiveCopyAddress.
  ///
  /// In en, this message translates to:
  /// **'Copy address'**
  String get receiveCopyAddress;

  /// No description provided for @sendTitle.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get sendTitle;

  /// No description provided for @sendChooseAssetTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose asset'**
  String get sendChooseAssetTitle;

  /// No description provided for @sendHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Send history'**
  String get sendHistoryTitle;

  /// No description provided for @sendUnavailableChildMode.
  ///
  /// In en, this message translates to:
  /// **'Send is unavailable in child mode.'**
  String get sendUnavailableChildMode;

  /// No description provided for @sendOpenReceive.
  ///
  /// In en, this message translates to:
  /// **'Open Receive'**
  String get sendOpenReceive;

  /// No description provided for @sendNoAssets.
  ///
  /// In en, this message translates to:
  /// **'No assets available to send.'**
  String get sendNoAssets;

  /// No description provided for @sendRecipientPrefilled.
  ///
  /// In en, this message translates to:
  /// **'Recipient prefilled'**
  String get sendRecipientPrefilled;

  /// No description provided for @sendLoadAssetsFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load assets: {error}'**
  String sendLoadAssetsFailed(String error);

  /// No description provided for @sendAssetNotFound.
  ///
  /// In en, this message translates to:
  /// **'Asset not found.'**
  String get sendAssetNotFound;

  /// No description provided for @sendAssetTitle.
  ///
  /// In en, this message translates to:
  /// **'Send {symbol}'**
  String sendAssetTitle(String symbol);

  /// No description provided for @sendScanQrCode.
  ///
  /// In en, this message translates to:
  /// **'Scan QR code'**
  String get sendScanQrCode;

  /// No description provided for @sendRecipientAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Recipient Solana address'**
  String get sendRecipientAddressHint;

  /// No description provided for @sendAvailableAmount.
  ///
  /// In en, this message translates to:
  /// **'Available {amount} {symbol}'**
  String sendAvailableAmount(String amount, String symbol);

  /// No description provided for @sendLoadFormFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load send form: {error}'**
  String sendLoadFormFailed(String error);

  /// No description provided for @sendInvalidAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid Solana address.'**
  String get sendInvalidAddress;

  /// No description provided for @sendInvalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount.'**
  String get sendInvalidAmount;

  /// No description provided for @sendInsufficientBalance.
  ///
  /// In en, this message translates to:
  /// **'Insufficient balance.'**
  String get sendInsufficientBalance;

  /// No description provided for @sendUnlockAgain.
  ///
  /// In en, this message translates to:
  /// **'Unlock the wallet again before sending.'**
  String get sendUnlockAgain;

  /// No description provided for @sendNotEnoughSolAfterFee.
  ///
  /// In en, this message translates to:
  /// **'Not enough SOL after reserving the network fee.'**
  String get sendNotEnoughSolAfterFee;

  /// No description provided for @sendNotEnoughSolForFee.
  ///
  /// In en, this message translates to:
  /// **'Not enough SOL to cover the network fee.'**
  String get sendNotEnoughSolForFee;

  /// No description provided for @sendGenericFailure.
  ///
  /// In en, this message translates to:
  /// **'Send failed. Please try again.'**
  String get sendGenericFailure;

  /// No description provided for @sendAmountHint.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get sendAmountHint;

  /// No description provided for @portfolioChildAccounts.
  ///
  /// In en, this message translates to:
  /// **'Child accounts'**
  String get portfolioChildAccounts;

  /// No description provided for @portfolioCrypto.
  ///
  /// In en, this message translates to:
  /// **'Crypto'**
  String get portfolioCrypto;

  /// No description provided for @portfolioStocks.
  ///
  /// In en, this message translates to:
  /// **'Stocks'**
  String get portfolioStocks;

  /// No description provided for @portfolioMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get portfolioMessages;

  /// No description provided for @portfolioTokens.
  ///
  /// In en, this message translates to:
  /// **'Tokens'**
  String get portfolioTokens;

  /// No description provided for @portfolioDefi.
  ///
  /// In en, this message translates to:
  /// **'DeFi'**
  String get portfolioDefi;

  /// No description provided for @portfolioSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get portfolioSend;

  /// No description provided for @portfolioSwap.
  ///
  /// In en, this message translates to:
  /// **'Swap'**
  String get portfolioSwap;

  /// No description provided for @portfolioReceive.
  ///
  /// In en, this message translates to:
  /// **'Receive'**
  String get portfolioReceive;

  /// No description provided for @portfolioCouldNotRefreshAssets.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t refresh assets'**
  String get portfolioCouldNotRefreshAssets;

  /// No description provided for @portfolioPullToRetry.
  ///
  /// In en, this message translates to:
  /// **'Pull down to try again.'**
  String get portfolioPullToRetry;

  /// No description provided for @portfolioDefiParentOnly.
  ///
  /// In en, this message translates to:
  /// **'DeFi is parent-only'**
  String get portfolioDefiParentOnly;

  /// No description provided for @portfolioDefiParentOnlyMessage.
  ///
  /// In en, this message translates to:
  /// **'Switch back to parent mode to review protocol positions.'**
  String get portfolioDefiParentOnlyMessage;

  /// No description provided for @portfolioDefiUnavailable.
  ///
  /// In en, this message translates to:
  /// **'DeFi data is temporarily unavailable'**
  String get portfolioDefiUnavailable;

  /// No description provided for @portfolioDefiUnavailableMessage.
  ///
  /// In en, this message translates to:
  /// **'Tokens are still up to date.'**
  String get portfolioDefiUnavailableMessage;

  /// No description provided for @portfolioNoDefi.
  ///
  /// In en, this message translates to:
  /// **'No DeFi positions yet'**
  String get portfolioNoDefi;

  /// No description provided for @portfolioRefreshingDefi.
  ///
  /// In en, this message translates to:
  /// **'Refreshing protocol positions...'**
  String get portfolioRefreshingDefi;

  /// No description provided for @portfolioNoActiveDefi.
  ///
  /// In en, this message translates to:
  /// **'Your wallet has no active DeFi positions.'**
  String get portfolioNoActiveDefi;

  /// No description provided for @portfolioRefreshFailed.
  ///
  /// In en, this message translates to:
  /// **'Refresh failed'**
  String get portfolioRefreshFailed;

  /// No description provided for @portfolioNetworkBusy.
  ///
  /// In en, this message translates to:
  /// **'The network is busy right now. Pull down to try again.'**
  String get portfolioNetworkBusy;

  /// No description provided for @portfolioServerUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach the server. Check your connection and pull down to try again.'**
  String get portfolioServerUnavailable;

  /// No description provided for @portfolioRefreshAssetsFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t refresh assets. Pull down to try again.'**
  String get portfolioRefreshAssetsFailed;

  /// No description provided for @portfolioReceiveSol.
  ///
  /// In en, this message translates to:
  /// **'Receive SOL'**
  String get portfolioReceiveSol;

  /// No description provided for @portfolioReceiveSolSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive SOL to get started with Benny Wallet.'**
  String get portfolioReceiveSolSubtitle;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @commonAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get commonAmount;

  /// No description provided for @commonAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get commonAuto;

  /// No description provided for @commonBuy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get commonBuy;

  /// No description provided for @commonConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get commonConfirmed;

  /// No description provided for @commonCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get commonCustom;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get commonFrom;

  /// No description provided for @commonNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get commonNetwork;

  /// No description provided for @commonNetworkFee.
  ///
  /// In en, this message translates to:
  /// **'Network fee'**
  String get commonNetworkFee;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get commonSend;

  /// No description provided for @commonSignature.
  ///
  /// In en, this message translates to:
  /// **'Signature'**
  String get commonSignature;

  /// No description provided for @commonSolana.
  ///
  /// In en, this message translates to:
  /// **'Solana'**
  String get commonSolana;

  /// No description provided for @commonStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get commonStatus;

  /// No description provided for @commonSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get commonSubmitted;

  /// No description provided for @commonTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get commonTo;

  /// No description provided for @commonToken.
  ///
  /// In en, this message translates to:
  /// **'Token'**
  String get commonToken;

  /// No description provided for @transactionTimeline.
  ///
  /// In en, this message translates to:
  /// **'Transaction timeline'**
  String get transactionTimeline;

  /// No description provided for @walletAddressUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Wallet address is unavailable.'**
  String get walletAddressUnavailable;

  /// No description provided for @relativeSecondsAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}s ago'**
  String relativeSecondsAgo(Object count);

  /// No description provided for @relativeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String relativeMinutesAgo(Object count);

  /// No description provided for @relativeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String relativeHoursAgo(Object count);

  /// No description provided for @relativeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String relativeDaysAgo(Object count);

  /// No description provided for @importWalletLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Importing wallet...'**
  String get importWalletLoadingTitle;

  /// No description provided for @importWalletLoadingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Preparing your Solana wallet list.'**
  String get importWalletLoadingSubtitle;

  /// No description provided for @importSolanaMainnet.
  ///
  /// In en, this message translates to:
  /// **'Solana Mainnet'**
  String get importSolanaMainnet;

  /// No description provided for @importSelectSolanaAccount.
  ///
  /// In en, this message translates to:
  /// **'Select the Solana account to import.'**
  String get importSelectSolanaAccount;

  /// No description provided for @importLoadingSolanaAccounts.
  ///
  /// In en, this message translates to:
  /// **'Loading Solana accounts...'**
  String get importLoadingSolanaAccounts;

  /// No description provided for @importCheckingActiveSolanaAccounts.
  ///
  /// In en, this message translates to:
  /// **'Checking active Solana accounts.'**
  String get importCheckingActiveSolanaAccounts;

  /// No description provided for @importUnableScanRecoveryPhrase.
  ///
  /// In en, this message translates to:
  /// **'Unable to scan this recovery phrase right now.'**
  String get importUnableScanRecoveryPhrase;

  /// No description provided for @importActiveAccount.
  ///
  /// In en, this message translates to:
  /// **'Active account'**
  String get importActiveAccount;

  /// No description provided for @importDefaultMainWallet.
  ///
  /// In en, this message translates to:
  /// **'Default main wallet'**
  String get importDefaultMainWallet;

  /// No description provided for @seekerVaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Seeker Vault'**
  String get seekerVaultTitle;

  /// No description provided for @seekerVaultChooseFundedAccount.
  ///
  /// In en, this message translates to:
  /// **'Choose funded account'**
  String get seekerVaultChooseFundedAccount;

  /// No description provided for @seekerVaultChooseAccount.
  ///
  /// In en, this message translates to:
  /// **'Choose account'**
  String get seekerVaultChooseAccount;

  /// No description provided for @seekerVaultFundedAccountFound.
  ///
  /// In en, this message translates to:
  /// **'Benny found account activity under this Seed Vault wallet.'**
  String get seekerVaultFundedAccountFound;

  /// No description provided for @seekerVaultNoFundedAccountFound.
  ///
  /// In en, this message translates to:
  /// **'No funded account was found. These are the accounts returned by Seed Vault.'**
  String get seekerVaultNoFundedAccountFound;

  /// No description provided for @seekerVaultAssetCount.
  ///
  /// In en, this message translates to:
  /// **'{count} assets'**
  String seekerVaultAssetCount(Object count);

  /// No description provided for @seekerVaultNoAssets.
  ///
  /// In en, this message translates to:
  /// **'No assets'**
  String get seekerVaultNoAssets;

  /// No description provided for @scanAddressTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan address'**
  String get scanAddressTitle;

  /// No description provided for @scanNoSolanaAddress.
  ///
  /// In en, this message translates to:
  /// **'No Solana address found in this QR code.'**
  String get scanNoSolanaAddress;

  /// No description provided for @scanPointCamera.
  ///
  /// In en, this message translates to:
  /// **'Point the camera at a Solana QR code.'**
  String get scanPointCamera;

  /// No description provided for @sendConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm send'**
  String get sendConfirmTitle;

  /// No description provided for @sendSubmitting.
  ///
  /// In en, this message translates to:
  /// **'Submitting...'**
  String get sendSubmitting;

  /// No description provided for @sendSubmittingSummary.
  ///
  /// In en, this message translates to:
  /// **'{amount} {symbol} to {address}'**
  String sendSubmittingSummary(Object address, Object amount, Object symbol);

  /// No description provided for @sendSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get sendSubmitted;

  /// No description provided for @sendFailed.
  ///
  /// In en, this message translates to:
  /// **'Send failed'**
  String get sendFailed;

  /// No description provided for @sendSubmittedMessage.
  ///
  /// In en, this message translates to:
  /// **'{amount} {symbol} was submitted to {address}. Confirmation may take a moment.'**
  String sendSubmittedMessage(Object address, Object amount, Object symbol);

  /// No description provided for @sendTransactionCouldNotComplete.
  ///
  /// In en, this message translates to:
  /// **'The transaction could not be completed.'**
  String get sendTransactionCouldNotComplete;

  /// No description provided for @sendViewTransaction.
  ///
  /// In en, this message translates to:
  /// **'View transaction'**
  String get sendViewTransaction;

  /// No description provided for @sendRecipientNotReady.
  ///
  /// In en, this message translates to:
  /// **'The recipient wallet is not ready to receive this token yet.'**
  String get sendRecipientNotReady;

  /// No description provided for @sendNetworkBusy.
  ///
  /// In en, this message translates to:
  /// **'The network is busy. Please try again.'**
  String get sendNetworkBusy;

  /// No description provided for @sendNetworkTakingLonger.
  ///
  /// In en, this message translates to:
  /// **'The network is taking longer than expected. Please try again.'**
  String get sendNetworkTakingLonger;

  /// No description provided for @sendHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No send history yet.'**
  String get sendHistoryEmpty;

  /// No description provided for @sendHistoryLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load send history: {error}'**
  String sendHistoryLoadFailed(Object error);

  /// No description provided for @sendDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Send details'**
  String get sendDetailsTitle;

  /// No description provided for @sendNotConfirmedYet.
  ///
  /// In en, this message translates to:
  /// **'Not confirmed yet'**
  String get sendNotConfirmedYet;

  /// No description provided for @sendOpenTokenDetails.
  ///
  /// In en, this message translates to:
  /// **'Open token details'**
  String get sendOpenTokenDetails;

  /// No description provided for @sendViewOnSolscan.
  ///
  /// In en, this message translates to:
  /// **'View on Solscan'**
  String get sendViewOnSolscan;

  /// No description provided for @sendToEmpty.
  ///
  /// In en, this message translates to:
  /// **'To --'**
  String get sendToEmpty;

  /// No description provided for @sendToAddress.
  ///
  /// In en, this message translates to:
  /// **'To {address}'**
  String sendToAddress(Object address);

  /// No description provided for @sendStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get sendStatusFailed;

  /// No description provided for @sendStatusFinalized.
  ///
  /// In en, this message translates to:
  /// **'Finalized'**
  String get sendStatusFinalized;

  /// No description provided for @sendStatusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get sendStatusConfirmed;

  /// No description provided for @sendStatusSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get sendStatusSubmitted;

  /// No description provided for @sendStatusSourceHeliusWebhook.
  ///
  /// In en, this message translates to:
  /// **'Helius webhook'**
  String get sendStatusSourceHeliusWebhook;

  /// No description provided for @sendStatusSourceRpcSync.
  ///
  /// In en, this message translates to:
  /// **'Chain status sync'**
  String get sendStatusSourceRpcSync;

  /// No description provided for @sendStatusSourceChainActivity.
  ///
  /// In en, this message translates to:
  /// **'Chain activity'**
  String get sendStatusSourceChainActivity;

  /// No description provided for @sendTransactionFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Send transaction'**
  String get sendTransactionFallbackTitle;

  /// No description provided for @sendSubmittedToSender.
  ///
  /// In en, this message translates to:
  /// **'Submitted to sender'**
  String get sendSubmittedToSender;

  /// No description provided for @sendSubmittedToSenderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Helius Sender accepted the signed transaction.'**
  String get sendSubmittedToSenderSubtitle;

  /// No description provided for @sendAsyncResultFailed.
  ///
  /// In en, this message translates to:
  /// **'Async result failed'**
  String get sendAsyncResultFailed;

  /// No description provided for @sendWaitingAsyncConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Waiting for async confirmation'**
  String get sendWaitingAsyncConfirmation;

  /// No description provided for @sendAsyncConfirmationReceived.
  ///
  /// In en, this message translates to:
  /// **'Async confirmation received'**
  String get sendAsyncConfirmationReceived;

  /// No description provided for @sendUpdatedFromHeliusWebhook.
  ///
  /// In en, this message translates to:
  /// **'Updated from Helius webhook.'**
  String get sendUpdatedFromHeliusWebhook;

  /// No description provided for @sendUpdatedFromChainStatusSync.
  ///
  /// In en, this message translates to:
  /// **'Updated from chain status sync.'**
  String get sendUpdatedFromChainStatusSync;

  /// No description provided for @sendConfirmationNotReceivedYet.
  ///
  /// In en, this message translates to:
  /// **'Confirmation has not been received yet.'**
  String get sendConfirmationNotReceivedYet;

  /// No description provided for @swapTitle.
  ///
  /// In en, this message translates to:
  /// **'Swap'**
  String get swapTitle;

  /// No description provided for @swapButton.
  ///
  /// In en, this message translates to:
  /// **'Swap'**
  String get swapButton;

  /// No description provided for @swapReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review swap'**
  String get swapReviewTitle;

  /// No description provided for @swapForAmount.
  ///
  /// In en, this message translates to:
  /// **'for ~{amount} {symbol}'**
  String swapForAmount(Object amount, Object symbol);

  /// No description provided for @swapPay.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get swapPay;

  /// No description provided for @swapReceive.
  ///
  /// In en, this message translates to:
  /// **'Receive'**
  String get swapReceive;

  /// No description provided for @swapMinimumReceive.
  ///
  /// In en, this message translates to:
  /// **'Minimum receive'**
  String get swapMinimumReceive;

  /// No description provided for @swapSlippage.
  ///
  /// In en, this message translates to:
  /// **'Slippage'**
  String get swapSlippage;

  /// No description provided for @swapPriorityFee.
  ///
  /// In en, this message translates to:
  /// **'Priority fee'**
  String get swapPriorityFee;

  /// No description provided for @swapRoute.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get swapRoute;

  /// No description provided for @swapLamports.
  ///
  /// In en, this message translates to:
  /// **'{lamports} lamports'**
  String swapLamports(Object lamports);

  /// No description provided for @swapPriorityNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get swapPriorityNormal;

  /// No description provided for @swapPriorityFast.
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get swapPriorityFast;

  /// No description provided for @swapPriorityTurbo.
  ///
  /// In en, this message translates to:
  /// **'Turbo'**
  String get swapPriorityTurbo;

  /// No description provided for @swapProcessing.
  ///
  /// In en, this message translates to:
  /// **'Swapping...'**
  String get swapProcessing;

  /// No description provided for @swapProcessingSummary.
  ///
  /// In en, this message translates to:
  /// **'{inputAmount} {inputSymbol} to {outputAmount} {outputSymbol}'**
  String swapProcessingSummary(
    Object inputAmount,
    Object inputSymbol,
    Object outputAmount,
    Object outputSymbol,
  );

  /// No description provided for @swapComplete.
  ///
  /// In en, this message translates to:
  /// **'Swap complete'**
  String get swapComplete;

  /// No description provided for @swapFailed.
  ///
  /// In en, this message translates to:
  /// **'Swap failed'**
  String get swapFailed;

  /// No description provided for @swapReceivedAmount.
  ///
  /// In en, this message translates to:
  /// **'{amount} {symbol} received'**
  String swapReceivedAmount(Object amount, Object symbol);

  /// No description provided for @swapCouldNotComplete.
  ///
  /// In en, this message translates to:
  /// **'The swap could not be completed.'**
  String get swapCouldNotComplete;

  /// No description provided for @swapTradingUnavailableChildMode.
  ///
  /// In en, this message translates to:
  /// **'Trading is unavailable in child mode.'**
  String get swapTradingUnavailableChildMode;

  /// No description provided for @swapNoBaseAssetsForXStocks.
  ///
  /// In en, this message translates to:
  /// **'No SOL, USDC, or USDT available to buy xStocks.'**
  String get swapNoBaseAssetsForXStocks;

  /// No description provided for @swapNoAssetsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No assets available to swap.'**
  String get swapNoAssetsAvailable;

  /// No description provided for @swapPayWith.
  ///
  /// In en, this message translates to:
  /// **'Pay with'**
  String get swapPayWith;

  /// No description provided for @swapBuyXStock.
  ///
  /// In en, this message translates to:
  /// **'Buy xStock'**
  String get swapBuyXStock;

  /// No description provided for @swapAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available {amount} {symbol}'**
  String swapAvailable(Object amount, Object symbol);

  /// No description provided for @swapRefreshingQuote.
  ///
  /// In en, this message translates to:
  /// **'Refreshing quote...'**
  String get swapRefreshingQuote;

  /// No description provided for @swapRouteLabel.
  ///
  /// In en, this message translates to:
  /// **'Route: {route}'**
  String swapRouteLabel(Object route);

  /// No description provided for @swapBestRoute.
  ///
  /// In en, this message translates to:
  /// **'Best route'**
  String get swapBestRoute;

  /// No description provided for @swapFailedLoadWalletAssets.
  ///
  /// In en, this message translates to:
  /// **'Failed to load wallet assets: {error}'**
  String swapFailedLoadWalletAssets(Object error);

  /// No description provided for @swapRateSummary.
  ///
  /// In en, this message translates to:
  /// **'1 {inputSymbol} ≈ {rate} {outputSymbol}'**
  String swapRateSummary(Object inputSymbol, Object outputSymbol, Object rate);

  /// No description provided for @swapSlippageMin.
  ///
  /// In en, this message translates to:
  /// **'{value} min'**
  String swapSlippageMin(Object value);

  /// No description provided for @swapCustomWithValue.
  ///
  /// In en, this message translates to:
  /// **'Custom · {value}'**
  String swapCustomWithValue(Object value);

  /// No description provided for @swapMinReceive.
  ///
  /// In en, this message translates to:
  /// **'Min {amount}'**
  String swapMinReceive(Object amount);

  /// No description provided for @swapAmountTooSmall.
  ///
  /// In en, this message translates to:
  /// **'This amount is too small for a valid route.'**
  String get swapAmountTooSmall;

  /// No description provided for @swapWaitValidQuote.
  ///
  /// In en, this message translates to:
  /// **'Wait for a valid quote before continuing.'**
  String get swapWaitValidQuote;

  /// No description provided for @swapNotEnoughSolReserve.
  ///
  /// In en, this message translates to:
  /// **'Not enough SOL.\nNeed {reserve} SOL reserve.'**
  String swapNotEnoughSolReserve(Object reserve);

  /// No description provided for @swapRouteUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This swap route isn\'t available right now. Try swapping with SOL or choose another token pair.'**
  String get swapRouteUnavailable;

  /// No description provided for @swapPriceMoved.
  ///
  /// In en, this message translates to:
  /// **'Price moved before the swap was sent. Increase slippage and try again.'**
  String get swapPriceMoved;

  /// No description provided for @swapNotEnoughTokenBalance.
  ///
  /// In en, this message translates to:
  /// **'Not enough token balance. Tap Max again and retry.'**
  String get swapNotEnoughTokenBalance;

  /// No description provided for @swapQuotesBusy.
  ///
  /// In en, this message translates to:
  /// **'Quotes are busy right now. Try again in a moment.'**
  String get swapQuotesBusy;

  /// No description provided for @swapQuoteExpired.
  ///
  /// In en, this message translates to:
  /// **'This quote expired. Review the swap again.'**
  String get swapQuoteExpired;

  /// No description provided for @swapUnlockAgain.
  ///
  /// In en, this message translates to:
  /// **'Unlock the wallet again before swapping.'**
  String get swapUnlockAgain;

  /// No description provided for @swapTransactionUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Swap transaction is unavailable.'**
  String get swapTransactionUnavailable;

  /// No description provided for @swapConnectSeekerVaultAgain.
  ///
  /// In en, this message translates to:
  /// **'Connect Seeker Vault again before swapping.'**
  String get swapConnectSeekerVaultAgain;

  /// No description provided for @swapConnectSeedVaultAgain.
  ///
  /// In en, this message translates to:
  /// **'Connect Seed Vault again before swapping.'**
  String get swapConnectSeedVaultAgain;

  /// No description provided for @swapUnexpectedSignatureCount.
  ///
  /// In en, this message translates to:
  /// **'Wallet returned an unexpected signature count.'**
  String get swapUnexpectedSignatureCount;

  /// No description provided for @swapCustomSlippageLabel.
  ///
  /// In en, this message translates to:
  /// **'Custom slippage %'**
  String get swapCustomSlippageLabel;

  /// No description provided for @swapChooseToken.
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get swapChooseToken;

  /// No description provided for @swapApproxYouReceive.
  ///
  /// In en, this message translates to:
  /// **'Approx. you receive'**
  String get swapApproxYouReceive;

  /// No description provided for @swapRate.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get swapRate;

  /// No description provided for @swapPlatformFee.
  ///
  /// In en, this message translates to:
  /// **'Platform fee'**
  String get swapPlatformFee;

  /// No description provided for @swapSearchTokenHint.
  ///
  /// In en, this message translates to:
  /// **'Search token name or symbol'**
  String get swapSearchTokenHint;

  /// No description provided for @swapNoTokensAvailable.
  ///
  /// In en, this message translates to:
  /// **'No tokens available'**
  String get swapNoTokensAvailable;

  /// No description provided for @swapNoResultsFor.
  ///
  /// In en, this message translates to:
  /// **'No results found for \"{query}\"'**
  String swapNoResultsFor(Object query);

  /// No description provided for @swapYourAssets.
  ///
  /// In en, this message translates to:
  /// **'Your assets'**
  String get swapYourAssets;

  /// No description provided for @swapSuggestedTokens.
  ///
  /// In en, this message translates to:
  /// **'Suggested tokens'**
  String get swapSuggestedTokens;

  /// No description provided for @swapAvailableBalance.
  ///
  /// In en, this message translates to:
  /// **'{amount} available'**
  String swapAvailableBalance(Object amount);

  /// No description provided for @assetNotFound.
  ///
  /// In en, this message translates to:
  /// **'Asset not found.'**
  String get assetNotFound;

  /// No description provided for @assetPosition.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get assetPosition;

  /// No description provided for @assetValue.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get assetValue;

  /// No description provided for @assetBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get assetBalance;

  /// No description provided for @assetReturn24h.
  ///
  /// In en, this message translates to:
  /// **'24h return'**
  String get assetReturn24h;

  /// No description provided for @assetInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get assetInfo;

  /// No description provided for @assetName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get assetName;

  /// No description provided for @assetSymbol.
  ///
  /// In en, this message translates to:
  /// **'Symbol'**
  String get assetSymbol;

  /// No description provided for @assetMint.
  ///
  /// In en, this message translates to:
  /// **'Mint'**
  String get assetMint;

  /// No description provided for @assetWebsite.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get assetWebsite;

  /// No description provided for @assetPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get assetPrice;

  /// No description provided for @assetMarketCap.
  ///
  /// In en, this message translates to:
  /// **'Market cap'**
  String get assetMarketCap;

  /// No description provided for @assetFdv.
  ///
  /// In en, this message translates to:
  /// **'FDV'**
  String get assetFdv;

  /// No description provided for @assetTotalSupply.
  ///
  /// In en, this message translates to:
  /// **'Total supply'**
  String get assetTotalSupply;

  /// No description provided for @assetCirculatingSupply.
  ///
  /// In en, this message translates to:
  /// **'Circulating supply'**
  String get assetCirculatingSupply;

  /// No description provided for @assetHolders.
  ///
  /// In en, this message translates to:
  /// **'Holders'**
  String get assetHolders;

  /// No description provided for @assetCreated.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get assetCreated;

  /// No description provided for @assetPerformance24h.
  ///
  /// In en, this message translates to:
  /// **'24h performance'**
  String get assetPerformance24h;

  /// No description provided for @assetVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get assetVolume;

  /// No description provided for @assetTraders.
  ///
  /// In en, this message translates to:
  /// **'Traders'**
  String get assetTraders;

  /// No description provided for @assetSafety.
  ///
  /// In en, this message translates to:
  /// **'Safety'**
  String get assetSafety;

  /// No description provided for @assetTop10Holders.
  ///
  /// In en, this message translates to:
  /// **'Top 10 holders'**
  String get assetTop10Holders;

  /// No description provided for @assetMarketStatsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Some market stats are unavailable right now.'**
  String get assetMarketStatsUnavailable;

  /// No description provided for @assetActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get assetActivity;

  /// No description provided for @assetNoActivity.
  ///
  /// In en, this message translates to:
  /// **'No activity yet.'**
  String get assetNoActivity;

  /// No description provided for @assetActivityLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Activity could not be loaded.'**
  String get assetActivityLoadFailed;

  /// No description provided for @assetLoadDetailsFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load asset details: {error}'**
  String assetLoadDetailsFailed(Object error);

  /// No description provided for @assetMintCopied.
  ///
  /// In en, this message translates to:
  /// **'Mint copied (will clear in 60s)'**
  String get assetMintCopied;

  /// No description provided for @assetCouldNotOpenWebsite.
  ///
  /// In en, this message translates to:
  /// **'Could not open website.'**
  String get assetCouldNotOpenWebsite;

  /// No description provided for @assetSwapOut.
  ///
  /// In en, this message translates to:
  /// **'Swap Out'**
  String get assetSwapOut;

  /// No description provided for @assetSwapIn.
  ///
  /// In en, this message translates to:
  /// **'Swap In'**
  String get assetSwapIn;

  /// No description provided for @assetToSymbol.
  ///
  /// In en, this message translates to:
  /// **'To {symbol}'**
  String assetToSymbol(Object symbol);

  /// No description provided for @assetFromSymbol.
  ///
  /// In en, this message translates to:
  /// **'From {symbol}'**
  String assetFromSymbol(Object symbol);

  /// No description provided for @assetSent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get assetSent;

  /// No description provided for @assetReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get assetReceived;

  /// No description provided for @assetTransfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get assetTransfer;

  /// No description provided for @assetSwapWithTime.
  ///
  /// In en, this message translates to:
  /// **'Swap  •  {time}'**
  String assetSwapWithTime(Object time);

  /// No description provided for @assetCounterpartyWithTime.
  ///
  /// In en, this message translates to:
  /// **'{address}  •  {time}'**
  String assetCounterpartyWithTime(Object address, Object time);

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Messages unavailable'**
  String get notificationsUnavailableTitle;

  /// No description provided for @notificationsUnavailableSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unable to load messages right now.'**
  String get notificationsUnavailableSubtitle;

  /// No description provided for @notificationsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get notificationsEmptyTitle;

  /// No description provided for @notificationsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Push messages will appear here after they arrive.'**
  String get notificationsEmptySubtitle;

  /// No description provided for @notificationDeleted.
  ///
  /// In en, this message translates to:
  /// **'Message deleted'**
  String get notificationDeleted;

  /// No description provided for @receivedHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No received history yet.'**
  String get receivedHistoryEmpty;

  /// No description provided for @receivedHistoryLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load received history: {error}'**
  String receivedHistoryLoadFailed(Object error);

  /// No description provided for @receivedDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Received details'**
  String get receivedDetailsTitle;

  /// No description provided for @receivedDetailsMissingId.
  ///
  /// In en, this message translates to:
  /// **'This message does not include a received transfer id.'**
  String get receivedDetailsMissingId;

  /// No description provided for @receivedDetailsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load this received transfer: {error}'**
  String receivedDetailsLoadFailed(Object error);

  /// No description provided for @receivedFundsTitle.
  ///
  /// In en, this message translates to:
  /// **'Funds received'**
  String get receivedFundsTitle;

  /// No description provided for @receivedYouReceived.
  ///
  /// In en, this message translates to:
  /// **'You received {amount}'**
  String receivedYouReceived(Object amount);

  /// Incoming-funds message; wallet is the receiving wallet name and short address.
  ///
  /// In en, this message translates to:
  /// **'You received {amount} in {wallet}'**
  String receivedYouReceivedInWallet(String amount, String wallet);

  /// No description provided for @receivedFromEmpty.
  ///
  /// In en, this message translates to:
  /// **'From --'**
  String get receivedFromEmpty;

  /// No description provided for @receivedFromAddress.
  ///
  /// In en, this message translates to:
  /// **'From {address}'**
  String receivedFromAddress(Object address);

  /// No description provided for @receivedRelatedChanges.
  ///
  /// In en, this message translates to:
  /// **'Related changes'**
  String get receivedRelatedChanges;

  /// No description provided for @receivedOnSolana.
  ///
  /// In en, this message translates to:
  /// **'Received on Solana'**
  String get receivedOnSolana;

  /// No description provided for @receivedMarkedFailed.
  ///
  /// In en, this message translates to:
  /// **'The receive event was marked failed.'**
  String get receivedMarkedFailed;

  /// No description provided for @receivedArrived.
  ///
  /// In en, this message translates to:
  /// **'Funds arrived in this wallet.'**
  String get receivedArrived;

  /// No description provided for @receivedNewFundsArrived.
  ///
  /// In en, this message translates to:
  /// **'New funds arrived in your wallet.'**
  String get receivedNewFundsArrived;

  /// No description provided for @childVerifyPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your PIN'**
  String get childVerifyPinTitle;

  /// No description provided for @childWalletAlreadyAdded.
  ///
  /// In en, this message translates to:
  /// **'This child wallet has already been added.'**
  String get childWalletAlreadyAdded;

  /// No description provided for @childWalletAdded.
  ///
  /// In en, this message translates to:
  /// **'{name} added successfully'**
  String childWalletAdded(Object name);

  /// No description provided for @childWalletAddFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to add child wallet: {error}'**
  String childWalletAddFailed(Object error);

  /// No description provided for @childWalletUpdated.
  ///
  /// In en, this message translates to:
  /// **'{name} updated successfully'**
  String childWalletUpdated(Object name);

  /// No description provided for @childWalletUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update child wallet: {error}'**
  String childWalletUpdateFailed(Object error);

  /// No description provided for @childWalletDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String childWalletDeleteTitle(Object name);

  /// No description provided for @childWalletDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'This child wallet entry will be removed from parent monitoring.'**
  String get childWalletDeleteMessage;

  /// No description provided for @childWalletDeleted.
  ///
  /// In en, this message translates to:
  /// **'{name} deleted'**
  String childWalletDeleted(Object name);

  /// No description provided for @childWalletDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete child wallet: {error}'**
  String childWalletDeleteFailed(Object error);

  /// No description provided for @childAccountsTitle.
  ///
  /// In en, this message translates to:
  /// **'Child Accounts'**
  String get childAccountsTitle;

  /// No description provided for @childManageUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Turn off child mode to manage child accounts.'**
  String get childManageUnavailable;

  /// No description provided for @childNoAccountsYet.
  ///
  /// In en, this message translates to:
  /// **'No child accounts yet'**
  String get childNoAccountsYet;

  /// No description provided for @childAccountCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 child account} other{{count} child accounts}}'**
  String childAccountCount(num count);

  /// No description provided for @childAddAccount.
  ///
  /// In en, this message translates to:
  /// **'Add Child Account'**
  String get childAddAccount;

  /// No description provided for @childEditAccount.
  ///
  /// In en, this message translates to:
  /// **'Edit Child Account'**
  String get childEditAccount;

  /// No description provided for @childName.
  ///
  /// In en, this message translates to:
  /// **'Child name'**
  String get childName;

  /// No description provided for @childNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Alice'**
  String get childNameHint;

  /// No description provided for @childWalletAddress.
  ///
  /// In en, this message translates to:
  /// **'Child Wallet Address'**
  String get childWalletAddress;

  /// No description provided for @childScanAgain.
  ///
  /// In en, this message translates to:
  /// **'Scan Again'**
  String get childScanAgain;

  /// No description provided for @childScanQrAgain.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code Again'**
  String get childScanQrAgain;

  /// No description provided for @childEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a child name.'**
  String get childEnterName;

  /// No description provided for @childEnterValidWalletAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid wallet address.'**
  String get childEnterValidWalletAddress;

  /// No description provided for @childWalletTitle.
  ///
  /// In en, this message translates to:
  /// **'Child Wallet'**
  String get childWalletTitle;

  /// No description provided for @childWalletNotFound.
  ///
  /// In en, this message translates to:
  /// **'Child wallet not found'**
  String get childWalletNotFound;

  /// No description provided for @childAddressCopied.
  ///
  /// In en, this message translates to:
  /// **'Address copied to clipboard'**
  String get childAddressCopied;

  /// No description provided for @childTotalBalance.
  ///
  /// In en, this message translates to:
  /// **'Total Balance'**
  String get childTotalBalance;

  /// No description provided for @childSendToChildWallet.
  ///
  /// In en, this message translates to:
  /// **'Send to Child Wallet'**
  String get childSendToChildWallet;

  /// No description provided for @childNoAssets.
  ///
  /// In en, this message translates to:
  /// **'No assets'**
  String get childNoAssets;

  /// No description provided for @childAssets.
  ///
  /// In en, this message translates to:
  /// **'Assets'**
  String get childAssets;

  /// No description provided for @childWalletLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Error loading child wallet: {error}'**
  String childWalletLoadFailed(Object error);

  /// No description provided for @feedbackHeading.
  ///
  /// In en, this message translates to:
  /// **'Tell us what went wrong'**
  String get feedbackHeading;

  /// No description provided for @feedbackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send your question or issue directly to Benny Wallet support.'**
  String get feedbackSubtitle;

  /// No description provided for @feedbackEmailOptional.
  ///
  /// In en, this message translates to:
  /// **'Email (optional)'**
  String get feedbackEmailOptional;

  /// No description provided for @feedbackMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get feedbackMessage;

  /// No description provided for @feedbackMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the issue you are seeing.'**
  String get feedbackMessageHint;

  /// No description provided for @feedbackSending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get feedbackSending;

  /// No description provided for @feedbackMessageRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Message Required'**
  String get feedbackMessageRequiredTitle;

  /// No description provided for @feedbackMessageRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter your feedback before sending.'**
  String get feedbackMessageRequiredMessage;

  /// No description provided for @feedbackMessageTooLongTitle.
  ///
  /// In en, this message translates to:
  /// **'Message Too Long'**
  String get feedbackMessageTooLongTitle;

  /// No description provided for @feedbackMessageTooLongMessage.
  ///
  /// In en, this message translates to:
  /// **'Keep your feedback within 2000 characters.'**
  String get feedbackMessageTooLongMessage;

  /// No description provided for @feedbackInvalidEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Invalid Email'**
  String get feedbackInvalidEmailTitle;

  /// No description provided for @feedbackInvalidEmailMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address or leave it empty.'**
  String get feedbackInvalidEmailMessage;

  /// No description provided for @feedbackSent.
  ///
  /// In en, this message translates to:
  /// **'Your message has been sent.'**
  String get feedbackSent;

  /// No description provided for @feedbackSendFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Send Failed'**
  String get feedbackSendFailedTitle;

  /// No description provided for @feedbackSendFailedFallback.
  ///
  /// In en, this message translates to:
  /// **'Unable to send your message right now. Please try again shortly.'**
  String get feedbackSendFailedFallback;

  /// No description provided for @rentTitle.
  ///
  /// In en, this message translates to:
  /// **'Solana Rent Reclaim'**
  String get rentTitle;

  /// No description provided for @rentDescription.
  ///
  /// In en, this message translates to:
  /// **'Close empty token accounts and recover their rent back to your main SOL balance.'**
  String get rentDescription;

  /// No description provided for @rentWalletAddress.
  ///
  /// In en, this message translates to:
  /// **'Wallet address'**
  String get rentWalletAddress;

  /// No description provided for @rentClosableTokenAccounts.
  ///
  /// In en, this message translates to:
  /// **'Closable token accounts'**
  String get rentClosableTokenAccounts;

  /// No description provided for @rentReclaimableRent.
  ///
  /// In en, this message translates to:
  /// **'Reclaimable rent'**
  String get rentReclaimableRent;

  /// No description provided for @rentAccountsToClose.
  ///
  /// In en, this message translates to:
  /// **'Accounts to close'**
  String get rentAccountsToClose;

  /// No description provided for @rentMoreAccounts.
  ///
  /// In en, this message translates to:
  /// **'+{count} more accounts will be reclaimed.'**
  String rentMoreAccounts(Object count);

  /// No description provided for @rentReclaiming.
  ///
  /// In en, this message translates to:
  /// **'Reclaiming...'**
  String get rentReclaiming;

  /// No description provided for @rentNothingToReclaim.
  ///
  /// In en, this message translates to:
  /// **'Nothing to reclaim'**
  String get rentNothingToReclaim;

  /// No description provided for @rentReclaimAll.
  ///
  /// In en, this message translates to:
  /// **'Reclaim all rent'**
  String get rentReclaimAll;

  /// No description provided for @rentReclaimingRent.
  ///
  /// In en, this message translates to:
  /// **'Reclaiming rent...'**
  String get rentReclaimingRent;

  /// No description provided for @rentSubmittingTransactions.
  ///
  /// In en, this message translates to:
  /// **'Submitting close-account transactions now.'**
  String get rentSubmittingTransactions;

  /// No description provided for @rentUnlockRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock Required'**
  String get rentUnlockRequiredTitle;

  /// No description provided for @rentUnlockRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Unlock the wallet again before reclaiming rent.'**
  String get rentUnlockRequiredMessage;

  /// No description provided for @rentReclaimFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Reclaim Failed'**
  String get rentReclaimFailedTitle;

  /// No description provided for @rentWalletRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Wallet Required'**
  String get rentWalletRequiredTitle;

  /// No description provided for @rentConnectSeekerVaultAgain.
  ///
  /// In en, this message translates to:
  /// **'Connect Seeker Vault again before reclaiming rent.'**
  String get rentConnectSeekerVaultAgain;

  /// No description provided for @rentConnectSeedVaultAgain.
  ///
  /// In en, this message translates to:
  /// **'Connect Seed Vault again before reclaiming rent.'**
  String get rentConnectSeedVaultAgain;

  /// No description provided for @rentSubmittedTransactions.
  ///
  /// In en, this message translates to:
  /// **'Submitted {count, plural, one{1 reclaim transaction} other{{count} reclaim transactions}}.'**
  String rentSubmittedTransactions(num count);

  /// No description provided for @rentSubmittedTransactionsWithSkipped.
  ///
  /// In en, this message translates to:
  /// **'Submitted {submitted, plural, one{1 reclaim transaction} other{{submitted} reclaim transactions}}; {skipped, plural, one{1 account} other{{skipped} accounts}} skipped.'**
  String rentSubmittedTransactionsWithSkipped(num skipped, num submitted);

  /// No description provided for @rentUnableScan.
  ///
  /// In en, this message translates to:
  /// **'Unable to scan reclaimable token accounts right now.'**
  String get rentUnableScan;

  /// No description provided for @rentMintAddress.
  ///
  /// In en, this message translates to:
  /// **'Mint {address}'**
  String rentMintAddress(Object address);

  /// No description provided for @airdropTitle.
  ///
  /// In en, this message translates to:
  /// **'BYC Airdrop'**
  String get airdropTitle;

  /// No description provided for @airdropUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'BYC airdrop temporarily unavailable'**
  String get airdropUnavailableTitle;

  /// No description provided for @airdropUnlockBeforeJoin.
  ///
  /// In en, this message translates to:
  /// **'Unlock your wallet before joining the BYC airdrop.'**
  String get airdropUnlockBeforeJoin;

  /// No description provided for @airdropJoinDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Join the BYC airdrop?'**
  String get airdropJoinDialogTitle;

  /// No description provided for @airdropJoinDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'We will use your current Benny wallet address:\n\n{address}\n\nThis address will be sent to the Benny backend to register your airdrop profile.'**
  String airdropJoinDialogMessage(Object address);

  /// No description provided for @airdropJoin.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get airdropJoin;

  /// No description provided for @airdropJoinedSnack.
  ///
  /// In en, this message translates to:
  /// **'You are in. Your BYC reward profile is ready.'**
  String get airdropJoinedSnack;

  /// No description provided for @airdropJoinBeforeCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Join the BYC airdrop before checking in.'**
  String get airdropJoinBeforeCheckIn;

  /// No description provided for @airdropUnlockBeforeCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Unlock your wallet before checking in.'**
  String get airdropUnlockBeforeCheckIn;

  /// No description provided for @airdropJoined.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get airdropJoined;

  /// No description provided for @airdropNotJoined.
  ///
  /// In en, this message translates to:
  /// **'Not joined'**
  String get airdropNotJoined;

  /// No description provided for @airdropBycPoints.
  ///
  /// In en, this message translates to:
  /// **'BYC points'**
  String get airdropBycPoints;

  /// No description provided for @airdropStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get airdropStreak;

  /// No description provided for @airdropDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 day} other{{count} days}}'**
  String airdropDays(num count);

  /// No description provided for @airdropWalletUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Wallet unavailable'**
  String get airdropWalletUnavailable;

  /// No description provided for @airdropJoinCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Join the airdrop'**
  String get airdropJoinCardTitle;

  /// No description provided for @airdropJoinCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm with your active Benny wallet and create your BYC reward profile.'**
  String get airdropJoinCardSubtitle;

  /// No description provided for @airdropJoining.
  ///
  /// In en, this message translates to:
  /// **'Joining...'**
  String get airdropJoining;

  /// No description provided for @airdropJoinWithThisWallet.
  ///
  /// In en, this message translates to:
  /// **'Join With This Wallet'**
  String get airdropJoinWithThisWallet;

  /// No description provided for @airdropCheckInNow.
  ///
  /// In en, this message translates to:
  /// **'Check in now'**
  String get airdropCheckInNow;

  /// No description provided for @airdropCheckedInToday.
  ///
  /// In en, this message translates to:
  /// **'Checked in today'**
  String get airdropCheckedInToday;

  /// No description provided for @airdropNextReward.
  ///
  /// In en, this message translates to:
  /// **'Next reward: +{points} BYC'**
  String airdropNextReward(Object points);

  /// No description provided for @airdropComeBackTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Come back tomorrow to claim more BYC.'**
  String get airdropComeBackTomorrow;

  /// No description provided for @airdropCheckingIn.
  ///
  /// In en, this message translates to:
  /// **'Checking in...'**
  String get airdropCheckingIn;

  /// No description provided for @airdropLastClaimed.
  ///
  /// In en, this message translates to:
  /// **'Last claimed {date}'**
  String airdropLastClaimed(Object date);

  /// No description provided for @airdropRewardRules.
  ///
  /// In en, this message translates to:
  /// **'Reward rules'**
  String get airdropRewardRules;

  /// No description provided for @airdropFirstCheckIn.
  ///
  /// In en, this message translates to:
  /// **'First check-in'**
  String get airdropFirstCheckIn;

  /// No description provided for @airdropNextDayReward.
  ///
  /// In en, this message translates to:
  /// **'Next day reward'**
  String get airdropNextDayReward;

  /// No description provided for @airdropEveryDayStreak.
  ///
  /// In en, this message translates to:
  /// **'Every {days}-day streak'**
  String airdropEveryDayStreak(Object days);

  /// No description provided for @airdropUnableOpenPumpFun.
  ///
  /// In en, this message translates to:
  /// **'Unable to open Pump.fun right now.'**
  String get airdropUnableOpenPumpFun;

  /// No description provided for @airdropView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get airdropView;

  /// No description provided for @airdropPointsBalanceUpdated.
  ///
  /// In en, this message translates to:
  /// **'Your Benny points balance has been updated.'**
  String get airdropPointsBalanceUpdated;

  /// No description provided for @airdropFirstCheckInUnlocked.
  ///
  /// In en, this message translates to:
  /// **'First check-in unlocked'**
  String get airdropFirstCheckInUnlocked;

  /// No description provided for @airdropStreakBonusLanded.
  ///
  /// In en, this message translates to:
  /// **'Streak bonus landed'**
  String get airdropStreakBonusLanded;

  /// No description provided for @airdropAlreadyClaimedToday.
  ///
  /// In en, this message translates to:
  /// **'Already claimed today'**
  String get airdropAlreadyClaimedToday;

  /// No description provided for @airdropRewardClaimed.
  ///
  /// In en, this message translates to:
  /// **'Reward claimed'**
  String get airdropRewardClaimed;

  /// No description provided for @defiTypeDeposit.
  ///
  /// In en, this message translates to:
  /// **'deposit'**
  String get defiTypeDeposit;

  /// No description provided for @defiTypeBorrow.
  ///
  /// In en, this message translates to:
  /// **'borrow'**
  String get defiTypeBorrow;

  /// No description provided for @defiTypeStaking.
  ///
  /// In en, this message translates to:
  /// **'staking'**
  String get defiTypeStaking;

  /// No description provided for @defiTypeLiquidity.
  ///
  /// In en, this message translates to:
  /// **'liquidity'**
  String get defiTypeLiquidity;

  /// No description provided for @defiTypeYield.
  ///
  /// In en, this message translates to:
  /// **'yield'**
  String get defiTypeYield;

  /// No description provided for @defiTypePerps.
  ///
  /// In en, this message translates to:
  /// **'perps'**
  String get defiTypePerps;

  /// No description provided for @defiTypeRewards.
  ///
  /// In en, this message translates to:
  /// **'rewards'**
  String get defiTypeRewards;

  /// No description provided for @defiTypePosition.
  ///
  /// In en, this message translates to:
  /// **'position'**
  String get defiTypePosition;

  /// No description provided for @settingsSeekerWallet.
  ///
  /// In en, this message translates to:
  /// **'Seeker Wallet'**
  String get settingsSeekerWallet;

  /// No description provided for @updateDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get updateDefaultTitle;

  /// No description provided for @updateDefaultMessage.
  ///
  /// In en, this message translates to:
  /// **'A newer version of Benny Wallet is available.'**
  String get updateDefaultMessage;

  /// No description provided for @updateFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Failed'**
  String get updateFailedTitle;

  /// No description provided for @updateUnableToOpen.
  ///
  /// In en, this message translates to:
  /// **'Unable to open the Benny Wallet update link right now.'**
  String get updateUnableToOpen;

  /// No description provided for @routerFeatureUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Feature unavailable'**
  String get routerFeatureUnavailableTitle;

  /// No description provided for @routerFeatureUnavailableMessage.
  ///
  /// In en, this message translates to:
  /// **'This feature is not available in this build.'**
  String get routerFeatureUnavailableMessage;

  /// No description provided for @routerMessageUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Message unavailable'**
  String get routerMessageUnavailableTitle;

  /// No description provided for @routerMessageUnavailableMessage.
  ///
  /// In en, this message translates to:
  /// **'Open a received message from the message list first.'**
  String get routerMessageUnavailableMessage;

  /// No description provided for @routerSendDetailsUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Send details unavailable'**
  String get routerSendDetailsUnavailableTitle;

  /// No description provided for @routerSendDetailsUnavailableMessage.
  ///
  /// In en, this message translates to:
  /// **'Open a transaction from send history first.'**
  String get routerSendDetailsUnavailableMessage;

  /// No description provided for @routerInvalidChildWalletId.
  ///
  /// In en, this message translates to:
  /// **'Invalid child wallet ID'**
  String get routerInvalidChildWalletId;

  /// No description provided for @routerRouteNotFound.
  ///
  /// In en, this message translates to:
  /// **'Route not found: {uri}'**
  String routerRouteNotFound(String uri);

  /// No description provided for @walletsTitle.
  ///
  /// In en, this message translates to:
  /// **'Wallets'**
  String get walletsTitle;

  /// No description provided for @walletsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Switch, add, rename or remove wallets'**
  String get walletsSubtitle;

  /// No description provided for @walletSwitcherTitle.
  ///
  /// In en, this message translates to:
  /// **'Your wallets'**
  String get walletSwitcherTitle;

  /// No description provided for @walletSwitcherCount.
  ///
  /// In en, this message translates to:
  /// **'{count} of {max}'**
  String walletSwitcherCount(int count, int max);

  /// No description provided for @walletAddWallet.
  ///
  /// In en, this message translates to:
  /// **'Add wallet'**
  String get walletAddWallet;

  /// No description provided for @walletAddLimitReached.
  ///
  /// In en, this message translates to:
  /// **'You can add up to {max} wallets.'**
  String walletAddLimitReached(int max);

  /// No description provided for @walletManage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get walletManage;

  /// No description provided for @walletAddSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a wallet'**
  String get walletAddSheetTitle;

  /// No description provided for @walletAddSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Each wallet has its own recovery phrase and account. One PIN unlocks them all.'**
  String get walletAddSheetSubtitle;

  /// No description provided for @walletAddCreate.
  ///
  /// In en, this message translates to:
  /// **'Create new wallet'**
  String get walletAddCreate;

  /// No description provided for @walletAddCreateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Generate a fresh recovery phrase'**
  String get walletAddCreateSubtitle;

  /// No description provided for @walletAddImport.
  ///
  /// In en, this message translates to:
  /// **'Import recovery phrase'**
  String get walletAddImport;

  /// No description provided for @walletAddImportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use a phrase or another account'**
  String get walletAddImportSubtitle;

  /// No description provided for @walletAddSeedVault.
  ///
  /// In en, this message translates to:
  /// **'Connect Seed Vault'**
  String get walletAddSeedVault;

  /// No description provided for @walletAddSeedVaultSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use an account from your Seeker'**
  String get walletAddSeedVaultSubtitle;

  /// No description provided for @walletNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Name your wallet'**
  String get walletNameTitle;

  /// No description provided for @walletNameSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Only saved on this device. You can change it anytime.'**
  String get walletNameSubtitle;

  /// No description provided for @walletNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Wallet name'**
  String get walletNameLabel;

  /// No description provided for @walletNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter a wallet name'**
  String get walletNameEmpty;

  /// No description provided for @walletAdded.
  ///
  /// In en, this message translates to:
  /// **'{name} added'**
  String walletAdded(String name);

  /// No description provided for @walletSwitched.
  ///
  /// In en, this message translates to:
  /// **'Switched to {name}'**
  String walletSwitched(String name);

  /// No description provided for @walletDuplicateTitle.
  ///
  /// In en, this message translates to:
  /// **'Already added'**
  String get walletDuplicateTitle;

  /// No description provided for @walletDuplicateMessage.
  ///
  /// In en, this message translates to:
  /// **'This recovery phrase and account is already in Benny. Each phrase + account can only be added once.'**
  String get walletDuplicateMessage;

  /// No description provided for @walletAlreadyAddedBadge.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get walletAlreadyAddedBadge;

  /// No description provided for @walletRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get walletRename;

  /// No description provided for @walletRenameTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename wallet'**
  String get walletRenameTitle;

  /// No description provided for @walletRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get walletRemove;

  /// No description provided for @walletRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}?'**
  String walletRemoveTitle(String name);

  /// No description provided for @walletRemoveMessage.
  ///
  /// In en, this message translates to:
  /// **'This removes the wallet from this device. Back up its recovery phrase first — without it the funds cannot be recovered.'**
  String get walletRemoveMessage;

  /// No description provided for @walletRemoveExternalMessage.
  ///
  /// In en, this message translates to:
  /// **'This disconnects the wallet from Benny. Your keys stay safe in Seed Vault.'**
  String get walletRemoveExternalMessage;

  /// No description provided for @walletRemoved.
  ///
  /// In en, this message translates to:
  /// **'{name} removed'**
  String walletRemoved(String name);

  /// No description provided for @walletActiveBadge.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get walletActiveBadge;

  /// No description provided for @walletTypePhrase.
  ///
  /// In en, this message translates to:
  /// **'Recovery phrase'**
  String get walletTypePhrase;

  /// No description provided for @walletTypeSeedVault.
  ///
  /// In en, this message translates to:
  /// **'Seed Vault'**
  String get walletTypeSeedVault;

  /// No description provided for @swapWalletChanged.
  ///
  /// In en, this message translates to:
  /// **'The active wallet changed. Go back and get a new quote.'**
  String get swapWalletChanged;

  /// No description provided for @seedVaultPickNamedSeed.
  ///
  /// In en, this message translates to:
  /// **'Pick the seed “{seed}” next. It holds {wallet}.'**
  String seedVaultPickNamedSeed(String seed, String wallet);

  /// No description provided for @seedVaultPickUnknownSeed.
  ///
  /// In en, this message translates to:
  /// **'Pick the seed that holds {wallet}. If you pick the wrong one, you\'ll be told and it disappears from the list.'**
  String seedVaultPickUnknownSeed(String wallet);

  /// No description provided for @seedVaultWrongSeedNamed.
  ///
  /// In en, this message translates to:
  /// **'“{seed}” doesn\'t contain this wallet.'**
  String seedVaultWrongSeedNamed(String seed);

  /// No description provided for @seedVaultReauthorizeTitle.
  ///
  /// In en, this message translates to:
  /// **'Re-authorize Seed Vault'**
  String get seedVaultReauthorizeTitle;

  /// No description provided for @childAddFromMyWallets.
  ///
  /// In en, this message translates to:
  /// **'Or pick one of my wallets'**
  String get childAddFromMyWallets;

  /// No description provided for @walletAddChildModeSetPin.
  ///
  /// In en, this message translates to:
  /// **'This wallet has no saved child-mode PIN. Set one next; it\'s needed to turn child mode off.'**
  String get walletAddChildModeSetPin;

  /// No description provided for @settingsChildModeAppPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your app PIN to turn off child mode'**
  String get settingsChildModeAppPinTitle;

  /// No description provided for @walletAddChildModeTitle.
  ///
  /// In en, this message translates to:
  /// **'This is a child-mode wallet'**
  String get walletAddChildModeTitle;

  /// No description provided for @walletAddChildModeMessage.
  ///
  /// In en, this message translates to:
  /// **'After importing, the app switches to child mode: wallet switching is hidden, no wallets can be added, and you can\'t send to your other wallets. Import it anyway?'**
  String get walletAddChildModeMessage;

  /// No description provided for @walletAddChildModeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Agree and import'**
  String get walletAddChildModeConfirm;

  /// No description provided for @walletTypeStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get walletTypeStandard;

  /// Label above one-tap chips that fill the recipient with one of the user's own wallets.
  ///
  /// In en, this message translates to:
  /// **'Send to my wallet'**
  String get sendToMyWallet;

  /// No description provided for @walletChildModeLocked.
  ///
  /// In en, this message translates to:
  /// **'Turn off child mode to switch or add wallets.'**
  String get walletChildModeLocked;

  /// No description provided for @walletPinToContinue.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN to continue'**
  String get walletPinToContinue;

  /// No description provided for @walletActionFailed.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get walletActionFailed;

  /// No description provided for @settingsChangePin.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get settingsChangePin;

  /// No description provided for @settingsChangePinSubtitle.
  ///
  /// In en, this message translates to:
  /// **'One PIN unlocks all your wallets'**
  String get settingsChangePinSubtitle;

  /// No description provided for @changePinCurrent.
  ///
  /// In en, this message translates to:
  /// **'Enter current PIN'**
  String get changePinCurrent;

  /// No description provided for @changePinNew.
  ///
  /// In en, this message translates to:
  /// **'Enter new PIN'**
  String get changePinNew;

  /// No description provided for @changePinConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm new PIN'**
  String get changePinConfirm;

  /// No description provided for @changePinSuccess.
  ///
  /// In en, this message translates to:
  /// **'PIN changed'**
  String get changePinSuccess;

  /// No description provided for @changePinSameAsOld.
  ///
  /// In en, this message translates to:
  /// **'Choose a different PIN'**
  String get changePinSameAsOld;

  /// No description provided for @unlockSetPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Set a Benny PIN'**
  String get unlockSetPinTitle;

  /// No description provided for @unlockSetPinSubtitle.
  ///
  /// In en, this message translates to:
  /// **'One PIN now protects every wallet on this device.'**
  String get unlockSetPinSubtitle;

  /// No description provided for @pinUnlocksAllWallets.
  ///
  /// In en, this message translates to:
  /// **'This PIN unlocks all your wallets.'**
  String get pinUnlocksAllWallets;

  /// No description provided for @settingsLogOutAllWallets.
  ///
  /// In en, this message translates to:
  /// **'This removes all {count} wallets from this device. Back up every recovery phrase first.'**
  String settingsLogOutAllWallets(int count);

  /// No description provided for @importAccountLabel.
  ///
  /// In en, this message translates to:
  /// **'Account {number}'**
  String importAccountLabel(int number);

  /// No description provided for @importAccountAltLabel.
  ///
  /// In en, this message translates to:
  /// **'Account {number} · alt path'**
  String importAccountAltLabel(int number);

  /// No description provided for @importLegacyLabel.
  ///
  /// In en, this message translates to:
  /// **'Legacy'**
  String get importLegacyLabel;

  /// No description provided for @travelGuardTitle.
  ///
  /// In en, this message translates to:
  /// **'Travel guard'**
  String get travelGuardTitle;

  /// No description provided for @travelGuardOffSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A special PIN that opens only one wallet'**
  String get travelGuardOffSubtitle;

  /// No description provided for @travelGuardOnSubtitle.
  ///
  /// In en, this message translates to:
  /// **'On: the special PIN opens one wallet'**
  String get travelGuardOnSubtitle;

  /// No description provided for @travelGuardInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'What is travel guard?'**
  String get travelGuardInfoTitle;

  /// No description provided for @travelGuardInfoBody.
  ///
  /// In en, this message translates to:
  /// **'For when someone forces you to open your wallet.\n\nSet a special PIN and pick one wallet (keep a small amount in it). Unlocking with the special PIN opens only that wallet: your other wallets, their balances and messages are hidden everywhere, including wallet lists and send, and this setting is hidden too. It looks like an ordinary wallet.\n\nWhile travel guard is on, biometric unlock is turned off and cannot be turned on, so the PIN is always asked.\n\nLock the app (or let it lock) and unlock with your normal PIN to see all your wallets again.'**
  String get travelGuardInfoBody;

  /// No description provided for @travelGuardChooseWallet.
  ///
  /// In en, this message translates to:
  /// **'Choose the wallet the special PIN opens'**
  String get travelGuardChooseWallet;

  /// No description provided for @travelGuardNewPin.
  ///
  /// In en, this message translates to:
  /// **'Set the special PIN'**
  String get travelGuardNewPin;

  /// No description provided for @travelGuardConfirmPin.
  ///
  /// In en, this message translates to:
  /// **'Enter the special PIN again'**
  String get travelGuardConfirmPin;

  /// No description provided for @travelGuardPinHint.
  ///
  /// In en, this message translates to:
  /// **'It must differ from your normal PIN.'**
  String get travelGuardPinHint;

  /// No description provided for @travelGuardPinSameAsApp.
  ///
  /// In en, this message translates to:
  /// **'This is your normal PIN. Choose another one.'**
  String get travelGuardPinSameAsApp;

  /// No description provided for @travelGuardEnabled.
  ///
  /// In en, this message translates to:
  /// **'Travel guard is on'**
  String get travelGuardEnabled;

  /// No description provided for @travelGuardDisabled.
  ///
  /// In en, this message translates to:
  /// **'Travel guard is off'**
  String get travelGuardDisabled;

  /// No description provided for @travelGuardActiveBadge.
  ///
  /// In en, this message translates to:
  /// **'Travel guard is on'**
  String get travelGuardActiveBadge;

  /// No description provided for @travelGuardBiometricsOff.
  ///
  /// In en, this message translates to:
  /// **'Unavailable while travel guard is on'**
  String get travelGuardBiometricsOff;

  /// No description provided for @welcomeUseAsSigner.
  ///
  /// In en, this message translates to:
  /// **'Use this phone as an offline signer'**
  String get welcomeUseAsSigner;

  /// No description provided for @walletAddAirGap.
  ///
  /// In en, this message translates to:
  /// **'Connect offline signer'**
  String get walletAddAirGap;

  /// No description provided for @walletAddAirGapSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keys stay on another phone that never goes online'**
  String get walletAddAirGapSubtitle;

  /// No description provided for @createWalletWordCount.
  ///
  /// In en, this message translates to:
  /// **'{count} words'**
  String createWalletWordCount(int count);

  /// No description provided for @signerAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Benny Signer'**
  String get signerAppTitle;

  /// No description provided for @signerNeedsNoWalletsTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove all wallets first'**
  String get signerNeedsNoWalletsTitle;

  /// No description provided for @signerNeedsNoWalletsBody.
  ///
  /// In en, this message translates to:
  /// **'A signer phone holds only its own offline recovery phrase. Back up and remove every wallet on this phone in Settings > Wallets, then try again.'**
  String get signerNeedsNoWalletsBody;

  /// No description provided for @signerEnterTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn this phone into a signer?'**
  String get signerEnterTitle;

  /// No description provided for @signerEnterBody.
  ///
  /// In en, this message translates to:
  /// **'This phone will stay offline and only sign. It will have no wallet screens. To use it as a wallet again you will have to erase it.'**
  String get signerEnterBody;

  /// No description provided for @signerIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Offline signer'**
  String get signerIntroTitle;

  /// No description provided for @signerIntroPoint1.
  ///
  /// In en, this message translates to:
  /// **'This phone keeps your recovery phrase and never goes online again.'**
  String get signerIntroPoint1;

  /// No description provided for @signerIntroPoint2.
  ///
  /// In en, this message translates to:
  /// **'Your other phone with Benny Wallet builds transactions. You sign them here by scanning QR codes.'**
  String get signerIntroPoint2;

  /// No description provided for @signerIntroPoint3.
  ///
  /// In en, this message translates to:
  /// **'Before a recovery phrase is created, we will help you switch off every network.'**
  String get signerIntroPoint3;

  /// No description provided for @signerIntroPoint4.
  ///
  /// In en, this message translates to:
  /// **'Write the recovery phrase on paper. It is the only backup.'**
  String get signerIntroPoint4;

  /// No description provided for @signerIntroStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get signerIntroStart;

  /// No description provided for @signerIntroCancel.
  ///
  /// In en, this message translates to:
  /// **'Not now, use as a wallet'**
  String get signerIntroCancel;

  /// No description provided for @signerOfflineTitle.
  ///
  /// In en, this message translates to:
  /// **'Take this phone offline'**
  String get signerOfflineTitle;

  /// No description provided for @signerOfflineBody.
  ///
  /// In en, this message translates to:
  /// **'Turn on airplane mode and switch off Wi-Fi, Bluetooth and NFC. You can continue once every required item is green.'**
  String get signerOfflineBody;

  /// No description provided for @signerCheckAirplane.
  ///
  /// In en, this message translates to:
  /// **'Airplane mode on'**
  String get signerCheckAirplane;

  /// No description provided for @signerCheckWifi.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi off'**
  String get signerCheckWifi;

  /// No description provided for @signerCheckBluetooth.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth off'**
  String get signerCheckBluetooth;

  /// No description provided for @signerCheckNfc.
  ///
  /// In en, this message translates to:
  /// **'NFC off'**
  String get signerCheckNfc;

  /// No description provided for @signerCheckNoNetwork.
  ///
  /// In en, this message translates to:
  /// **'No network connection'**
  String get signerCheckNoNetwork;

  /// No description provided for @signerCheckUsbDebugging.
  ///
  /// In en, this message translates to:
  /// **'USB debugging off'**
  String get signerCheckUsbDebugging;

  /// No description provided for @signerCheckSim.
  ///
  /// In en, this message translates to:
  /// **'SIM card removed (recommended)'**
  String get signerCheckSim;

  /// No description provided for @signerCheckManualHint.
  ///
  /// In en, this message translates to:
  /// **'This phone can\'t check this. Confirm it yourself.'**
  String get signerCheckManualHint;

  /// No description provided for @signerOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get signerOpenSettings;

  /// No description provided for @signerNetworkDetected.
  ///
  /// In en, this message translates to:
  /// **'A network connection was detected. Switch it off to continue.'**
  String get signerNetworkDetected;

  /// No description provided for @signerPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Set signer PIN'**
  String get signerPinTitle;

  /// No description provided for @signerPinBody.
  ///
  /// In en, this message translates to:
  /// **'Choose a 6-digit PIN for this signer.'**
  String get signerPinBody;

  /// No description provided for @signerPinConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get signerPinConfirmTitle;

  /// No description provided for @signerPinConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Enter the PIN again.'**
  String get signerPinConfirmBody;

  /// No description provided for @signerPinMismatch.
  ///
  /// In en, this message translates to:
  /// **'The PINs don\'t match. Try again.'**
  String get signerPinMismatch;

  /// No description provided for @signerSourceTitle.
  ///
  /// In en, this message translates to:
  /// **'Recovery phrase'**
  String get signerSourceTitle;

  /// No description provided for @signerSourceBody.
  ///
  /// In en, this message translates to:
  /// **'Create a new recovery phrase on this offline phone, or enter one you already have.'**
  String get signerSourceBody;

  /// No description provided for @signerSourceCreate24.
  ///
  /// In en, this message translates to:
  /// **'Create 24 words'**
  String get signerSourceCreate24;

  /// No description provided for @signerSourceCreate24Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Recommended for a signer'**
  String get signerSourceCreate24Subtitle;

  /// No description provided for @signerSourceCreate12.
  ///
  /// In en, this message translates to:
  /// **'Create 12 words'**
  String get signerSourceCreate12;

  /// No description provided for @signerSourceCreate12Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Shorter to write down'**
  String get signerSourceCreate12Subtitle;

  /// No description provided for @signerSourceImport.
  ///
  /// In en, this message translates to:
  /// **'Import existing phrase'**
  String get signerSourceImport;

  /// No description provided for @signerSourceImportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'12 or 24 words'**
  String get signerSourceImportSubtitle;

  /// No description provided for @signerWordsTitle.
  ///
  /// In en, this message translates to:
  /// **'Write these words down'**
  String get signerWordsTitle;

  /// No description provided for @signerWordsWarning.
  ///
  /// In en, this message translates to:
  /// **'Write the words on paper in order. Never take a photo, screenshot or type them anywhere else. Anyone with these words can take your funds.'**
  String get signerWordsWarning;

  /// No description provided for @signerWordsDone.
  ///
  /// In en, this message translates to:
  /// **'I wrote them down'**
  String get signerWordsDone;

  /// No description provided for @signerVerifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your backup'**
  String get signerVerifyTitle;

  /// No description provided for @signerImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import recovery phrase'**
  String get signerImportTitle;

  /// No description provided for @signerImportBody.
  ///
  /// In en, this message translates to:
  /// **'Enter your 12 or 24 words separated by spaces.'**
  String get signerImportBody;

  /// No description provided for @signerImportInvalid.
  ///
  /// In en, this message translates to:
  /// **'This isn\'t a valid 12 or 24 word recovery phrase.'**
  String get signerImportInvalid;

  /// No description provided for @signerFinishTitle.
  ///
  /// In en, this message translates to:
  /// **'Finish setup'**
  String get signerFinishTitle;

  /// No description provided for @signerDeviceNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Signer name'**
  String get signerDeviceNameLabel;

  /// No description provided for @signerDeviceNameHelper.
  ///
  /// In en, this message translates to:
  /// **'Shown in your wallet after you connect.'**
  String get signerDeviceNameHelper;

  /// No description provided for @signerBiometricToggle.
  ///
  /// In en, this message translates to:
  /// **'Unlock with biometrics'**
  String get signerBiometricToggle;

  /// No description provided for @signerFinishButton.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get signerFinishButton;

  /// No description provided for @signerSetupFailed.
  ///
  /// In en, this message translates to:
  /// **'Setup couldn\'t be saved. Try again.'**
  String get signerSetupFailed;

  /// No description provided for @signerUnlockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your signer PIN'**
  String get signerUnlockSubtitle;

  /// No description provided for @signerUnlockNetworkBlocked.
  ///
  /// In en, this message translates to:
  /// **'A network connection is on. Turn on airplane mode to unlock.'**
  String get signerUnlockNetworkBlocked;

  /// No description provided for @signerWrongPin.
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN. {count} attempts left before the signer is erased.'**
  String signerWrongPin(int count);

  /// No description provided for @signerUnlockFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t unlock. Try again.'**
  String get signerUnlockFailed;

  /// No description provided for @signerUseBiometric.
  ///
  /// In en, this message translates to:
  /// **'Use biometrics'**
  String get signerUseBiometric;

  /// No description provided for @signerBiometricReason.
  ///
  /// In en, this message translates to:
  /// **'Unlock your Benny signer'**
  String get signerBiometricReason;

  /// No description provided for @signerBiometricFailed.
  ///
  /// In en, this message translates to:
  /// **'Biometrics couldn\'t be changed.'**
  String get signerBiometricFailed;

  /// No description provided for @signerRecheckTitle.
  ///
  /// In en, this message translates to:
  /// **'Offline check'**
  String get signerRecheckTitle;

  /// No description provided for @signerRecheckBody.
  ///
  /// In en, this message translates to:
  /// **'The app was updated. Make sure this phone is fully offline again before you unlock it.'**
  String get signerRecheckBody;

  /// No description provided for @signerLockNow.
  ///
  /// In en, this message translates to:
  /// **'Lock'**
  String get signerLockNow;

  /// No description provided for @signerOfflineChip.
  ///
  /// In en, this message translates to:
  /// **'Offline signer'**
  String get signerOfflineChip;

  /// No description provided for @signerScanToSign.
  ///
  /// In en, this message translates to:
  /// **'Scan to sign'**
  String get signerScanToSign;

  /// No description provided for @signerPairWallet.
  ///
  /// In en, this message translates to:
  /// **'Connect wallet'**
  String get signerPairWallet;

  /// No description provided for @signerAccountsTitle.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get signerAccountsTitle;

  /// No description provided for @signerAccountName.
  ///
  /// In en, this message translates to:
  /// **'Account {number}'**
  String signerAccountName(int number);

  /// No description provided for @signerPairBody.
  ///
  /// In en, this message translates to:
  /// **'In Benny Wallet on your other phone, choose Connect offline signer and scan this code.'**
  String get signerPairBody;

  /// No description provided for @signerPairPublicOnly.
  ///
  /// In en, this message translates to:
  /// **'This code contains only public addresses, never your recovery phrase.'**
  String get signerPairPublicOnly;

  /// No description provided for @signerScanBody.
  ///
  /// In en, this message translates to:
  /// **'Scan the QR code shown by Benny Wallet on your other phone.'**
  String get signerScanBody;

  /// No description provided for @signerScanWrongCode.
  ///
  /// In en, this message translates to:
  /// **'This isn\'t a signing request from Benny Wallet.'**
  String get signerScanWrongCode;

  /// No description provided for @signerScanAgain.
  ///
  /// In en, this message translates to:
  /// **'Scan again'**
  String get signerScanAgain;

  /// No description provided for @signerRejectUnknownAccount.
  ///
  /// In en, this message translates to:
  /// **'This request is for an account that isn\'t on this signer.'**
  String get signerRejectUnknownAccount;

  /// No description provided for @signerRejectNotASigner.
  ///
  /// In en, this message translates to:
  /// **'This account doesn\'t need to sign this transaction.'**
  String get signerRejectNotASigner;

  /// No description provided for @signerRejectUnreadable.
  ///
  /// In en, this message translates to:
  /// **'This transaction can\'t be read, so it won\'t be signed.'**
  String get signerRejectUnreadable;

  /// No description provided for @signerRejectMessageIsTransaction.
  ///
  /// In en, this message translates to:
  /// **'This message is actually a transaction, so it won\'t be signed.'**
  String get signerRejectMessageIsTransaction;

  /// No description provided for @signerRejectInvalidCode.
  ///
  /// In en, this message translates to:
  /// **'This QR code isn\'t a valid signing request.'**
  String get signerRejectInvalidCode;

  /// No description provided for @signerReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review and sign'**
  String get signerReviewTitle;

  /// No description provided for @signerReviewAccount.
  ///
  /// In en, this message translates to:
  /// **'Signing account'**
  String get signerReviewAccount;

  /// No description provided for @signerReviewFee.
  ///
  /// In en, this message translates to:
  /// **'Network fee'**
  String get signerReviewFee;

  /// No description provided for @signerReviewMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get signerReviewMessage;

  /// No description provided for @signerBinaryMessage.
  ///
  /// In en, this message translates to:
  /// **'Binary data ({count} bytes)'**
  String signerBinaryMessage(int count);

  /// No description provided for @signerThisAccount.
  ///
  /// In en, this message translates to:
  /// **'this account'**
  String get signerThisAccount;

  /// No description provided for @signerActionSendSol.
  ///
  /// In en, this message translates to:
  /// **'Send {amount} SOL'**
  String signerActionSendSol(String amount);

  /// No description provided for @signerActionSendToken.
  ///
  /// In en, this message translates to:
  /// **'Send {amount} {symbol}'**
  String signerActionSendToken(String amount, String symbol);

  /// No description provided for @signerActionSendUnverified.
  ///
  /// In en, this message translates to:
  /// **'Send {amount} of an unverified token'**
  String signerActionSendUnverified(String amount);

  /// No description provided for @signerActionTo.
  ///
  /// In en, this message translates to:
  /// **'To {address}'**
  String signerActionTo(String address);

  /// No description provided for @signerActionToTokenAccount.
  ///
  /// In en, this message translates to:
  /// **'To token account {address}'**
  String signerActionToTokenAccount(String address);

  /// No description provided for @signerActionMint.
  ///
  /// In en, this message translates to:
  /// **'Token address {mint}'**
  String signerActionMint(String mint);

  /// No description provided for @signerActionOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner {address}'**
  String signerActionOwner(String address);

  /// No description provided for @signerActionRentTo.
  ///
  /// In en, this message translates to:
  /// **'Rent returned to {address}'**
  String signerActionRentTo(String address);

  /// No description provided for @signerActionCreateTokenAccount.
  ///
  /// In en, this message translates to:
  /// **'Create token account'**
  String get signerActionCreateTokenAccount;

  /// No description provided for @signerActionCloseTokenAccount.
  ///
  /// In en, this message translates to:
  /// **'Close token account'**
  String get signerActionCloseTokenAccount;

  /// No description provided for @signerActionMemo.
  ///
  /// In en, this message translates to:
  /// **'Memo'**
  String get signerActionMemo;

  /// No description provided for @signerActionApprove.
  ///
  /// In en, this message translates to:
  /// **'Allow another account to spend your tokens'**
  String get signerActionApprove;

  /// No description provided for @signerActionSetAuthority.
  ///
  /// In en, this message translates to:
  /// **'Change account authority'**
  String get signerActionSetAuthority;

  /// No description provided for @signerActionAssign.
  ///
  /// In en, this message translates to:
  /// **'Change account owner'**
  String get signerActionAssign;

  /// No description provided for @signerActionCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signerActionCreateAccount;

  /// No description provided for @signerActionProgram.
  ///
  /// In en, this message translates to:
  /// **'Program {program}'**
  String signerActionProgram(String program);

  /// No description provided for @signerHoldToSign.
  ///
  /// In en, this message translates to:
  /// **'Hold to sign'**
  String get signerHoldToSign;

  /// No description provided for @signerReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get signerReject;

  /// No description provided for @signerSignFailed.
  ///
  /// In en, this message translates to:
  /// **'Signing failed. Try again.'**
  String get signerSignFailed;

  /// No description provided for @signerSignatureTitle.
  ///
  /// In en, this message translates to:
  /// **'Signature'**
  String get signerSignatureTitle;

  /// No description provided for @signerSignatureBody.
  ///
  /// In en, this message translates to:
  /// **'Scan this code with Benny Wallet on your other phone to finish.'**
  String get signerSignatureBody;

  /// No description provided for @signerSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Signer settings'**
  String get signerSettingsTitle;

  /// No description provided for @signerAccountCount.
  ///
  /// In en, this message translates to:
  /// **'Accounts shown'**
  String get signerAccountCount;

  /// No description provided for @signerAccountCountHint.
  ///
  /// In en, this message translates to:
  /// **'Up to 5 accounts from this recovery phrase'**
  String get signerAccountCountHint;

  /// No description provided for @signerUpgradeTitle.
  ///
  /// In en, this message translates to:
  /// **'Update the signer'**
  String get signerUpgradeTitle;

  /// No description provided for @signerUpgradeIntro.
  ///
  /// In en, this message translates to:
  /// **'Updating the app needs a network, so plan it. Your recovery phrase stays encrypted on this phone while it is online, and the signer will not open it until the phone is offline again.'**
  String get signerUpgradeIntro;

  /// No description provided for @signerUpgradeStep0.
  ///
  /// In en, this message translates to:
  /// **'1. Check your paper backup'**
  String get signerUpgradeStep0;

  /// No description provided for @signerUpgradeVerifyBackup.
  ///
  /// In en, this message translates to:
  /// **'Check backup'**
  String get signerUpgradeVerifyBackup;

  /// No description provided for @signerUpgradeBackupOk.
  ///
  /// In en, this message translates to:
  /// **'Backup checked'**
  String get signerUpgradeBackupOk;

  /// No description provided for @signerUpgradeOnlineTitle.
  ///
  /// In en, this message translates to:
  /// **'2a. Standard update'**
  String get signerUpgradeOnlineTitle;

  /// No description provided for @signerUpgradeOnlineBody.
  ///
  /// In en, this message translates to:
  /// **'Lock the signer. Turn the network on and update Benny Wallet from the same store you installed it from. Turn airplane mode back on. The signer runs the offline check again before you can unlock it.'**
  String get signerUpgradeOnlineBody;

  /// No description provided for @signerUpgradeSecureTitle.
  ///
  /// In en, this message translates to:
  /// **'2b. Most secure update'**
  String get signerUpgradeSecureTitle;

  /// No description provided for @signerUpgradeSecureBody.
  ///
  /// In en, this message translates to:
  /// **'Erase the signer in settings, then update the app online. Go offline again, set up the signer and import your recovery phrase. Your accounts and addresses stay the same.'**
  String get signerUpgradeSecureBody;

  /// No description provided for @signerUpgradeOfflineApkTitle.
  ///
  /// In en, this message translates to:
  /// **'Android: update without going online'**
  String get signerUpgradeOfflineApkTitle;

  /// No description provided for @signerUpgradeOfflineApkBody.
  ///
  /// In en, this message translates to:
  /// **'You can also copy the new APK to this phone by USB cable or SD card and install it while staying offline. Use an APK from the same source you installed from, otherwise it won\'t install over this one.'**
  String get signerUpgradeOfflineApkBody;

  /// No description provided for @signerUpgradeCompatTitle.
  ///
  /// In en, this message translates to:
  /// **'Older signers keep working'**
  String get signerUpgradeCompatTitle;

  /// No description provided for @signerUpgradeCompatBody.
  ///
  /// In en, this message translates to:
  /// **'A newer wallet app still works with an older signer. The wallet only asks for what this signer supports, so you can update when it suits you.'**
  String get signerUpgradeCompatBody;

  /// No description provided for @signerVersionTitle.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get signerVersionTitle;

  /// No description provided for @signerVersionDetail.
  ///
  /// In en, this message translates to:
  /// **'App {app} · protocol {protocol} · token list {tokens}'**
  String signerVersionDetail(String app, int protocol, int tokens);

  /// No description provided for @signerEraseTitle.
  ///
  /// In en, this message translates to:
  /// **'Erase signer'**
  String get signerEraseTitle;

  /// No description provided for @signerEraseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Removes the recovery phrase from this phone'**
  String get signerEraseSubtitle;

  /// No description provided for @signerEraseBody.
  ///
  /// In en, this message translates to:
  /// **'The recovery phrase will be deleted from this phone. Without your paper backup the funds can\'t be recovered.'**
  String get signerEraseBody;

  /// No description provided for @signerEraseConfirm.
  ///
  /// In en, this message translates to:
  /// **'Erase'**
  String get signerEraseConfirm;

  /// No description provided for @signerEraseWrongPin.
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN. Nothing was erased.'**
  String get signerEraseWrongPin;

  /// No description provided for @airGapConnectTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect offline signer'**
  String get airGapConnectTitle;

  /// No description provided for @airGapConnectBody.
  ///
  /// In en, this message translates to:
  /// **'On your signer phone tap Connect wallet, then scan the code it shows.'**
  String get airGapConnectBody;

  /// No description provided for @airGapConnectInvalid.
  ///
  /// In en, this message translates to:
  /// **'This isn\'t a signer pairing code.'**
  String get airGapConnectInvalid;

  /// No description provided for @airGapConnectChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose an account on {device}'**
  String airGapConnectChoose(String device);

  /// No description provided for @airGapConnectAccount.
  ///
  /// In en, this message translates to:
  /// **'Account {number}'**
  String airGapConnectAccount(int number);

  /// No description provided for @airGapConnectAccountAdded.
  ///
  /// In en, this message translates to:
  /// **'Account {number} (already added)'**
  String airGapConnectAccountAdded(int number);

  /// No description provided for @airGapConnectCompare.
  ///
  /// In en, this message translates to:
  /// **'Check that the address matches the one shown on your signer.'**
  String get airGapConnectCompare;

  /// No description provided for @airGapConnectScanAgain.
  ///
  /// In en, this message translates to:
  /// **'Scan again'**
  String get airGapConnectScanAgain;

  /// No description provided for @airGapSignTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign with your signer'**
  String get airGapSignTitle;

  /// No description provided for @airGapSignShowRequestAgain.
  ///
  /// In en, this message translates to:
  /// **'Show the request again'**
  String get airGapSignShowRequestAgain;

  /// No description provided for @airGapSignMayHaveExpired.
  ///
  /// In en, this message translates to:
  /// **'This transaction may have expired. If sending fails, start again.'**
  String get airGapSignMayHaveExpired;

  /// No description provided for @airGapSignWrongRequest.
  ///
  /// In en, this message translates to:
  /// **'This signature belongs to a different request.'**
  String get airGapSignWrongRequest;

  /// No description provided for @airGapSignInvalidCode.
  ///
  /// In en, this message translates to:
  /// **'This isn\'t a signature from your signer.'**
  String get airGapSignInvalidCode;

  /// No description provided for @airGapSignerOutdated.
  ///
  /// In en, this message translates to:
  /// **'Your signer runs an older version. It still works; update it when convenient.'**
  String get airGapSignerOutdated;

  /// No description provided for @signerIntroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep your keys on a phone that never goes online.'**
  String get signerIntroSubtitle;

  /// No description provided for @signerFinishSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Give this signer a name and set a PIN.'**
  String get signerFinishSubtitle;

  /// No description provided for @signerQuizBody.
  ///
  /// In en, this message translates to:
  /// **'Pick the right word for {count} positions. Use your paper backup.'**
  String signerQuizBody(int count);

  /// No description provided for @signerQuizProgress.
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String signerQuizProgress(int current, int total);

  /// No description provided for @signerQuizQuestion.
  ///
  /// In en, this message translates to:
  /// **'Which is word #{position}?'**
  String signerQuizQuestion(int position);

  /// No description provided for @signerQuizCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get signerQuizCorrect;

  /// No description provided for @signerQuizWrong.
  ///
  /// In en, this message translates to:
  /// **'That\'s not right. Check your paper; we picked new words to try again.'**
  String get signerQuizWrong;

  /// No description provided for @signerQuizShowWords.
  ///
  /// In en, this message translates to:
  /// **'Show the words again'**
  String get signerQuizShowWords;

  /// No description provided for @signerScanToSignSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scan the request shown by your wallet'**
  String get signerScanToSignSubtitle;

  /// No description provided for @signerPairWalletSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show a code for Benny Wallet to scan'**
  String get signerPairWalletSubtitle;

  /// No description provided for @signerWalletPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Benny Wallet'**
  String get signerWalletPhoneLabel;

  /// No description provided for @signerScanRefusedTitle.
  ///
  /// In en, this message translates to:
  /// **'Can\'t sign this'**
  String get signerScanRefusedTitle;

  /// No description provided for @airGapSignerLabel.
  ///
  /// In en, this message translates to:
  /// **'Signer'**
  String get airGapSignerLabel;

  /// No description provided for @airGapThisPhone.
  ///
  /// In en, this message translates to:
  /// **'This phone'**
  String get airGapThisPhone;

  /// No description provided for @airGapConnectFound.
  ///
  /// In en, this message translates to:
  /// **'Signer recognized'**
  String get airGapConnectFound;

  /// No description provided for @airGapSignNeedsSigner.
  ///
  /// In en, this message translates to:
  /// **'This needs to be verified and signed by your signer'**
  String get airGapSignNeedsSigner;

  /// No description provided for @airGapSignStepShort1.
  ///
  /// In en, this message translates to:
  /// **'Signer scans'**
  String get airGapSignStepShort1;

  /// No description provided for @airGapSignStepShort2.
  ///
  /// In en, this message translates to:
  /// **'Scan signature'**
  String get airGapSignStepShort2;

  /// No description provided for @airGapSignStep1Named.
  ///
  /// In en, this message translates to:
  /// **'Step 1: scan this code with “{device}”'**
  String airGapSignStep1Named(String device);

  /// No description provided for @airGapSignStep1BodyNamed.
  ///
  /// In en, this message translates to:
  /// **'On “{device}”, tap Scan to sign, check the details, then confirm.'**
  String airGapSignStep1BodyNamed(String device);

  /// No description provided for @airGapSignStep2Named.
  ///
  /// In en, this message translates to:
  /// **'Step 2: scan the signature from “{device}”'**
  String airGapSignStep2Named(String device);

  /// No description provided for @airGapSignStep2BodyNamed.
  ///
  /// In en, this message translates to:
  /// **'After you confirm, “{device}” shows a signature code. Scan it with this phone.'**
  String airGapSignStep2BodyNamed(String device);

  /// No description provided for @airGapSignScanSignatureNamed.
  ///
  /// In en, this message translates to:
  /// **'Next: scan signature from {device}'**
  String airGapSignScanSignatureNamed(String device);

  /// No description provided for @signerActionSwapPair.
  ///
  /// In en, this message translates to:
  /// **'Swap {from} → {to}'**
  String signerActionSwapPair(String from, String to);

  /// No description provided for @signerSwapPay.
  ///
  /// In en, this message translates to:
  /// **'Pay {amount}'**
  String signerSwapPay(String amount);

  /// No description provided for @signerSwapPayAtMost.
  ///
  /// In en, this message translates to:
  /// **'Pay at most {amount}'**
  String signerSwapPayAtMost(String amount);

  /// No description provided for @signerSwapReceive.
  ///
  /// In en, this message translates to:
  /// **'Receive {amount}'**
  String signerSwapReceive(String amount);

  /// No description provided for @signerSwapReceiveAtLeast.
  ///
  /// In en, this message translates to:
  /// **'Receive at least {amount}'**
  String signerSwapReceiveAtLeast(String amount);

  /// No description provided for @signerSwapUnverifiedToken.
  ///
  /// In en, this message translates to:
  /// **'Unverified token'**
  String get signerSwapUnverifiedToken;

  /// No description provided for @airGapSignTimeLeft.
  ///
  /// In en, this message translates to:
  /// **'{seconds} s left. If time runs out, a fresh code appears automatically.'**
  String airGapSignTimeLeft(int seconds);

  /// No description provided for @airGapSignRefreshing.
  ///
  /// In en, this message translates to:
  /// **'Time is up. Getting a fresh quote and code…'**
  String get airGapSignRefreshing;

  /// No description provided for @airGapSignRefreshed.
  ///
  /// In en, this message translates to:
  /// **'The last code expired, so here is a new one. Scan it again with “{device}”.'**
  String airGapSignRefreshed(String device);

  /// No description provided for @airGapSignRefreshFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t get a fresh code. Check your connection and try again.'**
  String get airGapSignRefreshFailed;

  /// No description provided for @airGapSignOldRequest.
  ///
  /// In en, this message translates to:
  /// **'This signature is for the expired code. Scan the new code on your signer first.'**
  String get airGapSignOldRequest;

  /// No description provided for @scanHintRoleShows.
  ///
  /// In en, this message translates to:
  /// **'Shows code'**
  String get scanHintRoleShows;

  /// No description provided for @scanHintRoleScans.
  ///
  /// In en, this message translates to:
  /// **'Scans'**
  String get scanHintRoleScans;

  /// No description provided for @signerTokenUnchecked.
  ///
  /// In en, this message translates to:
  /// **'{symbol} (unverified)'**
  String signerTokenUnchecked(String symbol);

  /// No description provided for @signerReviewActions.
  ///
  /// In en, this message translates to:
  /// **'Transaction'**
  String get signerReviewActions;

  /// No description provided for @signerNewerWalletNotice.
  ///
  /// In en, this message translates to:
  /// **'Your wallet app is newer than this signer. Update the signer when you can.'**
  String get signerNewerWalletNotice;

  /// No description provided for @signerDangerBanner.
  ///
  /// In en, this message translates to:
  /// **'High risk. Don\'t sign unless you started this yourself.'**
  String get signerDangerBanner;

  /// No description provided for @signerActionSwap.
  ///
  /// In en, this message translates to:
  /// **'Swap'**
  String get signerActionSwap;

  /// No description provided for @signerActionSwapDetail.
  ///
  /// In en, this message translates to:
  /// **'Check the amounts in your wallet.'**
  String get signerActionSwapDetail;

  /// No description provided for @signerActionDangerDetail.
  ///
  /// In en, this message translates to:
  /// **'Dangerous. If you\'re not sure, don\'t sign.'**
  String get signerActionDangerDetail;

  /// No description provided for @signerActionAdvanceNonce.
  ///
  /// In en, this message translates to:
  /// **'Update transaction number'**
  String get signerActionAdvanceNonce;

  /// No description provided for @signerActionSyncNative.
  ///
  /// In en, this message translates to:
  /// **'Update SOL balance'**
  String get signerActionSyncNative;

  /// No description provided for @signerHoldLongHint.
  ///
  /// In en, this message translates to:
  /// **'Check carefully, then hold for 3 seconds.'**
  String get signerHoldLongHint;

  /// No description provided for @signerTokenVerified.
  ///
  /// In en, this message translates to:
  /// **'{token} · Verified by Benny Wallet'**
  String signerTokenVerified(String token);

  /// No description provided for @signerTokenWalletProvided.
  ///
  /// In en, this message translates to:
  /// **'{symbol} · Not verified by Benny Wallet'**
  String signerTokenWalletProvided(String symbol);

  /// No description provided for @signerSwapWalletQuote.
  ///
  /// In en, this message translates to:
  /// **'Estimate: pay {pay}, get about {receive}'**
  String signerSwapWalletQuote(String pay, String receive);

  /// No description provided for @signerActionUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unrecognized step'**
  String get signerActionUnknown;

  /// No description provided for @signerActionCreateTokenAccountFor.
  ///
  /// In en, this message translates to:
  /// **'Open {symbol} account'**
  String signerActionCreateTokenAccountFor(String symbol);

  /// No description provided for @signerUnresolvedAccounts.
  ///
  /// In en, this message translates to:
  /// **'The signer can\'t see all of this transaction. Only sign if you just started it.'**
  String get signerUnresolvedAccounts;

  /// No description provided for @signerTokenNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Not verified by Benny Wallet'**
  String get signerTokenNotVerified;

  /// No description provided for @signerKindSwap.
  ///
  /// In en, this message translates to:
  /// **'Swap'**
  String get signerKindSwap;

  /// No description provided for @signerKindSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get signerKindSend;

  /// No description provided for @signerAbout.
  ///
  /// In en, this message translates to:
  /// **'About {amount}'**
  String signerAbout(String amount);

  /// No description provided for @signerAmountsFromWallet.
  ///
  /// In en, this message translates to:
  /// **'Amounts come from the wallet'**
  String get signerAmountsFromWallet;

  /// No description provided for @signerTrustSafe.
  ///
  /// In en, this message translates to:
  /// **'All tokens verified by Benny Wallet'**
  String get signerTrustSafe;

  /// No description provided for @signerTrustCaution.
  ///
  /// In en, this message translates to:
  /// **'One token is not verified by Benny Wallet. Be careful.'**
  String get signerTrustCaution;

  /// No description provided for @signerTrustDangerSwap.
  ///
  /// In en, this message translates to:
  /// **'Neither token is verified by Benny Wallet. High risk.'**
  String get signerTrustDangerSwap;

  /// No description provided for @signerTrustDangerSend.
  ///
  /// In en, this message translates to:
  /// **'This token is not verified by Benny Wallet. High risk.'**
  String get signerTrustDangerSend;

  /// No description provided for @signerReviewOtherSteps.
  ///
  /// In en, this message translates to:
  /// **'Other steps'**
  String get signerReviewOtherSteps;

  /// No description provided for @signerPay.
  ///
  /// In en, this message translates to:
  /// **'You pay'**
  String get signerPay;

  /// No description provided for @signerPayAtMost.
  ///
  /// In en, this message translates to:
  /// **'You pay at most'**
  String get signerPayAtMost;

  /// No description provided for @signerGet.
  ///
  /// In en, this message translates to:
  /// **'You get'**
  String get signerGet;

  /// No description provided for @signerGetAtLeast.
  ///
  /// In en, this message translates to:
  /// **'You get at least'**
  String get signerGetAtLeast;

  /// No description provided for @signerGetAbout.
  ///
  /// In en, this message translates to:
  /// **'You get about'**
  String get signerGetAbout;

  /// No description provided for @signerRecipient.
  ///
  /// In en, this message translates to:
  /// **'Recipient'**
  String get signerRecipient;

  /// No description provided for @signerRecipientTokenAccount.
  ///
  /// In en, this message translates to:
  /// **'Recipient token account'**
  String get signerRecipientTokenAccount;

  /// No description provided for @signerUsdFromWallet.
  ///
  /// In en, this message translates to:
  /// **'USD values are the wallet\'s estimate'**
  String get signerUsdFromWallet;

  /// No description provided for @signerActionCreateTokenAccountForRecipient.
  ///
  /// In en, this message translates to:
  /// **'Open {symbol} account for the recipient'**
  String signerActionCreateTokenAccountForRecipient(String symbol);

  /// No description provided for @signerCreateAccountSkipIfOpen.
  ///
  /// In en, this message translates to:
  /// **'(First time costs about 0.002 SOL; skipped for free if already open)'**
  String get signerCreateAccountSkipIfOpen;

  /// No description provided for @signerCreateAccountNotOpen.
  ///
  /// In en, this message translates to:
  /// **'(Not open yet; costs about 0.002 SOL)'**
  String get signerCreateAccountNotOpen;

  /// No description provided for @signerAddressFromWallet.
  ///
  /// In en, this message translates to:
  /// **'This address comes from the wallet. The signer can\'t check it.'**
  String get signerAddressFromWallet;

  /// No description provided for @signerSwapOutputUnchecked.
  ///
  /// In en, this message translates to:
  /// **'Can\'t confirm the swapped tokens come to you.'**
  String get signerSwapOutputUnchecked;

  /// No description provided for @signerExtraOutflow.
  ///
  /// In en, this message translates to:
  /// **'This also sends funds to another address.'**
  String get signerExtraOutflow;

  /// No description provided for @signerHighFee.
  ///
  /// In en, this message translates to:
  /// **'Very high network fee: {amount} SOL'**
  String signerHighFee(String amount);

  /// No description provided for @signerDurableNonce.
  ///
  /// In en, this message translates to:
  /// **'This signature never expires. It can be used later.'**
  String get signerDurableNonce;

  /// No description provided for @signerSwapFromWallet.
  ///
  /// In en, this message translates to:
  /// **'Token or amount comes from the wallet and can\'t be checked.'**
  String get signerSwapFromWallet;

  /// No description provided for @signerActionCloseTo.
  ///
  /// In en, this message translates to:
  /// **'Balance and rent go to {address}'**
  String signerActionCloseTo(String address);

  /// No description provided for @signerWalletNote.
  ///
  /// In en, this message translates to:
  /// **'Wallet note: {name}'**
  String signerWalletNote(String name);

  /// No description provided for @signerReviewFeePayer.
  ///
  /// In en, this message translates to:
  /// **'Fee paid by'**
  String get signerReviewFeePayer;

  /// No description provided for @signerActionOwnerProgram.
  ///
  /// In en, this message translates to:
  /// **'Controlled by program {program}'**
  String signerActionOwnerProgram(String program);

  /// No description provided for @signerSlippageAll.
  ///
  /// In en, this message translates to:
  /// **'Slippage 100% or more: you may get nothing.'**
  String get signerSlippageAll;

  /// No description provided for @signerQuizTooManyWrong.
  ///
  /// In en, this message translates to:
  /// **'Too many wrong answers. Enter your PIN to try again.'**
  String get signerQuizTooManyWrong;

  /// No description provided for @signerSignInTitle.
  ///
  /// In en, this message translates to:
  /// **'Login request'**
  String get signerSignInTitle;

  /// No description provided for @signerKindSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signerKindSignIn;

  /// No description provided for @signerSignInBenny.
  ///
  /// In en, this message translates to:
  /// **'Sign in to Benny Wallet'**
  String get signerSignInBenny;

  /// No description provided for @signerSignInOtherSite.
  ///
  /// In en, this message translates to:
  /// **'“{site}” asks you to sign in. Sign only if you started it.'**
  String signerSignInOtherSite(String site);

  /// No description provided for @signerSignInExpired.
  ///
  /// In en, this message translates to:
  /// **'This login request has expired. Check this phone\'s time, or start again in the wallet.'**
  String get signerSignInExpired;

  /// No description provided for @signerSignInOtherAccount.
  ///
  /// In en, this message translates to:
  /// **'This login is for another account. Don\'t sign.'**
  String get signerSignInOtherAccount;

  /// No description provided for @signerSignInWhat.
  ///
  /// In en, this message translates to:
  /// **'Proves this account is yours, so Benny can show its balance, history and alerts.'**
  String get signerSignInWhat;

  /// No description provided for @signerSignInNoFunds.
  ///
  /// In en, this message translates to:
  /// **'Moves no funds and costs no fee.'**
  String get signerSignInNoFunds;

  /// No description provided for @signerSignInShowText.
  ///
  /// In en, this message translates to:
  /// **'Show original text'**
  String get signerSignInShowText;

  /// No description provided for @airGapSignInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your signer'**
  String get airGapSignInTitle;

  /// No description provided for @airGapSignInWhy.
  ///
  /// In en, this message translates to:
  /// **'Why sign this?'**
  String get airGapSignInWhy;

  /// No description provided for @airGapSignInWhyBody.
  ///
  /// In en, this message translates to:
  /// **'Benny needs to confirm this account is yours before it can load your balance, history and alerts. Usually you do this only once per wallet.'**
  String get airGapSignInWhyBody;

  /// No description provided for @airGapSignInSafe.
  ///
  /// In en, this message translates to:
  /// **'This is only a login. It moves no funds and costs no fee.'**
  String get airGapSignInSafe;

  /// No description provided for @airGapSignInSignerShows.
  ///
  /// In en, this message translates to:
  /// **'“{device}” will show “Sign in to Benny Wallet”.'**
  String airGapSignInSignerShows(String device);

  /// No description provided for @airGapSignInSignerShowsText.
  ///
  /// In en, this message translates to:
  /// **'“{device}” will show English text starting with “Benny Wallet wants you to sign in”. That is this login. After updating the signer it shows “Sign in to Benny Wallet” instead.'**
  String airGapSignInSignerShowsText(String device);

  /// No description provided for @dappScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect a website'**
  String get dappScanTitle;

  /// No description provided for @dappScanHint.
  ///
  /// In en, this message translates to:
  /// **'Scan the WalletConnect QR code shown on the website'**
  String get dappScanHint;

  /// No description provided for @dappPasteLink.
  ///
  /// In en, this message translates to:
  /// **'Paste link'**
  String get dappPasteLink;

  /// No description provided for @dappScanNotWalletConnect.
  ///
  /// In en, this message translates to:
  /// **'This is not a WalletConnect code'**
  String get dappScanNotWalletConnect;

  /// No description provided for @dappConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get dappConnecting;

  /// No description provided for @dappPairFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not connect. Ask the website for a new QR code.'**
  String get dappPairFailed;

  /// No description provided for @dappNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Website connections are not available in this build.'**
  String get dappNotConfigured;

  /// No description provided for @dappProposalTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect to website'**
  String get dappProposalTitle;

  /// No description provided for @dappProposalWants.
  ///
  /// In en, this message translates to:
  /// **'{site} wants to connect to your wallet'**
  String dappProposalWants(String site);

  /// No description provided for @dappProposalCanDo.
  ///
  /// In en, this message translates to:
  /// **'The website will be able to:'**
  String get dappProposalCanDo;

  /// No description provided for @dappProposalSeeAddress.
  ///
  /// In en, this message translates to:
  /// **'See your wallet address'**
  String get dappProposalSeeAddress;

  /// No description provided for @dappProposalRequestSign.
  ///
  /// In en, this message translates to:
  /// **'Ask you to approve transactions and messages'**
  String get dappProposalRequestSign;

  /// No description provided for @dappProposalNoAutoFunds.
  ///
  /// In en, this message translates to:
  /// **'It cannot move funds on its own. Every request needs your approval.'**
  String get dappProposalNoAutoFunds;

  /// No description provided for @dappProposalWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get dappProposalWallet;

  /// No description provided for @dappProposalNoEligibleWallet.
  ///
  /// In en, this message translates to:
  /// **'None of your wallets can connect to websites yet. External wallets will be supported later.'**
  String get dappProposalNoEligibleWallet;

  /// No description provided for @dappProposalOnlySolana.
  ///
  /// In en, this message translates to:
  /// **'Benny Wallet only supports Solana. This website asked for other networks.'**
  String get dappProposalOnlySolana;

  /// No description provided for @dappProposalUnsupportedChain.
  ///
  /// In en, this message translates to:
  /// **'This website asked for a Solana test network. Benny Wallet only supports Solana mainnet.'**
  String get dappProposalUnsupportedChain;

  /// No description provided for @dappConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get dappConnect;

  /// No description provided for @dappReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get dappReject;

  /// No description provided for @dappConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected to {site}'**
  String dappConnected(String site);

  /// No description provided for @dappSiteVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get dappSiteVerified;

  /// No description provided for @dappSiteUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unverified'**
  String get dappSiteUnknown;

  /// No description provided for @dappSiteMismatch.
  ///
  /// In en, this message translates to:
  /// **'Domain mismatch'**
  String get dappSiteMismatch;

  /// No description provided for @dappSiteScam.
  ///
  /// In en, this message translates to:
  /// **'Known scam'**
  String get dappSiteScam;

  /// No description provided for @dappSitesTitle.
  ///
  /// In en, this message translates to:
  /// **'Connected websites'**
  String get dappSitesTitle;

  /// No description provided for @dappSitesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No websites connected. Scan a WalletConnect QR code on a website to connect.'**
  String get dappSitesEmpty;

  /// No description provided for @dappSitesDisconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get dappSitesDisconnect;

  /// No description provided for @dappSitesDisconnectAll.
  ///
  /// In en, this message translates to:
  /// **'Disconnect all'**
  String get dappSitesDisconnectAll;

  /// No description provided for @dappSitesDisconnectAllConfirm.
  ///
  /// In en, this message translates to:
  /// **'Disconnect every website from all wallets?'**
  String get dappSitesDisconnectAllConfirm;

  /// No description provided for @dappSitesExpires.
  ///
  /// In en, this message translates to:
  /// **'Expires {date}'**
  String dappSitesExpires(String date);

  /// No description provided for @dappSitesWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet: {name}'**
  String dappSitesWallet(String name);

  /// No description provided for @dappSitesBanner.
  ///
  /// In en, this message translates to:
  /// **'Connected websites: {count}'**
  String dappSitesBanner(int count);

  /// No description provided for @dappRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Signature request'**
  String get dappRequestTitle;

  /// No description provided for @dappRequestSignMessage.
  ///
  /// In en, this message translates to:
  /// **'Sign a message'**
  String get dappRequestSignMessage;

  /// No description provided for @dappRequestSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in to {domain}'**
  String dappRequestSignIn(String domain);

  /// No description provided for @dappRequestTransaction.
  ///
  /// In en, this message translates to:
  /// **'Approve transaction'**
  String get dappRequestTransaction;

  /// No description provided for @dappRequestTransactions.
  ///
  /// In en, this message translates to:
  /// **'Approve {count} transactions'**
  String dappRequestTransactions(int count);

  /// No description provided for @dappRequestSendNote.
  ///
  /// In en, this message translates to:
  /// **'Benny Wallet sends it after you sign.'**
  String get dappRequestSendNote;

  /// No description provided for @dappRequestBalanceChanges.
  ///
  /// In en, this message translates to:
  /// **'Estimated balance changes'**
  String get dappRequestBalanceChanges;

  /// No description provided for @dappRequestNoBalanceChange.
  ///
  /// In en, this message translates to:
  /// **'No balance change for this wallet besides the network fee'**
  String get dappRequestNoBalanceChange;

  /// No description provided for @dappRequestNetworkFee.
  ///
  /// In en, this message translates to:
  /// **'Network fee'**
  String get dappRequestNetworkFee;

  /// No description provided for @dappRequestMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get dappRequestMessage;

  /// No description provided for @dappRequestDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get dappRequestDetails;

  /// No description provided for @dappRequestPrograms.
  ///
  /// In en, this message translates to:
  /// **'Programs called'**
  String get dappRequestPrograms;

  /// No description provided for @dappActionTitle.
  ///
  /// In en, this message translates to:
  /// **'What this does'**
  String get dappActionTitle;

  /// No description provided for @browserTitle.
  ///
  /// In en, this message translates to:
  /// **'Browser'**
  String get browserTitle;

  /// No description provided for @browserAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Enter an address, e.g. jup.ag'**
  String get browserAddressHint;

  /// No description provided for @browserReload.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get browserReload;

  /// No description provided for @browserHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get browserHome;

  /// No description provided for @browserHomeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a website address. On the site, tap Connect wallet and choose Benny Wallet: no switching apps, no unlocking again.'**
  String get browserHomeHint;

  /// No description provided for @browserNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get browserNotConnected;

  /// No description provided for @browserConnectedAs.
  ///
  /// In en, this message translates to:
  /// **'Connected: {wallet}'**
  String browserConnectedAs(String wallet);

  /// No description provided for @browserInvalidUrl.
  ///
  /// In en, this message translates to:
  /// **'Not a web address'**
  String get browserInvalidUrl;

  /// No description provided for @browserOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get browserOpen;

  /// No description provided for @browserBookmarks.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get browserBookmarks;

  /// No description provided for @browserBookmark.
  ///
  /// In en, this message translates to:
  /// **'Bookmark'**
  String get browserBookmark;

  /// No description provided for @browserBookmarked.
  ///
  /// In en, this message translates to:
  /// **'Bookmarked'**
  String get browserBookmarked;

  /// No description provided for @browserBookmarkRemoved.
  ///
  /// In en, this message translates to:
  /// **'Bookmark removed'**
  String get browserBookmarkRemoved;

  /// No description provided for @browserBookmarkRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get browserBookmarkRemove;

  /// No description provided for @browserBookmarksEmpty.
  ///
  /// In en, this message translates to:
  /// **'Open a page and tap the star in the address bar to save it. Bookmarks stay on this phone and are never synced.'**
  String get browserBookmarksEmpty;

  /// No description provided for @browserBookmarksLocal.
  ///
  /// In en, this message translates to:
  /// **'Saved only on this phone, never synced.'**
  String get browserBookmarksLocal;

  /// No description provided for @browserBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get browserBack;

  /// No description provided for @browserForward.
  ///
  /// In en, this message translates to:
  /// **'Forward'**
  String get browserForward;

  /// No description provided for @browserCopyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get browserCopyLink;

  /// No description provided for @browserHomeTagline.
  ///
  /// In en, this message translates to:
  /// **'Your gateway to Solana apps'**
  String get browserHomeTagline;

  /// No description provided for @browserBennyFeatures.
  ///
  /// In en, this message translates to:
  /// **'Benny Apps'**
  String get browserBennyFeatures;

  /// No description provided for @browserComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get browserComingSoon;

  /// No description provided for @browserPopular.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get browserPopular;

  /// No description provided for @browserYourSites.
  ///
  /// In en, this message translates to:
  /// **'Connected sites'**
  String get browserYourSites;

  /// No description provided for @dappColdSwapNotice.
  ///
  /// In en, this message translates to:
  /// **'This swap expires within about a minute and a cold wallet often cannot sign it in time. For swaps with a cold wallet, use Benny\'s built-in Swap: it refreshes the quote when it expires.'**
  String get dappColdSwapNotice;

  /// No description provided for @dappActionSwap.
  ///
  /// In en, this message translates to:
  /// **'Swap'**
  String get dappActionSwap;

  /// No description provided for @dappActionTransfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get dappActionTransfer;

  /// No description provided for @dappActionStake.
  ///
  /// In en, this message translates to:
  /// **'Stake'**
  String get dappActionStake;

  /// No description provided for @dappActionLend.
  ///
  /// In en, this message translates to:
  /// **'Lend or borrow'**
  String get dappActionLend;

  /// No description provided for @dappActionPerps.
  ///
  /// In en, this message translates to:
  /// **'Futures trade'**
  String get dappActionPerps;

  /// No description provided for @dappActionNft.
  ///
  /// In en, this message translates to:
  /// **'NFT trade'**
  String get dappActionNft;

  /// No description provided for @dappActionOther.
  ///
  /// In en, this message translates to:
  /// **'Other action'**
  String get dappActionOther;

  /// No description provided for @dappActionVia.
  ///
  /// In en, this message translates to:
  /// **'via {protocol}'**
  String dappActionVia(String protocol);

  /// No description provided for @dappActionPay.
  ///
  /// In en, this message translates to:
  /// **'You pay'**
  String get dappActionPay;

  /// No description provided for @dappActionReceive.
  ///
  /// In en, this message translates to:
  /// **'You receive'**
  String get dappActionReceive;

  /// No description provided for @dappActionUnknownHint.
  ///
  /// In en, this message translates to:
  /// **'Benny cannot read what these programs do. Sign only if you just started this on the website yourself.'**
  String get dappActionUnknownHint;

  /// No description provided for @dappActionUnknownPrograms.
  ///
  /// In en, this message translates to:
  /// **'Unknown programs ({count})'**
  String dappActionUnknownPrograms(int count);

  /// No description provided for @dappActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'Connection history'**
  String get dappActivityTitle;

  /// No description provided for @dappActivityNote.
  ///
  /// In en, this message translates to:
  /// **'Saved only on this phone. Never uploaded to the cloud or backed up. Records the website, the action and amounts only, not message contents or your personal details.'**
  String get dappActivityNote;

  /// No description provided for @dappActivityEmpty.
  ///
  /// In en, this message translates to:
  /// **'No website activity yet.'**
  String get dappActivityEmpty;

  /// No description provided for @dappActivityClear.
  ///
  /// In en, this message translates to:
  /// **'Clear activity'**
  String get dappActivityClear;

  /// No description provided for @dappActivityClearConfirm.
  ///
  /// In en, this message translates to:
  /// **'Clear all website activity on this phone?'**
  String get dappActivityClearConfirm;

  /// No description provided for @dappActivityCount.
  ///
  /// In en, this message translates to:
  /// **'{count} records'**
  String dappActivityCount(int count);

  /// No description provided for @dappActivityConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get dappActivityConnected;

  /// No description provided for @dappActivityConnectRejected.
  ///
  /// In en, this message translates to:
  /// **'Connection declined'**
  String get dappActivityConnectRejected;

  /// No description provided for @dappActivityMessage.
  ///
  /// In en, this message translates to:
  /// **'Message signature'**
  String get dappActivityMessage;

  /// No description provided for @dappActivitySigned.
  ///
  /// In en, this message translates to:
  /// **'Signed'**
  String get dappActivitySigned;

  /// No description provided for @dappActivitySent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get dappActivitySent;

  /// No description provided for @dappActivityRejected.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get dappActivityRejected;

  /// No description provided for @dappActivityFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get dappActivityFailed;

  /// No description provided for @dappActivityViewTx.
  ///
  /// In en, this message translates to:
  /// **'View on Solscan'**
  String get dappActivityViewTx;

  /// No description provided for @dappActivityViaPhone.
  ///
  /// In en, this message translates to:
  /// **'App on this phone'**
  String get dappActivityViaPhone;

  /// No description provided for @dappActivityInBrowser.
  ///
  /// In en, this message translates to:
  /// **'Benny\'s browser'**
  String get dappActivityInBrowser;

  /// No description provided for @dappActivityWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet {wallet}'**
  String dappActivityWallet(String wallet);

  /// No description provided for @dappActivityDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get dappActivityDisconnected;

  /// No description provided for @dappSitesLastUsed.
  ///
  /// In en, this message translates to:
  /// **'Last used {date}'**
  String dappSitesLastUsed(String date);

  /// No description provided for @dappActivityDetail.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get dappActivityDetail;

  /// No description provided for @dappActivitySite.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get dappActivitySite;

  /// No description provided for @dappActivityTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get dappActivityTime;

  /// No description provided for @dappActivityVia.
  ///
  /// In en, this message translates to:
  /// **'Connected through'**
  String get dappActivityVia;

  /// No description provided for @dappActivityViaWalletConnect.
  ///
  /// In en, this message translates to:
  /// **'Scanned QR code (WalletConnect)'**
  String get dappActivityViaWalletConnect;

  /// No description provided for @dappActivityWalletLabel.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get dappActivityWalletLabel;

  /// No description provided for @dappActivityTxId.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get dappActivityTxId;

  /// No description provided for @dappActivityCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get dappActivityCopied;

  /// No description provided for @dappActivityResult.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get dappActivityResult;

  /// No description provided for @dappRequestSigningWallet.
  ///
  /// In en, this message translates to:
  /// **'Signing wallet'**
  String get dappRequestSigningWallet;

  /// No description provided for @dappRequestLoading.
  ///
  /// In en, this message translates to:
  /// **'Checking request…'**
  String get dappRequestLoading;

  /// No description provided for @dappRequestInvalid.
  ///
  /// In en, this message translates to:
  /// **'This request could not be read and was rejected.'**
  String get dappRequestInvalid;

  /// No description provided for @dappRequestSign.
  ///
  /// In en, this message translates to:
  /// **'Sign'**
  String get dappRequestSign;

  /// No description provided for @dappRequestHoldToSign.
  ///
  /// In en, this message translates to:
  /// **'Hold to sign'**
  String get dappRequestHoldToSign;

  /// No description provided for @dappRequestAcceptRisk.
  ///
  /// In en, this message translates to:
  /// **'I understand the risk and still want to sign'**
  String get dappRequestAcceptRisk;

  /// No description provided for @dappRequestBlocked.
  ///
  /// In en, this message translates to:
  /// **'Benny Wallet blocked this request to protect your funds.'**
  String get dappRequestBlocked;

  /// No description provided for @dappRequestDone.
  ///
  /// In en, this message translates to:
  /// **'Signed. Go back to the website.'**
  String get dappRequestDone;

  /// No description provided for @dappRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Sent. Go back to the website.'**
  String get dappRequestSent;

  /// No description provided for @dappRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Signing failed: {error}'**
  String dappRequestFailed(String error);

  /// No description provided for @dappRequestRejected.
  ///
  /// In en, this message translates to:
  /// **'Request rejected'**
  String get dappRequestRejected;

  /// No description provided for @dappAuthReason.
  ///
  /// In en, this message translates to:
  /// **'Confirm the signature'**
  String get dappAuthReason;

  /// No description provided for @dappPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN to sign'**
  String get dappPinTitle;

  /// No description provided for @dappTrustSafe.
  ///
  /// In en, this message translates to:
  /// **'Looks normal'**
  String get dappTrustSafe;

  /// No description provided for @dappTrustCaution.
  ///
  /// In en, this message translates to:
  /// **'Check carefully'**
  String get dappTrustCaution;

  /// No description provided for @dappTrustDanger.
  ///
  /// In en, this message translates to:
  /// **'High risk'**
  String get dappTrustDanger;

  /// No description provided for @dappTrustBlocked.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get dappTrustBlocked;

  /// No description provided for @dappWarnSiteScam.
  ///
  /// In en, this message translates to:
  /// **'This website is a known scam.'**
  String get dappWarnSiteScam;

  /// No description provided for @dappWarnSiteMismatch.
  ///
  /// In en, this message translates to:
  /// **'The website\'s address does not match the app it claims to be.'**
  String get dappWarnSiteMismatch;

  /// No description provided for @dappWarnSiteUnknown.
  ///
  /// In en, this message translates to:
  /// **'This website could not be verified.'**
  String get dappWarnSiteUnknown;

  /// No description provided for @dappWarnMessageUnreadable.
  ///
  /// In en, this message translates to:
  /// **'The message is not readable text, so you cannot tell what you are signing.'**
  String get dappWarnMessageUnreadable;

  /// No description provided for @dappWarnMessageIsTransaction.
  ///
  /// In en, this message translates to:
  /// **'This message is really a transaction. Signing it could move your funds.'**
  String get dappWarnMessageIsTransaction;

  /// No description provided for @dappWarnSignInOtherSite.
  ///
  /// In en, this message translates to:
  /// **'The sign-in is for a different website than the one asking.'**
  String get dappWarnSignInOtherSite;

  /// No description provided for @dappWarnSignInOtherAccount.
  ///
  /// In en, this message translates to:
  /// **'The sign-in is for a different wallet.'**
  String get dappWarnSignInOtherAccount;

  /// No description provided for @dappWarnSignInExpired.
  ///
  /// In en, this message translates to:
  /// **'This sign-in request has expired.'**
  String get dappWarnSignInExpired;

  /// No description provided for @dappWarnTokenApprove.
  ///
  /// In en, this message translates to:
  /// **'Gives another account permission to spend your tokens.'**
  String get dappWarnTokenApprove;

  /// No description provided for @dappWarnSetAuthority.
  ///
  /// In en, this message translates to:
  /// **'Hands control of one of your accounts to someone else.'**
  String get dappWarnSetAuthority;

  /// No description provided for @dappWarnAssignAccount.
  ///
  /// In en, this message translates to:
  /// **'Changes the owner of your wallet account.'**
  String get dappWarnAssignAccount;

  /// No description provided for @dappWarnCloseAccount.
  ///
  /// In en, this message translates to:
  /// **'Closes a token account.'**
  String get dappWarnCloseAccount;

  /// No description provided for @dappWarnAdvanceNonce.
  ///
  /// In en, this message translates to:
  /// **'Uses a durable nonce, so the signature stays valid until it is used.'**
  String get dappWarnAdvanceNonce;

  /// No description provided for @dappWarnUnknownProgram.
  ///
  /// In en, this message translates to:
  /// **'Calls a program Benny Wallet does not recognise.'**
  String get dappWarnUnknownProgram;

  /// No description provided for @dappWarnBlockedProgram.
  ///
  /// In en, this message translates to:
  /// **'Calls a program on Benny Wallet\'s blocklist. It cannot be signed.'**
  String get dappWarnBlockedProgram;

  /// No description provided for @dappWarnUnresolvedAccounts.
  ///
  /// In en, this message translates to:
  /// **'Some accounts could not be looked up.'**
  String get dappWarnUnresolvedAccounts;

  /// No description provided for @dappWarnSimulationFailed.
  ///
  /// In en, this message translates to:
  /// **'The transaction fails in simulation.'**
  String get dappWarnSimulationFailed;

  /// No description provided for @dappWarnSimulationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The balance changes could not be estimated.'**
  String get dappWarnSimulationUnavailable;

  /// No description provided for @dappWarnHighSlippage.
  ///
  /// In en, this message translates to:
  /// **'Allows a swap that could return nothing.'**
  String get dappWarnHighSlippage;

  /// No description provided for @dappRequestQueued.
  ///
  /// In en, this message translates to:
  /// **'{count} more requests waiting'**
  String dappRequestQueued(int count);

  /// No description provided for @airGapSignFromSite.
  ///
  /// In en, this message translates to:
  /// **'This request comes from the website {site}. The signer shows the site too.'**
  String airGapSignFromSite(String site);

  /// No description provided for @airGapSignFromSiteStep.
  ///
  /// In en, this message translates to:
  /// **'From the website {site}: transaction {current} of {total}'**
  String airGapSignFromSiteStep(String site, int current, int total);

  /// No description provided for @airGapSignerNoSiteSupport.
  ///
  /// In en, this message translates to:
  /// **'Your signer is an older version and cannot show which website this came from. Update the signer when you can.'**
  String get airGapSignerNoSiteSupport;

  /// No description provided for @signerDappSource.
  ///
  /// In en, this message translates to:
  /// **'From the website {site} (passed on by the wallet)'**
  String signerDappSource(String site);

  /// No description provided for @signerDappSiteVerified.
  ///
  /// In en, this message translates to:
  /// **'The wallet verified this website.'**
  String get signerDappSiteVerified;

  /// No description provided for @signerDappSiteUnverified.
  ///
  /// In en, this message translates to:
  /// **'The wallet could not verify this website.'**
  String get signerDappSiteUnverified;

  /// No description provided for @signerDappSiteMismatch.
  ///
  /// In en, this message translates to:
  /// **'The website\'s address does not match what it claims to be. It may be a fake site.'**
  String get signerDappSiteMismatch;

  /// No description provided for @signerDappSiteScam.
  ///
  /// In en, this message translates to:
  /// **'This is a known scam website. Do not sign.'**
  String get signerDappSiteScam;

  /// No description provided for @signerDappSourceHint.
  ///
  /// In en, this message translates to:
  /// **'Only sign if you just did this on that website yourself.'**
  String get signerDappSourceHint;

  /// No description provided for @signerDappUnknownStep.
  ///
  /// In en, this message translates to:
  /// **'The signer cannot read this step (program {program}). Only sign if you just did this on the website yourself.'**
  String signerDappUnknownStep(String program);

  /// No description provided for @signerDappSimulation.
  ///
  /// In en, this message translates to:
  /// **'Balance changes simulated by the wallet'**
  String get signerDappSimulation;

  /// No description provided for @signerDappSimulationNone.
  ///
  /// In en, this message translates to:
  /// **'No balance change besides the network fee'**
  String get signerDappSimulationNone;

  /// No description provided for @signerDappSimulationNote.
  ///
  /// In en, this message translates to:
  /// **'Simulated by the wallet. The signer cannot check this; use it only as a reference.'**
  String get signerDappSimulationNote;

  /// No description provided for @airGapSignSiteTimeLeft.
  ///
  /// In en, this message translates to:
  /// **'The website waits {time} more'**
  String airGapSignSiteTimeLeft(String time);

  /// No description provided for @airGapSignSiteExpired.
  ///
  /// In en, this message translates to:
  /// **'The website\'s request has probably expired. Close this and start again on the website.'**
  String get airGapSignSiteExpired;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'en',
    'es',
    'ja',
    'ko',
    'ru',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
