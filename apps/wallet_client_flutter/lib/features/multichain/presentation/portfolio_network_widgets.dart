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
    return PopupMenuButton<String>(
      key: const Key('portfolio-network-menu'),
      tooltip: chainText(context, 'Choose networks', '选择网络'),
      initialValue: selected ?? 'all',
      onSelected: (value) {
        ref.read(portfolioNetworkFilterProvider.notifier).state = value == 'all'
            ? null
            : value;
        if (value != 'all')
          ref.read(selectedChainIdProvider.notifier).state = value;
      },
      itemBuilder: (_) => [
        CheckedPopupMenuItem(
          value: 'all',
          checked: selected == null,
          child: Text(chainText(context, 'All networks', '全部网络')),
        ),
        for (final item in configs)
          CheckedPopupMenuItem(
            value: item.id,
            checked: selected == item.id,
            child: Text(item.displayName),
          ),
      ],
      child: Container(
        constraints: const BoxConstraints(minHeight: 44, maxWidth: 92),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .18),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                config?.displayName.split(' ').first ??
                    chainText(context, 'All', '全部'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Icon(
              Icons.expand_more_rounded,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 20,
            ),
          ],
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
                title: Text(config.displayName),
                subtitle: const LinearProgressIndicator(),
              ),
              error: (error, _) => ListTile(
                title: Text(config.displayName),
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
                          : asset.fiatPrice == null
                          ? '--'
                          : Formatters.usd(
                              double.parse(asset.balanceText) *
                                  asset.fiatPrice!,
                            ),
                      secondaryValue: config.isTestnet
                          ? chainText(context, 'Excluded from total', '不计入总额')
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
