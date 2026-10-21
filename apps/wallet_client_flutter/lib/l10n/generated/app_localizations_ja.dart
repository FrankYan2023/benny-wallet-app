// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Benny Wallet';

  @override
  String get brandShortName => 'Benny';

  @override
  String get commonBack => '戻る';

  @override
  String get commonCancel => 'キャンセル';

  @override
  String get commonClose => '近い';

  @override
  String get commonContinue => '続く';

  @override
  String get commonConfirm => '確認する';

  @override
  String get commonCopied => 'コピーされました';

  @override
  String get commonCopy => 'コピー';

  @override
  String get commonDone => '終わり';

  @override
  String get commonLater => '後で';

  @override
  String get commonLoading => '読み込み中...';

  @override
  String get commonMax => 'MAX';

  @override
  String get commonNext => '次';

  @override
  String get commonOk => 'わかりました';

  @override
  String get commonRetry => 'リトライ';

  @override
  String get commonSettings => '設定';

  @override
  String get commonShare => '共有';

  @override
  String get commonUpdate => 'アップデート';

  @override
  String get languageSystem => 'システム';

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
  String get settingsLanguage => '言語';

  @override
  String get settingsLanguageSubtitle => 'アプリの言語を選択してください';

  @override
  String get settingsLanguageSystemDescription => 'このデバイスをフォローしてください';

  @override
  String get settingsLanguageSheetTitle => '言語';

  @override
  String get settingsLanguageSheetSubtitle => 'Benny で使用される言語を選択します。';

  @override
  String get settingsBiometricUnlock => '生体認証によるロック解除';

  @override
  String get settingsUseFingerprint => '指紋を使用する';

  @override
  String get settingsUnlockWalletToEnable => 'ウォレットのロックを解除して有効にします';

  @override
  String get settingsAutoLock => 'オートロック';

  @override
  String get settingsAutoLockSheetSubtitle => 'Benny が再度ロックされるタイミングを選択します。';

  @override
  String get settingsNotifications => '通知を受け取る';

  @override
  String get settingsNotificationsSubtitle => '資金が到着したらアラートを受け取る';

  @override
  String get settingsChildMode => 'チャイルドモード';

  @override
  String get settingsChildModeActive => 'チャイルドモードがアクティブです';

  @override
  String get settingsChildModeActiveDescription =>
      'ウォレットは、4 桁の子モード PIN が入力されるまで、受信専用モードのままになります。';

  @override
  String get settingsChildModeProtected => '4桁の子モードPINで保護';

  @override
  String get settingsChildModeRemoveAccounts => '有効にする前にすべての子アカウントを削除してください';

  @override
  String get settingsChildModeSetPin => '子モード用に別の 4 桁の PIN を設定します';

  @override
  String get settingsChildAccounts => '子アカウント';

  @override
  String get settingsRentReclaim => '家賃の返還';

  @override
  String get settingsRentReclaimSubtitle => '空のトークン アカウントを閉じて SOL を回復する';

  @override
  String get settingsFeedback => 'フィードバック';

  @override
  String get settingsFeedbackSubtitle => '問題を報告するか質問する';

  @override
  String get settingsLogOut => 'ログアウト';

  @override
  String get settingsLogOutSubtitle => 'ホーム画面に戻る';

  @override
  String get settingsIncorrectPin => '間違ったPIN';

  @override
  String get settingsPersistentBiometricUnsupported =>
      'このデバイスでは、永続的な生体認証によるロック解除はサポートされていません。';

  @override
  String get settingsBiometricsUnavailable => 'このデバイスでは生体認証は利用できません。';

  @override
  String get settingsBiometricEnabled => '生体認証の有効化';

  @override
  String get settingsBiometricDisabled => '生体認証が無効です';

  @override
  String get settingsUnlockBeforeBiometrics =>
      '生体認証を有効にする前にウォレットのロックを解除してください。';

  @override
  String get settingsNotificationsSystemDisabled =>
      '通知は無効になっています。システム設定でそれらを有効にします。';

  @override
  String get settingsNotificationsEnabled => '通知の受信を有効にする';

  @override
  String get settingsNotificationsDisabled => '通知の受信が無効になっています';

  @override
  String settingsNotificationsUpdateFailed(String error) {
    return '通知の更新に失敗しました: $error';
  }

  @override
  String get settingsRemoveChildAccountsFirst =>
      '子モードを有効にする前に、すべての子アカウントを削除してください。';

  @override
  String get settingsChildModeEnabled => 'チャイルドモードが有効になっています';

  @override
  String get settingsChildModeDisabled => 'チャイルドモードが無効になっています';

  @override
  String settingsChildModeUpdateFailed(String error) {
    return '子モードの更新に失敗しました: $error';
  }

  @override
  String get settingsCopyRecoveryPhraseFirst => 'まずリカバリフレーズをコピーしてください。';

  @override
  String get settingsLogOutWarning =>
      'ログアウトすると、このデバイス上のすべてのローカル アプリ データが消去されます。';

  @override
  String get settingsWalletUpToDate => 'Benny Walletは最新です。';

  @override
  String get settingsUpdateCheckFailed => '更新チェックに失敗しました';

  @override
  String get settingsUnableToCheckUpdates => '現在更新を確認できません。';

  @override
  String get settingsSeedPhraseBackup => 'シードフレーズのバックアップ';

  @override
  String get settingsSeedPhraseBackupDescription =>
      '物理コピーを安全な場所に保管することをお勧めします。';

  @override
  String get settingsSecureNow => '今すぐ安全を確保';

  @override
  String get settingsCheckingUpdates => 'チェック中...';

  @override
  String get settingsFullFeaturesUnlocked => '全機能が解放されました';

  @override
  String get settingsCheckForUpdates => 'アップデートをチェックする';

  @override
  String settingsVersion(String version) {
    return 'バージョン $version';
  }

  @override
  String settingsVersionBuild(String version, String buildNumber) {
    return 'バージョン $version+$buildNumber';
  }

  @override
  String get autoLockImmediate => 'すぐに';

  @override
  String get autoLockOneMinute => '1分';

  @override
  String get autoLockFiveMinutes => '5分';

  @override
  String get autoLockTenMinutes => '10分';

  @override
  String get autoLockThirtyMinutes => '30分';

  @override
  String get biometricUnlockReason => '生体認証を使用して Benny Wallet のロックを解除します。';

  @override
  String get biometricSetupReason => 'このセキュリティ機能を有効にするには、生体認証で認証してください。';

  @override
  String get unlockFailedTitle => 'ロック解除に失敗しました';

  @override
  String get unlockIncorrectPin => 'PIN が正しくありません。';

  @override
  String get unlockBiometricCancelled => '生体認証がキャンセルされました';

  @override
  String get unlockBiometricFailed => '生体認証によるロック解除に失敗しました。もう一度やり直してください。';

  @override
  String get unlockSessionExpired => 'セッションが期限切れになりました。PIN を使用してください';

  @override
  String get unlockBiometricUnavailable => '生体認証が利用できない';

  @override
  String get unlockUseFingerprint => '指紋を使用する';

  @override
  String get unlockEnterPin => 'PINを入力してください';

  @override
  String get pinConfirm => 'PINを確認する';

  @override
  String get pinSet => 'セット Benny PIN';

  @override
  String get pinMismatch => 'PIN は一致しません';

  @override
  String get pinImportFailed => 'インポートに失敗しました';

  @override
  String get pinExternalWalletSetupDescription =>
      'これにより、Benny 設定と子アカウントが保護されます。 Seeker は Seeker Wallet で署名キーを維持します。';

  @override
  String get childModeConfirmPinTitle => 'チャイルドモードPINの確認';

  @override
  String get childModeSetPinTitle => 'チャイルドモードの設定 PIN';

  @override
  String get childModeEnterPinTitle => 'チャイルドモードに入る PIN';

  @override
  String get childModeConfirmPinSubtitle => '子モードのみに使用される 4 桁の PIN を再入力します。';

  @override
  String get childModeSetPinSubtitle => '子モードのみに使用される 4 桁の PIN を作成します。';

  @override
  String get childModeEnterPinSubtitle =>
      '子モードのみをオフにするには、子モードのみに使用される 4 桁の PIN を入力します。';

  @override
  String get childModeOnlyUsed => '子モードでのみ使用されます';

  @override
  String get welcomeReplaceWalletTitle => '現在のウォレットを交換する';

  @override
  String get welcomeReplaceWalletMessage => '続行すると、現在のウォレットが削除されます。';

  @override
  String get welcomeConfirmAgainTitle => '再度確認';

  @override
  String get welcomeConfirmAgainMessage =>
      '削除すると、そのフレーズにアクセスできなくなる可能性があります。まず保存してください。';

  @override
  String get welcomeNewWalletSubtitle => '新しいデフォルトのウォレットを開始する';

  @override
  String get welcomeImportWalletSubtitleSeeker => 'フレーズまたはSeeker Vault';

  @override
  String get welcomeImportWalletSubtitlePhrase => 'リカバリフレーズから復元';

  @override
  String get welcomeHeroSemantics => 'Benny Wallet';

  @override
  String get welcomeHeroPrelude => '新しい財布が登場しました。';

  @override
  String get welcomeHeroTitle => 'Benny Wallet';

  @override
  String get welcomeHeroSubtitle => '新たに始めるか、リカバリフレーズを復元してください。';

  @override
  String get welcomeNewWallet => '新しい財布';

  @override
  String get welcomeImportWallet => 'インポートウォレット';

  @override
  String get createWalletTitle => 'ウォレットの作成';

  @override
  String get createWalletRecoveryTitle => 'リカバリフレーズを書き留めてください。';

  @override
  String get createWalletRecoverySubtitle => 'これがウォレットを回復する唯一の方法です。';

  @override
  String get webTestingOnly => 'Web はテスト専用です。';

  @override
  String get recoveryPhraseCopied => 'リカバリフレーズをコピーしました (15秒でク​​リアされます)';

  @override
  String get copyPhrase => 'コピーフレーズ';

  @override
  String get importWalletTitle => 'ウォレットをインポートする';

  @override
  String get importRecoveryPhraseTitle => 'リカバリフレーズをインポートする';

  @override
  String get importRecoveryPhraseSubtitle => '12 個または 24 個の英単語を使用します。';

  @override
  String get importPasteHint => 'ここに回復フレーズを貼り付けてください';

  @override
  String get importInvalidPhrase => '無効なリカバリフレーズです';

  @override
  String get importEnterWords => '12 または 24 の単語を入力または貼り付けます。';

  @override
  String importWordsDetected(int count) {
    return '$count ワードが検出されました';
  }

  @override
  String get importClear => 'クリア';

  @override
  String get seekerVaultConnectDescription =>
      'この Seeker にハードウェア バックアップされたウォレットを接続します。';

  @override
  String get seekerVaultConnect => '接続する';

  @override
  String get seekerVaultInstallOrEnable =>
      'Seeker Wallet をインストールまたは有効にして、再試行してください。';

  @override
  String get seekerVaultAndroidOnly => 'Seeker Vault インポートは Android でのみ使用できます。';

  @override
  String get seekerVaultNoAccounts =>
      'このシードに対して既存の Seed Vault ウォレット アカウントは返されませんでした。';

  @override
  String get seekerVaultUnavailable => 'Seed Vault はこのデバイスでは使用できません。';

  @override
  String get seekerVaultCancelled => 'Seeker Vault 接続がキャンセルされました。';

  @override
  String get seekerVaultConnectFailed =>
      '現在 Seeker Vault に接続できません。もう一度試してください。';

  @override
  String get receiveTitle => '受け取る';

  @override
  String get receivedHistoryTitle => '受信履歴';

  @override
  String get receiveShareAddressTitle => 'このアドレスを共有する';

  @override
  String get receiveShareAddressSubtitle => 'スキャンまたはコピーします。';

  @override
  String get receiveNoAddress => '利用可能なウォレットアドレスがありません';

  @override
  String get receiveNoAddressSubtitle => '資金を受け取るためにウォレットを作成またはロック解除します。';

  @override
  String get receiveAddressCopied => 'アドレスがコピーされました (60 秒後に消去されます)';

  @override
  String get receiveCopyAddress => 'アドレスをコピーする';

  @override
  String get sendTitle => '送信';

  @override
  String get sendChooseAssetTitle => 'アセットの選択';

  @override
  String get sendHistoryTitle => '送信履歴';

  @override
  String get sendUnavailableChildMode => '子モードでは送信できません。';

  @override
  String get sendOpenReceive => 'オープン受信';

  @override
  String get sendNoAssets => '送信できるアセットがありません。';

  @override
  String get sendRecipientPrefilled => '受信者が事前入力されています';

  @override
  String sendLoadAssetsFailed(String error) {
    return 'アセットのロードに失敗しました: $error';
  }

  @override
  String get sendAssetNotFound => 'アセットが見つかりません。';

  @override
  String sendAssetTitle(String symbol) {
    return '$symbol を送信する';
  }

  @override
  String get sendScanQrCode => 'QR コードをスキャンします';

  @override
  String get sendRecipientAddressHint => '受信者の Solana アドレス';

  @override
  String sendAvailableAmount(String amount, String symbol) {
    return '利用可能 $amount $symbol';
  }

  @override
  String sendLoadFormFailed(String error) {
    return '送信フォームの読み込みに失敗しました: $error';
  }

  @override
  String get sendInvalidAddress => '有効な Solana アドレスを入力してください。';

  @override
  String get sendInvalidAmount => '有効な金額を入力してください。';

  @override
  String get sendInsufficientBalance => 'バランスが不十分です。';

  @override
  String get sendUnlockAgain => '送信する前にウォレットのロックを再度解除してください。';

  @override
  String get sendNotEnoughSolAfterFee => 'ネットワーク料金を予約した後、SOL が足りません。';

  @override
  String get sendNotEnoughSolForFee => 'SOL ではネットワーク料金を賄うのに十分ではありません。';

  @override
  String get sendGenericFailure => '送信に失敗しました。もう一度試してください。';

  @override
  String get sendAmountHint => '額';

  @override
  String get portfolioChildAccounts => '子アカウント';

  @override
  String get portfolioCrypto => '暗号';

  @override
  String get portfolioStocks => '株式';

  @override
  String get portfolioMessages => 'メッセージ';

  @override
  String get portfolioTokens => 'トークン';

  @override
  String get portfolioDefi => 'DeFi';

  @override
  String get portfolioSend => '送信';

  @override
  String get portfolioSwap => 'スワップ';

  @override
  String get portfolioReceive => '受け取る';

  @override
  String get portfolioCouldNotRefreshAssets => 'アセットを更新できませんでした';

  @override
  String get portfolioPullToRetry => '下に引き下げて再試行してください。';

  @override
  String get portfolioDefiParentOnly => 'DeFi は親専用です';

  @override
  String get portfolioDefiParentOnlyMessage => '親モードに戻ってプロトコルの位置を確認します。';

  @override
  String get portfolioDefiUnavailable => 'DeFi データは一時的に利用できません';

  @override
  String get portfolioDefiUnavailableMessage => 'トークンはまだ最新です。';

  @override
  String get portfolioNoDefi => 'DeFi ポジションはまだありません';

  @override
  String get portfolioRefreshingDefi => 'プロトコルの位置を更新しています...';

  @override
  String get portfolioNoActiveDefi => 'あなたのウォレットにはアクティブな DeFi ポジションがありません。';

  @override
  String get portfolioRefreshFailed => '更新に失敗しました';

  @override
  String get portfolioNetworkBusy => '現在ネットワークが混雑しています。下に引き下げて再試行してください。';

  @override
  String get portfolioServerUnavailable =>
      'サーバーに到達できませんでした。接続を確認し、プルダウンして再試行してください。';

  @override
  String get portfolioRefreshAssetsFailed =>
      'アセットを更新できませんでした。下に引き下げて再試行してください。';

  @override
  String get portfolioReceiveSol => 'SOLを受信する';

  @override
  String get portfolioReceiveSolSubtitle => 'Benny Wallet を開始するには、SOL を受け取ります。';

  @override
  String get commonAdd => '追加';

  @override
  String get commonAmount => '額';

  @override
  String get commonAuto => '自動';

  @override
  String get commonBuy => '買う';

  @override
  String get commonConfirmed => '確認済み';

  @override
  String get commonCustom => 'カスタム';

  @override
  String get commonDelete => '消去';

  @override
  String get commonEdit => '編集';

  @override
  String get commonFrom => 'から';

  @override
  String get commonNetwork => 'ネットワーク';

  @override
  String get commonNetworkFee => 'ネットワーク料金';

  @override
  String get commonSave => '保存';

  @override
  String get commonSend => '送信';

  @override
  String get commonSignature => 'サイン';

  @override
  String get commonSolana => 'Solana';

  @override
  String get commonStatus => '状態';

  @override
  String get commonSubmitted => '提出済み';

  @override
  String get commonTo => 'に';

  @override
  String get commonToken => 'トークン';

  @override
  String get transactionTimeline => 'トランザクションのタイムライン';

  @override
  String get walletAddressUnavailable => 'ウォレットアドレスが利用できません。';

  @override
  String relativeSecondsAgo(Object count) {
    return '$count 年前';
  }

  @override
  String relativeMinutesAgo(Object count) {
    return '$count 分前';
  }

  @override
  String relativeHoursAgo(Object count) {
    return '$count時間前';
  }

  @override
  String relativeDaysAgo(Object count) {
    return '$count日前';
  }

  @override
  String get importWalletLoadingTitle => 'ウォレットをインポートしています...';

  @override
  String get importWalletLoadingSubtitle => 'Solana ウォレット リストを準備しています。';

  @override
  String get importSolanaMainnet => 'Solana Mainnet';

  @override
  String get importSelectSolanaAccount => 'インポートする Solana アカウントを選択します。';

  @override
  String get importLoadingSolanaAccounts => 'Solana アカウントをロードしています...';

  @override
  String get importCheckingActiveSolanaAccounts =>
      'アクティブな Solana アカウントを確認しています。';

  @override
  String get importUnableScanRecoveryPhrase => '現在、このリカバリ フレーズをスキャンできません。';

  @override
  String get importActiveAccount => 'アクティブなアカウント';

  @override
  String get importDefaultMainWallet => 'デフォルトのメインウォレット';

  @override
  String get seekerVaultTitle => 'Seeker Vault';

  @override
  String get seekerVaultChooseFundedAccount => '入金済みアカウントを選択してください';

  @override
  String get seekerVaultChooseAccount => 'アカウントを選択してください';

  @override
  String get seekerVaultFundedAccountFound =>
      'Benny は、この Seed Vault ウォレットでアカウント アクティビティを検出しました。';

  @override
  String get seekerVaultNoFundedAccountFound =>
      '入金されたアカウントは見つかりませんでした。これらは Seed Vault によって返されるアカウントです。';

  @override
  String seekerVaultAssetCount(Object count) {
    return '$count アセット';
  }

  @override
  String get seekerVaultNoAssets => '資産がありません';

  @override
  String get scanAddressTitle => 'スキャンアドレス';

  @override
  String get scanNoSolanaAddress => 'この QR コードには Solana アドレスが見つかりません。';

  @override
  String get scanPointCamera => 'カメラを Solana QR コードに向けます。';

  @override
  String get sendConfirmTitle => '送信の確認';

  @override
  String get sendSubmitting => '送信中...';

  @override
  String sendSubmittingSummary(Object address, Object amount, Object symbol) {
    return '$amount $symbol ～ $address';
  }

  @override
  String get sendSubmitted => '提出済み';

  @override
  String get sendFailed => '送信に失敗しました';

  @override
  String sendSubmittedMessage(Object address, Object amount, Object symbol) {
    return '$amount $symbol は $address に提出されました。確認には少し時間がかかる場合があります。';
  }

  @override
  String get sendTransactionCouldNotComplete => 'トランザクションを完了できませんでした。';

  @override
  String get sendViewTransaction => 'トランザクションの表示';

  @override
  String get sendRecipientNotReady => '受信者のウォレットはまだこのトークンを受信する準備ができていません。';

  @override
  String get sendNetworkBusy => 'ネットワークが混雑しています。もう一度試してください。';

  @override
  String get sendNetworkTakingLonger => 'ネットワークに予想より時間がかかっています。もう一度試してください。';

  @override
  String get sendHistoryEmpty => 'まだ送信履歴がありません。';

  @override
  String sendHistoryLoadFailed(Object error) {
    return '送信履歴をロードできません: $error';
  }

  @override
  String get sendDetailsTitle => '詳細を送信する';

  @override
  String get sendNotConfirmedYet => 'まだ確認されていません';

  @override
  String get sendOpenTokenDetails => 'オープントークンの詳細';

  @override
  String get sendViewOnSolscan => 'Solscanで見る';

  @override
  String get sendToEmpty => 'に  -';

  @override
  String sendToAddress(Object address) {
    return '$addressへ';
  }

  @override
  String get sendStatusFailed => '失敗した';

  @override
  String get sendStatusFinalized => '確定済み';

  @override
  String get sendStatusConfirmed => '確認済み';

  @override
  String get sendStatusSubmitted => '提出済み';

  @override
  String get sendStatusSourceHeliusWebhook => 'Helius Webhook';

  @override
  String get sendStatusSourceRpcSync => 'チェーンステータス同期';

  @override
  String get sendStatusSourceChainActivity => 'チェーンアクティビティ';

  @override
  String get sendTransactionFallbackTitle => 'トランザクションの送信';

  @override
  String get sendSubmittedToSender => '送信者に送信されました';

  @override
  String get sendSubmittedToSenderSubtitle =>
      'Helius 送信者は署名されたトランザクションを受け入れました。';

  @override
  String get sendAsyncResultFailed => '非同期結果が失敗しました';

  @override
  String get sendWaitingAsyncConfirmation => '非同期の確認を待っています';

  @override
  String get sendAsyncConfirmationReceived => '非同期確認を受信しました';

  @override
  String get sendUpdatedFromHeliusWebhook => 'Helius Webhook から更新されました。';

  @override
  String get sendUpdatedFromChainStatusSync => 'チェーンステータス同期から更新されました。';

  @override
  String get sendConfirmationNotReceivedYet => '確認はまだ受け取っていません。';

  @override
  String get swapTitle => 'スワップ';

  @override
  String get swapButton => 'スワップ';

  @override
  String get swapReviewTitle => 'レビュー交換';

  @override
  String swapForAmount(Object amount, Object symbol) {
    return '～$amount $symbolの場合';
  }

  @override
  String get swapPay => '支払う';

  @override
  String get swapReceive => '受け取る';

  @override
  String get swapMinimumReceive => '最小受信数';

  @override
  String get swapSlippage => '滑り';

  @override
  String get swapPriorityFee => '優先料金';

  @override
  String get swapRoute => 'ルート';

  @override
  String swapLamports(Object lamports) {
    return '$lamports ラムポート';
  }

  @override
  String get swapPriorityNormal => '普通';

  @override
  String get swapPriorityFast => '速い';

  @override
  String get swapPriorityTurbo => 'ターボ';

  @override
  String get swapProcessing => 'スワッピング...';

  @override
  String swapProcessingSummary(
    Object inputAmount,
    Object inputSymbol,
    Object outputAmount,
    Object outputSymbol,
  ) {
    return '$inputAmount $inputSymbol ～ $outputAmount $outputSymbol';
  }

  @override
  String get swapComplete => '交換完了';

  @override
  String get swapFailed => 'スワップに失敗しました';

  @override
  String swapReceivedAmount(Object amount, Object symbol) {
    return '$amount $symbol を受信しました';
  }

  @override
  String get swapCouldNotComplete => '交換を完了できませんでした。';

  @override
  String get swapTradingUnavailableChildMode => '子モードでは取引はできません。';

  @override
  String get swapNoBaseAssetsForXStocks =>
      'xStocks を購入できる SOL、USDC、または USDT はありません。';

  @override
  String get swapNoAssetsAvailable => 'スワップできるアセットがありません。';

  @override
  String get swapPayWith => 'で支払う';

  @override
  String get swapBuyXStock => 'xStockを購入する';

  @override
  String swapAvailable(Object amount, Object symbol) {
    return '利用可能 $amount $symbol';
  }

  @override
  String get swapRefreshingQuote => '爽やかな引用...';

  @override
  String swapRouteLabel(Object route) {
    return 'ルート: $route';
  }

  @override
  String get swapBestRoute => 'ベストルート';

  @override
  String swapFailedLoadWalletAssets(Object error) {
    return 'ウォレット資産のロードに失敗しました: $error';
  }

  @override
  String swapRateSummary(Object inputSymbol, Object outputSymbol, Object rate) {
    return '1 $inputSymbol ≈ $rate $outputSymbol';
  }

  @override
  String swapSlippageMin(Object value) {
    return '$value 分';
  }

  @override
  String swapCustomWithValue(Object value) {
    return 'カスタム・$value';
  }

  @override
  String swapMinReceive(Object amount) {
    return '最小 $amount';
  }

  @override
  String get swapAmountTooSmall => 'この量は有効なルートとしては小さすぎます。';

  @override
  String get swapWaitValidQuote => '続行する前に、有効な見積もりを待ってください。';

  @override
  String swapNotEnoughSolReserve(Object reserve) {
    return 'SOLが足りません。\n$reserve SOL の予備が必要です。';
  }

  @override
  String get swapRouteUnavailable =>
      'このスワップ ルートは現在利用できません。 SOL と交換するか、別のトークン ペアを選択してください。';

  @override
  String get swapPriceMoved => 'スワップが送信される前に価格が変動しました。滑りを大きくして再試行してください。';

  @override
  String get swapNotEnoughTokenBalance =>
      'トークン残高が足りません。もう一度「最大」をタップして再試行してください。';

  @override
  String get swapQuotesBusy => '引用は現在忙しいです。しばらくしてからもう一度試してください。';

  @override
  String get swapQuoteExpired => 'この見積もりは期限切れになりました。もう一度交換内容を見直します。';

  @override
  String get swapUnlockAgain => '交換する前に、ウォレットのロックを再度解除してください。';

  @override
  String get swapTransactionUnavailable => 'スワップ取引はご利用いただけません。';

  @override
  String get swapConnectSeekerVaultAgain => '交換する前にSeeker Vaultを再度接続してください。';

  @override
  String get swapConnectSeedVaultAgain => '交換する前にSeed Vaultを再度接続してください。';

  @override
  String get swapUnexpectedSignatureCount => 'ウォレットから予期しない署名数が返されました。';

  @override
  String get swapCustomSlippageLabel => 'カスタムスリッページ%';

  @override
  String get swapChooseToken => '選ぶ';

  @override
  String get swapApproxYouReceive => '約あなたは受け取ります';

  @override
  String get swapRate => 'レート';

  @override
  String get swapPlatformFee => 'プラットフォーム料金';

  @override
  String get swapSearchTokenHint => 'トークン名またはシンボルを検索';

  @override
  String get swapNoTokensAvailable => '利用可能なトークンがありません';

  @override
  String swapNoResultsFor(Object query) {
    return '「$query」に一致する結果はありませんでした';
  }

  @override
  String get swapYourAssets => 'あなたの資産';

  @override
  String get swapSuggestedTokens => '推奨されるトークン';

  @override
  String swapAvailableBalance(Object amount) {
    return '$amountが利用可能';
  }

  @override
  String get assetNotFound => 'アセットが見つかりません。';

  @override
  String get assetPosition => '位置';

  @override
  String get assetValue => '価値';

  @override
  String get assetBalance => 'バランス';

  @override
  String get assetReturn24h => '24時間返却';

  @override
  String get assetInfo => '情報';

  @override
  String get assetName => '名前';

  @override
  String get assetSymbol => 'シンボル';

  @override
  String get assetMint => 'ミント';

  @override
  String get assetWebsite => 'Webサイト';

  @override
  String get assetPrice => '価格';

  @override
  String get assetMarketCap => '時価総額';

  @override
  String get assetFdv => 'FDV';

  @override
  String get assetTotalSupply => '総供給量';

  @override
  String get assetCirculatingSupply => '循環供給';

  @override
  String get assetHolders => 'ホルダー';

  @override
  String get assetCreated => '作成されました';

  @override
  String get assetPerformance24h => '24時間パフォーマンス';

  @override
  String get assetVolume => '音量';

  @override
  String get assetTraders => 'トレーダー';

  @override
  String get assetSafety => '安全性';

  @override
  String get assetTop10Holders => '上位10位の保有者';

  @override
  String get assetMarketStatsUnavailable => '一部の市場統計は現在利用できません。';

  @override
  String get assetActivity => '活動';

  @override
  String get assetNoActivity => 'まだ活動はありません。';

  @override
  String get assetActivityLoadFailed => 'アクティビティをロードできませんでした。';

  @override
  String assetLoadDetailsFailed(Object error) {
    return 'アセットの詳細のロードに失敗しました: $error';
  }

  @override
  String get assetMintCopied => 'ミントがコピーされました (60 秒後にクリアされます)';

  @override
  String get assetCouldNotOpenWebsite => 'ウェブサイトを開けませんでした。';

  @override
  String get assetSwapOut => 'スワップアウト';

  @override
  String get assetSwapIn => 'スワップイン';

  @override
  String assetToSymbol(Object symbol) {
    return '$symbolへ';
  }

  @override
  String assetFromSymbol(Object symbol) {
    return '$symbolから';
  }

  @override
  String get assetSent => '送信済み';

  @override
  String get assetReceived => '受け取った';

  @override
  String get assetTransfer => '移行';

  @override
  String assetSwapWithTime(Object time) {
    return 'スワップ • $time';
  }

  @override
  String assetCounterpartyWithTime(Object address, Object time) {
    return '$address・$time';
  }

  @override
  String get notificationsMarkAllRead => 'すべて既読としてマークする';

  @override
  String get notificationsUnavailableTitle => 'メッセージが利用できません';

  @override
  String get notificationsUnavailableSubtitle => '現在メッセージを読み込むことができません。';

  @override
  String get notificationsEmptyTitle => 'まだメッセージはありません';

  @override
  String get notificationsEmptySubtitle => 'プッシュ メッセージは到着後、ここに表示されます。';

  @override
  String get notificationDeleted => 'メッセージが削除されました';

  @override
  String get receivedHistoryEmpty => 'まだ受信履歴がありません。';

  @override
  String receivedHistoryLoadFailed(Object error) {
    return '受信履歴をロードできません: $error';
  }

  @override
  String get receivedDetailsTitle => '受信した詳細';

  @override
  String get receivedDetailsMissingId => 'このメッセージには、受信した転送 ID は含まれません。';

  @override
  String receivedDetailsLoadFailed(Object error) {
    return 'この受信した転送をロードできません: $error';
  }

  @override
  String get receivedFundsTitle => '受け取った資金';

  @override
  String receivedYouReceived(Object amount) {
    return '$amount を受け取りました';
  }

  @override
  String receivedYouReceivedInWallet(String amount, String wallet) {
    return '$wallet に $amount を受け取りました';
  }

  @override
  String get receivedFromEmpty => 'から  -';

  @override
  String receivedFromAddress(Object address) {
    return '$addressから';
  }

  @override
  String get receivedRelatedChanges => '関連する変更';

  @override
  String get receivedOnSolana => 'Solanaで受信';

  @override
  String get receivedMarkedFailed => '受信イベントは失敗としてマークされました。';

  @override
  String get receivedArrived => 'このウォレットに資金が到着しました。';

  @override
  String get receivedNewFundsArrived => '新しい資金があなたのウォレットに到着しました。';

  @override
  String get childVerifyPinTitle => 'PIN を確認する';

  @override
  String get childWalletAlreadyAdded => 'この子ウォレットはすでに追加されています。';

  @override
  String childWalletAdded(Object name) {
    return '$name が正常に追加されました';
  }

  @override
  String childWalletAddFailed(Object error) {
    return '子ウォレットの追加に失敗しました: $error';
  }

  @override
  String childWalletUpdated(Object name) {
    return '$name が正常に更新されました';
  }

  @override
  String childWalletUpdateFailed(Object error) {
    return '子ウォレットの更新に失敗しました: $error';
  }

  @override
  String childWalletDeleteTitle(Object name) {
    return '$nameを削除しますか?';
  }

  @override
  String get childWalletDeleteMessage => 'この子ウォレットのエントリは親の監視から削除されます。';

  @override
  String childWalletDeleted(Object name) {
    return '$name が削除されました';
  }

  @override
  String childWalletDeleteFailed(Object error) {
    return '子ウォレットの削除に失敗しました: $error';
  }

  @override
  String get childAccountsTitle => '子アカウント';

  @override
  String get childManageUnavailable => '子アカウントを管理するには、子モードをオフにしてください。';

  @override
  String get childNoAccountsYet => '子アカウントはまだありません';

  @override
  String childAccountCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '子アカウント $count 件',
      one: '子アカウント 1 件',
    );
    return '$_temp0';
  }

  @override
  String get childAddAccount => '子アカウントの追加';

  @override
  String get childEditAccount => '子アカウントの編集';

  @override
  String get childName => '子供の名前';

  @override
  String get childNameHint => '例えばアリス';

  @override
  String get childWalletAddress => '子ウォレットアドレス';

  @override
  String get childScanAgain => '再スキャン';

  @override
  String get childScanQrAgain => 'QR コードを再度スキャンする';

  @override
  String get childEnterName => 'お子様のお名前を入力してください。';

  @override
  String get childEnterValidWalletAddress => '有効なウォレットアドレスを入力してください。';

  @override
  String get childWalletTitle => '子供財布';

  @override
  String get childWalletNotFound => '子ウォレットが見つかりません';

  @override
  String get childAddressCopied => 'アドレスをクリップボードにコピーしました';

  @override
  String get childTotalBalance => '合計残高';

  @override
  String get childSendToChildWallet => '子ウォレットに送信';

  @override
  String get childNoAssets => '資産がありません';

  @override
  String get childAssets => '資産';

  @override
  String childWalletLoadFailed(Object error) {
    return '子ウォレットの読み込みエラー: $error';
  }

  @override
  String get feedbackHeading => '何が問題だったのか教えてください';

  @override
  String get feedbackSubtitle => '質問や問題を Benny Wallet サポートに直接送信してください。';

  @override
  String get feedbackEmailOptional => '電子メール (オプション)';

  @override
  String get feedbackMessage => 'メッセージ';

  @override
  String get feedbackMessageHint => '発生している問題について説明してください。';

  @override
  String get feedbackSending => '送信中...';

  @override
  String get feedbackMessageRequiredTitle => 'メッセージは必須です';

  @override
  String get feedbackMessageRequiredMessage => '送信する前にフィードバックを入力してください。';

  @override
  String get feedbackMessageTooLongTitle => 'メッセージが長すぎます';

  @override
  String get feedbackMessageTooLongMessage => 'フィードバックは 2000 文字以内にしてください。';

  @override
  String get feedbackInvalidEmailTitle => '無効な電子メール';

  @override
  String get feedbackInvalidEmailMessage => '有効な電子メール アドレスを入力するか、空のままにしてください。';

  @override
  String get feedbackSent => 'メッセージは送信されました。';

  @override
  String get feedbackSendFailedTitle => '送信失敗';

  @override
  String get feedbackSendFailedFallback =>
      '現在メッセージを送信できません。しばらくしてからもう一度お試しください。';

  @override
  String get rentTitle => 'Solana 家賃回収';

  @override
  String get rentDescription => '空のトークン アカウントを閉鎖し、そのレンタルをメインの SOL 残高に戻します。';

  @override
  String get rentWalletAddress => 'ウォレットアドレス';

  @override
  String get rentClosableTokenAccounts => '閉鎖可能なトークンアカウント';

  @override
  String get rentReclaimableRent => '回収可能な家賃';

  @override
  String get rentAccountsToClose => '閉鎖するアカウント';

  @override
  String rentMoreAccounts(Object count) {
    return '+$count 個以上のアカウントが回収されます。';
  }

  @override
  String get rentReclaiming => '回収中...';

  @override
  String get rentNothingToReclaim => '取り戻すものは何もない';

  @override
  String get rentReclaimAll => '家賃を全額取り戻す';

  @override
  String get rentReclaimingRent => '家賃の返還…';

  @override
  String get rentSubmittingTransactions => '現在クローズアカウントトランザクションを送信しています。';

  @override
  String get rentUnlockRequiredTitle => 'ロック解除が必要です';

  @override
  String get rentUnlockRequiredMessage => '家賃を取り戻す前に、ウォレットのロックを再度解除してください。';

  @override
  String get rentReclaimFailedTitle => '再利用に失敗しました';

  @override
  String get rentWalletRequiredTitle => 'ウォレットが必要です';

  @override
  String get rentConnectSeekerVaultAgain =>
      '家賃を回収する前に Seeker Vault を再度接続してください。';

  @override
  String get rentConnectSeedVaultAgain => '家賃を回収する前に Seed Vault を再度接続してください。';

  @override
  String rentSubmittedTransactions(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '回収トランザクション $count 件を送信しました',
      one: '回収トランザクション 1 件を送信しました',
    );
    return '$_temp0。';
  }

  @override
  String rentSubmittedTransactionsWithSkipped(num skipped, num submitted) {
    String _temp0 = intl.Intl.pluralLogic(
      submitted,
      locale: localeName,
      other: '回収トランザクション $submitted 件を送信しました',
      one: '回収トランザクション 1 件を送信しました',
    );
    String _temp1 = intl.Intl.pluralLogic(
      skipped,
      locale: localeName,
      other: '$skipped 個のアカウント',
      one: '1 個のアカウント',
    );
    return '$_temp0。$_temp1をスキップしました。';
  }

  @override
  String get rentUnableScan => '現在、再利用可能なトークン アカウントをスキャンできません。';

  @override
  String rentMintAddress(Object address) {
    return 'ミント $address';
  }

  @override
  String get airdropTitle => 'BYC エアドロップ';

  @override
  String get airdropUnavailableTitle => 'BYC エアドロップは一時的に利用できなくなります';

  @override
  String get airdropUnlockBeforeJoin => 'BYC エアドロップに参加する前にウォレットのロックを解除してください。';

  @override
  String get airdropJoinDialogTitle => 'BYC エアドロップに参加しますか?';

  @override
  String airdropJoinDialogMessage(Object address) {
    return '現在の Benny ウォレット アドレスを使用します。\n\n$address\n\nこのアドレスは、Airdrop プロファイルを登録するために Benny バックエンドに送信されます。';
  }

  @override
  String get airdropJoin => '参加する';

  @override
  String get airdropJoinedSnack => 'BYC 報酬プロファイルの準備が完了しました。';

  @override
  String get airdropJoinBeforeCheckIn => 'チェックインする前に BYC エアドロップに参加してください。';

  @override
  String get airdropUnlockBeforeCheckIn => 'チェックインする前にウォレットのロックを解除してください。';

  @override
  String get airdropJoined => '参加しました';

  @override
  String get airdropNotJoined => '未加入';

  @override
  String get airdropBycPoints => 'BYC ポイント';

  @override
  String get airdropStreak => 'ストリーク';

  @override
  String airdropDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 日',
      one: '1 日',
    );
    return '$_temp0';
  }

  @override
  String get airdropWalletUnavailable => 'ウォレットが利用できません';

  @override
  String get airdropJoinCardTitle => 'エアドロップに参加する';

  @override
  String get airdropJoinCardSubtitle =>
      'アクティブな Benny ウォレットを確認し、BYC 報酬プロファイルを作成します。';

  @override
  String get airdropJoining => '接合...';

  @override
  String get airdropJoinWithThisWallet => 'このウォレットで参加する';

  @override
  String get airdropCheckInNow => '今すぐチェックイン';

  @override
  String get airdropCheckedInToday => '今日チェックインしました';

  @override
  String airdropNextReward(Object points) {
    return '次の報酬: +$points BYC';
  }

  @override
  String get airdropComeBackTomorrow => '明日また来て、さらに BYC を獲得してください。';

  @override
  String get airdropCheckingIn => 'チェックイン中...';

  @override
  String airdropLastClaimed(Object date) {
    return '最後に申請した $date';
  }

  @override
  String get airdropRewardRules => '報酬ルール';

  @override
  String get airdropFirstCheckIn => '最初のチェックイン';

  @override
  String get airdropNextDayReward => '翌日のご褒美';

  @override
  String airdropEveryDayStreak(Object days) {
    return '$days 日の連続記録ごと';
  }

  @override
  String get airdropUnableOpenPumpFun => '現在 Pump.fun を開けません。';

  @override
  String get airdropView => 'ビュー';

  @override
  String get airdropPointsBalanceUpdated => 'Benny ポイントの残高が更新されました。';

  @override
  String get airdropFirstCheckInUnlocked => '初回チェックインのロックが解除されました';

  @override
  String get airdropStreakBonusLanded => '連続ボーナスが発生しました';

  @override
  String get airdropAlreadyClaimedToday => '今日すでに申請済み';

  @override
  String get airdropRewardClaimed => '報酬の請求';

  @override
  String get defiTypeDeposit => 'デポジット';

  @override
  String get defiTypeBorrow => '借りる';

  @override
  String get defiTypeStaking => 'ステーキング';

  @override
  String get defiTypeLiquidity => '流動性';

  @override
  String get defiTypeYield => '収率';

  @override
  String get defiTypePerps => '犯人';

  @override
  String get defiTypeRewards => '報酬';

  @override
  String get defiTypePosition => '位置';

  @override
  String get settingsSeekerWallet => 'Seeker Wallet';

  @override
  String get updateDefaultTitle => '利用可能なアップデート';

  @override
  String get updateDefaultMessage => 'Benny Wallet の新しいバージョンが利用可能です。';

  @override
  String get updateFailedTitle => '更新に失敗しました';

  @override
  String get updateUnableToOpen => '現在、Benny Wallet 更新リンクを開けません。';

  @override
  String get routerFeatureUnavailableTitle => '利用できない機能';

  @override
  String get routerFeatureUnavailableMessage => 'この機能はこのビルドでは使用できません。';

  @override
  String get routerMessageUnavailableTitle => 'メッセージが利用できません';

  @override
  String get routerMessageUnavailableMessage => 'まず、メッセージ一覧から受信したメッセージを開きます。';

  @override
  String get routerSendDetailsUnavailableTitle => '送信詳細は利用できません';

  @override
  String get routerSendDetailsUnavailableMessage => 'まず送信履歴からトランザクションを開きます。';

  @override
  String get routerInvalidChildWalletId => '子ウォレットIDが無効です';

  @override
  String routerRouteNotFound(String uri) {
    return 'ルートが見つかりません: $uri';
  }

  @override
  String get walletsTitle => 'ウォレット';

  @override
  String get walletsSubtitle => 'ウォレットの切替・追加・名前変更・削除';

  @override
  String get walletSwitcherTitle => 'マイウォレット';

  @override
  String walletSwitcherCount(int count, int max) {
    return '$count/$max';
  }

  @override
  String get walletAddWallet => 'ウォレットを追加';

  @override
  String walletAddLimitReached(int max) {
    return 'ウォレットは最大 $max 個まで追加できます。';
  }

  @override
  String get walletManage => '管理';

  @override
  String get walletAddSheetTitle => 'ウォレットを追加';

  @override
  String get walletAddSheetSubtitle =>
      '各ウォレットは独自のリカバリーフレーズとアカウントを持ち、1つのPINですべて解除できます。';

  @override
  String get walletAddCreate => '新しいウォレットを作成';

  @override
  String get walletAddCreateSubtitle => '新しいリカバリーフレーズを生成';

  @override
  String get walletAddImport => 'リカバリーフレーズをインポート';

  @override
  String get walletAddImportSubtitle => '別のフレーズや別アカウントを使用';

  @override
  String get walletAddSeedVault => 'Seed Vault を接続';

  @override
  String get walletAddSeedVaultSubtitle => 'Seeker のアカウントを使用';

  @override
  String get walletNameTitle => 'ウォレットに名前を付ける';

  @override
  String get walletNameSubtitle => 'この端末にのみ保存され、いつでも変更できます。';

  @override
  String get walletNameLabel => 'ウォレット名';

  @override
  String get walletNameEmpty => 'ウォレット名を入力してください';

  @override
  String walletAdded(String name) {
    return '$name を追加しました';
  }

  @override
  String walletSwitched(String name) {
    return '$name に切り替えました';
  }

  @override
  String get walletDuplicateTitle => '追加済み';

  @override
  String get walletDuplicateMessage =>
      'このフレーズとアカウントは既に追加されています。同じフレーズ＋アカウントは1回のみ追加できます。';

  @override
  String get walletAlreadyAddedBadge => '追加済み';

  @override
  String get walletRename => '名前を変更';

  @override
  String get walletRenameTitle => 'ウォレット名を変更';

  @override
  String get walletRemove => '削除';

  @override
  String walletRemoveTitle(String name) {
    return '$name を削除しますか？';
  }

  @override
  String get walletRemoveMessage =>
      'この端末からウォレットを削除します。先にリカバリーフレーズをバックアップしてください。ないと資産を復元できません。';

  @override
  String get walletRemoveExternalMessage =>
      'Benny との接続を解除します。鍵は Seed Vault に安全に保管されたままです。';

  @override
  String walletRemoved(String name) {
    return '$name を削除しました';
  }

  @override
  String get walletActiveBadge => '使用中';

  @override
  String get walletTypePhrase => 'リカバリーフレーズ';

  @override
  String get walletTypeSeedVault => 'Seed Vault';

  @override
  String get swapWalletChanged => '使用中のウォレットが変わりました。戻って見積もりを取り直してください。';

  @override
  String seedVaultPickNamedSeed(String seed, String wallet) {
    return '次にシード「$seed」を選択してください。$wallet はこのシードにあります。';
  }

  @override
  String seedVaultPickUnknownSeed(String wallet) {
    return '$wallet を含むシードを選択してください。違うシードを選んだ場合はお知らせし、そのシードは一覧から消えます。';
  }

  @override
  String seedVaultWrongSeedNamed(String seed) {
    return 'シード「$seed」にこのウォレットはありません。';
  }

  @override
  String get seedVaultReauthorizeTitle => 'Seed Vault を再認証';

  @override
  String get childAddFromMyWallets => 'または自分のウォレットから選択';

  @override
  String get walletAddChildModeSetPin =>
      'このウォレットにはキッズモードのPINが保存されていません。次に設定してください。キッズモードを解除するときに必要です。';

  @override
  String get settingsChildModeAppPinTitle => 'キッズモードを解除するにはアプリのPINを入力';

  @override
  String get walletAddChildModeTitle => 'キッズモードのウォレットです';

  @override
  String get walletAddChildModeMessage =>
      'インポートするとアプリはキッズモードになります。ウォレットの切り替えは非表示になり、ウォレットの追加や自分の他のウォレットへの送金はできません。インポートしますか？';

  @override
  String get walletAddChildModeConfirm => '同意してインポート';

  @override
  String get walletTypeStandard => '通常';

  @override
  String get sendToMyWallet => '自分のウォレットへ';

  @override
  String get walletChildModeLocked => 'ウォレットの切替・追加には子どもモードをオフにしてください。';

  @override
  String get walletPinToContinue => '続けるにはPINを入力してください';

  @override
  String get walletActionFailed => '問題が発生しました。もう一度お試しください。';

  @override
  String get settingsChangePin => 'PINを変更';

  @override
  String get settingsChangePinSubtitle => '1つのPINですべてのウォレットを解除';

  @override
  String get changePinCurrent => '現在のPINを入力';

  @override
  String get changePinNew => '新しいPINを入力';

  @override
  String get changePinConfirm => '新しいPINを確認';

  @override
  String get changePinSuccess => 'PINを変更しました';

  @override
  String get changePinSameAsOld => '別のPINを選んでください';

  @override
  String get unlockSetPinTitle => 'Benny のPINを設定';

  @override
  String get unlockSetPinSubtitle => '1つのPINでこの端末のすべてのウォレットを保護します。';

  @override
  String get pinUnlocksAllWallets => 'このPINですべてのウォレットを解除します。';

  @override
  String settingsLogOutAllWallets(int count) {
    return 'この端末から $count 個のウォレットをすべて削除します。先に各リカバリーフレーズをバックアップしてください。';
  }

  @override
  String importAccountLabel(int number) {
    return 'アカウント $number';
  }

  @override
  String importAccountAltLabel(int number) {
    return 'アカウント $number · 代替パス';
  }

  @override
  String get importLegacyLabel => 'レガシー';

  @override
  String get travelGuardTitle => '旅行用防犯モード';

  @override
  String get travelGuardOffSubtitle => '1 つのウォレットだけを開く特別な PIN';

  @override
  String get travelGuardOnSubtitle => 'オン：特別な PIN は 1 つのウォレットだけを開きます';

  @override
  String get travelGuardInfoTitle => '旅行用防犯モードとは';

  @override
  String get travelGuardInfoBody =>
      'ウォレットを開くよう脅されたときのための機能です。\n\n特別な PIN を設定し、ウォレットを 1 つ選びます（少額だけ入れておくのがおすすめ）。特別な PIN で解除するとそのウォレットだけが開き、他のウォレットや残高、メッセージはウォレット一覧や送金を含めてすべて非表示になり、この設定も表示されません。\n\nオンの間は生体認証が無効になり、有効にできません。\n\nアプリをロックして通常の PIN で解除すると、すべてのウォレットに戻ります。';

  @override
  String get travelGuardChooseWallet => '特別な PIN で開くウォレットを選択';

  @override
  String get travelGuardNewPin => '特別な PIN を設定';

  @override
  String get travelGuardConfirmPin => '特別な PIN をもう一度入力';

  @override
  String get travelGuardPinHint => '通常の PIN とは別の番号にしてください。';

  @override
  String get travelGuardPinSameAsApp => 'これは通常の PIN です。別の番号にしてください。';

  @override
  String get travelGuardEnabled => '旅行用防犯モードをオンにしました';

  @override
  String get travelGuardDisabled => '旅行用防犯モードをオフにしました';

  @override
  String get travelGuardActiveBadge => '旅行用防犯モード オン';

  @override
  String get travelGuardBiometricsOff => '旅行用防犯モード中は使用できません';

  @override
  String get welcomeUseAsSigner => 'このスマホをオフライン署名デバイスにする';

  @override
  String get walletAddAirGap => 'オフライン署名デバイスを接続';

  @override
  String get walletAddAirGapSubtitle => '鍵はオンラインにならない別のスマホに保管されます';

  @override
  String createWalletWordCount(int count) {
    return '$count 単語';
  }

  @override
  String get signerAppTitle => 'Benny Signer';

  @override
  String get signerNeedsNoWalletsTitle => '先にすべてのウォレットを削除してください';

  @override
  String get signerNeedsNoWalletsBody =>
      '署名デバイスには、そのデバイス専用のオフラインのリカバリーフレーズのみが保管されます。「設定 > ウォレット」でこのスマホのすべてのウォレットをバックアップして削除してから、もう一度お試しください。';

  @override
  String get signerEnterTitle => 'このスマホを署名デバイスにしますか？';

  @override
  String get signerEnterBody =>
      'このスマホはオフラインのまま署名専用になり、ウォレット画面は表示されなくなります。再びウォレットとして使うには、署名デバイスを消去する必要があります。';

  @override
  String get signerIntroTitle => 'オフライン署名デバイス';

  @override
  String get signerIntroPoint1 => 'このスマホがリカバリーフレーズを保管し、今後オンラインになることはありません。';

  @override
  String get signerIntroPoint2 =>
      '別のスマホの Benny Wallet で取引を作成し、ここで QR コードをスキャンして署名します。';

  @override
  String get signerIntroPoint3 => 'リカバリーフレーズを作成する前に、すべてのネットワークをオフにする手順をご案内します。';

  @override
  String get signerIntroPoint4 => 'リカバリーフレーズは紙に書き留めてください。それが唯一のバックアップです。';

  @override
  String get signerIntroStart => '開始';

  @override
  String get signerIntroCancel => '今はしない（ウォレットとして使う）';

  @override
  String get signerOfflineTitle => 'このスマホをオフラインにする';

  @override
  String get signerOfflineBody =>
      '機内モードをオンにし、Wi-Fi、Bluetooth、NFC をオフにしてください。必須項目がすべて緑になると続行できます。';

  @override
  String get signerCheckAirplane => '機内モード：オン';

  @override
  String get signerCheckWifi => 'Wi-Fi：オフ';

  @override
  String get signerCheckBluetooth => 'Bluetooth：オフ';

  @override
  String get signerCheckNfc => 'NFC：オフ';

  @override
  String get signerCheckNoNetwork => 'ネットワーク接続なし';

  @override
  String get signerCheckUsbDebugging => 'USB デバッグ：オフ';

  @override
  String get signerCheckSim => 'SIM カードを取り外し済み（推奨）';

  @override
  String get signerCheckManualHint => 'この項目は自動で確認できません。ご自身で確認してください。';

  @override
  String get signerOpenSettings => '設定を開く';

  @override
  String get signerNetworkDetected => 'ネットワーク接続が検出されました。オフにしてから続行してください。';

  @override
  String get signerPinTitle => '署名デバイスの PIN を設定';

  @override
  String get signerPinBody => 'この署名デバイス用の 6 桁の PIN を設定してください。';

  @override
  String get signerPinConfirmTitle => 'PIN を確認';

  @override
  String get signerPinConfirmBody => 'もう一度 PIN を入力してください。';

  @override
  String get signerPinMismatch => 'PIN が一致しません。もう一度お試しください。';

  @override
  String get signerSourceTitle => 'リカバリーフレーズ';

  @override
  String get signerSourceBody =>
      'このオフラインのスマホで新しいリカバリーフレーズを作成するか、お持ちのフレーズを入力してください。';

  @override
  String get signerSourceCreate24 => '24 単語で作成';

  @override
  String get signerSourceCreate24Subtitle => '署名デバイスにおすすめ';

  @override
  String get signerSourceCreate12 => '12 単語で作成';

  @override
  String get signerSourceCreate12Subtitle => '書き留めるのが簡単';

  @override
  String get signerSourceImport => '既存のフレーズをインポート';

  @override
  String get signerSourceImportSubtitle => '12 または 24 単語';

  @override
  String get signerWordsTitle => 'これらの単語を書き留めてください';

  @override
  String get signerWordsWarning =>
      '単語を順番どおりに紙に書き留めてください。写真やスクリーンショットを撮ったり、他の場所に入力したりしないでください。これらの単語を知っている人は誰でもあなたの資産を奪えます。';

  @override
  String get signerWordsDone => '書き留めました';

  @override
  String get signerVerifyTitle => 'バックアップを確認';

  @override
  String get signerImportTitle => 'リカバリーフレーズをインポート';

  @override
  String get signerImportBody => '12 または 24 個の単語をスペースで区切って入力してください。';

  @override
  String get signerImportInvalid => '有効な 12 または 24 単語のリカバリーフレーズではありません。';

  @override
  String get signerFinishTitle => 'セットアップを完了';

  @override
  String get signerDeviceNameLabel => '署名デバイス名';

  @override
  String get signerDeviceNameHelper => '接続後にウォレットに表示されます。';

  @override
  String get signerBiometricToggle => '生体認証でロック解除';

  @override
  String get signerFinishButton => '完了';

  @override
  String get signerSetupFailed => '設定を保存できませんでした。もう一度お試しください。';

  @override
  String get signerUnlockSubtitle => '署名デバイスの PIN を入力';

  @override
  String get signerUnlockNetworkBlocked =>
      'ネットワークに接続されています。ロックを解除するには機内モードをオンにしてください。';

  @override
  String signerWrongPin(int count) {
    return 'PIN が違います。あと $count 回間違えると署名デバイスが消去されます。';
  }

  @override
  String get signerUnlockFailed => 'ロックを解除できませんでした。もう一度お試しください。';

  @override
  String get signerUseBiometric => '生体認証を使用';

  @override
  String get signerBiometricReason => 'Benny Signer のロックを解除';

  @override
  String get signerBiometricFailed => '生体認証の設定を変更できませんでした。';

  @override
  String get signerRecheckTitle => 'オフラインチェック';

  @override
  String get signerRecheckBody =>
      'アプリが更新されました。ロックを解除する前に、このスマホが再び完全にオフラインになっていることを確認してください。';

  @override
  String get signerLockNow => 'ロック';

  @override
  String get signerOfflineChip => 'オフライン署名デバイス';

  @override
  String get signerScanToSign => 'スキャンして署名';

  @override
  String get signerPairWallet => 'ウォレットを接続';

  @override
  String get signerAccountsTitle => 'アカウント';

  @override
  String signerAccountName(int number) {
    return 'アカウント $number';
  }

  @override
  String get signerPairBody =>
      '別のスマホの Benny Wallet で「オフライン署名デバイスを接続」を選び、このコードをスキャンしてください。';

  @override
  String get signerPairPublicOnly => 'このコードには公開アドレスのみが含まれ、リカバリーフレーズは含まれません。';

  @override
  String get signerScanBody => '別のスマホの Benny Wallet に表示された QR コードをスキャンしてください。';

  @override
  String get signerScanWrongCode => 'Benny Wallet からの署名リクエストではありません。';

  @override
  String get signerScanAgain => '再スキャン';

  @override
  String get signerRejectUnknownAccount => 'このリクエストは、この署名デバイスにないアカウント宛てです。';

  @override
  String get signerRejectNotASigner => 'この取引にこのアカウントの署名は不要です。';

  @override
  String get signerRejectUnreadable => 'この取引を読み取れないため、署名しません。';

  @override
  String get signerRejectMessageIsTransaction => 'このメッセージは実際には取引のため、署名しません。';

  @override
  String get signerRejectInvalidCode => 'この QR コードは有効な署名リクエストではありません。';

  @override
  String get signerReviewTitle => '確認して署名';

  @override
  String get signerReviewAccount => '署名するアカウント';

  @override
  String get signerReviewFee => 'ネットワーク手数料';

  @override
  String get signerReviewMessage => 'メッセージ';

  @override
  String signerBinaryMessage(int count) {
    return 'バイナリデータ（$count バイト）';
  }

  @override
  String get signerThisAccount => 'このアカウント';

  @override
  String signerActionSendSol(String amount) {
    return '$amount SOL を送金';
  }

  @override
  String signerActionSendToken(String amount, String symbol) {
    return '$amount $symbol を送金';
  }

  @override
  String signerActionSendUnverified(String amount) {
    return '未検証トークンを $amount 送金';
  }

  @override
  String signerActionTo(String address) {
    return '宛先 $address';
  }

  @override
  String signerActionToTokenAccount(String address) {
    return '宛先トークンアカウント $address';
  }

  @override
  String signerActionMint(String mint) {
    return 'トークンアドレス $mint';
  }

  @override
  String signerActionOwner(String address) {
    return '所有者 $address';
  }

  @override
  String signerActionRentTo(String address) {
    return 'レントの返却先 $address';
  }

  @override
  String get signerActionCreateTokenAccount => 'トークンアカウントを作成';

  @override
  String get signerActionCloseTokenAccount => 'トークンアカウントを閉じる';

  @override
  String get signerActionMemo => 'メモ';

  @override
  String get signerActionApprove => '他のアカウントにトークンの使用を許可';

  @override
  String get signerActionSetAuthority => 'アカウントの権限を変更';

  @override
  String get signerActionAssign => 'アカウントの所有者を変更';

  @override
  String get signerActionCreateAccount => 'アカウントを作成';

  @override
  String signerActionProgram(String program) {
    return 'プログラム $program';
  }

  @override
  String get signerHoldToSign => '長押しで署名';

  @override
  String get signerReject => '拒否';

  @override
  String get signerSignFailed => '署名に失敗しました。もう一度お試しください。';

  @override
  String get signerSignatureTitle => '署名';

  @override
  String get signerSignatureBody => '別のスマホの Benny Wallet でこのコードをスキャンすると完了します。';

  @override
  String get signerSettingsTitle => '署名デバイスの設定';

  @override
  String get signerAccountCount => '表示するアカウント数';

  @override
  String get signerAccountCountHint => 'このリカバリーフレーズから最大 5 アカウント';

  @override
  String get signerUpgradeTitle => '署名デバイスを更新';

  @override
  String get signerUpgradeIntro =>
      'アプリの更新にはネットワークが必要なため、計画的に行ってください。オンライン中もリカバリーフレーズはこのスマホに暗号化されて保管され、スマホが再びオフラインになるまで署名デバイスはそれを開きません。';

  @override
  String get signerUpgradeStep0 => '1. 紙のバックアップを確認';

  @override
  String get signerUpgradeVerifyBackup => 'バックアップを確認';

  @override
  String get signerUpgradeBackupOk => 'バックアップ確認済み';

  @override
  String get signerUpgradeOnlineTitle => '2a. 通常の更新';

  @override
  String get signerUpgradeOnlineBody =>
      '署名デバイスをロックします。ネットワークをオンにし、インストール元と同じストアから Benny Wallet を更新します。その後、機内モードを再びオンにします。ロックを解除する前に、署名デバイスが再度オフラインチェックを行います。';

  @override
  String get signerUpgradeSecureTitle => '2b. 最も安全な更新';

  @override
  String get signerUpgradeSecureBody =>
      '設定で署名デバイスを消去してから、オンラインでアプリを更新します。再びオフラインにして署名デバイスを設定し、リカバリーフレーズをインポートします。アカウントとアドレスは変わりません。';

  @override
  String get signerUpgradeOfflineApkTitle => 'Android：オンラインにせずに更新';

  @override
  String get signerUpgradeOfflineApkBody =>
      'benny-wallet.com から新しい APK を入手し、USB ケーブルまたは SD カードでこのスマホにコピーして、オフラインのままインストールすることもできます。同じ入手元のバージョンにのみ上書きインストールしてください。';

  @override
  String get signerUpgradeCompatTitle => '古い署名デバイスも引き続き使えます';

  @override
  String get signerUpgradeCompatBody =>
      '新しいウォレットアプリは古い署名デバイスでも使えます。ウォレットは署名デバイスが対応している機能だけを要求するため、都合のよいときに更新できます。';

  @override
  String get signerVersionTitle => 'バージョン';

  @override
  String signerVersionDetail(String app, int protocol, int tokens) {
    return 'アプリ $app · プロトコル $protocol · トークンリスト $tokens';
  }

  @override
  String get signerEraseTitle => '署名デバイスを消去';

  @override
  String get signerEraseSubtitle => 'このスマホからリカバリーフレーズを削除します';

  @override
  String get signerEraseBody =>
      'リカバリーフレーズがこのスマホから削除されます。紙のバックアップがなければ資産を復元できません。';

  @override
  String get signerEraseConfirm => '消去';

  @override
  String get signerEraseWrongPin => 'PIN が違います。何も消去されていません。';

  @override
  String get airGapConnectTitle => 'オフライン署名デバイスを接続';

  @override
  String get airGapConnectBody => '署名デバイスで「ウォレットを接続」をタップし、表示されたコードをスキャンしてください。';

  @override
  String get airGapConnectInvalid => '署名デバイスのペアリングコードではありません。';

  @override
  String airGapConnectChoose(String device) {
    return '$device のアカウントを選択';
  }

  @override
  String airGapConnectAccount(int number) {
    return 'アカウント $number';
  }

  @override
  String airGapConnectAccountAdded(int number) {
    return 'アカウント $number（追加済み）';
  }

  @override
  String get airGapConnectCompare => 'アドレスが署名デバイスに表示されているものと一致することを確認してください。';

  @override
  String get airGapConnectScanAgain => '再スキャン';

  @override
  String get airGapSignTitle => '署名デバイスで署名';

  @override
  String get airGapSignShowRequestAgain => 'リクエストを再表示';

  @override
  String get airGapSignMayHaveExpired =>
      'この取引は期限切れの可能性があります。送信に失敗した場合は、最初からやり直してください。';

  @override
  String get airGapSignWrongRequest => 'この署名は別のリクエストのものです。';

  @override
  String get airGapSignInvalidCode => '署名デバイスからの署名ではありません。';

  @override
  String get airGapSignerOutdated =>
      '署名デバイスは古いバージョンです。引き続き使えますが、都合のよいときに更新してください。';

  @override
  String get signerIntroSubtitle => '秘密鍵を二度とネットにつながないスマホに保管します。';

  @override
  String get signerFinishSubtitle => 'この署名機に名前を付けて、PIN を設定します。';

  @override
  String signerQuizBody(int count) {
    return '紙のバックアップを見ながら、$count か所の正しい単語を選んでください。';
  }

  @override
  String signerQuizProgress(int current, int total) {
    return '$total 問中 $current 問目';
  }

  @override
  String signerQuizQuestion(int position) {
    return '$position 番目の単語はどれ？';
  }

  @override
  String get signerQuizCorrect => '正解！';

  @override
  String get signerQuizWrong => '違います。紙を確認してください。新しい単語でやり直します。';

  @override
  String get signerQuizShowWords => '単語をもう一度表示';

  @override
  String get signerScanToSignSubtitle => 'ウォレットに表示されたリクエストをスキャン';

  @override
  String get signerPairWalletSubtitle => 'Benny Wallet でスキャンするコードを表示';

  @override
  String get signerWalletPhoneLabel => 'Benny Wallet';

  @override
  String get signerScanRefusedTitle => '署名できません';

  @override
  String get airGapSignerLabel => '署名機';

  @override
  String get airGapThisPhone => 'このスマホ';

  @override
  String get airGapConnectFound => '署名機を認識しました';

  @override
  String get airGapSignNeedsSigner => '署名機での確認と署名が必要です';

  @override
  String get airGapSignStepShort1 => '署名機でスキャン';

  @override
  String get airGapSignStepShort2 => '署名をスキャン';

  @override
  String airGapSignStep1Named(String device) {
    return 'ステップ 1：「$device」でこのコードをスキャン';
  }

  @override
  String airGapSignStep1BodyNamed(String device) {
    return '「$device」で「スキャンして署名」をタップし、内容を確認してから承認します。';
  }

  @override
  String airGapSignStep2Named(String device) {
    return 'ステップ 2：「$device」の署名コードをスキャン';
  }

  @override
  String airGapSignStep2BodyNamed(String device) {
    return '承認すると「$device」に署名コードが表示されます。このスマホでスキャンします。';
  }

  @override
  String airGapSignScanSignatureNamed(String device) {
    return '次へ：$device の署名をスキャン';
  }

  @override
  String signerActionSwapPair(String from, String to) {
    return '交換 $from → $to';
  }

  @override
  String signerSwapPay(String amount) {
    return '支払い $amount';
  }

  @override
  String signerSwapPayAtMost(String amount) {
    return '最大支払い $amount';
  }

  @override
  String signerSwapReceive(String amount) {
    return '受け取り $amount';
  }

  @override
  String signerSwapReceiveAtLeast(String amount) {
    return '最低受け取り $amount';
  }

  @override
  String get signerSwapUnverifiedToken => '未確認トークン';

  @override
  String airGapSignTimeLeft(int seconds) {
    return '残り $seconds 秒。時間切れになると新しいコードが自動で表示されます。';
  }

  @override
  String get airGapSignRefreshing => '時間切れです。新しい見積もりとコードを取得中…';

  @override
  String airGapSignRefreshed(String device) {
    return '前のコードは期限切れのため新しくしました。「$device」でもう一度スキャンしてください。';
  }

  @override
  String get airGapSignRefreshFailed => '新しいコードを取得できませんでした。接続を確認して再試行してください。';

  @override
  String get airGapSignOldRequest =>
      'これは期限切れのコードの署名です。先に署名機で新しいコードをスキャンしてください。';

  @override
  String get scanHintRoleShows => 'コードを表示';

  @override
  String get scanHintRoleScans => 'スキャン';

  @override
  String signerTokenUnchecked(String symbol) {
    return '$symbol（未確認）';
  }

  @override
  String get signerReviewActions => '取引内容';

  @override
  String get signerNewerWalletNotice =>
      'ウォレットの方が新しいバージョンです。都合のよい時に署名機を更新してください。';

  @override
  String get signerDangerBanner => '高リスクです。自分で始めた操作でなければ署名しないでください。';

  @override
  String get signerActionSwap => '交換';

  @override
  String get signerActionSwapDetail => '数量はウォレットで確認してください。';

  @override
  String get signerActionDangerDetail => '危険な操作です。よく分からなければ署名しないでください。';

  @override
  String get signerActionAdvanceNonce => '取引番号を更新';

  @override
  String get signerActionSyncNative => 'SOL 残高を更新';

  @override
  String get signerHoldLongHint => 'よく確認してから 3 秒長押ししてください。';

  @override
  String signerTokenVerified(String token) {
    return '$token · Benny Wallet 確認済み';
  }

  @override
  String signerTokenWalletProvided(String symbol) {
    return '$symbol · Benny Wallet 未確認';
  }

  @override
  String signerSwapWalletQuote(String pay, String receive) {
    return '目安：$pay を支払い、約 $receive を受け取り';
  }

  @override
  String get signerActionUnknown => '読み取れない操作';

  @override
  String signerActionCreateTokenAccountFor(String symbol) {
    return '$symbol 口座を開設';
  }

  @override
  String get signerUnresolvedAccounts =>
      '署名機はこの取引の全体を確認できません。自分で始めた直後の場合だけ署名してください。';

  @override
  String get signerTokenNotVerified => 'Benny Wallet 未確認';

  @override
  String get signerKindSwap => '交換';

  @override
  String get signerKindSend => '送金';

  @override
  String signerAbout(String amount) {
    return '約 $amount';
  }

  @override
  String get signerAmountsFromWallet => '数量はウォレットから';

  @override
  String get signerTrustSafe => 'すべて Benny Wallet で確認済み';

  @override
  String get signerTrustCaution => '一方のトークンは Benny Wallet 未確認です。注意してください。';

  @override
  String get signerTrustDangerSwap => 'どちらのトークンも Benny Wallet 未確認です。高リスクです。';

  @override
  String get signerTrustDangerSend => 'このトークンは Benny Wallet 未確認です。高リスクです。';

  @override
  String get signerReviewOtherSteps => 'その他の手順';

  @override
  String get signerPay => '支払う';

  @override
  String get signerPayAtMost => '最大支払額';

  @override
  String get signerGet => '受け取る';

  @override
  String get signerGetAtLeast => '最低受取額';

  @override
  String get signerGetAbout => '受取額（目安）';

  @override
  String get signerRecipient => '受取人';

  @override
  String get signerRecipientTokenAccount => '受取人のトークン口座';

  @override
  String get signerUsdFromWallet => '米ドル額はウォレットの概算です';

  @override
  String signerActionCreateTokenAccountForRecipient(String symbol) {
    return '受取人の $symbol 口座を開設';
  }

  @override
  String get signerCreateAccountSkipIfOpen =>
      '（初回のみ約 0.002 SOL。開設済みなら自動でスキップ、費用なし）';

  @override
  String get signerCreateAccountNotOpen => '（未開設。約 0.002 SOL かかります）';

  @override
  String get signerAddressFromWallet => 'このアドレスはウォレットが指定したもので、署名機では確認できません。';

  @override
  String get signerSwapOutputUnchecked => '交換したトークンがあなたに届くか確認できません。';

  @override
  String get signerExtraOutflow => 'このトランザクションは別のアドレスにも資金を送ります。';

  @override
  String signerHighFee(String amount) {
    return 'ネットワーク手数料が非常に高い：$amount SOL';
  }

  @override
  String get signerDurableNonce => 'この署名は期限切れになりません。後から使われる可能性があります。';

  @override
  String get signerSwapFromWallet => 'トークンまたは数量はウォレットから提供され、確認できません。';

  @override
  String signerActionCloseTo(String address) {
    return '残高とレントの送り先 $address';
  }

  @override
  String signerWalletNote(String name) {
    return 'ウォレットのメモ：$name';
  }

  @override
  String get signerReviewFeePayer => '手数料の支払い元';

  @override
  String signerActionOwnerProgram(String program) {
    return 'プログラム $program が管理';
  }

  @override
  String get signerSlippageAll => 'スリッページ 100% 以上：何も受け取れない可能性があります。';

  @override
  String get signerQuizTooManyWrong => '間違いが多すぎます。PIN を入力してもう一度お試しください。';

  @override
  String get signerSignInTitle => 'ログインリクエスト';

  @override
  String get signerKindSignIn => 'ログイン';

  @override
  String get signerSignInBenny => 'Benny Wallet にログイン';

  @override
  String signerSignInOtherSite(String site) {
    return '「$site」がログインを求めています。自分で始めた場合のみ署名してください。';
  }

  @override
  String get signerSignInExpired =>
      'このログインリクエストは期限切れです。この端末の時刻を確認するか、ウォレットでやり直してください。';

  @override
  String get signerSignInOtherAccount => '別のアカウントのログインです。署名しないでください。';

  @override
  String get signerSignInWhat =>
      'このアカウントがあなたのものだと証明し、Benny が残高・履歴・通知を表示できるようにします。';

  @override
  String get signerSignInNoFunds => '資金は動かず、手数料もかかりません。';

  @override
  String get signerSignInShowText => '原文を表示';

  @override
  String get airGapSignInTitle => '署名デバイスでログイン';

  @override
  String get airGapSignInWhy => 'なぜ署名が必要？';

  @override
  String get airGapSignInWhyBody =>
      '残高・履歴・通知を読み込む前に、Benny はこのアカウントがあなたのものか確認する必要があります。通常はウォレットごとに一度だけです。';

  @override
  String get airGapSignInSafe => 'ログインだけです。資金は動かず、手数料もかかりません。';

  @override
  String airGapSignInSignerShows(String device) {
    return '「$device」に「Benny Wallet にログイン」と表示されます。';
  }

  @override
  String airGapSignInSignerShowsText(String device) {
    return '「$device」には “Benny Wallet wants you to sign in” で始まる英文が表示されます。これがこのログインです。署名デバイスを更新すると「Benny Wallet にログイン」と表示されます。';
  }

  @override
  String get dappScanTitle => 'ウェブサイトに接続';

  @override
  String get dappScanHint => 'ウェブサイトに表示された WalletConnect の QR コードをスキャンしてください';

  @override
  String get dappPasteLink => 'リンクを貼り付け';

  @override
  String get dappScanNotWalletConnect => 'WalletConnect のコードではありません';

  @override
  String get dappConnecting => '接続中…';

  @override
  String get dappPairFailed => '接続できませんでした。ウェブサイトで新しい QR コードを表示してください。';

  @override
  String get dappNotConfigured => 'このビルドではウェブサイト接続を利用できません。';

  @override
  String get dappProposalTitle => 'ウェブサイトに接続';

  @override
  String dappProposalWants(String site) {
    return '$site がウォレットへの接続を求めています';
  }

  @override
  String get dappProposalCanDo => '接続するとウェブサイトは次のことができます：';

  @override
  String get dappProposalSeeAddress => 'ウォレットアドレスを見る';

  @override
  String get dappProposalRequestSign => '取引やメッセージの承認を求める';

  @override
  String get dappProposalNoAutoFunds =>
      'ウェブサイトが勝手に資金を動かすことはできません。すべてのリクエストにあなたの承認が必要です。';

  @override
  String get dappProposalWallet => 'ウォレット';

  @override
  String get dappProposalNoEligibleWallet =>
      'ウェブサイトに接続できるウォレットがまだありません。外部ウォレットは今後対応予定です。';

  @override
  String get dappProposalOnlySolana =>
      'Benny Wallet は Solana のみ対応しています。このウェブサイトは他のネットワークを要求しています。';

  @override
  String get dappProposalUnsupportedChain =>
      'このウェブサイトは Solana のテストネットを要求しています。Benny Wallet は Solana メインネットのみ対応しています。';

  @override
  String get dappConnect => '接続';

  @override
  String get dappReject => '拒否';

  @override
  String dappConnected(String site) {
    return '$site に接続しました';
  }

  @override
  String get dappSiteVerified => '確認済み';

  @override
  String get dappSiteUnknown => '未確認';

  @override
  String get dappSiteMismatch => 'ドメイン不一致';

  @override
  String get dappSiteScam => '既知の詐欺サイト';

  @override
  String get dappSitesTitle => '接続中のウェブサイト';

  @override
  String get dappSitesEmpty =>
      '接続中のウェブサイトはありません。ウェブサイトの WalletConnect QR コードをスキャンして接続できます。';

  @override
  String get dappSitesDisconnect => '切断';

  @override
  String get dappSitesDisconnectAll => 'すべて切断';

  @override
  String get dappSitesDisconnectAllConfirm => 'すべてのウォレットからすべてのウェブサイトを切断しますか？';

  @override
  String dappSitesExpires(String date) {
    return '$date に期限切れ';
  }

  @override
  String dappSitesWallet(String name) {
    return 'ウォレット：$name';
  }

  @override
  String dappSitesBanner(int count) {
    return '$count 件接続中';
  }

  @override
  String get dappRequestTitle => '署名リクエスト';

  @override
  String get dappRequestSignMessage => 'メッセージに署名';

  @override
  String dappRequestSignIn(String domain) {
    return '$domain にサインイン';
  }

  @override
  String get dappRequestTransaction => '取引を承認';

  @override
  String dappRequestTransactions(int count) {
    return '$count 件の取引を承認';
  }

  @override
  String get dappRequestSendNote => '署名後に Benny Wallet が送信します。';

  @override
  String get dappRequestBalanceChanges => '予想される残高の変化';

  @override
  String get dappRequestNoBalanceChange => 'ネットワーク手数料以外、このウォレットの残高は変わりません';

  @override
  String get dappRequestNetworkFee => 'ネットワーク手数料';

  @override
  String get dappRequestMessage => 'メッセージ';

  @override
  String get dappRequestDetails => '詳細';

  @override
  String get dappRequestPrograms => '呼び出すプログラム';

  @override
  String get dappActionTitle => 'この取引の内容';

  @override
  String get browserTitle => 'ブラウザ';

  @override
  String get browserAddressHint => 'アドレスを入力（例：jup.ag）';

  @override
  String get browserReload => '再読み込み';

  @override
  String get browserHome => 'ホーム';

  @override
  String get browserHomeHint =>
      'サイトのアドレスを入力してください。サイトで「ウォレットを接続」を押し、Benny Wallet を選ぶだけで接続できます。アプリの切り替えや再ロック解除は不要です。';

  @override
  String get browserNotConnected => '未接続';

  @override
  String browserConnectedAs(String wallet) {
    return '接続中：$wallet';
  }

  @override
  String get browserInvalidUrl => '無効なアドレスです';

  @override
  String get browserOpen => '開く';

  @override
  String get browserBookmarks => 'ブックマーク';

  @override
  String get browserBookmark => 'ブックマーク';

  @override
  String get browserBookmarked => 'ブックマークしました';

  @override
  String get browserBookmarkRemoved => 'ブックマークを削除しました';

  @override
  String get browserBookmarkRemove => '削除';

  @override
  String get browserBookmarksEmpty =>
      'ページを開き、アドレスバーの星を押すと保存できます。ブックマークはこの端末にのみ保存され、同期されません。';

  @override
  String get browserBookmarksLocal => 'この端末にのみ保存され、同期されません。';

  @override
  String get browserBack => '戻る';

  @override
  String get browserForward => '進む';

  @override
  String get browserCopyLink => 'リンクをコピー';

  @override
  String get browserHomeTagline => 'Solana アプリへの入り口';

  @override
  String get browserBennyFeatures => 'Benny Apps';

  @override
  String get browserComingSoon => '近日公開';

  @override
  String get browserPopular => 'おすすめ';

  @override
  String get browserYourSites => '接続したサイト';

  @override
  String get dappColdSwapNotice =>
      'このスワップは約 1 分で期限切れになり、コールドウォレットでは署名が間に合わないことがあります。コールドウォレットでのスワップには Benny 内蔵の「スワップ」をご利用ください。期限切れ時に見積もりを自動更新します。';

  @override
  String get dappActionSwap => 'スワップ';

  @override
  String get dappActionTransfer => '送金';

  @override
  String get dappActionStake => 'ステーク';

  @override
  String get dappActionLend => '貸し借り';

  @override
  String get dappActionPerps => '先物取引';

  @override
  String get dappActionNft => 'NFT 取引';

  @override
  String get dappActionOther => 'その他の操作';

  @override
  String dappActionVia(String protocol) {
    return '$protocol 経由';
  }

  @override
  String get dappActionPay => '支払う';

  @override
  String get dappActionReceive => '受け取る';

  @override
  String get dappActionUnknownHint =>
      'Benny はこれらのプログラムの動作を読み取れません。ご自身がサイトで今始めた操作の場合のみ署名してください。';

  @override
  String dappActionUnknownPrograms(int count) {
    return '不明なプログラム（$count）';
  }

  @override
  String get dappActivityTitle => '接続履歴';

  @override
  String get dappActivityNote =>
      'この端末にのみ保存され、クラウドへのアップロードやバックアップは行われません。記録するのはサイト・操作・金額のみで、メッセージの内容や個人情報は記録しません。';

  @override
  String get dappActivityEmpty => 'ウェブサイトの履歴はまだありません。';

  @override
  String get dappActivityClear => '履歴を消去';

  @override
  String get dappActivityClearConfirm => 'この端末のウェブサイト履歴をすべて消去しますか？';

  @override
  String dappActivityCount(int count) {
    return '$count 件';
  }

  @override
  String get dappActivityConnected => '接続済み';

  @override
  String get dappActivityConnectRejected => '接続を拒否';

  @override
  String get dappActivityMessage => 'メッセージ署名';

  @override
  String get dappActivitySigned => '署名済み';

  @override
  String get dappActivitySent => '送信済み';

  @override
  String get dappActivityRejected => '拒否';

  @override
  String get dappActivityFailed => '失敗';

  @override
  String get dappActivityViewTx => 'Solscan で表示';

  @override
  String get dappActivityViaPhone => 'この端末のアプリ';

  @override
  String get dappActivityInBrowser => '内蔵ブラウザ';

  @override
  String dappActivityWallet(String wallet) {
    return 'ウォレット $wallet';
  }

  @override
  String get dappActivityDisconnected => '切断済み';

  @override
  String dappSitesLastUsed(String date) {
    return '最終利用 $date';
  }

  @override
  String get dappActivityDetail => '詳細';

  @override
  String get dappActivitySite => 'サイト';

  @override
  String get dappActivityTime => '日時';

  @override
  String get dappActivityVia => '接続方法';

  @override
  String get dappActivityViaWalletConnect => 'QR コードをスキャン（WalletConnect）';

  @override
  String get dappActivityWalletLabel => 'ウォレット';

  @override
  String get dappActivityTxId => '取引 ID';

  @override
  String get dappActivityCopied => 'コピーしました';

  @override
  String get dappActivityResult => '結果';

  @override
  String get dappRequestSigningWallet => '署名するウォレット';

  @override
  String get dappRequestLoading => 'リクエストを確認中…';

  @override
  String get dappRequestInvalid => 'このリクエストは読み取れなかったため拒否しました。';

  @override
  String get dappRequestSign => '署名';

  @override
  String get dappRequestHoldToSign => '長押しで署名';

  @override
  String get dappRequestAcceptRisk => 'リスクを理解した上で署名します';

  @override
  String get dappRequestBlocked => '資金を守るため、Benny Wallet はこのリクエストをブロックしました。';

  @override
  String get dappRequestDone => '署名しました。ウェブサイトに戻ってください。';

  @override
  String get dappRequestSent => '送信しました。ウェブサイトに戻ってください。';

  @override
  String dappRequestFailed(String error) {
    return '署名に失敗しました：$error';
  }

  @override
  String get dappRequestRejected => 'リクエストを拒否しました';

  @override
  String get dappAuthReason => '署名を確認';

  @override
  String get dappPinTitle => '署名するには PIN を入力';

  @override
  String get dappTrustSafe => '問題なさそうです';

  @override
  String get dappTrustCaution => 'よく確認してください';

  @override
  String get dappTrustDanger => '高リスク';

  @override
  String get dappTrustBlocked => 'ブロック済み';

  @override
  String get dappWarnSiteScam => 'このウェブサイトは既知の詐欺サイトです。';

  @override
  String get dappWarnSiteMismatch => 'ウェブサイトのアドレスが名乗っているアプリと一致しません。';

  @override
  String get dappWarnSiteUnknown => 'このウェブサイトを確認できませんでした。';

  @override
  String get dappWarnMessageUnreadable => 'メッセージが読める文字ではないため、何に署名するのか分かりません。';

  @override
  String get dappWarnMessageIsTransaction =>
      'この「メッセージ」は実際には取引です。署名すると資金が移動する可能性があります。';

  @override
  String get dappWarnSignInOtherSite => 'サインイン先がリクエスト元のウェブサイトと異なります。';

  @override
  String get dappWarnSignInOtherAccount => 'サインイン対象は別のウォレットです。';

  @override
  String get dappWarnSignInExpired => 'このサインインリクエストは期限切れです。';

  @override
  String get dappWarnTokenApprove => '他のアカウントにあなたのトークンの使用を許可します。';

  @override
  String get dappWarnSetAuthority => 'あなたのアカウントの管理権限を他人に渡します。';

  @override
  String get dappWarnAssignAccount => 'ウォレットアカウントの所有者を変更します。';

  @override
  String get dappWarnCloseAccount => 'トークンアカウントを閉じます。';

  @override
  String get dappWarnAdvanceNonce => '永続ナンスを使うため、署名は使われるまで有効なままです。';

  @override
  String get dappWarnUnknownProgram => 'Benny Wallet が認識していないプログラムを呼び出します。';

  @override
  String get dappWarnBlockedProgram =>
      'Benny Wallet のブロックリストにある危険なプログラムを呼び出します。署名できません。';

  @override
  String get dappWarnUnresolvedAccounts => '一部のアカウントを照会できませんでした。';

  @override
  String get dappWarnSimulationFailed => 'シミュレーションで取引が失敗します。';

  @override
  String get dappWarnSimulationUnavailable => '残高の変化を予測できませんでした。';

  @override
  String get dappWarnHighSlippage => '何も受け取れない可能性のあるスワップを許可します。';

  @override
  String dappRequestQueued(int count) {
    return 'あと $count 件のリクエストが待機中';
  }

  @override
  String airGapSignFromSite(String site) {
    return 'このリクエストはウェブサイト $site から来ています。署名機にもサイト名が表示されます。';
  }

  @override
  String airGapSignFromSiteStep(String site, int current, int total) {
    return 'ウェブサイト $site から：$total 件中 $current 件目';
  }

  @override
  String get airGapSignerNoSiteSupport =>
      '署名機のバージョンが古く、どのサイトからのリクエストか表示できません。署名機を更新してください。';

  @override
  String signerDappSource(String site) {
    return 'ウェブサイト $site から（ウォレット経由）';
  }

  @override
  String get signerDappSiteVerified => 'ウォレットがこのサイトを確認済みです。';

  @override
  String get signerDappSiteUnverified => 'ウォレットはこのサイトを確認できませんでした。';

  @override
  String get signerDappSiteMismatch =>
      'サイトのアドレスが名乗っている内容と一致しません。偽サイトの可能性があります。';

  @override
  String get signerDappSiteScam => '既知の詐欺サイトです。署名しないでください。';

  @override
  String get signerDappSourceHint => 'そのサイトで自分で操作した直後の場合だけ署名してください。';

  @override
  String signerDappUnknownStep(String program) {
    return '署名機はこの手順（プログラム $program）を読めません。サイトで自分で操作した直後の場合だけ署名してください。';
  }

  @override
  String get signerDappSimulation => 'ウォレットがシミュレーションした残高の変化';

  @override
  String get signerDappSimulationNone => 'ネットワーク手数料以外に残高の変化はありません';

  @override
  String get signerDappSimulationNote =>
      'ウォレットによるシミュレーションです。署名機では確認できないため、参考程度にしてください。';

  @override
  String airGapSignSiteTimeLeft(String time) {
    return 'サイトはあと $time 待ちます';
  }

  @override
  String get airGapSignSiteExpired =>
      'サイトのリクエストは期限切れの可能性があります。閉じてサイトでやり直してください。';
}
