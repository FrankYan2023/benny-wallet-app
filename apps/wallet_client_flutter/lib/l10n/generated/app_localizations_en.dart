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
}
