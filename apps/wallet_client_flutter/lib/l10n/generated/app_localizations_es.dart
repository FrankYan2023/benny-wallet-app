// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Benny Wallet';

  @override
  String get brandShortName => 'Benny';

  @override
  String get commonBack => 'Atrás';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonClose => 'Cerrar';

  @override
  String get commonContinue => 'Continuar';

  @override
  String get commonConfirm => 'Confirmar';

  @override
  String get commonCopied => 'Copiado';

  @override
  String get commonCopy => 'Copiar';

  @override
  String get commonDone => 'Listo';

  @override
  String get commonLater => 'Más tarde';

  @override
  String get commonLoading => 'Cargando...';

  @override
  String get commonMax => 'MÁX';

  @override
  String get commonNext => 'Siguiente';

  @override
  String get commonOk => 'OK';

  @override
  String get commonRetry => 'Reintentar';

  @override
  String get commonSettings => 'Ajustes';

  @override
  String get commonShare => 'Compartir';

  @override
  String get commonUpdate => 'Actualizar';

  @override
  String get languageSystem => 'Sistema';

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
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSubtitle => 'Elige el idioma de la app';

  @override
  String get settingsLanguageSystemDescription => 'Seguir este dispositivo';

  @override
  String get settingsLanguageSheetTitle => 'Idioma';

  @override
  String get settingsLanguageSheetSubtitle => 'Elige el idioma que usa Benny.';

  @override
  String get settingsBiometricUnlock => 'Desbloqueo biométrico';

  @override
  String get settingsUseFingerprint => 'Usar huella';

  @override
  String get settingsUnlockWalletToEnable =>
      'Desbloquea la billetera para activar';

  @override
  String get settingsAutoLock => 'Bloqueo automático';

  @override
  String get settingsAutoLockSheetSubtitle =>
      'Elige cuándo Benny se bloquea de nuevo.';

  @override
  String get settingsNotifications => 'Recibir notificaciones';

  @override
  String get settingsNotificationsSubtitle =>
      'Recibe una alerta cuando lleguen fondos';

  @override
  String get settingsChildMode => 'Modo infantil';

  @override
  String get settingsChildModeActive => 'El modo infantil está activo';

  @override
  String get settingsChildModeActiveDescription =>
      'La billetera permanece en modo solo recibir hasta que se ingrese el PIN infantil de 4 dígitos.';

  @override
  String get settingsChildModeProtected =>
      'Protegido por un PIN infantil de 4 dígitos';

  @override
  String get settingsChildModeRemoveAccounts =>
      'Elimina todas las cuentas infantiles antes de activarlo';

  @override
  String get settingsChildModeSetPin =>
      'Configura un PIN de 4 dígitos separado para el modo infantil';

  @override
  String get settingsChildAccounts => 'Cuentas infantiles';

  @override
  String get settingsRentReclaim => 'Recuperar rent';

  @override
  String get settingsRentReclaimSubtitle =>
      'Cierra cuentas de token vacías y recupera SOL';

  @override
  String get settingsFeedback => 'Comentarios';

  @override
  String get settingsFeedbackSubtitle =>
      'Informa un problema o haz una pregunta';

  @override
  String get settingsLogOut => 'Cerrar sesión';

  @override
  String get settingsLogOutSubtitle => 'Volver a la pantalla inicial';

  @override
  String get settingsIncorrectPin => 'PIN incorrecto';

  @override
  String get settingsPersistentBiometricUnsupported =>
      'Este dispositivo no admite desbloqueo biométrico persistente.';

  @override
  String get settingsBiometricsUnavailable =>
      'La biometría no está disponible en este dispositivo.';

  @override
  String get settingsBiometricEnabled => 'Biometría activada';

  @override
  String get settingsBiometricDisabled => 'Biometría desactivada';

  @override
  String get settingsUnlockBeforeBiometrics =>
      'Desbloquea la billetera antes de activar la biometría.';

  @override
  String get settingsNotificationsSystemDisabled =>
      'Las notificaciones están desactivadas. Actívalas en los ajustes del sistema.';

  @override
  String get settingsNotificationsEnabled =>
      'Notificaciones de recepción activadas';

  @override
  String get settingsNotificationsDisabled =>
      'Notificaciones de recepción desactivadas';

  @override
  String settingsNotificationsUpdateFailed(String error) {
    return 'No se pudieron actualizar las notificaciones: $error';
  }

  @override
  String get settingsRemoveChildAccountsFirst =>
      'Elimina todas las cuentas infantiles antes de activar el modo infantil.';

  @override
  String get settingsChildModeEnabled => 'Modo infantil activado';

  @override
  String get settingsChildModeDisabled => 'Modo infantil desactivado';

  @override
  String settingsChildModeUpdateFailed(String error) {
    return 'No se pudo actualizar el modo infantil: $error';
  }

  @override
  String get settingsCopyRecoveryPhraseFirst =>
      'Copia primero tu frase de recuperación.';

  @override
  String get settingsLogOutWarning =>
      'Cerrar sesión borrará todos los datos locales de la app en este dispositivo.';

  @override
  String get settingsWalletUpToDate => 'Benny Wallet está actualizada.';

  @override
  String get settingsUpdateCheckFailed => 'Error al buscar actualizaciones';

  @override
  String get settingsUnableToCheckUpdates =>
      'No se pueden buscar actualizaciones ahora.';

  @override
  String get settingsSeedPhraseBackup => 'Copia de frase semilla';

  @override
  String get settingsSeedPhraseBackupDescription =>
      'Recomendamos guardar una copia física en un lugar seguro.';

  @override
  String get settingsSecureNow => 'Proteger ahora';

  @override
  String get settingsCheckingUpdates => 'Buscando...';

  @override
  String get settingsFullFeaturesUnlocked =>
      'Funciones completas desbloqueadas';

  @override
  String get settingsCheckForUpdates => 'Buscar actualizaciones';

  @override
  String settingsVersion(String version) {
    return 'Versión $version';
  }

  @override
  String settingsVersionBuild(String version, String buildNumber) {
    return 'Versión $version+$buildNumber';
  }

  @override
  String get autoLockImmediate => 'Inmediatamente';

  @override
  String get autoLockOneMinute => '1 minuto';

  @override
  String get autoLockFiveMinutes => '5 minutos';

  @override
  String get autoLockTenMinutes => '10 minutos';

  @override
  String get autoLockThirtyMinutes => '30 minutos';

  @override
  String get biometricUnlockReason =>
      'Usa biometría para desbloquear tu Benny Wallet.';

  @override
  String get biometricSetupReason =>
      'Verifica con biometría para activar esta función de seguridad.';

  @override
  String get unlockFailedTitle => 'Error al desbloquear';

  @override
  String get unlockIncorrectPin => 'PIN incorrecto.';

  @override
  String get unlockBiometricCancelled => 'Biometría cancelada';

  @override
  String get unlockBiometricFailed =>
      'Falló el desbloqueo biométrico. Inténtalo de nuevo.';

  @override
  String get unlockSessionExpired => 'La sesión expiró, usa el PIN';

  @override
  String get unlockBiometricUnavailable => 'Biometría no disponible';

  @override
  String get unlockUseFingerprint => 'Usar huella';

  @override
  String get unlockEnterPin => 'Ingresa el PIN';

  @override
  String get pinConfirm => 'Confirmar PIN';

  @override
  String get pinSet => 'Configurar PIN de Benny';

  @override
  String get pinMismatch => 'Los PIN no coinciden';

  @override
  String get pinImportFailed => 'Error al importar';

  @override
  String get pinExternalWalletSetupDescription =>
      'Esto protege los ajustes de Benny y las cuentas infantiles. Seeker guarda las claves de firma en Seeker Wallet.';

  @override
  String get childModeConfirmPinTitle => 'Confirmar PIN infantil';

  @override
  String get childModeSetPinTitle => 'Configurar PIN infantil';

  @override
  String get childModeEnterPinTitle => 'Ingresar PIN infantil';

  @override
  String get childModeConfirmPinSubtitle =>
      'Vuelve a ingresar el PIN de 4 dígitos usado solo para el modo infantil.';

  @override
  String get childModeSetPinSubtitle =>
      'Crea un PIN de 4 dígitos usado solo para el modo infantil.';

  @override
  String get childModeEnterPinSubtitle =>
      'Ingresa el PIN de 4 dígitos usado solo para el modo infantil para desactivarlo.';

  @override
  String get childModeOnlyUsed => 'Solo se usa para el modo infantil';

  @override
  String get welcomeReplaceWalletTitle => 'Reemplazar billetera actual';

  @override
  String get welcomeReplaceWalletMessage =>
      'Continuar eliminará la billetera actual.';

  @override
  String get welcomeConfirmAgainTitle => 'Confirma de nuevo';

  @override
  String get welcomeConfirmAgainMessage =>
      'Después de eliminarla podrías perder acceso a la frase. Guárdala primero.';

  @override
  String get welcomeNewWalletSubtitle =>
      'Empieza con una billetera predeterminada nueva';

  @override
  String get welcomeImportWalletSubtitleSeeker => 'Frase o Seeker Vault';

  @override
  String get welcomeImportWalletSubtitlePhrase =>
      'Restaurar desde frase de recuperación';

  @override
  String get welcomeHeroSemantics => 'Benny Wallet';

  @override
  String get welcomeHeroPrelude => 'Una nueva billetera está aquí.';

  @override
  String get welcomeHeroTitle => 'Benny Wallet';

  @override
  String get welcomeHeroSubtitle =>
      'Empieza de cero o restaura tu frase de recuperación.';

  @override
  String get welcomeNewWallet => 'Nueva billetera';

  @override
  String get welcomeImportWallet => 'Importar billetera';

  @override
  String get createWalletTitle => 'Crear billetera';

  @override
  String get createWalletRecoveryTitle => 'Anota tu frase de recuperación.';

  @override
  String get createWalletRecoverySubtitle =>
      'Es la única forma de recuperar tu billetera.';

  @override
  String get webTestingOnly => 'La web es solo para pruebas.';

  @override
  String get recoveryPhraseCopied =>
      'Frase de recuperación copiada (se borrará en 15 s)';

  @override
  String get copyPhrase => 'Copiar frase';

  @override
  String get importWalletTitle => 'Importar billetera';

  @override
  String get importRecoveryPhraseTitle => 'Importar frase de recuperación';

  @override
  String get importRecoveryPhraseSubtitle => 'Usa 12 o 24 palabras en inglés.';

  @override
  String get importPasteHint => 'Pega aquí tu frase de recuperación';

  @override
  String get importInvalidPhrase => 'Frase de recuperación no válida';

  @override
  String get importEnterWords => 'Ingresa o pega 12 o 24 palabras.';

  @override
  String importWordsDetected(int count) {
    return '$count palabras detectadas';
  }

  @override
  String get importClear => 'Borrar';

  @override
  String get seekerVaultConnectDescription =>
      'Conecta la billetera respaldada por hardware en este Seeker.';

  @override
  String get seekerVaultConnect => 'Conectar';

  @override
  String get seekerVaultInstallOrEnable =>
      'Instala o activa Seeker Wallet y vuelve a intentarlo.';

  @override
  String get seekerVaultAndroidOnly =>
      'La importación de Seeker Vault solo está disponible en Android.';

  @override
  String get seekerVaultNoAccounts =>
      'No se devolvieron cuentas existentes de Seed Vault para esta semilla.';

  @override
  String get seekerVaultUnavailable =>
      'Seed Vault no está disponible en este dispositivo.';

  @override
  String get seekerVaultCancelled =>
      'La conexión con Seeker Vault fue cancelada.';

  @override
  String get seekerVaultConnectFailed =>
      'No se puede conectar Seeker Vault ahora. Inténtalo de nuevo.';

  @override
  String get receiveTitle => 'Recibir';

  @override
  String get receivedHistoryTitle => 'Historial recibido';

  @override
  String get receiveShareAddressTitle => 'Comparte esta dirección';

  @override
  String get receiveShareAddressSubtitle => 'Escanéala o cópiala.';

  @override
  String get receiveNoAddress => 'No hay dirección de billetera disponible';

  @override
  String get receiveNoAddressSubtitle =>
      'Crea o desbloquea una billetera para recibir fondos.';

  @override
  String get receiveAddressCopied => 'Dirección copiada (se borrará en 60 s)';

  @override
  String get receiveCopyAddress => 'Copiar dirección';

  @override
  String get sendTitle => 'Enviar';

  @override
  String get sendChooseAssetTitle => 'Elegir activo';

  @override
  String get sendHistoryTitle => 'Historial de envíos';

  @override
  String get sendUnavailableChildMode =>
      'Enviar no está disponible en modo infantil.';

  @override
  String get sendOpenReceive => 'Abrir Recibir';

  @override
  String get sendNoAssets => 'No hay activos disponibles para enviar.';

  @override
  String get sendRecipientPrefilled => 'Destinatario precargado';

  @override
  String sendLoadAssetsFailed(String error) {
    return 'No se pudieron cargar los activos: $error';
  }

  @override
  String get sendAssetNotFound => 'Activo no encontrado.';

  @override
  String sendAssetTitle(String symbol) {
    return 'Enviar $symbol';
  }

  @override
  String get sendScanQrCode => 'Escanear código QR';

  @override
  String get sendRecipientAddressHint => 'Dirección Solana del destinatario';

  @override
  String sendAvailableAmount(String amount, String symbol) {
    return 'Disponible $amount $symbol';
  }

  @override
  String sendLoadFormFailed(String error) {
    return 'No se pudo cargar el formulario de envío: $error';
  }

  @override
  String get sendInvalidAddress => 'Ingresa una dirección Solana válida.';

  @override
  String get sendInvalidAmount => 'Ingresa un importe válido.';

  @override
  String get sendInsufficientBalance => 'Saldo insuficiente.';

  @override
  String get sendUnlockAgain =>
      'Desbloquea la billetera de nuevo antes de enviar.';

  @override
  String get sendNotEnoughSolAfterFee =>
      'No hay suficiente SOL después de reservar la comisión de red.';

  @override
  String get sendNotEnoughSolForFee =>
      'No hay suficiente SOL para cubrir la comisión de red.';

  @override
  String get sendGenericFailure => 'El envío falló. Inténtalo de nuevo.';

  @override
  String get sendAmountHint => 'Importe';

  @override
  String get portfolioChildAccounts => 'Cuentas infantiles';

  @override
  String get portfolioCrypto => 'Cripto';

  @override
  String get portfolioStocks => 'Acciones';

  @override
  String get portfolioMessages => 'Mensajes';

  @override
  String get portfolioTokens => 'Tokens';

  @override
  String get portfolioDefi => 'DeFi';

  @override
  String get portfolioSend => 'Enviar';

  @override
  String get portfolioSwap => 'Intercambiar';

  @override
  String get portfolioReceive => 'Recibir';

  @override
  String get portfolioCouldNotRefreshAssets =>
      'No se pudieron actualizar los activos';

  @override
  String get portfolioPullToRetry =>
      'Desliza hacia abajo para intentarlo de nuevo.';

  @override
  String get portfolioDefiParentOnly => 'DeFi solo para modo padre';

  @override
  String get portfolioDefiParentOnlyMessage =>
      'Vuelve al modo padre para revisar posiciones de protocolos.';

  @override
  String get portfolioDefiUnavailable =>
      'Los datos DeFi no están disponibles temporalmente';

  @override
  String get portfolioDefiUnavailableMessage =>
      'Los tokens siguen actualizados.';

  @override
  String get portfolioNoDefi => 'Aún no hay posiciones DeFi';

  @override
  String get portfolioRefreshingDefi =>
      'Actualizando posiciones de protocolos...';

  @override
  String get portfolioNoActiveDefi =>
      'Tu billetera no tiene posiciones DeFi activas.';

  @override
  String get portfolioRefreshFailed => 'Error al actualizar';

  @override
  String get portfolioNetworkBusy =>
      'La red está ocupada ahora. Desliza hacia abajo para intentarlo de nuevo.';

  @override
  String get portfolioServerUnavailable =>
      'No se pudo conectar con el servidor. Revisa tu conexión y desliza hacia abajo para intentarlo de nuevo.';

  @override
  String get portfolioRefreshAssetsFailed =>
      'No se pudieron actualizar los activos. Desliza hacia abajo para intentarlo de nuevo.';

  @override
  String get portfolioReceiveSol => 'Recibir SOL';

  @override
  String get portfolioReceiveSolSubtitle =>
      'Recibe SOL para empezar a usar Benny Wallet.';

  @override
  String get commonAdd => 'Agregar';

  @override
  String get commonAmount => 'Cantidad';

  @override
  String get commonAuto => 'Auto';

  @override
  String get commonBuy => 'Comprar';

  @override
  String get commonConfirmed => 'Confirmado';

  @override
  String get commonCustom => 'Personalizado';

  @override
  String get commonDelete => 'Eliminar';

  @override
  String get commonEdit => 'Editar';

  @override
  String get commonFrom => 'De';

  @override
  String get commonNetwork => 'Red';

  @override
  String get commonNetworkFee => 'Comisión de red';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonSend => 'Enviar';

  @override
  String get commonSignature => 'Firma';

  @override
  String get commonSolana => 'Solana';

  @override
  String get commonStatus => 'Estado';

  @override
  String get commonSubmitted => 'Enviado';

  @override
  String get commonTo => 'Para';

  @override
  String get commonToken => 'Token';

  @override
  String get transactionTimeline => 'Cronología de la transacción';

  @override
  String get walletAddressUnavailable =>
      'La dirección de la billetera no está disponible.';

  @override
  String relativeSecondsAgo(Object count) {
    return 'hace $count s';
  }

  @override
  String relativeMinutesAgo(Object count) {
    return 'hace $count min';
  }

  @override
  String relativeHoursAgo(Object count) {
    return 'hace $count h';
  }

  @override
  String relativeDaysAgo(Object count) {
    return 'hace $count d';
  }

  @override
  String get importWalletLoadingTitle => 'Importando billetera...';

  @override
  String get importWalletLoadingSubtitle =>
      'Preparando tu lista de billeteras Solana.';

  @override
  String get importSolanaMainnet => 'Solana Mainnet';

  @override
  String get importSelectSolanaAccount =>
      'Selecciona la cuenta Solana que quieres importar.';

  @override
  String get importLoadingSolanaAccounts => 'Cargando cuentas Solana...';

  @override
  String get importCheckingActiveSolanaAccounts =>
      'Comprobando cuentas Solana activas.';

  @override
  String get importUnableScanRecoveryPhrase =>
      'No se puede escanear esta frase de recuperación ahora.';

  @override
  String get importActiveAccount => 'Cuenta activa';

  @override
  String get importDefaultMainWallet => 'Billetera principal predeterminada';

  @override
  String get seekerVaultTitle => 'Seeker Vault';

  @override
  String get seekerVaultChooseFundedAccount => 'Elige una cuenta con fondos';

  @override
  String get seekerVaultChooseAccount => 'Elige una cuenta';

  @override
  String get seekerVaultFundedAccountFound =>
      'Benny encontró actividad en esta billetera de Seed Vault.';

  @override
  String get seekerVaultNoFundedAccountFound =>
      'No se encontró ninguna cuenta con fondos. Estas son las cuentas devueltas por Seed Vault.';

  @override
  String seekerVaultAssetCount(Object count) {
    return '$count activos';
  }

  @override
  String get seekerVaultNoAssets => 'Sin activos';

  @override
  String get scanAddressTitle => 'Escanear dirección';

  @override
  String get scanNoSolanaAddress =>
      'No se encontró ninguna dirección Solana en este código QR.';

  @override
  String get scanPointCamera => 'Apunta la cámara a un código QR de Solana.';

  @override
  String get sendConfirmTitle => 'Confirmar envío';

  @override
  String get sendSubmitting => 'Enviando...';

  @override
  String sendSubmittingSummary(Object address, Object amount, Object symbol) {
    return '$amount $symbol a $address';
  }

  @override
  String get sendSubmitted => 'Enviado';

  @override
  String get sendFailed => 'Error al enviar';

  @override
  String sendSubmittedMessage(Object address, Object amount, Object symbol) {
    return '$amount $symbol se envió a $address. La confirmación puede tardar un momento.';
  }

  @override
  String get sendTransactionCouldNotComplete =>
      'La transacción no se pudo completar.';

  @override
  String get sendViewTransaction => 'Ver transacción';

  @override
  String get sendRecipientNotReady =>
      'La billetera receptora aún no está lista para recibir este token.';

  @override
  String get sendNetworkBusy => 'La red está ocupada. Inténtalo de nuevo.';

  @override
  String get sendNetworkTakingLonger =>
      'La red está tardando más de lo esperado. Inténtalo de nuevo.';

  @override
  String get sendHistoryEmpty => 'Aún no hay historial de envíos.';

  @override
  String sendHistoryLoadFailed(Object error) {
    return 'No se pudo cargar el historial de envíos: $error';
  }

  @override
  String get sendDetailsTitle => 'Detalles del envío';

  @override
  String get sendNotConfirmedYet => 'Aún no confirmado';

  @override
  String get sendOpenTokenDetails => 'Abrir detalles del token';

  @override
  String get sendViewOnSolscan => 'Ver en Solscan';

  @override
  String get sendToEmpty => 'Para --';

  @override
  String sendToAddress(Object address) {
    return 'Para $address';
  }

  @override
  String get sendStatusFailed => 'Fallido';

  @override
  String get sendStatusFinalized => 'Finalizado';

  @override
  String get sendStatusConfirmed => 'Confirmado';

  @override
  String get sendStatusSubmitted => 'Enviado';

  @override
  String get sendStatusSourceHeliusWebhook => 'Webhook de Helius';

  @override
  String get sendStatusSourceRpcSync => 'Sincronización de estado en cadena';

  @override
  String get sendStatusSourceChainActivity => 'Actividad en cadena';

  @override
  String get sendTransactionFallbackTitle => 'Transacción de envío';

  @override
  String get sendSubmittedToSender => 'Enviado al sender';

  @override
  String get sendSubmittedToSenderSubtitle =>
      'Helius Sender aceptó la transacción firmada.';

  @override
  String get sendAsyncResultFailed => 'El resultado asíncrono falló';

  @override
  String get sendWaitingAsyncConfirmation => 'Esperando confirmación asíncrona';

  @override
  String get sendAsyncConfirmationReceived => 'Confirmación asíncrona recibida';

  @override
  String get sendUpdatedFromHeliusWebhook =>
      'Actualizado desde el webhook de Helius.';

  @override
  String get sendUpdatedFromChainStatusSync =>
      'Actualizado desde la sincronización de estado en cadena.';

  @override
  String get sendConfirmationNotReceivedYet =>
      'La confirmación aún no se ha recibido.';

  @override
  String get swapTitle => 'Intercambiar';

  @override
  String get swapButton => 'Intercambiar';

  @override
  String get swapReviewTitle => 'Revisar intercambio';

  @override
  String swapForAmount(Object amount, Object symbol) {
    return 'por ~$amount $symbol';
  }

  @override
  String get swapPay => 'Pagar';

  @override
  String get swapReceive => 'Recibir';

  @override
  String get swapMinimumReceive => 'Mínimo a recibir';

  @override
  String get swapSlippage => 'Deslizamiento';

  @override
  String get swapPriorityFee => 'Comisión prioritaria';

  @override
  String get swapRoute => 'Ruta';

  @override
  String swapLamports(Object lamports) {
    return '$lamports lamports';
  }

  @override
  String get swapPriorityNormal => 'Normal';

  @override
  String get swapPriorityFast => 'Rápido';

  @override
  String get swapPriorityTurbo => 'Turbo';

  @override
  String get swapProcessing => 'Intercambiando...';

  @override
  String swapProcessingSummary(
    Object inputAmount,
    Object inputSymbol,
    Object outputAmount,
    Object outputSymbol,
  ) {
    return '$inputAmount $inputSymbol a $outputAmount $outputSymbol';
  }

  @override
  String get swapComplete => 'Intercambio completado';

  @override
  String get swapFailed => 'Error en el intercambio';

  @override
  String swapReceivedAmount(Object amount, Object symbol) {
    return '$amount $symbol recibidos';
  }

  @override
  String get swapCouldNotComplete => 'El intercambio no se pudo completar.';

  @override
  String get swapTradingUnavailableChildMode =>
      'El trading no está disponible en modo infantil.';

  @override
  String get swapNoBaseAssetsForXStocks =>
      'No hay SOL, USDC ni USDT disponibles para comprar xStocks.';

  @override
  String get swapNoAssetsAvailable =>
      'No hay activos disponibles para intercambiar.';

  @override
  String get swapPayWith => 'Pagar con';

  @override
  String get swapBuyXStock => 'Comprar xStock';

  @override
  String swapAvailable(Object amount, Object symbol) {
    return 'Disponible $amount $symbol';
  }

  @override
  String get swapRefreshingQuote => 'Actualizando cotización...';

  @override
  String swapRouteLabel(Object route) {
    return 'Ruta: $route';
  }

  @override
  String get swapBestRoute => 'Mejor ruta';

  @override
  String swapFailedLoadWalletAssets(Object error) {
    return 'No se pudieron cargar los activos de la billetera: $error';
  }

  @override
  String swapRateSummary(Object inputSymbol, Object outputSymbol, Object rate) {
    return '1 $inputSymbol ≈ $rate $outputSymbol';
  }

  @override
  String swapSlippageMin(Object value) {
    return '$value mín.';
  }

  @override
  String swapCustomWithValue(Object value) {
    return 'Personalizado · $value';
  }

  @override
  String swapMinReceive(Object amount) {
    return 'Mín. $amount';
  }

  @override
  String get swapAmountTooSmall =>
      'Esta cantidad es demasiado pequeña para una ruta válida.';

  @override
  String get swapWaitValidQuote =>
      'Espera una cotización válida antes de continuar.';

  @override
  String swapNotEnoughSolReserve(Object reserve) {
    return 'No hay suficiente SOL.\nSe necesita una reserva de $reserve SOL.';
  }

  @override
  String get swapRouteUnavailable =>
      'Esta ruta de intercambio no está disponible ahora. Prueba con SOL o elige otro par de tokens.';

  @override
  String get swapPriceMoved =>
      'El precio cambió antes de enviar el intercambio. Aumenta el deslizamiento e inténtalo de nuevo.';

  @override
  String get swapNotEnoughTokenBalance =>
      'Saldo de token insuficiente. Toca Max de nuevo y reintenta.';

  @override
  String get swapQuotesBusy =>
      'Las cotizaciones están ocupadas ahora. Inténtalo en un momento.';

  @override
  String get swapQuoteExpired =>
      'Esta cotización caducó. Revisa el intercambio de nuevo.';

  @override
  String get swapUnlockAgain =>
      'Desbloquea la billetera de nuevo antes de intercambiar.';

  @override
  String get swapTransactionUnavailable =>
      'La transacción de intercambio no está disponible.';

  @override
  String get swapConnectSeekerVaultAgain =>
      'Conecta Seeker Vault de nuevo antes de intercambiar.';

  @override
  String get swapConnectSeedVaultAgain =>
      'Conecta Seed Vault de nuevo antes de intercambiar.';

  @override
  String get swapUnexpectedSignatureCount =>
      'La billetera devolvió un número inesperado de firmas.';

  @override
  String get swapCustomSlippageLabel => 'Deslizamiento personalizado %';

  @override
  String get swapChooseToken => 'Elegir';

  @override
  String get swapApproxYouReceive => 'Recibirás aprox.';

  @override
  String get swapRate => 'Tasa';

  @override
  String get swapPlatformFee => 'Comisión de plataforma';

  @override
  String get swapSearchTokenHint => 'Busca nombre o símbolo del token';

  @override
  String get swapNoTokensAvailable => 'No hay tokens disponibles';

  @override
  String swapNoResultsFor(Object query) {
    return 'No se encontraron resultados para \"$query\"';
  }

  @override
  String get swapYourAssets => 'Tus activos';

  @override
  String get swapSuggestedTokens => 'Tokens sugeridos';

  @override
  String swapAvailableBalance(Object amount) {
    return '$amount disponible';
  }

  @override
  String get assetNotFound => 'Activo no encontrado.';

  @override
  String get assetPosition => 'Posición';

  @override
  String get assetValue => 'Valor';

  @override
  String get assetBalance => 'Saldo';

  @override
  String get assetReturn24h => 'Retorno 24 h';

  @override
  String get assetInfo => 'Información';

  @override
  String get assetName => 'Nombre';

  @override
  String get assetSymbol => 'Símbolo';

  @override
  String get assetMint => 'Mint';

  @override
  String get assetWebsite => 'Sitio web';

  @override
  String get assetPrice => 'Precio';

  @override
  String get assetMarketCap => 'Capitalización';

  @override
  String get assetFdv => 'FDV';

  @override
  String get assetTotalSupply => 'Suministro total';

  @override
  String get assetCirculatingSupply => 'Suministro circulante';

  @override
  String get assetHolders => 'Holders';

  @override
  String get assetCreated => 'Creado';

  @override
  String get assetPerformance24h => 'Rendimiento 24 h';

  @override
  String get assetVolume => 'Volumen';

  @override
  String get assetTraders => 'Traders';

  @override
  String get assetSafety => 'Seguridad';

  @override
  String get assetTop10Holders => 'Top 10 holders';

  @override
  String get assetMarketStatsUnavailable =>
      'Algunas estadísticas de mercado no están disponibles ahora.';

  @override
  String get assetActivity => 'Actividad';

  @override
  String get assetNoActivity => 'Aún no hay actividad.';

  @override
  String get assetActivityLoadFailed => 'No se pudo cargar la actividad.';

  @override
  String assetLoadDetailsFailed(Object error) {
    return 'No se pudieron cargar los detalles del activo: $error';
  }

  @override
  String get assetMintCopied => 'Mint copiado (se borrará en 60 s)';

  @override
  String get assetCouldNotOpenWebsite => 'No se pudo abrir el sitio web.';

  @override
  String get assetSwapOut => 'Swap out';

  @override
  String get assetSwapIn => 'Swap in';

  @override
  String assetToSymbol(Object symbol) {
    return 'A $symbol';
  }

  @override
  String assetFromSymbol(Object symbol) {
    return 'De $symbol';
  }

  @override
  String get assetSent => 'Enviado';

  @override
  String get assetReceived => 'Recibido';

  @override
  String get assetTransfer => 'Transferencia';

  @override
  String assetSwapWithTime(Object time) {
    return 'Swap  •  $time';
  }

  @override
  String assetCounterpartyWithTime(Object address, Object time) {
    return '$address  •  $time';
  }

  @override
  String get notificationsMarkAllRead => 'Marcar todo como leído';

  @override
  String get notificationsUnavailableTitle => 'Mensajes no disponibles';

  @override
  String get notificationsUnavailableSubtitle =>
      'No se pueden cargar mensajes ahora.';

  @override
  String get notificationsEmptyTitle => 'Aún no hay mensajes';

  @override
  String get notificationsEmptySubtitle =>
      'Los mensajes push aparecerán aquí cuando lleguen.';

  @override
  String get notificationDeleted => 'Mensaje eliminado';

  @override
  String get receivedHistoryEmpty => 'Aún no hay historial recibido.';

  @override
  String receivedHistoryLoadFailed(Object error) {
    return 'No se pudo cargar el historial recibido: $error';
  }

  @override
  String get receivedDetailsTitle => 'Detalles recibidos';

  @override
  String get receivedDetailsMissingId =>
      'Este mensaje no incluye un id de transferencia recibida.';

  @override
  String receivedDetailsLoadFailed(Object error) {
    return 'No se pudo cargar esta transferencia recibida: $error';
  }

  @override
  String get receivedFundsTitle => 'Fondos recibidos';

  @override
  String receivedYouReceived(Object amount) {
    return 'Recibiste $amount';
  }

  @override
  String receivedYouReceivedInWallet(String amount, String wallet) {
    return 'Recibiste $amount en $wallet';
  }

  @override
  String get receivedFromEmpty => 'De --';

  @override
  String receivedFromAddress(Object address) {
    return 'De $address';
  }

  @override
  String get receivedRelatedChanges => 'Cambios relacionados';

  @override
  String get receivedOnSolana => 'Recibido en Solana';

  @override
  String get receivedMarkedFailed =>
      'El evento de recepción se marcó como fallido.';

  @override
  String get receivedArrived => 'Los fondos llegaron a esta billetera.';

  @override
  String get receivedNewFundsArrived =>
      'Llegaron nuevos fondos a tu billetera.';

  @override
  String get childVerifyPinTitle => 'Verifica tu PIN';

  @override
  String get childWalletAlreadyAdded =>
      'Esta billetera infantil ya fue agregada.';

  @override
  String childWalletAdded(Object name) {
    return '$name se agregó correctamente';
  }

  @override
  String childWalletAddFailed(Object error) {
    return 'Error al agregar billetera infantil: $error';
  }

  @override
  String childWalletUpdated(Object name) {
    return '$name se actualizó correctamente';
  }

  @override
  String childWalletUpdateFailed(Object error) {
    return 'Error al actualizar billetera infantil: $error';
  }

  @override
  String childWalletDeleteTitle(Object name) {
    return '¿Eliminar $name?';
  }

  @override
  String get childWalletDeleteMessage =>
      'Esta entrada de billetera infantil se eliminará del monitoreo del padre.';

  @override
  String childWalletDeleted(Object name) {
    return '$name eliminado';
  }

  @override
  String childWalletDeleteFailed(Object error) {
    return 'Error al eliminar billetera infantil: $error';
  }

  @override
  String get childAccountsTitle => 'Cuentas infantiles';

  @override
  String get childManageUnavailable =>
      'Desactiva el modo infantil para gestionar cuentas infantiles.';

  @override
  String get childNoAccountsYet => 'Aún no hay cuentas infantiles';

  @override
  String childAccountCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cuentas infantiles',
      one: '1 cuenta infantil',
    );
    return '$_temp0';
  }

  @override
  String get childAddAccount => 'Agregar cuenta infantil';

  @override
  String get childEditAccount => 'Editar cuenta infantil';

  @override
  String get childName => 'Nombre del niño';

  @override
  String get childNameHint => 'p. ej., Alice';

  @override
  String get childWalletAddress => 'Dirección de la billetera infantil';

  @override
  String get childScanAgain => 'Escanear de nuevo';

  @override
  String get childScanQrAgain => 'Escanear QR de nuevo';

  @override
  String get childEnterName => 'Ingresa el nombre del niño.';

  @override
  String get childEnterValidWalletAddress =>
      'Ingresa una dirección de billetera válida.';

  @override
  String get childWalletTitle => 'Billetera infantil';

  @override
  String get childWalletNotFound => 'Billetera infantil no encontrada';

  @override
  String get childAddressCopied => 'Dirección copiada al portapapeles';

  @override
  String get childTotalBalance => 'Saldo total';

  @override
  String get childSendToChildWallet => 'Enviar a billetera infantil';

  @override
  String get childNoAssets => 'Sin activos';

  @override
  String get childAssets => 'Activos';

  @override
  String childWalletLoadFailed(Object error) {
    return 'Error al cargar billetera infantil: $error';
  }

  @override
  String get feedbackHeading => 'Cuéntanos qué salió mal';

  @override
  String get feedbackSubtitle =>
      'Envía tu pregunta o problema directamente al soporte de Benny Wallet.';

  @override
  String get feedbackEmailOptional => 'Email (opcional)';

  @override
  String get feedbackMessage => 'Mensaje';

  @override
  String get feedbackMessageHint => 'Describe el problema que estás viendo.';

  @override
  String get feedbackSending => 'Enviando...';

  @override
  String get feedbackMessageRequiredTitle => 'Mensaje requerido';

  @override
  String get feedbackMessageRequiredMessage =>
      'Ingresa tu feedback antes de enviar.';

  @override
  String get feedbackMessageTooLongTitle => 'Mensaje demasiado largo';

  @override
  String get feedbackMessageTooLongMessage =>
      'Mantén tu feedback dentro de 2000 caracteres.';

  @override
  String get feedbackInvalidEmailTitle => 'Email no válido';

  @override
  String get feedbackInvalidEmailMessage =>
      'Ingresa un email válido o déjalo vacío.';

  @override
  String get feedbackSent => 'Tu mensaje fue enviado.';

  @override
  String get feedbackSendFailedTitle => 'Error al enviar';

  @override
  String get feedbackSendFailedFallback =>
      'No se puede enviar tu mensaje ahora. Inténtalo de nuevo en breve.';

  @override
  String get rentTitle => 'Recuperar rent de Solana';

  @override
  String get rentDescription =>
      'Cierra cuentas de token vacías y recupera su rent al saldo principal de SOL.';

  @override
  String get rentWalletAddress => 'Dirección de billetera';

  @override
  String get rentClosableTokenAccounts => 'Cuentas de token cerrables';

  @override
  String get rentReclaimableRent => 'Rent recuperable';

  @override
  String get rentAccountsToClose => 'Cuentas a cerrar';

  @override
  String rentMoreAccounts(Object count) {
    return '+$count cuentas más se recuperarán.';
  }

  @override
  String get rentReclaiming => 'Recuperando...';

  @override
  String get rentNothingToReclaim => 'Nada que recuperar';

  @override
  String get rentReclaimAll => 'Recuperar todo el rent';

  @override
  String get rentReclaimingRent => 'Recuperando rent...';

  @override
  String get rentSubmittingTransactions =>
      'Enviando transacciones de cierre de cuenta.';

  @override
  String get rentUnlockRequiredTitle => 'Desbloqueo requerido';

  @override
  String get rentUnlockRequiredMessage =>
      'Desbloquea la billetera de nuevo antes de recuperar rent.';

  @override
  String get rentReclaimFailedTitle => 'Recuperación fallida';

  @override
  String get rentWalletRequiredTitle => 'Billetera requerida';

  @override
  String get rentConnectSeekerVaultAgain =>
      'Conecta Seeker Vault de nuevo antes de recuperar rent.';

  @override
  String get rentConnectSeedVaultAgain =>
      'Conecta Seed Vault de nuevo antes de recuperar rent.';

  @override
  String rentSubmittedTransactions(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transacciones de recuperación',
      one: '1 transacción de recuperación',
    );
    return 'Se enviaron $_temp0.';
  }

  @override
  String rentSubmittedTransactionsWithSkipped(num skipped, num submitted) {
    String _temp0 = intl.Intl.pluralLogic(
      submitted,
      locale: localeName,
      other: '$submitted transacciones de recuperación',
      one: '1 transacción de recuperación',
    );
    String _temp1 = intl.Intl.pluralLogic(
      skipped,
      locale: localeName,
      other: '$skipped cuentas',
      one: '1 cuenta',
    );
    return 'Se enviaron $_temp0; se omitieron $_temp1.';
  }

  @override
  String get rentUnableScan =>
      'No se pueden escanear cuentas de token recuperables ahora.';

  @override
  String rentMintAddress(Object address) {
    return 'Mint $address';
  }

  @override
  String get airdropTitle => 'Airdrop BYC';

  @override
  String get airdropUnavailableTitle =>
      'Airdrop BYC temporalmente no disponible';

  @override
  String get airdropUnlockBeforeJoin =>
      'Desbloquea tu billetera antes de unirte al airdrop BYC.';

  @override
  String get airdropJoinDialogTitle => '¿Unirte al airdrop BYC?';

  @override
  String airdropJoinDialogMessage(Object address) {
    return 'Usaremos tu dirección actual de Benny Wallet:\n\n$address\n\nEsta dirección se enviará al backend de Benny para registrar tu perfil de airdrop.';
  }

  @override
  String get airdropJoin => 'Unirse';

  @override
  String get airdropJoinedSnack =>
      'Ya estás dentro. Tu perfil de recompensas BYC está listo.';

  @override
  String get airdropJoinBeforeCheckIn =>
      'Únete al airdrop BYC antes de hacer check-in.';

  @override
  String get airdropUnlockBeforeCheckIn =>
      'Desbloquea tu billetera antes de hacer check-in.';

  @override
  String get airdropJoined => 'Unido';

  @override
  String get airdropNotJoined => 'No unido';

  @override
  String get airdropBycPoints => 'Puntos BYC';

  @override
  String get airdropStreak => 'Racha';

  @override
  String airdropDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '1 día',
    );
    return '$_temp0';
  }

  @override
  String get airdropWalletUnavailable => 'Billetera no disponible';

  @override
  String get airdropJoinCardTitle => 'Unirse al airdrop';

  @override
  String get airdropJoinCardSubtitle =>
      'Confirma con tu Benny Wallet activa y crea tu perfil de recompensas BYC.';

  @override
  String get airdropJoining => 'Uniendo...';

  @override
  String get airdropJoinWithThisWallet => 'Unirse con esta billetera';

  @override
  String get airdropCheckInNow => 'Hacer check-in ahora';

  @override
  String get airdropCheckedInToday => 'Check-in hecho hoy';

  @override
  String airdropNextReward(Object points) {
    return 'Próxima recompensa: +$points BYC';
  }

  @override
  String get airdropComeBackTomorrow => 'Vuelve mañana para reclamar más BYC.';

  @override
  String get airdropCheckingIn => 'Haciendo check-in...';

  @override
  String airdropLastClaimed(Object date) {
    return 'Último reclamo $date';
  }

  @override
  String get airdropRewardRules => 'Reglas de recompensa';

  @override
  String get airdropFirstCheckIn => 'Primer check-in';

  @override
  String get airdropNextDayReward => 'Recompensa del día siguiente';

  @override
  String airdropEveryDayStreak(Object days) {
    return 'Cada racha de $days días';
  }

  @override
  String get airdropUnableOpenPumpFun => 'No se puede abrir Pump.fun ahora.';

  @override
  String get airdropView => 'Ver';

  @override
  String get airdropPointsBalanceUpdated =>
      'Tu saldo de puntos Benny fue actualizado.';

  @override
  String get airdropFirstCheckInUnlocked => 'Primer check-in desbloqueado';

  @override
  String get airdropStreakBonusLanded => 'Bono de racha recibido';

  @override
  String get airdropAlreadyClaimedToday => 'Ya reclamado hoy';

  @override
  String get airdropRewardClaimed => 'Recompensa reclamada';

  @override
  String get defiTypeDeposit => 'depósito';

  @override
  String get defiTypeBorrow => 'préstamo';

  @override
  String get defiTypeStaking => 'staking';

  @override
  String get defiTypeLiquidity => 'liquidez';

  @override
  String get defiTypeYield => 'rendimiento';

  @override
  String get defiTypePerps => 'perps';

  @override
  String get defiTypeRewards => 'recompensas';

  @override
  String get defiTypePosition => 'posición';

  @override
  String get settingsSeekerWallet => 'Seeker Wallet';

  @override
  String get updateDefaultTitle => 'Actualización disponible';

  @override
  String get updateDefaultMessage =>
      'Hay una nueva versión de Benny Wallet disponible.';

  @override
  String get updateFailedTitle => 'Error al actualizar';

  @override
  String get updateUnableToOpen =>
      'No se puede abrir el enlace de actualización de Benny Wallet ahora.';

  @override
  String get routerFeatureUnavailableTitle => 'Función no disponible';

  @override
  String get routerFeatureUnavailableMessage =>
      'Esta función no está disponible en esta compilación.';

  @override
  String get routerMessageUnavailableTitle => 'Mensaje no disponible';

  @override
  String get routerMessageUnavailableMessage =>
      'Abre primero un mensaje recibido desde la lista de mensajes.';

  @override
  String get routerSendDetailsUnavailableTitle =>
      'Detalles de envío no disponibles';

  @override
  String get routerSendDetailsUnavailableMessage =>
      'Abre primero una transacción desde el historial de envíos.';

  @override
  String get routerInvalidChildWalletId => 'ID de billetera infantil no válido';

  @override
  String routerRouteNotFound(String uri) {
    return 'Ruta no encontrada: $uri';
  }

  @override
  String get walletsTitle => 'Billeteras';

  @override
  String get walletsSubtitle => 'Cambia, añade, renombra o elimina billeteras';

  @override
  String get walletSwitcherTitle => 'Tus billeteras';

  @override
  String walletSwitcherCount(int count, int max) {
    return '$count de $max';
  }

  @override
  String get walletAddWallet => 'Añadir billetera';

  @override
  String walletAddLimitReached(int max) {
    return 'Puedes añadir hasta $max billeteras.';
  }

  @override
  String get walletManage => 'Gestionar';

  @override
  String get walletAddSheetTitle => 'Añadir una billetera';

  @override
  String get walletAddSheetSubtitle =>
      'Cada billetera tiene su propia frase de recuperación y cuenta. Un solo PIN las desbloquea todas.';

  @override
  String get walletAddCreate => 'Crear billetera nueva';

  @override
  String get walletAddCreateSubtitle =>
      'Genera una nueva frase de recuperación';

  @override
  String get walletAddImport => 'Importar frase de recuperación';

  @override
  String get walletAddImportSubtitle => 'Usa otra frase u otra cuenta';

  @override
  String get walletAddSeedVault => 'Conectar Seed Vault';

  @override
  String get walletAddSeedVaultSubtitle => 'Usa una cuenta de tu Seeker';

  @override
  String get walletNameTitle => 'Ponle nombre a tu billetera';

  @override
  String get walletNameSubtitle =>
      'Solo se guarda en este dispositivo. Puedes cambiarlo cuando quieras.';

  @override
  String get walletNameLabel => 'Nombre de la billetera';

  @override
  String get walletNameEmpty => 'Escribe un nombre';

  @override
  String walletAdded(String name) {
    return '$name añadida';
  }

  @override
  String walletSwitched(String name) {
    return 'Cambiado a $name';
  }

  @override
  String get walletDuplicateTitle => 'Ya añadida';

  @override
  String get walletDuplicateMessage =>
      'Esta frase y cuenta ya están en Benny. Cada frase + cuenta solo se puede añadir una vez.';

  @override
  String get walletAlreadyAddedBadge => 'Añadida';

  @override
  String get walletRename => 'Renombrar';

  @override
  String get walletRenameTitle => 'Renombrar billetera';

  @override
  String get walletRemove => 'Eliminar';

  @override
  String walletRemoveTitle(String name) {
    return '¿Eliminar $name?';
  }

  @override
  String get walletRemoveMessage =>
      'Esto elimina la billetera de este dispositivo. Respalda antes su frase de recuperación: sin ella no podrás recuperar los fondos.';

  @override
  String get walletRemoveExternalMessage =>
      'Esto desconecta la billetera de Benny. Tus claves siguen seguras en Seed Vault.';

  @override
  String walletRemoved(String name) {
    return '$name eliminada';
  }

  @override
  String get walletActiveBadge => 'Activa';

  @override
  String get walletTypePhrase => 'Frase de recuperación';

  @override
  String get walletTypeSeedVault => 'Seed Vault';

  @override
  String get swapWalletChanged =>
      'La billetera activa cambió. Vuelve y obtén una nueva cotización.';

  @override
  String seedVaultPickNamedSeed(String seed, String wallet) {
    return 'A continuación elige la semilla «$seed». Ahí está $wallet.';
  }

  @override
  String seedVaultPickUnknownSeed(String wallet) {
    return 'Elige la semilla que contiene $wallet. Si eliges otra, te avisaremos y desaparecerá de la lista.';
  }

  @override
  String seedVaultWrongSeedNamed(String seed) {
    return '«$seed» no contiene esta billetera.';
  }

  @override
  String get seedVaultReauthorizeTitle => 'Volver a autorizar Seed Vault';

  @override
  String get childAddFromMyWallets => 'O elige una de mis billeteras';

  @override
  String get walletAddChildModeSetPin =>
      'Esta billetera no tiene un PIN de modo infantil guardado. Crea uno a continuación; lo necesitarás para desactivar el modo infantil.';

  @override
  String get settingsChildModeAppPinTitle =>
      'Ingresa el PIN de la app para desactivar el modo infantil';

  @override
  String get walletAddChildModeTitle => 'Esta billetera está en modo infantil';

  @override
  String get walletAddChildModeMessage =>
      'Al importarla, la app pasará a modo infantil: se ocultará el cambio de billetera, no se podrán añadir billeteras y no podrás enviar a tus otras billeteras. ¿Importarla de todos modos?';

  @override
  String get walletAddChildModeConfirm => 'Aceptar e importar';

  @override
  String get walletTypeStandard => 'Estándar';

  @override
  String get sendToMyWallet => 'Enviar a mi billetera';

  @override
  String get walletChildModeLocked =>
      'Desactiva el modo infantil para cambiar o añadir billeteras.';

  @override
  String get walletPinToContinue => 'Introduce tu PIN para continuar';

  @override
  String get walletActionFailed => 'Algo salió mal. Inténtalo de nuevo.';

  @override
  String get settingsChangePin => 'Cambiar PIN';

  @override
  String get settingsChangePinSubtitle =>
      'Un PIN desbloquea todas tus billeteras';

  @override
  String get changePinCurrent => 'Introduce tu PIN actual';

  @override
  String get changePinNew => 'Introduce el nuevo PIN';

  @override
  String get changePinConfirm => 'Confirma el nuevo PIN';

  @override
  String get changePinSuccess => 'PIN cambiado';

  @override
  String get changePinSameAsOld => 'Elige un PIN diferente';

  @override
  String get unlockSetPinTitle => 'Crea un PIN de Benny';

  @override
  String get unlockSetPinSubtitle =>
      'Ahora un solo PIN protege todas las billeteras de este dispositivo.';

  @override
  String get pinUnlocksAllWallets =>
      'Este PIN desbloquea todas tus billeteras.';

  @override
  String settingsLogOutAllWallets(int count) {
    return 'Esto elimina las $count billeteras de este dispositivo. Respalda antes cada frase de recuperación.';
  }

  @override
  String importAccountLabel(int number) {
    return 'Cuenta $number';
  }

  @override
  String importAccountAltLabel(int number) {
    return 'Cuenta $number · ruta alternativa';
  }

  @override
  String get importLegacyLabel => 'Heredada';

  @override
  String get travelGuardTitle => 'Protección de viaje';

  @override
  String get travelGuardOffSubtitle =>
      'Un PIN especial que abre solo una billetera';

  @override
  String get travelGuardOnSubtitle =>
      'Activada: el PIN especial abre una billetera';

  @override
  String get travelGuardInfoTitle => '¿Qué es la protección de viaje?';

  @override
  String get travelGuardInfoBody =>
      'Para cuando alguien te obliga a abrir tu billetera.\n\nDefine un PIN especial y elige una billetera (con poco saldo). Al desbloquear con el PIN especial solo se abre esa billetera: las demás, sus saldos y mensajes quedan ocultos en todas partes, incluidas las listas y los envíos, y este ajuste también se oculta.\n\nMientras está activada, el desbloqueo biométrico se desactiva y no se puede activar.\n\nBloquea la app y desbloquéala con tu PIN normal para volver a ver todas tus billeteras.';

  @override
  String get travelGuardChooseWallet =>
      'Elige la billetera que abre el PIN especial';

  @override
  String get travelGuardNewPin => 'Define el PIN especial';

  @override
  String get travelGuardConfirmPin => 'Repite el PIN especial';

  @override
  String get travelGuardPinHint => 'Debe ser distinto de tu PIN normal.';

  @override
  String get travelGuardPinSameAsApp => 'Ese es tu PIN normal. Elige otro.';

  @override
  String get travelGuardEnabled => 'Protección de viaje activada';

  @override
  String get travelGuardDisabled => 'Protección de viaje desactivada';

  @override
  String get travelGuardActiveBadge => 'Protección de viaje activada';

  @override
  String get travelGuardBiometricsOff =>
      'No disponible con la protección de viaje';

  @override
  String get welcomeUseAsSigner =>
      'Usar este teléfono como firmante sin conexión';

  @override
  String get walletAddAirGap => 'Conectar firmante sin conexión';

  @override
  String get walletAddAirGapSubtitle =>
      'Las claves se quedan en otro teléfono que nunca se conecta a internet';

  @override
  String createWalletWordCount(int count) {
    return '$count palabras';
  }

  @override
  String get signerAppTitle => 'Benny Signer';

  @override
  String get signerNeedsNoWalletsTitle =>
      'Primero elimina todas las billeteras';

  @override
  String get signerNeedsNoWalletsBody =>
      'Un teléfono firmante solo guarda su propia frase de recuperación sin conexión. Haz una copia de seguridad y elimina todas las billeteras de este teléfono en Ajustes > Billeteras, y vuelve a intentarlo.';

  @override
  String get signerEnterTitle => '¿Convertir este teléfono en firmante?';

  @override
  String get signerEnterBody =>
      'Este teléfono permanecerá sin conexión y solo firmará. No tendrá pantallas de billetera. Para volver a usarlo como billetera, tendrás que borrarlo.';

  @override
  String get signerIntroTitle => 'Firmante sin conexión';

  @override
  String get signerIntroPoint1 =>
      'Este teléfono guarda tu frase de recuperación y no vuelve a conectarse a internet.';

  @override
  String get signerIntroPoint2 =>
      'Tu otro teléfono con Benny Wallet crea las transacciones. Tú las firmas aquí escaneando códigos QR.';

  @override
  String get signerIntroPoint3 =>
      'Antes de crear una frase de recuperación, te ayudaremos a desactivar todas las redes.';

  @override
  String get signerIntroPoint4 =>
      'Escribe la frase de recuperación en papel. Es la única copia de seguridad.';

  @override
  String get signerIntroStart => 'Empezar';

  @override
  String get signerIntroCancel => 'Ahora no, usar como billetera';

  @override
  String get signerOfflineTitle => 'Desconecta este teléfono';

  @override
  String get signerOfflineBody =>
      'Activa el modo avión y desactiva Wi-Fi, Bluetooth y NFC. Podrás continuar cuando todos los elementos obligatorios estén en verde.';

  @override
  String get signerCheckAirplane => 'Modo avión activado';

  @override
  String get signerCheckWifi => 'Wi-Fi desactivado';

  @override
  String get signerCheckBluetooth => 'Bluetooth desactivado';

  @override
  String get signerCheckNfc => 'NFC desactivado';

  @override
  String get signerCheckNoNetwork => 'Sin conexión de red';

  @override
  String get signerCheckUsbDebugging => 'Depuración USB desactivada';

  @override
  String get signerCheckSim => 'Tarjeta SIM retirada (recomendado)';

  @override
  String get signerCheckManualHint =>
      'Este teléfono no puede comprobarlo. Confírmalo tú mismo.';

  @override
  String get signerOpenSettings => 'Abrir ajustes';

  @override
  String get signerNetworkDetected =>
      'Se detectó una conexión de red. Desactívala para continuar.';

  @override
  String get signerPinTitle => 'Configurar PIN del firmante';

  @override
  String get signerPinBody => 'Elige un PIN de 6 dígitos para este firmante.';

  @override
  String get signerPinConfirmTitle => 'Confirmar PIN';

  @override
  String get signerPinConfirmBody => 'Vuelve a introducir el PIN.';

  @override
  String get signerPinMismatch => 'Los PIN no coinciden. Inténtalo de nuevo.';

  @override
  String get signerSourceTitle => 'Frase de recuperación';

  @override
  String get signerSourceBody =>
      'Crea una nueva frase de recuperación en este teléfono sin conexión o introduce una que ya tengas.';

  @override
  String get signerSourceCreate24 => 'Crear 24 palabras';

  @override
  String get signerSourceCreate24Subtitle => 'Recomendado para un firmante';

  @override
  String get signerSourceCreate12 => 'Crear 12 palabras';

  @override
  String get signerSourceCreate12Subtitle => 'Más corta de anotar';

  @override
  String get signerSourceImport => 'Importar frase existente';

  @override
  String get signerSourceImportSubtitle => '12 o 24 palabras';

  @override
  String get signerWordsTitle => 'Anota estas palabras';

  @override
  String get signerWordsWarning =>
      'Escribe las palabras en papel y en orden. Nunca les hagas una foto ni una captura de pantalla, ni las escribas en ningún otro lugar. Cualquiera que tenga estas palabras puede llevarse tus fondos.';

  @override
  String get signerWordsDone => 'Ya las anoté';

  @override
  String get signerVerifyTitle => 'Comprueba tu copia de seguridad';

  @override
  String get signerImportTitle => 'Importar frase de recuperación';

  @override
  String get signerImportBody =>
      'Introduce tus 12 o 24 palabras separadas por espacios.';

  @override
  String get signerImportInvalid =>
      'No es una frase de recuperación válida de 12 o 24 palabras.';

  @override
  String get signerFinishTitle => 'Finalizar configuración';

  @override
  String get signerDeviceNameLabel => 'Nombre del firmante';

  @override
  String get signerDeviceNameHelper =>
      'Se muestra en tu billetera después de conectar.';

  @override
  String get signerBiometricToggle => 'Desbloquear con biometría';

  @override
  String get signerFinishButton => 'Finalizar';

  @override
  String get signerSetupFailed =>
      'No se pudo guardar la configuración. Inténtalo de nuevo.';

  @override
  String get signerUnlockSubtitle => 'Introduce el PIN del firmante';

  @override
  String get signerUnlockNetworkBlocked =>
      'Hay una conexión de red activa. Activa el modo avión para desbloquear.';

  @override
  String signerWrongPin(int count) {
    return 'PIN incorrecto. Quedan $count intentos antes de que se borre el firmante.';
  }

  @override
  String get signerUnlockFailed =>
      'No se pudo desbloquear. Inténtalo de nuevo.';

  @override
  String get signerUseBiometric => 'Usar biometría';

  @override
  String get signerBiometricReason => 'Desbloquea tu firmante Benny';

  @override
  String get signerBiometricFailed => 'No se pudo cambiar la biometría.';

  @override
  String get signerRecheckTitle => 'Comprobación sin conexión';

  @override
  String get signerRecheckBody =>
      'La app se actualizó. Asegúrate de que este teléfono vuelva a estar completamente sin conexión antes de desbloquearlo.';

  @override
  String get signerLockNow => 'Bloquear';

  @override
  String get signerOfflineChip => 'Firmante sin conexión';

  @override
  String get signerScanToSign => 'Escanear para firmar';

  @override
  String get signerPairWallet => 'Conectar billetera';

  @override
  String get signerAccountsTitle => 'Cuentas';

  @override
  String signerAccountName(int number) {
    return 'Cuenta $number';
  }

  @override
  String get signerPairBody =>
      'En Benny Wallet de tu otro teléfono, elige Conectar firmante sin conexión y escanea este código.';

  @override
  String get signerPairPublicOnly =>
      'Este código solo contiene direcciones públicas, nunca tu frase de recuperación.';

  @override
  String get signerScanBody =>
      'Escanea el código QR que muestra Benny Wallet en tu otro teléfono.';

  @override
  String get signerScanWrongCode =>
      'Esto no es una solicitud de firma de Benny Wallet.';

  @override
  String get signerScanAgain => 'Escanear de nuevo';

  @override
  String get signerRejectUnknownAccount =>
      'Esta solicitud es para una cuenta que no está en este firmante.';

  @override
  String get signerRejectNotASigner =>
      'Esta cuenta no necesita firmar esta transacción.';

  @override
  String get signerRejectUnreadable =>
      'No se puede leer esta transacción, así que no se firmará.';

  @override
  String get signerRejectMessageIsTransaction =>
      'Este mensaje es en realidad una transacción, así que no se firmará.';

  @override
  String get signerRejectInvalidCode =>
      'Este código QR no es una solicitud de firma válida.';

  @override
  String get signerReviewTitle => 'Revisar y firmar';

  @override
  String get signerReviewAccount => 'Cuenta firmante';

  @override
  String get signerReviewFee => 'Comisión de red';

  @override
  String get signerReviewMessage => 'Mensaje';

  @override
  String signerBinaryMessage(int count) {
    return 'Datos binarios ($count bytes)';
  }

  @override
  String get signerThisAccount => 'esta cuenta';

  @override
  String signerActionSendSol(String amount) {
    return 'Enviar $amount SOL';
  }

  @override
  String signerActionSendToken(String amount, String symbol) {
    return 'Enviar $amount $symbol';
  }

  @override
  String signerActionSendUnverified(String amount) {
    return 'Enviar $amount de un token no verificado';
  }

  @override
  String signerActionTo(String address) {
    return 'A $address';
  }

  @override
  String signerActionToTokenAccount(String address) {
    return 'A la cuenta de token $address';
  }

  @override
  String signerActionMint(String mint) {
    return 'Dirección del token $mint';
  }

  @override
  String signerActionOwner(String address) {
    return 'Propietario $address';
  }

  @override
  String signerActionRentTo(String address) {
    return 'Renta devuelta a $address';
  }

  @override
  String get signerActionCreateTokenAccount => 'Crear cuenta de token';

  @override
  String get signerActionCloseTokenAccount => 'Cerrar cuenta de token';

  @override
  String get signerActionMemo => 'Memo';

  @override
  String get signerActionApprove => 'Permitir que otra cuenta gaste tus tokens';

  @override
  String get signerActionSetAuthority => 'Cambiar la autoridad de la cuenta';

  @override
  String get signerActionAssign => 'Cambiar el propietario de la cuenta';

  @override
  String get signerActionCreateAccount => 'Crear cuenta';

  @override
  String signerActionProgram(String program) {
    return 'Programa $program';
  }

  @override
  String get signerHoldToSign => 'Mantén pulsado para firmar';

  @override
  String get signerReject => 'Rechazar';

  @override
  String get signerSignFailed => 'No se pudo firmar. Inténtalo de nuevo.';

  @override
  String get signerSignatureTitle => 'Firma';

  @override
  String get signerSignatureBody =>
      'Escanea este código con Benny Wallet en tu otro teléfono para terminar.';

  @override
  String get signerSettingsTitle => 'Ajustes del firmante';

  @override
  String get signerAccountCount => 'Cuentas mostradas';

  @override
  String get signerAccountCountHint =>
      'Hasta 5 cuentas de esta frase de recuperación';

  @override
  String get signerUpgradeTitle => 'Actualizar el firmante';

  @override
  String get signerUpgradeIntro =>
      'Actualizar la app requiere conexión, así que planifícalo. Tu frase de recuperación sigue cifrada en este teléfono mientras está conectado, y el firmante no la abrirá hasta que el teléfono vuelva a estar sin conexión.';

  @override
  String get signerUpgradeStep0 => '1. Comprueba tu copia en papel';

  @override
  String get signerUpgradeVerifyBackup => 'Comprobar copia';

  @override
  String get signerUpgradeBackupOk => 'Copia comprobada';

  @override
  String get signerUpgradeOnlineTitle => '2a. Actualización estándar';

  @override
  String get signerUpgradeOnlineBody =>
      'Bloquea el firmante. Activa la red y actualiza Benny Wallet desde la misma tienda en la que lo instalaste. Vuelve a activar el modo avión. El firmante repetirá la comprobación sin conexión antes de que puedas desbloquearlo.';

  @override
  String get signerUpgradeSecureTitle => '2b. Actualización más segura';

  @override
  String get signerUpgradeSecureBody =>
      'Borra el firmante en ajustes y luego actualiza la app con conexión. Vuelve a desconectarte, configura el firmante e importa tu frase de recuperación. Tus cuentas y direcciones no cambian.';

  @override
  String get signerUpgradeOfflineApkTitle => 'Android: actualizar sin conexión';

  @override
  String get signerUpgradeOfflineApkBody =>
      'También puedes copiar el nuevo APK de benny-wallet.com a este teléfono por cable USB o tarjeta SD e instalarlo sin conectarte. Instálalo solo sobre una versión de la misma fuente.';

  @override
  String get signerUpgradeCompatTitle =>
      'Los firmantes antiguos siguen funcionando';

  @override
  String get signerUpgradeCompatBody =>
      'Una app de billetera más reciente sigue funcionando con un firmante antiguo. La billetera solo pide lo que este firmante admite, así que puedes actualizar cuando te convenga.';

  @override
  String get signerVersionTitle => 'Versión';

  @override
  String signerVersionDetail(String app, int protocol, int tokens) {
    return 'App $app · protocolo $protocol · lista de tokens $tokens';
  }

  @override
  String get signerEraseTitle => 'Borrar firmante';

  @override
  String get signerEraseSubtitle =>
      'Elimina la frase de recuperación de este teléfono';

  @override
  String get signerEraseBody =>
      'La frase de recuperación se eliminará de este teléfono. Sin tu copia en papel, los fondos no se podrán recuperar.';

  @override
  String get signerEraseConfirm => 'Borrar';

  @override
  String get signerEraseWrongPin => 'PIN incorrecto. No se borró nada.';

  @override
  String get airGapConnectTitle => 'Conectar firmante sin conexión';

  @override
  String get airGapConnectBody =>
      'En tu teléfono firmante, toca Conectar billetera y escanea el código que muestra.';

  @override
  String get airGapConnectInvalid =>
      'Esto no es un código de vinculación de firmante.';

  @override
  String airGapConnectChoose(String device) {
    return 'Elige una cuenta en $device';
  }

  @override
  String airGapConnectAccount(int number) {
    return 'Cuenta $number';
  }

  @override
  String airGapConnectAccountAdded(int number) {
    return 'Cuenta $number (ya añadida)';
  }

  @override
  String get airGapConnectCompare =>
      'Comprueba que la dirección coincide con la que muestra tu firmante.';

  @override
  String get airGapConnectScanAgain => 'Escanear de nuevo';

  @override
  String get airGapSignTitle => 'Firmar con tu firmante';

  @override
  String get airGapSignShowRequestAgain => 'Mostrar la solicitud de nuevo';

  @override
  String get airGapSignMayHaveExpired =>
      'Es posible que esta transacción haya caducado. Si el envío falla, vuelve a empezar.';

  @override
  String get airGapSignWrongRequest => 'Esta firma pertenece a otra solicitud.';

  @override
  String get airGapSignInvalidCode => 'Esta no es una firma de tu firmante.';

  @override
  String get airGapSignerOutdated =>
      'Tu firmante usa una versión anterior. Sigue funcionando; actualízalo cuando te venga bien.';

  @override
  String get signerIntroSubtitle =>
      'Guarda tus claves en un teléfono que nunca se conecta a internet.';

  @override
  String get signerFinishSubtitle =>
      'Ponle un nombre a este firmante y crea un PIN.';

  @override
  String signerQuizBody(int count) {
    return 'Elige la palabra correcta para $count posiciones. Usa tu copia en papel.';
  }

  @override
  String signerQuizProgress(int current, int total) {
    return 'Pregunta $current de $total';
  }

  @override
  String signerQuizQuestion(int position) {
    return '¿Cuál es la palabra n.º $position?';
  }

  @override
  String get signerQuizCorrect => '¡Correcto!';

  @override
  String get signerQuizWrong =>
      'No es correcto. Revisa tu papel; elegimos palabras nuevas para volver a intentarlo.';

  @override
  String get signerQuizShowWords => 'Ver las palabras otra vez';

  @override
  String get signerScanToSignSubtitle =>
      'Escanea la solicitud que muestra tu billetera';

  @override
  String get signerPairWalletSubtitle =>
      'Muestra un código para que Benny Wallet lo escanee';

  @override
  String get signerWalletPhoneLabel => 'Benny Wallet';

  @override
  String get signerScanRefusedTitle => 'No se puede firmar';

  @override
  String get airGapSignerLabel => 'Firmante';

  @override
  String get airGapThisPhone => 'Este teléfono';

  @override
  String get airGapConnectFound => 'Firmante reconocido';

  @override
  String get airGapSignNeedsSigner =>
      'Tu firmante debe verificar y firmar esto';

  @override
  String get airGapSignStepShort1 => 'Escanea el firmante';

  @override
  String get airGapSignStepShort2 => 'Escanear firma';

  @override
  String airGapSignStep1Named(String device) {
    return 'Paso 1: escanea este código con “$device”';
  }

  @override
  String airGapSignStep1BodyNamed(String device) {
    return 'En “$device”, toca Escanear para firmar, revisa los detalles y confirma.';
  }

  @override
  String airGapSignStep2Named(String device) {
    return 'Paso 2: escanea la firma de “$device”';
  }

  @override
  String airGapSignStep2BodyNamed(String device) {
    return 'Tras confirmar, “$device” muestra un código de firma. Escanéalo con este teléfono.';
  }

  @override
  String airGapSignScanSignatureNamed(String device) {
    return 'Siguiente: escanear la firma de $device';
  }

  @override
  String signerActionSwapPair(String from, String to) {
    return 'Intercambiar $from → $to';
  }

  @override
  String signerSwapPay(String amount) {
    return 'Pagas $amount';
  }

  @override
  String signerSwapPayAtMost(String amount) {
    return 'Pagas como máximo $amount';
  }

  @override
  String signerSwapReceive(String amount) {
    return 'Recibes $amount';
  }

  @override
  String signerSwapReceiveAtLeast(String amount) {
    return 'Recibes al menos $amount';
  }

  @override
  String get signerSwapUnverifiedToken => 'Token no verificado';

  @override
  String airGapSignTimeLeft(int seconds) {
    return 'Quedan $seconds s. Si se acaba el tiempo, aparecerá un código nuevo automáticamente.';
  }

  @override
  String get airGapSignRefreshing =>
      'Se acabó el tiempo. Obteniendo una cotización y un código nuevos…';

  @override
  String airGapSignRefreshed(String device) {
    return 'El código anterior caducó; aquí tienes uno nuevo. Escanéalo de nuevo con “$device”.';
  }

  @override
  String get airGapSignRefreshFailed =>
      'No se pudo obtener un código nuevo. Revisa tu conexión e inténtalo de nuevo.';

  @override
  String get airGapSignOldRequest =>
      'Esta firma es del código caducado. Escanea primero el código nuevo en tu firmante.';

  @override
  String get scanHintRoleShows => 'Muestra el código';

  @override
  String get scanHintRoleScans => 'Escanea';

  @override
  String signerTokenUnchecked(String symbol) {
    return '$symbol (no verificado)';
  }

  @override
  String get signerReviewActions => 'Transacción';

  @override
  String get signerNewerWalletNotice =>
      'Tu billetera es más nueva que este firmante. Actualiza el firmante cuando puedas.';

  @override
  String get signerDangerBanner =>
      'Riesgo alto. No firmes si no lo iniciaste tú.';

  @override
  String get signerActionSwap => 'Intercambio';

  @override
  String get signerActionSwapDetail => 'Revisa las cantidades en tu billetera.';

  @override
  String get signerActionDangerDetail =>
      'Peligroso. Si no estás seguro, no firmes.';

  @override
  String get signerActionAdvanceNonce => 'Actualizar número de transacción';

  @override
  String get signerActionSyncNative => 'Actualizar saldo de SOL';

  @override
  String get signerHoldLongHint =>
      'Revisa con cuidado y mantén pulsado 3 segundos.';

  @override
  String signerTokenVerified(String token) {
    return '$token · Verificado por Benny Wallet';
  }

  @override
  String signerTokenWalletProvided(String symbol) {
    return '$symbol · No verificado por Benny Wallet';
  }

  @override
  String signerSwapWalletQuote(String pay, String receive) {
    return 'Estimado: pagas $pay, recibes unos $receive';
  }

  @override
  String get signerActionUnknown => 'Paso no reconocido';

  @override
  String signerActionCreateTokenAccountFor(String symbol) {
    return 'Abrir cuenta de $symbol';
  }

  @override
  String get signerUnresolvedAccounts =>
      'El firmante no puede ver toda la transacción. Firma solo si acabas de iniciarla tú.';

  @override
  String get signerTokenNotVerified => 'No verificado por Benny Wallet';

  @override
  String get signerKindSwap => 'Intercambio';

  @override
  String get signerKindSend => 'Envío';

  @override
  String signerAbout(String amount) {
    return 'Unos $amount';
  }

  @override
  String get signerAmountsFromWallet => 'Las cantidades vienen de la billetera';

  @override
  String get signerTrustSafe => 'Todos los tokens verificados por Benny Wallet';

  @override
  String get signerTrustCaution =>
      'Un token no está verificado por Benny Wallet. Ten cuidado.';

  @override
  String get signerTrustDangerSwap =>
      'Ningún token está verificado por Benny Wallet. Riesgo alto.';

  @override
  String get signerTrustDangerSend =>
      'Este token no está verificado por Benny Wallet. Riesgo alto.';

  @override
  String get signerReviewOtherSteps => 'Otros pasos';

  @override
  String get signerPay => 'Pagas';

  @override
  String get signerPayAtMost => 'Pagas como máximo';

  @override
  String get signerGet => 'Recibes';

  @override
  String get signerGetAtLeast => 'Recibes como mínimo';

  @override
  String get signerGetAbout => 'Recibes aprox.';

  @override
  String get signerRecipient => 'Destinatario';

  @override
  String get signerRecipientTokenAccount => 'Cuenta de token del destinatario';

  @override
  String get signerUsdFromWallet =>
      'Los valores en USD son una estimación de la billetera';

  @override
  String signerActionCreateTokenAccountForRecipient(String symbol) {
    return 'Abrir cuenta de $symbol para el destinatario';
  }

  @override
  String get signerCreateAccountSkipIfOpen =>
      '(La primera vez cuesta unos 0,002 SOL; si ya existe se omite sin coste)';

  @override
  String get signerCreateAccountNotOpen =>
      '(Aún no existe; cuesta unos 0,002 SOL)';

  @override
  String get signerAddressFromWallet =>
      'Esta dirección la da la billetera. El firmador no puede comprobarla.';

  @override
  String get signerSwapOutputUnchecked =>
      'No se puede confirmar que los tokens del intercambio lleguen a ti.';

  @override
  String get signerExtraOutflow =>
      'Esto también envía fondos a otra dirección.';

  @override
  String signerHighFee(String amount) {
    return 'Comisión de red muy alta: $amount SOL';
  }

  @override
  String get signerDurableNonce =>
      'Esta firma no caduca nunca. Puede usarse más tarde.';

  @override
  String get signerSwapFromWallet =>
      'El token o la cantidad vienen de la billetera y no se pueden comprobar.';

  @override
  String signerActionCloseTo(String address) {
    return 'El saldo y la renta van a $address';
  }

  @override
  String signerWalletNote(String name) {
    return 'Nota de la billetera: $name';
  }

  @override
  String get signerReviewFeePayer => 'Comisión pagada por';

  @override
  String signerActionOwnerProgram(String program) {
    return 'Controlada por el programa $program';
  }

  @override
  String get signerSlippageAll =>
      'Deslizamiento del 100 % o más: puede que no recibas nada.';

  @override
  String get signerQuizTooManyWrong =>
      'Demasiadas respuestas incorrectas. Introduce tu PIN para intentarlo de nuevo.';

  @override
  String get signerSignInTitle => 'Solicitud de inicio de sesión';

  @override
  String get signerKindSignIn => 'Iniciar sesión';

  @override
  String get signerSignInBenny => 'Iniciar sesión en Benny Wallet';

  @override
  String signerSignInOtherSite(String site) {
    return '“$site” te pide iniciar sesión. Firma solo si lo iniciaste tú.';
  }

  @override
  String get signerSignInExpired =>
      'Esta solicitud ha caducado. Revisa la hora de este teléfono o empieza de nuevo en la billetera.';

  @override
  String get signerSignInOtherAccount =>
      'Este inicio de sesión es de otra cuenta. No firmes.';

  @override
  String get signerSignInWhat =>
      'Demuestra que esta cuenta es tuya para que Benny muestre su saldo, historial y avisos.';

  @override
  String get signerSignInNoFunds => 'No mueve fondos ni cuesta comisión.';

  @override
  String get signerSignInShowText => 'Ver texto original';

  @override
  String get airGapSignInTitle => 'Inicia sesión con tu firmante';

  @override
  String get airGapSignInWhy => '¿Por qué firmar esto?';

  @override
  String get airGapSignInWhyBody =>
      'Benny necesita confirmar que esta cuenta es tuya antes de cargar tu saldo, historial y avisos. Normalmente solo se hace una vez por billetera.';

  @override
  String get airGapSignInSafe =>
      'Es solo un inicio de sesión. No mueve fondos ni cuesta comisión.';

  @override
  String airGapSignInSignerShows(String device) {
    return '“$device” mostrará “Iniciar sesión en Benny Wallet”.';
  }

  @override
  String airGapSignInSignerShowsText(String device) {
    return '“$device” mostrará un texto en inglés que empieza por “Benny Wallet wants you to sign in”. Es este inicio de sesión. Tras actualizar el firmante, mostrará “Iniciar sesión en Benny Wallet”.';
  }
}
