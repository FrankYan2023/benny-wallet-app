abstract final class AppConstants {
  static const _defaultApiBaseUrl = 'https://api.example.invalid';
  static const productionApiBaseUrl = 'https://api.gobennyapp.com';
  static const productionApiFallbackBaseUrl =
      'https://benny-wallet-api-production.up.railway.app';

  static const appName = 'Benny Wallet';
  static const supportedNetwork = 'Solana Mainnet';
  static const assetRefreshIntervalSec = 20;
  static const priceRefreshIntervalSec = 30;
  static const sessionTimeoutSec = 60;
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: _defaultApiBaseUrl,
  );
  static const apiFallbackBaseUrls = String.fromEnvironment(
    'API_FALLBACK_BASE_URLS',
    defaultValue: '',
  );
  static const solanaRpcUrl = String.fromEnvironment(
    'SOLANA_RPC_URL',
    defaultValue: '$apiBaseUrl/v1/solana-rpc',
  );
  static const solanaWebSocketUrl = String.fromEnvironment(
    'SOLANA_WS_URL',
    defaultValue: '',
  );

  static const walletRecordsKey = 'wallet_records_v1';
  static const selectedWalletPublicKeyKey = 'selected_wallet_public_key';
  static const unlockedSessionPublicKeyKey = 'unlocked_session_public_key';
  static const unlockedSessionMnemonicKey = 'unlocked_session_mnemonic';
  static const backendAccessSessionKey = 'backend_access_session_v1';
  static const walletCipherTextKey = 'wallet_cipher_text';
  static const walletNonceKey = 'wallet_nonce';
  static const walletSaltKey = 'wallet_salt';
  static const walletPublicKeyKey = 'wallet_public_key';
  static const biometricEnabledKey = 'wallet_biometric_enabled';
  static const biometricMnemonicKey = 'wallet_biometric_mnemonic';
  static const biometricPublicKeyKey = 'wallet_biometric_public_key';
  static const installAnalyticsIdKey = 'install_analytics_id_v1';
  static const installAnalyticsSentKey = 'install_analytics_sent_v1';
  static const autoLockOptionKey = 'auto_lock_option';
  static const notificationsEnabledKey = 'notifications_enabled';
  static const lastPushFcmTokenKey = 'last_push_fcm_token_v1';
  static const lastPushWalletPublicKeyKey = 'last_push_wallet_public_key_v1';
  static const lastPushPermissionStatusKey = 'last_push_permission_status_v1';
  static const lastPushRegisteredAtKey = 'last_push_registered_at_v1';
  static const lastIncomingNotificationPrefix = 'last_incoming_notification';
}
