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
  String get settingsFullFeaturesUnlocked => 'Все функции разблокированы';

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
  String receivedYouReceivedInWallet(String amount, String wallet) {
    return 'Вы получили $amount на $wallet';
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

  @override
  String get walletsTitle => 'Кошельки';

  @override
  String get walletsSubtitle =>
      'Переключение, добавление, переименование и удаление';

  @override
  String get walletSwitcherTitle => 'Ваши кошельки';

  @override
  String walletSwitcherCount(int count, int max) {
    return '$count из $max';
  }

  @override
  String get walletAddWallet => 'Добавить кошелёк';

  @override
  String walletAddLimitReached(int max) {
    return 'Можно добавить не более $max кошельков.';
  }

  @override
  String get walletManage => 'Управление';

  @override
  String get walletAddSheetTitle => 'Добавить кошелёк';

  @override
  String get walletAddSheetSubtitle =>
      'У каждого кошелька своя фраза восстановления и аккаунт. Один PIN открывает их все.';

  @override
  String get walletAddCreate => 'Создать новый кошелёк';

  @override
  String get walletAddCreateSubtitle =>
      'Сгенерировать новую фразу восстановления';

  @override
  String get walletAddImport => 'Импортировать фразу';

  @override
  String get walletAddImportSubtitle => 'Другая фраза или другой аккаунт';

  @override
  String get walletAddSeedVault => 'Подключить Seed Vault';

  @override
  String get walletAddSeedVaultSubtitle => 'Аккаунт из вашего Seeker';

  @override
  String get walletNameTitle => 'Назовите кошелёк';

  @override
  String get walletNameSubtitle =>
      'Хранится только на этом устройстве. Можно изменить в любой момент.';

  @override
  String get walletNameLabel => 'Название кошелька';

  @override
  String get walletNameEmpty => 'Введите название';

  @override
  String walletAdded(String name) {
    return '$name добавлен';
  }

  @override
  String walletSwitched(String name) {
    return 'Переключено на $name';
  }

  @override
  String get walletDuplicateTitle => 'Уже добавлен';

  @override
  String get walletDuplicateMessage =>
      'Эта фраза и аккаунт уже добавлены. Каждую пару «фраза + аккаунт» можно добавить только один раз.';

  @override
  String get walletAlreadyAddedBadge => 'Добавлен';

  @override
  String get walletRename => 'Переименовать';

  @override
  String get walletRenameTitle => 'Переименовать кошелёк';

  @override
  String get walletRemove => 'Удалить';

  @override
  String walletRemoveTitle(String name) {
    return 'Удалить $name?';
  }

  @override
  String get walletRemoveMessage =>
      'Кошелёк будет удалён с устройства. Сначала сохраните фразу восстановления — без неё средства не вернуть.';

  @override
  String get walletRemoveExternalMessage =>
      'Кошелёк будет отключён от Benny. Ключи останутся в Seed Vault.';

  @override
  String walletRemoved(String name) {
    return '$name удалён';
  }

  @override
  String get walletActiveBadge => 'Активный';

  @override
  String get walletTypePhrase => 'Фраза восстановления';

  @override
  String get walletTypeSeedVault => 'Seed Vault';

  @override
  String get swapWalletChanged =>
      'Активный кошелёк изменился. Вернитесь и получите новую котировку.';

  @override
  String seedVaultPickNamedSeed(String seed, String wallet) {
    return 'Далее выберите сид «$seed». В нём находится $wallet.';
  }

  @override
  String seedVaultPickUnknownSeed(String wallet) {
    return 'Выберите сид, в котором находится $wallet. Если ошибётесь, мы сообщим, и этот сид пропадёт из списка.';
  }

  @override
  String seedVaultWrongSeedNamed(String seed) {
    return 'В сиде «$seed» нет этого кошелька.';
  }

  @override
  String get seedVaultReauthorizeTitle => 'Повторная авторизация Seed Vault';

  @override
  String get childAddFromMyWallets => 'Или выберите свой кошелёк';

  @override
  String get walletAddChildModeSetPin =>
      'Для этого кошелька не сохранён PIN детского режима. Задайте его на следующем шаге — он нужен, чтобы выключить детский режим.';

  @override
  String get settingsChildModeAppPinTitle =>
      'Введите PIN приложения, чтобы выключить детский режим';

  @override
  String get walletAddChildModeTitle => 'Это кошелёк в детском режиме';

  @override
  String get walletAddChildModeMessage =>
      'После импорта приложение перейдёт в детский режим: переключение кошельков будет скрыто, добавлять кошельки и переводить на другие свои кошельки будет нельзя. Импортировать?';

  @override
  String get walletAddChildModeConfirm => 'Согласиться и импортировать';

  @override
  String get walletTypeStandard => 'Обычный';

  @override
  String get sendToMyWallet => 'На мой кошелёк';

  @override
  String get walletChildModeLocked =>
      'Отключите детский режим, чтобы менять или добавлять кошельки.';

  @override
  String get walletPinToContinue => 'Введите PIN, чтобы продолжить';

  @override
  String get walletActionFailed => 'Что-то пошло не так. Попробуйте ещё раз.';

  @override
  String get settingsChangePin => 'Сменить PIN';

  @override
  String get settingsChangePinSubtitle => 'Один PIN для всех кошельков';

  @override
  String get changePinCurrent => 'Введите текущий PIN';

  @override
  String get changePinNew => 'Введите новый PIN';

  @override
  String get changePinConfirm => 'Подтвердите новый PIN';

  @override
  String get changePinSuccess => 'PIN изменён';

  @override
  String get changePinSameAsOld => 'Выберите другой PIN';

  @override
  String get unlockSetPinTitle => 'Задайте PIN Benny';

  @override
  String get unlockSetPinSubtitle =>
      'Теперь один PIN защищает все кошельки на устройстве.';

  @override
  String get pinUnlocksAllWallets => 'Этот PIN открывает все ваши кошельки.';

  @override
  String settingsLogOutAllWallets(int count) {
    return 'С устройства будут удалены все кошельки ($count). Сначала сохраните все фразы восстановления.';
  }

  @override
  String importAccountLabel(int number) {
    return 'Аккаунт $number';
  }

  @override
  String importAccountAltLabel(int number) {
    return 'Аккаунт $number · другой путь';
  }

  @override
  String get importLegacyLabel => 'Устаревший путь';

  @override
  String get travelGuardTitle => 'Защита в поездке';

  @override
  String get travelGuardOffSubtitle =>
      'Особый PIN, открывающий только один кошелёк';

  @override
  String get travelGuardOnSubtitle =>
      'Включено: особый PIN открывает один кошелёк';

  @override
  String get travelGuardInfoTitle => 'Что такое защита в поездке?';

  @override
  String get travelGuardInfoBody =>
      'На случай, если вас заставляют открыть кошелёк.\n\nЗадайте особый PIN и выберите один кошелёк (держите в нём немного средств). При разблокировке особым PIN откроется только он: остальные кошельки, их балансы и сообщения скрыты везде, включая списки кошельков и отправку, и эта настройка тоже скрыта.\n\nПока защита включена, биометрия отключена и не может быть включена.\n\nЗаблокируйте приложение и войдите обычным PIN, чтобы снова видеть все кошельки.';

  @override
  String get travelGuardChooseWallet => 'Выберите кошелёк для особого PIN';

  @override
  String get travelGuardNewPin => 'Задайте особый PIN';

  @override
  String get travelGuardConfirmPin => 'Повторите особый PIN';

  @override
  String get travelGuardPinHint => 'Он должен отличаться от обычного PIN.';

  @override
  String get travelGuardPinSameAsApp => 'Это ваш обычный PIN. Выберите другой.';

  @override
  String get travelGuardEnabled => 'Защита в поездке включена';

  @override
  String get travelGuardDisabled => 'Защита в поездке выключена';

  @override
  String get travelGuardActiveBadge => 'Защита в поездке включена';

  @override
  String get travelGuardBiometricsOff =>
      'Недоступно, пока включена защита в поездке';

  @override
  String get welcomeUseAsSigner => 'Использовать телефон как офлайн-подписант';

  @override
  String get walletAddAirGap => 'Подключить офлайн-подписант';

  @override
  String get walletAddAirGapSubtitle =>
      'Ключи хранятся на другом телефоне, который никогда не выходит в сеть';

  @override
  String createWalletWordCount(int count) {
    return 'Слов: $count';
  }

  @override
  String get signerAppTitle => 'Benny Signer';

  @override
  String get signerNeedsNoWalletsTitle => 'Сначала удалите все кошельки';

  @override
  String get signerNeedsNoWalletsBody =>
      'Телефон-подписант хранит только собственную офлайн-фразу восстановления. Сделайте резервную копию и удалите все кошельки на этом телефоне в разделе «Настройки > Кошельки», затем повторите попытку.';

  @override
  String get signerEnterTitle => 'Сделать этот телефон подписантом?';

  @override
  String get signerEnterBody =>
      'Телефон будет постоянно офлайн и будет только подписывать. Экранов кошелька на нём не будет. Чтобы снова использовать его как кошелёк, подписант придётся стереть.';

  @override
  String get signerIntroTitle => 'Офлайн-подписант';

  @override
  String get signerIntroPoint1 =>
      'Этот телефон хранит вашу фразу восстановления и больше никогда не выходит в сеть.';

  @override
  String get signerIntroPoint2 =>
      'Benny Wallet на другом телефоне создаёт транзакции. Вы подписываете их здесь, сканируя QR-коды.';

  @override
  String get signerIntroPoint3 =>
      'Перед созданием фразы восстановления мы поможем отключить все сети.';

  @override
  String get signerIntroPoint4 =>
      'Запишите фразу восстановления на бумаге. Это единственная резервная копия.';

  @override
  String get signerIntroStart => 'Начать';

  @override
  String get signerIntroCancel => 'Не сейчас, использовать как кошелёк';

  @override
  String get signerOfflineTitle => 'Отключите телефон от сети';

  @override
  String get signerOfflineBody =>
      'Включите режим полёта и отключите Wi-Fi, Bluetooth и NFC. Продолжить можно, когда все обязательные пункты станут зелёными.';

  @override
  String get signerCheckAirplane => 'Режим полёта включён';

  @override
  String get signerCheckWifi => 'Wi-Fi выключен';

  @override
  String get signerCheckBluetooth => 'Bluetooth выключен';

  @override
  String get signerCheckNfc => 'NFC выключен';

  @override
  String get signerCheckNoNetwork => 'Нет подключения к сети';

  @override
  String get signerCheckUsbDebugging => 'Отладка по USB выключена';

  @override
  String get signerCheckSim => 'SIM-карта извлечена (рекомендуется)';

  @override
  String get signerCheckManualHint =>
      'Телефон не может проверить это. Подтвердите сами.';

  @override
  String get signerOpenSettings => 'Открыть настройки';

  @override
  String get signerNetworkDetected =>
      'Обнаружено подключение к сети. Отключите его, чтобы продолжить.';

  @override
  String get signerPinTitle => 'Задайте PIN подписанта';

  @override
  String get signerPinBody => 'Придумайте 6-значный PIN для этого подписанта.';

  @override
  String get signerPinConfirmTitle => 'Подтвердите PIN';

  @override
  String get signerPinConfirmBody => 'Введите PIN ещё раз.';

  @override
  String get signerPinMismatch => 'PIN-коды не совпадают. Повторите попытку.';

  @override
  String get signerSourceTitle => 'Фраза восстановления';

  @override
  String get signerSourceBody =>
      'Создайте новую фразу восстановления на этом офлайн-телефоне или введите уже имеющуюся.';

  @override
  String get signerSourceCreate24 => 'Создать 24 слова';

  @override
  String get signerSourceCreate24Subtitle => 'Рекомендуется для подписанта';

  @override
  String get signerSourceCreate12 => 'Создать 12 слов';

  @override
  String get signerSourceCreate12Subtitle => 'Проще записать';

  @override
  String get signerSourceImport => 'Импортировать фразу';

  @override
  String get signerSourceImportSubtitle => '12 или 24 слова';

  @override
  String get signerWordsTitle => 'Запишите эти слова';

  @override
  String get signerWordsWarning =>
      'Запишите слова на бумаге по порядку. Никогда не фотографируйте, не делайте скриншот и нигде их не вводите. Любой, у кого есть эти слова, может забрать ваши средства.';

  @override
  String get signerWordsDone => 'Я записал(а) слова';

  @override
  String get signerVerifyTitle => 'Проверьте резервную копию';

  @override
  String get signerImportTitle => 'Импорт фразы восстановления';

  @override
  String get signerImportBody => 'Введите 12 или 24 слова через пробел.';

  @override
  String get signerImportInvalid =>
      'Это недействительная фраза восстановления из 12 или 24 слов.';

  @override
  String get signerFinishTitle => 'Завершение настройки';

  @override
  String get signerDeviceNameLabel => 'Имя подписанта';

  @override
  String get signerDeviceNameHelper =>
      'Отображается в кошельке после подключения.';

  @override
  String get signerBiometricToggle => 'Разблокировка по биометрии';

  @override
  String get signerFinishButton => 'Готово';

  @override
  String get signerSetupFailed =>
      'Не удалось сохранить настройки. Повторите попытку.';

  @override
  String get signerUnlockSubtitle => 'Введите PIN подписанта';

  @override
  String get signerUnlockNetworkBlocked =>
      'Подключение к сети активно. Включите режим полёта, чтобы разблокировать.';

  @override
  String signerWrongPin(int count) {
    return 'Неверный PIN. Осталось попыток до стирания подписанта: $count.';
  }

  @override
  String get signerUnlockFailed =>
      'Не удалось разблокировать. Повторите попытку.';

  @override
  String get signerUseBiometric => 'Использовать биометрию';

  @override
  String get signerBiometricReason => 'Разблокируйте Benny Signer';

  @override
  String get signerBiometricFailed =>
      'Не удалось изменить настройки биометрии.';

  @override
  String get signerRecheckTitle => 'Проверка офлайн-режима';

  @override
  String get signerRecheckBody =>
      'Приложение обновлено. Перед разблокировкой убедитесь, что телефон снова полностью офлайн.';

  @override
  String get signerLockNow => 'Заблокировать';

  @override
  String get signerOfflineChip => 'Офлайн-подписант';

  @override
  String get signerScanToSign => 'Сканировать и подписать';

  @override
  String get signerPairWallet => 'Подключить кошелёк';

  @override
  String get signerAccountsTitle => 'Счета';

  @override
  String signerAccountName(int number) {
    return 'Счёт $number';
  }

  @override
  String get signerPairBody =>
      'В Benny Wallet на другом телефоне выберите «Подключить офлайн-подписант» и отсканируйте этот код.';

  @override
  String get signerPairPublicOnly =>
      'Этот код содержит только публичные адреса и никогда — фразу восстановления.';

  @override
  String get signerScanBody =>
      'Отсканируйте QR-код, показанный в Benny Wallet на другом телефоне.';

  @override
  String get signerScanWrongCode => 'Это не запрос на подпись от Benny Wallet.';

  @override
  String get signerScanAgain => 'Сканировать снова';

  @override
  String get signerRejectUnknownAccount =>
      'Запрос относится к счёту, которого нет на этом подписанте.';

  @override
  String get signerRejectNotASigner =>
      'Этому счёту не нужно подписывать эту транзакцию.';

  @override
  String get signerRejectUnreadable =>
      'Не удалось прочитать транзакцию, поэтому она не будет подписана.';

  @override
  String get signerRejectMessageIsTransaction =>
      'Это сообщение на самом деле является транзакцией, поэтому оно не будет подписано.';

  @override
  String get signerRejectInvalidCode =>
      'Этот QR-код не является действительным запросом на подпись.';

  @override
  String get signerReviewTitle => 'Проверка и подпись';

  @override
  String get signerReviewAccount => 'Подписывающий счёт';

  @override
  String get signerReviewFee => 'Комиссия сети';

  @override
  String get signerReviewMessage => 'Сообщение';

  @override
  String signerBinaryMessage(int count) {
    return 'Двоичные данные (байт: $count)';
  }

  @override
  String get signerThisAccount => 'этот счёт';

  @override
  String signerActionSendSol(String amount) {
    return 'Отправить $amount SOL';
  }

  @override
  String signerActionSendToken(String amount, String symbol) {
    return 'Отправить $amount $symbol';
  }

  @override
  String signerActionSendUnverified(String amount) {
    return 'Отправить $amount непроверенного токена';
  }

  @override
  String signerActionTo(String address) {
    return 'Кому: $address';
  }

  @override
  String signerActionToTokenAccount(String address) {
    return 'На токен-счёт $address';
  }

  @override
  String signerActionMint(String mint) {
    return 'Адрес токена $mint';
  }

  @override
  String signerActionOwner(String address) {
    return 'Владелец $address';
  }

  @override
  String signerActionRentTo(String address) {
    return 'Рента возвращается на $address';
  }

  @override
  String get signerActionCreateTokenAccount => 'Создать токен-счёт';

  @override
  String get signerActionCloseTokenAccount => 'Закрыть токен-счёт';

  @override
  String get signerActionMemo => 'Примечание';

  @override
  String get signerActionApprove =>
      'Разрешить другому счёту тратить ваши токены';

  @override
  String get signerActionSetAuthority => 'Изменить полномочия счёта';

  @override
  String get signerActionAssign => 'Изменить владельца счёта';

  @override
  String get signerActionCreateAccount => 'Создать счёт';

  @override
  String signerActionProgram(String program) {
    return 'Программа $program';
  }

  @override
  String get signerHoldToSign => 'Удерживайте для подписи';

  @override
  String get signerReject => 'Отклонить';

  @override
  String get signerSignFailed => 'Не удалось подписать. Повторите попытку.';

  @override
  String get signerSignatureTitle => 'Подпись';

  @override
  String get signerSignatureBody =>
      'Отсканируйте этот код в Benny Wallet на другом телефоне, чтобы завершить.';

  @override
  String get signerSettingsTitle => 'Настройки подписанта';

  @override
  String get signerAccountCount => 'Показываемые счета';

  @override
  String get signerAccountCountHint =>
      'До 5 счетов из этой фразы восстановления';

  @override
  String get signerUpgradeTitle => 'Обновление подписанта';

  @override
  String get signerUpgradeIntro =>
      'Для обновления приложения нужна сеть, поэтому подготовьтесь заранее. Пока телефон онлайн, фраза восстановления остаётся зашифрованной, и подписант не откроет её, пока телефон снова не будет офлайн.';

  @override
  String get signerUpgradeStep0 => '1. Проверьте бумажную копию';

  @override
  String get signerUpgradeVerifyBackup => 'Проверить копию';

  @override
  String get signerUpgradeBackupOk => 'Копия проверена';

  @override
  String get signerUpgradeOnlineTitle => '2a. Обычное обновление';

  @override
  String get signerUpgradeOnlineBody =>
      'Заблокируйте подписант. Включите сеть и обновите Benny Wallet из того же магазина, откуда устанавливали. Снова включите режим полёта. Перед разблокировкой подписант повторно проверит офлайн-режим.';

  @override
  String get signerUpgradeSecureTitle => '2b. Самое безопасное обновление';

  @override
  String get signerUpgradeSecureBody =>
      'Сотрите подписант в настройках, затем обновите приложение онлайн. Снова перейдите в офлайн, настройте подписант и импортируйте фразу восстановления. Счета и адреса останутся прежними.';

  @override
  String get signerUpgradeOfflineApkTitle =>
      'Android: обновление без выхода в сеть';

  @override
  String get signerUpgradeOfflineApkBody =>
      'Также можно скопировать новый APK с benny-wallet.com на этот телефон через USB-кабель или SD-карту и установить его, оставаясь офлайн. Устанавливайте только поверх версии из того же источника.';

  @override
  String get signerUpgradeCompatTitle =>
      'Старые подписанты продолжают работать';

  @override
  String get signerUpgradeCompatBody =>
      'Новое приложение-кошелёк работает и со старым подписантом. Кошелёк запрашивает только то, что поддерживает подписант, поэтому обновляйтесь, когда удобно.';

  @override
  String get signerVersionTitle => 'Версия';

  @override
  String signerVersionDetail(String app, int protocol, int tokens) {
    return 'Приложение $app · протокол $protocol · список токенов $tokens';
  }

  @override
  String get signerEraseTitle => 'Стереть подписант';

  @override
  String get signerEraseSubtitle =>
      'Удаляет фразу восстановления с этого телефона';

  @override
  String get signerEraseBody =>
      'Фраза восстановления будет удалена с этого телефона. Без бумажной копии средства восстановить не получится.';

  @override
  String get signerEraseConfirm => 'Стереть';

  @override
  String get signerEraseWrongPin => 'Неверный PIN. Ничего не стёрто.';

  @override
  String get airGapConnectTitle => 'Подключение офлайн-подписанта';

  @override
  String get airGapConnectBody =>
      'На телефоне-подписанте нажмите «Подключить кошелёк», затем отсканируйте показанный код.';

  @override
  String get airGapConnectInvalid => 'Это не код сопряжения подписанта.';

  @override
  String airGapConnectChoose(String device) {
    return 'Выберите счёт на $device';
  }

  @override
  String airGapConnectAccount(int number) {
    return 'Счёт $number';
  }

  @override
  String airGapConnectAccountAdded(int number) {
    return 'Счёт $number (уже добавлен)';
  }

  @override
  String get airGapConnectCompare =>
      'Убедитесь, что адрес совпадает с показанным на подписанте.';

  @override
  String get airGapConnectScanAgain => 'Сканировать снова';

  @override
  String get airGapSignTitle => 'Подпись через подписант';

  @override
  String get airGapSignShowRequestAgain => 'Показать запрос снова';

  @override
  String get airGapSignMayHaveExpired =>
      'Срок транзакции мог истечь. Если отправка не удастся, начните заново.';

  @override
  String get airGapSignWrongRequest =>
      'Эта подпись относится к другому запросу.';

  @override
  String get airGapSignInvalidCode => 'Это не подпись от вашего подписанта.';

  @override
  String get airGapSignerOutdated =>
      'На подписанте установлена старая версия. Она работает, но обновите её, когда будет удобно.';

  @override
  String get signerIntroSubtitle =>
      'Храните ключи на телефоне, который больше никогда не выходит в сеть.';

  @override
  String get signerFinishSubtitle => 'Дайте подписанту имя и задайте PIN-код.';

  @override
  String signerQuizBody(int count) {
    return 'Выберите правильное слово для $count позиций, сверяясь с бумажной копией.';
  }

  @override
  String signerQuizProgress(int current, int total) {
    return 'Вопрос $current из $total';
  }

  @override
  String signerQuizQuestion(int position) {
    return 'Какое слово стоит под номером $position?';
  }

  @override
  String get signerQuizCorrect => 'Верно!';

  @override
  String get signerQuizWrong =>
      'Неверно. Сверьтесь с бумагой; мы выбрали новые слова для новой попытки.';

  @override
  String get signerQuizShowWords => 'Показать слова снова';

  @override
  String get signerScanToSignSubtitle =>
      'Отсканируйте запрос, показанный кошельком';

  @override
  String get signerPairWalletSubtitle =>
      'Покажите код для сканирования в Benny Wallet';

  @override
  String get signerWalletPhoneLabel => 'Benny Wallet';

  @override
  String get signerScanRefusedTitle => 'Невозможно подписать';

  @override
  String get airGapSignerLabel => 'Подписант';

  @override
  String get airGapThisPhone => 'Этот телефон';

  @override
  String get airGapConnectFound => 'Подписант распознан';

  @override
  String get airGapSignNeedsSigner =>
      'Нужно проверить и подписать на вашем подписанте';

  @override
  String get airGapSignStepShort1 => 'Сканирует подписант';

  @override
  String get airGapSignStepShort2 => 'Скан подписи';

  @override
  String airGapSignStep1Named(String device) {
    return 'Шаг 1: отсканируйте этот код на «$device»';
  }

  @override
  String airGapSignStep1BodyNamed(String device) {
    return 'На «$device» нажмите «Сканировать и подписать», проверьте данные и подтвердите.';
  }

  @override
  String airGapSignStep2Named(String device) {
    return 'Шаг 2: отсканируйте подпись с «$device»';
  }

  @override
  String airGapSignStep2BodyNamed(String device) {
    return 'После подтверждения «$device» покажет код подписи. Отсканируйте его этим телефоном.';
  }

  @override
  String airGapSignScanSignatureNamed(String device) {
    return 'Далее: скан подписи с $device';
  }

  @override
  String signerActionSwapPair(String from, String to) {
    return 'Обмен $from → $to';
  }

  @override
  String signerSwapPay(String amount) {
    return 'Отдаёте $amount';
  }

  @override
  String signerSwapPayAtMost(String amount) {
    return 'Отдаёте не более $amount';
  }

  @override
  String signerSwapReceive(String amount) {
    return 'Получаете $amount';
  }

  @override
  String signerSwapReceiveAtLeast(String amount) {
    return 'Получаете не менее $amount';
  }

  @override
  String get signerSwapUnverifiedToken => 'Непроверенный токен';

  @override
  String airGapSignTimeLeft(int seconds) {
    return 'Осталось $seconds с. Когда время выйдет, новый код появится автоматически.';
  }

  @override
  String get airGapSignRefreshing =>
      'Время вышло. Получаем новую котировку и код…';

  @override
  String airGapSignRefreshed(String device) {
    return 'Прежний код истёк, вот новый. Отсканируйте его снова на «$device».';
  }

  @override
  String get airGapSignRefreshFailed =>
      'Не удалось получить новый код. Проверьте подключение и повторите.';

  @override
  String get airGapSignOldRequest =>
      'Эта подпись для истёкшего кода. Сначала отсканируйте новый код на подписанте.';

  @override
  String get scanHintRoleShows => 'Показывает код';

  @override
  String get scanHintRoleScans => 'Сканирует';

  @override
  String signerTokenUnchecked(String symbol) {
    return '$symbol (не проверен)';
  }

  @override
  String get signerReviewActions => 'Транзакция';

  @override
  String get signerNewerWalletNotice =>
      'Кошелёк новее подписанта. Обновите подписант, когда будет удобно.';

  @override
  String get signerDangerBanner =>
      'Высокий риск. Не подписывайте, если это начали не вы.';

  @override
  String get signerActionSwap => 'Обмен';

  @override
  String get signerActionSwapDetail => 'Проверьте суммы в кошельке.';

  @override
  String get signerActionDangerDetail =>
      'Опасно. Если не уверены, не подписывайте.';

  @override
  String get signerActionAdvanceNonce => 'Обновить номер транзакции';

  @override
  String get signerActionSyncNative => 'Обновить баланс SOL';

  @override
  String get signerHoldLongHint =>
      'Внимательно проверьте и удерживайте 3 секунды.';

  @override
  String signerTokenVerified(String token) {
    return '$token · Проверено Benny Wallet';
  }

  @override
  String signerTokenWalletProvided(String symbol) {
    return '$symbol · Не проверено Benny Wallet';
  }

  @override
  String signerSwapWalletQuote(String pay, String receive) {
    return 'Примерно: отдаёте $pay, получаете около $receive';
  }

  @override
  String get signerActionUnknown => 'Непонятная операция';

  @override
  String signerActionCreateTokenAccountFor(String symbol) {
    return 'Открыть счёт $symbol';
  }

  @override
  String get signerUnresolvedAccounts =>
      'Подписант видит не всю транзакцию. Подписывайте, только если сами её начали.';

  @override
  String get signerTokenNotVerified => 'Не проверено Benny Wallet';

  @override
  String get signerKindSwap => 'Обмен';

  @override
  String get signerKindSend => 'Отправка';

  @override
  String signerAbout(String amount) {
    return 'Около $amount';
  }

  @override
  String get signerAmountsFromWallet => 'Суммы указаны кошельком';

  @override
  String get signerTrustSafe => 'Все токены проверены Benny Wallet';

  @override
  String get signerTrustCaution =>
      'Один токен не проверен Benny Wallet. Будьте осторожны.';

  @override
  String get signerTrustDangerSwap =>
      'Ни один токен не проверен Benny Wallet. Высокий риск.';

  @override
  String get signerTrustDangerSend =>
      'Этот токен не проверен Benny Wallet. Высокий риск.';

  @override
  String get signerReviewOtherSteps => 'Другие шаги';

  @override
  String get signerPay => 'Вы платите';

  @override
  String get signerPayAtMost => 'Платите не больше';

  @override
  String get signerGet => 'Вы получите';

  @override
  String get signerGetAtLeast => 'Получите не меньше';

  @override
  String get signerGetAbout => 'Получите примерно';

  @override
  String get signerRecipient => 'Получатель';

  @override
  String get signerRecipientTokenAccount => 'Токен-счёт получателя';

  @override
  String get signerUsdFromWallet => 'Суммы в USD — оценка кошелька';

  @override
  String signerActionCreateTokenAccountForRecipient(String symbol) {
    return 'Открыть счёт $symbol получателю';
  }

  @override
  String get signerCreateAccountSkipIfOpen =>
      '(Впервые — около 0,002 SOL; если счёт уже есть, шаг пропускается бесплатно)';

  @override
  String get signerCreateAccountNotOpen => '(Счёта ещё нет; около 0,002 SOL)';

  @override
  String get signerAddressFromWallet =>
      'Этот адрес передал кошелёк. Подписант не может его проверить.';

  @override
  String get signerSwapOutputUnchecked =>
      'Нельзя подтвердить, что полученные токены придут вам.';

  @override
  String get signerExtraOutflow => 'Также отправляет средства на другой адрес.';

  @override
  String signerHighFee(String amount) {
    return 'Очень высокая комиссия сети: $amount SOL';
  }

  @override
  String get signerDurableNonce =>
      'Эта подпись не истекает. Её можно использовать позже.';

  @override
  String get signerSwapFromWallet =>
      'Токен или сумма указаны кошельком и не проверены.';

  @override
  String signerActionCloseTo(String address) {
    return 'Остаток и рента уходят на $address';
  }

  @override
  String signerWalletNote(String name) {
    return 'Заметка кошелька: $name';
  }

  @override
  String get signerReviewFeePayer => 'Комиссию платит';

  @override
  String signerActionOwnerProgram(String program) {
    return 'Под управлением программы $program';
  }

  @override
  String get signerSlippageAll =>
      'Проскальзывание 100% или больше: можно ничего не получить.';

  @override
  String get signerQuizTooManyWrong =>
      'Слишком много ошибок. Введите PIN и попробуйте снова.';

  @override
  String get signerSignInTitle => 'Запрос на вход';

  @override
  String get signerKindSignIn => 'Вход';

  @override
  String get signerSignInBenny => 'Вход в Benny Wallet';

  @override
  String signerSignInOtherSite(String site) {
    return '«$site» просит войти. Подписывайте, только если начали это сами.';
  }

  @override
  String get signerSignInExpired =>
      'Срок запроса истёк. Проверьте время на этом телефоне или начните заново в кошельке.';

  @override
  String get signerSignInOtherAccount =>
      'Это вход для другого аккаунта. Не подписывайте.';

  @override
  String get signerSignInWhat =>
      'Подтверждает, что аккаунт ваш, чтобы Benny показывал баланс, историю и уведомления.';

  @override
  String get signerSignInNoFunds => 'Средства не переводятся, комиссии нет.';

  @override
  String get signerSignInShowText => 'Показать исходный текст';

  @override
  String get airGapSignInTitle => 'Вход через подписант';

  @override
  String get airGapSignInWhy => 'Зачем эта подпись?';

  @override
  String get airGapSignInWhyBody =>
      'Прежде чем загрузить баланс, историю и уведомления, Benny должен убедиться, что аккаунт ваш. Обычно это нужно один раз для каждого кошелька.';

  @override
  String get airGapSignInSafe =>
      'Это только вход. Средства не переводятся, комиссии нет.';

  @override
  String airGapSignInSignerShows(String device) {
    return '«$device» покажет «Вход в Benny Wallet».';
  }

  @override
  String airGapSignInSignerShowsText(String device) {
    return '«$device» покажет английский текст, начинающийся с «Benny Wallet wants you to sign in». Это и есть вход. После обновления подписанта он покажет «Вход в Benny Wallet».';
  }
}
