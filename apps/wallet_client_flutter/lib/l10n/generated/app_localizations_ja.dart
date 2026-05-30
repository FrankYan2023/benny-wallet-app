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
}
