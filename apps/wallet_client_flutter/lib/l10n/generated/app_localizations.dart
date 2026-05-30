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
