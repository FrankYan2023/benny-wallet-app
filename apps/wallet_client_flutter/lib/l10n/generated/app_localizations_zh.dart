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
  String get settingsFullFeaturesUnlocked => '已開啟全功能版';

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
  String receivedYouReceivedInWallet(String amount, String wallet) {
    return '你已收到 $amount（$wallet）';
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

  @override
  String get walletsTitle => '錢包';

  @override
  String get walletsSubtitle => '切換、新增、重新命名或移除錢包';

  @override
  String get walletSwitcherTitle => '我的錢包';

  @override
  String walletSwitcherCount(int count, int max) {
    return '$count/$max';
  }

  @override
  String get walletAddWallet => '新增錢包';

  @override
  String walletAddLimitReached(int max) {
    return '最多可新增 $max 個錢包。';
  }

  @override
  String get walletManage => '管理';

  @override
  String get walletAddSheetTitle => '新增錢包';

  @override
  String get walletAddSheetSubtitle => '每個錢包都有獨立的助記詞和帳戶，一組 PIN 即可解鎖全部錢包。';

  @override
  String get walletAddCreate => '建立新錢包';

  @override
  String get walletAddCreateSubtitle => '產生一組新的助記詞';

  @override
  String get walletAddImport => '匯入助記詞';

  @override
  String get walletAddImportSubtitle => '匯入其他助記詞或其他帳戶';

  @override
  String get walletAddSeedVault => '連接 Seed Vault';

  @override
  String get walletAddSeedVaultSubtitle => '使用 Seeker 中的帳戶';

  @override
  String get walletNameTitle => '為錢包命名';

  @override
  String get walletNameSubtitle => '名稱只儲存在本機，可隨時修改。';

  @override
  String get walletNameLabel => '錢包名稱';

  @override
  String get walletNameEmpty => '請輸入錢包名稱';

  @override
  String walletAdded(String name) {
    return '已新增 $name';
  }

  @override
  String walletSwitched(String name) {
    return '已切換到 $name';
  }

  @override
  String get walletDuplicateTitle => '錢包已存在';

  @override
  String get walletDuplicateMessage => '該助記詞和帳戶已新增過。同一助記詞的同一帳戶只能新增一次。';

  @override
  String get walletAlreadyAddedBadge => '已新增';

  @override
  String get walletRename => '重新命名';

  @override
  String get walletRenameTitle => '重新命名錢包';

  @override
  String get walletRemove => '移除';

  @override
  String walletRemoveTitle(String name) {
    return '移除 $name？';
  }

  @override
  String get walletRemoveMessage => '這會從本機移除該錢包。請先備份它的助記詞，否則資產將無法找回。';

  @override
  String get walletRemoveExternalMessage =>
      '這會中斷該錢包與 Benny 的連線，私鑰仍安全保存在 Seed Vault 中。';

  @override
  String walletRemoved(String name) {
    return '已移除 $name';
  }

  @override
  String get walletActiveBadge => '目前';

  @override
  String get walletTypePhrase => '助記詞錢包';

  @override
  String get walletTypeSeedVault => 'Seed Vault';

  @override
  String get swapWalletChanged => '目前錢包已切換，請返回重新取得報價。';

  @override
  String seedVaultPickNamedSeed(String seed, String wallet) {
    return '接下來請選擇種子「$seed」，$wallet 就在這個種子裡。';
  }

  @override
  String seedVaultPickUnknownSeed(String wallet) {
    return '接下來請選擇包含 $wallet 的種子。如果選錯了，App 會提示你，並且這個種子不會再出現在列表裡。';
  }

  @override
  String seedVaultWrongSeedNamed(String seed) {
    return '種子「$seed」裡沒有這個錢包。';
  }

  @override
  String get seedVaultReauthorizeTitle => '重新授權 Seed Vault';

  @override
  String get childAddFromMyWallets => '或從我的錢包選擇';

  @override
  String get walletAddChildModeSetPin =>
      '這個錢包沒有保存兒童模式密碼，接下來請設定一個，之後停用兒童模式需要輸入它。';

  @override
  String get settingsChildModeAppPinTitle => '輸入 App PIN 以停用兒童模式';

  @override
  String get walletAddChildModeTitle => '這是兒童模式錢包';

  @override
  String get walletAddChildModeMessage =>
      '匯入後 App 會進入兒童模式：錢包切換介面會被隱藏，也不能再新增錢包，轉帳時不能轉給你的其他錢包。確定要匯入嗎？';

  @override
  String get walletAddChildModeConfirm => '同意並匯入';

  @override
  String get walletTypeStandard => '普通錢包';

  @override
  String get sendToMyWallet => '轉給我的錢包';

  @override
  String get walletChildModeLocked => '請先關閉兒童模式，再切換或新增錢包。';

  @override
  String get walletPinToContinue => '請輸入 PIN 以繼續';

  @override
  String get walletActionFailed => '操作失敗，請重試。';

  @override
  String get settingsChangePin => '修改 PIN';

  @override
  String get settingsChangePinSubtitle => '一組 PIN 解鎖所有錢包';

  @override
  String get changePinCurrent => '輸入目前 PIN';

  @override
  String get changePinNew => '輸入新 PIN';

  @override
  String get changePinConfirm => '確認新 PIN';

  @override
  String get changePinSuccess => 'PIN 已修改';

  @override
  String get changePinSameAsOld => '新 PIN 不能與目前 PIN 相同';

  @override
  String get unlockSetPinTitle => '設定 Benny PIN';

  @override
  String get unlockSetPinSubtitle => '現在一組 PIN 保護本機所有錢包。';

  @override
  String get pinUnlocksAllWallets => '此 PIN 將用於解鎖您的所有錢包。';

  @override
  String settingsLogOutAllWallets(int count) {
    return '這會從本機移除全部 $count 個錢包。請先備份每個錢包的助記詞。';
  }

  @override
  String importAccountLabel(int number) {
    return '帳戶 $number';
  }

  @override
  String importAccountAltLabel(int number) {
    return '帳戶 $number · 備用路徑';
  }

  @override
  String get importLegacyLabel => '舊版路徑';

  @override
  String get travelGuardTitle => '旅行防搶劫';

  @override
  String get travelGuardOffSubtitle => '設定一組只打開一個錢包的特殊 PIN';

  @override
  String get travelGuardOnSubtitle => '已開啟：特殊 PIN 只打開一個錢包';

  @override
  String get travelGuardInfoTitle => '什麼是旅行防搶劫？';

  @override
  String get travelGuardInfoBody =>
      '用於被人脅迫打開錢包的時候。\n\n設定一組特殊 PIN 並選擇一個錢包（建議只放少量資金）。用特殊 PIN 解鎖時只會打開這個錢包：其他錢包、它們的餘額和訊息在所有地方都會隱藏，包括錢包列表和轉帳，這個設定本身也會隱藏，看起來就像普通錢包。\n\n開啟後生物辨識解鎖會自動關閉且無法開啟，每次都需要輸入 PIN。\n\n鎖定 App（或等待自動鎖定）後用正常 PIN 解鎖，就會回到所有錢包。';

  @override
  String get travelGuardChooseWallet => '選擇特殊 PIN 要打開的錢包';

  @override
  String get travelGuardNewPin => '設定特殊 PIN';

  @override
  String get travelGuardConfirmPin => '再輸入一次特殊 PIN';

  @override
  String get travelGuardPinHint => '不能和正常解鎖 PIN 相同。';

  @override
  String get travelGuardPinSameAsApp => '這是你的正常 PIN，請換一組。';

  @override
  String get travelGuardEnabled => '旅行防搶劫已開啟';

  @override
  String get travelGuardDisabled => '旅行防搶劫已關閉';

  @override
  String get travelGuardActiveBadge => '旅行防搶劫已開啟';

  @override
  String get travelGuardBiometricsOff => '旅行防搶劫開啟時無法使用';
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
  String get settingsFullFeaturesUnlocked => '已開啟全功能版';

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
  String receivedYouReceivedInWallet(String amount, String wallet) {
    return '你已收到 $amount（$wallet）';
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

  @override
  String get walletsTitle => '錢包';

  @override
  String get walletsSubtitle => '切換、新增、重新命名或移除錢包';

  @override
  String get walletSwitcherTitle => '我的錢包';

  @override
  String walletSwitcherCount(int count, int max) {
    return '$count/$max';
  }

  @override
  String get walletAddWallet => '新增錢包';

  @override
  String walletAddLimitReached(int max) {
    return '最多可新增 $max 個錢包。';
  }

  @override
  String get walletManage => '管理';

  @override
  String get walletAddSheetTitle => '新增錢包';

  @override
  String get walletAddSheetSubtitle => '每個錢包都有獨立的助記詞和帳戶，一組 PIN 即可解鎖全部錢包。';

  @override
  String get walletAddCreate => '建立新錢包';

  @override
  String get walletAddCreateSubtitle => '產生一組新的助記詞';

  @override
  String get walletAddImport => '匯入助記詞';

  @override
  String get walletAddImportSubtitle => '匯入其他助記詞或其他帳戶';

  @override
  String get walletAddSeedVault => '連接 Seed Vault';

  @override
  String get walletAddSeedVaultSubtitle => '使用 Seeker 中的帳戶';

  @override
  String get walletNameTitle => '為錢包命名';

  @override
  String get walletNameSubtitle => '名稱只儲存在本機，可隨時修改。';

  @override
  String get walletNameLabel => '錢包名稱';

  @override
  String get walletNameEmpty => '請輸入錢包名稱';

  @override
  String walletAdded(String name) {
    return '已新增 $name';
  }

  @override
  String walletSwitched(String name) {
    return '已切換到 $name';
  }

  @override
  String get walletDuplicateTitle => '錢包已存在';

  @override
  String get walletDuplicateMessage => '該助記詞和帳戶已新增過。同一助記詞的同一帳戶只能新增一次。';

  @override
  String get walletAlreadyAddedBadge => '已新增';

  @override
  String get walletRename => '重新命名';

  @override
  String get walletRenameTitle => '重新命名錢包';

  @override
  String get walletRemove => '移除';

  @override
  String walletRemoveTitle(String name) {
    return '移除 $name？';
  }

  @override
  String get walletRemoveMessage => '這會從本機移除該錢包。請先備份它的助記詞，否則資產將無法找回。';

  @override
  String get walletRemoveExternalMessage =>
      '這會中斷該錢包與 Benny 的連線，私鑰仍安全保存在 Seed Vault 中。';

  @override
  String walletRemoved(String name) {
    return '已移除 $name';
  }

  @override
  String get walletActiveBadge => '目前';

  @override
  String get walletTypePhrase => '助記詞錢包';

  @override
  String get walletTypeSeedVault => 'Seed Vault';

  @override
  String get swapWalletChanged => '目前錢包已切換，請返回重新取得報價。';

  @override
  String seedVaultPickNamedSeed(String seed, String wallet) {
    return '接下來請選擇種子「$seed」，$wallet 就在這個種子裡。';
  }

  @override
  String seedVaultPickUnknownSeed(String wallet) {
    return '接下來請選擇包含 $wallet 的種子。如果選錯了，App 會提示你，並且這個種子不會再出現在列表裡。';
  }

  @override
  String seedVaultWrongSeedNamed(String seed) {
    return '種子「$seed」裡沒有這個錢包。';
  }

  @override
  String get seedVaultReauthorizeTitle => '重新授權 Seed Vault';

  @override
  String get childAddFromMyWallets => '或從我的錢包選擇';

  @override
  String get walletAddChildModeSetPin =>
      '這個錢包沒有保存兒童模式密碼，接下來請設定一個，之後停用兒童模式需要輸入它。';

  @override
  String get settingsChildModeAppPinTitle => '輸入 App PIN 以停用兒童模式';

  @override
  String get walletAddChildModeTitle => '這是兒童模式錢包';

  @override
  String get walletAddChildModeMessage =>
      '匯入後 App 會進入兒童模式：錢包切換介面會被隱藏，也不能再新增錢包，轉帳時不能轉給你的其他錢包。確定要匯入嗎？';

  @override
  String get walletAddChildModeConfirm => '同意並匯入';

  @override
  String get walletTypeStandard => '普通錢包';

  @override
  String get sendToMyWallet => '轉給我的錢包';

  @override
  String get walletChildModeLocked => '請先關閉兒童模式，再切換或新增錢包。';

  @override
  String get walletPinToContinue => '請輸入 PIN 以繼續';

  @override
  String get walletActionFailed => '操作失敗，請重試。';

  @override
  String get settingsChangePin => '修改 PIN';

  @override
  String get settingsChangePinSubtitle => '一組 PIN 解鎖所有錢包';

  @override
  String get changePinCurrent => '輸入目前 PIN';

  @override
  String get changePinNew => '輸入新 PIN';

  @override
  String get changePinConfirm => '確認新 PIN';

  @override
  String get changePinSuccess => 'PIN 已修改';

  @override
  String get changePinSameAsOld => '新 PIN 不能與目前 PIN 相同';

  @override
  String get unlockSetPinTitle => '設定 Benny PIN';

  @override
  String get unlockSetPinSubtitle => '現在一組 PIN 保護本機所有錢包。';

  @override
  String get pinUnlocksAllWallets => '此 PIN 將用於解鎖您的所有錢包。';

  @override
  String settingsLogOutAllWallets(int count) {
    return '這會從本機移除全部 $count 個錢包。請先備份每個錢包的助記詞。';
  }

  @override
  String importAccountLabel(int number) {
    return '帳戶 $number';
  }

  @override
  String importAccountAltLabel(int number) {
    return '帳戶 $number · 備用路徑';
  }

  @override
  String get importLegacyLabel => '舊版路徑';

  @override
  String get travelGuardTitle => '旅行防搶劫';

  @override
  String get travelGuardOffSubtitle => '設定一組只打開一個錢包的特殊 PIN';

  @override
  String get travelGuardOnSubtitle => '已開啟：特殊 PIN 只打開一個錢包';

  @override
  String get travelGuardInfoTitle => '什麼是旅行防搶劫？';

  @override
  String get travelGuardInfoBody =>
      '用於被人脅迫打開錢包的時候。\n\n設定一組特殊 PIN 並選擇一個錢包（建議只放少量資金）。用特殊 PIN 解鎖時只會打開這個錢包：其他錢包、它們的餘額和訊息在所有地方都會隱藏，包括錢包列表和轉帳，這個設定本身也會隱藏，看起來就像普通錢包。\n\n開啟後生物辨識解鎖會自動關閉且無法開啟，每次都需要輸入 PIN。\n\n鎖定 App（或等待自動鎖定）後用正常 PIN 解鎖，就會回到所有錢包。';

  @override
  String get travelGuardChooseWallet => '選擇特殊 PIN 要打開的錢包';

  @override
  String get travelGuardNewPin => '設定特殊 PIN';

  @override
  String get travelGuardConfirmPin => '再輸入一次特殊 PIN';

  @override
  String get travelGuardPinHint => '不能和正常解鎖 PIN 相同。';

  @override
  String get travelGuardPinSameAsApp => '這是你的正常 PIN，請換一組。';

  @override
  String get travelGuardEnabled => '旅行防搶劫已開啟';

  @override
  String get travelGuardDisabled => '旅行防搶劫已關閉';

  @override
  String get travelGuardActiveBadge => '旅行防搶劫已開啟';

  @override
  String get travelGuardBiometricsOff => '旅行防搶劫開啟時無法使用';
}
