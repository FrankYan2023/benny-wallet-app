import '../../../core/widgets/wallet_dropdown.dart';
import '../../../core/widgets/network_badge.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/chains/chain_models.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/presentation/providers/wallet_controller.dart';
import '../providers/multichain_providers.dart';
import 'chain_widgets.dart';

/// null means the asset-first view across every configured network.
final portfolioNetworkFilterProvider = StateProvider<String?>((ref) => null);
final showPrimaryPortfolioProvider = Provider<bool>((ref) {
  final filter = ref.watch(portfolioNetworkFilterProvider);
  return filter == null || filter == ref.watch(chainConfigsProvider).first.id;
});
final visibleAdditionalNetworksProvider = Provider<List<ChainConfig>>((ref) {
  final filter = ref.watch(portfolioNetworkFilterProvider);
  return ref
      .watch(additionalChainConfigsProvider)
      .where((config) => filter == null || filter == config.id)
      .toList();
});

class AdditionalPortfolioValue {
  const AdditionalPortfolioValue({
    this.usd = 0,
    this.loading = false,
    this.unavailable = false,
    this.unpriced = false,
    this.hasHoldings = false,
    this.hasData = false,
  });
  final double usd;
  final bool loading, unavailable, unpriced, hasHoldings, hasData;
  bool get incomplete => loading || unavailable || unpriced;
}

final additionalPortfolioValueProvider = Provider<AdditionalPortfolioValue>((
  ref,
) {
  var usd = 0.0,
      loading = false,
      unavailable = false,
      unpriced = false,
      hasHoldings = false,
      hasData = false;
  for (final config in ref.watch(visibleAdditionalNetworksProvider)) {
    if (config.isTestnet) continue;
    final result = ref.watch(chainAssetsProvider(config.id));
    loading = loading || result.isLoading;
    unavailable = unavailable || result.hasError;
    final assets = result.valueOrNull;
    hasData = hasData || assets != null;
    for (final asset in assets ?? <ChainAsset>[]) {
      if (!asset.balanceAvailable) {
        unavailable = true;
        continue;
      }
      if (asset.rawBalance == BigInt.zero) continue;
      hasHoldings = true;
      final price = asset.fiatPrice;
      final balance = double.tryParse(asset.balanceText);
      final value = price == null || balance == null ? null : price * balance;
      if (value == null || !value.isFinite || value < 0) {
        unpriced = true;
      } else {
        usd += value;
      }
    }
  }
  return AdditionalPortfolioValue(
    usd: usd,
    loading: loading,
    unavailable: unavailable,
    unpriced: unpriced,
    hasHoldings: hasHoldings,
    hasData: hasData,
  );
});

final usesPrimarySendProvider = Provider.family<bool, String>(
  (ref, id) => id == ref.watch(chainConfigsProvider).first.id,
);

String walletSendPath(String chainId, {String? assetId, String? recipient}) =>
    Uri(
      path: '/send',
      queryParameters: {
        'network': chainId,
        if (assetId != null) 'asset': assetId,
        if (recipient != null) 'recipient': recipient,
      },
    ).toString();
String walletAssetPath(ChainAsset asset) => Uri(
  path: '/asset/${asset.contractAddress ?? 'native'}',
  queryParameters: {'network': asset.chainId, 'asset': asset.id},
).toString();

class PortfolioNetworkMenu extends ConsumerWidget {
  const PortfolioNetworkMenu({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(portfolioNetworkFilterProvider);
    final configs = ref.watch(chainConfigsProvider);
    final config = selected == null ? null : findChain(configs, selected);
    final theme = Theme.of(context);
    const menuWidth = 120.0;
    return SizedBox(
      width: menuWidth,
      child: WalletDropdown<String>(
        key: const Key('portfolio-network-menu'),
        tooltip:
            '${chainText(context, 'Choose networks', '选择网络')}: '
            '${config?.displayName ?? chainText(context, 'All networks', '全部网络')}',
        menuPadding: const EdgeInsets.all(4),
        onSelected: (value) {
          ref.read(portfolioNetworkFilterProvider.notifier).state =
              value == 'all' ? null : value;
          if (value != 'all')
            ref.read(selectedChainIdProvider.notifier).state = value;
        },
        itemBuilder: (_) => [
          for (final id in ['all', ...configs.map((item) => item.id)])
            PopupMenuItem<String>(
              value: id,
              height: 56,
              padding: EdgeInsets.zero,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: id == (selected ?? 'all')
                      ? theme.colorScheme.primary.withValues(alpha: .08)
                      : null,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    NetworkIcon(
                      iconAsset: id == 'all'
                          ? null
                          : findChain(configs, id)?.iconAsset,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        id == 'all'
                            ? chainText(context, 'All networks', '全部网络')
                            : findChain(configs, id)!.displayName,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    if (id == (selected ?? 'all')) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          width: menuWidth,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .18),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (config == null)
                Icon(
                  Icons.public_rounded,
                  key: const Key('portfolio-all-networks-icon'),
                  size: 24,
                  color: Theme.of(context).colorScheme.onPrimary,
                )
              else ...[
                NetworkIcon(iconAsset: config.iconAsset, size: 20),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    config.displayName.split(' ').first,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 4),
              Icon(
                Icons.expand_more_rounded,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WalletAssetsHeading extends ConsumerWidget {
  const WalletAssetsHeading({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Row(
    children: [
      Expanded(
        child: Text(
          chainText(context, 'Assets', '资产'),
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      if (!ref.watch(walletControllerProvider).childModeEnabled)
        IconButton(
          tooltip: chainText(context, 'Import token', '导入代币'),
          onPressed: () {
            final available = ref.read(additionalChainConfigsProvider);
            final selected = ref.read(portfolioNetworkFilterProvider);
            final config =
                findChain(available, selected ?? '') ?? available.first;
            context.push('${networkPath(config.id)}/import-token');
          },
          icon: const Icon(Icons.add_rounded),
        ),
    ],
  );
}

/// Individual rows use the same TokenRow as the primary portfolio. No separate
/// network card, network wallet, or separate send/receive entry is presented.
class AdditionalAssetRows extends ConsumerWidget {
  const AdditionalAssetRows({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Column(
    children: [
      for (final config in ref.watch(visibleAdditionalNetworksProvider))
        ref
            .watch(chainAssetsProvider(config.id))
            .when(
              loading: () => ListTile(
                title: NetworkBadge.fromConfig(config, compact: false),
                subtitle: const LinearProgressIndicator(),
              ),
              error: (error, _) => ListTile(
                title: NetworkBadge.fromConfig(config, compact: false),
                subtitle: Text('$error'),
                trailing: IconButton(
                  tooltip: chainText(context, 'Retry', '重试'),
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: () =>
                      ref.invalidate(chainAccountProvider(config.id)),
                ),
              ),
              data: (assets) => Column(
                children: [
                  for (final asset in assets) ...[
                    TokenRow(
                      name: asset.name,
                      symbol: asset.symbol,
                      change: '--',
                      isPositiveChange: null,
                      balanceLine: '${asset.balanceText} ${asset.symbol}',
                      networkLabel: config.displayName,
                      networkIconAsset: config.iconAsset,
                      value: config.isTestnet
                          ? chainText(context, 'Testnet', '测试网')
                          : !asset.balanceAvailable || asset.fiatPrice == null
                          ? '--'
                          : Formatters.usd(
                              double.parse(asset.balanceText) *
                                  asset.fiatPrice!,
                            ),
                      secondaryValue: config.isTestnet
                          ? chainText(context, 'Excluded from total', '不计入总额')
                          : !asset.balanceAvailable ||
                                asset.fiatPrice == null &&
                                    asset.rawBalance > BigInt.zero
                          ? chainText(context, 'Price unavailable', '暂无价格')
                          : null,
                      iconUrl: asset.logoUrl,
                      onTap: () => context.push(walletAssetPath(asset)),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
    ],
  );
}
