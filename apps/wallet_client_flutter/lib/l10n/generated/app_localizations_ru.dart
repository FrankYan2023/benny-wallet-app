// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Benny Wallet';

  @override
  String get brandShortName => 'Benny';

  @override
  String get commonBack => 'Назад';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonClose => 'Закрывать';

  @override
  String get commonContinue => 'Продолжать';

  @override
  String get commonConfirm => 'Подтверждать';

  @override
  String get commonCopied => 'Скопировано';

  @override
  String get commonCopy => 'Копировать';

  @override
  String get commonDone => 'Сделанный';

  @override
  String get commonLater => 'Позже';

  @override
  String get commonLoading => 'Загрузка...';

  @override
  String get commonMax => 'MAX';

  @override
  String get commonNext => 'Следующий';

  @override
  String get commonOk => 'ХОРОШО';

  @override
  String get commonRetry => 'Повторить попытку';

  @override
  String get commonSettings => 'Настройки';

  @override
  String get commonShare => 'Делиться';

  @override
  String get commonUpdate => 'Обновлять';

  @override
  String get languageSystem => 'Система';

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
  String get settingsLanguage => 'Язык';

  @override
  String get settingsLanguageSubtitle => 'Выберите язык приложения';

  @override
  String get settingsLanguageSystemDescription =>
      'Следовать за этим устройством';

  @override
  String get settingsLanguageSheetTitle => 'Язык';

  @override
  String get settingsLanguageSheetSubtitle =>
      'Выберите язык, используемый в Benny.';

  @override
  String get settingsBiometricUnlock => 'Биометрическая разблокировка';

  @override
  String get settingsUseFingerprint => 'Использовать отпечаток пальца';

  @override
  String get settingsUnlockWalletToEnable =>
      'Разблокируйте кошелек, чтобы включить';

  @override
  String get settingsAutoLock => 'Автоматическая блокировка';

  @override
  String get settingsAutoLockSheetSubtitle =>
      'Выберите, когда Benny снова заблокируется.';

  @override
  String get settingsNotifications => 'Получать уведомления';

  @override
  String get settingsNotificationsSubtitle =>
      'Получите уведомление о поступлении средств';

  @override
  String get settingsChildMode => 'Детский режим';

  @override
  String get settingsChildModeActive => 'Детский режим активен';

  @override
  String get settingsChildModeActiveDescription =>
      'Кошелек остается в режиме только приема до тех пор, пока не будет введен 4-значный дочерний режим PIN.';

  @override
  String get settingsChildModeProtected =>
      'Защищено 4-значным дочерним режимом PIN.';

  @override
  String get settingsChildModeRemoveAccounts =>
      'Удалите все дочерние учетные записи перед включением';

  @override
  String get settingsChildModeSetPin =>
      'Установите отдельный 4-значный PIN для детского режима.';

  @override
  String get settingsChildAccounts => 'Дочерние аккаунты';

  @override
  String get settingsRentReclaim => 'Возврат арендной платы';

  @override
  String get settingsRentReclaimSubtitle =>
      'Закройте пустые учетные записи токенов и восстановите SOL.';

  @override
  String get settingsFeedback => 'Обратная связь';

  @override
  String get settingsFeedbackSubtitle =>
      'Сообщите о проблеме или задайте вопрос';

  @override
  String get settingsLogOut => 'Выйти';

  @override
  String get settingsLogOutSubtitle => 'Вернуться на главный экран';

  @override
  String get settingsIncorrectPin => 'Неправильный PIN';

  @override
  String get settingsPersistentBiometricUnsupported =>
      'Постоянная биометрическая разблокировка не поддерживается на этом устройстве.';

  @override
  String get settingsBiometricsUnavailable =>
      'Биометрия на этом устройстве недоступна.';

  @override
  String get settingsBiometricEnabled => 'Биометрия включена';

  @override
  String get settingsBiometricDisabled => 'Биометрия отключена';

  @override
  String get settingsUnlockBeforeBiometrics =>
      'Разблокируйте кошелек перед включением биометрии.';

  @override
  String get settingsNotificationsSystemDisabled =>
      'Уведомления отключены. Включите их в настройках системы.';

  @override
  String get settingsNotificationsEnabled => 'Получение уведомлений включено';

  @override
  String get settingsNotificationsDisabled => 'Получение уведомлений отключено';

  @override
  String settingsNotificationsUpdateFailed(String error) {
    return 'Не удалось обновить уведомления: $error.';
  }

  @override
  String get settingsRemoveChildAccountsFirst =>
      'Прежде чем включать детский режим, удалите все дочерние учетные записи.';

  @override
  String get settingsChildModeEnabled => 'Детский режим включен';

  @override
  String get settingsChildModeDisabled => 'Детский режим отключен';

  @override
  String settingsChildModeUpdateFailed(String error) {
    return 'Не удалось обновить дочерний режим: $error.';
  }

  @override
  String get settingsCopyRecoveryPhraseFirst =>
      'Сначала скопируйте фразу восстановления.';

  @override
  String get settingsLogOutWarning =>
      'При выходе из системы будут удалены все данные локальных приложений на этом устройстве.';

  @override
  String get settingsWalletUpToDate => 'Benny Wallet обновлен.';

  @override
  String get settingsUpdateCheckFailed => 'Проверка обновления не удалась';

  @override
  String get settingsUnableToCheckUpdates =>
      'Сейчас невозможно проверить наличие обновлений.';

  @override
  String get settingsSeedPhraseBackup => 'Резервное копирование исходной фразы';

  @override
  String get settingsSeedPhraseBackupDescription =>
      'Мы рекомендуем хранить физическую копию в безопасном месте.';

  @override
  String get settingsSecureNow => 'Защитите сейчас';

  @override
  String get settingsCheckingUpdates => 'Проверка...';

  @override
  String get settingsCheckForUpdates => 'Проверьте наличие обновлений';

  @override
  String settingsVersion(String version) {
    return 'Версия $version';
  }

  @override
  String settingsVersionBuild(String version, String buildNumber) {
    return 'Версия $version+$buildNumber';
  }

  @override
  String get autoLockImmediate => 'Немедленно';

  @override
  String get autoLockOneMinute => '1 минута';

  @override
  String get autoLockFiveMinutes => '5 минут';

  @override
  String get autoLockTenMinutes => '10 минут';

  @override
  String get autoLockThirtyMinutes => '30 минут';

  @override
  String get biometricUnlockReason =>
      'Используйте биометрию, чтобы разблокировать Benny Wallet.';

  @override
  String get biometricSetupReason =>
      'Подтвердите биометрию, чтобы включить эту функцию безопасности.';

  @override
  String get unlockFailedTitle => 'Разблокировать не удалось';

  @override
  String get unlockIncorrectPin => 'Неверный PIN.';

  @override
  String get unlockBiometricCancelled => 'Биометрия отменена';

  @override
  String get unlockBiometricFailed =>
      'Биометрическая разблокировка не удалась. Попробуйте еще раз.';

  @override
  String get unlockSessionExpired => 'Срок сеанса истек, используйте PIN';

  @override
  String get unlockBiometricUnavailable => 'Биометрические данные недоступны';

  @override
  String get unlockUseFingerprint => 'Использовать отпечаток пальца';

  @override
  String get unlockEnterPin => 'Введите PIN';

  @override
  String get pinConfirm => 'Подтвердить PIN';

  @override
  String get pinSet => 'Набор Benny PIN';

  @override
  String get pinMismatch => 'PIN не совпадают';

  @override
  String get pinImportFailed => 'Импорт не удался';

  @override
  String get pinExternalWalletSetupDescription =>
      'Это защищает настройки Benny и дочерние учетные записи. Seeker продолжает подписывать ключи в Seeker Wallet.';

  @override
  String get childModeConfirmPinTitle => 'Подтвердите детский режим PIN';

  @override
  String get childModeSetPinTitle => 'Установить детский режим PIN';

  @override
  String get childModeEnterPinTitle => 'Войдите в детский режим PIN';

  @override
  String get childModeConfirmPinSubtitle =>
      'Повторно введите 4-значный номер PIN, используемый только для детского режима.';

  @override
  String get childModeSetPinSubtitle =>
      'Создайте 4-значный PIN, используемый только для дочернего режима.';

  @override
  String get childModeEnterPinSubtitle =>
      'Введите 4-значный код PIN, используемый только для детского режима, чтобы его отключить.';

  @override
  String get childModeOnlyUsed => 'Используется только для детского режима';

  @override
  String get welcomeReplaceWalletTitle => 'Заменить текущий кошелек';

  @override
  String get welcomeReplaceWalletMessage =>
      'Продолжение приведет к удалению текущего кошелька.';

  @override
  String get welcomeConfirmAgainTitle => 'Подтвердите еще раз';

  @override
  String get welcomeConfirmAgainMessage =>
      'После удаления вы можете потерять доступ к фразе. Сначала сохраните его.';

  @override
  String get welcomeNewWalletSubtitle => 'Запустите новый кошелек по умолчанию';

  @override
  String get welcomeImportWalletSubtitleSeeker => 'Фраза или Seeker Vault';

  @override
  String get welcomeImportWalletSubtitlePhrase =>
      'Восстановление с помощью фразы восстановления';

  @override
  String get welcomeHeroSemantics => 'Benny Wallet';

  @override
  String get welcomeHeroPrelude => 'Новый кошелек здесь.';

  @override
  String get welcomeHeroTitle => 'Benny Wallet';

  @override
  String get welcomeHeroSubtitle =>
      'Начните заново или восстановите фразу восстановления.';

  @override
  String get welcomeNewWallet => 'Новый кошелек';

  @override
  String get welcomeImportWallet => 'Импортировать кошелек';

  @override
  String get createWalletTitle => 'Создать кошелек';

  @override
  String get createWalletRecoveryTitle => 'Запишите фразу восстановления.';

  @override
  String get createWalletRecoverySubtitle =>
      'Это единственный способ восстановить свой кошелек.';

  @override
  String get webTestingOnly => 'Веб предназначен только для тестирования.';

  @override
  String get recoveryPhraseCopied =>
      'Фраза восстановления скопирована (будет удалена через 15 секунд).';

  @override
  String get copyPhrase => 'Копировать фразу';

  @override
  String get importWalletTitle => 'Импортировать кошелек';

  @override
  String get importRecoveryPhraseTitle => 'Импортировать фразу восстановления';

  @override
  String get importRecoveryPhraseSubtitle =>
      'Используйте 12 или 24 английских слова.';

  @override
  String get importPasteHint => 'Вставьте сюда фразу восстановления';

  @override
  String get importInvalidPhrase => 'Неверная фраза восстановления';

  @override
  String get importEnterWords => 'Введите или вставьте 12 или 24 слова.';

  @override
  String importWordsDetected(int count) {
    return 'Обнаружены слова $count';
  }

  @override
  String get importClear => 'Прозрачный';

  @override
  String get seekerVaultConnectDescription =>
      'Подключите аппаратный кошелек к этому Seeker.';

  @override
  String get seekerVaultConnect => 'Соединять';

  @override
  String get seekerVaultInstallOrEnable =>
      'Установите или включите Seeker Wallet, затем повторите попытку.';

  @override
  String get seekerVaultAndroidOnly =>
      'Импорт Seeker Vault доступен только на Android.';

  @override
  String get seekerVaultNoAccounts =>
      'Ни одна из существующих учетных записей кошелька Seed Vault не была возвращена для этого начального числа.';

  @override
  String get seekerVaultUnavailable =>
      'Seed Vault недоступен на этом устройстве.';

  @override
  String get seekerVaultCancelled => 'Соединение Seeker Vault было отменено.';

  @override
  String get seekerVaultConnectFailed =>
      'Сейчас невозможно подключить Seeker Vault. Пожалуйста, попробуйте еще раз.';

  @override
  String get receiveTitle => 'Получать';

  @override
  String get receivedHistoryTitle => 'Полученная история';

  @override
  String get receiveShareAddressTitle => 'Поделитесь этим адресом';

  @override
  String get receiveShareAddressSubtitle => 'Отсканируйте или скопируйте его.';

  @override
  String get receiveNoAddress => 'Нет адреса кошелька';

  @override
  String get receiveNoAddressSubtitle =>
      'Создайте или разблокируйте кошелек для получения средств.';

  @override
  String get receiveAddressCopied =>
      'Адрес скопирован (будет удален через 60 секунд)';

  @override
  String get receiveCopyAddress => 'Копировать адрес';

  @override
  String get sendTitle => 'Отправлять';

  @override
  String get sendChooseAssetTitle => 'Выберите актив';

  @override
  String get sendHistoryTitle => 'Отправить историю';

  @override
  String get sendUnavailableChildMode =>
      'Отправка недоступна в дочернем режиме.';

  @override
  String get sendOpenReceive => 'Открыть получение';

  @override
  String get sendNoAssets => 'Нет ресурсов для отправки.';

  @override
  String get sendRecipientPrefilled => 'Получатель предварительно заполнен';

  @override
  String sendLoadAssetsFailed(String error) {
    return 'Не удалось загрузить ресурсы: $error.';
  }

  @override
  String get sendAssetNotFound => 'Актив не найден.';

  @override
  String sendAssetTitle(String symbol) {
    return 'Отправить $symbol';
  }

  @override
  String get sendScanQrCode => 'Сканировать код QR';

  @override
  String get sendRecipientAddressHint => 'Адрес получателя Solana';

  @override
  String sendAvailableAmount(String amount, String symbol) {
    return 'Доступно $amount $symbol';
  }

  @override
  String sendLoadFormFailed(String error) {
    return 'Не удалось загрузить форму отправки: $error.';
  }

  @override
  String get sendInvalidAddress => 'Введите действительный адрес Solana.';

  @override
  String get sendInvalidAmount => 'Введите действительную сумму.';

  @override
  String get sendInsufficientBalance => 'Недостаточный баланс.';

  @override
  String get sendUnlockAgain => 'Перед отправкой снова разблокируйте кошелек.';

  @override
  String get sendNotEnoughSolAfterFee =>
      'Недостаточно SOL после резервирования сетевой платы.';

  @override
  String get sendNotEnoughSolForFee =>
      'SOL недостаточно для покрытия платы за сеть.';

  @override
  String get sendGenericFailure =>
      'Отправить не удалось. Пожалуйста, попробуйте еще раз.';

  @override
  String get sendAmountHint => 'Количество';

  @override
  String get portfolioChildAccounts => 'Дочерние аккаунты';

  @override
  String get portfolioCrypto => 'Крипто';

  @override
  String get portfolioStocks => 'Акции';

  @override
  String get portfolioMessages => 'Сообщения';

  @override
  String get portfolioTokens => 'Токены';

  @override
  String get portfolioDefi => 'DeFi';

  @override
  String get portfolioSend => 'Отправлять';

  @override
  String get portfolioSwap => 'Менять';

  @override
  String get portfolioReceive => 'Получать';

  @override
  String get portfolioCouldNotRefreshAssets => 'Не удалось обновить ресурсы.';

  @override
  String get portfolioPullToRetry => 'Потяните вниз, чтобы повторить попытку.';

  @override
  String get portfolioDefiParentOnly =>
      'DeFi предназначен только для родителей.';

  @override
  String get portfolioDefiParentOnlyMessage =>
      'Вернитесь в родительский режим, чтобы просмотреть позиции протокола.';

  @override
  String get portfolioDefiUnavailable => 'Данные DeFi временно недоступны.';

  @override
  String get portfolioDefiUnavailableMessage => 'Токены все еще актуальны.';

  @override
  String get portfolioNoDefi => 'Вакансий DeFi пока нет';

  @override
  String get portfolioRefreshingDefi => 'Обновление протокольных позиций...';

  @override
  String get portfolioNoActiveDefi =>
      'В вашем кошельке нет активных позиций DeFi.';

  @override
  String get portfolioRefreshFailed => 'Обновить не удалось';

  @override
  String get portfolioNetworkBusy =>
      'Сеть сейчас занята. Потяните вниз, чтобы повторить попытку.';

  @override
  String get portfolioServerUnavailable =>
      'Не удалось связаться с сервером. Проверьте соединение и потяните вниз, чтобы повторить попытку.';

  @override
  String get portfolioRefreshAssetsFailed =>
      'Не удалось обновить ресурсы. Потяните вниз, чтобы повторить попытку.';

  @override
  String get portfolioReceiveSol => 'Получить SOL';

  @override
  String get portfolioReceiveSolSubtitle =>
      'Получите SOL, чтобы начать работу с Benny Wallet.';

  @override
  String get commonAdd => 'Добавлять';

  @override
  String get commonAmount => 'Количество';

  @override
  String get commonAuto => 'Авто';

  @override
  String get commonBuy => 'Купить';

  @override
  String get commonConfirmed => 'Подтвержденный';

  @override
  String get commonCustom => 'Обычай';

  @override
  String get commonDelete => 'Удалить';

  @override
  String get commonEdit => 'Редактировать';

  @override
  String get commonFrom => 'От';

  @override
  String get commonNetwork => 'Сеть';

  @override
  String get commonNetworkFee => 'Сетевая плата';

  @override
  String get commonSave => 'Сохранять';

  @override
  String get commonSend => 'Отправлять';

  @override
  String get commonSignature => 'Подпись';

  @override
  String get commonSolana => 'Solana';

  @override
  String get commonStatus => 'Статус';

  @override
  String get commonSubmitted => 'Поданный';

  @override
  String get commonTo => 'К';

  @override
  String get commonToken => 'Токен';

  @override
  String get transactionTimeline => 'График транзакции';

  @override
  String get walletAddressUnavailable => 'Адрес кошелька недоступен.';

  @override
  String relativeSecondsAgo(Object count) {
    return '$count сек. назад';
  }

  @override
  String relativeMinutesAgo(Object count) {
    return '$countмин назад';
  }

  @override
  String relativeHoursAgo(Object count) {
    return '$countч назад';
  }

  @override
  String relativeDaysAgo(Object count) {
    return '${count}d назад';
  }

  @override
  String get importWalletLoadingTitle => 'Импорт кошелька...';

  @override
  String get importWalletLoadingSubtitle =>
      'Подготовка списка кошельков Solana.';

  @override
  String get importSolanaMainnet => 'Solana Mainnet';

  @override
  String get importSelectSolanaAccount =>
      'Выберите учетную запись Solana для импорта.';

  @override
  String get importLoadingSolanaAccounts =>
      'Загрузка учетных записей Solana...';

  @override
  String get importCheckingActiveSolanaAccounts =>
      'Проверка активных учетных записей Solana.';

  @override
  String get importUnableScanRecoveryPhrase =>
      'Сейчас невозможно отсканировать эту фразу восстановления.';

  @override
  String get importActiveAccount => 'Активный аккаунт';

  @override
  String get importDefaultMainWallet => 'Основной кошелек по умолчанию';

  @override
  String get seekerVaultTitle => 'Seeker Vault';

  @override
  String get seekerVaultChooseFundedAccount => 'Выберите накопительный счет';

  @override
  String get seekerVaultChooseAccount => 'Выберите аккаунт';

  @override
  String get seekerVaultFundedAccountFound =>
      'Benny обнаружил активность учетной записи в этом кошельке Seed Vault.';

  @override
  String get seekerVaultNoFundedAccountFound =>
      'Пополняемый счет не найден. Это учетные записи, возвращенные Seed Vault.';

  @override
  String seekerVaultAssetCount(Object count) {
    return '$count активы';
  }

  @override
  String get seekerVaultNoAssets => 'Нет активов';

  @override
  String get scanAddressTitle => 'Сканировать адрес';

  @override
  String get scanNoSolanaAddress => 'В этом коде QR не найден адрес Solana.';

  @override
  String get scanPointCamera => 'Наведите камеру на код Solana QR.';

  @override
  String get sendConfirmTitle => 'Подтвердить отправку';

  @override
  String get sendSubmitting => 'Отправка...';

  @override
  String sendSubmittingSummary(Object address, Object amount, Object symbol) {
    return '$amount от $symbol до $address';
  }

  @override
  String get sendSubmitted => 'Поданный';

  @override
  String get sendFailed => 'Отправить не удалось';

  @override
  String sendSubmittedMessage(Object address, Object amount, Object symbol) {
    return '$amount $symbol был отправлен на рассмотрение $address. Подтверждение может занять некоторое время.';
  }

  @override
  String get sendTransactionCouldNotComplete =>
      'Транзакция не может быть завершена.';

  @override
  String get sendViewTransaction => 'Посмотреть транзакцию';

  @override
  String get sendRecipientNotReady =>
      'Кошелек получателя еще не готов получить этот токен.';

  @override
  String get sendNetworkBusy => 'Сеть занята. Пожалуйста, попробуйте еще раз.';

  @override
  String get sendNetworkTakingLonger =>
      'Сеть работает дольше, чем ожидалось. Пожалуйста, попробуйте еще раз.';

  @override
  String get sendHistoryEmpty => 'Истории отправки пока нет.';

  @override
  String sendHistoryLoadFailed(Object error) {
    return 'Невозможно загрузить историю отправки: $error.';
  }

  @override
  String get sendDetailsTitle => 'Отправить детали';

  @override
  String get sendNotConfirmedYet => 'Еще не подтверждено';

  @override
  String get sendOpenTokenDetails => 'Открыть детали токена';

  @override
  String get sendViewOnSolscan => 'Посмотреть на Solscan';

  @override
  String get sendToEmpty => 'К --';

  @override
  String sendToAddress(Object address) {
    return 'В $address';
  }

  @override
  String get sendStatusFailed => 'Неуспешный';

  @override
  String get sendStatusFinalized => 'Завершено';

  @override
  String get sendStatusConfirmed => 'Подтвержденный';

  @override
  String get sendStatusSubmitted => 'Поданный';

  @override
  String get sendStatusSourceHeliusWebhook => 'Веб-перехватчик Helius';

  @override
  String get sendStatusSourceRpcSync => 'Синхронизация статуса цепочки';

  @override
  String get sendStatusSourceChainActivity => 'Сетевая активность';

  @override
  String get sendTransactionFallbackTitle => 'Отправить транзакцию';

  @override
  String get sendSubmittedToSender => 'Отправлено отправителю';

  @override
  String get sendSubmittedToSenderSubtitle =>
      'Отправитель Helius принял подписанную транзакцию.';

  @override
  String get sendAsyncResultFailed => 'Асинхронный результат не удался';

  @override
  String get sendWaitingAsyncConfirmation =>
      'Ожидание асинхронного подтверждения';

  @override
  String get sendAsyncConfirmationReceived =>
      'Асинхронное подтверждение получено';

  @override
  String get sendUpdatedFromHeliusWebhook =>
      'Обновлено веб-перехватчиком Helius.';

  @override
  String get sendUpdatedFromChainStatusSync =>
      'Обновлено из синхронизации статуса цепочки.';

  @override
  String get sendConfirmationNotReceivedYet => 'Подтверждение еще не получено.';

  @override
  String get swapTitle => 'Менять';

  @override
  String get swapButton => 'Менять';

  @override
  String get swapReviewTitle => 'Обзор обмена';

  @override
  String swapForAmount(Object amount, Object symbol) {
    return 'для ~$amount $symbol';
  }

  @override
  String get swapPay => 'Платить';

  @override
  String get swapReceive => 'Получать';

  @override
  String get swapMinimumReceive => 'Минимальное получение';

  @override
  String get swapSlippage => 'проскальзывание';

  @override
  String get swapPriorityFee => 'Плата за приоритет';

  @override
  String get swapRoute => 'Маршрут';

  @override
  String swapLamports(Object lamports) {
    return 'Лампорты $lamports';
  }

  @override
  String get swapPriorityNormal => 'Нормальный';

  @override
  String get swapPriorityFast => 'Быстрый';

  @override
  String get swapPriorityTurbo => 'Турбо';

  @override
  String get swapProcessing => 'Обмен...';

  @override
  String swapProcessingSummary(
    Object inputAmount,
    Object inputSymbol,
    Object outputAmount,
    Object outputSymbol,
  ) {
    return '$inputAmount $inputSymbol — $outputAmount $outputSymbol';
  }

  @override
  String get swapComplete => 'Обмен завершен';

  @override
  String get swapFailed => 'Замена не удалась';

  @override
  String swapReceivedAmount(Object amount, Object symbol) {
    return '$amount $symbol получен';
  }

  @override
  String get swapCouldNotComplete => 'Обмен не удалось завершить.';

  @override
  String get swapTradingUnavailableChildMode =>
      'Торговля недоступна в дочернем режиме.';

  @override
  String get swapNoBaseAssetsForXStocks =>
      'Для покупки xStocks не доступны SOL, USDC или USDT.';

  @override
  String get swapNoAssetsAvailable => 'Нет активов, доступных для обмена.';

  @override
  String get swapPayWith => 'Оплатить с помощью';

  @override
  String get swapBuyXStock => 'Купить xStock';

  @override
  String swapAvailable(Object amount, Object symbol) {
    return 'Доступно $amount $symbol';
  }

  @override
  String get swapRefreshingQuote => 'Свежая цитата...';

  @override
  String swapRouteLabel(Object route) {
    return 'Маршрут: $route';
  }

  @override
  String get swapBestRoute => 'Лучший маршрут';

  @override
  String swapFailedLoadWalletAssets(Object error) {
    return 'Не удалось загрузить активы кошелька: $error.';
  }

  @override
  String swapRateSummary(Object inputSymbol, Object outputSymbol, Object rate) {
    return '1 $inputSymbol ≈ $rate $outputSymbol';
  }

  @override
  String swapSlippageMin(Object value) {
    return '$value мин.';
  }

  @override
  String swapCustomWithValue(Object value) {
    return 'Пользовательский · $value';
  }

  @override
  String swapMinReceive(Object amount) {
    return 'Мин $amount';
  }

  @override
  String get swapAmountTooSmall =>
      'Эта сумма слишком мала для действующего маршрута.';

  @override
  String get swapWaitValidQuote =>
      'Прежде чем продолжить, дождитесь действительного предложения.';

  @override
  String swapNotEnoughSolReserve(Object reserve) {
    return 'Недостаточно SOL.\nНужен резерв $reserve SOL.';
  }

  @override
  String get swapRouteUnavailable =>
      'Этот маршрут замены сейчас недоступен. Попробуйте поменяться с SOL или выберите другую пару токенов.';

  @override
  String get swapPriceMoved =>
      'Цена изменилась до отправки свопа. Увеличьте проскальзывание и повторите попытку.';

  @override
  String get swapNotEnoughTokenBalance =>
      'Недостаточно токенов на балансе. Нажмите «Макс» еще раз и повторите попытку.';

  @override
  String get swapQuotesBusy =>
      'Котировки сейчас заняты. Повторите попытку через минуту.';

  @override
  String get swapQuoteExpired =>
      'Срок действия этой цитаты истек. Просмотрите обмен еще раз.';

  @override
  String get swapUnlockAgain => 'Перед заменой снова разблокируйте кошелек.';

  @override
  String get swapTransactionUnavailable => 'Своп-сделка невозможна.';

  @override
  String get swapConnectSeekerVaultAgain =>
      'Перед заменой снова подключите Seeker Vault.';

  @override
  String get swapConnectSeedVaultAgain =>
      'Перед заменой снова подключите Seed Vault.';

  @override
  String get swapUnexpectedSignatureCount =>
      'Кошелек вернул неожиданное количество подписей.';

  @override
  String get swapCustomSlippageLabel => 'Пользовательское проскальзывание, %';

  @override
  String get swapChooseToken => 'Выбирать';

  @override
  String get swapApproxYouReceive => 'Прибл. вы получаете';

  @override
  String get swapRate => 'Ставка';

  @override
  String get swapPlatformFee => 'Плата за платформу';

  @override
  String get swapSearchTokenHint => 'Поиск по имени или символу токена';

  @override
  String get swapNoTokensAvailable => 'Нет доступных токенов';

  @override
  String swapNoResultsFor(Object query) {
    return 'По запросу \"$query\" результатов не найдено.';
  }

  @override
  String get swapYourAssets => 'Ваши активы';

  @override
  String get swapSuggestedTokens => 'Предлагаемые токены';

  @override
  String swapAvailableBalance(Object amount) {
    return '$amount доступен';
  }

  @override
  String get assetNotFound => 'Актив не найден.';

  @override
  String get assetPosition => 'Позиция';

  @override
  String get assetValue => 'Ценить';

  @override
  String get assetBalance => 'Баланс';

  @override
  String get assetReturn24h => '24-часовой возврат';

  @override
  String get assetInfo => 'Информация';

  @override
  String get assetName => 'Имя';

  @override
  String get assetSymbol => 'Символ';

  @override
  String get assetMint => 'Мятный';

  @override
  String get assetWebsite => 'Веб-сайт';

  @override
  String get assetPrice => 'Цена';

  @override
  String get assetMarketCap => 'Рыночная капитализация';

  @override
  String get assetFdv => 'FDV';

  @override
  String get assetTotalSupply => 'Общий объем поставок';

  @override
  String get assetCirculatingSupply => 'Оборотное предложение';

  @override
  String get assetHolders => 'Держатели';

  @override
  String get assetCreated => 'Созданный';

  @override
  String get assetPerformance24h => '24-часовая производительность';

  @override
  String get assetVolume => 'Объем';

  @override
  String get assetTraders => 'Трейдеры';

  @override
  String get assetSafety => 'Безопасность';

  @override
  String get assetTop10Holders => 'Топ-10 обладателей';

  @override
  String get assetMarketStatsUnavailable =>
      'Некоторая рыночная статистика сейчас недоступна.';

  @override
  String get assetActivity => 'Активность';

  @override
  String get assetNoActivity => 'Пока нет активности.';

  @override
  String get assetActivityLoadFailed => 'Не удалось загрузить активность.';

  @override
  String assetLoadDetailsFailed(Object error) {
    return 'Не удалось загрузить сведения об объекте: $error.';
  }

  @override
  String get assetMintCopied => 'Mint скопирован (очистится через 60 секунд)';

  @override
  String get assetCouldNotOpenWebsite => 'Не удалось открыть сайт.';

  @override
  String get assetSwapOut => 'Обмен';

  @override
  String get assetSwapIn => 'Обмен в';

  @override
  String assetToSymbol(Object symbol) {
    return 'В $symbol';
  }

  @override
  String assetFromSymbol(Object symbol) {
    return 'Из $symbol';
  }

  @override
  String get assetSent => 'Отправил';

  @override
  String get assetReceived => 'Полученный';

  @override
  String get assetTransfer => 'Передача';

  @override
  String assetSwapWithTime(Object time) {
    return 'Обмен • $time';
  }

  @override
  String assetCounterpartyWithTime(Object address, Object time) {
    return '$address • $time';
  }

  @override
  String get notificationsMarkAllRead => 'Отметить все прочитанными';

  @override
  String get notificationsUnavailableTitle => 'Сообщения недоступны';

  @override
  String get notificationsUnavailableSubtitle =>
      'Невозможно загрузить сообщения прямо сейчас.';

  @override
  String get notificationsEmptyTitle => 'Сообщений пока нет';

  @override
  String get notificationsEmptySubtitle =>
      'Push-сообщения будут появляться здесь после их поступления.';

  @override
  String get notificationDeleted => 'Сообщение удалено';

  @override
  String get receivedHistoryEmpty => 'История получения еще не получена.';

  @override
  String receivedHistoryLoadFailed(Object error) {
    return 'Невозможно загрузить полученную историю: $error.';
  }

  @override
  String get receivedDetailsTitle => 'Полученные данные';

  @override
  String get receivedDetailsMissingId =>
      'Это сообщение не включает полученный идентификатор перевода.';

  @override
  String receivedDetailsLoadFailed(Object error) {
    return 'Невозможно загрузить полученный перевод: $error.';
  }

  @override
  String get receivedFundsTitle => 'Средства полученные';

  @override
  String receivedYouReceived(Object amount) {
    return 'Вы получили $amount';
  }

  @override
  String get receivedFromEmpty => 'От --';

  @override
  String receivedFromAddress(Object address) {
    return 'Из $address';
  }

  @override
  String get receivedRelatedChanges => 'Связанные изменения';

  @override
  String get receivedOnSolana => 'Получено на Solana';

  @override
  String get receivedMarkedFailed =>
      'Событие получения было помечено как неудачное.';

  @override
  String get receivedArrived => 'Средства поступили на этот кошелек.';

  @override
  String get receivedNewFundsArrived =>
      'Новые средства поступили в ваш кошелек.';

  @override
  String get childVerifyPinTitle => 'Проверьте свой PIN';

  @override
  String get childWalletAlreadyAdded => 'Этот детский кошелек уже добавлен.';

  @override
  String childWalletAdded(Object name) {
    return '$name успешно добавлен';
  }

  @override
  String childWalletAddFailed(Object error) {
    return 'Не удалось добавить дочерний кошелек: $error.';
  }

  @override
  String childWalletUpdated(Object name) {
    return '$name успешно обновлен';
  }

  @override
  String childWalletUpdateFailed(Object error) {
    return 'Не удалось обновить дочерний кошелек: $error.';
  }

  @override
  String childWalletDeleteTitle(Object name) {
    return 'Удалить $name?';
  }

  @override
  String get childWalletDeleteMessage =>
      'Эта запись дочернего кошелька будет удалена из родительского контроля.';

  @override
  String childWalletDeleted(Object name) {
    return '$name удален';
  }

  @override
  String childWalletDeleteFailed(Object error) {
    return 'Не удалось удалить дочерний кошелек: $error.';
  }

  @override
  String get childAccountsTitle => 'Дочерние аккаунты';

  @override
  String get childManageUnavailable =>
      'Отключите детский режим, чтобы управлять дочерними учетными записями.';

  @override
  String get childNoAccountsYet => 'Дочерних аккаунтов пока нет';

  @override
  String childAccountCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count детского аккаунта',
      many: '$count детских аккаунтов',
      few: '$count детских аккаунта',
      one: '1 детский аккаунт',
    );
    return '$_temp0';
  }

  @override
  String get childAddAccount => 'Добавить дочернюю учетную запись';

  @override
  String get childEditAccount => 'Изменить детскую учетную запись';

  @override
  String get childName => 'Имя ребенка';

  @override
  String get childNameHint => 'например Алиса';

  @override
  String get childWalletAddress => 'Адрес детского кошелька';

  @override
  String get childScanAgain => 'Сканировать еще раз';

  @override
  String get childScanQrAgain => 'Сканируйте код QR еще раз';

  @override
  String get childEnterName => 'Пожалуйста, введите имя ребенка.';

  @override
  String get childEnterValidWalletAddress =>
      'Пожалуйста, введите действительный адрес кошелька.';

  @override
  String get childWalletTitle => 'Детский кошелек';

  @override
  String get childWalletNotFound => 'Детский кошелек не найден';

  @override
  String get childAddressCopied => 'Адрес скопирован в буфер обмена';

  @override
  String get childTotalBalance => 'Общий баланс';

  @override
  String get childSendToChildWallet => 'Отправить на детский кошелек';

  @override
  String get childNoAssets => 'Нет активов';

  @override
  String get childAssets => 'Ресурсы';

  @override
  String childWalletLoadFailed(Object error) {
    return 'Ошибка загрузки дочернего кошелька: $error.';
  }

  @override
  String get feedbackHeading => 'Расскажите нам, что пошло не так';

  @override
  String get feedbackSubtitle =>
      'Отправьте свой вопрос или проблему непосредственно в службу поддержки Benny Wallet.';

  @override
  String get feedbackEmailOptional => 'Электронная почта (необязательно)';

  @override
  String get feedbackMessage => 'Сообщение';

  @override
  String get feedbackMessageHint =>
      'Опишите проблему, с которой вы столкнулись.';

  @override
  String get feedbackSending => 'Отправка...';

  @override
  String get feedbackMessageRequiredTitle => 'Требуется сообщение';

  @override
  String get feedbackMessageRequiredMessage =>
      'Введите свой отзыв перед отправкой.';

  @override
  String get feedbackMessageTooLongTitle => 'Сообщение слишком длинное';

  @override
  String get feedbackMessageTooLongMessage =>
      'Держите свой отзыв в пределах 2000 символов.';

  @override
  String get feedbackInvalidEmailTitle => 'Неверный адрес электронной почты';

  @override
  String get feedbackInvalidEmailMessage =>
      'Введите действительный адрес электронной почты или оставьте его пустым.';

  @override
  String get feedbackSent => 'Ваше сообщение отправлено.';

  @override
  String get feedbackSendFailedTitle => 'Отправить не удалось';

  @override
  String get feedbackSendFailedFallback =>
      'Невозможно отправить ваше сообщение прямо сейчас. Пожалуйста, повторите попытку в ближайшее время.';

  @override
  String get rentTitle => 'Возврат арендной платы Solana';

  @override
  String get rentDescription =>
      'Закройте пустые счета токенов и верните их арендную плату обратно на свой основной баланс SOL.';

  @override
  String get rentWalletAddress => 'Адрес кошелька';

  @override
  String get rentClosableTokenAccounts => 'Закрываемые токены-аккаунты';

  @override
  String get rentReclaimableRent => 'Возвратная арендная плата';

  @override
  String get rentAccountsToClose => 'Счета, которые нужно закрыть';

  @override
  String rentMoreAccounts(Object count) {
    return 'Будет восстановлено +$count больше аккаунтов.';
  }

  @override
  String get rentReclaiming => 'Восстановление...';

  @override
  String get rentNothingToReclaim => 'Нечего восстанавливать';

  @override
  String get rentReclaimAll => 'Вернуть всю арендную плату';

  @override
  String get rentReclaimingRent => 'Возврат арендной платы...';

  @override
  String get rentSubmittingTransactions =>
      'Отправка транзакций по закрытию счета сейчас.';

  @override
  String get rentUnlockRequiredTitle => 'Требуется разблокировка';

  @override
  String get rentUnlockRequiredMessage =>
      'Разблокируйте кошелек еще раз, прежде чем возвращать арендную плату.';

  @override
  String get rentReclaimFailedTitle => 'Восстановить не удалось';

  @override
  String get rentWalletRequiredTitle => 'Требуется кошелек';

  @override
  String get rentConnectSeekerVaultAgain =>
      'Подключите Seeker Vault еще раз, прежде чем вернуть арендную плату.';

  @override
  String get rentConnectSeedVaultAgain =>
      'Подключите Seed Vault еще раз, прежде чем вернуть арендную плату.';

  @override
  String rentSubmittedTransactions(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Отправлено $count транзакции возврата',
      many: 'Отправлено $count транзакций возврата',
      few: 'Отправлено $count транзакции возврата',
      one: 'Отправлена 1 транзакция возврата',
    );
    return '$_temp0.';
  }

  @override
  String rentSubmittedTransactionsWithSkipped(num skipped, num submitted) {
    String _temp0 = intl.Intl.pluralLogic(
      submitted,
      locale: localeName,
      other: 'Отправлено $submitted транзакции возврата',
      many: 'Отправлено $submitted транзакций возврата',
      few: 'Отправлено $submitted транзакции возврата',
      one: 'Отправлена 1 транзакция возврата',
    );
    String _temp1 = intl.Intl.pluralLogic(
      skipped,
      locale: localeName,
      other: 'пропущено $skipped аккаунта',
      many: 'пропущено $skipped аккаунтов',
      few: 'пропущено $skipped аккаунта',
      one: 'пропущен 1 аккаунт',
    );
    return '$_temp0; $_temp1.';
  }

  @override
  String get rentUnableScan =>
      'Сейчас невозможно сканировать учетные записи с токенами, подлежащими возврату.';

  @override
  String rentMintAddress(Object address) {
    return 'Мятный $address';
  }

  @override
  String get airdropTitle => 'BYC раздача по воздуху';

  @override
  String get airdropUnavailableTitle => 'Раздача BYC временно недоступна';

  @override
  String get airdropUnlockBeforeJoin =>
      'Разблокируйте свой кошелек, прежде чем присоединиться к раздаче BYC.';

  @override
  String get airdropJoinDialogTitle => 'Присоединяетесь к раздаче BYC?';

  @override
  String airdropJoinDialogMessage(Object address) {
    return 'Мы будем использовать ваш текущий адрес кошелька Benny:\n\n$address\n\nЭтот адрес будет отправлен на серверную часть Benny для регистрации вашего профиля раздачи.';
  }

  @override
  String get airdropJoin => 'Присоединиться';

  @override
  String get airdropJoinedSnack =>
      'Вы в игре. Ваш профиль вознаграждения BYC готов.';

  @override
  String get airdropJoinBeforeCheckIn =>
      'Присоединяйтесь к раздаче BYC перед регистрацией.';

  @override
  String get airdropUnlockBeforeCheckIn =>
      'Разблокируйте кошелек перед регистрацией.';

  @override
  String get airdropJoined => 'Присоединился';

  @override
  String get airdropNotJoined => 'Не присоединился';

  @override
  String get airdropBycPoints => 'BYC баллов';

  @override
  String get airdropStreak => 'Полоса';

  @override
  String airdropDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дня',
      many: '$count дней',
      few: '$count дня',
      one: '1 день',
    );
    return '$_temp0';
  }

  @override
  String get airdropWalletUnavailable => 'Кошелек недоступен';

  @override
  String get airdropJoinCardTitle => 'Присоединяйтесь к раздаче';

  @override
  String get airdropJoinCardSubtitle =>
      'Подтвердите свой активный кошелек Benny и создайте свой профиль вознаграждения BYC.';

  @override
  String get airdropJoining => 'Присоединяюсь...';

  @override
  String get airdropJoinWithThisWallet =>
      'Присоединяйтесь с помощью этого кошелька';

  @override
  String get airdropCheckInNow => 'Зарегистрируйтесь сейчас';

  @override
  String get airdropCheckedInToday => 'Зарегистрировался сегодня';

  @override
  String airdropNextReward(Object points) {
    return 'Следующая награда: +$points BYC.';
  }

  @override
  String get airdropComeBackTomorrow =>
      'Возвращайтесь завтра, чтобы получить больше BYC.';

  @override
  String get airdropCheckingIn => 'Проверка...';

  @override
  String airdropLastClaimed(Object date) {
    return 'Последний заявленный $date';
  }

  @override
  String get airdropRewardRules => 'Правила вознаграждения';

  @override
  String get airdropFirstCheckIn => 'Первая регистрация';

  @override
  String get airdropNextDayReward => 'Награда на следующий день';

  @override
  String airdropEveryDayStreak(Object days) {
    return 'Каждая полоса за $days-день';
  }

  @override
  String get airdropUnableOpenPumpFun =>
      'Невозможно открыть Pump.fun прямо сейчас.';

  @override
  String get airdropView => 'Вид';

  @override
  String get airdropPointsBalanceUpdated => 'Ваш баланс баллов Benny обновлен.';

  @override
  String get airdropFirstCheckInUnlocked => 'Первая регистрация разблокирована';

  @override
  String get airdropStreakBonusLanded => 'Получен бонус за серию';

  @override
  String get airdropAlreadyClaimedToday => 'Уже заявлено сегодня';

  @override
  String get airdropRewardClaimed => 'Награда получена';

  @override
  String get defiTypeDeposit => 'депозит';

  @override
  String get defiTypeBorrow => 'занимать';

  @override
  String get defiTypeStaking => 'ставка';

  @override
  String get defiTypeLiquidity => 'ликвидность';

  @override
  String get defiTypeYield => 'урожай';

  @override
  String get defiTypePerps => 'преступники';

  @override
  String get defiTypeRewards => 'награды';

  @override
  String get defiTypePosition => 'позиция';

  @override
  String get settingsSeekerWallet => 'Seeker Wallet';

  @override
  String get updateDefaultTitle => 'Доступно обновление';

  @override
  String get updateDefaultMessage =>
      'Доступна более новая версия Benny Wallet.';

  @override
  String get updateFailedTitle => 'Обновление не выполнено';

  @override
  String get updateUnableToOpen =>
      'Сейчас невозможно открыть ссылку на обновление Benny Wallet.';

  @override
  String get routerFeatureUnavailableTitle => 'Функция недоступна';

  @override
  String get routerFeatureUnavailableMessage =>
      'Эта функция недоступна в данной сборке.';

  @override
  String get routerMessageUnavailableTitle => 'Сообщение недоступно';

  @override
  String get routerMessageUnavailableMessage =>
      'Сначала откройте полученное сообщение из списка сообщений.';

  @override
  String get routerSendDetailsUnavailableTitle => 'Детали отправки недоступны';

  @override
  String get routerSendDetailsUnavailableMessage =>
      'Сначала откройте транзакцию из истории отправки.';

  @override
  String get routerInvalidChildWalletId =>
      'Неверный идентификатор детского кошелька.';

  @override
  String routerRouteNotFound(String uri) {
    return 'Маршрут не найден: $uri';
  }
}
