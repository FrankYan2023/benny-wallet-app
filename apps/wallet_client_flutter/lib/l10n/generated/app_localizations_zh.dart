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

  @override
  String get welcomeUseAsSigner => '把這台手機設為離線簽名機';

  @override
  String get walletAddAirGap => '連接離線簽名機';

  @override
  String get walletAddAirGapSubtitle => '私鑰留在另一台永不聯網的手機上';

  @override
  String createWalletWordCount(int count) {
    return '$count 個詞';
  }

  @override
  String get signerAppTitle => 'Benny 簽名機';

  @override
  String get signerNeedsNoWalletsTitle => '請先刪除所有錢包';

  @override
  String get signerNeedsNoWalletsBody =>
      '簽名機只保存自己離線產生或匯入的助記詞。請先備份，並在「設定 > 錢包」刪除這台手機上的所有錢包，然後再試一次。';

  @override
  String get signerEnterTitle => '把這台手機設為簽名機？';

  @override
  String get signerEnterBody =>
      '這台手機會一直保持離線，只負責簽名，不再顯示錢包頁面。之後如果要改回錢包，必須先清除簽名機。';

  @override
  String get signerIntroTitle => '離線簽名機';

  @override
  String get signerIntroPoint1 => '這台手機保存你的助記詞，之後不再聯網。';

  @override
  String get signerIntroPoint2 => '另一台手機上的 Benny Wallet 負責建立交易，你在這裡掃碼確認並簽名。';

  @override
  String get signerIntroPoint3 => '產生助記詞之前，會先引導你關閉所有網路。';

  @override
  String get signerIntroPoint4 => '請把助記詞抄在紙上，這是唯一的備份。';

  @override
  String get signerIntroStart => '開始設定';

  @override
  String get signerIntroCancel => '暫不設定，繼續當錢包使用';

  @override
  String get signerOfflineTitle => '讓手機完全離線';

  @override
  String get signerOfflineBody => '請開啟飛航模式，並關閉 Wi-Fi、藍牙和 NFC。所有必要項目都通過後才能繼續。';

  @override
  String get signerCheckAirplane => '已開啟飛航模式';

  @override
  String get signerCheckWifi => 'Wi-Fi 已關閉';

  @override
  String get signerCheckBluetooth => '藍牙已關閉';

  @override
  String get signerCheckNfc => 'NFC 已關閉';

  @override
  String get signerCheckNoNetwork => '沒有任何網路連線';

  @override
  String get signerCheckUsbDebugging => 'USB 偵錯已關閉';

  @override
  String get signerCheckSim => '已取出 SIM 卡（建議）';

  @override
  String get signerCheckManualHint => '此項無法自動偵測，請自行確認。';

  @override
  String get signerOpenSettings => '打開設定';

  @override
  String get signerNetworkDetected => '偵測到網路連線，請關閉後再繼續。';

  @override
  String get signerPinTitle => '設定簽名機 PIN 碼';

  @override
  String get signerPinBody => '請為簽名機設定 6 位數 PIN 碼。';

  @override
  String get signerPinConfirmTitle => '確認 PIN 碼';

  @override
  String get signerPinConfirmBody => '請再輸入一次 PIN 碼。';

  @override
  String get signerPinMismatch => '兩次輸入的 PIN 碼不一致，請重試。';

  @override
  String get signerSourceTitle => '助記詞';

  @override
  String get signerSourceBody => '在這台離線手機上產生新的助記詞，或輸入你已有的助記詞。';

  @override
  String get signerSourceCreate24 => '產生 24 個詞';

  @override
  String get signerSourceCreate24Subtitle => '簽名機建議使用';

  @override
  String get signerSourceCreate12 => '產生 12 個詞';

  @override
  String get signerSourceCreate12Subtitle => '抄寫較短';

  @override
  String get signerSourceImport => '匯入已有助記詞';

  @override
  String get signerSourceImportSubtitle => '支援 12 或 24 個詞';

  @override
  String get signerWordsTitle => '抄下這些詞';

  @override
  String get signerWordsWarning => '請按順序抄在紙上。不要拍照、截圖或輸入到其他地方。任何人拿到這些詞都能轉走你的資產。';

  @override
  String get signerWordsDone => '我已抄好';

  @override
  String get signerVerifyTitle => '核對備份';

  @override
  String get signerImportTitle => '匯入助記詞';

  @override
  String get signerImportBody => '請輸入 12 或 24 個詞，以空格分隔。';

  @override
  String get signerImportInvalid => '這不是有效的 12 或 24 個詞助記詞。';

  @override
  String get signerFinishTitle => '完成設定';

  @override
  String get signerDeviceNameLabel => '簽名機名稱';

  @override
  String get signerDeviceNameHelper => '連接後會顯示在錢包中。';

  @override
  String get signerBiometricToggle => '使用生物辨識解鎖';

  @override
  String get signerFinishButton => '完成';

  @override
  String get signerSetupFailed => '設定無法儲存，請重試。';

  @override
  String get signerUnlockSubtitle => '請輸入簽名機 PIN 碼';

  @override
  String get signerUnlockNetworkBlocked => '目前有網路連線，請開啟飛航模式後再解鎖。';

  @override
  String signerWrongPin(int count) {
    return 'PIN 碼錯誤。再錯 $count 次簽名機將被清除。';
  }

  @override
  String get signerUnlockFailed => '無法解鎖，請重試。';

  @override
  String get signerUseBiometric => '使用生物辨識';

  @override
  String get signerBiometricReason => '解鎖 Benny 簽名機';

  @override
  String get signerBiometricFailed => '無法更改生物辨識設定。';

  @override
  String get signerRecheckTitle => '離線檢查';

  @override
  String get signerRecheckBody => '應用已更新。解鎖前請確認這台手機已重新完全離線。';

  @override
  String get signerLockNow => '鎖定';

  @override
  String get signerOfflineChip => '離線簽名機';

  @override
  String get signerScanToSign => '掃碼簽名';

  @override
  String get signerPairWallet => '連接錢包';

  @override
  String get signerAccountsTitle => '帳戶';

  @override
  String signerAccountName(int number) {
    return '帳戶 $number';
  }

  @override
  String get signerPairBody => '在另一台手機的 Benny Wallet 選擇「連接離線簽名機」，然後掃描這個二維碼。';

  @override
  String get signerPairPublicOnly => '這個二維碼只包含公開地址，不含助記詞。';

  @override
  String get signerScanBody => '掃描另一台手機上 Benny Wallet 顯示的二維碼。';

  @override
  String get signerScanWrongCode => '這不是 Benny Wallet 的簽名請求。';

  @override
  String get signerScanAgain => '重新掃描';

  @override
  String get signerRejectUnknownAccount => '這個請求的帳戶不在這台簽名機上。';

  @override
  String get signerRejectNotASigner => '這筆交易不需要這個帳戶簽名。';

  @override
  String get signerRejectUnreadable => '無法解析這筆交易，因此不會簽名。';

  @override
  String get signerRejectMessageIsTransaction => '這則訊息實際上是一筆交易，因此不會簽名。';

  @override
  String get signerRejectInvalidCode => '這不是有效的簽名請求二維碼。';

  @override
  String get signerReviewTitle => '核對並簽名';

  @override
  String get signerReviewAccount => '簽名帳戶';

  @override
  String get signerReviewFee => '網路手續費';

  @override
  String get signerReviewMessage => '訊息';

  @override
  String signerBinaryMessage(int count) {
    return '二進位資料（$count 位元組）';
  }

  @override
  String get signerThisAccount => '本帳戶';

  @override
  String signerActionSendSol(String amount) {
    return '發送 $amount SOL';
  }

  @override
  String signerActionSendToken(String amount, String symbol) {
    return '發送 $amount $symbol';
  }

  @override
  String signerActionSendUnverified(String amount) {
    return '發送 $amount 個未驗證代幣';
  }

  @override
  String signerActionTo(String address) {
    return '至 $address';
  }

  @override
  String signerActionToTokenAccount(String address) {
    return '至代幣帳戶 $address';
  }

  @override
  String signerActionMint(String mint) {
    return '代幣地址 $mint';
  }

  @override
  String signerActionOwner(String address) {
    return '擁有者 $address';
  }

  @override
  String signerActionRentTo(String address) {
    return '租金退回至 $address';
  }

  @override
  String get signerActionCreateTokenAccount => '建立代幣帳戶';

  @override
  String get signerActionCloseTokenAccount => '關閉代幣帳戶';

  @override
  String get signerActionMemo => '備註';

  @override
  String get signerActionApprove => '允許其他帳戶動用你的代幣';

  @override
  String get signerActionSetAuthority => '更改帳戶權限';

  @override
  String get signerActionAssign => '更改帳戶擁有者';

  @override
  String get signerActionCreateAccount => '建立帳戶';

  @override
  String signerActionProgram(String program) {
    return '程式 $program';
  }

  @override
  String get signerHoldToSign => '按住簽名';

  @override
  String get signerReject => '拒絕';

  @override
  String get signerSignFailed => '簽名失敗，請重試。';

  @override
  String get signerSignatureTitle => '簽名結果';

  @override
  String get signerSignatureBody => '用另一台手機上的 Benny Wallet 掃描這個二維碼即可完成。';

  @override
  String get signerSettingsTitle => '簽名機設定';

  @override
  String get signerAccountCount => '顯示帳戶數';

  @override
  String get signerAccountCountHint => '此助記詞最多 5 個帳戶';

  @override
  String get signerUpgradeTitle => '更新簽名機';

  @override
  String get signerUpgradeIntro =>
      '更新應用需要聯網，請事先準備。聯網期間助記詞仍加密保存在手機中，簽名機要等手機重新離線後才會開啟。';

  @override
  String get signerUpgradeStep0 => '1. 核對紙本備份';

  @override
  String get signerUpgradeVerifyBackup => '核對備份';

  @override
  String get signerUpgradeBackupOk => '備份已核對';

  @override
  String get signerUpgradeOnlineTitle => '2a. 一般更新';

  @override
  String get signerUpgradeOnlineBody =>
      '先鎖定簽名機，再開啟網路，從原本安裝的商店更新 Benny Wallet。更新後重新開啟飛航模式。解鎖前簽名機會再次進行離線檢查。';

  @override
  String get signerUpgradeSecureTitle => '2b. 最高安全更新';

  @override
  String get signerUpgradeSecureBody =>
      '先在設定中清除簽名機，然後聯網更新應用。更新後重新離線，再次設定簽名機並匯入助記詞。帳戶和地址都不會改變。';

  @override
  String get signerUpgradeOfflineApkTitle => 'Android：不聯網更新';

  @override
  String get signerUpgradeOfflineApkBody =>
      '也可以用 USB 線或 SD 卡把新版 APK 複製到這台手機，在離線狀態下安裝。請使用與原本安裝相同來源的 APK，否則無法覆蓋安裝。';

  @override
  String get signerUpgradeCompatTitle => '舊版簽名機仍可使用';

  @override
  String get signerUpgradeCompatBody =>
      '新版錢包仍能配合舊版簽名機使用。錢包只會使用簽名機支援的功能，你可以在方便時再更新。';

  @override
  String get signerVersionTitle => '版本';

  @override
  String signerVersionDetail(String app, int protocol, int tokens) {
    return '應用 $app · 協議 $protocol · 代幣清單 $tokens';
  }

  @override
  String get signerEraseTitle => '清除簽名機';

  @override
  String get signerEraseSubtitle => '從這台手機刪除助記詞';

  @override
  String get signerEraseBody => '助記詞將從這台手機刪除。沒有紙本備份將無法找回資產。';

  @override
  String get signerEraseConfirm => '清除';

  @override
  String get signerEraseWrongPin => 'PIN 碼錯誤，未清除任何資料。';

  @override
  String get airGapConnectTitle => '連接離線簽名機';

  @override
  String get airGapConnectBody => '在簽名機上點「連接錢包」，然後掃描顯示的二維碼。';

  @override
  String get airGapConnectInvalid => '這不是簽名機的配對二維碼。';

  @override
  String airGapConnectChoose(String device) {
    return '選擇 $device 上的帳戶';
  }

  @override
  String airGapConnectAccount(int number) {
    return '帳戶 $number';
  }

  @override
  String airGapConnectAccountAdded(int number) {
    return '帳戶 $number（已新增）';
  }

  @override
  String get airGapConnectCompare => '請確認地址與簽名機上顯示的一致。';

  @override
  String get airGapConnectScanAgain => '重新掃描';

  @override
  String get airGapSignTitle => '用簽名機簽名';

  @override
  String get airGapSignShowRequestAgain => '重新顯示請求';

  @override
  String get airGapSignMayHaveExpired => '這筆交易可能已過期，若發送失敗請重新開始。';

  @override
  String get airGapSignWrongRequest => '這個簽名屬於另一個請求。';

  @override
  String get airGapSignInvalidCode => '這不是簽名機產生的簽名。';

  @override
  String get airGapSignerOutdated => '簽名機版本較舊，仍可正常使用，方便時再更新即可。';

  @override
  String get signerIntroSubtitle => '把私鑰放在一台永不聯網的手機上。';

  @override
  String get signerFinishSubtitle => '為這台簽名機取個名字，並設定 PIN 碼。';

  @override
  String signerQuizBody(int count) {
    return '請對照紙本備份，為 $count 個位置選出正確的詞。';
  }

  @override
  String signerQuizProgress(int current, int total) {
    return '第 $current / $total 題';
  }

  @override
  String signerQuizQuestion(int position) {
    return '第 $position 個詞是哪一個？';
  }

  @override
  String get signerQuizCorrect => '答對了！';

  @override
  String get signerQuizWrong => '選錯了。請再對照紙本，我們換了新的位置重新開始。';

  @override
  String get signerQuizShowWords => '再看一次助記詞';

  @override
  String get signerScanToSignSubtitle => '掃描錢包顯示的簽名請求';

  @override
  String get signerPairWalletSubtitle => '顯示二維碼讓 Benny Wallet 掃描';

  @override
  String get signerWalletPhoneLabel => 'Benny Wallet';

  @override
  String get signerScanRefusedTitle => '無法簽名';

  @override
  String get airGapSignerLabel => '簽名機';

  @override
  String get airGapThisPhone => '本機';

  @override
  String get airGapConnectFound => '已識別簽名機';

  @override
  String get airGapSignNeedsSigner => '需要由您的簽名機驗證並簽名';

  @override
  String get airGapSignStepShort1 => '簽名機掃碼';

  @override
  String get airGapSignStepShort2 => '掃描簽名';

  @override
  String airGapSignStep1Named(String device) {
    return '第一步：用簽名機「$device」掃描這個二維碼';
  }

  @override
  String airGapSignStep1BodyNamed(String device) {
    return '在「$device」點「掃碼簽名」，核對內容後確認。';
  }

  @override
  String airGapSignStep2Named(String device) {
    return '第二步：掃描簽名機「$device」上的簽名碼';
  }

  @override
  String airGapSignStep2BodyNamed(String device) {
    return '「$device」確認後會顯示簽名碼，用本機掃描。';
  }

  @override
  String airGapSignScanSignatureNamed(String device) {
    return '下一步：掃描「$device」的簽名';
  }

  @override
  String signerActionSwapPair(String from, String to) {
    return '兌換 $from → $to';
  }

  @override
  String signerSwapPay(String amount) {
    return '支付 $amount';
  }

  @override
  String signerSwapPayAtMost(String amount) {
    return '最多支付 $amount';
  }

  @override
  String signerSwapReceive(String amount) {
    return '收到 $amount';
  }

  @override
  String signerSwapReceiveAtLeast(String amount) {
    return '至少收到 $amount';
  }

  @override
  String get signerSwapUnverifiedToken => '未驗證代幣';

  @override
  String airGapSignTimeLeft(int seconds) {
    return '還剩 $seconds 秒，超時會自動換新的二維碼。';
  }

  @override
  String get airGapSignRefreshing => '時間到了，正在取得新的報價和二維碼…';

  @override
  String airGapSignRefreshed(String device) {
    return '上一個二維碼已過期，已自動換新。請用簽名機「$device」重新掃碼。';
  }

  @override
  String get airGapSignRefreshFailed => '無法取得新的二維碼，請檢查網路後重試。';

  @override
  String get airGapSignOldRequest => '這是舊二維碼的簽名，已經過期。請先用簽名機掃描新的二維碼。';

  @override
  String get scanHintRoleShows => '出示二維碼';

  @override
  String get scanHintRoleScans => '掃碼';

  @override
  String signerTokenUnchecked(String symbol) {
    return '$symbol（未驗證）';
  }

  @override
  String get signerReviewActions => '交易內容';

  @override
  String get signerNewerWalletNotice => '錢包版本比簽名機新，方便時請更新簽名機。';

  @override
  String get signerDangerBanner => '高風險操作。不是你本人發起的，不要簽。';

  @override
  String get signerActionSwap => '兌換';

  @override
  String get signerActionSwapDetail => '請在錢包上核對數量。';

  @override
  String get signerActionDangerDetail => '危險操作，看不懂就不要簽。';

  @override
  String get signerActionAdvanceNonce => '更新交易編號';

  @override
  String get signerActionSyncNative => '更新 SOL 餘額';

  @override
  String get signerHoldLongHint => '請仔細核對，按住 3 秒簽名。';

  @override
  String signerTokenVerified(String token) {
    return '$token · Benny Wallet 已驗證';
  }

  @override
  String signerTokenWalletProvided(String symbol) {
    return '$symbol · Benny Wallet 未驗證';
  }

  @override
  String signerSwapWalletQuote(String pay, String receive) {
    return '預計支付 $pay，收到約 $receive';
  }

  @override
  String get signerActionUnknown => '看不懂的操作';

  @override
  String signerActionCreateTokenAccountFor(String symbol) {
    return '開通 $symbol 帳戶';
  }

  @override
  String get signerUnresolvedAccounts => '簽名機看不全這筆交易。只有你本人剛發起時才簽。';

  @override
  String get signerTokenNotVerified => '未經 Benny Wallet 驗證';

  @override
  String get signerKindSwap => '兌換';

  @override
  String get signerKindSend => '發送';

  @override
  String signerAbout(String amount) {
    return '約 $amount';
  }

  @override
  String get signerAmountsFromWallet => '數量由錢包提供';

  @override
  String get signerTrustSafe => '幣都已通過 Benny Wallet 驗證';

  @override
  String get signerTrustCaution => '有一種幣未經 Benny Wallet 驗證，請小心。';

  @override
  String get signerTrustDangerSwap => '兩種幣都未經 Benny Wallet 驗證，高風險交易。';

  @override
  String get signerTrustDangerSend => '這個幣未經 Benny Wallet 驗證，高風險交易。';

  @override
  String get signerReviewOtherSteps => '其他步驟';

  @override
  String get signerPay => '支付';

  @override
  String get signerPayAtMost => '最多支付';

  @override
  String get signerGet => '獲得';

  @override
  String get signerGetAtLeast => '至少獲得';

  @override
  String get signerGetAbout => '約獲得';

  @override
  String get signerRecipient => '收款人';

  @override
  String get signerRecipientTokenAccount => '收款代幣帳戶';

  @override
  String get signerUsdFromWallet => '美金價值由錢包估算';

  @override
  String signerActionCreateTokenAccountForRecipient(String symbol) {
    return '幫收款人開通 $symbol 帳戶';
  }

  @override
  String get signerCreateAccountSkipIfOpen => '（第一次需付約 0.002 SOL；已開通會自動跳過，不扣費）';

  @override
  String get signerCreateAccountNotOpen => '（還沒開通，需付約 0.002 SOL）';

  @override
  String get signerAddressFromWallet => '此地址由錢包提供，簽名機無法核對。';

  @override
  String get signerSwapOutputUnchecked => '無法確認換到的幣會進入你的帳戶。';

  @override
  String get signerExtraOutflow => '這筆交易還會把資金轉到其他地址。';

  @override
  String signerHighFee(String amount) {
    return '網路費異常高：$amount SOL';
  }

  @override
  String get signerDurableNonce => '這個簽名永不過期，之後仍可被使用。';

  @override
  String get signerSwapFromWallet => '幣種或數量由錢包提供，無法核對。';

  @override
  String signerActionCloseTo(String address) {
    return '餘額和租金轉給 $address';
  }

  @override
  String signerWalletNote(String name) {
    return '錢包備註：$name';
  }

  @override
  String get signerReviewFeePayer => '手續費付款方';

  @override
  String signerActionOwnerProgram(String program) {
    return '由程式 $program 控制';
  }

  @override
  String get signerSlippageAll => '滑點達 100% 以上：可能什麼都換不到。';

  @override
  String get signerQuizTooManyWrong => '答錯太多次。請輸入 PIN 後再試。';

  @override
  String get signerSignInTitle => '登入請求';

  @override
  String get signerKindSignIn => '登入';

  @override
  String get signerSignInBenny => '登入 Benny Wallet';

  @override
  String signerSignInOtherSite(String site) {
    return '「$site」請求登入。只有你自己發起時才簽。';
  }

  @override
  String get signerSignInExpired => '這個登入請求已過期。請檢查本機時間，或在錢包重新開始。';

  @override
  String get signerSignInOtherAccount => '這是另一個帳戶的登入，不要簽。';

  @override
  String get signerSignInWhat => '證明這個帳戶是你的，Benny 才能顯示餘額、紀錄和通知。';

  @override
  String get signerSignInNoFunds => '不會轉帳，也不花手續費。';

  @override
  String get signerSignInShowText => '查看原文';

  @override
  String get airGapSignInTitle => '用簽名機登入';

  @override
  String get airGapSignInWhy => '為什麼要簽名？';

  @override
  String get airGapSignInWhyBody =>
      'Benny 要先確認這個帳戶是你的，才能讀取餘額、交易紀錄和通知。每個錢包通常只需做一次。';

  @override
  String get airGapSignInSafe => '這只是登入，不會轉帳，也不花手續費。';

  @override
  String airGapSignInSignerShows(String device) {
    return '「$device」上會顯示「登入 Benny Wallet」。';
  }

  @override
  String airGapSignInSignerShowsText(String device) {
    return '「$device」上會顯示一段英文，開頭是 “Benny Wallet wants you to sign in”，這就是這次登入。更新簽名機後會直接顯示「登入 Benny Wallet」。';
  }

  @override
  String get dappScanTitle => '连接网站';

  @override
  String get dappScanHint => '扫描网站上显示的 WalletConnect 二维码';

  @override
  String get dappPasteLink => '粘贴链接';

  @override
  String get dappScanNotWalletConnect => '这不是 WalletConnect 二维码';

  @override
  String get dappConnecting => '正在连接…';

  @override
  String get dappPairFailed => '连接失败，请在网站上刷新二维码再试。';

  @override
  String get dappNotConfigured => '这个版本不支持连接网站。';

  @override
  String get dappProposalTitle => '连接网站';

  @override
  String dappProposalWants(String site) {
    return '$site 请求连接你的钱包';
  }

  @override
  String get dappProposalCanDo => '连接后网站可以：';

  @override
  String get dappProposalSeeAddress => '查看你的钱包地址';

  @override
  String get dappProposalRequestSign => '请求你确认交易和消息签名';

  @override
  String get dappProposalNoAutoFunds => '网站不能自己动用资金，每一笔都要你确认。';

  @override
  String get dappProposalWallet => '钱包';

  @override
  String get dappProposalNoEligibleWallet => '你目前没有可以连接网站的钱包。外部钱包会在后续版本支持。';

  @override
  String get dappProposalOnlySolana => 'Benny Wallet 只支持 Solana，这个网站要求连接其他网络。';

  @override
  String get dappProposalUnsupportedChain =>
      '这个网站要求连接 Solana 测试网，Benny Wallet 只支持 Solana 主网。';

  @override
  String get dappConnect => '连接';

  @override
  String get dappReject => '拒绝';

  @override
  String dappConnected(String site) {
    return '已连接 $site';
  }

  @override
  String get dappSiteVerified => '已验证';

  @override
  String get dappSiteUnknown => '未验证';

  @override
  String get dappSiteMismatch => '域名不匹配';

  @override
  String get dappSiteScam => '已知诈骗网站';

  @override
  String get dappSitesTitle => '已连接网站';

  @override
  String get dappSitesEmpty => '还没有连接网站。在网站上扫描 WalletConnect 二维码即可连接。';

  @override
  String get dappSitesDisconnect => '断开';

  @override
  String get dappSitesDisconnectAll => '全部断开';

  @override
  String get dappSitesDisconnectAllConfirm => '要断开所有钱包上的全部网站吗？';

  @override
  String dappSitesExpires(String date) {
    return '$date 到期';
  }

  @override
  String dappSitesWallet(String name) {
    return '钱包：$name';
  }

  @override
  String dappSitesBanner(int count) {
    return '已连接 $count 个网站';
  }

  @override
  String get dappRequestTitle => '签名请求';

  @override
  String get dappRequestSignMessage => '签名一条消息';

  @override
  String dappRequestSignIn(String domain) {
    return '登录 $domain';
  }

  @override
  String get dappRequestTransaction => '确认交易';

  @override
  String dappRequestTransactions(int count) {
    return '确认 $count 笔交易';
  }

  @override
  String get dappRequestSendNote => '签名后由 Benny Wallet 发送。';

  @override
  String get dappRequestBalanceChanges => '预计余额变化';

  @override
  String get dappRequestNoBalanceChange => '除网络费外，这个钱包余额不变';

  @override
  String get dappRequestNetworkFee => '网络费';

  @override
  String get dappRequestMessage => '消息内容';

  @override
  String get dappRequestDetails => '详情';

  @override
  String get dappRequestPrograms => '调用的程序';

  @override
  String get dappActionTitle => '这笔交易会做什么';

  @override
  String get browserTitle => '浏览器';

  @override
  String get browserAddressHint => '输入网址，例如 jup.ag';

  @override
  String get browserReload => '刷新';

  @override
  String get browserHome => '首页';

  @override
  String get browserHomeHint =>
      '输入网址打开网站。在网站上点「连接钱包」并选择 Benny Wallet 即可连接，不用跳转，也不用再解锁。';

  @override
  String get browserNotConnected => '未连接';

  @override
  String browserConnectedAs(String wallet) {
    return '已连接：$wallet';
  }

  @override
  String get browserInvalidUrl => '网址无效';

  @override
  String get browserOpen => '打开';

  @override
  String get browserBookmarks => '收藏夹';

  @override
  String get browserBookmark => '收藏';

  @override
  String get browserBookmarked => '已收藏';

  @override
  String get browserBookmarkRemoved => '已取消收藏';

  @override
  String get browserBookmarkRemove => '删除';

  @override
  String get browserBookmarksEmpty => '打开网页后，点地址栏里的星标即可收藏。收藏只保存在这台手机上，不会同步。';

  @override
  String get browserBookmarksLocal => '只保存在这台手机上，不同步。';

  @override
  String get browserBack => '后退';

  @override
  String get browserForward => '前进';

  @override
  String get browserCopyLink => '复制链接';

  @override
  String get browserHomeTagline => '通往 Solana 应用的入口';

  @override
  String get browserBennyFeatures => 'Benny Apps';

  @override
  String get browserComingSoon => '即将到来';

  @override
  String get browserPopular => '推荐';

  @override
  String get browserYourSites => '连接过的网站';

  @override
  String get dappColdSwapNotice =>
      '这笔兑换交易大约 1 分钟内就会过期，冷钱包常常来不及签完。用冷钱包兑换，建议改用 Benny 内置的「兑换」：过期时会自动重新报价。';

  @override
  String get dappActionSwap => '兑换';

  @override
  String get dappActionTransfer => '转账';

  @override
  String get dappActionStake => '质押';

  @override
  String get dappActionLend => '借贷';

  @override
  String get dappActionPerps => '合约交易';

  @override
  String get dappActionNft => 'NFT 交易';

  @override
  String get dappActionOther => '其他操作';

  @override
  String dappActionVia(String protocol) {
    return '通过 $protocol';
  }

  @override
  String get dappActionPay => '你付出';

  @override
  String get dappActionReceive => '你收到';

  @override
  String get dappActionUnknownHint => 'Benny 看不懂这些程序在做什么。只有你刚在网站上亲手发起时才签。';

  @override
  String dappActionUnknownPrograms(int count) {
    return '未识别的程序（$count 个）';
  }

  @override
  String get dappActivityTitle => '历史连接';

  @override
  String get dappActivityNote =>
      '只保存在这台手机上，不上传云端，也不会备份。只记录网站、操作和金额，不记录消息内容或你的个人信息。';

  @override
  String get dappActivityEmpty => '还没有网站活动。';

  @override
  String get dappActivityClear => '清除记录';

  @override
  String get dappActivityClearConfirm => '要清除这台手机上的所有网站活动记录吗？';

  @override
  String dappActivityCount(int count) {
    return '$count 条记录';
  }

  @override
  String get dappActivityConnected => '已连接';

  @override
  String get dappActivityConnectRejected => '已拒绝连接';

  @override
  String get dappActivityMessage => '消息签名';

  @override
  String get dappActivitySigned => '已签名';

  @override
  String get dappActivitySent => '已发送';

  @override
  String get dappActivityRejected => '已拒绝';

  @override
  String get dappActivityFailed => '失败';

  @override
  String get dappActivityViewTx => '在 Solscan 查看';

  @override
  String get dappActivityViaPhone => '本机 App';

  @override
  String get dappActivityInBrowser => '内置浏览器';

  @override
  String dappActivityWallet(String wallet) {
    return '钱包 $wallet';
  }

  @override
  String get dappActivityDisconnected => '已断开';

  @override
  String dappSitesLastUsed(String date) {
    return '最近使用 $date';
  }

  @override
  String get dappActivityDetail => '明细';

  @override
  String get dappActivitySite => '网站';

  @override
  String get dappActivityTime => '时间';

  @override
  String get dappActivityVia => '连接方式';

  @override
  String get dappActivityViaWalletConnect => '扫码连接（WalletConnect）';

  @override
  String get dappActivityWalletLabel => '钱包';

  @override
  String get dappActivityTxId => '交易号';

  @override
  String get dappActivityCopied => '已复制';

  @override
  String get dappActivityResult => '结果';

  @override
  String get dappRequestSigningWallet => '签名钱包';

  @override
  String get dappRequestLoading => '正在检查请求…';

  @override
  String get dappRequestInvalid => '无法读取这个请求，已自动拒绝。';

  @override
  String get dappRequestSign => '签名';

  @override
  String get dappRequestHoldToSign => '长按签名';

  @override
  String get dappRequestAcceptRisk => '我了解风险，仍要签名';

  @override
  String get dappRequestBlocked => '为保护你的资金，Benny Wallet 已拦截这个请求。';

  @override
  String get dappRequestDone => '已签名，请回到网站。';

  @override
  String get dappRequestSent => '已发送，请回到网站。';

  @override
  String dappRequestFailed(String error) {
    return '签名失败：$error';
  }

  @override
  String get dappRequestRejected => '已拒绝请求';

  @override
  String get dappAuthReason => '确认签名';

  @override
  String get dappPinTitle => '输入 PIN 码签名';

  @override
  String get dappTrustSafe => '看起来正常';

  @override
  String get dappTrustCaution => '请仔细核对';

  @override
  String get dappTrustDanger => '高风险';

  @override
  String get dappTrustBlocked => '已拦截';

  @override
  String get dappWarnSiteScam => '这是已知的诈骗网站。';

  @override
  String get dappWarnSiteMismatch => '网站地址和它自称的应用不一致。';

  @override
  String get dappWarnSiteUnknown => '无法验证这个网站。';

  @override
  String get dappWarnMessageUnreadable => '消息不是可读文字，你无法知道自己签的是什么。';

  @override
  String get dappWarnMessageIsTransaction => '这条「消息」其实是一笔交易，签了可能会转走你的资金。';

  @override
  String get dappWarnSignInOtherSite => '登录对象和发出请求的网站不是同一个。';

  @override
  String get dappWarnSignInOtherAccount => '登录的是另一个钱包。';

  @override
  String get dappWarnSignInExpired => '这个登录请求已过期。';

  @override
  String get dappWarnTokenApprove => '允许其他账户动用你的代币。';

  @override
  String get dappWarnSetAuthority => '把你某个账户的控制权交给别人。';

  @override
  String get dappWarnAssignAccount => '更改你钱包账户的所有者。';

  @override
  String get dappWarnCloseAccount => '关闭一个代币账户。';

  @override
  String get dappWarnAdvanceNonce => '使用了持久随机数，签名会一直有效直到被使用。';

  @override
  String get dappWarnUnknownProgram => '调用了 Benny Wallet 不认识的程序。';

  @override
  String get dappWarnBlockedProgram => '调用了 Benny Wallet 黑名单上的危险程序，不能签名。';

  @override
  String get dappWarnUnresolvedAccounts => '部分账户无法查询。';

  @override
  String get dappWarnSimulationFailed => '模拟执行时交易失败。';

  @override
  String get dappWarnSimulationUnavailable => '无法预估余额变化。';

  @override
  String get dappWarnHighSlippage => '允许一笔可能什么都换不回来的兑换。';

  @override
  String dappRequestQueued(int count) {
    return '还有 $count 个请求在排队';
  }

  @override
  String airGapSignFromSite(String site) {
    return '這筆請求來自網站 $site，簽名機上也會顯示網站名稱。';
  }

  @override
  String airGapSignFromSiteStep(String site, int current, int total) {
    return '來自網站 $site：第 $current/$total 筆';
  }

  @override
  String get airGapSignerNoSiteSupport => '簽名機版本較舊，看不到網站來源。建議先更新簽名機。';

  @override
  String signerDappSource(String site) {
    return '來自網站 $site（由錢包轉交）';
  }

  @override
  String get signerDappSiteVerified => '錢包已驗證這個網站。';

  @override
  String get signerDappSiteUnverified => '錢包無法驗證這個網站。';

  @override
  String get signerDappSiteMismatch => '網站地址和它聲稱的不符，可能是假冒網站。';

  @override
  String get signerDappSiteScam => '這是已知的詐騙網站，不要簽。';

  @override
  String get signerDappSourceHint => '只有你剛在這個網站上親手操作時才簽。';

  @override
  String signerDappUnknownStep(String program) {
    return '簽名機看不懂這一步（程式 $program）。只有你剛在網站上親手操作時才簽。';
  }

  @override
  String get signerDappSimulation => '錢包模擬的餘額變化';

  @override
  String get signerDappSimulationNone => '除網路費外沒有餘額變化';

  @override
  String get signerDappSimulationNote => '由錢包模擬，簽名機無法核對，僅供參考。';

  @override
  String airGapSignSiteTimeLeft(String time) {
    return '網站還會等 $time';
  }

  @override
  String get airGapSignSiteExpired => '網站的請求可能已過期，請關閉後回到網站重新發起。';
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

  @override
  String get welcomeUseAsSigner => '把這台手機設為離線簽名機';

  @override
  String get walletAddAirGap => '連接離線簽名機';

  @override
  String get walletAddAirGapSubtitle => '私鑰留在另一台永不聯網的手機上';

  @override
  String createWalletWordCount(int count) {
    return '$count 個詞';
  }

  @override
  String get signerAppTitle => 'Benny 簽名機';

  @override
  String get signerNeedsNoWalletsTitle => '請先刪除所有錢包';

  @override
  String get signerNeedsNoWalletsBody =>
      '簽名機只保存自己離線產生或匯入的助記詞。請先備份，並在「設定 > 錢包」刪除這台手機上的所有錢包，然後再試一次。';

  @override
  String get signerEnterTitle => '把這台手機設為簽名機？';

  @override
  String get signerEnterBody =>
      '這台手機會一直保持離線，只負責簽名，不再顯示錢包頁面。之後如果要改回錢包，必須先清除簽名機。';

  @override
  String get signerIntroTitle => '離線簽名機';

  @override
  String get signerIntroPoint1 => '這台手機保存你的助記詞，之後不再聯網。';

  @override
  String get signerIntroPoint2 => '另一台手機上的 Benny Wallet 負責建立交易，你在這裡掃碼確認並簽名。';

  @override
  String get signerIntroPoint3 => '產生助記詞之前，會先引導你關閉所有網路。';

  @override
  String get signerIntroPoint4 => '請把助記詞抄在紙上，這是唯一的備份。';

  @override
  String get signerIntroStart => '開始設定';

  @override
  String get signerIntroCancel => '暫不設定，繼續當錢包使用';

  @override
  String get signerOfflineTitle => '讓手機完全離線';

  @override
  String get signerOfflineBody => '請開啟飛航模式，並關閉 Wi-Fi、藍牙和 NFC。所有必要項目都通過後才能繼續。';

  @override
  String get signerCheckAirplane => '已開啟飛航模式';

  @override
  String get signerCheckWifi => 'Wi-Fi 已關閉';

  @override
  String get signerCheckBluetooth => '藍牙已關閉';

  @override
  String get signerCheckNfc => 'NFC 已關閉';

  @override
  String get signerCheckNoNetwork => '沒有任何網路連線';

  @override
  String get signerCheckUsbDebugging => 'USB 偵錯已關閉';

  @override
  String get signerCheckSim => '已取出 SIM 卡（建議）';

  @override
  String get signerCheckManualHint => '此項無法自動偵測，請自行確認。';

  @override
  String get signerOpenSettings => '打開設定';

  @override
  String get signerNetworkDetected => '偵測到網路連線，請關閉後再繼續。';

  @override
  String get signerPinTitle => '設定簽名機 PIN 碼';

  @override
  String get signerPinBody => '請為簽名機設定 6 位數 PIN 碼。';

  @override
  String get signerPinConfirmTitle => '確認 PIN 碼';

  @override
  String get signerPinConfirmBody => '請再輸入一次 PIN 碼。';

  @override
  String get signerPinMismatch => '兩次輸入的 PIN 碼不一致，請重試。';

  @override
  String get signerSourceTitle => '助記詞';

  @override
  String get signerSourceBody => '在這台離線手機上產生新的助記詞，或輸入你已有的助記詞。';

  @override
  String get signerSourceCreate24 => '產生 24 個詞';

  @override
  String get signerSourceCreate24Subtitle => '簽名機建議使用';

  @override
  String get signerSourceCreate12 => '產生 12 個詞';

  @override
  String get signerSourceCreate12Subtitle => '抄寫較短';

  @override
  String get signerSourceImport => '匯入已有助記詞';

  @override
  String get signerSourceImportSubtitle => '支援 12 或 24 個詞';

  @override
  String get signerWordsTitle => '抄下這些詞';

  @override
  String get signerWordsWarning => '請按順序抄在紙上。不要拍照、截圖或輸入到其他地方。任何人拿到這些詞都能轉走你的資產。';

  @override
  String get signerWordsDone => '我已抄好';

  @override
  String get signerVerifyTitle => '核對備份';

  @override
  String get signerImportTitle => '匯入助記詞';

  @override
  String get signerImportBody => '請輸入 12 或 24 個詞，以空格分隔。';

  @override
  String get signerImportInvalid => '這不是有效的 12 或 24 個詞助記詞。';

  @override
  String get signerFinishTitle => '完成設定';

  @override
  String get signerDeviceNameLabel => '簽名機名稱';

  @override
  String get signerDeviceNameHelper => '連接後會顯示在錢包中。';

  @override
  String get signerBiometricToggle => '使用生物辨識解鎖';

  @override
  String get signerFinishButton => '完成';

  @override
  String get signerSetupFailed => '設定無法儲存，請重試。';

  @override
  String get signerUnlockSubtitle => '請輸入簽名機 PIN 碼';

  @override
  String get signerUnlockNetworkBlocked => '目前有網路連線，請開啟飛航模式後再解鎖。';

  @override
  String signerWrongPin(int count) {
    return 'PIN 碼錯誤。再錯 $count 次簽名機將被清除。';
  }

  @override
  String get signerUnlockFailed => '無法解鎖，請重試。';

  @override
  String get signerUseBiometric => '使用生物辨識';

  @override
  String get signerBiometricReason => '解鎖 Benny 簽名機';

  @override
  String get signerBiometricFailed => '無法更改生物辨識設定。';

  @override
  String get signerRecheckTitle => '離線檢查';

  @override
  String get signerRecheckBody => '應用已更新。解鎖前請確認這台手機已重新完全離線。';

  @override
  String get signerLockNow => '鎖定';

  @override
  String get signerOfflineChip => '離線簽名機';

  @override
  String get signerScanToSign => '掃碼簽名';

  @override
  String get signerPairWallet => '連接錢包';

  @override
  String get signerAccountsTitle => '帳戶';

  @override
  String signerAccountName(int number) {
    return '帳戶 $number';
  }

  @override
  String get signerPairBody => '在另一台手機的 Benny Wallet 選擇「連接離線簽名機」，然後掃描這個二維碼。';

  @override
  String get signerPairPublicOnly => '這個二維碼只包含公開地址，不含助記詞。';

  @override
  String get signerScanBody => '掃描另一台手機上 Benny Wallet 顯示的二維碼。';

  @override
  String get signerScanWrongCode => '這不是 Benny Wallet 的簽名請求。';

  @override
  String get signerScanAgain => '重新掃描';

  @override
  String get signerRejectUnknownAccount => '這個請求的帳戶不在這台簽名機上。';

  @override
  String get signerRejectNotASigner => '這筆交易不需要這個帳戶簽名。';

  @override
  String get signerRejectUnreadable => '無法解析這筆交易，因此不會簽名。';

  @override
  String get signerRejectMessageIsTransaction => '這則訊息實際上是一筆交易，因此不會簽名。';

  @override
  String get signerRejectInvalidCode => '這不是有效的簽名請求二維碼。';

  @override
  String get signerReviewTitle => '核對並簽名';

  @override
  String get signerReviewAccount => '簽名帳戶';

  @override
  String get signerReviewFee => '網路手續費';

  @override
  String get signerReviewMessage => '訊息';

  @override
  String signerBinaryMessage(int count) {
    return '二進位資料（$count 位元組）';
  }

  @override
  String get signerThisAccount => '本帳戶';

  @override
  String signerActionSendSol(String amount) {
    return '發送 $amount SOL';
  }

  @override
  String signerActionSendToken(String amount, String symbol) {
    return '發送 $amount $symbol';
  }

  @override
  String signerActionSendUnverified(String amount) {
    return '發送 $amount 個未驗證代幣';
  }

  @override
  String signerActionTo(String address) {
    return '至 $address';
  }

  @override
  String signerActionToTokenAccount(String address) {
    return '至代幣帳戶 $address';
  }

  @override
  String signerActionMint(String mint) {
    return '代幣地址 $mint';
  }

  @override
  String signerActionOwner(String address) {
    return '擁有者 $address';
  }

  @override
  String signerActionRentTo(String address) {
    return '租金退回至 $address';
  }

  @override
  String get signerActionCreateTokenAccount => '建立代幣帳戶';

  @override
  String get signerActionCloseTokenAccount => '關閉代幣帳戶';

  @override
  String get signerActionMemo => '備註';

  @override
  String get signerActionApprove => '允許其他帳戶動用你的代幣';

  @override
  String get signerActionSetAuthority => '更改帳戶權限';

  @override
  String get signerActionAssign => '更改帳戶擁有者';

  @override
  String get signerActionCreateAccount => '建立帳戶';

  @override
  String signerActionProgram(String program) {
    return '程式 $program';
  }

  @override
  String get signerHoldToSign => '按住簽名';

  @override
  String get signerReject => '拒絕';

  @override
  String get signerSignFailed => '簽名失敗，請重試。';

  @override
  String get signerSignatureTitle => '簽名結果';

  @override
  String get signerSignatureBody => '用另一台手機上的 Benny Wallet 掃描這個二維碼即可完成。';

  @override
  String get signerSettingsTitle => '簽名機設定';

  @override
  String get signerAccountCount => '顯示帳戶數';

  @override
  String get signerAccountCountHint => '此助記詞最多 5 個帳戶';

  @override
  String get signerUpgradeTitle => '更新簽名機';

  @override
  String get signerUpgradeIntro =>
      '更新應用需要聯網，請事先準備。聯網期間助記詞仍加密保存在手機中，簽名機要等手機重新離線後才會開啟。';

  @override
  String get signerUpgradeStep0 => '1. 核對紙本備份';

  @override
  String get signerUpgradeVerifyBackup => '核對備份';

  @override
  String get signerUpgradeBackupOk => '備份已核對';

  @override
  String get signerUpgradeOnlineTitle => '2a. 一般更新';

  @override
  String get signerUpgradeOnlineBody =>
      '先鎖定簽名機，再開啟網路，從原本安裝的商店更新 Benny Wallet。更新後重新開啟飛航模式。解鎖前簽名機會再次進行離線檢查。';

  @override
  String get signerUpgradeSecureTitle => '2b. 最高安全更新';

  @override
  String get signerUpgradeSecureBody =>
      '先在設定中清除簽名機，然後聯網更新應用。更新後重新離線，再次設定簽名機並匯入助記詞。帳戶和地址都不會改變。';

  @override
  String get signerUpgradeOfflineApkTitle => 'Android：不聯網更新';

  @override
  String get signerUpgradeOfflineApkBody =>
      '也可以用 USB 線或 SD 卡把新版 APK 複製到這台手機，在離線狀態下安裝。請使用與原本安裝相同來源的 APK，否則無法覆蓋安裝。';

  @override
  String get signerUpgradeCompatTitle => '舊版簽名機仍可使用';

  @override
  String get signerUpgradeCompatBody =>
      '新版錢包仍能配合舊版簽名機使用。錢包只會使用簽名機支援的功能，你可以在方便時再更新。';

  @override
  String get signerVersionTitle => '版本';

  @override
  String signerVersionDetail(String app, int protocol, int tokens) {
    return '應用 $app · 協議 $protocol · 代幣清單 $tokens';
  }

  @override
  String get signerEraseTitle => '清除簽名機';

  @override
  String get signerEraseSubtitle => '從這台手機刪除助記詞';

  @override
  String get signerEraseBody => '助記詞將從這台手機刪除。沒有紙本備份將無法找回資產。';

  @override
  String get signerEraseConfirm => '清除';

  @override
  String get signerEraseWrongPin => 'PIN 碼錯誤，未清除任何資料。';

  @override
  String get airGapConnectTitle => '連接離線簽名機';

  @override
  String get airGapConnectBody => '在簽名機上點「連接錢包」，然後掃描顯示的二維碼。';

  @override
  String get airGapConnectInvalid => '這不是簽名機的配對二維碼。';

  @override
  String airGapConnectChoose(String device) {
    return '選擇 $device 上的帳戶';
  }

  @override
  String airGapConnectAccount(int number) {
    return '帳戶 $number';
  }

  @override
  String airGapConnectAccountAdded(int number) {
    return '帳戶 $number（已新增）';
  }

  @override
  String get airGapConnectCompare => '請確認地址與簽名機上顯示的一致。';

  @override
  String get airGapConnectScanAgain => '重新掃描';

  @override
  String get airGapSignTitle => '用簽名機簽名';

  @override
  String get airGapSignShowRequestAgain => '重新顯示請求';

  @override
  String get airGapSignMayHaveExpired => '這筆交易可能已過期，若發送失敗請重新開始。';

  @override
  String get airGapSignWrongRequest => '這個簽名屬於另一個請求。';

  @override
  String get airGapSignInvalidCode => '這不是簽名機產生的簽名。';

  @override
  String get airGapSignerOutdated => '簽名機版本較舊，仍可正常使用，方便時再更新即可。';

  @override
  String get signerIntroSubtitle => '把私鑰放在一台永不聯網的手機上。';

  @override
  String get signerFinishSubtitle => '為這台簽名機取個名字，並設定 PIN 碼。';

  @override
  String signerQuizBody(int count) {
    return '請對照紙本備份，為 $count 個位置選出正確的詞。';
  }

  @override
  String signerQuizProgress(int current, int total) {
    return '第 $current / $total 題';
  }

  @override
  String signerQuizQuestion(int position) {
    return '第 $position 個詞是哪一個？';
  }

  @override
  String get signerQuizCorrect => '答對了！';

  @override
  String get signerQuizWrong => '選錯了。請再對照紙本，我們換了新的位置重新開始。';

  @override
  String get signerQuizShowWords => '再看一次助記詞';

  @override
  String get signerScanToSignSubtitle => '掃描錢包顯示的簽名請求';

  @override
  String get signerPairWalletSubtitle => '顯示二維碼讓 Benny Wallet 掃描';

  @override
  String get signerWalletPhoneLabel => 'Benny Wallet';

  @override
  String get signerScanRefusedTitle => '無法簽名';

  @override
  String get airGapSignerLabel => '簽名機';

  @override
  String get airGapThisPhone => '本機';

  @override
  String get airGapConnectFound => '已識別簽名機';

  @override
  String get airGapSignNeedsSigner => '需要由您的簽名機驗證並簽名';

  @override
  String get airGapSignStepShort1 => '簽名機掃碼';

  @override
  String get airGapSignStepShort2 => '掃描簽名';

  @override
  String airGapSignStep1Named(String device) {
    return '第一步：用簽名機「$device」掃描這個二維碼';
  }

  @override
  String airGapSignStep1BodyNamed(String device) {
    return '在「$device」點「掃碼簽名」，核對內容後確認。';
  }

  @override
  String airGapSignStep2Named(String device) {
    return '第二步：掃描簽名機「$device」上的簽名碼';
  }

  @override
  String airGapSignStep2BodyNamed(String device) {
    return '「$device」確認後會顯示簽名碼，用本機掃描。';
  }

  @override
  String airGapSignScanSignatureNamed(String device) {
    return '下一步：掃描「$device」的簽名';
  }

  @override
  String signerActionSwapPair(String from, String to) {
    return '兌換 $from → $to';
  }

  @override
  String signerSwapPay(String amount) {
    return '支付 $amount';
  }

  @override
  String signerSwapPayAtMost(String amount) {
    return '最多支付 $amount';
  }

  @override
  String signerSwapReceive(String amount) {
    return '收到 $amount';
  }

  @override
  String signerSwapReceiveAtLeast(String amount) {
    return '至少收到 $amount';
  }

  @override
  String get signerSwapUnverifiedToken => '未驗證代幣';

  @override
  String airGapSignTimeLeft(int seconds) {
    return '還剩 $seconds 秒，超時會自動換新的二維碼。';
  }

  @override
  String get airGapSignRefreshing => '時間到了，正在取得新的報價和二維碼…';

  @override
  String airGapSignRefreshed(String device) {
    return '上一個二維碼已過期，已自動換新。請用簽名機「$device」重新掃碼。';
  }

  @override
  String get airGapSignRefreshFailed => '無法取得新的二維碼，請檢查網路後重試。';

  @override
  String get airGapSignOldRequest => '這是舊二維碼的簽名，已經過期。請先用簽名機掃描新的二維碼。';

  @override
  String get scanHintRoleShows => '出示二維碼';

  @override
  String get scanHintRoleScans => '掃碼';

  @override
  String signerTokenUnchecked(String symbol) {
    return '$symbol（未驗證）';
  }

  @override
  String get signerReviewActions => '交易內容';

  @override
  String get signerNewerWalletNotice => '錢包版本比簽名機新，方便時請更新簽名機。';

  @override
  String get signerDangerBanner => '高風險操作。不是你本人發起的，不要簽。';

  @override
  String get signerActionSwap => '兌換';

  @override
  String get signerActionSwapDetail => '請在錢包上核對數量。';

  @override
  String get signerActionDangerDetail => '危險操作，看不懂就不要簽。';

  @override
  String get signerActionAdvanceNonce => '更新交易編號';

  @override
  String get signerActionSyncNative => '更新 SOL 餘額';

  @override
  String get signerHoldLongHint => '請仔細核對，按住 3 秒簽名。';

  @override
  String signerTokenVerified(String token) {
    return '$token · Benny Wallet 已驗證';
  }

  @override
  String signerTokenWalletProvided(String symbol) {
    return '$symbol · Benny Wallet 未驗證';
  }

  @override
  String signerSwapWalletQuote(String pay, String receive) {
    return '預計支付 $pay，收到約 $receive';
  }

  @override
  String get signerActionUnknown => '看不懂的操作';

  @override
  String signerActionCreateTokenAccountFor(String symbol) {
    return '開通 $symbol 帳戶';
  }

  @override
  String get signerUnresolvedAccounts => '簽名機看不全這筆交易。只有你本人剛發起時才簽。';

  @override
  String get signerTokenNotVerified => '未經 Benny Wallet 驗證';

  @override
  String get signerKindSwap => '兌換';

  @override
  String get signerKindSend => '發送';

  @override
  String signerAbout(String amount) {
    return '約 $amount';
  }

  @override
  String get signerAmountsFromWallet => '數量由錢包提供';

  @override
  String get signerTrustSafe => '幣都已通過 Benny Wallet 驗證';

  @override
  String get signerTrustCaution => '有一種幣未經 Benny Wallet 驗證，請小心。';

  @override
  String get signerTrustDangerSwap => '兩種幣都未經 Benny Wallet 驗證，高風險交易。';

  @override
  String get signerTrustDangerSend => '這個幣未經 Benny Wallet 驗證，高風險交易。';

  @override
  String get signerReviewOtherSteps => '其他步驟';

  @override
  String get signerPay => '支付';

  @override
  String get signerPayAtMost => '最多支付';

  @override
  String get signerGet => '獲得';

  @override
  String get signerGetAtLeast => '至少獲得';

  @override
  String get signerGetAbout => '約獲得';

  @override
  String get signerRecipient => '收款人';

  @override
  String get signerRecipientTokenAccount => '收款代幣帳戶';

  @override
  String get signerUsdFromWallet => '美金價值由錢包估算';

  @override
  String signerActionCreateTokenAccountForRecipient(String symbol) {
    return '幫收款人開通 $symbol 帳戶';
  }

  @override
  String get signerCreateAccountSkipIfOpen => '（第一次需付約 0.002 SOL；已開通會自動跳過，不扣費）';

  @override
  String get signerCreateAccountNotOpen => '（還沒開通，需付約 0.002 SOL）';

  @override
  String get signerAddressFromWallet => '此地址由錢包提供，簽名機無法核對。';

  @override
  String get signerSwapOutputUnchecked => '無法確認換到的幣會進入你的帳戶。';

  @override
  String get signerExtraOutflow => '這筆交易還會把資金轉到其他地址。';

  @override
  String signerHighFee(String amount) {
    return '網路費異常高：$amount SOL';
  }

  @override
  String get signerDurableNonce => '這個簽名永不過期，之後仍可被使用。';

  @override
  String get signerSwapFromWallet => '幣種或數量由錢包提供，無法核對。';

  @override
  String signerActionCloseTo(String address) {
    return '餘額和租金轉給 $address';
  }

  @override
  String signerWalletNote(String name) {
    return '錢包備註：$name';
  }

  @override
  String get signerReviewFeePayer => '手續費付款方';

  @override
  String signerActionOwnerProgram(String program) {
    return '由程式 $program 控制';
  }

  @override
  String get signerSlippageAll => '滑點達 100% 以上：可能什麼都換不到。';

  @override
  String get signerQuizTooManyWrong => '答錯太多次。請輸入 PIN 後再試。';

  @override
  String get signerSignInTitle => '登入請求';

  @override
  String get signerKindSignIn => '登入';

  @override
  String get signerSignInBenny => '登入 Benny Wallet';

  @override
  String signerSignInOtherSite(String site) {
    return '「$site」請求登入。只有你自己發起時才簽。';
  }

  @override
  String get signerSignInExpired => '這個登入請求已過期。請檢查本機時間，或在錢包重新開始。';

  @override
  String get signerSignInOtherAccount => '這是另一個帳戶的登入，不要簽。';

  @override
  String get signerSignInWhat => '證明這個帳戶是你的，Benny 才能顯示餘額、紀錄和通知。';

  @override
  String get signerSignInNoFunds => '不會轉帳，也不花手續費。';

  @override
  String get signerSignInShowText => '查看原文';

  @override
  String get airGapSignInTitle => '用簽名機登入';

  @override
  String get airGapSignInWhy => '為什麼要簽名？';

  @override
  String get airGapSignInWhyBody =>
      'Benny 要先確認這個帳戶是你的，才能讀取餘額、交易紀錄和通知。每個錢包通常只需做一次。';

  @override
  String get airGapSignInSafe => '這只是登入，不會轉帳，也不花手續費。';

  @override
  String airGapSignInSignerShows(String device) {
    return '「$device」上會顯示「登入 Benny Wallet」。';
  }

  @override
  String airGapSignInSignerShowsText(String device) {
    return '「$device」上會顯示一段英文，開頭是 “Benny Wallet wants you to sign in”，這就是這次登入。更新簽名機後會直接顯示「登入 Benny Wallet」。';
  }

  @override
  String get dappScanTitle => '連接網站';

  @override
  String get dappScanHint => '掃描網站上顯示的 WalletConnect QR 碼';

  @override
  String get dappPasteLink => '貼上連結';

  @override
  String get dappScanNotWalletConnect => '這不是 WalletConnect QR 碼';

  @override
  String get dappConnecting => '正在連接…';

  @override
  String get dappPairFailed => '連接失敗，請在網站上重新產生 QR 碼再試。';

  @override
  String get dappNotConfigured => '這個版本不支援連接網站。';

  @override
  String get dappProposalTitle => '連接網站';

  @override
  String dappProposalWants(String site) {
    return '$site 請求連接你的錢包';
  }

  @override
  String get dappProposalCanDo => '連接後網站可以：';

  @override
  String get dappProposalSeeAddress => '查看你的錢包地址';

  @override
  String get dappProposalRequestSign => '請求你確認交易和訊息簽名';

  @override
  String get dappProposalNoAutoFunds => '網站不能自行動用資金，每一筆都需要你確認。';

  @override
  String get dappProposalWallet => '錢包';

  @override
  String get dappProposalNoEligibleWallet => '你目前沒有可以連接網站的錢包。外部錢包會在後續版本支援。';

  @override
  String get dappProposalOnlySolana => 'Benny Wallet 只支援 Solana，這個網站要求連接其他網路。';

  @override
  String get dappProposalUnsupportedChain =>
      '這個網站要求連接 Solana 測試網，Benny Wallet 只支援 Solana 主網。';

  @override
  String get dappConnect => '連接';

  @override
  String get dappReject => '拒絕';

  @override
  String dappConnected(String site) {
    return '已連接 $site';
  }

  @override
  String get dappSiteVerified => '已驗證';

  @override
  String get dappSiteUnknown => '未驗證';

  @override
  String get dappSiteMismatch => '網域不符';

  @override
  String get dappSiteScam => '已知詐騙網站';

  @override
  String get dappSitesTitle => '已連接網站';

  @override
  String get dappSitesEmpty => '還沒有連接網站。在網站上掃描 WalletConnect QR 碼即可連接。';

  @override
  String get dappSitesDisconnect => '中斷連接';

  @override
  String get dappSitesDisconnectAll => '全部中斷';

  @override
  String get dappSitesDisconnectAllConfirm => '要中斷所有錢包上的全部網站嗎？';

  @override
  String dappSitesExpires(String date) {
    return '$date 到期';
  }

  @override
  String dappSitesWallet(String name) {
    return '錢包：$name';
  }

  @override
  String dappSitesBanner(int count) {
    return '已連接 $count 個網站';
  }

  @override
  String get dappRequestTitle => '簽名請求';

  @override
  String get dappRequestSignMessage => '簽署一則訊息';

  @override
  String dappRequestSignIn(String domain) {
    return '登入 $domain';
  }

  @override
  String get dappRequestTransaction => '確認交易';

  @override
  String dappRequestTransactions(int count) {
    return '確認 $count 筆交易';
  }

  @override
  String get dappRequestSendNote => '簽名後由 Benny Wallet 發送。';

  @override
  String get dappRequestBalanceChanges => '預估餘額變化';

  @override
  String get dappRequestNoBalanceChange => '除網路費外，這個錢包餘額不變';

  @override
  String get dappRequestNetworkFee => '網路費';

  @override
  String get dappRequestMessage => '訊息內容';

  @override
  String get dappRequestDetails => '詳情';

  @override
  String get dappRequestPrograms => '呼叫的程式';

  @override
  String get dappActionTitle => '這筆交易會做什麼';

  @override
  String get browserTitle => '瀏覽器';

  @override
  String get browserAddressHint => '輸入網址，例如 jup.ag';

  @override
  String get browserReload => '重新整理';

  @override
  String get browserHome => '首頁';

  @override
  String get browserHomeHint =>
      '輸入網址打開網站。在網站上點「連接錢包」並選擇 Benny Wallet 即可連接，不用跳轉，也不用再解鎖。';

  @override
  String get browserNotConnected => '未連接';

  @override
  String browserConnectedAs(String wallet) {
    return '已連接：$wallet';
  }

  @override
  String get browserInvalidUrl => '網址無效';

  @override
  String get browserOpen => '打開';

  @override
  String get browserBookmarks => '收藏夾';

  @override
  String get browserBookmark => '收藏';

  @override
  String get browserBookmarked => '已收藏';

  @override
  String get browserBookmarkRemoved => '已取消收藏';

  @override
  String get browserBookmarkRemove => '刪除';

  @override
  String get browserBookmarksEmpty => '打開網頁後，點網址列裡的星標即可收藏。收藏只保存在這台手機上，不會同步。';

  @override
  String get browserBookmarksLocal => '只保存在這台手機上，不同步。';

  @override
  String get browserBack => '上一頁';

  @override
  String get browserForward => '下一頁';

  @override
  String get browserCopyLink => '複製連結';

  @override
  String get browserHomeTagline => '通往 Solana 應用的入口';

  @override
  String get browserBennyFeatures => 'Benny Apps';

  @override
  String get browserComingSoon => '即將到來';

  @override
  String get browserPopular => '推薦';

  @override
  String get browserYourSites => '連接過的網站';

  @override
  String get dappColdSwapNotice =>
      '這筆兌換交易大約 1 分鐘內就會過期，冷錢包常常來不及簽完。用冷錢包兌換，建議改用 Benny 內建的「兌換」：過期時會自動重新報價。';

  @override
  String get dappActionSwap => '兌換';

  @override
  String get dappActionTransfer => '轉帳';

  @override
  String get dappActionStake => '質押';

  @override
  String get dappActionLend => '借貸';

  @override
  String get dappActionPerps => '合約交易';

  @override
  String get dappActionNft => 'NFT 交易';

  @override
  String get dappActionOther => '其他操作';

  @override
  String dappActionVia(String protocol) {
    return '透過 $protocol';
  }

  @override
  String get dappActionPay => '你付出';

  @override
  String get dappActionReceive => '你收到';

  @override
  String get dappActionUnknownHint => 'Benny 看不懂這些程式在做什麼。只有你剛在網站上親手發起時才簽。';

  @override
  String dappActionUnknownPrograms(int count) {
    return '未識別的程式（$count 個）';
  }

  @override
  String get dappActivityTitle => '歷史連接';

  @override
  String get dappActivityNote =>
      '只保存在這台手機上，不上傳雲端，也不會備份。只記錄網站、操作和金額，不記錄訊息內容或你的個人資料。';

  @override
  String get dappActivityEmpty => '還沒有網站活動。';

  @override
  String get dappActivityClear => '清除記錄';

  @override
  String get dappActivityClearConfirm => '要清除這台手機上的所有網站活動記錄嗎？';

  @override
  String dappActivityCount(int count) {
    return '$count 筆記錄';
  }

  @override
  String get dappActivityConnected => '已連接';

  @override
  String get dappActivityConnectRejected => '已拒絕連接';

  @override
  String get dappActivityMessage => '訊息簽名';

  @override
  String get dappActivitySigned => '已簽名';

  @override
  String get dappActivitySent => '已送出';

  @override
  String get dappActivityRejected => '已拒絕';

  @override
  String get dappActivityFailed => '失敗';

  @override
  String get dappActivityViewTx => '在 Solscan 查看';

  @override
  String get dappActivityViaPhone => '本機 App';

  @override
  String get dappActivityInBrowser => '內建瀏覽器';

  @override
  String dappActivityWallet(String wallet) {
    return '錢包 $wallet';
  }

  @override
  String get dappActivityDisconnected => '已斷開';

  @override
  String dappSitesLastUsed(String date) {
    return '最近使用 $date';
  }

  @override
  String get dappActivityDetail => '明細';

  @override
  String get dappActivitySite => '網站';

  @override
  String get dappActivityTime => '時間';

  @override
  String get dappActivityVia => '連接方式';

  @override
  String get dappActivityViaWalletConnect => '掃碼連接（WalletConnect）';

  @override
  String get dappActivityWalletLabel => '錢包';

  @override
  String get dappActivityTxId => '交易編號';

  @override
  String get dappActivityCopied => '已複製';

  @override
  String get dappActivityResult => '結果';

  @override
  String get dappRequestSigningWallet => '簽名錢包';

  @override
  String get dappRequestLoading => '正在檢查請求…';

  @override
  String get dappRequestInvalid => '無法讀取這個請求，已自動拒絕。';

  @override
  String get dappRequestSign => '簽名';

  @override
  String get dappRequestHoldToSign => '長按簽名';

  @override
  String get dappRequestAcceptRisk => '我了解風險，仍要簽名';

  @override
  String get dappRequestBlocked => '為保護你的資金，Benny Wallet 已攔截這個請求。';

  @override
  String get dappRequestDone => '已簽名，請回到網站。';

  @override
  String get dappRequestSent => '已送出，請回到網站。';

  @override
  String dappRequestFailed(String error) {
    return '簽名失敗：$error';
  }

  @override
  String get dappRequestRejected => '已拒絕請求';

  @override
  String get dappAuthReason => '確認簽名';

  @override
  String get dappPinTitle => '輸入 PIN 碼簽名';

  @override
  String get dappTrustSafe => '看起來正常';

  @override
  String get dappTrustCaution => '請仔細核對';

  @override
  String get dappTrustDanger => '高風險';

  @override
  String get dappTrustBlocked => '已攔截';

  @override
  String get dappWarnSiteScam => '這是已知的詐騙網站。';

  @override
  String get dappWarnSiteMismatch => '網站地址和它自稱的應用不一致。';

  @override
  String get dappWarnSiteUnknown => '無法驗證這個網站。';

  @override
  String get dappWarnMessageUnreadable => '訊息不是可讀文字，你無法知道自己簽的是什麼。';

  @override
  String get dappWarnMessageIsTransaction => '這則「訊息」其實是一筆交易，簽了可能會轉走你的資金。';

  @override
  String get dappWarnSignInOtherSite => '登入對象和發出請求的網站不是同一個。';

  @override
  String get dappWarnSignInOtherAccount => '登入的是另一個錢包。';

  @override
  String get dappWarnSignInExpired => '這個登入請求已過期。';

  @override
  String get dappWarnTokenApprove => '允許其他帳戶動用你的代幣。';

  @override
  String get dappWarnSetAuthority => '把你某個帳戶的控制權交給別人。';

  @override
  String get dappWarnAssignAccount => '變更你錢包帳戶的擁有者。';

  @override
  String get dappWarnCloseAccount => '關閉一個代幣帳戶。';

  @override
  String get dappWarnAdvanceNonce => '使用了持久隨機數，簽名會一直有效直到被使用。';

  @override
  String get dappWarnUnknownProgram => '呼叫了 Benny Wallet 不認識的程式。';

  @override
  String get dappWarnBlockedProgram => '呼叫了 Benny Wallet 黑名單上的危險程式，不能簽名。';

  @override
  String get dappWarnUnresolvedAccounts => '部分帳戶無法查詢。';

  @override
  String get dappWarnSimulationFailed => '模擬執行時交易失敗。';

  @override
  String get dappWarnSimulationUnavailable => '無法預估餘額變化。';

  @override
  String get dappWarnHighSlippage => '允許一筆可能什麼都換不回來的兌換。';

  @override
  String dappRequestQueued(int count) {
    return '還有 $count 個請求在排隊';
  }

  @override
  String airGapSignFromSite(String site) {
    return '這筆請求來自網站 $site，簽名機上也會顯示網站名稱。';
  }

  @override
  String airGapSignFromSiteStep(String site, int current, int total) {
    return '來自網站 $site：第 $current/$total 筆';
  }

  @override
  String get airGapSignerNoSiteSupport => '簽名機版本較舊，看不到網站來源。建議先更新簽名機。';

  @override
  String signerDappSource(String site) {
    return '來自網站 $site（由錢包轉交）';
  }

  @override
  String get signerDappSiteVerified => '錢包已驗證這個網站。';

  @override
  String get signerDappSiteUnverified => '錢包無法驗證這個網站。';

  @override
  String get signerDappSiteMismatch => '網站地址和它聲稱的不符，可能是假冒網站。';

  @override
  String get signerDappSiteScam => '這是已知的詐騙網站，不要簽。';

  @override
  String get signerDappSourceHint => '只有你剛在這個網站上親手操作時才簽。';

  @override
  String signerDappUnknownStep(String program) {
    return '簽名機看不懂這一步（程式 $program）。只有你剛在網站上親手操作時才簽。';
  }

  @override
  String get signerDappSimulation => '錢包模擬的餘額變化';

  @override
  String get signerDappSimulationNone => '除網路費外沒有餘額變化';

  @override
  String get signerDappSimulationNote => '由錢包模擬，簽名機無法核對，僅供參考。';

  @override
  String airGapSignSiteTimeLeft(String time) {
    return '網站還會等 $time';
  }

  @override
  String get airGapSignSiteExpired => '網站的請求可能已過期，請關閉後回到網站重新發起。';
}
