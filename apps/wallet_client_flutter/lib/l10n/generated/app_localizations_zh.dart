// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Benny Wallet';

  @override
  String get brandShortName => 'Benny';

  @override
  String get commonBack => '返回';

  @override
  String get commonCancel => '取消';

  @override
  String get commonClose => '關閉';

  @override
  String get commonContinue => '繼續';

  @override
  String get commonConfirm => '確認';

  @override
  String get commonCopied => '已複製';

  @override
  String get commonCopy => '複製';

  @override
  String get commonDone => '完成';

  @override
  String get commonLater => '稍後';

  @override
  String get commonLoading => '載入中...';

  @override
  String get commonMax => '最大';

  @override
  String get commonNext => '下一步';

  @override
  String get commonOk => '好';

  @override
  String get commonRetry => '重試';

  @override
  String get commonSettings => '設定';

  @override
  String get commonShare => '分享';

  @override
  String get commonUpdate => '更新';

  @override
  String get languageSystem => '系統';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageTraditionalChinese => '繁體中文';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageKorean => '한국어';

  @override
  String get settingsTitle => 'Benny';

  @override
  String get settingsLanguage => '語言';

  @override
  String get settingsLanguageSubtitle => '選擇 App 語言';

  @override
  String get settingsLanguageSystemDescription => '跟隨此裝置';

  @override
  String get settingsLanguageSheetTitle => '語言';

  @override
  String get settingsLanguageSheetSubtitle => '選擇 Benny 使用的語言。';

  @override
  String get settingsBiometricUnlock => '生物辨識解鎖';

  @override
  String get settingsUseFingerprint => '使用指紋';

  @override
  String get settingsUnlockWalletToEnable => '先解鎖錢包才能啟用';

  @override
  String get settingsAutoLock => '自動鎖定';

  @override
  String get settingsAutoLockSheetSubtitle => '選擇 Benny 何時再次鎖定。';

  @override
  String get settingsNotifications => '接收通知';

  @override
  String get settingsNotificationsSubtitle => '資金入帳時收到提醒';

  @override
  String get settingsChildMode => '兒童模式';

  @override
  String get settingsChildModeActive => '兒童模式已啟用';

  @override
  String get settingsChildModeActiveDescription =>
      '錢包會保持僅接收模式，直到輸入 4 位數兒童模式 PIN。';

  @override
  String get settingsChildModeProtected => '受 4 位數兒童模式 PIN 保護';

  @override
  String get settingsChildModeRemoveAccounts => '啟用前請先移除所有子帳戶';

  @override
  String get settingsChildModeSetPin => '為兒童模式設定獨立的 4 位數 PIN';

  @override
  String get settingsChildAccounts => '子帳戶';

  @override
  String get settingsRentReclaim => '租金回收';

  @override
  String get settingsRentReclaimSubtitle => '關閉空的代幣帳戶並取回 SOL';

  @override
  String get settingsFeedback => '意見回饋';

  @override
  String get settingsFeedbackSubtitle => '回報問題或提出疑問';

  @override
  String get settingsLogOut => '登出';

  @override
  String get settingsLogOutSubtitle => '返回首頁';

  @override
  String get settingsIncorrectPin => 'PIN 不正確';

  @override
  String get settingsPersistentBiometricUnsupported => '此裝置不支援持續性生物辨識解鎖。';

  @override
  String get settingsBiometricsUnavailable => '此裝置無法使用生物辨識。';

  @override
  String get settingsBiometricEnabled => '已啟用生物辨識';

  @override
  String get settingsBiometricDisabled => '已停用生物辨識';

  @override
  String get settingsUnlockBeforeBiometrics => '請先解鎖錢包，再啟用生物辨識。';

  @override
  String get settingsNotificationsSystemDisabled => '通知已停用。請到系統設定中啟用。';

  @override
  String get settingsNotificationsEnabled => '已啟用接收通知';

  @override
  String get settingsNotificationsDisabled => '已停用接收通知';

  @override
  String settingsNotificationsUpdateFailed(String error) {
    return '更新通知設定失敗：$error';
  }

  @override
  String get settingsRemoveChildAccountsFirst => '啟用兒童模式前，請先移除所有子帳戶。';

  @override
  String get settingsChildModeEnabled => '已啟用兒童模式';

  @override
  String get settingsChildModeDisabled => '已停用兒童模式';

  @override
  String settingsChildModeUpdateFailed(String error) {
    return '更新兒童模式失敗：$error';
  }

  @override
  String get settingsCopyRecoveryPhraseFirst => '請先複製你的復原助記詞。';

  @override
  String get settingsLogOutWarning => '登出會清除此裝置上的所有本機 App 資料。';

  @override
  String get settingsWalletUpToDate => 'Benny Wallet 已是最新版本。';

  @override
  String get settingsUpdateCheckFailed => '檢查更新失敗';

  @override
  String get settingsUnableToCheckUpdates => '目前無法檢查更新。';

  @override
  String get settingsSeedPhraseBackup => '備份助記詞';

  @override
  String get settingsSeedPhraseBackupDescription => '建議製作實體副本，並存放在安全位置。';

  @override
  String get settingsSecureNow => '立即保護';

  @override
  String get settingsCheckingUpdates => '檢查中...';

  @override
  String get settingsCheckForUpdates => '檢查更新';

  @override
  String settingsVersion(String version) {
    return '版本 $version';
  }

  @override
  String settingsVersionBuild(String version, String buildNumber) {
    return '版本 $version+$buildNumber';
  }

  @override
  String get autoLockImmediate => '立即';

  @override
  String get autoLockOneMinute => '1 分鐘';

  @override
  String get autoLockFiveMinutes => '5 分鐘';

  @override
  String get autoLockTenMinutes => '10 分鐘';

  @override
  String get autoLockThirtyMinutes => '30 分鐘';

  @override
  String get biometricUnlockReason => '使用生物辨識解鎖 Benny Wallet。';

  @override
  String get biometricSetupReason => '請使用生物辨識驗證，以啟用此安全功能。';

  @override
  String get unlockFailedTitle => '解鎖失敗';

  @override
  String get unlockIncorrectPin => 'PIN 不正確。';

  @override
  String get unlockBiometricCancelled => '生物辨識已取消';

  @override
  String get unlockBiometricFailed => '生物辨識解鎖失敗。請再試一次。';

  @override
  String get unlockSessionExpired => '工作階段已過期，請使用 PIN';

  @override
  String get unlockBiometricUnavailable => '生物辨識無法使用';

  @override
  String get unlockUseFingerprint => '使用指紋';

  @override
  String get unlockEnterPin => '輸入 PIN';

  @override
  String get pinConfirm => '確認 PIN';

  @override
  String get pinSet => '設定 Benny PIN';

  @override
  String get pinMismatch => 'PIN 不相符';

  @override
  String get pinImportFailed => '匯入失敗';

  @override
  String get pinExternalWalletSetupDescription =>
      '這會保護 Benny 設定和子帳戶。Seeker 會將簽名金鑰保存在 Seeker Wallet。';

  @override
  String get childModeConfirmPinTitle => '確認兒童模式 PIN';

  @override
  String get childModeSetPinTitle => '設定兒童模式 PIN';

  @override
  String get childModeEnterPinTitle => '輸入兒童模式 PIN';

  @override
  String get childModeConfirmPinSubtitle => '再次輸入僅用於兒童模式的 4 位數 PIN。';

  @override
  String get childModeSetPinSubtitle => '建立僅用於兒童模式的 4 位數 PIN。';

  @override
  String get childModeEnterPinSubtitle => '輸入僅用於兒童模式的 4 位數 PIN 以關閉此模式。';

  @override
  String get childModeOnlyUsed => '僅用於兒童模式';

  @override
  String get welcomeReplaceWalletTitle => '取代目前錢包';

  @override
  String get welcomeReplaceWalletMessage => '繼續會刪除目前錢包。';

  @override
  String get welcomeConfirmAgainTitle => '再次確認';

  @override
  String get welcomeConfirmAgainMessage => '刪除後你可能會失去助記詞存取權。請先妥善保存。';

  @override
  String get welcomeNewWalletSubtitle => '建立新的預設錢包';

  @override
  String get welcomeImportWalletSubtitleSeeker => '助記詞或 Seeker Vault';

  @override
  String get welcomeImportWalletSubtitlePhrase => '從復原助記詞還原';

  @override
  String get welcomeHeroSemantics => 'Benny Wallet';

  @override
  String get welcomeHeroPrelude => '新的錢包來了。';

  @override
  String get welcomeHeroTitle => 'Benny Wallet';

  @override
  String get welcomeHeroSubtitle => '從零開始，或還原你的復原助記詞。';

  @override
  String get welcomeNewWallet => '新錢包';

  @override
  String get welcomeImportWallet => '匯入錢包';

  @override
  String get createWalletTitle => '建立錢包';

  @override
  String get createWalletRecoveryTitle => '請寫下你的復原助記詞。';

  @override
  String get createWalletRecoverySubtitle => '這是復原錢包的唯一方式。';

  @override
  String get webTestingOnly => 'Web 版本僅供測試。';

  @override
  String get recoveryPhraseCopied => '復原助記詞已複製（15 秒後清除）';

  @override
  String get copyPhrase => '複製助記詞';

  @override
  String get importWalletTitle => '匯入錢包';

  @override
  String get importRecoveryPhraseTitle => '匯入復原助記詞';

  @override
  String get importRecoveryPhraseSubtitle => '使用 12 或 24 個英文單字。';

  @override
  String get importPasteHint => '在此貼上你的復原助記詞';

  @override
  String get importInvalidPhrase => '復原助記詞無效';

  @override
  String get importEnterWords => '輸入或貼上 12 或 24 個單字。';

  @override
  String importWordsDetected(int count) {
    return '偵測到 $count 個單字';
  }

  @override
  String get importClear => '清除';

  @override
  String get seekerVaultConnectDescription => '連接此 Seeker 上由硬體保護的錢包。';

  @override
  String get seekerVaultConnect => '連接';

  @override
  String get seekerVaultInstallOrEnable => '請安裝或啟用 Seeker Wallet，然後再試一次。';

  @override
  String get seekerVaultAndroidOnly => 'Seeker Vault 匯入僅可在 Android 使用。';

  @override
  String get seekerVaultNoAccounts => '此種子未返回任何現有 Seed Vault 錢包帳戶。';

  @override
  String get seekerVaultUnavailable => '此裝置無法使用 Seed Vault。';

  @override
  String get seekerVaultCancelled => 'Seeker Vault 連線已取消。';

  @override
  String get seekerVaultConnectFailed => '目前無法連接 Seeker Vault。請再試一次。';

  @override
  String get receiveTitle => '接收';

  @override
  String get receivedHistoryTitle => '接收記錄';

  @override
  String get receiveShareAddressTitle => '分享此地址';

  @override
  String get receiveShareAddressSubtitle => '掃描或複製。';

  @override
  String get receiveNoAddress => '沒有可用的錢包地址';

  @override
  String get receiveNoAddressSubtitle => '建立或解鎖錢包以接收資金。';

  @override
  String get receiveAddressCopied => '地址已複製（60 秒後清除）';

  @override
  String get receiveCopyAddress => '複製地址';

  @override
  String get sendTitle => '傳送';

  @override
  String get sendChooseAssetTitle => '選擇資產';

  @override
  String get sendHistoryTitle => '傳送記錄';

  @override
  String get sendUnavailableChildMode => '兒童模式下無法傳送。';

  @override
  String get sendOpenReceive => '開啟接收';

  @override
  String get sendNoAssets => '沒有可傳送的資產。';

  @override
  String get sendRecipientPrefilled => '已預填接收者';

  @override
  String sendLoadAssetsFailed(String error) {
    return '載入資產失敗：$error';
  }

  @override
  String get sendAssetNotFound => '找不到資產。';

  @override
  String sendAssetTitle(String symbol) {
    return '傳送 $symbol';
  }

  @override
  String get sendScanQrCode => '掃描 QR 碼';

  @override
  String get sendRecipientAddressHint => '接收者 Solana 地址';

  @override
  String sendAvailableAmount(String amount, String symbol) {
    return '可用 $amount $symbol';
  }

  @override
  String sendLoadFormFailed(String error) {
    return '載入傳送表單失敗：$error';
  }

  @override
  String get sendInvalidAddress => '請輸入有效的 Solana 地址。';

  @override
  String get sendInvalidAmount => '請輸入有效金額。';

  @override
  String get sendInsufficientBalance => '餘額不足。';

  @override
  String get sendUnlockAgain => '傳送前請再次解鎖錢包。';

  @override
  String get sendNotEnoughSolAfterFee => '預留網路費後 SOL 不足。';

  @override
  String get sendNotEnoughSolForFee => 'SOL 不足以支付網路費。';

  @override
  String get sendGenericFailure => '傳送失敗。請再試一次。';

  @override
  String get sendAmountHint => '金額';

  @override
  String get portfolioChildAccounts => '子帳戶';

  @override
  String get portfolioCrypto => '加密貨幣';

  @override
  String get portfolioStocks => '股票';

  @override
  String get portfolioMessages => '訊息';

  @override
  String get portfolioTokens => '代幣';

  @override
  String get portfolioDefi => 'DeFi';

  @override
  String get portfolioSend => '傳送';

  @override
  String get portfolioSwap => '兌換';

  @override
  String get portfolioReceive => '接收';

  @override
  String get portfolioCouldNotRefreshAssets => '無法重新整理資產';

  @override
  String get portfolioPullToRetry => '下拉以再試一次。';

  @override
  String get portfolioDefiParentOnly => 'DeFi 僅限家長模式';

  @override
  String get portfolioDefiParentOnlyMessage => '切回家長模式以查看協議持倉。';

  @override
  String get portfolioDefiUnavailable => 'DeFi 資料暫時無法使用';

  @override
  String get portfolioDefiUnavailableMessage => '代幣資料仍為最新。';

  @override
  String get portfolioNoDefi => '尚無 DeFi 持倉';

  @override
  String get portfolioRefreshingDefi => '正在重新整理協議持倉...';

  @override
  String get portfolioNoActiveDefi => '你的錢包沒有有效的 DeFi 持倉。';

  @override
  String get portfolioRefreshFailed => '重新整理失敗';

  @override
  String get portfolioNetworkBusy => '網路目前繁忙。請下拉再試一次。';

  @override
  String get portfolioServerUnavailable => '無法連線到伺服器。請檢查連線並下拉再試一次。';

  @override
  String get portfolioRefreshAssetsFailed => '無法重新整理資產。請下拉再試一次。';

  @override
  String get portfolioReceiveSol => '接收 SOL';

  @override
  String get portfolioReceiveSolSubtitle => '接收 SOL，開始使用 Benny Wallet。';

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
  String get updateFailedTitle => '更新失敗';

  @override
  String get updateUnableToOpen => '目前無法開啟 Benny Wallet 更新連結。';

  @override
  String get routerFeatureUnavailableTitle => '功能無法使用';

  @override
  String get routerFeatureUnavailableMessage => '此版本無法使用此功能。';

  @override
  String get routerMessageUnavailableTitle => '訊息無法使用';

  @override
  String get routerMessageUnavailableMessage => '請先從訊息清單開啟接收訊息。';

  @override
  String get routerSendDetailsUnavailableTitle => '傳送詳細資料無法使用';

  @override
  String get routerSendDetailsUnavailableMessage => '請先從傳送記錄開啟交易。';

  @override
  String get routerInvalidChildWalletId => '子錢包 ID 無效';

  @override
  String routerRouteNotFound(String uri) {
    return '找不到路由：$uri';
  }
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get appTitle => 'Benny Wallet';

  @override
  String get brandShortName => 'Benny';

  @override
  String get commonBack => '返回';

  @override
  String get commonCancel => '取消';

  @override
  String get commonClose => '關閉';

  @override
  String get commonContinue => '繼續';

  @override
  String get commonConfirm => '確認';

  @override
  String get commonCopied => '已複製';

  @override
  String get commonCopy => '複製';

  @override
  String get commonDone => '完成';

  @override
  String get commonLater => '稍後';

  @override
  String get commonLoading => '載入中...';

  @override
  String get commonMax => '最大';

  @override
  String get commonNext => '下一步';

  @override
  String get commonOk => '好';

  @override
  String get commonRetry => '重試';

  @override
  String get commonSettings => '設定';

  @override
  String get commonShare => '分享';

  @override
  String get commonUpdate => '更新';

  @override
  String get languageSystem => '系統';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageTraditionalChinese => '繁體中文';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageKorean => '한국어';

  @override
  String get settingsTitle => 'Benny';

  @override
  String get settingsLanguage => '語言';

  @override
  String get settingsLanguageSubtitle => '選擇 App 語言';

  @override
  String get settingsLanguageSystemDescription => '跟隨此裝置';

  @override
  String get settingsLanguageSheetTitle => '語言';

  @override
  String get settingsLanguageSheetSubtitle => '選擇 Benny 使用的語言。';

  @override
  String get settingsBiometricUnlock => '生物辨識解鎖';

  @override
  String get settingsUseFingerprint => '使用指紋';

  @override
  String get settingsUnlockWalletToEnable => '先解鎖錢包才能啟用';

  @override
  String get settingsAutoLock => '自動鎖定';

  @override
  String get settingsAutoLockSheetSubtitle => '選擇 Benny 何時再次鎖定。';

  @override
  String get settingsNotifications => '接收通知';

  @override
  String get settingsNotificationsSubtitle => '資金入帳時收到提醒';

  @override
  String get settingsChildMode => '兒童模式';

  @override
  String get settingsChildModeActive => '兒童模式已啟用';

  @override
  String get settingsChildModeActiveDescription =>
      '錢包會保持僅接收模式，直到輸入 4 位數兒童模式 PIN。';

  @override
  String get settingsChildModeProtected => '受 4 位數兒童模式 PIN 保護';

  @override
  String get settingsChildModeRemoveAccounts => '啟用前請先移除所有子帳戶';

  @override
  String get settingsChildModeSetPin => '為兒童模式設定獨立的 4 位數 PIN';

  @override
  String get settingsChildAccounts => '子帳戶';

  @override
  String get settingsRentReclaim => '租金回收';

  @override
  String get settingsRentReclaimSubtitle => '關閉空的代幣帳戶並取回 SOL';

  @override
  String get settingsFeedback => '意見回饋';

  @override
  String get settingsFeedbackSubtitle => '回報問題或提出疑問';

  @override
  String get settingsLogOut => '登出';

  @override
  String get settingsLogOutSubtitle => '返回首頁';

  @override
  String get settingsIncorrectPin => 'PIN 不正確';

  @override
  String get settingsPersistentBiometricUnsupported => '此裝置不支援持續性生物辨識解鎖。';

  @override
  String get settingsBiometricsUnavailable => '此裝置無法使用生物辨識。';

  @override
  String get settingsBiometricEnabled => '已啟用生物辨識';

  @override
  String get settingsBiometricDisabled => '已停用生物辨識';

  @override
  String get settingsUnlockBeforeBiometrics => '請先解鎖錢包，再啟用生物辨識。';

  @override
  String get settingsNotificationsSystemDisabled => '通知已停用。請到系統設定中啟用。';

  @override
  String get settingsNotificationsEnabled => '已啟用接收通知';

  @override
  String get settingsNotificationsDisabled => '已停用接收通知';

  @override
  String settingsNotificationsUpdateFailed(String error) {
    return '更新通知設定失敗：$error';
  }

  @override
  String get settingsRemoveChildAccountsFirst => '啟用兒童模式前，請先移除所有子帳戶。';

  @override
  String get settingsChildModeEnabled => '已啟用兒童模式';

  @override
  String get settingsChildModeDisabled => '已停用兒童模式';

  @override
  String settingsChildModeUpdateFailed(String error) {
    return '更新兒童模式失敗：$error';
  }

  @override
  String get settingsCopyRecoveryPhraseFirst => '請先複製你的復原助記詞。';

  @override
  String get settingsLogOutWarning => '登出會清除此裝置上的所有本機 App 資料。';

  @override
  String get settingsWalletUpToDate => 'Benny Wallet 已是最新版本。';

  @override
  String get settingsUpdateCheckFailed => '檢查更新失敗';

  @override
  String get settingsUnableToCheckUpdates => '目前無法檢查更新。';

  @override
  String get settingsSeedPhraseBackup => '備份助記詞';

  @override
  String get settingsSeedPhraseBackupDescription => '建議製作實體副本，並存放在安全位置。';

  @override
  String get settingsSecureNow => '立即保護';

  @override
  String get settingsCheckingUpdates => '檢查中...';

  @override
  String get settingsCheckForUpdates => '檢查更新';

  @override
  String settingsVersion(String version) {
    return '版本 $version';
  }

  @override
  String settingsVersionBuild(String version, String buildNumber) {
    return '版本 $version+$buildNumber';
  }

  @override
  String get autoLockImmediate => '立即';

  @override
  String get autoLockOneMinute => '1 分鐘';

  @override
  String get autoLockFiveMinutes => '5 分鐘';

  @override
  String get autoLockTenMinutes => '10 分鐘';

  @override
  String get autoLockThirtyMinutes => '30 分鐘';

  @override
  String get biometricUnlockReason => '使用生物辨識解鎖 Benny Wallet。';

  @override
  String get biometricSetupReason => '請使用生物辨識驗證，以啟用此安全功能。';

  @override
  String get unlockFailedTitle => '解鎖失敗';

  @override
  String get unlockIncorrectPin => 'PIN 不正確。';

  @override
  String get unlockBiometricCancelled => '生物辨識已取消';

  @override
  String get unlockBiometricFailed => '生物辨識解鎖失敗。請再試一次。';

  @override
  String get unlockSessionExpired => '工作階段已過期，請使用 PIN';

  @override
  String get unlockBiometricUnavailable => '生物辨識無法使用';

  @override
  String get unlockUseFingerprint => '使用指紋';

  @override
  String get unlockEnterPin => '輸入 PIN';

  @override
  String get pinConfirm => '確認 PIN';

  @override
  String get pinSet => '設定 Benny PIN';

  @override
  String get pinMismatch => 'PIN 不相符';

  @override
  String get pinImportFailed => '匯入失敗';

  @override
  String get pinExternalWalletSetupDescription =>
      '這會保護 Benny 設定和子帳戶。Seeker 會將簽名金鑰保存在 Seeker Wallet。';

  @override
  String get childModeConfirmPinTitle => '確認兒童模式 PIN';

  @override
  String get childModeSetPinTitle => '設定兒童模式 PIN';

  @override
  String get childModeEnterPinTitle => '輸入兒童模式 PIN';

  @override
  String get childModeConfirmPinSubtitle => '再次輸入僅用於兒童模式的 4 位數 PIN。';

  @override
  String get childModeSetPinSubtitle => '建立僅用於兒童模式的 4 位數 PIN。';

  @override
  String get childModeEnterPinSubtitle => '輸入僅用於兒童模式的 4 位數 PIN 以關閉此模式。';

  @override
  String get childModeOnlyUsed => '僅用於兒童模式';

  @override
  String get welcomeReplaceWalletTitle => '取代目前錢包';

  @override
  String get welcomeReplaceWalletMessage => '繼續會刪除目前錢包。';

  @override
  String get welcomeConfirmAgainTitle => '再次確認';

  @override
  String get welcomeConfirmAgainMessage => '刪除後你可能會失去助記詞存取權。請先妥善保存。';

  @override
  String get welcomeNewWalletSubtitle => '建立新的預設錢包';

  @override
  String get welcomeImportWalletSubtitleSeeker => '助記詞或 Seeker Vault';

  @override
  String get welcomeImportWalletSubtitlePhrase => '從復原助記詞還原';

  @override
  String get welcomeHeroSemantics => 'Benny Wallet';

  @override
  String get welcomeHeroPrelude => '新的錢包來了。';

  @override
  String get welcomeHeroTitle => 'Benny Wallet';

  @override
  String get welcomeHeroSubtitle => '從零開始，或還原你的復原助記詞。';

  @override
  String get welcomeNewWallet => '新錢包';

  @override
  String get welcomeImportWallet => '匯入錢包';

  @override
  String get createWalletTitle => '建立錢包';

  @override
  String get createWalletRecoveryTitle => '請寫下你的復原助記詞。';

  @override
  String get createWalletRecoverySubtitle => '這是復原錢包的唯一方式。';

  @override
  String get webTestingOnly => 'Web 版本僅供測試。';

  @override
  String get recoveryPhraseCopied => '復原助記詞已複製（15 秒後清除）';

  @override
  String get copyPhrase => '複製助記詞';

  @override
  String get importWalletTitle => '匯入錢包';

  @override
  String get importRecoveryPhraseTitle => '匯入復原助記詞';

  @override
  String get importRecoveryPhraseSubtitle => '使用 12 或 24 個英文單字。';

  @override
  String get importPasteHint => '在此貼上你的復原助記詞';

  @override
  String get importInvalidPhrase => '復原助記詞無效';

  @override
  String get importEnterWords => '輸入或貼上 12 或 24 個單字。';

  @override
  String importWordsDetected(int count) {
    return '偵測到 $count 個單字';
  }

  @override
  String get importClear => '清除';

  @override
  String get seekerVaultConnectDescription => '連接此 Seeker 上由硬體保護的錢包。';

  @override
  String get seekerVaultConnect => '連接';

  @override
  String get seekerVaultInstallOrEnable => '請安裝或啟用 Seeker Wallet，然後再試一次。';

  @override
  String get seekerVaultAndroidOnly => 'Seeker Vault 匯入僅可在 Android 使用。';

  @override
  String get seekerVaultNoAccounts => '此種子未返回任何現有 Seed Vault 錢包帳戶。';

  @override
  String get seekerVaultUnavailable => '此裝置無法使用 Seed Vault。';

  @override
  String get seekerVaultCancelled => 'Seeker Vault 連線已取消。';

  @override
  String get seekerVaultConnectFailed => '目前無法連接 Seeker Vault。請再試一次。';

  @override
  String get receiveTitle => '接收';

  @override
  String get receivedHistoryTitle => '接收記錄';

  @override
  String get receiveShareAddressTitle => '分享此地址';

  @override
  String get receiveShareAddressSubtitle => '掃描或複製。';

  @override
  String get receiveNoAddress => '沒有可用的錢包地址';

  @override
  String get receiveNoAddressSubtitle => '建立或解鎖錢包以接收資金。';

  @override
  String get receiveAddressCopied => '地址已複製（60 秒後清除）';

  @override
  String get receiveCopyAddress => '複製地址';

  @override
  String get sendTitle => '傳送';

  @override
  String get sendChooseAssetTitle => '選擇資產';

  @override
  String get sendHistoryTitle => '傳送記錄';

  @override
  String get sendUnavailableChildMode => '兒童模式下無法傳送。';

  @override
  String get sendOpenReceive => '開啟接收';

  @override
  String get sendNoAssets => '沒有可傳送的資產。';

  @override
  String get sendRecipientPrefilled => '已預填接收者';

  @override
  String sendLoadAssetsFailed(String error) {
    return '載入資產失敗：$error';
  }

  @override
  String get sendAssetNotFound => '找不到資產。';

  @override
  String sendAssetTitle(String symbol) {
    return '傳送 $symbol';
  }

  @override
  String get sendScanQrCode => '掃描 QR 碼';

  @override
  String get sendRecipientAddressHint => '接收者 Solana 地址';

  @override
  String sendAvailableAmount(String amount, String symbol) {
    return '可用 $amount $symbol';
  }

  @override
  String sendLoadFormFailed(String error) {
    return '載入傳送表單失敗：$error';
  }

  @override
  String get sendInvalidAddress => '請輸入有效的 Solana 地址。';

  @override
  String get sendInvalidAmount => '請輸入有效金額。';

  @override
  String get sendInsufficientBalance => '餘額不足。';

  @override
  String get sendUnlockAgain => '傳送前請再次解鎖錢包。';

  @override
  String get sendNotEnoughSolAfterFee => '預留網路費後 SOL 不足。';

  @override
  String get sendNotEnoughSolForFee => 'SOL 不足以支付網路費。';

  @override
  String get sendGenericFailure => '傳送失敗。請再試一次。';

  @override
  String get sendAmountHint => '金額';

  @override
  String get portfolioChildAccounts => '子帳戶';

  @override
  String get portfolioCrypto => '加密貨幣';

  @override
  String get portfolioStocks => '股票';

  @override
  String get portfolioMessages => '訊息';

  @override
  String get portfolioTokens => '代幣';

  @override
  String get portfolioDefi => 'DeFi';

  @override
  String get portfolioSend => '傳送';

  @override
  String get portfolioSwap => '兌換';

  @override
  String get portfolioReceive => '接收';

  @override
  String get portfolioCouldNotRefreshAssets => '無法重新整理資產';

  @override
  String get portfolioPullToRetry => '下拉以再試一次。';

  @override
  String get portfolioDefiParentOnly => 'DeFi 僅限家長模式';

  @override
  String get portfolioDefiParentOnlyMessage => '切回家長模式以查看協議持倉。';

  @override
  String get portfolioDefiUnavailable => 'DeFi 資料暫時無法使用';

  @override
  String get portfolioDefiUnavailableMessage => '代幣資料仍為最新。';

  @override
  String get portfolioNoDefi => '尚無 DeFi 持倉';

  @override
  String get portfolioRefreshingDefi => '正在重新整理協議持倉...';

  @override
  String get portfolioNoActiveDefi => '你的錢包沒有有效的 DeFi 持倉。';

  @override
  String get portfolioRefreshFailed => '重新整理失敗';

  @override
  String get portfolioNetworkBusy => '網路目前繁忙。請下拉再試一次。';

  @override
  String get portfolioServerUnavailable => '無法連線到伺服器。請檢查連線並下拉再試一次。';

  @override
  String get portfolioRefreshAssetsFailed => '無法重新整理資產。請下拉再試一次。';

  @override
  String get portfolioReceiveSol => '接收 SOL';

  @override
  String get portfolioReceiveSolSubtitle => '接收 SOL，開始使用 Benny Wallet。';

  @override
  String get commonAdd => '新增';

  @override
  String get commonAmount => '金額';

  @override
  String get commonAuto => '自動';

  @override
  String get commonBuy => '購買';

  @override
  String get commonConfirmed => '已確認';

  @override
  String get commonCustom => '自訂';

  @override
  String get commonDelete => '刪除';

  @override
  String get commonEdit => '編輯';

  @override
  String get commonFrom => '來自';

  @override
  String get commonNetwork => '網路';

  @override
  String get commonNetworkFee => '網路費';

  @override
  String get commonSave => '儲存';

  @override
  String get commonSend => '傳送';

  @override
  String get commonSignature => '簽名';

  @override
  String get commonSolana => 'Solana';

  @override
  String get commonStatus => '狀態';

  @override
  String get commonSubmitted => '已提交';

  @override
  String get commonTo => '收款方';

  @override
  String get commonToken => '代幣';

  @override
  String get transactionTimeline => '交易時間軸';

  @override
  String get walletAddressUnavailable => '錢包地址無法使用。';

  @override
  String relativeSecondsAgo(Object count) {
    return '$count 秒前';
  }

  @override
  String relativeMinutesAgo(Object count) {
    return '$count 分鐘前';
  }

  @override
  String relativeHoursAgo(Object count) {
    return '$count 小時前';
  }

  @override
  String relativeDaysAgo(Object count) {
    return '$count 天前';
  }

  @override
  String get importWalletLoadingTitle => '正在匯入錢包...';

  @override
  String get importWalletLoadingSubtitle => '正在準備你的 Solana 錢包清單。';

  @override
  String get importSolanaMainnet => 'Solana 主網';

  @override
  String get importSelectSolanaAccount => '選擇要匯入的 Solana 帳戶。';

  @override
  String get importLoadingSolanaAccounts => '正在載入 Solana 帳戶...';

  @override
  String get importCheckingActiveSolanaAccounts => '正在檢查有效的 Solana 帳戶。';

  @override
  String get importUnableScanRecoveryPhrase => '目前無法掃描此助記詞。';

  @override
  String get importActiveAccount => '有效帳戶';

  @override
  String get importDefaultMainWallet => '預設主錢包';

  @override
  String get seekerVaultTitle => 'Seeker Vault';

  @override
  String get seekerVaultChooseFundedAccount => '選擇有資產的帳戶';

  @override
  String get seekerVaultChooseAccount => '選擇帳戶';

  @override
  String get seekerVaultFundedAccountFound => 'Benny 在這個 Seed Vault 錢包下找到帳戶活動。';

  @override
  String get seekerVaultNoFundedAccountFound =>
      '沒有找到有資產的帳戶。以下是 Seed Vault 傳回的帳戶。';

  @override
  String seekerVaultAssetCount(Object count) {
    return '$count 項資產';
  }

  @override
  String get seekerVaultNoAssets => '無資產';

  @override
  String get scanAddressTitle => '掃描地址';

  @override
  String get scanNoSolanaAddress => '此 QR 碼中找不到 Solana 地址。';

  @override
  String get scanPointCamera => '將相機對準 Solana QR 碼。';

  @override
  String get sendConfirmTitle => '確認傳送';

  @override
  String get sendSubmitting => '正在提交...';

  @override
  String sendSubmittingSummary(Object address, Object amount, Object symbol) {
    return '$amount $symbol 至 $address';
  }

  @override
  String get sendSubmitted => '已提交';

  @override
  String get sendFailed => '傳送失敗';

  @override
  String sendSubmittedMessage(Object address, Object amount, Object symbol) {
    return '$amount $symbol 已提交至 $address。確認可能需要一點時間。';
  }

  @override
  String get sendTransactionCouldNotComplete => '交易無法完成。';

  @override
  String get sendViewTransaction => '檢視交易';

  @override
  String get sendRecipientNotReady => '收款錢包尚未準備好接收此代幣。';

  @override
  String get sendNetworkBusy => '網路繁忙，請再試一次。';

  @override
  String get sendNetworkTakingLonger => '網路花費時間比預期更久。請再試一次。';

  @override
  String get sendHistoryEmpty => '尚無傳送記錄。';

  @override
  String sendHistoryLoadFailed(Object error) {
    return '無法載入傳送記錄：$error';
  }

  @override
  String get sendDetailsTitle => '傳送詳細資料';

  @override
  String get sendNotConfirmedYet => '尚未確認';

  @override
  String get sendOpenTokenDetails => '開啟代幣詳細資料';

  @override
  String get sendViewOnSolscan => '在 Solscan 檢視';

  @override
  String get sendToEmpty => '收款方 --';

  @override
  String sendToAddress(Object address) {
    return '收款方 $address';
  }

  @override
  String get sendStatusFailed => '失敗';

  @override
  String get sendStatusFinalized => '已最終確認';

  @override
  String get sendStatusConfirmed => '已確認';

  @override
  String get sendStatusSubmitted => '已提交';

  @override
  String get sendStatusSourceHeliusWebhook => 'Helius webhook';

  @override
  String get sendStatusSourceRpcSync => '鏈上狀態同步';

  @override
  String get sendStatusSourceChainActivity => '鏈上活動';

  @override
  String get sendTransactionFallbackTitle => '傳送交易';

  @override
  String get sendSubmittedToSender => '已提交至 Sender';

  @override
  String get sendSubmittedToSenderSubtitle => 'Helius Sender 已接受已簽名交易。';

  @override
  String get sendAsyncResultFailed => '非同步結果失敗';

  @override
  String get sendWaitingAsyncConfirmation => '等待非同步確認';

  @override
  String get sendAsyncConfirmationReceived => '已收到非同步確認';

  @override
  String get sendUpdatedFromHeliusWebhook => '由 Helius webhook 更新。';

  @override
  String get sendUpdatedFromChainStatusSync => '由鏈上狀態同步更新。';

  @override
  String get sendConfirmationNotReceivedYet => '尚未收到確認。';

  @override
  String get swapTitle => '兌換';

  @override
  String get swapButton => '兌換';

  @override
  String get swapReviewTitle => '檢查兌換';

  @override
  String swapForAmount(Object amount, Object symbol) {
    return '約換得 $amount $symbol';
  }

  @override
  String get swapPay => '支付';

  @override
  String get swapReceive => '接收';

  @override
  String get swapMinimumReceive => '最低接收';

  @override
  String get swapSlippage => '滑價';

  @override
  String get swapPriorityFee => '優先費';

  @override
  String get swapRoute => '路由';

  @override
  String swapLamports(Object lamports) {
    return '$lamports lamports';
  }

  @override
  String get swapPriorityNormal => '一般';

  @override
  String get swapPriorityFast => '快速';

  @override
  String get swapPriorityTurbo => '極速';

  @override
  String get swapProcessing => '正在兌換...';

  @override
  String swapProcessingSummary(
    Object inputAmount,
    Object inputSymbol,
    Object outputAmount,
    Object outputSymbol,
  ) {
    return '$inputAmount $inputSymbol 至 $outputAmount $outputSymbol';
  }

  @override
  String get swapComplete => '兌換完成';

  @override
  String get swapFailed => '兌換失敗';

  @override
  String swapReceivedAmount(Object amount, Object symbol) {
    return '已收到 $amount $symbol';
  }

  @override
  String get swapCouldNotComplete => '兌換無法完成。';

  @override
  String get swapTradingUnavailableChildMode => '兒童模式下無法交易。';

  @override
  String get swapNoBaseAssetsForXStocks => '沒有可用於購買 xStocks 的 SOL、USDC 或 USDT。';

  @override
  String get swapNoAssetsAvailable => '沒有可兌換的資產。';

  @override
  String get swapPayWith => '使用以下資產支付';

  @override
  String get swapBuyXStock => '購買 xStock';

  @override
  String swapAvailable(Object amount, Object symbol) {
    return '可用 $amount $symbol';
  }

  @override
  String get swapRefreshingQuote => '正在更新報價...';

  @override
  String swapRouteLabel(Object route) {
    return '路由：$route';
  }

  @override
  String get swapBestRoute => '最佳路由';

  @override
  String swapFailedLoadWalletAssets(Object error) {
    return '無法載入錢包資產：$error';
  }

  @override
  String swapRateSummary(Object inputSymbol, Object outputSymbol, Object rate) {
    return '1 $inputSymbol ≈ $rate $outputSymbol';
  }

  @override
  String swapSlippageMin(Object value) {
    return '最低 $value';
  }

  @override
  String swapCustomWithValue(Object value) {
    return '自訂 · $value';
  }

  @override
  String swapMinReceive(Object amount) {
    return '最低 $amount';
  }

  @override
  String get swapAmountTooSmall => '此金額太小，無法取得有效路由。';

  @override
  String get swapWaitValidQuote => '請等待有效報價後再繼續。';

  @override
  String swapNotEnoughSolReserve(Object reserve) {
    return 'SOL 不足。\n需要保留 $reserve SOL。';
  }

  @override
  String get swapRouteUnavailable => '此兌換路由目前無法使用。請嘗試用 SOL 兌換或選擇其他代幣組合。';

  @override
  String get swapPriceMoved => '兌換送出前價格已變動。請提高滑價後再試一次。';

  @override
  String get swapNotEnoughTokenBalance => '代幣餘額不足。請再次點選 Max 後重試。';

  @override
  String get swapQuotesBusy => '報價服務目前繁忙。請稍後再試。';

  @override
  String get swapQuoteExpired => '此報價已過期。請重新檢查兌換。';

  @override
  String get swapUnlockAgain => '兌換前請重新解鎖錢包。';

  @override
  String get swapTransactionUnavailable => '兌換交易無法使用。';

  @override
  String get swapConnectSeekerVaultAgain => '兌換前請重新連接 Seeker Vault。';

  @override
  String get swapConnectSeedVaultAgain => '兌換前請重新連接 Seed Vault。';

  @override
  String get swapUnexpectedSignatureCount => '錢包傳回的簽名數量不符合預期。';

  @override
  String get swapCustomSlippageLabel => '自訂滑價 %';

  @override
  String get swapChooseToken => '選擇';

  @override
  String get swapApproxYouReceive => '預估你會收到';

  @override
  String get swapRate => '匯率';

  @override
  String get swapPlatformFee => '平台費';

  @override
  String get swapSearchTokenHint => '搜尋代幣名稱或符號';

  @override
  String get swapNoTokensAvailable => '沒有可用代幣';

  @override
  String swapNoResultsFor(Object query) {
    return '找不到「$query」的結果';
  }

  @override
  String get swapYourAssets => '你的資產';

  @override
  String get swapSuggestedTokens => '建議代幣';

  @override
  String swapAvailableBalance(Object amount) {
    return '可用 $amount';
  }

  @override
  String get assetNotFound => '找不到資產。';

  @override
  String get assetPosition => '持倉';

  @override
  String get assetValue => '價值';

  @override
  String get assetBalance => '餘額';

  @override
  String get assetReturn24h => '24 小時收益';

  @override
  String get assetInfo => '資訊';

  @override
  String get assetName => '名稱';

  @override
  String get assetSymbol => '符號';

  @override
  String get assetMint => 'Mint';

  @override
  String get assetWebsite => '網站';

  @override
  String get assetPrice => '價格';

  @override
  String get assetMarketCap => '市值';

  @override
  String get assetFdv => 'FDV';

  @override
  String get assetTotalSupply => '總供應量';

  @override
  String get assetCirculatingSupply => '流通供應量';

  @override
  String get assetHolders => '持有人';

  @override
  String get assetCreated => '建立時間';

  @override
  String get assetPerformance24h => '24 小時表現';

  @override
  String get assetVolume => '交易量';

  @override
  String get assetTraders => '交易者';

  @override
  String get assetSafety => '安全性';

  @override
  String get assetTop10Holders => '前 10 名持有人';

  @override
  String get assetMarketStatsUnavailable => '部分市場統計目前無法使用。';

  @override
  String get assetActivity => '活動';

  @override
  String get assetNoActivity => '尚無活動。';

  @override
  String get assetActivityLoadFailed => '無法載入活動。';

  @override
  String assetLoadDetailsFailed(Object error) {
    return '無法載入資產詳細資料：$error';
  }

  @override
  String get assetMintCopied => 'Mint 已複製（60 秒後清除）';

  @override
  String get assetCouldNotOpenWebsite => '無法開啟網站。';

  @override
  String get assetSwapOut => '兌出';

  @override
  String get assetSwapIn => '兌入';

  @override
  String assetToSymbol(Object symbol) {
    return '至 $symbol';
  }

  @override
  String assetFromSymbol(Object symbol) {
    return '來自 $symbol';
  }

  @override
  String get assetSent => '已傳送';

  @override
  String get assetReceived => '已接收';

  @override
  String get assetTransfer => '轉帳';

  @override
  String assetSwapWithTime(Object time) {
    return '兌換  •  $time';
  }

  @override
  String assetCounterpartyWithTime(Object address, Object time) {
    return '$address  •  $time';
  }

  @override
  String get notificationsMarkAllRead => '全部標為已讀';

  @override
  String get notificationsUnavailableTitle => '訊息無法使用';

  @override
  String get notificationsUnavailableSubtitle => '目前無法載入訊息。';

  @override
  String get notificationsEmptyTitle => '尚無訊息';

  @override
  String get notificationsEmptySubtitle => '推播訊息抵達後會顯示在這裡。';

  @override
  String get notificationDeleted => '訊息已刪除';

  @override
  String get receivedHistoryEmpty => '尚無接收記錄。';

  @override
  String receivedHistoryLoadFailed(Object error) {
    return '無法載入接收記錄：$error';
  }

  @override
  String get receivedDetailsTitle => '接收詳細資料';

  @override
  String get receivedDetailsMissingId => '此訊息不包含接收轉帳 ID。';

  @override
  String receivedDetailsLoadFailed(Object error) {
    return '無法載入此接收轉帳：$error';
  }

  @override
  String get receivedFundsTitle => '已收到資金';

  @override
  String receivedYouReceived(Object amount) {
    return '你已收到 $amount';
  }

  @override
  String get receivedFromEmpty => '來自 --';

  @override
  String receivedFromAddress(Object address) {
    return '來自 $address';
  }

  @override
  String get receivedRelatedChanges => '相關變動';

  @override
  String get receivedOnSolana => '已在 Solana 接收';

  @override
  String get receivedMarkedFailed => '此接收事件已標記為失敗。';

  @override
  String get receivedArrived => '資金已抵達此錢包。';

  @override
  String get receivedNewFundsArrived => '新資金已抵達你的錢包。';

  @override
  String get childVerifyPinTitle => '驗證你的 PIN';

  @override
  String get childWalletAlreadyAdded => '此子錢包已經新增。';

  @override
  String childWalletAdded(Object name) {
    return '$name 已成功新增';
  }

  @override
  String childWalletAddFailed(Object error) {
    return '新增子錢包失敗：$error';
  }

  @override
  String childWalletUpdated(Object name) {
    return '$name 已成功更新';
  }

  @override
  String childWalletUpdateFailed(Object error) {
    return '更新子錢包失敗：$error';
  }

  @override
  String childWalletDeleteTitle(Object name) {
    return '刪除 $name？';
  }

  @override
  String get childWalletDeleteMessage => '此子錢包項目將從父帳戶監控中移除。';

  @override
  String childWalletDeleted(Object name) {
    return '$name 已刪除';
  }

  @override
  String childWalletDeleteFailed(Object error) {
    return '刪除子錢包失敗：$error';
  }

  @override
  String get childAccountsTitle => '子帳戶';

  @override
  String get childManageUnavailable => '請關閉兒童模式以管理子帳戶。';

  @override
  String get childNoAccountsYet => '尚無子帳戶';

  @override
  String childAccountCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個子帳戶',
    );
    return '$_temp0';
  }

  @override
  String get childAddAccount => '新增子帳戶';

  @override
  String get childEditAccount => '編輯子帳戶';

  @override
  String get childName => '孩子名稱';

  @override
  String get childNameHint => '例如 Alice';

  @override
  String get childWalletAddress => '子錢包地址';

  @override
  String get childScanAgain => '再次掃描';

  @override
  String get childScanQrAgain => '再次掃描 QR 碼';

  @override
  String get childEnterName => '請輸入孩子名稱。';

  @override
  String get childEnterValidWalletAddress => '請輸入有效的錢包地址。';

  @override
  String get childWalletTitle => '子錢包';

  @override
  String get childWalletNotFound => '找不到子錢包';

  @override
  String get childAddressCopied => '地址已複製到剪貼簿';

  @override
  String get childTotalBalance => '總餘額';

  @override
  String get childSendToChildWallet => '傳送至子錢包';

  @override
  String get childNoAssets => '沒有資產';

  @override
  String get childAssets => '資產';

  @override
  String childWalletLoadFailed(Object error) {
    return '載入子錢包時發生錯誤：$error';
  }

  @override
  String get feedbackHeading => '告訴我們發生了什麼問題';

  @override
  String get feedbackSubtitle => '將你的問題或疑問直接傳送給 Benny Wallet 支援團隊。';

  @override
  String get feedbackEmailOptional => '電子郵件（選填）';

  @override
  String get feedbackMessage => '訊息';

  @override
  String get feedbackMessageHint => '描述你遇到的問題。';

  @override
  String get feedbackSending => '正在傳送...';

  @override
  String get feedbackMessageRequiredTitle => '需要訊息';

  @override
  String get feedbackMessageRequiredMessage => '傳送前請先輸入回饋內容。';

  @override
  String get feedbackMessageTooLongTitle => '訊息太長';

  @override
  String get feedbackMessageTooLongMessage => '請將回饋內容控制在 2000 個字元內。';

  @override
  String get feedbackInvalidEmailTitle => '電子郵件無效';

  @override
  String get feedbackInvalidEmailMessage => '請輸入有效的電子郵件地址，或留空。';

  @override
  String get feedbackSent => '你的訊息已送出。';

  @override
  String get feedbackSendFailedTitle => '傳送失敗';

  @override
  String get feedbackSendFailedFallback => '目前無法傳送你的訊息。請稍後再試。';

  @override
  String get rentTitle => 'Solana 租金回收';

  @override
  String get rentDescription => '關閉空的代幣帳戶，並將其租金回收到你的主要 SOL 餘額。';

  @override
  String get rentWalletAddress => '錢包地址';

  @override
  String get rentClosableTokenAccounts => '可關閉代幣帳戶';

  @override
  String get rentReclaimableRent => '可回收租金';

  @override
  String get rentAccountsToClose => '將關閉的帳戶';

  @override
  String rentMoreAccounts(Object count) {
    return '另外 $count 個帳戶將被回收。';
  }

  @override
  String get rentReclaiming => '正在回收...';

  @override
  String get rentNothingToReclaim => '沒有可回收項目';

  @override
  String get rentReclaimAll => '回收全部租金';

  @override
  String get rentReclaimingRent => '正在回收租金...';

  @override
  String get rentSubmittingTransactions => '正在提交關閉帳戶交易。';

  @override
  String get rentUnlockRequiredTitle => '需要解鎖';

  @override
  String get rentUnlockRequiredMessage => '回收租金前請重新解鎖錢包。';

  @override
  String get rentReclaimFailedTitle => '回收失敗';

  @override
  String get rentWalletRequiredTitle => '需要錢包';

  @override
  String get rentConnectSeekerVaultAgain => '回收租金前請重新連接 Seeker Vault。';

  @override
  String get rentConnectSeedVaultAgain => '回收租金前請重新連接 Seed Vault。';

  @override
  String rentSubmittedTransactions(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 筆回收交易',
    );
    return '已提交 $_temp0。';
  }

  @override
  String rentSubmittedTransactionsWithSkipped(num skipped, num submitted) {
    String _temp0 = intl.Intl.pluralLogic(
      submitted,
      locale: localeName,
      other: '$submitted 筆回收交易',
    );
    String _temp1 = intl.Intl.pluralLogic(
      skipped,
      locale: localeName,
      other: '$skipped 個帳戶',
    );
    return '已提交 $_temp0；已略過 $_temp1。';
  }

  @override
  String get rentUnableScan => '目前無法掃描可回收的代幣帳戶。';

  @override
  String rentMintAddress(Object address) {
    return 'Mint $address';
  }

  @override
  String get airdropTitle => 'BYC 空投';

  @override
  String get airdropUnavailableTitle => 'BYC 空投暫時無法使用';

  @override
  String get airdropUnlockBeforeJoin => '加入 BYC 空投前請先解鎖錢包。';

  @override
  String get airdropJoinDialogTitle => '加入 BYC 空投？';

  @override
  String airdropJoinDialogMessage(Object address) {
    return '我們將使用你目前的 Benny 錢包地址：\n\n$address\n\n此地址會傳送到 Benny 後端，用於註冊你的空投資料。';
  }

  @override
  String get airdropJoin => '加入';

  @override
  String get airdropJoinedSnack => '你已加入。你的 BYC 獎勵資料已準備就緒。';

  @override
  String get airdropJoinBeforeCheckIn => '請先加入 BYC 空投再簽到。';

  @override
  String get airdropUnlockBeforeCheckIn => '簽到前請先解鎖錢包。';

  @override
  String get airdropJoined => '已加入';

  @override
  String get airdropNotJoined => '未加入';

  @override
  String get airdropBycPoints => 'BYC 點數';

  @override
  String get airdropStreak => '連續天數';

  @override
  String airdropDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 天',
    );
    return '$_temp0';
  }

  @override
  String get airdropWalletUnavailable => '錢包無法使用';

  @override
  String get airdropJoinCardTitle => '加入空投';

  @override
  String get airdropJoinCardSubtitle => '使用目前的 Benny 錢包確認，並建立你的 BYC 獎勵資料。';

  @override
  String get airdropJoining => '正在加入...';

  @override
  String get airdropJoinWithThisWallet => '使用此錢包加入';

  @override
  String get airdropCheckInNow => '立即簽到';

  @override
  String get airdropCheckedInToday => '今天已簽到';

  @override
  String airdropNextReward(Object points) {
    return '下一次獎勵：+$points BYC';
  }

  @override
  String get airdropComeBackTomorrow => '明天再回來領取更多 BYC。';

  @override
  String get airdropCheckingIn => '正在簽到...';

  @override
  String airdropLastClaimed(Object date) {
    return '上次領取 $date';
  }

  @override
  String get airdropRewardRules => '獎勵規則';

  @override
  String get airdropFirstCheckIn => '首次簽到';

  @override
  String get airdropNextDayReward => '次日獎勵';

  @override
  String airdropEveryDayStreak(Object days) {
    return '每連續 $days 天';
  }

  @override
  String get airdropUnableOpenPumpFun => '目前無法開啟 Pump.fun。';

  @override
  String get airdropView => '檢視';

  @override
  String get airdropPointsBalanceUpdated => '你的 Benny 點數餘額已更新。';

  @override
  String get airdropFirstCheckInUnlocked => '首次簽到已解鎖';

  @override
  String get airdropStreakBonusLanded => '連續獎勵已入帳';

  @override
  String get airdropAlreadyClaimedToday => '今天已領取';

  @override
  String get airdropRewardClaimed => '獎勵已領取';

  @override
  String get defiTypeDeposit => '存款';

  @override
  String get defiTypeBorrow => '借款';

  @override
  String get defiTypeStaking => '質押';

  @override
  String get defiTypeLiquidity => '流動性';

  @override
  String get defiTypeYield => '收益';

  @override
  String get defiTypePerps => '永續合約';

  @override
  String get defiTypeRewards => '獎勵';

  @override
  String get defiTypePosition => '持倉';

  @override
  String get settingsSeekerWallet => 'Seeker Wallet';

  @override
  String get updateDefaultTitle => '有可用更新';

  @override
  String get updateDefaultMessage => 'Benny Wallet 有新版本可用。';

  @override
  String get updateFailedTitle => '更新失敗';

  @override
  String get updateUnableToOpen => '目前無法開啟 Benny Wallet 更新連結。';

  @override
  String get routerFeatureUnavailableTitle => '功能無法使用';

  @override
  String get routerFeatureUnavailableMessage => '此版本無法使用此功能。';

  @override
  String get routerMessageUnavailableTitle => '訊息無法使用';

  @override
  String get routerMessageUnavailableMessage => '請先從訊息清單開啟接收訊息。';

  @override
  String get routerSendDetailsUnavailableTitle => '傳送詳細資料無法使用';

  @override
  String get routerSendDetailsUnavailableMessage => '請先從傳送記錄開啟交易。';

  @override
  String get routerInvalidChildWalletId => '子錢包 ID 無效';

  @override
  String routerRouteNotFound(String uri) {
    return '找不到路由：$uri';
  }
}
