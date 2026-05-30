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
}
