// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Benny Wallet';

  @override
  String get brandShortName => 'Benny';

  @override
  String get commonBack => 'Back';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonClose => 'Close';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonCopied => 'Copied';

  @override
  String get commonCopy => 'Copy';

  @override
  String get commonDone => 'Done';

  @override
  String get commonLater => 'Later';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonMax => 'MAX';

  @override
  String get commonNext => 'Next';

  @override
  String get commonOk => 'OK';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonSettings => 'Settings';

  @override
  String get commonShare => 'Share';

  @override
  String get commonUpdate => 'Update';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageTraditionalChinese => 'Traditional Chinese';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get languageJapanese => 'Japanese';

  @override
  String get languageRussian => 'Russian';

  @override
  String get languageKorean => 'Korean';

  @override
  String get settingsTitle => 'Benny';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSubtitle => 'Choose the app language';

  @override
  String get settingsLanguageSystemDescription => 'Follow this device';

  @override
  String get settingsLanguageSheetTitle => 'Language';

  @override
  String get settingsLanguageSheetSubtitle =>
      'Choose the language used in Benny.';

  @override
  String get settingsBiometricUnlock => 'Biometric unlock';

  @override
  String get settingsUseFingerprint => 'Use fingerprint';

  @override
  String get settingsUnlockWalletToEnable => 'Unlock wallet to enable';

  @override
  String get settingsAutoLock => 'Auto lock';

  @override
  String get settingsAutoLockSheetSubtitle => 'Choose when Benny locks again.';

  @override
  String get settingsNotifications => 'Receive notifications';

  @override
  String get settingsNotificationsSubtitle => 'Get an alert when funds arrive';

  @override
  String get settingsChildMode => 'Child mode';

  @override
  String get settingsChildModeActive => 'Child mode is active';

  @override
  String get settingsChildModeActiveDescription =>
      'The wallet stays in receive-only mode until the 4-digit child mode PIN is entered.';

  @override
  String get settingsChildModeProtected =>
      'Protected by a 4-digit child mode PIN';

  @override
  String get settingsChildModeRemoveAccounts =>
      'Remove all child accounts before enabling';

  @override
  String get settingsChildModeSetPin =>
      'Set a separate 4-digit PIN for child mode';

  @override
  String get settingsChildAccounts => 'Child accounts';

  @override
  String get settingsRentReclaim => 'Rent reclaim';

  @override
  String get settingsRentReclaimSubtitle =>
      'Close empty token accounts and recover SOL';

  @override
  String get settingsFeedback => 'Feedback';

  @override
  String get settingsFeedbackSubtitle => 'Report a problem or ask a question';

  @override
  String get settingsLogOut => 'Log out';

  @override
  String get settingsLogOutSubtitle => 'Return to the home screen';

  @override
  String get settingsIncorrectPin => 'Incorrect PIN';

  @override
  String get settingsPersistentBiometricUnsupported =>
      'Persistent biometric unlock is not supported on this device.';

  @override
  String get settingsBiometricsUnavailable =>
      'Biometrics are not available on this device.';

  @override
  String get settingsBiometricEnabled => 'Biometric enabled';

  @override
  String get settingsBiometricDisabled => 'Biometric disabled';

  @override
  String get settingsUnlockBeforeBiometrics =>
      'Unlock the wallet before enabling biometrics.';

  @override
  String get settingsNotificationsSystemDisabled =>
      'Notifications are disabled. Enable them in system settings.';

  @override
  String get settingsNotificationsEnabled => 'Receive notifications enabled';

  @override
  String get settingsNotificationsDisabled => 'Receive notifications disabled';

  @override
  String settingsNotificationsUpdateFailed(String error) {
    return 'Failed to update notifications: $error';
  }

  @override
  String get settingsRemoveChildAccountsFirst =>
      'Remove all child accounts before enabling child mode.';

  @override
  String get settingsChildModeEnabled => 'Child mode enabled';

  @override
  String get settingsChildModeDisabled => 'Child mode disabled';

  @override
  String settingsChildModeUpdateFailed(String error) {
    return 'Failed to update child mode: $error';
  }

  @override
  String get settingsCopyRecoveryPhraseFirst =>
      'Copy your recovery phrase first.';

  @override
  String get settingsLogOutWarning =>
      'Logging out will clear all local app data on this device.';

  @override
  String get settingsWalletUpToDate => 'Benny Wallet is up to date.';

  @override
  String get settingsUpdateCheckFailed => 'Update Check Failed';

  @override
  String get settingsUnableToCheckUpdates =>
      'Unable to check for updates right now.';

  @override
  String get settingsSeedPhraseBackup => 'Seed Phrase Backup';

  @override
  String get settingsSeedPhraseBackupDescription =>
      'We recommend a physical copy stored in a secure spot.';

  @override
  String get settingsSecureNow => 'Secure Now';

  @override
  String get settingsCheckingUpdates => 'Checking...';

  @override
  String get settingsFullFeaturesUnlocked => 'Full features unlocked';

  @override
  String get settingsCheckForUpdates => 'Check for updates';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String settingsVersionBuild(String version, String buildNumber) {
    return 'Version $version+$buildNumber';
  }

  @override
  String get autoLockImmediate => 'Immediately';

  @override
  String get autoLockOneMinute => '1 minute';

  @override
  String get autoLockFiveMinutes => '5 minutes';

  @override
  String get autoLockTenMinutes => '10 minutes';

  @override
  String get autoLockThirtyMinutes => '30 minutes';

  @override
  String get biometricUnlockReason =>
      'Use biometrics to unlock your Benny Wallet.';

  @override
  String get biometricSetupReason =>
      'Verify with biometrics to enable this security feature.';

  @override
  String get unlockFailedTitle => 'Unlock Failed';

  @override
  String get unlockIncorrectPin => 'Incorrect PIN.';

  @override
  String get unlockBiometricCancelled => 'Biometric cancelled';

  @override
  String get unlockBiometricFailed => 'Biometric unlock failed. Try again.';

  @override
  String get unlockSessionExpired => 'Session expired, use PIN';

  @override
  String get unlockBiometricUnavailable => 'Biometric unavailable';

  @override
  String get unlockUseFingerprint => 'Use fingerprint';

  @override
  String get unlockEnterPin => 'Enter PIN';

  @override
  String get pinConfirm => 'Confirm PIN';

  @override
  String get pinSet => 'Set Benny PIN';

  @override
  String get pinMismatch => 'PINs do not match';

  @override
  String get pinImportFailed => 'Import failed';

  @override
  String get pinExternalWalletSetupDescription =>
      'This protects Benny settings and child accounts. Seeker keeps signing keys in Seeker Wallet.';

  @override
  String get childModeConfirmPinTitle => 'Confirm Child Mode PIN';

  @override
  String get childModeSetPinTitle => 'Set Child Mode PIN';

  @override
  String get childModeEnterPinTitle => 'Enter Child Mode PIN';

  @override
  String get childModeConfirmPinSubtitle =>
      'Re-enter the 4-digit PIN used only for child mode.';

  @override
  String get childModeSetPinSubtitle =>
      'Create a 4-digit PIN used only for child mode.';

  @override
  String get childModeEnterPinSubtitle =>
      'Enter the 4-digit PIN used only for child mode to turn it off.';

  @override
  String get childModeOnlyUsed => 'Only used for child mode';

  @override
  String get welcomeReplaceWalletTitle => 'Replace current wallet';

  @override
  String get welcomeReplaceWalletMessage =>
      'Continuing will delete the current wallet.';

  @override
  String get welcomeConfirmAgainTitle => 'Confirm again';

  @override
  String get welcomeConfirmAgainMessage =>
      'After deletion you may lose access to the phrase. Save it first.';

  @override
  String get welcomeNewWalletSubtitle => 'Start a fresh default wallet';

  @override
  String get welcomeImportWalletSubtitleSeeker => 'Phrase or Seeker Vault';

  @override
  String get welcomeImportWalletSubtitlePhrase =>
      'Restore from recovery phrase';

  @override
  String get welcomeHeroSemantics => 'Benny Wallet';

  @override
  String get welcomeHeroPrelude => 'A new wallet is here.';

  @override
  String get welcomeHeroTitle => 'Benny Wallet';

  @override
  String get welcomeHeroSubtitle =>
      'Start fresh or restore your recovery phrase.';

  @override
  String get welcomeNewWallet => 'New wallet';

  @override
  String get welcomeImportWallet => 'Import wallet';

  @override
  String get createWalletTitle => 'Create Wallet';

  @override
  String get createWalletRecoveryTitle => 'Write down your recovery phrase.';

  @override
  String get createWalletRecoverySubtitle =>
      'This is the only way to recover your wallet.';

  @override
  String get webTestingOnly => 'Web is for testing only.';

  @override
  String get recoveryPhraseCopied =>
      'Recovery phrase copied (will clear in 15s)';

  @override
  String get copyPhrase => 'Copy phrase';

  @override
  String get importWalletTitle => 'Import Wallet';

  @override
  String get importRecoveryPhraseTitle => 'Import recovery phrase';

  @override
  String get importRecoveryPhraseSubtitle => 'Use 12 or 24 English words.';

  @override
  String get importPasteHint => 'Paste your recovery phrase here';

  @override
  String get importInvalidPhrase => 'Invalid recovery phrase';

  @override
  String get importEnterWords => 'Enter or paste 12 or 24 words.';

  @override
  String importWordsDetected(int count) {
    return '$count words detected';
  }

  @override
  String get importClear => 'Clear';

  @override
  String get seekerVaultConnectDescription =>
      'Connect the hardware-backed wallet on this Seeker.';

  @override
  String get seekerVaultConnect => 'Connect';

  @override
  String get seekerVaultInstallOrEnable =>
      'Install or enable Seeker Wallet, then try again.';

  @override
  String get seekerVaultAndroidOnly =>
      'Seeker Vault import is available on Android only.';

  @override
  String get seekerVaultNoAccounts =>
      'No existing Seed Vault wallet accounts were returned for this seed.';

  @override
  String get seekerVaultUnavailable =>
      'Seed Vault is not available on this device.';

  @override
  String get seekerVaultCancelled => 'Seeker Vault connection was cancelled.';

  @override
  String get seekerVaultConnectFailed =>
      'Unable to connect Seeker Vault right now. Please try again.';

  @override
  String get receiveTitle => 'Receive';

  @override
  String get receivedHistoryTitle => 'Received history';

  @override
  String get receiveShareAddressTitle => 'Share this address';

  @override
  String get receiveShareAddressSubtitle => 'Scan or copy it.';

  @override
  String get receiveNoAddress => 'No wallet address available';

  @override
  String get receiveNoAddressSubtitle =>
      'Create or unlock a wallet to receive funds.';

  @override
  String get receiveAddressCopied => 'Address copied (will clear in 60s)';

  @override
  String get receiveCopyAddress => 'Copy address';

  @override
  String get sendTitle => 'Send';

  @override
  String get sendChooseAssetTitle => 'Choose asset';

  @override
  String get sendHistoryTitle => 'Send history';

  @override
  String get sendUnavailableChildMode => 'Send is unavailable in child mode.';

  @override
  String get sendOpenReceive => 'Open Receive';

  @override
  String get sendNoAssets => 'No assets available to send.';

  @override
  String get sendRecipientPrefilled => 'Recipient prefilled';

  @override
  String sendLoadAssetsFailed(String error) {
    return 'Failed to load assets: $error';
  }

  @override
  String get sendAssetNotFound => 'Asset not found.';

  @override
  String sendAssetTitle(String symbol) {
    return 'Send $symbol';
  }

  @override
  String get sendScanQrCode => 'Scan QR code';

  @override
  String get sendRecipientAddressHint => 'Recipient Solana address';

  @override
  String sendAvailableAmount(String amount, String symbol) {
    return 'Available $amount $symbol';
  }

  @override
  String sendLoadFormFailed(String error) {
    return 'Failed to load send form: $error';
  }

  @override
  String get sendInvalidAddress => 'Enter a valid Solana address.';

  @override
  String get sendInvalidAmount => 'Enter a valid amount.';

  @override
  String get sendInsufficientBalance => 'Insufficient balance.';

  @override
  String get sendUnlockAgain => 'Unlock the wallet again before sending.';

  @override
  String get sendNotEnoughSolAfterFee =>
      'Not enough SOL after reserving the network fee.';

  @override
  String get sendNotEnoughSolForFee =>
      'Not enough SOL to cover the network fee.';

  @override
  String get sendGenericFailure => 'Send failed. Please try again.';

  @override
  String get sendAmountHint => 'Amount';

  @override
  String get portfolioChildAccounts => 'Child accounts';

  @override
  String get portfolioCrypto => 'Crypto';

  @override
  String get portfolioStocks => 'Stocks';

  @override
  String get portfolioMessages => 'Messages';

  @override
  String get portfolioTokens => 'Tokens';

  @override
  String get portfolioDefi => 'DeFi';

  @override
  String get portfolioSend => 'Send';

  @override
  String get portfolioSwap => 'Swap';

  @override
  String get portfolioReceive => 'Receive';

  @override
  String get portfolioCouldNotRefreshAssets => 'Couldn\'t refresh assets';

  @override
  String get portfolioPullToRetry => 'Pull down to try again.';

  @override
  String get portfolioDefiParentOnly => 'DeFi is parent-only';

  @override
  String get portfolioDefiParentOnlyMessage =>
      'Switch back to parent mode to review protocol positions.';

  @override
  String get portfolioDefiUnavailable => 'DeFi data is temporarily unavailable';

  @override
  String get portfolioDefiUnavailableMessage => 'Tokens are still up to date.';

  @override
  String get portfolioNoDefi => 'No DeFi positions yet';

  @override
  String get portfolioRefreshingDefi => 'Refreshing protocol positions...';

  @override
  String get portfolioNoActiveDefi =>
      'Your wallet has no active DeFi positions.';

  @override
  String get portfolioRefreshFailed => 'Refresh failed';

  @override
  String get portfolioNetworkBusy =>
      'The network is busy right now. Pull down to try again.';

  @override
  String get portfolioServerUnavailable =>
      'Couldn\'t reach the server. Check your connection and pull down to try again.';

  @override
  String get portfolioRefreshAssetsFailed =>
      'Couldn\'t refresh assets. Pull down to try again.';

  @override
  String get portfolioReceiveSol => 'Receive SOL';

  @override
  String get portfolioReceiveSolSubtitle =>
      'Receive SOL to get started with Benny Wallet.';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonAmount => 'Amount';

  @override
  String get commonAuto => 'Auto';

  @override
  String get commonBuy => 'Buy';

  @override
  String get commonConfirmed => 'Confirmed';

  @override
  String get commonCustom => 'Custom';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonFrom => 'From';

  @override
  String get commonNetwork => 'Network';

  @override
  String get commonNetworkFee => 'Network fee';

  @override
  String get commonSave => 'Save';

  @override
  String get commonSend => 'Send';

  @override
  String get commonSignature => 'Signature';

  @override
  String get commonSolana => 'Solana';

  @override
  String get commonStatus => 'Status';

  @override
  String get commonSubmitted => 'Submitted';

  @override
  String get commonTo => 'To';

  @override
  String get commonToken => 'Token';

  @override
  String get transactionTimeline => 'Transaction timeline';

  @override
  String get walletAddressUnavailable => 'Wallet address is unavailable.';

  @override
  String relativeSecondsAgo(Object count) {
    return '${count}s ago';
  }

  @override
  String relativeMinutesAgo(Object count) {
    return '${count}m ago';
  }

  @override
  String relativeHoursAgo(Object count) {
    return '${count}h ago';
  }

  @override
  String relativeDaysAgo(Object count) {
    return '${count}d ago';
  }

  @override
  String get importWalletLoadingTitle => 'Importing wallet...';

  @override
  String get importWalletLoadingSubtitle =>
      'Preparing your Solana wallet list.';

  @override
  String get importSolanaMainnet => 'Solana Mainnet';

  @override
  String get importSelectSolanaAccount =>
      'Select the Solana account to import.';

  @override
  String get importLoadingSolanaAccounts => 'Loading Solana accounts...';

  @override
  String get importCheckingActiveSolanaAccounts =>
      'Checking active Solana accounts.';

  @override
  String get importUnableScanRecoveryPhrase =>
      'Unable to scan this recovery phrase right now.';

  @override
  String get importActiveAccount => 'Active account';

  @override
  String get importDefaultMainWallet => 'Default main wallet';

  @override
  String get seekerVaultTitle => 'Seeker Vault';

  @override
  String get seekerVaultChooseFundedAccount => 'Choose funded account';

  @override
  String get seekerVaultChooseAccount => 'Choose account';

  @override
  String get seekerVaultFundedAccountFound =>
      'Benny found account activity under this Seed Vault wallet.';

  @override
  String get seekerVaultNoFundedAccountFound =>
      'No funded account was found. These are the accounts returned by Seed Vault.';

  @override
  String seekerVaultAssetCount(Object count) {
    return '$count assets';
  }

  @override
  String get seekerVaultNoAssets => 'No assets';

  @override
  String get scanAddressTitle => 'Scan address';

  @override
  String get scanNoSolanaAddress => 'No Solana address found in this QR code.';

  @override
  String get scanPointCamera => 'Point the camera at a Solana QR code.';

  @override
  String get sendConfirmTitle => 'Confirm send';

  @override
  String get sendSubmitting => 'Submitting...';

  @override
  String sendSubmittingSummary(Object address, Object amount, Object symbol) {
    return '$amount $symbol to $address';
  }

  @override
  String get sendSubmitted => 'Submitted';

  @override
  String get sendFailed => 'Send failed';

  @override
  String sendSubmittedMessage(Object address, Object amount, Object symbol) {
    return '$amount $symbol was submitted to $address. Confirmation may take a moment.';
  }

  @override
  String get sendTransactionCouldNotComplete =>
      'The transaction could not be completed.';

  @override
  String get sendViewTransaction => 'View transaction';

  @override
  String get sendRecipientNotReady =>
      'The recipient wallet is not ready to receive this token yet.';

  @override
  String get sendNetworkBusy => 'The network is busy. Please try again.';

  @override
  String get sendNetworkTakingLonger =>
      'The network is taking longer than expected. Please try again.';

  @override
  String get sendHistoryEmpty => 'No send history yet.';

  @override
  String sendHistoryLoadFailed(Object error) {
    return 'Unable to load send history: $error';
  }

  @override
  String get sendDetailsTitle => 'Send details';

  @override
  String get sendNotConfirmedYet => 'Not confirmed yet';

  @override
  String get sendOpenTokenDetails => 'Open token details';

  @override
  String get sendViewOnSolscan => 'View on Solscan';

  @override
  String get sendToEmpty => 'To --';

  @override
  String sendToAddress(Object address) {
    return 'To $address';
  }

  @override
  String get sendStatusFailed => 'Failed';

  @override
  String get sendStatusFinalized => 'Finalized';

  @override
  String get sendStatusConfirmed => 'Confirmed';

  @override
  String get sendStatusSubmitted => 'Submitted';

  @override
  String get sendStatusSourceHeliusWebhook => 'Helius webhook';

  @override
  String get sendStatusSourceRpcSync => 'Chain status sync';

  @override
  String get sendStatusSourceChainActivity => 'Chain activity';

  @override
  String get sendTransactionFallbackTitle => 'Send transaction';

  @override
  String get sendSubmittedToSender => 'Submitted to sender';

  @override
  String get sendSubmittedToSenderSubtitle =>
      'Helius Sender accepted the signed transaction.';

  @override
  String get sendAsyncResultFailed => 'Async result failed';

  @override
  String get sendWaitingAsyncConfirmation => 'Waiting for async confirmation';

  @override
  String get sendAsyncConfirmationReceived => 'Async confirmation received';

  @override
  String get sendUpdatedFromHeliusWebhook => 'Updated from Helius webhook.';

  @override
  String get sendUpdatedFromChainStatusSync =>
      'Updated from chain status sync.';

  @override
  String get sendConfirmationNotReceivedYet =>
      'Confirmation has not been received yet.';

  @override
  String get swapTitle => 'Swap';

  @override
  String get swapButton => 'Swap';

  @override
  String get swapReviewTitle => 'Review swap';

  @override
  String swapForAmount(Object amount, Object symbol) {
    return 'for ~$amount $symbol';
  }

  @override
  String get swapPay => 'Pay';

  @override
  String get swapReceive => 'Receive';

  @override
  String get swapMinimumReceive => 'Minimum receive';

  @override
  String get swapSlippage => 'Slippage';

  @override
  String get swapPriorityFee => 'Priority fee';

  @override
  String get swapRoute => 'Route';

  @override
  String swapLamports(Object lamports) {
    return '$lamports lamports';
  }

  @override
  String get swapPriorityNormal => 'Normal';

  @override
  String get swapPriorityFast => 'Fast';

  @override
  String get swapPriorityTurbo => 'Turbo';

  @override
  String get swapProcessing => 'Swapping...';

  @override
  String swapProcessingSummary(
    Object inputAmount,
    Object inputSymbol,
    Object outputAmount,
    Object outputSymbol,
  ) {
    return '$inputAmount $inputSymbol to $outputAmount $outputSymbol';
  }

  @override
  String get swapComplete => 'Swap complete';

  @override
  String get swapFailed => 'Swap failed';

  @override
  String swapReceivedAmount(Object amount, Object symbol) {
    return '$amount $symbol received';
  }

  @override
  String get swapCouldNotComplete => 'The swap could not be completed.';

  @override
  String get swapTradingUnavailableChildMode =>
      'Trading is unavailable in child mode.';

  @override
  String get swapNoBaseAssetsForXStocks =>
      'No SOL, USDC, or USDT available to buy xStocks.';

  @override
  String get swapNoAssetsAvailable => 'No assets available to swap.';

  @override
  String get swapPayWith => 'Pay with';

  @override
  String get swapBuyXStock => 'Buy xStock';

  @override
  String swapAvailable(Object amount, Object symbol) {
    return 'Available $amount $symbol';
  }

  @override
  String get swapRefreshingQuote => 'Refreshing quote...';

  @override
  String swapRouteLabel(Object route) {
    return 'Route: $route';
  }

  @override
  String get swapBestRoute => 'Best route';

  @override
  String swapFailedLoadWalletAssets(Object error) {
    return 'Failed to load wallet assets: $error';
  }

  @override
  String swapRateSummary(Object inputSymbol, Object outputSymbol, Object rate) {
    return '1 $inputSymbol ≈ $rate $outputSymbol';
  }

  @override
  String swapSlippageMin(Object value) {
    return '$value min';
  }

  @override
  String swapCustomWithValue(Object value) {
    return 'Custom · $value';
  }

  @override
  String swapMinReceive(Object amount) {
    return 'Min $amount';
  }

  @override
  String get swapAmountTooSmall =>
      'This amount is too small for a valid route.';

  @override
  String get swapWaitValidQuote => 'Wait for a valid quote before continuing.';

  @override
  String swapNotEnoughSolReserve(Object reserve) {
    return 'Not enough SOL.\nNeed $reserve SOL reserve.';
  }

  @override
  String get swapRouteUnavailable =>
      'This swap route isn\'t available right now. Try swapping with SOL or choose another token pair.';

  @override
  String get swapPriceMoved =>
      'Price moved before the swap was sent. Increase slippage and try again.';

  @override
  String get swapNotEnoughTokenBalance =>
      'Not enough token balance. Tap Max again and retry.';

  @override
  String get swapQuotesBusy =>
      'Quotes are busy right now. Try again in a moment.';

  @override
  String get swapQuoteExpired => 'This quote expired. Review the swap again.';

  @override
  String get swapUnlockAgain => 'Unlock the wallet again before swapping.';

  @override
  String get swapTransactionUnavailable => 'Swap transaction is unavailable.';

  @override
  String get swapConnectSeekerVaultAgain =>
      'Connect Seeker Vault again before swapping.';

  @override
  String get swapConnectSeedVaultAgain =>
      'Connect Seed Vault again before swapping.';

  @override
  String get swapUnexpectedSignatureCount =>
      'Wallet returned an unexpected signature count.';

  @override
  String get swapCustomSlippageLabel => 'Custom slippage %';

  @override
  String get swapChooseToken => 'Choose';

  @override
  String get swapApproxYouReceive => 'Approx. you receive';

  @override
  String get swapRate => 'Rate';

  @override
  String get swapPlatformFee => 'Platform fee';

  @override
  String get swapSearchTokenHint => 'Search token name or symbol';

  @override
  String get swapNoTokensAvailable => 'No tokens available';

  @override
  String swapNoResultsFor(Object query) {
    return 'No results found for \"$query\"';
  }

  @override
  String get swapYourAssets => 'Your assets';

  @override
  String get swapSuggestedTokens => 'Suggested tokens';

  @override
  String swapAvailableBalance(Object amount) {
    return '$amount available';
  }

  @override
  String get assetNotFound => 'Asset not found.';

  @override
  String get assetPosition => 'Position';

  @override
  String get assetValue => 'Value';

  @override
  String get assetBalance => 'Balance';

  @override
  String get assetReturn24h => '24h return';

  @override
  String get assetInfo => 'Info';

  @override
  String get assetName => 'Name';

  @override
  String get assetSymbol => 'Symbol';

  @override
  String get assetMint => 'Mint';

  @override
  String get assetWebsite => 'Website';

  @override
  String get assetPrice => 'Price';

  @override
  String get assetMarketCap => 'Market cap';

  @override
  String get assetFdv => 'FDV';

  @override
  String get assetTotalSupply => 'Total supply';

  @override
  String get assetCirculatingSupply => 'Circulating supply';

  @override
  String get assetHolders => 'Holders';

  @override
  String get assetCreated => 'Created';

  @override
  String get assetPerformance24h => '24h performance';

  @override
  String get assetVolume => 'Volume';

  @override
  String get assetTraders => 'Traders';

  @override
  String get assetSafety => 'Safety';

  @override
  String get assetTop10Holders => 'Top 10 holders';

  @override
  String get assetMarketStatsUnavailable =>
      'Some market stats are unavailable right now.';

  @override
  String get assetActivity => 'Activity';

  @override
  String get assetNoActivity => 'No activity yet.';

  @override
  String get assetActivityLoadFailed => 'Activity could not be loaded.';

  @override
  String assetLoadDetailsFailed(Object error) {
    return 'Failed to load asset details: $error';
  }

  @override
  String get assetMintCopied => 'Mint copied (will clear in 60s)';

  @override
  String get assetCouldNotOpenWebsite => 'Could not open website.';

  @override
  String get assetSwapOut => 'Swap Out';

  @override
  String get assetSwapIn => 'Swap In';

  @override
  String assetToSymbol(Object symbol) {
    return 'To $symbol';
  }

  @override
  String assetFromSymbol(Object symbol) {
    return 'From $symbol';
  }

  @override
  String get assetSent => 'Sent';

  @override
  String get assetReceived => 'Received';

  @override
  String get assetTransfer => 'Transfer';

  @override
  String assetSwapWithTime(Object time) {
    return 'Swap  •  $time';
  }

  @override
  String assetCounterpartyWithTime(Object address, Object time) {
    return '$address  •  $time';
  }

  @override
  String get notificationsMarkAllRead => 'Mark all read';

  @override
  String get notificationsUnavailableTitle => 'Messages unavailable';

  @override
  String get notificationsUnavailableSubtitle =>
      'Unable to load messages right now.';

  @override
  String get notificationsEmptyTitle => 'No messages yet';

  @override
  String get notificationsEmptySubtitle =>
      'Push messages will appear here after they arrive.';

  @override
  String get notificationDeleted => 'Message deleted';

  @override
  String get receivedHistoryEmpty => 'No received history yet.';

  @override
  String receivedHistoryLoadFailed(Object error) {
    return 'Unable to load received history: $error';
  }

  @override
  String get receivedDetailsTitle => 'Received details';

  @override
  String get receivedDetailsMissingId =>
      'This message does not include a received transfer id.';

  @override
  String receivedDetailsLoadFailed(Object error) {
    return 'Unable to load this received transfer: $error';
  }

  @override
  String get receivedFundsTitle => 'Funds received';

  @override
  String receivedYouReceived(Object amount) {
    return 'You received $amount';
  }

  @override
  String receivedYouReceivedInWallet(String amount, String wallet) {
    return 'You received $amount in $wallet';
  }

  @override
  String get receivedFromEmpty => 'From --';

  @override
  String receivedFromAddress(Object address) {
    return 'From $address';
  }

  @override
  String get receivedRelatedChanges => 'Related changes';

  @override
  String get receivedOnSolana => 'Received on Solana';

  @override
  String get receivedMarkedFailed => 'The receive event was marked failed.';

  @override
  String get receivedArrived => 'Funds arrived in this wallet.';

  @override
  String get receivedNewFundsArrived => 'New funds arrived in your wallet.';

  @override
  String get childVerifyPinTitle => 'Verify your PIN';

  @override
  String get childWalletAlreadyAdded =>
      'This child wallet has already been added.';

  @override
  String childWalletAdded(Object name) {
    return '$name added successfully';
  }

  @override
  String childWalletAddFailed(Object error) {
    return 'Failed to add child wallet: $error';
  }

  @override
  String childWalletUpdated(Object name) {
    return '$name updated successfully';
  }

  @override
  String childWalletUpdateFailed(Object error) {
    return 'Failed to update child wallet: $error';
  }

  @override
  String childWalletDeleteTitle(Object name) {
    return 'Delete $name?';
  }

  @override
  String get childWalletDeleteMessage =>
      'This child wallet entry will be removed from parent monitoring.';

  @override
  String childWalletDeleted(Object name) {
    return '$name deleted';
  }

  @override
  String childWalletDeleteFailed(Object error) {
    return 'Failed to delete child wallet: $error';
  }

  @override
  String get childAccountsTitle => 'Child Accounts';

  @override
  String get childManageUnavailable =>
      'Turn off child mode to manage child accounts.';

  @override
  String get childNoAccountsYet => 'No child accounts yet';

  @override
  String childAccountCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count child accounts',
      one: '1 child account',
    );
    return '$_temp0';
  }

  @override
  String get childAddAccount => 'Add Child Account';

  @override
  String get childEditAccount => 'Edit Child Account';

  @override
  String get childName => 'Child name';

  @override
  String get childNameHint => 'e.g. Alice';

  @override
  String get childWalletAddress => 'Child Wallet Address';

  @override
  String get childScanAgain => 'Scan Again';

  @override
  String get childScanQrAgain => 'Scan QR Code Again';

  @override
  String get childEnterName => 'Please enter a child name.';

  @override
  String get childEnterValidWalletAddress =>
      'Please enter a valid wallet address.';

  @override
  String get childWalletTitle => 'Child Wallet';

  @override
  String get childWalletNotFound => 'Child wallet not found';

  @override
  String get childAddressCopied => 'Address copied to clipboard';

  @override
  String get childTotalBalance => 'Total Balance';

  @override
  String get childSendToChildWallet => 'Send to Child Wallet';

  @override
  String get childNoAssets => 'No assets';

  @override
  String get childAssets => 'Assets';

  @override
  String childWalletLoadFailed(Object error) {
    return 'Error loading child wallet: $error';
  }

  @override
  String get feedbackHeading => 'Tell us what went wrong';

  @override
  String get feedbackSubtitle =>
      'Send your question or issue directly to Benny Wallet support.';

  @override
  String get feedbackEmailOptional => 'Email (optional)';

  @override
  String get feedbackMessage => 'Message';

  @override
  String get feedbackMessageHint => 'Describe the issue you are seeing.';

  @override
  String get feedbackSending => 'Sending...';

  @override
  String get feedbackMessageRequiredTitle => 'Message Required';

  @override
  String get feedbackMessageRequiredMessage =>
      'Enter your feedback before sending.';

  @override
  String get feedbackMessageTooLongTitle => 'Message Too Long';

  @override
  String get feedbackMessageTooLongMessage =>
      'Keep your feedback within 2000 characters.';

  @override
  String get feedbackInvalidEmailTitle => 'Invalid Email';

  @override
  String get feedbackInvalidEmailMessage =>
      'Enter a valid email address or leave it empty.';

  @override
  String get feedbackSent => 'Your message has been sent.';

  @override
  String get feedbackSendFailedTitle => 'Send Failed';

  @override
  String get feedbackSendFailedFallback =>
      'Unable to send your message right now. Please try again shortly.';

  @override
  String get rentTitle => 'Solana Rent Reclaim';

  @override
  String get rentDescription =>
      'Close empty token accounts and recover their rent back to your main SOL balance.';

  @override
  String get rentWalletAddress => 'Wallet address';

  @override
  String get rentClosableTokenAccounts => 'Closable token accounts';

  @override
  String get rentReclaimableRent => 'Reclaimable rent';

  @override
  String get rentAccountsToClose => 'Accounts to close';

  @override
  String rentMoreAccounts(Object count) {
    return '+$count more accounts will be reclaimed.';
  }

  @override
  String get rentReclaiming => 'Reclaiming...';

  @override
  String get rentNothingToReclaim => 'Nothing to reclaim';

  @override
  String get rentReclaimAll => 'Reclaim all rent';

  @override
  String get rentReclaimingRent => 'Reclaiming rent...';

  @override
  String get rentSubmittingTransactions =>
      'Submitting close-account transactions now.';

  @override
  String get rentUnlockRequiredTitle => 'Unlock Required';

  @override
  String get rentUnlockRequiredMessage =>
      'Unlock the wallet again before reclaiming rent.';

  @override
  String get rentReclaimFailedTitle => 'Reclaim Failed';

  @override
  String get rentWalletRequiredTitle => 'Wallet Required';

  @override
  String get rentConnectSeekerVaultAgain =>
      'Connect Seeker Vault again before reclaiming rent.';

  @override
  String get rentConnectSeedVaultAgain =>
      'Connect Seed Vault again before reclaiming rent.';

  @override
  String rentSubmittedTransactions(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reclaim transactions',
      one: '1 reclaim transaction',
    );
    return 'Submitted $_temp0.';
  }

  @override
  String rentSubmittedTransactionsWithSkipped(num skipped, num submitted) {
    String _temp0 = intl.Intl.pluralLogic(
      submitted,
      locale: localeName,
      other: '$submitted reclaim transactions',
      one: '1 reclaim transaction',
    );
    String _temp1 = intl.Intl.pluralLogic(
      skipped,
      locale: localeName,
      other: '$skipped accounts',
      one: '1 account',
    );
    return 'Submitted $_temp0; $_temp1 skipped.';
  }

  @override
  String get rentUnableScan =>
      'Unable to scan reclaimable token accounts right now.';

  @override
  String rentMintAddress(Object address) {
    return 'Mint $address';
  }

  @override
  String get airdropTitle => 'BYC Airdrop';

  @override
  String get airdropUnavailableTitle => 'BYC airdrop temporarily unavailable';

  @override
  String get airdropUnlockBeforeJoin =>
      'Unlock your wallet before joining the BYC airdrop.';

  @override
  String get airdropJoinDialogTitle => 'Join the BYC airdrop?';

  @override
  String airdropJoinDialogMessage(Object address) {
    return 'We will use your current Benny wallet address:\n\n$address\n\nThis address will be sent to the Benny backend to register your airdrop profile.';
  }

  @override
  String get airdropJoin => 'Join';

  @override
  String get airdropJoinedSnack =>
      'You are in. Your BYC reward profile is ready.';

  @override
  String get airdropJoinBeforeCheckIn =>
      'Join the BYC airdrop before checking in.';

  @override
  String get airdropUnlockBeforeCheckIn =>
      'Unlock your wallet before checking in.';

  @override
  String get airdropJoined => 'Joined';

  @override
  String get airdropNotJoined => 'Not joined';

  @override
  String get airdropBycPoints => 'BYC points';

  @override
  String get airdropStreak => 'Streak';

  @override
  String airdropDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get airdropWalletUnavailable => 'Wallet unavailable';

  @override
  String get airdropJoinCardTitle => 'Join the airdrop';

  @override
  String get airdropJoinCardSubtitle =>
      'Confirm with your active Benny wallet and create your BYC reward profile.';

  @override
  String get airdropJoining => 'Joining...';

  @override
  String get airdropJoinWithThisWallet => 'Join With This Wallet';

  @override
  String get airdropCheckInNow => 'Check in now';

  @override
  String get airdropCheckedInToday => 'Checked in today';

  @override
  String airdropNextReward(Object points) {
    return 'Next reward: +$points BYC';
  }

  @override
  String get airdropComeBackTomorrow => 'Come back tomorrow to claim more BYC.';

  @override
  String get airdropCheckingIn => 'Checking in...';

  @override
  String airdropLastClaimed(Object date) {
    return 'Last claimed $date';
  }

  @override
  String get airdropRewardRules => 'Reward rules';

  @override
  String get airdropFirstCheckIn => 'First check-in';

  @override
  String get airdropNextDayReward => 'Next day reward';

  @override
  String airdropEveryDayStreak(Object days) {
    return 'Every $days-day streak';
  }

  @override
  String get airdropUnableOpenPumpFun => 'Unable to open Pump.fun right now.';

  @override
  String get airdropView => 'View';

  @override
  String get airdropPointsBalanceUpdated =>
      'Your Benny points balance has been updated.';

  @override
  String get airdropFirstCheckInUnlocked => 'First check-in unlocked';

  @override
  String get airdropStreakBonusLanded => 'Streak bonus landed';

  @override
  String get airdropAlreadyClaimedToday => 'Already claimed today';

  @override
  String get airdropRewardClaimed => 'Reward claimed';

  @override
  String get defiTypeDeposit => 'deposit';

  @override
  String get defiTypeBorrow => 'borrow';

  @override
  String get defiTypeStaking => 'staking';

  @override
  String get defiTypeLiquidity => 'liquidity';

  @override
  String get defiTypeYield => 'yield';

  @override
  String get defiTypePerps => 'perps';

  @override
  String get defiTypeRewards => 'rewards';

  @override
  String get defiTypePosition => 'position';

  @override
  String get settingsSeekerWallet => 'Seeker Wallet';

  @override
  String get updateDefaultTitle => 'Update available';

  @override
  String get updateDefaultMessage =>
      'A newer version of Benny Wallet is available.';

  @override
  String get updateFailedTitle => 'Update Failed';

  @override
  String get updateUnableToOpen =>
      'Unable to open the Benny Wallet update link right now.';

  @override
  String get routerFeatureUnavailableTitle => 'Feature unavailable';

  @override
  String get routerFeatureUnavailableMessage =>
      'This feature is not available in this build.';

  @override
  String get routerMessageUnavailableTitle => 'Message unavailable';

  @override
  String get routerMessageUnavailableMessage =>
      'Open a received message from the message list first.';

  @override
  String get routerSendDetailsUnavailableTitle => 'Send details unavailable';

  @override
  String get routerSendDetailsUnavailableMessage =>
      'Open a transaction from send history first.';

  @override
  String get routerInvalidChildWalletId => 'Invalid child wallet ID';

  @override
  String routerRouteNotFound(String uri) {
    return 'Route not found: $uri';
  }

  @override
  String get walletsTitle => 'Wallets';

  @override
  String get walletsSubtitle => 'Switch, add, rename or remove wallets';

  @override
  String get walletSwitcherTitle => 'Your wallets';

  @override
  String walletSwitcherCount(int count, int max) {
    return '$count of $max';
  }

  @override
  String get walletAddWallet => 'Add wallet';

  @override
  String walletAddLimitReached(int max) {
    return 'You can add up to $max wallets.';
  }

  @override
  String get walletManage => 'Manage';

  @override
  String get walletAddSheetTitle => 'Add a wallet';

  @override
  String get walletAddSheetSubtitle =>
      'Each wallet has its own recovery phrase and account. One PIN unlocks them all.';

  @override
  String get walletAddCreate => 'Create new wallet';

  @override
  String get walletAddCreateSubtitle => 'Generate a fresh recovery phrase';

  @override
  String get walletAddImport => 'Import recovery phrase';

  @override
  String get walletAddImportSubtitle => 'Use a phrase or another account';

  @override
  String get walletAddSeedVault => 'Connect Seed Vault';

  @override
  String get walletAddSeedVaultSubtitle => 'Use an account from your Seeker';

  @override
  String get walletNameTitle => 'Name your wallet';

  @override
  String get walletNameSubtitle =>
      'Only saved on this device. You can change it anytime.';

  @override
  String get walletNameLabel => 'Wallet name';

  @override
  String get walletNameEmpty => 'Enter a wallet name';

  @override
  String walletAdded(String name) {
    return '$name added';
  }

  @override
  String walletSwitched(String name) {
    return 'Switched to $name';
  }

  @override
  String get walletDuplicateTitle => 'Already added';

  @override
  String get walletDuplicateMessage =>
      'This recovery phrase and account is already in Benny. Each phrase + account can only be added once.';

  @override
  String get walletAlreadyAddedBadge => 'Added';

  @override
  String get walletRename => 'Rename';

  @override
  String get walletRenameTitle => 'Rename wallet';

  @override
  String get walletRemove => 'Remove';

  @override
  String walletRemoveTitle(String name) {
    return 'Remove $name?';
  }

  @override
  String get walletRemoveMessage =>
      'This removes the wallet from this device. Back up its recovery phrase first — without it the funds cannot be recovered.';

  @override
  String get walletRemoveExternalMessage =>
      'This disconnects the wallet from Benny. Your keys stay safe in Seed Vault.';

  @override
  String walletRemoved(String name) {
    return '$name removed';
  }

  @override
  String get walletActiveBadge => 'Active';

  @override
  String get walletTypePhrase => 'Recovery phrase';

  @override
  String get walletTypeSeedVault => 'Seed Vault';

  @override
  String get swapWalletChanged =>
      'The active wallet changed. Go back and get a new quote.';

  @override
  String seedVaultPickNamedSeed(String seed, String wallet) {
    return 'Pick the seed “$seed” next. It holds $wallet.';
  }

  @override
  String seedVaultPickUnknownSeed(String wallet) {
    return 'Pick the seed that holds $wallet. If you pick the wrong one, you\'ll be told and it disappears from the list.';
  }

  @override
  String seedVaultWrongSeedNamed(String seed) {
    return '“$seed” doesn\'t contain this wallet.';
  }

  @override
  String get seedVaultReauthorizeTitle => 'Re-authorize Seed Vault';

  @override
  String get childAddFromMyWallets => 'Or pick one of my wallets';

  @override
  String get walletAddChildModeSetPin =>
      'This wallet has no saved child-mode PIN. Set one next; it\'s needed to turn child mode off.';

  @override
  String get settingsChildModeAppPinTitle =>
      'Enter your app PIN to turn off child mode';

  @override
  String get walletAddChildModeTitle => 'This is a child-mode wallet';

  @override
  String get walletAddChildModeMessage =>
      'After importing, the app switches to child mode: wallet switching is hidden, no wallets can be added, and you can\'t send to your other wallets. Import it anyway?';

  @override
  String get walletAddChildModeConfirm => 'Agree and import';

  @override
  String get walletTypeStandard => 'Standard';

  @override
  String get sendToMyWallet => 'Send to my wallet';

  @override
  String get walletChildModeLocked =>
      'Turn off child mode to switch or add wallets.';

  @override
  String get walletPinToContinue => 'Enter your PIN to continue';

  @override
  String get walletActionFailed => 'Something went wrong. Please try again.';

  @override
  String get settingsChangePin => 'Change PIN';

  @override
  String get settingsChangePinSubtitle => 'One PIN unlocks all your wallets';

  @override
  String get changePinCurrent => 'Enter current PIN';

  @override
  String get changePinNew => 'Enter new PIN';

  @override
  String get changePinConfirm => 'Confirm new PIN';

  @override
  String get changePinSuccess => 'PIN changed';

  @override
  String get changePinSameAsOld => 'Choose a different PIN';

  @override
  String get unlockSetPinTitle => 'Set a Benny PIN';

  @override
  String get unlockSetPinSubtitle =>
      'One PIN now protects every wallet on this device.';

  @override
  String get pinUnlocksAllWallets => 'This PIN unlocks all your wallets.';

  @override
  String settingsLogOutAllWallets(int count) {
    return 'This removes all $count wallets from this device. Back up every recovery phrase first.';
  }

  @override
  String importAccountLabel(int number) {
    return 'Account $number';
  }

  @override
  String importAccountAltLabel(int number) {
    return 'Account $number · alt path';
  }

  @override
  String get importLegacyLabel => 'Legacy';

  @override
  String get travelGuardTitle => 'Travel guard';

  @override
  String get travelGuardOffSubtitle =>
      'A special PIN that opens only one wallet';

  @override
  String get travelGuardOnSubtitle => 'On: the special PIN opens one wallet';

  @override
  String get travelGuardInfoTitle => 'What is travel guard?';

  @override
  String get travelGuardInfoBody =>
      'For when someone forces you to open your wallet.\n\nSet a special PIN and pick one wallet (keep a small amount in it). Unlocking with the special PIN opens only that wallet: your other wallets, their balances and messages are hidden everywhere, including wallet lists and send, and this setting is hidden too. It looks like an ordinary wallet.\n\nWhile travel guard is on, biometric unlock is turned off and cannot be turned on, so the PIN is always asked.\n\nLock the app (or let it lock) and unlock with your normal PIN to see all your wallets again.';

  @override
  String get travelGuardChooseWallet =>
      'Choose the wallet the special PIN opens';

  @override
  String get travelGuardNewPin => 'Set the special PIN';

  @override
  String get travelGuardConfirmPin => 'Enter the special PIN again';

  @override
  String get travelGuardPinHint => 'It must differ from your normal PIN.';

  @override
  String get travelGuardPinSameAsApp =>
      'This is your normal PIN. Choose another one.';

  @override
  String get travelGuardEnabled => 'Travel guard is on';

  @override
  String get travelGuardDisabled => 'Travel guard is off';

  @override
  String get travelGuardActiveBadge => 'Travel guard is on';

  @override
  String get travelGuardBiometricsOff => 'Unavailable while travel guard is on';

  @override
  String get welcomeUseAsSigner => 'Use this phone as an offline signer';

  @override
  String get walletAddAirGap => 'Connect offline signer';

  @override
  String get walletAddAirGapSubtitle =>
      'Keys stay on another phone that never goes online';

  @override
  String createWalletWordCount(int count) {
    return '$count words';
  }

  @override
  String get signerAppTitle => 'Benny Signer';

  @override
  String get signerNeedsNoWalletsTitle => 'Remove all wallets first';

  @override
  String get signerNeedsNoWalletsBody =>
      'A signer phone holds only its own offline recovery phrase. Back up and remove every wallet on this phone in Settings > Wallets, then try again.';

  @override
  String get signerEnterTitle => 'Turn this phone into a signer?';

  @override
  String get signerEnterBody =>
      'This phone will stay offline and only sign. It will have no wallet screens. To use it as a wallet again you will have to erase it.';

  @override
  String get signerIntroTitle => 'Offline signer';

  @override
  String get signerIntroPoint1 =>
      'This phone keeps your recovery phrase and never goes online again.';

  @override
  String get signerIntroPoint2 =>
      'Your other phone with Benny Wallet builds transactions. You sign them here by scanning QR codes.';

  @override
  String get signerIntroPoint3 =>
      'Before a recovery phrase is created, we will help you switch off every network.';

  @override
  String get signerIntroPoint4 =>
      'Write the recovery phrase on paper. It is the only backup.';

  @override
  String get signerIntroStart => 'Start';

  @override
  String get signerIntroCancel => 'Not now, use as a wallet';

  @override
  String get signerOfflineTitle => 'Take this phone offline';

  @override
  String get signerOfflineBody =>
      'Turn on airplane mode and switch off Wi-Fi, Bluetooth and NFC. You can continue once every required item is green.';

  @override
  String get signerCheckAirplane => 'Airplane mode on';

  @override
  String get signerCheckWifi => 'Wi-Fi off';

  @override
  String get signerCheckBluetooth => 'Bluetooth off';

  @override
  String get signerCheckNfc => 'NFC off';

  @override
  String get signerCheckNoNetwork => 'No network connection';

  @override
  String get signerCheckUsbDebugging => 'USB debugging off';

  @override
  String get signerCheckSim => 'SIM card removed (recommended)';

  @override
  String get signerCheckManualHint =>
      'This phone can\'t check this. Confirm it yourself.';

  @override
  String get signerOpenSettings => 'Open settings';

  @override
  String get signerNetworkDetected =>
      'A network connection was detected. Switch it off to continue.';

  @override
  String get signerPinTitle => 'Set signer PIN';

  @override
  String get signerPinBody => 'Choose a 6-digit PIN for this signer.';

  @override
  String get signerPinConfirmTitle => 'Confirm PIN';

  @override
  String get signerPinConfirmBody => 'Enter the PIN again.';

  @override
  String get signerPinMismatch => 'The PINs don\'t match. Try again.';

  @override
  String get signerSourceTitle => 'Recovery phrase';

  @override
  String get signerSourceBody =>
      'Create a new recovery phrase on this offline phone, or enter one you already have.';

  @override
  String get signerSourceCreate24 => 'Create 24 words';

  @override
  String get signerSourceCreate24Subtitle => 'Recommended for a signer';

  @override
  String get signerSourceCreate12 => 'Create 12 words';

  @override
  String get signerSourceCreate12Subtitle => 'Shorter to write down';

  @override
  String get signerSourceImport => 'Import existing phrase';

  @override
  String get signerSourceImportSubtitle => '12 or 24 words';

  @override
  String get signerWordsTitle => 'Write these words down';

  @override
  String get signerWordsWarning =>
      'Write the words on paper in order. Never take a photo, screenshot or type them anywhere else. Anyone with these words can take your funds.';

  @override
  String get signerWordsDone => 'I wrote them down';

  @override
  String get signerVerifyTitle => 'Check your backup';

  @override
  String get signerImportTitle => 'Import recovery phrase';

  @override
  String get signerImportBody =>
      'Enter your 12 or 24 words separated by spaces.';

  @override
  String get signerImportInvalid =>
      'This isn\'t a valid 12 or 24 word recovery phrase.';

  @override
  String get signerFinishTitle => 'Finish setup';

  @override
  String get signerDeviceNameLabel => 'Signer name';

  @override
  String get signerDeviceNameHelper =>
      'Shown in your wallet after you connect.';

  @override
  String get signerBiometricToggle => 'Unlock with biometrics';

  @override
  String get signerFinishButton => 'Finish';

  @override
  String get signerSetupFailed => 'Setup couldn\'t be saved. Try again.';

  @override
  String get signerUnlockSubtitle => 'Enter your signer PIN';

  @override
  String get signerUnlockNetworkBlocked =>
      'A network connection is on. Turn on airplane mode to unlock.';

  @override
  String signerWrongPin(int count) {
    return 'Wrong PIN. $count attempts left before the signer is erased.';
  }

  @override
  String get signerUnlockFailed => 'Couldn\'t unlock. Try again.';

  @override
  String get signerUseBiometric => 'Use biometrics';

  @override
  String get signerBiometricReason => 'Unlock your Benny signer';

  @override
  String get signerBiometricFailed => 'Biometrics couldn\'t be changed.';

  @override
  String get signerRecheckTitle => 'Offline check';

  @override
  String get signerRecheckBody =>
      'The app was updated. Make sure this phone is fully offline again before you unlock it.';

  @override
  String get signerLockNow => 'Lock';

  @override
  String get signerOfflineChip => 'Offline signer';

  @override
  String get signerScanToSign => 'Scan to sign';

  @override
  String get signerPairWallet => 'Connect wallet';

  @override
  String get signerAccountsTitle => 'Accounts';

  @override
  String signerAccountName(int number) {
    return 'Account $number';
  }

  @override
  String get signerPairBody =>
      'In Benny Wallet on your other phone, choose Connect offline signer and scan this code.';

  @override
  String get signerPairPublicOnly =>
      'This code contains only public addresses, never your recovery phrase.';

  @override
  String get signerScanBody =>
      'Scan the QR code shown by Benny Wallet on your other phone.';

  @override
  String get signerScanWrongCode =>
      'This isn\'t a signing request from Benny Wallet.';

  @override
  String get signerScanAgain => 'Scan again';

  @override
  String get signerRejectUnknownAccount =>
      'This request is for an account that isn\'t on this signer.';

  @override
  String get signerRejectNotASigner =>
      'This account doesn\'t need to sign this transaction.';

  @override
  String get signerRejectUnreadable =>
      'This transaction can\'t be read, so it won\'t be signed.';

  @override
  String get signerRejectMessageIsTransaction =>
      'This message is actually a transaction, so it won\'t be signed.';

  @override
  String get signerRejectInvalidCode =>
      'This QR code isn\'t a valid signing request.';

  @override
  String get signerReviewTitle => 'Review and sign';

  @override
  String get signerReviewAccount => 'Signing account';

  @override
  String get signerReviewFee => 'Network fee';

  @override
  String get signerReviewMessage => 'Message';

  @override
  String signerBinaryMessage(int count) {
    return 'Binary data ($count bytes)';
  }

  @override
  String get signerThisAccount => 'this account';

  @override
  String signerActionSendSol(String amount) {
    return 'Send $amount SOL';
  }

  @override
  String signerActionSendToken(String amount, String symbol) {
    return 'Send $amount $symbol';
  }

  @override
  String signerActionSendUnverified(String amount) {
    return 'Send $amount of an unverified token';
  }

  @override
  String signerActionTo(String address) {
    return 'To $address';
  }

  @override
  String signerActionToTokenAccount(String address) {
    return 'To token account $address';
  }

  @override
  String signerActionMint(String mint) {
    return 'Token address $mint';
  }

  @override
  String signerActionOwner(String address) {
    return 'Owner $address';
  }

  @override
  String signerActionRentTo(String address) {
    return 'Rent returned to $address';
  }

  @override
  String get signerActionCreateTokenAccount => 'Create token account';

  @override
  String get signerActionCloseTokenAccount => 'Close token account';

  @override
  String get signerActionMemo => 'Memo';

  @override
  String get signerActionApprove =>
      'Allow another account to spend your tokens';

  @override
  String get signerActionSetAuthority => 'Change account authority';

  @override
  String get signerActionAssign => 'Change account owner';

  @override
  String get signerActionCreateAccount => 'Create account';

  @override
  String signerActionProgram(String program) {
    return 'Program $program';
  }

  @override
  String get signerHoldToSign => 'Hold to sign';

  @override
  String get signerReject => 'Reject';

  @override
  String get signerSignFailed => 'Signing failed. Try again.';

  @override
  String get signerSignatureTitle => 'Signature';

  @override
  String get signerSignatureBody =>
      'Scan this code with Benny Wallet on your other phone to finish.';

  @override
  String get signerSettingsTitle => 'Signer settings';

  @override
  String get signerAccountCount => 'Accounts shown';

  @override
  String get signerAccountCountHint =>
      'Up to 5 accounts from this recovery phrase';

  @override
  String get signerUpgradeTitle => 'Update the signer';

  @override
  String get signerUpgradeIntro =>
      'Updating the app needs a network, so plan it. Your recovery phrase stays encrypted on this phone while it is online, and the signer will not open it until the phone is offline again.';

  @override
  String get signerUpgradeStep0 => '1. Check your paper backup';

  @override
  String get signerUpgradeVerifyBackup => 'Check backup';

  @override
  String get signerUpgradeBackupOk => 'Backup checked';

  @override
  String get signerUpgradeOnlineTitle => '2a. Standard update';

  @override
  String get signerUpgradeOnlineBody =>
      'Lock the signer. Turn the network on and update Benny Wallet from the same store you installed it from. Turn airplane mode back on. The signer runs the offline check again before you can unlock it.';

  @override
  String get signerUpgradeSecureTitle => '2b. Most secure update';

  @override
  String get signerUpgradeSecureBody =>
      'Erase the signer in settings, then update the app online. Go offline again, set up the signer and import your recovery phrase. Your accounts and addresses stay the same.';

  @override
  String get signerUpgradeOfflineApkTitle =>
      'Android: update without going online';

  @override
  String get signerUpgradeOfflineApkBody =>
      'You can also copy the new APK to this phone by USB cable or SD card and install it while staying offline. Use an APK from the same source you installed from, otherwise it won\'t install over this one.';

  @override
  String get signerUpgradeCompatTitle => 'Older signers keep working';

  @override
  String get signerUpgradeCompatBody =>
      'A newer wallet app still works with an older signer. The wallet only asks for what this signer supports, so you can update when it suits you.';

  @override
  String get signerVersionTitle => 'Version';

  @override
  String signerVersionDetail(String app, int protocol, int tokens) {
    return 'App $app · protocol $protocol · token list $tokens';
  }

  @override
  String get signerEraseTitle => 'Erase signer';

  @override
  String get signerEraseSubtitle =>
      'Removes the recovery phrase from this phone';

  @override
  String get signerEraseBody =>
      'The recovery phrase will be deleted from this phone. Without your paper backup the funds can\'t be recovered.';

  @override
  String get signerEraseConfirm => 'Erase';

  @override
  String get signerEraseWrongPin => 'Wrong PIN. Nothing was erased.';

  @override
  String get airGapConnectTitle => 'Connect offline signer';

  @override
  String get airGapConnectBody =>
      'On your signer phone tap Connect wallet, then scan the code it shows.';

  @override
  String get airGapConnectInvalid => 'This isn\'t a signer pairing code.';

  @override
  String airGapConnectChoose(String device) {
    return 'Choose an account on $device';
  }

  @override
  String airGapConnectAccount(int number) {
    return 'Account $number';
  }

  @override
  String airGapConnectAccountAdded(int number) {
    return 'Account $number (already added)';
  }

  @override
  String get airGapConnectCompare =>
      'Check that the address matches the one shown on your signer.';

  @override
  String get airGapConnectScanAgain => 'Scan again';

  @override
  String get airGapSignTitle => 'Sign with your signer';

  @override
  String get airGapSignShowRequestAgain => 'Show the request again';

  @override
  String get airGapSignMayHaveExpired =>
      'This transaction may have expired. If sending fails, start again.';

  @override
  String get airGapSignWrongRequest =>
      'This signature belongs to a different request.';

  @override
  String get airGapSignInvalidCode =>
      'This isn\'t a signature from your signer.';

  @override
  String get airGapSignerOutdated =>
      'Your signer runs an older version. It still works; update it when convenient.';

  @override
  String get signerIntroSubtitle =>
      'Keep your keys on a phone that never goes online.';

  @override
  String get signerFinishSubtitle => 'Give this signer a name and set a PIN.';

  @override
  String signerQuizBody(int count) {
    return 'Pick the right word for $count positions. Use your paper backup.';
  }

  @override
  String signerQuizProgress(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String signerQuizQuestion(int position) {
    return 'Which is word #$position?';
  }

  @override
  String get signerQuizCorrect => 'Correct!';

  @override
  String get signerQuizWrong =>
      'That\'s not right. Check your paper; we picked new words to try again.';

  @override
  String get signerQuizShowWords => 'Show the words again';

  @override
  String get signerScanToSignSubtitle =>
      'Scan the request shown by your wallet';

  @override
  String get signerPairWalletSubtitle => 'Show a code for Benny Wallet to scan';

  @override
  String get signerWalletPhoneLabel => 'Benny Wallet';

  @override
  String get signerScanRefusedTitle => 'Can\'t sign this';

  @override
  String get airGapSignerLabel => 'Signer';

  @override
  String get airGapThisPhone => 'This phone';

  @override
  String get airGapConnectFound => 'Signer recognized';

  @override
  String get airGapSignNeedsSigner =>
      'This needs to be verified and signed by your signer';

  @override
  String get airGapSignStepShort1 => 'Signer scans';

  @override
  String get airGapSignStepShort2 => 'Scan signature';

  @override
  String airGapSignStep1Named(String device) {
    return 'Step 1: scan this code with “$device”';
  }

  @override
  String airGapSignStep1BodyNamed(String device) {
    return 'On “$device”, tap Scan to sign, check the details, then confirm.';
  }

  @override
  String airGapSignStep2Named(String device) {
    return 'Step 2: scan the signature from “$device”';
  }

  @override
  String airGapSignStep2BodyNamed(String device) {
    return 'After you confirm, “$device” shows a signature code. Scan it with this phone.';
  }

  @override
  String airGapSignScanSignatureNamed(String device) {
    return 'Next: scan signature from $device';
  }

  @override
  String signerActionSwapPair(String from, String to) {
    return 'Swap $from → $to';
  }

  @override
  String signerSwapPay(String amount) {
    return 'Pay $amount';
  }

  @override
  String signerSwapPayAtMost(String amount) {
    return 'Pay at most $amount';
  }

  @override
  String signerSwapReceive(String amount) {
    return 'Receive $amount';
  }

  @override
  String signerSwapReceiveAtLeast(String amount) {
    return 'Receive at least $amount';
  }

  @override
  String get signerSwapUnverifiedToken => 'Unverified token';

  @override
  String airGapSignTimeLeft(int seconds) {
    return '$seconds s left. If time runs out, a fresh code appears automatically.';
  }

  @override
  String get airGapSignRefreshing =>
      'Time is up. Getting a fresh quote and code…';

  @override
  String airGapSignRefreshed(String device) {
    return 'The last code expired, so here is a new one. Scan it again with “$device”.';
  }

  @override
  String get airGapSignRefreshFailed =>
      'Couldn\'t get a fresh code. Check your connection and try again.';

  @override
  String get airGapSignOldRequest =>
      'This signature is for the expired code. Scan the new code on your signer first.';

  @override
  String get scanHintRoleShows => 'Shows code';

  @override
  String get scanHintRoleScans => 'Scans';

  @override
  String signerTokenUnchecked(String symbol) {
    return '$symbol (unverified)';
  }

  @override
  String get signerReviewActions => 'Transaction';

  @override
  String get signerNewerWalletNotice =>
      'Your wallet app is newer than this signer. Update the signer when you can.';

  @override
  String get signerDangerBanner =>
      'High risk. Don\'t sign unless you started this yourself.';

  @override
  String get signerActionSwap => 'Swap';

  @override
  String get signerActionSwapDetail => 'Check the amounts in your wallet.';

  @override
  String get signerActionDangerDetail =>
      'Dangerous. If you\'re not sure, don\'t sign.';

  @override
  String get signerActionAdvanceNonce => 'Update transaction number';

  @override
  String get signerActionSyncNative => 'Update SOL balance';

  @override
  String get signerHoldLongHint => 'Check carefully, then hold for 3 seconds.';

  @override
  String signerTokenVerified(String token) {
    return '$token · Verified by Benny Wallet';
  }

  @override
  String signerTokenWalletProvided(String symbol) {
    return '$symbol · Not verified by Benny Wallet';
  }

  @override
  String signerSwapWalletQuote(String pay, String receive) {
    return 'Estimate: pay $pay, get about $receive';
  }

  @override
  String get signerActionUnknown => 'Unrecognized step';

  @override
  String signerActionCreateTokenAccountFor(String symbol) {
    return 'Open $symbol account';
  }

  @override
  String get signerUnresolvedAccounts =>
      'The signer can\'t see all of this transaction. Only sign if you just started it.';

  @override
  String get signerTokenNotVerified => 'Not verified by Benny Wallet';

  @override
  String get signerKindSwap => 'Swap';

  @override
  String get signerKindSend => 'Send';

  @override
  String signerAbout(String amount) {
    return 'About $amount';
  }

  @override
  String get signerAmountsFromWallet => 'Amounts come from the wallet';

  @override
  String get signerTrustSafe => 'All tokens verified by Benny Wallet';

  @override
  String get signerTrustCaution =>
      'One token is not verified by Benny Wallet. Be careful.';

  @override
  String get signerTrustDangerSwap =>
      'Neither token is verified by Benny Wallet. High risk.';

  @override
  String get signerTrustDangerSend =>
      'This token is not verified by Benny Wallet. High risk.';

  @override
  String get signerReviewOtherSteps => 'Other steps';

  @override
  String get signerPay => 'You pay';

  @override
  String get signerPayAtMost => 'You pay at most';

  @override
  String get signerGet => 'You get';

  @override
  String get signerGetAtLeast => 'You get at least';

  @override
  String get signerGetAbout => 'You get about';

  @override
  String get signerRecipient => 'Recipient';

  @override
  String get signerRecipientTokenAccount => 'Recipient token account';

  @override
  String get signerUsdFromWallet => 'USD values are the wallet\'s estimate';

  @override
  String signerActionCreateTokenAccountForRecipient(String symbol) {
    return 'Open $symbol account for the recipient';
  }

  @override
  String get signerCreateAccountSkipIfOpen =>
      '(First time costs about 0.002 SOL; skipped for free if already open)';

  @override
  String get signerCreateAccountNotOpen =>
      '(Not open yet; costs about 0.002 SOL)';

  @override
  String get signerAddressFromWallet =>
      'This address comes from the wallet. The signer can\'t check it.';

  @override
  String get signerSwapOutputUnchecked =>
      'Can\'t confirm the swapped tokens come to you.';

  @override
  String get signerExtraOutflow => 'This also sends funds to another address.';

  @override
  String signerHighFee(String amount) {
    return 'Very high network fee: $amount SOL';
  }

  @override
  String get signerDurableNonce =>
      'This signature never expires. It can be used later.';

  @override
  String get signerSwapFromWallet =>
      'Token or amount comes from the wallet and can\'t be checked.';

  @override
  String signerActionCloseTo(String address) {
    return 'Balance and rent go to $address';
  }

  @override
  String signerWalletNote(String name) {
    return 'Wallet note: $name';
  }

  @override
  String get signerReviewFeePayer => 'Fee paid by';

  @override
  String signerActionOwnerProgram(String program) {
    return 'Controlled by program $program';
  }

  @override
  String get signerSlippageAll => 'Slippage 100% or more: you may get nothing.';

  @override
  String get signerQuizTooManyWrong =>
      'Too many wrong answers. Enter your PIN to try again.';

  @override
  String get signerSignInTitle => 'Login request';

  @override
  String get signerKindSignIn => 'Sign in';

  @override
  String get signerSignInBenny => 'Sign in to Benny Wallet';

  @override
  String signerSignInOtherSite(String site) {
    return '“$site” asks you to sign in. Sign only if you started it.';
  }

  @override
  String get signerSignInExpired =>
      'This login request has expired. Check this phone\'s time, or start again in the wallet.';

  @override
  String get signerSignInOtherAccount =>
      'This login is for another account. Don\'t sign.';

  @override
  String get signerSignInWhat =>
      'Proves this account is yours, so Benny can show its balance, history and alerts.';

  @override
  String get signerSignInNoFunds => 'Moves no funds and costs no fee.';

  @override
  String get signerSignInShowText => 'Show original text';

  @override
  String get airGapSignInTitle => 'Sign in with your signer';

  @override
  String get airGapSignInWhy => 'Why sign this?';

  @override
  String get airGapSignInWhyBody =>
      'Benny needs to confirm this account is yours before it can load your balance, history and alerts. Usually you do this only once per wallet.';

  @override
  String get airGapSignInSafe =>
      'This is only a login. It moves no funds and costs no fee.';

  @override
  String airGapSignInSignerShows(String device) {
    return '“$device” will show “Sign in to Benny Wallet”.';
  }

  @override
  String airGapSignInSignerShowsText(String device) {
    return '“$device” will show English text starting with “Benny Wallet wants you to sign in”. That is this login. After updating the signer it shows “Sign in to Benny Wallet” instead.';
  }

  @override
  String get dappScanTitle => 'Connect a website';

  @override
  String get dappScanHint =>
      'Scan the WalletConnect QR code shown on the website';

  @override
  String get dappPasteLink => 'Paste link';

  @override
  String get dappScanNotWalletConnect => 'This is not a WalletConnect code';

  @override
  String get dappConnecting => 'Connecting…';

  @override
  String get dappPairFailed =>
      'Could not connect. Ask the website for a new QR code.';

  @override
  String get dappNotConfigured =>
      'Website connections are not available in this build.';

  @override
  String get dappProposalTitle => 'Connect to website';

  @override
  String dappProposalWants(String site) {
    return '$site wants to connect to your wallet';
  }

  @override
  String get dappProposalCanDo => 'The website will be able to:';

  @override
  String get dappProposalSeeAddress => 'See your wallet address';

  @override
  String get dappProposalRequestSign =>
      'Ask you to approve transactions and messages';

  @override
  String get dappProposalNoAutoFunds =>
      'It cannot move funds on its own. Every request needs your approval.';

  @override
  String get dappProposalWallet => 'Wallet';

  @override
  String get dappProposalNoEligibleWallet =>
      'None of your wallets can connect to websites yet. External wallets will be supported later.';

  @override
  String get dappProposalOnlySolana =>
      'Benny Wallet only supports Solana. This website asked for other networks.';

  @override
  String get dappProposalUnsupportedChain =>
      'This website asked for a Solana test network. Benny Wallet only supports Solana mainnet.';

  @override
  String get dappConnect => 'Connect';

  @override
  String get dappReject => 'Reject';

  @override
  String dappConnected(String site) {
    return 'Connected to $site';
  }

  @override
  String get dappSiteVerified => 'Verified';

  @override
  String get dappSiteUnknown => 'Unverified';

  @override
  String get dappSiteMismatch => 'Domain mismatch';

  @override
  String get dappSiteScam => 'Known scam';

  @override
  String get dappSitesTitle => 'Connected websites';

  @override
  String get dappSitesEmpty =>
      'No websites connected. Scan a WalletConnect QR code on a website to connect.';

  @override
  String get dappSitesDisconnect => 'Disconnect';

  @override
  String get dappSitesDisconnectAll => 'Disconnect all';

  @override
  String get dappSitesDisconnectAllConfirm =>
      'Disconnect every website from all wallets?';

  @override
  String dappSitesExpires(String date) {
    return 'Expires $date';
  }

  @override
  String dappSitesWallet(String name) {
    return 'Wallet: $name';
  }

  @override
  String dappSitesBanner(int count) {
    return 'Connected websites: $count';
  }

  @override
  String get dappRequestTitle => 'Signature request';

  @override
  String get dappRequestSignMessage => 'Sign a message';

  @override
  String dappRequestSignIn(String domain) {
    return 'Sign in to $domain';
  }

  @override
  String get dappRequestTransaction => 'Approve transaction';

  @override
  String dappRequestTransactions(int count) {
    return 'Approve $count transactions';
  }

  @override
  String get dappRequestSendNote => 'Benny Wallet sends it after you sign.';

  @override
  String get dappRequestBalanceChanges => 'Estimated balance changes';

  @override
  String get dappRequestNoBalanceChange =>
      'No balance change for this wallet besides the network fee';

  @override
  String get dappRequestNetworkFee => 'Network fee';

  @override
  String get dappRequestMessage => 'Message';

  @override
  String get dappRequestDetails => 'Details';

  @override
  String get dappRequestPrograms => 'Programs called';

  @override
  String get dappActionTitle => 'What this does';

  @override
  String get browserTitle => 'Browser';

  @override
  String get browserAddressHint => 'Enter an address, e.g. jup.ag';

  @override
  String get browserReload => 'Reload';

  @override
  String get browserHome => 'Home';

  @override
  String get browserHomeHint =>
      'Enter a website address. On the site, tap Connect wallet and choose Benny Wallet: no switching apps, no unlocking again.';

  @override
  String get browserNotConnected => 'Not connected';

  @override
  String browserConnectedAs(String wallet) {
    return 'Connected: $wallet';
  }

  @override
  String get browserInvalidUrl => 'Not a web address';

  @override
  String get browserOpen => 'Open';

  @override
  String get browserBookmarks => 'Bookmarks';

  @override
  String get browserBookmark => 'Bookmark';

  @override
  String get browserBookmarked => 'Bookmarked';

  @override
  String get browserBookmarkRemoved => 'Bookmark removed';

  @override
  String get browserBookmarkRemove => 'Remove';

  @override
  String get browserBookmarksEmpty =>
      'Open a page and tap the star in the address bar to save it. Bookmarks stay on this phone and are never synced.';

  @override
  String get browserBookmarksLocal => 'Saved only on this phone, never synced.';

  @override
  String get browserBack => 'Back';

  @override
  String get browserForward => 'Forward';

  @override
  String get browserCopyLink => 'Copy link';

  @override
  String get browserHomeTagline => 'Your gateway to Solana apps';

  @override
  String get browserBennyFeatures => 'Benny Apps';

  @override
  String get browserComingSoon => 'Coming soon';

  @override
  String get browserPopular => 'Recommended';

  @override
  String get browserYourSites => 'Connected sites';

  @override
  String get dappColdSwapNotice =>
      'This swap expires within about a minute and a cold wallet often cannot sign it in time. For swaps with a cold wallet, use Benny\'s built-in Swap: it refreshes the quote when it expires.';

  @override
  String get dappActionSwap => 'Swap';

  @override
  String get dappActionTransfer => 'Transfer';

  @override
  String get dappActionStake => 'Stake';

  @override
  String get dappActionLend => 'Lend or borrow';

  @override
  String get dappActionPerps => 'Futures trade';

  @override
  String get dappActionNft => 'NFT trade';

  @override
  String get dappActionOther => 'Other action';

  @override
  String dappActionVia(String protocol) {
    return 'via $protocol';
  }

  @override
  String get dappActionPay => 'You pay';

  @override
  String get dappActionReceive => 'You receive';

  @override
  String get dappActionUnknownHint =>
      'Benny cannot read what these programs do. Sign only if you just started this on the website yourself.';

  @override
  String dappActionUnknownPrograms(int count) {
    return 'Unknown programs ($count)';
  }

  @override
  String get dappActivityTitle => 'Connection history';

  @override
  String get dappActivityNote =>
      'Saved only on this phone. Never uploaded to the cloud or backed up. Records the website, the action and amounts only, not message contents or your personal details.';

  @override
  String get dappActivityEmpty => 'No website activity yet.';

  @override
  String get dappActivityClear => 'Clear activity';

  @override
  String get dappActivityClearConfirm =>
      'Clear all website activity on this phone?';

  @override
  String dappActivityCount(int count) {
    return '$count records';
  }

  @override
  String get dappActivityConnected => 'Connected';

  @override
  String get dappActivityConnectRejected => 'Connection declined';

  @override
  String get dappActivityMessage => 'Message signature';

  @override
  String get dappActivitySigned => 'Signed';

  @override
  String get dappActivitySent => 'Sent';

  @override
  String get dappActivityRejected => 'Declined';

  @override
  String get dappActivityFailed => 'Failed';

  @override
  String get dappActivityViewTx => 'View on Solscan';

  @override
  String get dappActivityViaPhone => 'App on this phone';

  @override
  String get dappActivityInBrowser => 'Benny\'s browser';

  @override
  String dappActivityWallet(String wallet) {
    return 'Wallet $wallet';
  }

  @override
  String get dappActivityDisconnected => 'Disconnected';

  @override
  String dappSitesLastUsed(String date) {
    return 'Last used $date';
  }

  @override
  String get dappActivityDetail => 'Details';

  @override
  String get dappActivitySite => 'Website';

  @override
  String get dappActivityTime => 'Time';

  @override
  String get dappActivityVia => 'Connected through';

  @override
  String get dappActivityViaWalletConnect => 'Scanned QR code (WalletConnect)';

  @override
  String get dappActivityWalletLabel => 'Wallet';

  @override
  String get dappActivityTxId => 'Transaction ID';

  @override
  String get dappActivityCopied => 'Copied';

  @override
  String get dappActivityResult => 'Result';

  @override
  String get dappRequestSigningWallet => 'Signing wallet';

  @override
  String get dappRequestLoading => 'Checking request…';

  @override
  String get dappRequestInvalid =>
      'This request could not be read and was rejected.';

  @override
  String get dappRequestSign => 'Sign';

  @override
  String get dappRequestHoldToSign => 'Hold to sign';

  @override
  String get dappRequestAcceptRisk =>
      'I understand the risk and still want to sign';

  @override
  String get dappRequestBlocked =>
      'Benny Wallet blocked this request to protect your funds.';

  @override
  String get dappRequestDone => 'Signed. Go back to the website.';

  @override
  String get dappRequestSent => 'Sent. Go back to the website.';

  @override
  String dappRequestFailed(String error) {
    return 'Signing failed: $error';
  }

  @override
  String get dappRequestRejected => 'Request rejected';

  @override
  String get dappAuthReason => 'Confirm the signature';

  @override
  String get dappPinTitle => 'Enter PIN to sign';

  @override
  String get dappTrustSafe => 'Looks normal';

  @override
  String get dappTrustCaution => 'Check carefully';

  @override
  String get dappTrustDanger => 'High risk';

  @override
  String get dappTrustBlocked => 'Blocked';

  @override
  String get dappWarnSiteScam => 'This website is a known scam.';

  @override
  String get dappWarnSiteMismatch =>
      'The website\'s address does not match the app it claims to be.';

  @override
  String get dappWarnSiteUnknown => 'This website could not be verified.';

  @override
  String get dappWarnMessageUnreadable =>
      'The message is not readable text, so you cannot tell what you are signing.';

  @override
  String get dappWarnMessageIsTransaction =>
      'This message is really a transaction. Signing it could move your funds.';

  @override
  String get dappWarnSignInOtherSite =>
      'The sign-in is for a different website than the one asking.';

  @override
  String get dappWarnSignInOtherAccount =>
      'The sign-in is for a different wallet.';

  @override
  String get dappWarnSignInExpired => 'This sign-in request has expired.';

  @override
  String get dappWarnTokenApprove =>
      'Gives another account permission to spend your tokens.';

  @override
  String get dappWarnSetAuthority =>
      'Hands control of one of your accounts to someone else.';

  @override
  String get dappWarnAssignAccount =>
      'Changes the owner of your wallet account.';

  @override
  String get dappWarnCloseAccount => 'Closes a token account.';

  @override
  String get dappWarnAdvanceNonce =>
      'Uses a durable nonce, so the signature stays valid until it is used.';

  @override
  String get dappWarnUnknownProgram =>
      'Calls a program Benny Wallet does not recognise.';

  @override
  String get dappWarnBlockedProgram =>
      'Calls a program on Benny Wallet\'s blocklist. It cannot be signed.';

  @override
  String get dappWarnUnresolvedAccounts =>
      'Some accounts could not be looked up.';

  @override
  String get dappWarnSimulationFailed => 'The transaction fails in simulation.';

  @override
  String get dappWarnSimulationUnavailable =>
      'The balance changes could not be estimated.';

  @override
  String get dappWarnHighSlippage => 'Allows a swap that could return nothing.';

  @override
  String dappRequestQueued(int count) {
    return '$count more requests waiting';
  }

  @override
  String airGapSignFromSite(String site) {
    return 'This request comes from the website $site. The signer shows the site too.';
  }

  @override
  String airGapSignFromSiteStep(String site, int current, int total) {
    return 'From the website $site: transaction $current of $total';
  }

  @override
  String get airGapSignerNoSiteSupport =>
      'Your signer is an older version and cannot show which website this came from. Update the signer when you can.';

  @override
  String signerDappSource(String site) {
    return 'From the website $site (passed on by the wallet)';
  }

  @override
  String get signerDappSiteVerified => 'The wallet verified this website.';

  @override
  String get signerDappSiteUnverified =>
      'The wallet could not verify this website.';

  @override
  String get signerDappSiteMismatch =>
      'The website\'s address does not match what it claims to be. It may be a fake site.';

  @override
  String get signerDappSiteScam => 'This is a known scam website. Do not sign.';

  @override
  String get signerDappSourceHint =>
      'Only sign if you just did this on that website yourself.';

  @override
  String signerDappUnknownStep(String program) {
    return 'The signer cannot read this step (program $program). Only sign if you just did this on the website yourself.';
  }

  @override
  String get signerDappSimulation => 'Balance changes simulated by the wallet';

  @override
  String get signerDappSimulationNone =>
      'No balance change besides the network fee';

  @override
  String get signerDappSimulationNote =>
      'Simulated by the wallet. The signer cannot check this; use it only as a reference.';

  @override
  String airGapSignSiteTimeLeft(String time) {
    return 'The website waits $time more';
  }

  @override
  String get airGapSignSiteExpired =>
      'The website\'s request has probably expired. Close this and start again on the website.';
}
