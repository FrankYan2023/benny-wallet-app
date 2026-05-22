enum StoreMode { lite, full }

class FeatureReviewItem {
  const FeatureReviewItem({
    required this.label,
    required this.enabled,
    required this.reviewNote,
  });

  final String label;
  final bool enabled;
  final String reviewNote;
}

abstract final class AppFeatures {
  static const _storeModeRaw = String.fromEnvironment(
    'STORE_MODE',
    defaultValue: 'full',
  );

  static StoreMode get storeMode =>
      _storeModeRaw.toLowerCase() == 'lite' ? StoreMode.lite : StoreMode.full;

  static const webviewEnabled = bool.fromEnvironment(
    'FEATURE_WEBVIEW_ENABLED',
    defaultValue: false,
  );

  static const swapEnabled = bool.fromEnvironment(
    'FEATURE_SWAP_ENABLED',
    defaultValue: true,
  );

  static const xstocksEnabled = bool.fromEnvironment(
    'FEATURE_SWAP_XSTOCK_ENABLED',
    defaultValue: true,
  );

  static const tokenExchangeEnabled = bool.fromEnvironment(
    'FEATURE_SWAP_TOKEN_EXCHANGE_ENABLED',
    defaultValue: true,
  );

  static const airdropEnabled = bool.fromEnvironment(
    'FEATURE_AIRDROP_ENABLED',
    defaultValue: true,
  );

  static const defiPortfolioEnabled = bool.fromEnvironment(
    'FEATURE_DEFI_PORTFOLIO_ENABLED',
    defaultValue: true,
  );

  static const defiActionsEnabled = bool.fromEnvironment(
    'FEATURE_DEFI_ACTIONS_ENABLED',
    defaultValue: false,
  );

  static const appUpdatesEnabled = bool.fromEnvironment(
    'FEATURE_APP_UPDATES_ENABLED',
    defaultValue: true,
  );

  static const seekerVaultEnabled = bool.fromEnvironment(
    'FEATURE_SEEKER_VAULT_ENABLED',
    defaultValue: true,
  );

  static bool get isLiteStore => storeMode == StoreMode.lite;

  static bool get canOpenSwap =>
      !isLiteStore && swapEnabled && tokenExchangeEnabled;

  static bool get canOpenXStocks =>
      !isLiteStore && swapEnabled && xstocksEnabled;

  static bool get canOpenAirdrop => airdropEnabled;

  static bool get canOpenDefiPortfolio => defiPortfolioEnabled;

  static bool get canUseDefiActions =>
      defiPortfolioEnabled && defiActionsEnabled;

  static bool get canCheckForUpdates => appUpdatesEnabled;

  static bool get canOpenWebView => webviewEnabled;

  static bool get canConnectSeekerVault => seekerVaultEnabled;

  static String get storeModeLabel =>
      isLiteStore ? 'Lite store review build' : 'Full feature build';

  static List<FeatureReviewItem> get liteReviewItems => [
    const FeatureReviewItem(
      label: 'Create and import wallet',
      enabled: true,
      reviewNote: 'Core self-custody wallet flow remains enabled.',
    ),
    const FeatureReviewItem(
      label: 'Private key storage and local signing',
      enabled: true,
      reviewNote: 'Keys stay on device; transactions are signed natively.',
    ),
    FeatureReviewItem(
      label: 'Seeker Vault',
      enabled: canConnectSeekerVault,
      reviewNote: canConnectSeekerVault
          ? 'Enabled in packages, then gated by Seeker device detection at runtime.'
          : 'Disabled only when the build flag is explicitly false.',
    ),
    const FeatureReviewItem(
      label: 'Biometric unlock',
      enabled: true,
      reviewNote: 'Local unlock convenience for the native wallet.',
    ),
    const FeatureReviewItem(
      label: 'Asset list and receive',
      enabled: true,
      reviewNote: 'Users can view assets and receive funds.',
    ),
    const FeatureReviewItem(
      label: 'Send',
      enabled: true,
      reviewNote: 'Native transfer flow with confirmation UI.',
    ),
    FeatureReviewItem(
      label: 'Swap',
      enabled: canOpenSwap,
      reviewNote: isLiteStore
          ? 'Disabled in Lite builds.'
          : 'Enabled in full builds.',
    ),
    FeatureReviewItem(
      label: 'xStocks',
      enabled: canOpenXStocks,
      reviewNote: isLiteStore
          ? 'Disabled in Lite builds.'
          : 'Enabled in full builds.',
    ),
    FeatureReviewItem(
      label: 'BYC airdrop',
      enabled: canOpenAirdrop,
      reviewNote:
          'Enabled so users can check in and collect BYC points. Buying is disabled in Lite.',
    ),
    FeatureReviewItem(
      label: 'DeFi portfolio',
      enabled: canOpenDefiPortfolio,
      reviewNote: canOpenDefiPortfolio
          ? 'Read-only protocol position display. DeFi actions stay disabled unless explicitly enabled.'
          : 'Disabled by feature flag.',
    ),
    FeatureReviewItem(
      label: 'WebView trading UI',
      enabled: canOpenWebView,
      reviewNote: 'Controlled by feature flag.',
    ),
    FeatureReviewItem(
      label: 'External app update flow',
      enabled: canCheckForUpdates,
      reviewNote: 'Controlled by feature flag.',
    ),
  ];
}
