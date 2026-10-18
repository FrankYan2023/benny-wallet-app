// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'Benny Wallet';

  @override
  String get brandShortName => 'Benny';

  @override
  String get commonBack => '뒤쪽에';

  @override
  String get commonCancel => '취소';

  @override
  String get commonClose => '닫다';

  @override
  String get commonContinue => '계속하다';

  @override
  String get commonConfirm => '확인하다';

  @override
  String get commonCopied => '복사됨';

  @override
  String get commonCopy => '복사';

  @override
  String get commonDone => '완료';

  @override
  String get commonLater => '나중에';

  @override
  String get commonLoading => '로드 중...';

  @override
  String get commonMax => 'MAX';

  @override
  String get commonNext => '다음';

  @override
  String get commonOk => '좋아요';

  @override
  String get commonRetry => '다시 해 보다';

  @override
  String get commonSettings => '설정';

  @override
  String get commonShare => '공유하다';

  @override
  String get commonUpdate => '업데이트';

  @override
  String get languageSystem => '시스템';

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
  String get settingsLanguage => '언어';

  @override
  String get settingsLanguageSubtitle => '앱 언어를 선택하세요';

  @override
  String get settingsLanguageSystemDescription => '이 장치를 따르십시오';

  @override
  String get settingsLanguageSheetTitle => '언어';

  @override
  String get settingsLanguageSheetSubtitle => 'Benny에서 사용되는 언어를 선택하세요.';

  @override
  String get settingsBiometricUnlock => '생체 인식 잠금 해제';

  @override
  String get settingsUseFingerprint => '지문 사용';

  @override
  String get settingsUnlockWalletToEnable => '활성화하려면 지갑을 잠금 해제하세요.';

  @override
  String get settingsAutoLock => '자동 잠금';

  @override
  String get settingsAutoLockSheetSubtitle => 'Benny가 다시 잠길 시기를 선택합니다.';

  @override
  String get settingsNotifications => '알림 받기';

  @override
  String get settingsNotificationsSubtitle => '자금이 도착하면 알림을 받으세요';

  @override
  String get settingsChildMode => '어린이 모드';

  @override
  String get settingsChildModeActive => '어린이 모드가 활성화되었습니다.';

  @override
  String get settingsChildModeActiveDescription =>
      '지갑은 4자리 하위 모드 PIN가 입력될 때까지 수신 전용 모드로 유지됩니다.';

  @override
  String get settingsChildModeProtected => '4자리 어린이 모드 PIN로 보호됩니다.';

  @override
  String get settingsChildModeRemoveAccounts => '활성화하기 전에 모든 하위 계정을 제거하십시오.';

  @override
  String get settingsChildModeSetPin => '어린이 모드용으로 별도의 4자리 PIN 설정';

  @override
  String get settingsChildAccounts => '자녀 계정';

  @override
  String get settingsRentReclaim => '임대료 회수';

  @override
  String get settingsRentReclaimSubtitle => '빈 토큰 계정을 닫고 SOL를 복구하세요';

  @override
  String get settingsFeedback => '피드백';

  @override
  String get settingsFeedbackSubtitle => '문제를 신고하거나 질문하세요';

  @override
  String get settingsLogOut => '로그아웃';

  @override
  String get settingsLogOutSubtitle => '홈 화면으로 돌아가기';

  @override
  String get settingsIncorrectPin => '잘못된 PIN';

  @override
  String get settingsPersistentBiometricUnsupported =>
      '이 장치에서는 영구 생체 인식 잠금 해제가 지원되지 않습니다.';

  @override
  String get settingsBiometricsUnavailable => '이 기기에서는 생체 인식을 사용할 수 없습니다.';

  @override
  String get settingsBiometricEnabled => '생체인식 활성화';

  @override
  String get settingsBiometricDisabled => '생체인식 비활성화됨';

  @override
  String get settingsUnlockBeforeBiometrics => '생체 인식을 활성화하기 전에 지갑을 잠금 해제하세요.';

  @override
  String get settingsNotificationsSystemDisabled =>
      '알림이 비활성화되었습니다. 시스템 설정에서 활성화하세요.';

  @override
  String get settingsNotificationsEnabled => '알림 수신이 활성화되었습니다.';

  @override
  String get settingsNotificationsDisabled => '알림 수신이 비활성화되었습니다.';

  @override
  String settingsNotificationsUpdateFailed(String error) {
    return '알림 업데이트 실패: $error';
  }

  @override
  String get settingsRemoveChildAccountsFirst =>
      '자녀 모드를 활성화하기 전에 모든 자녀 계정을 제거하세요.';

  @override
  String get settingsChildModeEnabled => '어린이 모드 활성화됨';

  @override
  String get settingsChildModeDisabled => '어린이 모드가 비활성화되었습니다.';

  @override
  String settingsChildModeUpdateFailed(String error) {
    return '어린이 모드 업데이트 실패: $error';
  }

  @override
  String get settingsCopyRecoveryPhraseFirst => '먼저 복구 문구를 복사하세요.';

  @override
  String get settingsLogOutWarning => '로그아웃하면 이 기기의 모든 로컬 앱 데이터가 삭제됩니다.';

  @override
  String get settingsWalletUpToDate => 'Benny Wallet는 최신 버전입니다.';

  @override
  String get settingsUpdateCheckFailed => '업데이트 확인 실패';

  @override
  String get settingsUnableToCheckUpdates => '지금은 업데이트를 확인할 수 없습니다.';

  @override
  String get settingsSeedPhraseBackup => '시드 구문 백업';

  @override
  String get settingsSeedPhraseBackupDescription =>
      '안전한 장소에 물리적 사본을 저장하는 것이 좋습니다.';

  @override
  String get settingsSecureNow => '지금 보안을 유지하세요';

  @override
  String get settingsCheckingUpdates => '확인 중...';

  @override
  String get settingsFullFeaturesUnlocked => '전체 기능이 활성화되었습니다';

  @override
  String get settingsCheckForUpdates => '업데이트 확인';

  @override
  String settingsVersion(String version) {
    return '버전 $version';
  }

  @override
  String settingsVersionBuild(String version, String buildNumber) {
    return '버전 $version+$buildNumber';
  }

  @override
  String get autoLockImmediate => '즉시';

  @override
  String get autoLockOneMinute => '1분';

  @override
  String get autoLockFiveMinutes => '5분';

  @override
  String get autoLockTenMinutes => '10분';

  @override
  String get autoLockThirtyMinutes => '30분';

  @override
  String get biometricUnlockReason => '생체 인식을 사용하여 Benny Wallet를 잠금 해제하세요.';

  @override
  String get biometricSetupReason => '이 보안 기능을 활성화하려면 생체 인식으로 인증하세요.';

  @override
  String get unlockFailedTitle => '잠금 해제 실패';

  @override
  String get unlockIncorrectPin => 'PIN가 잘못되었습니다.';

  @override
  String get unlockBiometricCancelled => '생체 인식이 취소되었습니다.';

  @override
  String get unlockBiometricFailed => '생체 인식 잠금 해제에 실패했습니다. 다시 시도해 보세요.';

  @override
  String get unlockSessionExpired => '세션이 만료되었습니다. PIN를 사용하세요.';

  @override
  String get unlockBiometricUnavailable => '생체 인식 불가';

  @override
  String get unlockUseFingerprint => '지문 사용';

  @override
  String get unlockEnterPin => 'PIN를 입력하세요';

  @override
  String get pinConfirm => 'PIN 확인';

  @override
  String get pinSet => 'Benny PIN 설정';

  @override
  String get pinMismatch => 'PIN가 일치하지 않습니다';

  @override
  String get pinImportFailed => '가져오기 실패';

  @override
  String get pinExternalWalletSetupDescription =>
      '이는 Benny 설정과 자녀 계정을 보호합니다. Seeker는 Seeker Wallet에서 키 서명을 유지합니다.';

  @override
  String get childModeConfirmPinTitle => '어린이 모드 확인 PIN';

  @override
  String get childModeSetPinTitle => '어린이 모드 설정 PIN';

  @override
  String get childModeEnterPinTitle => '어린이 모드 진입 PIN';

  @override
  String get childModeConfirmPinSubtitle => '어린이 모드에서만 사용되는 4자리 PIN를 다시 입력하세요.';

  @override
  String get childModeSetPinSubtitle => '자식 모드에만 사용되는 4자리 PIN를 만듭니다.';

  @override
  String get childModeEnterPinSubtitle => '끄려면 어린이 모드에만 사용되는 4자리 PIN를 입력하세요.';

  @override
  String get childModeOnlyUsed => '어린이 모드에만 사용됩니다.';

  @override
  String get welcomeReplaceWalletTitle => '현재 지갑 교체';

  @override
  String get welcomeReplaceWalletMessage => '계속 진행하면 현재 지갑이 삭제됩니다.';

  @override
  String get welcomeConfirmAgainTitle => '다시 확인하세요';

  @override
  String get welcomeConfirmAgainMessage =>
      '삭제 후에는 해당 문구에 액세스하지 못할 수 있습니다. 먼저 저장하세요.';

  @override
  String get welcomeNewWalletSubtitle => '새로운 기본 지갑을 시작하세요';

  @override
  String get welcomeImportWalletSubtitleSeeker => '문구 또는 Seeker Vault';

  @override
  String get welcomeImportWalletSubtitlePhrase => '복구 문구에서 복원';

  @override
  String get welcomeHeroSemantics => 'Benny Wallet';

  @override
  String get welcomeHeroPrelude => '새로운 지갑이 왔습니다.';

  @override
  String get welcomeHeroTitle => 'Benny Wallet';

  @override
  String get welcomeHeroSubtitle => '새로 시작하거나 복구 문구를 복원하세요.';

  @override
  String get welcomeNewWallet => '새로운 지갑';

  @override
  String get welcomeImportWallet => '지갑 가져오기';

  @override
  String get createWalletTitle => '지갑 생성';

  @override
  String get createWalletRecoveryTitle => '복구 문구를 적어보세요.';

  @override
  String get createWalletRecoverySubtitle => '이것이 지갑을 복구할 수 있는 유일한 방법입니다.';

  @override
  String get webTestingOnly => '웹은 테스트용입니다.';

  @override
  String get recoveryPhraseCopied => '복구 문구 복사됨(15초 후에 지워짐)';

  @override
  String get copyPhrase => '문구 복사';

  @override
  String get importWalletTitle => '지갑 가져오기';

  @override
  String get importRecoveryPhraseTitle => '복구 문구 가져오기';

  @override
  String get importRecoveryPhraseSubtitle => '12~24개의 영어 단어를 사용하세요.';

  @override
  String get importPasteHint => '여기에 복구 문구를 붙여넣으세요.';

  @override
  String get importInvalidPhrase => '잘못된 복구 문구';

  @override
  String get importEnterWords => '12~24단어를 입력하거나 붙여넣으세요.';

  @override
  String importWordsDetected(int count) {
    return '$count 단어가 감지되었습니다.';
  }

  @override
  String get importClear => '분명한';

  @override
  String get seekerVaultConnectDescription => '이 Seeker에 하드웨어 지원 지갑을 연결하세요.';

  @override
  String get seekerVaultConnect => '연결하다';

  @override
  String get seekerVaultInstallOrEnable =>
      'Seeker Wallet를 설치하거나 활성화한 후 다시 시도하세요.';

  @override
  String get seekerVaultAndroidOnly =>
      'Seeker Vault 가져오기는 Android에서만 사용할 수 있습니다.';

  @override
  String get seekerVaultNoAccounts =>
      '이 시드에 대해 기존 Seed Vault 지갑 계정이 반환되지 않았습니다.';

  @override
  String get seekerVaultUnavailable => '이 장치에서는 Seed Vault를 사용할 수 없습니다.';

  @override
  String get seekerVaultCancelled => 'Seeker Vault 연결이 취소되었습니다.';

  @override
  String get seekerVaultConnectFailed =>
      '지금은 Seeker Vault에 연결할 수 없습니다. 다시 시도해 주세요.';

  @override
  String get receiveTitle => '받다';

  @override
  String get receivedHistoryTitle => '수신내역';

  @override
  String get receiveShareAddressTitle => '이 주소를 공유하세요';

  @override
  String get receiveShareAddressSubtitle => '스캔하거나 복사하세요.';

  @override
  String get receiveNoAddress => '사용할 수 있는 지갑 주소가 없습니다.';

  @override
  String get receiveNoAddressSubtitle => '자금을 받으려면 지갑을 생성하거나 잠금 해제하세요.';

  @override
  String get receiveAddressCopied => '주소가 복사되었습니다(60초 후에 삭제됨).';

  @override
  String get receiveCopyAddress => '주소 복사';

  @override
  String get sendTitle => '보내다';

  @override
  String get sendChooseAssetTitle => '자산 선택';

  @override
  String get sendHistoryTitle => '보내기 기록';

  @override
  String get sendUnavailableChildMode => '어린이 모드에서는 보내기를 사용할 수 없습니다.';

  @override
  String get sendOpenReceive => '열기 수신';

  @override
  String get sendNoAssets => '보낼 수 있는 자산이 없습니다.';

  @override
  String get sendRecipientPrefilled => '수신자가 미리 입력됨';

  @override
  String sendLoadAssetsFailed(String error) {
    return '자산을 로드하지 못했습니다: $error';
  }

  @override
  String get sendAssetNotFound => '자산을 찾을 수 없습니다.';

  @override
  String sendAssetTitle(String symbol) {
    return '$symbol 보내기';
  }

  @override
  String get sendScanQrCode => 'QR 코드 스캔';

  @override
  String get sendRecipientAddressHint => '수신자 Solana 주소';

  @override
  String sendAvailableAmount(String amount, String symbol) {
    return '사용 가능한 $amount $symbol';
  }

  @override
  String sendLoadFormFailed(String error) {
    return '전송 양식을 로드하지 못했습니다: $error';
  }

  @override
  String get sendInvalidAddress => '유효한 Solana 주소를 입력하세요.';

  @override
  String get sendInvalidAmount => '유효한 금액을 입력하세요.';

  @override
  String get sendInsufficientBalance => '잔액이 부족합니다.';

  @override
  String get sendUnlockAgain => '보내기 전에 지갑을 다시 잠금 해제하세요.';

  @override
  String get sendNotEnoughSolAfterFee => '네트워크 요금을 예약한 후 SOL가 부족합니다.';

  @override
  String get sendNotEnoughSolForFee => '네트워크 요금을 감당할 만큼 SOL가 부족합니다.';

  @override
  String get sendGenericFailure => '보내기에 실패했습니다. 다시 시도해 주세요.';

  @override
  String get sendAmountHint => '양';

  @override
  String get portfolioChildAccounts => '자녀 계정';

  @override
  String get portfolioCrypto => '암호화폐';

  @override
  String get portfolioStocks => '주식';

  @override
  String get portfolioMessages => '메시지';

  @override
  String get portfolioTokens => '토큰';

  @override
  String get portfolioDefi => 'DeFi';

  @override
  String get portfolioSend => '보내다';

  @override
  String get portfolioSwap => '교환';

  @override
  String get portfolioReceive => '받다';

  @override
  String get portfolioCouldNotRefreshAssets => '자산을 새로고침할 수 없습니다.';

  @override
  String get portfolioPullToRetry => '아래로 당겨 다시 시도해 보세요.';

  @override
  String get portfolioDefiParentOnly => 'DeFi는 부모 전용입니다.';

  @override
  String get portfolioDefiParentOnlyMessage =>
      '프로토콜 위치를 검토하려면 상위 모드로 다시 전환하세요.';

  @override
  String get portfolioDefiUnavailable => 'DeFi 데이터를 일시적으로 사용할 수 없습니다.';

  @override
  String get portfolioDefiUnavailableMessage => '토큰은 아직 최신 상태입니다.';

  @override
  String get portfolioNoDefi => '아직 DeFi 위치가 없습니다.';

  @override
  String get portfolioRefreshingDefi => '프로토콜 위치를 새로 고치는 중...';

  @override
  String get portfolioNoActiveDefi => '귀하의 지갑에는 활성 DeFi 포지션이 없습니다.';

  @override
  String get portfolioRefreshFailed => '새로고침 실패';

  @override
  String get portfolioNetworkBusy => '현재 네트워크 사용량이 많습니다. 아래로 당겨 다시 시도해 보세요.';

  @override
  String get portfolioServerUnavailable =>
      '서버에 연결할 수 없습니다. 연결을 확인하고 아래로 당겨 다시 시도하세요.';

  @override
  String get portfolioRefreshAssetsFailed =>
      '애셋을 새로고침할 수 없습니다. 아래로 당겨 다시 시도해 보세요.';

  @override
  String get portfolioReceiveSol => 'SOL 수신';

  @override
  String get portfolioReceiveSolSubtitle => 'Benny Wallet를 시작하려면 SOL를 받으세요.';

  @override
  String get commonAdd => '추가하다';

  @override
  String get commonAmount => '양';

  @override
  String get commonAuto => '자동';

  @override
  String get commonBuy => '구입하다';

  @override
  String get commonConfirmed => '확인됨';

  @override
  String get commonCustom => '관습';

  @override
  String get commonDelete => '삭제';

  @override
  String get commonEdit => '편집하다';

  @override
  String get commonFrom => '에서';

  @override
  String get commonNetwork => '회로망';

  @override
  String get commonNetworkFee => '네트워크 수수료';

  @override
  String get commonSave => '구하다';

  @override
  String get commonSend => '보내다';

  @override
  String get commonSignature => '서명';

  @override
  String get commonSolana => 'Solana';

  @override
  String get commonStatus => '상태';

  @override
  String get commonSubmitted => '제출된';

  @override
  String get commonTo => '에게';

  @override
  String get commonToken => '토큰';

  @override
  String get transactionTimeline => '거래 타임라인';

  @override
  String get walletAddressUnavailable => '지갑 주소를 사용할 수 없습니다.';

  @override
  String relativeSecondsAgo(Object count) {
    return '$count초 전';
  }

  @override
  String relativeMinutesAgo(Object count) {
    return '$count분 전';
  }

  @override
  String relativeHoursAgo(Object count) {
    return '$count시간 전';
  }

  @override
  String relativeDaysAgo(Object count) {
    return '$count일 전';
  }

  @override
  String get importWalletLoadingTitle => '지갑을 가져오는 중...';

  @override
  String get importWalletLoadingSubtitle => 'Solana 지갑 목록을 준비하세요.';

  @override
  String get importSolanaMainnet => 'Solana Mainnet';

  @override
  String get importSelectSolanaAccount => '가져올 Solana 계정을 선택하세요.';

  @override
  String get importLoadingSolanaAccounts => 'Solana 계정 로드 중...';

  @override
  String get importCheckingActiveSolanaAccounts => '활성 Solana 계정을 확인하는 중입니다.';

  @override
  String get importUnableScanRecoveryPhrase => '지금은 이 복구 문구를 검색할 수 없습니다.';

  @override
  String get importActiveAccount => '활성 계정';

  @override
  String get importDefaultMainWallet => '기본 메인 지갑';

  @override
  String get seekerVaultTitle => 'Seeker Vault';

  @override
  String get seekerVaultChooseFundedAccount => '자금 지원 계정을 선택하세요';

  @override
  String get seekerVaultChooseAccount => '계정 선택';

  @override
  String get seekerVaultFundedAccountFound =>
      'Benny는 이 Seed Vault 지갑에서 계정 활동을 발견했습니다.';

  @override
  String get seekerVaultNoFundedAccountFound =>
      '입금된 계좌를 찾을 수 없습니다. Seed Vault가 반환한 계정입니다.';

  @override
  String seekerVaultAssetCount(Object count) {
    return '$count 자산';
  }

  @override
  String get seekerVaultNoAssets => '자산 없음';

  @override
  String get scanAddressTitle => '스캔 주소';

  @override
  String get scanNoSolanaAddress => '이 QR 코드에는 Solana 주소가 없습니다.';

  @override
  String get scanPointCamera => '카메라를 Solana QR 코드로 향하게 하세요.';

  @override
  String get sendConfirmTitle => '보내기 확인';

  @override
  String get sendSubmitting => '제출 중...';

  @override
  String sendSubmittingSummary(Object address, Object amount, Object symbol) {
    return '$amount $symbol ~ $address';
  }

  @override
  String get sendSubmitted => '제출된';

  @override
  String get sendFailed => '보내기 실패';

  @override
  String sendSubmittedMessage(Object address, Object amount, Object symbol) {
    return '$amount $symbol가 $address에 제출되었습니다. 확인하는 데 잠시 시간이 걸릴 수 있습니다.';
  }

  @override
  String get sendTransactionCouldNotComplete => '거래를 완료할 수 없습니다.';

  @override
  String get sendViewTransaction => '거래 보기';

  @override
  String get sendRecipientNotReady => '수신자 지갑은 아직 이 토큰을 받을 준비가 되어 있지 않습니다.';

  @override
  String get sendNetworkBusy => '네트워크 사용량이 많습니다. 다시 시도해 주세요.';

  @override
  String get sendNetworkTakingLonger => '네트워크가 예상보다 오래 걸리고 있습니다. 다시 시도해 주세요.';

  @override
  String get sendHistoryEmpty => '아직 전송 내역이 없습니다.';

  @override
  String sendHistoryLoadFailed(Object error) {
    return '전송 기록을 로드할 수 없습니다: $error';
  }

  @override
  String get sendDetailsTitle => '세부정보 보내기';

  @override
  String get sendNotConfirmedYet => '아직 확인되지 않음';

  @override
  String get sendOpenTokenDetails => '토큰 세부정보 열기';

  @override
  String get sendViewOnSolscan => 'Solscan에서 보기';

  @override
  String get sendToEmpty => '에게 --';

  @override
  String sendToAddress(Object address) {
    return '$address로';
  }

  @override
  String get sendStatusFailed => '실패한';

  @override
  String get sendStatusFinalized => '확정됨';

  @override
  String get sendStatusConfirmed => '확인됨';

  @override
  String get sendStatusSubmitted => '제출된';

  @override
  String get sendStatusSourceHeliusWebhook => 'Helius 웹훅';

  @override
  String get sendStatusSourceRpcSync => '체인 상태 동기화';

  @override
  String get sendStatusSourceChainActivity => '체인 활동';

  @override
  String get sendTransactionFallbackTitle => '거래 보내기';

  @override
  String get sendSubmittedToSender => '발신자에게 제출됨';

  @override
  String get sendSubmittedToSenderSubtitle => 'Helius 발신자는 서명된 거래를 수락했습니다.';

  @override
  String get sendAsyncResultFailed => '비동기 결과가 실패했습니다.';

  @override
  String get sendWaitingAsyncConfirmation => '비동기 확인을 기다리는 중';

  @override
  String get sendAsyncConfirmationReceived => '비동기 확인 수신됨';

  @override
  String get sendUpdatedFromHeliusWebhook => 'Helius 웹훅에서 업데이트되었습니다.';

  @override
  String get sendUpdatedFromChainStatusSync => '체인 상태 동기화에서 업데이트되었습니다.';

  @override
  String get sendConfirmationNotReceivedYet => '아직 확인을 받지 못했습니다.';

  @override
  String get swapTitle => '교환';

  @override
  String get swapButton => '교환';

  @override
  String get swapReviewTitle => '교환 검토';

  @override
  String swapForAmount(Object amount, Object symbol) {
    return '~$amount $symbol의 경우';
  }

  @override
  String get swapPay => '지불하다';

  @override
  String get swapReceive => '받다';

  @override
  String get swapMinimumReceive => '최소 수신';

  @override
  String get swapSlippage => '미끄러짐';

  @override
  String get swapPriorityFee => '우선 수수료';

  @override
  String get swapRoute => '노선';

  @override
  String swapLamports(Object lamports) {
    return '$lamports 램프';
  }

  @override
  String get swapPriorityNormal => '정상';

  @override
  String get swapPriorityFast => '빠른';

  @override
  String get swapPriorityTurbo => '터보';

  @override
  String get swapProcessing => '교환 중...';

  @override
  String swapProcessingSummary(
    Object inputAmount,
    Object inputSymbol,
    Object outputAmount,
    Object outputSymbol,
  ) {
    return '$inputAmount $inputSymbol ~ $outputAmount $outputSymbol';
  }

  @override
  String get swapComplete => '교체 완료';

  @override
  String get swapFailed => '교환 실패';

  @override
  String swapReceivedAmount(Object amount, Object symbol) {
    return '$amount $symbol 수신됨';
  }

  @override
  String get swapCouldNotComplete => '교환을 완료할 수 없습니다.';

  @override
  String get swapTradingUnavailableChildMode => '어린이 모드에서는 거래가 불가능합니다.';

  @override
  String get swapNoBaseAssetsForXStocks =>
      'SOL, USDC 또는 USDT는 xStocks를 구매할 수 없습니다.';

  @override
  String get swapNoAssetsAvailable => '교환할 수 있는 자산이 없습니다.';

  @override
  String get swapPayWith => '다음으로 결제';

  @override
  String get swapBuyXStock => 'xStock 구매';

  @override
  String swapAvailable(Object amount, Object symbol) {
    return '사용 가능한 $amount $symbol';
  }

  @override
  String get swapRefreshingQuote => '상쾌한 인용문...';

  @override
  String swapRouteLabel(Object route) {
    return '경로: $route';
  }

  @override
  String get swapBestRoute => '최적의 경로';

  @override
  String swapFailedLoadWalletAssets(Object error) {
    return '지갑 자산 로드 실패: $error';
  }

  @override
  String swapRateSummary(Object inputSymbol, Object outputSymbol, Object rate) {
    return '1 $inputSymbol ≒ $rate $outputSymbol';
  }

  @override
  String swapSlippageMin(Object value) {
    return '최소 $value';
  }

  @override
  String swapCustomWithValue(Object value) {
    return '사용자 정의 · $value';
  }

  @override
  String swapMinReceive(Object amount) {
    return '최소 $amount';
  }

  @override
  String get swapAmountTooSmall => '이 금액은 유효한 경로에 비해 너무 적습니다.';

  @override
  String get swapWaitValidQuote => '계속하기 전에 유효한 견적을 기다리십시오.';

  @override
  String swapNotEnoughSolReserve(Object reserve) {
    return 'SOL가 충분하지 않습니다.\n$reserve SOL 예비가 필요합니다.';
  }

  @override
  String get swapRouteUnavailable =>
      '지금은 이 스왑 경로를 사용할 수 없습니다. SOL로 교체하거나 다른 토큰 쌍을 선택해 보세요.';

  @override
  String get swapPriceMoved => '스왑이 전송되기 전에 가격이 움직였습니다. 미끄러짐을 증가시키고 다시 시도하십시오.';

  @override
  String get swapNotEnoughTokenBalance => '토큰 잔액이 부족합니다. Max를 다시 탭하고 다시 시도하세요.';

  @override
  String get swapQuotesBusy => '지금 견적이 바빠요. 잠시 후에 다시 시도해 보세요.';

  @override
  String get swapQuoteExpired => '이 견적은 만료되었습니다. 스왑을 다시 검토하세요.';

  @override
  String get swapUnlockAgain => '교환하기 전에 지갑을 다시 잠금 해제하세요.';

  @override
  String get swapTransactionUnavailable => '스왑거래가 불가능합니다.';

  @override
  String get swapConnectSeekerVaultAgain => '교체하기 전에 Seeker Vault를 다시 연결하세요.';

  @override
  String get swapConnectSeedVaultAgain => '교체하기 전에 Seed Vault를 다시 연결하세요.';

  @override
  String get swapUnexpectedSignatureCount => '월렛에서 예상치 못한 서명 수를 반환했습니다.';

  @override
  String get swapCustomSlippageLabel => '사용자 정의 미끄러짐 %';

  @override
  String get swapChooseToken => '선택하다';

  @override
  String get swapApproxYouReceive => '대략. 당신은 받는다';

  @override
  String get swapRate => '비율';

  @override
  String get swapPlatformFee => '플랫폼 수수료';

  @override
  String get swapSearchTokenHint => '토큰 이름 또는 기호 검색';

  @override
  String get swapNoTokensAvailable => '사용 가능한 토큰이 없습니다.';

  @override
  String swapNoResultsFor(Object query) {
    return '\"$query\"에 대한 검색결과가 없습니다.';
  }

  @override
  String get swapYourAssets => '귀하의 자산';

  @override
  String get swapSuggestedTokens => '추천 토큰';

  @override
  String swapAvailableBalance(Object amount) {
    return '$amount 사용 가능';
  }

  @override
  String get assetNotFound => '자산을 찾을 수 없습니다.';

  @override
  String get assetPosition => '위치';

  @override
  String get assetValue => '값';

  @override
  String get assetBalance => '균형';

  @override
  String get assetReturn24h => '24시간 반납';

  @override
  String get assetInfo => '정보';

  @override
  String get assetName => '이름';

  @override
  String get assetSymbol => '상징';

  @override
  String get assetMint => '박하';

  @override
  String get assetWebsite => '웹사이트';

  @override
  String get assetPrice => '가격';

  @override
  String get assetMarketCap => '시가총액';

  @override
  String get assetFdv => 'FDV';

  @override
  String get assetTotalSupply => '총 공급량';

  @override
  String get assetCirculatingSupply => '순환 공급';

  @override
  String get assetHolders => '홀더';

  @override
  String get assetCreated => '생성됨';

  @override
  String get assetPerformance24h => '24시간 성능';

  @override
  String get assetVolume => '용량';

  @override
  String get assetTraders => '상인';

  @override
  String get assetSafety => '안전';

  @override
  String get assetTop10Holders => '상위 10위 보유자';

  @override
  String get assetMarketStatsUnavailable => '현재 일부 시장 통계를 사용할 수 없습니다.';

  @override
  String get assetActivity => '활동';

  @override
  String get assetNoActivity => '아직 활동이 없습니다.';

  @override
  String get assetActivityLoadFailed => '활동을 로드할 수 없습니다.';

  @override
  String assetLoadDetailsFailed(Object error) {
    return '자산 세부정보를 로드하지 못했습니다: $error';
  }

  @override
  String get assetMintCopied => '민트 복사됨(60초 후에 지워짐)';

  @override
  String get assetCouldNotOpenWebsite => '웹사이트를 열 수 없습니다.';

  @override
  String get assetSwapOut => '스왑 아웃';

  @override
  String get assetSwapIn => '스왑인';

  @override
  String assetToSymbol(Object symbol) {
    return '$symbol로';
  }

  @override
  String assetFromSymbol(Object symbol) {
    return '$symbol에서';
  }

  @override
  String get assetSent => '전송된';

  @override
  String get assetReceived => '받았다';

  @override
  String get assetTransfer => '옮기다';

  @override
  String assetSwapWithTime(Object time) {
    return '스왑 • $time';
  }

  @override
  String assetCounterpartyWithTime(Object address, Object time) {
    return '$address • $time';
  }

  @override
  String get notificationsMarkAllRead => '모두 읽은 것으로 표시';

  @override
  String get notificationsUnavailableTitle => '메시지를 사용할 수 없습니다.';

  @override
  String get notificationsUnavailableSubtitle => '지금은 메시지를 로드할 수 없습니다.';

  @override
  String get notificationsEmptyTitle => '아직 메시지가 없습니다';

  @override
  String get notificationsEmptySubtitle => '푸시 메시지가 도착하면 여기에 표시됩니다.';

  @override
  String get notificationDeleted => '메시지가 삭제되었습니다.';

  @override
  String get receivedHistoryEmpty => '아직 수신된 내역이 없습니다.';

  @override
  String receivedHistoryLoadFailed(Object error) {
    return '수신된 기록을 로드할 수 없습니다: $error';
  }

  @override
  String get receivedDetailsTitle => '받은 내용';

  @override
  String get receivedDetailsMissingId => '이 메시지에는 수신된 전송 ID가 포함되어 있지 않습니다.';

  @override
  String receivedDetailsLoadFailed(Object error) {
    return '수신된 전송을 로드할 수 없습니다: $error';
  }

  @override
  String get receivedFundsTitle => '수령한 자금';

  @override
  String receivedYouReceived(Object amount) {
    return '$amount를 받았습니다';
  }

  @override
  String receivedYouReceivedInWallet(String amount, String wallet) {
    return '$wallet에 $amount 입금됨';
  }

  @override
  String get receivedFromEmpty => '에서 --';

  @override
  String receivedFromAddress(Object address) {
    return '$address에서';
  }

  @override
  String get receivedRelatedChanges => '관련 변경 사항';

  @override
  String get receivedOnSolana => 'Solana에서 수신됨';

  @override
  String get receivedMarkedFailed => '수신 이벤트가 실패로 표시되었습니다.';

  @override
  String get receivedArrived => '이 지갑에 자금이 도착했습니다.';

  @override
  String get receivedNewFundsArrived => '지갑에 새로운 자금이 도착했습니다.';

  @override
  String get childVerifyPinTitle => 'PIN 확인';

  @override
  String get childWalletAlreadyAdded => '이 하위 지갑은 이미 추가되었습니다.';

  @override
  String childWalletAdded(Object name) {
    return '$name가 성공적으로 추가되었습니다.';
  }

  @override
  String childWalletAddFailed(Object error) {
    return '하위 지갑 추가 실패: $error';
  }

  @override
  String childWalletUpdated(Object name) {
    return '$name가 성공적으로 업데이트되었습니다.';
  }

  @override
  String childWalletUpdateFailed(Object error) {
    return '하위 지갑 업데이트 실패: $error';
  }

  @override
  String childWalletDeleteTitle(Object name) {
    return '$name를 삭제하시겠습니까?';
  }

  @override
  String get childWalletDeleteMessage => '이 하위 지갑 항목은 상위 모니터링에서 제거됩니다.';

  @override
  String childWalletDeleted(Object name) {
    return '$name가 삭제되었습니다.';
  }

  @override
  String childWalletDeleteFailed(Object error) {
    return '하위 지갑 삭제 실패: $error';
  }

  @override
  String get childAccountsTitle => '자녀 계정';

  @override
  String get childManageUnavailable => '자녀 계정을 관리하려면 자녀 모드를 끄세요.';

  @override
  String get childNoAccountsYet => '아직 자녀 계정이 없습니다.';

  @override
  String childAccountCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '자녀 계정 $count개',
      one: '자녀 계정 1개',
    );
    return '$_temp0';
  }

  @override
  String get childAddAccount => '자녀 계정 추가';

  @override
  String get childEditAccount => '자녀 계정 편집';

  @override
  String get childName => '아이 이름';

  @override
  String get childNameHint => '예를 들어 앨리스';

  @override
  String get childWalletAddress => '하위 지갑 주소';

  @override
  String get childScanAgain => '다시 스캔';

  @override
  String get childScanQrAgain => 'QR 코드를 다시 스캔하세요';

  @override
  String get childEnterName => '자녀의 이름을 입력해주세요.';

  @override
  String get childEnterValidWalletAddress => '유효한 지갑 주소를 입력해주세요.';

  @override
  String get childWalletTitle => '어린이 지갑';

  @override
  String get childWalletNotFound => '자녀 지갑을 찾을 수 없습니다';

  @override
  String get childAddressCopied => '주소가 클립보드에 복사되었습니다.';

  @override
  String get childTotalBalance => '총 잔액';

  @override
  String get childSendToChildWallet => '하위 지갑으로 보내기';

  @override
  String get childNoAssets => '자산 없음';

  @override
  String get childAssets => '자산';

  @override
  String childWalletLoadFailed(Object error) {
    return '하위 지갑 로드 오류: $error';
  }

  @override
  String get feedbackHeading => '무엇이 잘못되었는지 알려주세요.';

  @override
  String get feedbackSubtitle => '질문이나 문제를 Benny Wallet 지원팀에 직접 보내세요.';

  @override
  String get feedbackEmailOptional => '이메일(선택사항)';

  @override
  String get feedbackMessage => '메시지';

  @override
  String get feedbackMessageHint => '발생한 문제를 설명하세요.';

  @override
  String get feedbackSending => '배상...';

  @override
  String get feedbackMessageRequiredTitle => '메시지 필수';

  @override
  String get feedbackMessageRequiredMessage => '보내기 전에 피드백을 입력하세요.';

  @override
  String get feedbackMessageTooLongTitle => '메시지가 너무 깁니다.';

  @override
  String get feedbackMessageTooLongMessage => '피드백을 2000자 이내로 유지하세요.';

  @override
  String get feedbackInvalidEmailTitle => '잘못된 이메일';

  @override
  String get feedbackInvalidEmailMessage => '유효한 이메일 주소를 입력하거나 비워두세요.';

  @override
  String get feedbackSent => '귀하의 메시지가 전송되었습니다.';

  @override
  String get feedbackSendFailedTitle => '보내기 실패';

  @override
  String get feedbackSendFailedFallback =>
      '지금은 메시지를 보낼 수 없습니다. 잠시 후 다시 시도해 주세요.';

  @override
  String get rentTitle => 'Solana 임대료 회수';

  @override
  String get rentDescription => '빈 토큰 계정을 닫고 임대료를 기본 SOL 잔액으로 다시 복구하세요.';

  @override
  String get rentWalletAddress => '지갑 주소';

  @override
  String get rentClosableTokenAccounts => '폐쇄 가능한 토큰 계정';

  @override
  String get rentReclaimableRent => '회수 가능한 임대료';

  @override
  String get rentAccountsToClose => '폐쇄할 계정';

  @override
  String rentMoreAccounts(Object count) {
    return '+$count개 이상의 계정이 회수됩니다.';
  }

  @override
  String get rentReclaiming => '회수 중...';

  @override
  String get rentNothingToReclaim => '회수할 것이 없음';

  @override
  String get rentReclaimAll => '임대료 모두 회수';

  @override
  String get rentReclaimingRent => '임대료 회수 중…';

  @override
  String get rentSubmittingTransactions => '지금 계좌 폐쇄 거래를 제출하는 중입니다.';

  @override
  String get rentUnlockRequiredTitle => '잠금 해제 필요';

  @override
  String get rentUnlockRequiredMessage => '임대료를 회수하기 전에 지갑을 다시 잠금 해제하세요.';

  @override
  String get rentReclaimFailedTitle => '회수 실패';

  @override
  String get rentWalletRequiredTitle => '지갑 필요';

  @override
  String get rentConnectSeekerVaultAgain =>
      '임대료를 환급받기 전에 Seeker Vault를 다시 연결하세요.';

  @override
  String get rentConnectSeedVaultAgain => '임대료를 환급받기 전에 Seed Vault를 다시 연결하세요.';

  @override
  String rentSubmittedTransactions(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '회수 트랜잭션 $count개를 제출했습니다',
      one: '회수 트랜잭션 1개를 제출했습니다',
    );
    return '$_temp0.';
  }

  @override
  String rentSubmittedTransactionsWithSkipped(num skipped, num submitted) {
    String _temp0 = intl.Intl.pluralLogic(
      submitted,
      locale: localeName,
      other: '회수 트랜잭션 $submitted개를 제출했습니다',
      one: '회수 트랜잭션 1개를 제출했습니다',
    );
    String _temp1 = intl.Intl.pluralLogic(
      skipped,
      locale: localeName,
      other: '계정 $skipped개',
      one: '계정 1개',
    );
    return '$_temp0; $_temp1를 건너뛰었습니다.';
  }

  @override
  String get rentUnableScan => '지금은 회수 가능한 토큰 계정을 스캔할 수 없습니다.';

  @override
  String rentMintAddress(Object address) {
    return '민트 $address';
  }

  @override
  String get airdropTitle => 'BYC 에어드롭';

  @override
  String get airdropUnavailableTitle => 'BYC 에어드랍을 일시적으로 사용할 수 없습니다.';

  @override
  String get airdropUnlockBeforeJoin => 'BYC 에어드롭에 참여하기 전에 지갑을 잠금 해제하세요.';

  @override
  String get airdropJoinDialogTitle => 'BYC 에어드롭에 참여하시겠습니까?';

  @override
  String airdropJoinDialogMessage(Object address) {
    return '현재 Benny 지갑 주소를 사용합니다:\n\n$address\n\n이 주소는 에어드롭 프로필을 등록하기 위해 Benny 백엔드로 전송됩니다.';
  }

  @override
  String get airdropJoin => '가입하다';

  @override
  String get airdropJoinedSnack => '참여하셨습니다. BYC 보상 프로필이 준비되었습니다.';

  @override
  String get airdropJoinBeforeCheckIn => '체크인하기 전에 BYC 에어드롭에 참여하세요.';

  @override
  String get airdropUnlockBeforeCheckIn => '체크인하기 전에 지갑을 잠금 해제하세요.';

  @override
  String get airdropJoined => '가입됨';

  @override
  String get airdropNotJoined => '가입하지 않음';

  @override
  String get airdropBycPoints => 'BYC 포인트';

  @override
  String get airdropStreak => '줄';

  @override
  String airdropDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count일',
      one: '1일',
    );
    return '$_temp0';
  }

  @override
  String get airdropWalletUnavailable => '지갑을 사용할 수 없음';

  @override
  String get airdropJoinCardTitle => '에어드랍에 참여하세요';

  @override
  String get airdropJoinCardSubtitle => '활성 Benny 지갑을 확인하고 BYC 보상 프로필을 생성하세요.';

  @override
  String get airdropJoining => '합류...';

  @override
  String get airdropJoinWithThisWallet => '이 지갑으로 가입하세요';

  @override
  String get airdropCheckInNow => '지금 체크인하세요';

  @override
  String get airdropCheckedInToday => '오늘 체크인했습니다';

  @override
  String airdropNextReward(Object points) {
    return '다음 보상: +$points BYC';
  }

  @override
  String get airdropComeBackTomorrow => '내일 다시 방문하여 더 많은 BYC를 받으세요.';

  @override
  String get airdropCheckingIn => '체크인 중...';

  @override
  String airdropLastClaimed(Object date) {
    return '마지막으로 청구된 $date';
  }

  @override
  String get airdropRewardRules => '보상 규칙';

  @override
  String get airdropFirstCheckIn => '첫 번째 체크인';

  @override
  String get airdropNextDayReward => '다음날 보상';

  @override
  String airdropEveryDayStreak(Object days) {
    return '$days일마다 연속';
  }

  @override
  String get airdropUnableOpenPumpFun => '지금은 Pump.fun를 열 수 없습니다.';

  @override
  String get airdropView => '보다';

  @override
  String get airdropPointsBalanceUpdated => 'Benny 포인트 잔액이 업데이트되었습니다.';

  @override
  String get airdropFirstCheckInUnlocked => '첫 번째 체크인 잠금 해제';

  @override
  String get airdropStreakBonusLanded => '연속 보너스 도착';

  @override
  String get airdropAlreadyClaimedToday => '오늘 이미 소유권을 주장했습니다.';

  @override
  String get airdropRewardClaimed => '보상 청구';

  @override
  String get defiTypeDeposit => '보증금';

  @override
  String get defiTypeBorrow => '빌리다';

  @override
  String get defiTypeStaking => '스테이킹';

  @override
  String get defiTypeLiquidity => '유동성';

  @override
  String get defiTypeYield => '생산하다';

  @override
  String get defiTypePerps => '범인';

  @override
  String get defiTypeRewards => '보상';

  @override
  String get defiTypePosition => '위치';

  @override
  String get settingsSeekerWallet => 'Seeker Wallet';

  @override
  String get updateDefaultTitle => '업데이트 가능';

  @override
  String get updateDefaultMessage => 'Benny Wallet의 최신 버전을 사용할 수 있습니다.';

  @override
  String get updateFailedTitle => '업데이트 실패';

  @override
  String get updateUnableToOpen => '지금은 Benny Wallet 업데이트 링크를 열 수 없습니다.';

  @override
  String get routerFeatureUnavailableTitle => '사용할 수 없는 기능';

  @override
  String get routerFeatureUnavailableMessage => '이 빌드에서는 이 기능을 사용할 수 없습니다.';

  @override
  String get routerMessageUnavailableTitle => '메시지를 사용할 수 없습니다.';

  @override
  String get routerMessageUnavailableMessage => '먼저 메시지 목록에서 받은 메시지를 엽니다.';

  @override
  String get routerSendDetailsUnavailableTitle => '세부정보 보내기 불가';

  @override
  String get routerSendDetailsUnavailableMessage => '먼저 전송 내역에서 거래를 엽니다.';

  @override
  String get routerInvalidChildWalletId => '잘못된 하위 지갑 ID';

  @override
  String routerRouteNotFound(String uri) {
    return '경로를 찾을 수 없음: $uri';
  }

  @override
  String get walletsTitle => '지갑';

  @override
  String get walletsSubtitle => '지갑 전환, 추가, 이름 변경, 삭제';

  @override
  String get walletSwitcherTitle => '내 지갑';

  @override
  String walletSwitcherCount(int count, int max) {
    return '$count/$max';
  }

  @override
  String get walletAddWallet => '지갑 추가';

  @override
  String walletAddLimitReached(int max) {
    return '지갑은 최대 $max개까지 추가할 수 있습니다.';
  }

  @override
  String get walletManage => '관리';

  @override
  String get walletAddSheetTitle => '지갑 추가';

  @override
  String get walletAddSheetSubtitle =>
      '각 지갑은 고유한 복구 문구와 계정을 가지며, PIN 하나로 모두 잠금 해제됩니다.';

  @override
  String get walletAddCreate => '새 지갑 만들기';

  @override
  String get walletAddCreateSubtitle => '새 복구 문구 생성';

  @override
  String get walletAddImport => '복구 문구 가져오기';

  @override
  String get walletAddImportSubtitle => '다른 문구 또는 다른 계정 사용';

  @override
  String get walletAddSeedVault => 'Seed Vault 연결';

  @override
  String get walletAddSeedVaultSubtitle => 'Seeker의 계정 사용';

  @override
  String get walletNameTitle => '지갑 이름 정하기';

  @override
  String get walletNameSubtitle => '이 기기에만 저장되며 언제든지 변경할 수 있습니다.';

  @override
  String get walletNameLabel => '지갑 이름';

  @override
  String get walletNameEmpty => '지갑 이름을 입력하세요';

  @override
  String walletAdded(String name) {
    return '$name 추가됨';
  }

  @override
  String walletSwitched(String name) {
    return '$name(으)로 전환됨';
  }

  @override
  String get walletDuplicateTitle => '이미 추가됨';

  @override
  String get walletDuplicateMessage =>
      '이 복구 문구와 계정은 이미 추가되어 있습니다. 같은 문구 + 계정은 한 번만 추가할 수 있습니다.';

  @override
  String get walletAlreadyAddedBadge => '추가됨';

  @override
  String get walletRename => '이름 변경';

  @override
  String get walletRenameTitle => '지갑 이름 변경';

  @override
  String get walletRemove => '삭제';

  @override
  String walletRemoveTitle(String name) {
    return '$name을(를) 삭제할까요?';
  }

  @override
  String get walletRemoveMessage =>
      '이 기기에서 지갑을 삭제합니다. 먼저 복구 문구를 백업하세요. 없으면 자산을 복구할 수 없습니다.';

  @override
  String get walletRemoveExternalMessage =>
      'Benny와의 연결을 해제합니다. 키는 Seed Vault에 안전하게 보관됩니다.';

  @override
  String walletRemoved(String name) {
    return '$name 삭제됨';
  }

  @override
  String get walletActiveBadge => '사용 중';

  @override
  String get walletTypePhrase => '복구 문구';

  @override
  String get walletTypeSeedVault => 'Seed Vault';

  @override
  String get swapWalletChanged => '사용 중인 지갑이 바뀌었습니다. 돌아가서 견적을 다시 받으세요.';

  @override
  String seedVaultPickNamedSeed(String seed, String wallet) {
    return '다음 화면에서 시드 「$seed」를 선택하세요. $wallet이(가) 이 시드에 있습니다.';
  }

  @override
  String seedVaultPickUnknownSeed(String wallet) {
    return '$wallet이(가) 들어 있는 시드를 선택하세요. 잘못 선택하면 알려 드리고 그 시드는 목록에서 사라집니다.';
  }

  @override
  String seedVaultWrongSeedNamed(String seed) {
    return '시드 「$seed」에는 이 지갑이 없습니다.';
  }

  @override
  String get seedVaultReauthorizeTitle => 'Seed Vault 재승인';

  @override
  String get childAddFromMyWallets => '또는 내 지갑에서 선택';

  @override
  String get walletAddChildModeSetPin =>
      '이 지갑에는 저장된 어린이 모드 PIN이 없습니다. 다음 단계에서 설정하세요. 어린이 모드를 끌 때 필요합니다.';

  @override
  String get settingsChildModeAppPinTitle => '어린이 모드를 끄려면 앱 PIN을 입력하세요';

  @override
  String get walletAddChildModeTitle => '어린이 모드 지갑입니다';

  @override
  String get walletAddChildModeMessage =>
      '가져오면 앱이 어린이 모드로 전환됩니다. 지갑 전환 화면이 숨겨지고, 지갑을 추가하거나 내 다른 지갑으로 송금할 수 없습니다. 가져오시겠습니까?';

  @override
  String get walletAddChildModeConfirm => '동의하고 가져오기';

  @override
  String get walletTypeStandard => '일반';

  @override
  String get sendToMyWallet => '내 지갑으로 보내기';

  @override
  String get walletChildModeLocked => '지갑을 전환하거나 추가하려면 어린이 모드를 끄세요.';

  @override
  String get walletPinToContinue => '계속하려면 PIN을 입력하세요';

  @override
  String get walletActionFailed => '문제가 발생했습니다. 다시 시도하세요.';

  @override
  String get settingsChangePin => 'PIN 변경';

  @override
  String get settingsChangePinSubtitle => 'PIN 하나로 모든 지갑 잠금 해제';

  @override
  String get changePinCurrent => '현재 PIN 입력';

  @override
  String get changePinNew => '새 PIN 입력';

  @override
  String get changePinConfirm => '새 PIN 확인';

  @override
  String get changePinSuccess => 'PIN이 변경되었습니다';

  @override
  String get changePinSameAsOld => '다른 PIN을 선택하세요';

  @override
  String get unlockSetPinTitle => 'Benny PIN 설정';

  @override
  String get unlockSetPinSubtitle => '이제 PIN 하나로 이 기기의 모든 지갑을 보호합니다.';

  @override
  String get pinUnlocksAllWallets => '이 PIN으로 모든 지갑을 잠금 해제합니다.';

  @override
  String settingsLogOutAllWallets(int count) {
    return '이 기기에서 지갑 $count개를 모두 삭제합니다. 먼저 각 복구 문구를 백업하세요.';
  }

  @override
  String importAccountLabel(int number) {
    return '계정 $number';
  }

  @override
  String importAccountAltLabel(int number) {
    return '계정 $number · 대체 경로';
  }

  @override
  String get importLegacyLabel => '레거시';

  @override
  String get travelGuardTitle => '여행 강도 방지';

  @override
  String get travelGuardOffSubtitle => '지갑 하나만 여는 특별 PIN';

  @override
  String get travelGuardOnSubtitle => '켜짐: 특별 PIN은 지갑 하나만 엽니다';

  @override
  String get travelGuardInfoTitle => '여행 강도 방지란?';

  @override
  String get travelGuardInfoBody =>
      '누군가 지갑을 열라고 강요할 때를 위한 기능입니다.\n\n특별 PIN을 설정하고 지갑 하나를 고르세요(소액만 보관 권장). 특별 PIN으로 잠금 해제하면 그 지갑만 열리고, 다른 지갑과 잔액, 메시지는 지갑 목록과 송금을 포함한 모든 곳에서 숨겨지며 이 설정도 보이지 않습니다.\n\n켜져 있는 동안 생체 인증 잠금 해제는 꺼지며 켤 수 없습니다.\n\n앱을 잠근 뒤 원래 PIN으로 해제하면 모든 지갑이 다시 보입니다.';

  @override
  String get travelGuardChooseWallet => '특별 PIN으로 열 지갑 선택';

  @override
  String get travelGuardNewPin => '특별 PIN 설정';

  @override
  String get travelGuardConfirmPin => '특별 PIN 다시 입력';

  @override
  String get travelGuardPinHint => '원래 PIN과 달라야 합니다.';

  @override
  String get travelGuardPinSameAsApp => '원래 PIN입니다. 다른 번호를 고르세요.';

  @override
  String get travelGuardEnabled => '여행 강도 방지를 켰습니다';

  @override
  String get travelGuardDisabled => '여행 강도 방지를 껐습니다';

  @override
  String get travelGuardActiveBadge => '여행 강도 방지 켜짐';

  @override
  String get travelGuardBiometricsOff => '여행 강도 방지가 켜져 있어 사용할 수 없습니다';

  @override
  String get welcomeUseAsSigner => '이 휴대폰을 오프라인 서명 기기로 사용';

  @override
  String get walletAddAirGap => '오프라인 서명 기기 연결';

  @override
  String get walletAddAirGapSubtitle => '키는 인터넷에 연결되지 않는 다른 휴대폰에 보관됩니다';

  @override
  String createWalletWordCount(int count) {
    return '$count개 단어';
  }

  @override
  String get signerAppTitle => 'Benny Signer';

  @override
  String get signerNeedsNoWalletsTitle => '먼저 모든 지갑을 삭제하세요';

  @override
  String get signerNeedsNoWalletsBody =>
      '서명 기기에는 자체 오프라인 복구 문구만 보관됩니다. 설정 > 지갑에서 이 휴대폰의 모든 지갑을 백업한 후 삭제하고 다시 시도하세요.';

  @override
  String get signerEnterTitle => '이 휴대폰을 서명 기기로 전환할까요?';

  @override
  String get signerEnterBody =>
      '이 휴대폰은 오프라인 상태를 유지하며 서명만 합니다. 지갑 화면은 표시되지 않습니다. 다시 지갑으로 사용하려면 초기화해야 합니다.';

  @override
  String get signerIntroTitle => '오프라인 서명 기기';

  @override
  String get signerIntroPoint1 => '이 휴대폰에 복구 문구를 보관하며 다시는 온라인에 연결하지 않습니다.';

  @override
  String get signerIntroPoint2 =>
      'Benny Wallet이 설치된 다른 휴대폰에서 거래를 생성하고, 이 기기에서 QR 코드를 스캔해 서명합니다.';

  @override
  String get signerIntroPoint3 => '복구 문구를 생성하기 전에 모든 네트워크를 끄도록 안내해 드립니다.';

  @override
  String get signerIntroPoint4 => '복구 문구를 종이에 적어 두세요. 유일한 백업입니다.';

  @override
  String get signerIntroStart => '시작';

  @override
  String get signerIntroCancel => '나중에 하기, 지갑으로 사용';

  @override
  String get signerOfflineTitle => '이 휴대폰을 오프라인으로 전환';

  @override
  String get signerOfflineBody =>
      '비행기 모드를 켜고 Wi-Fi, 블루투스, NFC를 끄세요. 모든 필수 항목이 초록색이 되면 계속할 수 있습니다.';

  @override
  String get signerCheckAirplane => '비행기 모드 켜짐';

  @override
  String get signerCheckWifi => 'Wi-Fi 꺼짐';

  @override
  String get signerCheckBluetooth => '블루투스 꺼짐';

  @override
  String get signerCheckNfc => 'NFC 꺼짐';

  @override
  String get signerCheckNoNetwork => '네트워크 연결 없음';

  @override
  String get signerCheckUsbDebugging => 'USB 디버깅 꺼짐';

  @override
  String get signerCheckSim => 'SIM 카드 제거됨 (권장)';

  @override
  String get signerCheckManualHint => '이 항목은 자동으로 확인할 수 없습니다. 직접 확인하세요.';

  @override
  String get signerOpenSettings => '설정 열기';

  @override
  String get signerNetworkDetected => '네트워크 연결이 감지되었습니다. 계속하려면 연결을 끄세요.';

  @override
  String get signerPinTitle => '서명 기기 PIN 설정';

  @override
  String get signerPinBody => '이 서명 기기에 사용할 6자리 PIN을 설정하세요.';

  @override
  String get signerPinConfirmTitle => 'PIN 확인';

  @override
  String get signerPinConfirmBody => 'PIN을 한 번 더 입력하세요.';

  @override
  String get signerPinMismatch => 'PIN이 일치하지 않습니다. 다시 시도하세요.';

  @override
  String get signerSourceTitle => '복구 문구';

  @override
  String get signerSourceBody => '이 오프라인 휴대폰에서 새 복구 문구를 생성하거나 기존 복구 문구를 입력하세요.';

  @override
  String get signerSourceCreate24 => '24개 단어 생성';

  @override
  String get signerSourceCreate24Subtitle => '서명 기기에 권장';

  @override
  String get signerSourceCreate12 => '12개 단어 생성';

  @override
  String get signerSourceCreate12Subtitle => '적기 더 간편함';

  @override
  String get signerSourceImport => '기존 복구 문구 가져오기';

  @override
  String get signerSourceImportSubtitle => '12개 또는 24개 단어';

  @override
  String get signerWordsTitle => '이 단어들을 적어 두세요';

  @override
  String get signerWordsWarning =>
      '단어를 순서대로 종이에 적으세요. 사진이나 스크린샷을 찍거나 다른 곳에 입력하지 마세요. 이 단어를 아는 사람은 누구나 자산을 가져갈 수 있습니다.';

  @override
  String get signerWordsDone => '다 적었습니다';

  @override
  String get signerVerifyTitle => '백업 확인';

  @override
  String get signerImportTitle => '복구 문구 가져오기';

  @override
  String get signerImportBody => '12개 또는 24개 단어를 공백으로 구분하여 입력하세요.';

  @override
  String get signerImportInvalid => '유효한 12개 또는 24개 단어 복구 문구가 아닙니다.';

  @override
  String get signerFinishTitle => '설정 완료';

  @override
  String get signerDeviceNameLabel => '서명 기기 이름';

  @override
  String get signerDeviceNameHelper => '연결 후 지갑에 표시됩니다.';

  @override
  String get signerBiometricToggle => '생체 인증으로 잠금 해제';

  @override
  String get signerFinishButton => '완료';

  @override
  String get signerSetupFailed => '설정을 저장하지 못했습니다. 다시 시도하세요.';

  @override
  String get signerUnlockSubtitle => '서명 기기 PIN을 입력하세요';

  @override
  String get signerUnlockNetworkBlocked =>
      '네트워크 연결이 켜져 있습니다. 잠금을 해제하려면 비행기 모드를 켜세요.';

  @override
  String signerWrongPin(int count) {
    return 'PIN이 올바르지 않습니다. $count회 더 틀리면 서명 기기가 초기화됩니다.';
  }

  @override
  String get signerUnlockFailed => '잠금을 해제하지 못했습니다. 다시 시도하세요.';

  @override
  String get signerUseBiometric => '생체 인증 사용';

  @override
  String get signerBiometricReason => 'Benny 서명 기기 잠금 해제';

  @override
  String get signerBiometricFailed => '생체 인증 설정을 변경하지 못했습니다.';

  @override
  String get signerRecheckTitle => '오프라인 확인';

  @override
  String get signerRecheckBody =>
      '앱이 업데이트되었습니다. 잠금을 해제하기 전에 이 휴대폰이 다시 완전히 오프라인 상태인지 확인하세요.';

  @override
  String get signerLockNow => '잠금';

  @override
  String get signerOfflineChip => '오프라인 서명 기기';

  @override
  String get signerScanToSign => '스캔하여 서명';

  @override
  String get signerPairWallet => '지갑 연결';

  @override
  String get signerAccountsTitle => '계정';

  @override
  String signerAccountName(int number) {
    return '계정 $number';
  }

  @override
  String get signerPairBody =>
      '다른 휴대폰의 Benny Wallet에서 \'오프라인 서명 기기 연결\'을 선택하고 이 코드를 스캔하세요.';

  @override
  String get signerPairPublicOnly => '이 코드에는 공개 주소만 포함되며, 복구 문구는 절대 포함되지 않습니다.';

  @override
  String get signerScanBody => '다른 휴대폰의 Benny Wallet에 표시된 QR 코드를 스캔하세요.';

  @override
  String get signerScanWrongCode => 'Benny Wallet의 서명 요청이 아닙니다.';

  @override
  String get signerScanAgain => '다시 스캔';

  @override
  String get signerRejectUnknownAccount => '이 서명 기기에 없는 계정에 대한 요청입니다.';

  @override
  String get signerRejectNotASigner => '이 계정은 이 거래에 서명할 필요가 없습니다.';

  @override
  String get signerRejectUnreadable => '이 거래를 읽을 수 없어 서명하지 않습니다.';

  @override
  String get signerRejectMessageIsTransaction => '이 메시지는 실제로 거래이므로 서명하지 않습니다.';

  @override
  String get signerRejectInvalidCode => '유효한 서명 요청 QR 코드가 아닙니다.';

  @override
  String get signerReviewTitle => '검토 및 서명';

  @override
  String get signerReviewAccount => '서명 계정';

  @override
  String get signerReviewFee => '네트워크 수수료';

  @override
  String get signerReviewMessage => '메시지';

  @override
  String signerBinaryMessage(int count) {
    return '바이너리 데이터 ($count바이트)';
  }

  @override
  String get signerThisAccount => '이 계정';

  @override
  String signerActionSendSol(String amount) {
    return '$amount SOL 보내기';
  }

  @override
  String signerActionSendToken(String amount, String symbol) {
    return '$amount $symbol 보내기';
  }

  @override
  String signerActionSendUnverified(String amount) {
    return '확인되지 않은 토큰 $amount개 보내기';
  }

  @override
  String signerActionTo(String address) {
    return '받는 주소: $address';
  }

  @override
  String signerActionToTokenAccount(String address) {
    return '받는 토큰 계정: $address';
  }

  @override
  String signerActionMint(String mint) {
    return '토큰 주소: $mint';
  }

  @override
  String signerActionOwner(String address) {
    return '소유자: $address';
  }

  @override
  String signerActionRentTo(String address) {
    return '렌트 반환 주소: $address';
  }

  @override
  String get signerActionCreateTokenAccount => '토큰 계정 생성';

  @override
  String get signerActionCloseTokenAccount => '토큰 계정 닫기';

  @override
  String get signerActionMemo => '메모';

  @override
  String get signerActionApprove => '다른 계정이 내 토큰을 사용하도록 허용';

  @override
  String get signerActionSetAuthority => '계정 권한 변경';

  @override
  String get signerActionAssign => '계정 소유자 변경';

  @override
  String get signerActionCreateAccount => '계정 생성';

  @override
  String signerActionProgram(String program) {
    return '프로그램 $program';
  }

  @override
  String get signerHoldToSign => '길게 눌러 서명';

  @override
  String get signerReject => '거부';

  @override
  String get signerSignFailed => '서명에 실패했습니다. 다시 시도하세요.';

  @override
  String get signerSignatureTitle => '서명';

  @override
  String get signerSignatureBody => '다른 휴대폰의 Benny Wallet으로 이 코드를 스캔하면 완료됩니다.';

  @override
  String get signerSettingsTitle => '서명 기기 설정';

  @override
  String get signerAccountCount => '표시할 계정 수';

  @override
  String get signerAccountCountHint => '이 복구 문구에서 최대 5개 계정';

  @override
  String get signerUpgradeTitle => '서명 기기 업데이트';

  @override
  String get signerUpgradeIntro =>
      '앱을 업데이트하려면 네트워크가 필요하므로 미리 계획하세요. 온라인 상태인 동안에도 복구 문구는 이 휴대폰에 암호화되어 보관되며, 휴대폰이 다시 오프라인이 될 때까지 서명 기기는 이를 열지 않습니다.';

  @override
  String get signerUpgradeStep0 => '1. 종이 백업 확인';

  @override
  String get signerUpgradeVerifyBackup => '백업 확인';

  @override
  String get signerUpgradeBackupOk => '백업 확인 완료';

  @override
  String get signerUpgradeOnlineTitle => '2a. 일반 업데이트';

  @override
  String get signerUpgradeOnlineBody =>
      '서명 기기를 잠그세요. 네트워크를 켜고 설치했던 스토어에서 Benny Wallet을 업데이트하세요. 비행기 모드를 다시 켜세요. 잠금을 해제하기 전에 서명 기기가 오프라인 확인을 다시 진행합니다.';

  @override
  String get signerUpgradeSecureTitle => '2b. 가장 안전한 업데이트';

  @override
  String get signerUpgradeSecureBody =>
      '설정에서 서명 기기를 초기화한 후 온라인으로 앱을 업데이트하세요. 다시 오프라인으로 전환하고 서명 기기를 설정한 뒤 복구 문구를 가져오세요. 계정과 주소는 그대로 유지됩니다.';

  @override
  String get signerUpgradeOfflineApkTitle => 'Android: 온라인 연결 없이 업데이트';

  @override
  String get signerUpgradeOfflineApkBody =>
      'benny-wallet.com에서 받은 새 APK를 USB 케이블이나 SD 카드로 이 휴대폰에 복사해 오프라인 상태로 설치할 수도 있습니다. 같은 출처의 버전 위에만 설치하세요.';

  @override
  String get signerUpgradeCompatTitle => '이전 서명 기기도 계속 사용 가능';

  @override
  String get signerUpgradeCompatBody =>
      '최신 지갑 앱은 이전 버전의 서명 기기와도 함께 작동합니다. 지갑은 이 서명 기기가 지원하는 기능만 요청하므로 편할 때 업데이트하면 됩니다.';

  @override
  String get signerVersionTitle => '버전';

  @override
  String signerVersionDetail(String app, int protocol, int tokens) {
    return '앱 $app · 프로토콜 $protocol · 토큰 목록 $tokens';
  }

  @override
  String get signerEraseTitle => '서명 기기 초기화';

  @override
  String get signerEraseSubtitle => '이 휴대폰에서 복구 문구를 삭제합니다';

  @override
  String get signerEraseBody =>
      '이 휴대폰에서 복구 문구가 삭제됩니다. 종이 백업이 없으면 자산을 복구할 수 없습니다.';

  @override
  String get signerEraseConfirm => '초기화';

  @override
  String get signerEraseWrongPin => 'PIN이 올바르지 않습니다. 아무것도 삭제되지 않았습니다.';

  @override
  String get airGapConnectTitle => '오프라인 서명 기기 연결';

  @override
  String get airGapConnectBody => '서명 기기 휴대폰에서 \'지갑 연결\'을 탭한 후 표시되는 코드를 스캔하세요.';

  @override
  String get airGapConnectInvalid => '서명 기기 페어링 코드가 아닙니다.';

  @override
  String airGapConnectChoose(String device) {
    return '$device에서 계정 선택';
  }

  @override
  String airGapConnectAccount(int number) {
    return '계정 $number';
  }

  @override
  String airGapConnectAccountAdded(int number) {
    return '계정 $number (이미 추가됨)';
  }

  @override
  String get airGapConnectCompare => '주소가 서명 기기에 표시된 주소와 일치하는지 확인하세요.';

  @override
  String get airGapConnectScanAgain => '다시 스캔';

  @override
  String get airGapSignTitle => '서명 기기로 서명';

  @override
  String get airGapSignShowRequestAgain => '요청 다시 표시';

  @override
  String get airGapSignMayHaveExpired =>
      '이 거래가 만료되었을 수 있습니다. 전송에 실패하면 처음부터 다시 시작하세요.';

  @override
  String get airGapSignWrongRequest => '이 서명은 다른 요청에 대한 것입니다.';

  @override
  String get airGapSignInvalidCode => '내 서명 기기에서 생성된 서명이 아닙니다.';

  @override
  String get airGapSignerOutdated =>
      '서명 기기가 이전 버전을 사용 중입니다. 계속 사용할 수 있으며, 편할 때 업데이트하세요.';

  @override
  String get signerIntroSubtitle => '개인 키를 다시는 인터넷에 연결하지 않는 휴대폰에 보관하세요.';

  @override
  String get signerFinishSubtitle => '이 서명기의 이름을 정하고 PIN을 설정하세요.';

  @override
  String signerQuizBody(int count) {
    return '종이 백업을 보고 $count개 위치의 올바른 단어를 고르세요.';
  }

  @override
  String signerQuizProgress(int current, int total) {
    return '$total문항 중 $current번째';
  }

  @override
  String signerQuizQuestion(int position) {
    return '$position번째 단어는 무엇인가요?';
  }

  @override
  String get signerQuizCorrect => '정답입니다!';

  @override
  String get signerQuizWrong => '틀렸습니다. 종이를 확인하세요. 새 단어로 다시 시작합니다.';

  @override
  String get signerQuizShowWords => '단어 다시 보기';

  @override
  String get signerScanToSignSubtitle => '지갑에 표시된 요청을 스캔하세요';

  @override
  String get signerPairWalletSubtitle => 'Benny Wallet이 스캔할 코드를 표시';

  @override
  String get signerWalletPhoneLabel => 'Benny Wallet';

  @override
  String get signerScanRefusedTitle => '서명할 수 없습니다';

  @override
  String get airGapSignerLabel => '서명기';

  @override
  String get airGapThisPhone => '이 휴대폰';

  @override
  String get airGapConnectFound => '서명기를 인식했습니다';

  @override
  String get airGapSignNeedsSigner => '서명기에서 확인하고 서명해야 합니다';

  @override
  String get airGapSignStepShort1 => '서명기가 스캔';

  @override
  String get airGapSignStepShort2 => '서명 스캔';

  @override
  String airGapSignStep1Named(String device) {
    return '1단계: “$device”(으)로 이 코드를 스캔하세요';
  }

  @override
  String airGapSignStep1BodyNamed(String device) {
    return '“$device”에서 스캔하여 서명을 누르고 내용을 확인한 뒤 승인하세요.';
  }

  @override
  String airGapSignStep2Named(String device) {
    return '2단계: “$device”의 서명 코드를 스캔하세요';
  }

  @override
  String airGapSignStep2BodyNamed(String device) {
    return '승인하면 “$device”에 서명 코드가 표시됩니다. 이 휴대폰으로 스캔하세요.';
  }

  @override
  String airGapSignScanSignatureNamed(String device) {
    return '다음: $device의 서명 스캔';
  }

  @override
  String signerActionSwapPair(String from, String to) {
    return '스왑 $from → $to';
  }

  @override
  String signerSwapPay(String amount) {
    return '지불 $amount';
  }

  @override
  String signerSwapPayAtMost(String amount) {
    return '최대 지불 $amount';
  }

  @override
  String signerSwapReceive(String amount) {
    return '받는 금액 $amount';
  }

  @override
  String signerSwapReceiveAtLeast(String amount) {
    return '최소 받는 금액 $amount';
  }

  @override
  String get signerSwapUnverifiedToken => '미확인 토큰';

  @override
  String airGapSignTimeLeft(int seconds) {
    return '$seconds초 남음. 시간이 지나면 새 코드가 자동으로 표시됩니다.';
  }

  @override
  String get airGapSignRefreshing => '시간이 지났습니다. 새 견적과 코드를 받는 중…';

  @override
  String airGapSignRefreshed(String device) {
    return '이전 코드가 만료되어 새 코드로 바꿨습니다. “$device”(으)로 다시 스캔하세요.';
  }

  @override
  String get airGapSignRefreshFailed => '새 코드를 받지 못했습니다. 연결을 확인하고 다시 시도하세요.';

  @override
  String get airGapSignOldRequest => '만료된 코드의 서명입니다. 먼저 서명기로 새 코드를 스캔하세요.';

  @override
  String get scanHintRoleShows => '코드 표시';

  @override
  String get scanHintRoleScans => '스캔';

  @override
  String signerTokenUnchecked(String symbol) {
    return '$symbol(미확인)';
  }

  @override
  String get signerReviewActions => '거래 내용';

  @override
  String get signerNewerWalletNotice =>
      '지갑이 서명기보다 최신 버전입니다. 시간 될 때 서명기를 업데이트하세요.';

  @override
  String get signerDangerBanner => '고위험입니다. 본인이 시작한 것이 아니면 서명하지 마세요.';

  @override
  String get signerActionSwap => '스왑';

  @override
  String get signerActionSwapDetail => '수량은 지갑에서 확인하세요.';

  @override
  String get signerActionDangerDetail => '위험한 작업입니다. 잘 모르면 서명하지 마세요.';

  @override
  String get signerActionAdvanceNonce => '거래 번호 업데이트';

  @override
  String get signerActionSyncNative => 'SOL 잔액 업데이트';

  @override
  String get signerHoldLongHint => '꼼꼼히 확인한 뒤 3초간 누르세요.';

  @override
  String signerTokenVerified(String token) {
    return '$token · Benny Wallet 확인됨';
  }

  @override
  String signerTokenWalletProvided(String symbol) {
    return '$symbol · Benny Wallet 미확인';
  }

  @override
  String signerSwapWalletQuote(String pay, String receive) {
    return '예상: $pay 지불, 약 $receive 받음';
  }

  @override
  String get signerActionUnknown => '알 수 없는 작업';

  @override
  String signerActionCreateTokenAccountFor(String symbol) {
    return '$symbol 계정 개설';
  }

  @override
  String get signerUnresolvedAccounts =>
      '서명기가 이 거래 전체를 볼 수 없습니다. 방금 직접 시작한 경우에만 서명하세요.';

  @override
  String get signerTokenNotVerified => 'Benny Wallet 미확인';

  @override
  String get signerKindSwap => '스왑';

  @override
  String get signerKindSend => '보내기';

  @override
  String signerAbout(String amount) {
    return '약 $amount';
  }

  @override
  String get signerAmountsFromWallet => '수량은 지갑이 제공';

  @override
  String get signerTrustSafe => '모든 토큰이 Benny Wallet에서 확인됨';

  @override
  String get signerTrustCaution => '토큰 하나가 Benny Wallet에서 확인되지 않았습니다. 주의하세요.';

  @override
  String get signerTrustDangerSwap =>
      '두 토큰 모두 Benny Wallet에서 확인되지 않았습니다. 고위험입니다.';

  @override
  String get signerTrustDangerSend =>
      '이 토큰은 Benny Wallet에서 확인되지 않았습니다. 고위험입니다.';

  @override
  String get signerReviewOtherSteps => '기타 단계';

  @override
  String get signerPay => '지불';

  @override
  String get signerPayAtMost => '최대 지불';

  @override
  String get signerGet => '받음';

  @override
  String get signerGetAtLeast => '최소 받음';

  @override
  String get signerGetAbout => '약 받음';

  @override
  String get signerRecipient => '받는 사람';

  @override
  String get signerRecipientTokenAccount => '받는 사람 토큰 계정';

  @override
  String get signerUsdFromWallet => '달러 금액은 지갑의 추정치입니다';

  @override
  String signerActionCreateTokenAccountForRecipient(String symbol) {
    return '받는 사람의 $symbol 계정 개설';
  }

  @override
  String get signerCreateAccountSkipIfOpen =>
      '(처음에만 약 0.002 SOL; 이미 있으면 자동으로 건너뛰고 비용 없음)';

  @override
  String get signerCreateAccountNotOpen => '(아직 없음; 약 0.002 SOL 필요)';

  @override
  String get signerAddressFromWallet => '이 주소는 지갑이 제공한 것으로, 서명기가 확인할 수 없습니다.';

  @override
  String get signerSwapOutputUnchecked => '교환한 토큰이 내 계정으로 오는지 확인할 수 없습니다.';

  @override
  String get signerExtraOutflow => '이 거래는 다른 주소로도 자금을 보냅니다.';

  @override
  String signerHighFee(String amount) {
    return '네트워크 수수료가 매우 높음: $amount SOL';
  }

  @override
  String get signerDurableNonce => '이 서명은 만료되지 않아 나중에도 사용될 수 있습니다.';

  @override
  String get signerSwapFromWallet => '토큰 또는 수량은 지갑이 제공한 것이라 확인할 수 없습니다.';

  @override
  String signerActionCloseTo(String address) {
    return '잔액과 렌트 받는 주소: $address';
  }

  @override
  String signerWalletNote(String name) {
    return '지갑 메모: $name';
  }

  @override
  String get signerReviewFeePayer => '수수료 지불 계정';

  @override
  String signerActionOwnerProgram(String program) {
    return '프로그램 $program이(가) 관리';
  }

  @override
  String get signerSlippageAll => '슬리피지 100% 이상: 아무것도 받지 못할 수 있습니다.';

  @override
  String get signerQuizTooManyWrong => '오답이 너무 많습니다. PIN을 입력한 뒤 다시 시도하세요.';

  @override
  String get signerSignInTitle => '로그인 요청';

  @override
  String get signerKindSignIn => '로그인';

  @override
  String get signerSignInBenny => 'Benny Wallet 로그인';

  @override
  String signerSignInOtherSite(String site) {
    return '“$site”에서 로그인을 요청합니다. 직접 시작한 경우에만 서명하세요.';
  }

  @override
  String get signerSignInExpired =>
      '이 로그인 요청은 만료되었습니다. 이 기기의 시간을 확인하거나 지갑에서 다시 시작하세요.';

  @override
  String get signerSignInOtherAccount => '다른 계정의 로그인입니다. 서명하지 마세요.';

  @override
  String get signerSignInWhat =>
      '이 계정이 본인 것임을 증명해 Benny가 잔액, 기록, 알림을 보여 줄 수 있게 합니다.';

  @override
  String get signerSignInNoFunds => '자금이 이동하지 않고 수수료도 없습니다.';

  @override
  String get signerSignInShowText => '원문 보기';

  @override
  String get airGapSignInTitle => '서명 기기로 로그인';

  @override
  String get airGapSignInWhy => '왜 서명하나요?';

  @override
  String get airGapSignInWhyBody =>
      '잔액, 기록, 알림을 불러오기 전에 Benny가 이 계정이 본인 것인지 확인해야 합니다. 보통 지갑마다 한 번만 하면 됩니다.';

  @override
  String get airGapSignInSafe => '로그인일 뿐입니다. 자금이 이동하지 않고 수수료도 없습니다.';

  @override
  String airGapSignInSignerShows(String device) {
    return '“$device”에 “Benny Wallet 로그인”이 표시됩니다.';
  }

  @override
  String airGapSignInSignerShowsText(String device) {
    return '“$device”에 “Benny Wallet wants you to sign in”으로 시작하는 영어 문장이 표시됩니다. 이것이 이번 로그인입니다. 서명 기기를 업데이트하면 “Benny Wallet 로그인”으로 표시됩니다.';
  }
}
