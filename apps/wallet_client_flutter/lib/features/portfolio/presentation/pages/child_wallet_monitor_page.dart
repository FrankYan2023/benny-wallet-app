import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/clipboard_utils.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../l10n/l10n.dart';
import '../../../auth/domain/wallet_controller_state.dart';
import '../../../auth/presentation/providers/wallet_controller.dart';
import '../../../send/presentation/pages/send_page.dart';
import '../../domain/entities/portfolio_view_data.dart';
import '../providers/portfolio_provider.dart';

class ChildWalletMonitorPage extends ConsumerWidget {
  const ChildWalletMonitorPage({required this.childId, super.key});

  final String childId;

  static const routeName = 'childWalletMonitor';
  static const routePath = '/portfolio/child-monitor';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletState = ref.watch(walletControllerProvider);

    ChildWallet? foundChild;
    try {
      foundChild = walletState.childWallets.firstWhere(
        (wallet) => wallet.id == childId,
      );
    } catch (_) {
      // Child not found.
    }

    if (foundChild == null) {
      return AppScaffold(
        title: context.l10n.childWalletTitle,
        child: Center(child: Text(context.l10n.childWalletNotFound)),
      );
    }

    final childWallet = foundChild;
    final childPortfolioAsync = ref.watch(
      portfolioProvider(childWallet.address),
    );

    return AppScaffold(
      title: childWallet.name,
      child: childPortfolioAsync.when(
        data: (portfolio) {
          final theme = Theme.of(context);
          final assets = [...portfolio.assets]
            ..sort((left, right) {
              final byValue = right.totalValueUsd.compareTo(left.totalValueUsd);
              if (byValue != 0) {
                return byValue;
              }

              final byBalance = right.balance.compareTo(left.balance);
              if (byBalance != 0) {
                return byBalance;
              }

              return left.token.symbol.compareTo(right.token.symbol);
            });

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(portfolioProvider(childWallet.address));
              await ref.read(portfolioProvider(childWallet.address).future);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          childWallet.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.l10n.childWalletAddress,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                Formatters.compactAddress(
                                  childWallet.address,
                                  visibleChars: 6,
                                ),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                  fontFamily: 'monospace',
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: Icon(
                                Icons.copy_rounded,
                                color: theme.colorScheme.onPrimary,
                              ),
                              onPressed: () async {
                                await ClipboardUtils.setDataWithAutoWipe(
                                  childWallet.address,
                                );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        context.l10n.childAddressCopied,
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Formatters.usd(portfolio.totalValueUsd),
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.l10n.childTotalBalance,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF8A7D6A),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: FilledButton.icon(
                    onPressed: () => context.push(
                      SendPage.pathFor(recipientAddress: childWallet.address),
                    ),
                    icon: const Icon(Icons.send_rounded),
                    label: Text(context.l10n.childSendToChildWallet),
                  ),
                ),
                const SizedBox(height: 24),
                if (assets.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        context.l10n.childNoAssets,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF8A7D6A),
                        ),
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.childAssets,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...assets.map((asset) => _ChildAssetCard(asset: asset)),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(context.l10n.childWalletLoadFailed('$error')),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  ref.invalidate(portfolioProvider(childWallet.address));
                },
                child: Text(context.l10n.commonRetry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChildAssetCard extends StatelessWidget {
  const _ChildAssetCard({required this.asset});

  final AssetHolding asset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFCF9F4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2DBD2)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: _ChildTokenAvatar(
              symbol: Formatters.tokenSymbol(asset.token.symbol),
              iconUrl: asset.logoUrl,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Formatters.tokenSymbol(asset.token.symbol),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${Formatters.compactNumber(asset.balance)} ${Formatters.tokenSymbol(asset.token.symbol)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF8A7D6A),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                asset.priceQuote == null
                    ? '--'
                    : Formatters.usd(asset.totalValueUsd),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 2),
              _AssetMarketLine(asset: asset),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChildTokenAvatar extends StatelessWidget {
  const _ChildTokenAvatar({required this.symbol, this.iconUrl});

  final String symbol;
  final String? iconUrl;

  static const _fallbackIconUrls = {
    'SOL': 'https://assets.coingecko.com/coins/images/4128/large/solana.png',
    'USDC': 'https://assets.coingecko.com/coins/images/6319/large/usdc.png',
    'USDT': 'https://assets.coingecko.com/coins/images/325/large/Tether.png',
    'JITOSOL': 'https://storage.googleapis.com/token-metadata/JitoSOL-256.png',
    'HYPE': 'https://arweave.net/QBRdRop8wI4PpScSRTKyibv-fQuYBua-WOvC7tuJyJo',
    'BYC': 'https://gobennyapp.com/benny_boy.png',
  };

  @override
  Widget build(BuildContext context) {
    final normalizedSymbol = symbol.trim().isEmpty ? '?' : symbol.trim();
    final normalizedUrl = iconUrl?.trim();
    final resolvedUrl = (normalizedUrl == null || normalizedUrl.isEmpty)
        ? _fallbackIconUrls[normalizedSymbol.toUpperCase()]
        : normalizedUrl;

    if (resolvedUrl == null || resolvedUrl.isEmpty) {
      return _LetterAvatar(symbol: normalizedSymbol);
    }

    final isSvg = resolvedUrl.toLowerCase().contains('.svg');
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: isSvg
          ? SvgPicture.network(
              resolvedUrl,
              fit: BoxFit.cover,
              placeholderBuilder: (_) =>
                  _LetterAvatar(symbol: normalizedSymbol),
              errorBuilder: (_, _, _) =>
                  _LetterAvatar(symbol: normalizedSymbol),
            )
          : Image.network(
              resolvedUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  _LetterAvatar(symbol: normalizedSymbol),
            ),
    );
  }
}

class _LetterAvatar extends StatelessWidget {
  const _LetterAvatar({required this.symbol});

  final String symbol;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          symbol.substring(0, 1).toUpperCase(),
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _AssetMarketLine extends StatelessWidget {
  const _AssetMarketLine({required this.asset});

  final AssetHolding asset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondaryTextColor = const Color(0xFF8A7D6A);
    final priceLine = _normalizeDetailText(_assetPriceLine(asset));
    final changeLine = _normalizeDetailText(_assetChangePctLine(asset));
    final changeColor = _assetChangeColor(asset);

    if (priceLine == null && changeLine == null) {
      return Text(
        '--',
        style: theme.textTheme.bodySmall?.copyWith(
          color: secondaryTextColor,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    if (priceLine == null) {
      return Text(
        changeLine!,
        style: theme.textTheme.bodySmall?.copyWith(
          color: changeColor,
          fontWeight: FontWeight.w700,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    if (changeLine == null) {
      return Text(
        priceLine,
        style: theme.textTheme.bodySmall?.copyWith(
          color: secondaryTextColor,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: priceLine,
            style: theme.textTheme.bodySmall?.copyWith(
              color: secondaryTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(
            text: '  $changeLine',
            style: theme.textTheme.bodySmall?.copyWith(
              color: changeColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  String _assetPriceLine(AssetHolding asset) {
    final priceUsd = double.tryParse(asset.priceQuote?.priceUsd ?? '');
    if (priceUsd == null) {
      return '--';
    }

    return Formatters.usdPrice(priceUsd);
  }

  String _assetChangePctLine(AssetHolding asset) {
    final changePct = double.tryParse(asset.priceQuote?.change24hPct ?? '');
    if (changePct == null) {
      return '--';
    }

    return Formatters.percent(changePct, signed: true);
  }

  Color _assetChangeColor(AssetHolding asset) {
    final changePct = double.tryParse(asset.priceQuote?.change24hPct ?? '');
    if (changePct == null || changePct == 0) {
      return const Color(0xFF8A7D6A);
    }

    return changePct > 0 ? const Color(0xFF30A46C) : const Color(0xFFE2562A);
  }

  String? _normalizeDetailText(String? value) {
    if (value == null) {
      return null;
    }

    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed == '--') {
      return null;
    }

    return trimmed;
  }
}
