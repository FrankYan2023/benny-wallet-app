import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/crypto/local_cipher.dart';
import '../../core/network/api_client.dart';
import '../../core/network/backend_session_manager.dart';
import '../../core/network/wallet_auth_api_client.dart';
import '../../core/security/biometric_session_protector.dart';
import '../../core/services/app_badge_service.dart';
import '../../core/services/biometric_auth_service.dart';
import '../../core/services/local_notification_service.dart';
import '../../core/services/mobile_wallet_adapter_service.dart';
import '../../core/services/push_notification_service.dart';
import '../../core/storage/key_value_store.dart';
import '../../core/storage/secure_store.dart';
import '../../features/airdrop/data/airdrop_repository.dart';
import '../../features/analytics/data/install_analytics_repository.dart';
import '../../features/asset_detail/data/asset_detail_repository.dart';
import '../../features/auth/data/solana_wallet_service.dart';
import '../../features/auth/data/wallet_repository.dart';
import '../../features/portfolio/data/portfolio_repository.dart';
import '../../features/notifications/presentation/providers/notification_inbox_provider.dart';
import '../../features/settings/data/app_settings_repository.dart';
import '../../features/swap/data/swap_repository.dart';
import '../../features/update/data/app_update_repository.dart';

final secureStoreProvider = Provider<KeyValueStore>((ref) => SecureStore());

final localCipherProvider = Provider<LocalCipher>((ref) => LocalCipher());

final biometricSessionProtectorProvider = Provider<BiometricSessionProtector>((
  ref,
) {
  return const BiometricSessionProtector();
});

final appSettingsRepositoryProvider = Provider<AppSettingsRepository>((ref) {
  return AppSettingsRepository();
});

final walletAuthApiClientProvider = Provider<WalletAuthApiClient>((ref) {
  return WalletAuthApiClient();
});

final backendSessionManagerProvider = Provider<BackendSessionManager>((ref) {
  return BackendSessionManager(
    ref: ref,
    store: ref.read(secureStoreProvider),
    authApiClient: ref.read(walletAuthApiClientProvider),
    mobileWalletAdapterService: ref.read(mobileWalletAdapterServiceProvider),
  );
});

final biometricAuthServiceProvider = Provider<BiometricAuthService>((ref) {
  return BiometricAuthService();
});

final localNotificationServiceProvider = Provider<LocalNotificationService>((
  ref,
) {
  return LocalNotificationService();
});

final appBadgeServiceProvider = Provider<AppBadgeService>((ref) {
  return AppBadgeService();
});

final pushNotificationServiceProvider = Provider<PushNotificationService>((
  ref,
) {
  final service = PushNotificationService(
    store: ref.read(secureStoreProvider),
    apiClient: ref.read(backendApiClientProvider),
    localNotificationService: ref.read(localNotificationServiceProvider),
    onRemoteMessageReceived: (message) {
      return ref
          .read(notificationInboxProvider.notifier)
          .recordRemoteMessage(message);
    },
  );
  ref.onDispose(service.dispose);
  return service;
});

final mobileWalletAdapterServiceProvider = Provider<MobileWalletAdapterService>(
  (ref) => MobileWalletAdapterService(),
);

final seekerVaultAvailableProvider = FutureProvider<bool>((ref) {
  return ref.read(mobileWalletAdapterServiceProvider).isSeedVaultAvailable();
});

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository(
    ref.read(secureStoreProvider),
    ref.read(localCipherProvider),
    ref.read(biometricSessionProtectorProvider),
  );
});

final backendApiClientProvider = Provider<BackendApiClient>((ref) {
  return BackendApiClient(
    sessionManager: ref.read(backendSessionManagerProvider),
  );
});

final solanaWalletServiceProvider = Provider<SolanaWalletService>((ref) {
  return SolanaWalletService(
    backendApiClient: ref.read(backendApiClientProvider),
    sessionManager: ref.read(backendSessionManagerProvider),
  );
});

final portfolioRepositoryProvider = Provider<PortfolioRepository>((ref) {
  return PortfolioRepository(ref.read(backendApiClientProvider));
});

final assetDetailRepositoryProvider = Provider<AssetDetailRepository>((ref) {
  return AssetDetailRepository(ref.read(backendApiClientProvider));
});

final airdropRepositoryProvider = Provider<AirdropRepository>((ref) {
  return AirdropRepository(ref.read(backendApiClientProvider));
});

final installAnalyticsRepositoryProvider = Provider<InstallAnalyticsRepository>(
  (ref) {
    return InstallAnalyticsRepository(
      ref.read(secureStoreProvider),
      ref.read(backendApiClientProvider),
    );
  },
);

final swapRepositoryProvider = Provider<SwapRepository>((ref) {
  return SwapRepository(ref.read(backendApiClientProvider));
});

final appUpdateRepositoryProvider = Provider<AppUpdateRepository>((ref) {
  return AppUpdateRepository(ref.read(backendApiClientProvider));
});

final packageInfoProvider = FutureProvider<PackageInfo>((ref) {
  return PackageInfo.fromPlatform();
});
