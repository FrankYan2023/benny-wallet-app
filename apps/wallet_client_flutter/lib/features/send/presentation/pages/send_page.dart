import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../l10n/l10n.dart';
import '../../../auth/presentation/providers/wallet_controller.dart';
import '../../../portfolio/domain/entities/portfolio_view_data.dart';
import '../../../multichain/presentation/chain_widgets.dart';
import '../../../multichain/presentation/network_send_page.dart';
import '../../../multichain/presentation/portfolio_network_widgets.dart';
import '../../../multichain/providers/multichain_providers.dart';
import '../../../portfolio/presentation/providers/portfolio_provider.dart';
import '../../../receive/presentation/pages/receive_page.dart';
import 'send_compose_page.dart';
import 'send_history_page.dart';

class SendPage extends ConsumerStatefulWidget {
  const SendPage({
    super.key,
    this.recipientAddress,
    this.chainId,
    this.assetId,
  });
  final String? chainId;
  final String? assetId;

  static const routeName = 'send';
  static const routePath = '/send';

  static String pathFor({String? recipientAddress}) {
    if (recipientAddress == null || recipientAddress.isEmpty) {
      return routePath;
    }
    return '$routePath?recipient=$recipientAddress';
  }

  final String? recipientAddress;

  @override
  ConsumerState<SendPage> createState() => _SendPageState();
}

class _SendPageState extends ConsumerState<SendPage> {
  late String _chainId;
  bool _busy = false;
  @override
  void initState() {
    super.initState();
    _chainId =
        widget.chainId ??
        ref.read(portfolioNetworkFilterProvider) ??
        ref.read(selectedChainIdProvider);
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletControllerProvider);
    final normalizedRecipient = widget.recipientAddress?.trim();
    final l10n = context.l10n;

    if (walletState.childModeEnabled) {
      return AppScaffold(
        title: l10n.sendTitle,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_rounded, size: 40),
                const SizedBox(height: 12),
                Text(
                  l10n.sendUnavailableChildMode,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => context.go(ReceivePage.routePath),
                  child: Text(l10n.sendOpenReceive),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final primary = ref.watch(usesPrimarySendProvider(_chainId));
    final portfolio = primary
        ? ref.watch(activePortfolioProvider)
        : const AsyncValue<PortfolioViewData>.loading();

    return AppScaffold(
      title: l10n.sendTitle,
      showBackButton: !_busy,
      enableTitleNavigation: !_busy,
      actions: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surface.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(22),
          ),
          child: IconButton(
            tooltip: l10n.sendHistoryTitle,
            onPressed: _busy
                ? null
                : () => context.push(
                    primary ? SendHistoryPage.routePath : networkPath(_chainId),
                  ),
            icon: const Icon(Icons.history_rounded),
          ),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IgnorePointer(
            ignoring: _busy,
            child: ChainNetworkSelector(
              value: _chainId,
              onChanged: (id) => setState(() {
                _chainId = id;
                ref.read(selectedChainIdProvider.notifier).state = id;
              }),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            chainText(
              context,
              'The recipient receives assets on the selected network.',
              '接收方将在所选网络收到资产。',
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: !primary
                ? NetworkSendPage(
                    key: ValueKey(_chainId),
                    chainId: _chainId,
                    assetId: widget.chainId == _chainId ? widget.assetId : null,
                    recipientAddress: normalizedRecipient,
                    embedded: true,
                    onBusyChanged: (busy) {
                      if (mounted) setState(() => _busy = busy);
                    },
                  )
                : portfolio.when(
                    data: (data) {
                      final assets = data.assets
                          .where((asset) => asset.balance > 0)
                          .toList();

                      if (assets.isEmpty) {
                        return Center(child: Text(l10n.sendNoAssets));
                      }

                      return ListView(
                        children: [
                          if (normalizedRecipient != null &&
                              normalizedRecipient.isNotEmpty) ...[
                            WalletCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.sendRecipientPrefilled,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    Formatters.compactAddress(
                                      normalizedRecipient,
                                      visibleChars: 6,
                                    ),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          const SizedBox(height: 6),
                          for (final asset in assets) ...[
                            TokenRow(
                              name: asset.token.name,
                              symbol: Formatters.tokenSymbol(
                                asset.token.symbol,
                              ),
                              balanceLine:
                                  '${Formatters.compactNumber(asset.balance)} ${Formatters.tokenSymbol(asset.token.symbol)}',
                              value: asset.priceQuote == null
                                  ? '--'
                                  : Formatters.usd(asset.totalValueUsd),
                              change: _assetChangeLine(asset),
                              isPositiveChange: _assetChangeDirection(asset),
                              iconUrl: asset.logoUrl,
                              onTap: () => context.push(
                                SendComposePage.pathFor(
                                  asset.token.mintAddress,
                                  recipientAddress: normalizedRecipient,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ],
                      );
                    },
                    error: (error, _) => Center(
                      child: Text(l10n.sendLoadAssetsFailed('$error')),
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                  ),
          ),
        ],
      ),
    );
  }

  static String _assetChangeLine(AssetHolding asset) {
    final changePct = double.tryParse(asset.priceQuote?.change24hPct ?? '');
    if (changePct == null) {
      return '--';
    }

    final deltaUsd = asset.totalValueUsd * (changePct / 100);
    return Formatters.signedUsd(deltaUsd);
  }

  static bool? _assetChangeDirection(AssetHolding asset) {
    final changePct = double.tryParse(asset.priceQuote?.change24hPct ?? '');
    if (changePct == null || changePct == 0) {
      return null;
    }
    return changePct > 0;
  }
}
