import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_types/shared_types.dart';

import '../../../../app/di/providers.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/config/app_features.dart';
import '../../../../core/utils/clipboard_utils.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../l10n/l10n.dart';
import '../../../auth/presentation/providers/wallet_controller.dart';
import '../../../dapp_connect/presentation/open_link.dart';
import '../../../dapp_connect/presentation/pages/dapp_browser_page.dart';
import '../../../portfolio/domain/entities/portfolio_view_data.dart';
import '../../../portfolio/presentation/providers/portfolio_provider.dart';
import '../../../receive/presentation/pages/receive_page.dart';
import '../../../send/presentation/pages/send_page.dart';
import '../../../swap/presentation/pages/swap_page.dart';
import '../../../transaction_history/domain/transaction_activity.dart';
import '../../domain/asset_detail_view_data.dart';
import '../../domain/stock_profile.dart';
import '../../domain/token_profile.dart';
import '../widgets/kline_card.dart';

final tokenDetailProvider = FutureProvider.family<AssetDetailViewData, String>((
  ref,
  mintAddress,
) async {
  return ref.read(assetDetailRepositoryProvider).loadTokenDetail(mintAddress);
});

typedef StockProfileRequest = ({String mintAddress, String language});

final stockProfileProvider = FutureProvider.autoDispose
    .family<StockProfile?, StockProfileRequest>((ref, request) {
      return ref
          .read(assetDetailRepositoryProvider)
          .loadStockProfile(request.mintAddress, language: request.language);
    });

final tokenProfileProvider = FutureProvider.autoDispose
    .family<TokenProfile?, StockProfileRequest>((ref, request) {
      return ref
          .read(assetDetailRepositoryProvider)
          .loadTokenProfile(request.mintAddress, language: request.language);
    });

/// A token's transfers and swaps in one wallet: the open wallet's, or a
/// child account's when a parent looks at it.
typedef AssetActivityRequest = ({String owner, String mint, String symbol});

final assetTransactionsProvider =
    FutureProvider.family<List<TransactionActivity>, AssetActivityRequest>((
      ref,
      request,
    ) {
      return ref
          .read(assetDetailRepositoryProvider)
          .loadTokenActivity(
            ownerAddress: request.owner,
            mintAddress: request.mint,
            symbol: request.symbol,
            limit: 10,
          );
    });

/// How a detail page was opened when the token is not simply one of the
/// open wallet's holdings.
class AssetDetailArgs {
  const AssetDetailArgs({
    this.holding,
    this.ownerAddress,
    this.symbol,
    this.name,
    this.logoUrl,
    this.category,
  });

  /// Someone else's holding (a child account's), shown read-only.
  final AssetHolding? holding;

  /// Whose activity to list with [holding].
  final String? ownerAddress;

  /// For a token the wallet does not hold (opened from the whitelist).
  final String? symbol;
  final String? name;
  final String? logoUrl;
  final String? category;
}

class AssetDetailPage extends ConsumerWidget {
  const AssetDetailPage({super.key, required this.mintAddress, this.args});

  static const routeName = 'assetDetail';
  static const routePath = '/asset/:mint';

  static String pathFor(String mintAddress) => '/asset/$mintAddress';

  final String mintAddress;
  final AssetDetailArgs? args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletState = ref.watch(walletControllerProvider);
    final l10n = context.l10n;
    final isChildMode = walletState.childModeEnabled;
    final portfolio = ref.watch(activePortfolioProvider);
    final tokenDetail = ref.watch(tokenDetailProvider(mintAddress));

    return AppScaffold(
      title: '',
      showTopBar: false,
      // The chart runs edge to edge; everything else pads itself.
      horizontalPadding: 0,
      child: portfolio.when(
        data: (data) {
          final detail = tokenDetail.valueOrNull;
          final shared = args?.holding;
          final owned = shared ?? _findAsset(data.assets, mintAddress);
          // A child's holding is only looked at; a token the wallet does not
          // hold (from the whitelist) has no position to show.
          final readOnly = shared != null;
          final held = owned != null;
          final asset =
              owned ??
              AssetHolding(
                token: TokenInfo(
                  mintAddress: mintAddress,
                  symbol: args?.symbol ?? detail?.symbol ?? '',
                  name: args?.name ?? detail?.name ?? '',
                  decimals: 0,
                  isNative: false,
                  isVisible: true,
                ),
                category: args?.category ?? '',
                balance: 0,
                priceQuote: null,
                totalValueUsd: 0,
                existsOnChain: false,
                logoUrl: args?.logoUrl ?? detail?.logoUrl,
              );
          final owner = readOnly
              ? args?.ownerAddress
              : walletState.publicKey ?? data.address;
          final transactions = owner == null
              ? const AsyncValue<List<TransactionActivity>>.data([])
              : ref.watch(
                  assetTransactionsProvider((
                    owner: owner,
                    mint: mintAddress,
                    symbol: asset.token.symbol,
                  )),
                );
          final detailError = tokenDetail.asError?.error;
          final priceUsd =
              detail?.priceUsd ??
              double.tryParse(asset.priceQuote?.priceUsd ?? '');
          final priceChangePct =
              detail?.change24hPct ??
              double.tryParse(asset.priceQuote?.change24hPct ?? '');
          final profitLoss24h = priceChangePct == null
              ? null
              : asset.totalValueUsd * (priceChangePct / 100);
          final websiteUrl = _normalizeWebsiteUrl(detail?.websiteUrl);
          final showMarketStatsUnavailableNotice =
              detailError != null && priceUsd == null && priceChangePct == null;
          final primaryAction = _primaryActionForAsset(context, asset);
          final isStock = asset.category == 'xstock';
          final name = _displayName(
            detail?.name ?? asset.token.name,
            asset.category,
          );

          final symbol = detail?.symbol ?? asset.token.symbol;
          final stockProfile = isStock
              ? ref
                    .watch(
                      stockProfileProvider(
                        _profileRequest(context, mintAddress),
                      ),
                    )
                    .valueOrNull
              : null;

          // The overview tab opens on the holding, then the figures, then
          // (for xStocks) the token's own on-chain figures.
          final positionSections = <Widget>[
            _SectionLabel(title: l10n.assetPosition),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    label: l10n.assetValue,
                    value: Formatters.usd(asset.totalValueUsd),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    label: l10n.assetBalance,
                    value:
                        '${Formatters.compactNumber(asset.balance)} ${Formatters.tokenSymbol(detail?.symbol ?? asset.token.symbol)}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _MetricCard(
              label: l10n.assetReturn24h,
              value: profitLoss24h == null
                  ? '--'
                  : Formatters.signedUsd(profitLoss24h),
              trailing: priceChangePct == null
                  ? null
                  : Text(
                      Formatters.percent(priceChangePct, signed: true),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _deltaColor(context, priceChangePct),
                      ),
                    ),
              emphasizeColor: priceChangePct == null
                  ? null
                  : _deltaColor(context, priceChangePct),
            ),
          ];
          final tokenInfoSections = <Widget>[
            if (isStock) ...[
              const SizedBox(height: 18),
              _SectionLabel(title: l10n.assetInfo),
              const SizedBox(height: 10),
              _InfoPanel(
                rows: [
                  _InfoRowData(l10n.assetName, name),
                  _InfoRowData(
                    l10n.assetSymbol,
                    detail?.symbol ?? asset.token.symbol,
                  ),
                  _InfoRowData(
                    l10n.commonNetwork,
                    detail?.network ?? l10n.commonSolana,
                  ),
                  _InfoRowData(
                    l10n.assetMint,
                    Formatters.compactAddress(mintAddress, visibleChars: 5),
                  ),
                  if (websiteUrl != null)
                    _InfoRowData(
                      l10n.assetWebsite,
                      _websiteDisplayText(websiteUrl),
                      linkUrl: websiteUrl,
                    ),
                  _InfoRowData(
                    l10n.assetPrice,
                    priceUsd == null ? '--' : Formatters.usdPrice(priceUsd),
                  ),
                  _InfoRowData(
                    l10n.assetMarketCap,
                    Formatters.compactUsd(detail?.marketCapUsd),
                  ),
                  _InfoRowData(
                    l10n.assetFdv,
                    Formatters.compactUsd(detail?.fdvUsd),
                  ),
                  _InfoRowData(
                    l10n.assetTotalSupply,
                    Formatters.compactNumber(detail?.totalSupply),
                  ),
                  _InfoRowData(
                    l10n.assetCirculatingSupply,
                    Formatters.compactNumber(detail?.circulatingSupply),
                  ),
                  _InfoRowData(
                    l10n.assetHolders,
                    detail?.holderCount == null
                        ? '--'
                        : Formatters.compactNumber(
                            detail!.holderCount!.toDouble(),
                          ),
                  ),
                  _InfoRowData(
                    l10n.assetCreated,
                    _formatDate(l10n, detail?.createdAt),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _SectionLabel(title: l10n.assetPerformance24h),
              const SizedBox(height: 10),
              _InfoPanel(
                rows: [
                  _InfoRowData(
                    l10n.assetVolume,
                    Formatters.compactUsd(detail?.volume24hUsd),
                  ),
                  _InfoRowData(
                    l10n.assetTraders,
                    detail?.traderCount24h == null
                        ? '--'
                        : Formatters.compactNumber(
                            detail!.traderCount24h!.toDouble(),
                          ),
                  ),
                ],
              ),
              if (detail?.top10HoldersPct != null) ...[
                const SizedBox(height: 18),
                _SectionLabel(title: l10n.assetSafety),
                const SizedBox(height: 10),
                _InfoPanel(
                  rows: [
                    _InfoRowData(
                      l10n.assetTop10Holders,
                      Formatters.percent(detail!.top10HoldersPct),
                    ),
                  ],
                ),
              ],
              if (showMarketStatsUnavailableNotice) ...[
                const SizedBox(height: 18),
                _InlineNotice(message: l10n.assetMarketStatsUnavailable),
              ],
            ],
            const SizedBox(height: 12),
          ];

          final activity = transactions.when(
            data: (items) {
              if (items.isEmpty) {
                return _EmptyState(message: l10n.assetNoActivity);
              }

              return Column(
                children: [
                  for (final item in items) ...[
                    _ActivityCard(item: item),
                    const SizedBox(height: 12),
                  ],
                ],
              );
            },
            error: (_, _) =>
                _InlineNotice(message: l10n.assetActivityLoadFailed),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(child: CircularProgressIndicator()),
            ),
          );

          final header = <Widget>[
            _withMargin(
              _HeaderBar(
                name: name,
                symbol: Formatters.tokenSymbol(symbol),
                mintAddress: mintAddress,
                logoUrl: detail?.logoUrl ?? asset.logoUrl,
                onCopy: () => _copyMint(context, mintAddress),
                // Child mode can only receive, which keeps its own button; a
                // child's holding is only looked at; a token not held can be
                // bought but not sent.
                actions: isChildMode || readOnly
                    ? const []
                    : [
                        _MenuAction(
                          icon: primaryAction.icon,
                          label: primaryAction.label,
                          onTap: primaryAction.onTap,
                        ),
                        if (held)
                          _MenuAction(
                            icon: Icons.send_rounded,
                            label: l10n.portfolioSend,
                            onTap: () => context.push(SendPage.routePath),
                          ),
                      ],
              ),
            ),
            const SizedBox(height: 18),
            if (isChildMode && !readOnly) ...[
              _ChildModeActionRow(
                onReceive: () => context.push(ReceivePage.routePath),
              ),
              const SizedBox(height: 18),
            ],
            _withMargin(
              _QuoteRow(
                isStock: isStock,
                stockProfile: stockProfile,
                detail: detail,
                priceUsd: priceUsd,
                changePct: priceChangePct,
              ),
            ),
            const SizedBox(height: 14),
            // The chart is always on screen, between the price and the tabs.
            KlineCard(mintAddress: mintAddress, framed: false),
            const SizedBox(height: 10),
          ];

          return _AssetTabsView(
            mintAddress: mintAddress,
            isStock: isStock,
            header: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: header,
            ),
            overview: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (held) ...[...positionSections, const SizedBox(height: 18)],
                if (isStock)
                  _StockOverviewTab(mintAddress: mintAddress)
                else
                  _CoinOverviewTab(
                    mintAddress: mintAddress,
                    symbol: Formatters.tokenSymbol(symbol),
                    detail: detail,
                    websiteUrl: websiteUrl,
                    statsUnavailable: showMarketStatsUnavailableNotice,
                  ),
                ...tokenInfoSections,
              ],
            ),
            activity: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: activity,
            ),
          );
        },
        error: (error, _) =>
            Center(child: Text(context.l10n.assetLoadDetailsFailed('$error'))),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  static AssetHolding? _findAsset(
    List<AssetHolding> assets,
    String mintAddress,
  ) {
    for (final asset in assets) {
      if (asset.token.mintAddress == mintAddress) {
        return asset;
      }
    }
    return null;
  }

  static Future<void> _copyMint(
    BuildContext context,
    String mintAddress,
  ) async {
    await ClipboardUtils.setDataWithAutoWipe(
      mintAddress,
      clearDelay: ClipboardUtils.addressClearDelay,
    );
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.assetMintCopied)));
  }

  static Color _deltaColor(BuildContext context, double value) {
    return PriceTrendColors.of(
      context,
    ).forChange(value, neutral: Theme.of(context).colorScheme.onSurface);
  }

  static _AssetPrimaryAction _primaryActionForAsset(
    BuildContext context,
    AssetHolding asset,
  ) {
    if (!AppFeatures.canOpenSwap) {
      return _AssetPrimaryAction.receive(
        context.l10n.portfolioReceive,
        () => context.push(ReceivePage.routePath),
      );
    }

    if (asset.category == 'xstock') {
      if (!AppFeatures.canOpenXStocks) {
        return _AssetPrimaryAction.receive(
          context.l10n.portfolioReceive,
          () => context.push(ReceivePage.routePath),
        );
      }
      return _AssetPrimaryAction.swap(
        context.l10n.portfolioSwap,
        () => context.push(
          XStocksSwapPage.pathFor(outputMint: asset.token.mintAddress),
        ),
      );
    }

    return _AssetPrimaryAction.swap(
      context.l10n.portfolioSwap,
      () => context.push(SwapPage.pathFor(outputMint: asset.token.mintAddress)),
    );
  }
}

class _AssetPrimaryAction {
  const _AssetPrimaryAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  factory _AssetPrimaryAction.receive(String label, VoidCallback onTap) {
    return _AssetPrimaryAction(
      icon: Icons.call_received_rounded,
      label: label,
      onTap: onTap,
    );
  }

  factory _AssetPrimaryAction.swap(String label, VoidCallback onTap) {
    return _AssetPrimaryAction(
      icon: Icons.swap_horiz_rounded,
      label: label,
      onTap: onTap,
    );
  }

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

/// The page's side margin, for everything but the edge-to-edge chart.
Widget _withMargin(Widget child) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: child,
  );
}

/// xStock names carry the issuer's suffix ("Apple xStock"); the page names
/// the company itself.
String _displayName(String name, String category) {
  if (category != 'xstock') {
    return name;
  }
  final trimmed = name
      .replaceFirst(RegExp(r'\s+(xStock|PreStocks)$', caseSensitive: false), '')
      .trim();
  return trimmed.isEmpty ? name : trimmed;
}

String? _normalizeWebsiteUrl(String? value) {
  if (value == null) {
    return null;
  }

  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return null;
  }

  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return trimmed;
  }

  return 'https://$trimmed';
}

String _websiteDisplayText(String url) {
  final uri = Uri.tryParse(url);
  final host = uri?.host;
  if (host != null && host.isNotEmpty) {
    return host.replaceFirst(RegExp(r'^www\.'), '');
  }

  return url;
}

/// Links open in a tab of Benny's browser (see [openLinkInApp]).
Future<void> _openWebsite(BuildContext context, String url) async {
  final didLaunch = await openLinkInApp(context, url);
  if (!didLaunch && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.assetCouldNotOpenWebsite)),
    );
  }
}

String _formatDate(AppLocalizations l10n, DateTime? value) {
  if (value == null) {
    return '--';
  }
  return DateFormat.yMMMd(l10n.localeName).format(value.toLocal());
}

String _relativeTime(AppLocalizations l10n, DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inSeconds < 60) {
    return l10n.relativeSecondsAgo(diff.inSeconds);
  }
  if (diff.inMinutes < 60) {
    return l10n.relativeMinutesAgo(diff.inMinutes);
  }
  if (diff.inHours < 24) {
    return l10n.relativeHoursAgo(diff.inHours);
  }
  return l10n.relativeDaysAgo(diff.inDays);
}

class _HeaderBar extends StatelessWidget {
  const _HeaderBar({
    required this.name,
    required this.symbol,
    required this.mintAddress,
    required this.onCopy,
    required this.actions,
    this.logoUrl,
  });

  final String name;
  final String symbol;
  final String mintAddress;
  final String? logoUrl;
  final VoidCallback onCopy;

  /// Swap and send, behind the "more" button.
  final List<_MenuAction> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Row(
      children: [
        _RoundIconButton(
          icon: Icons.arrow_back_rounded,
          onTap: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        const SizedBox(width: 10),
        _TokenLogo(symbol: symbol, iconUrl: logoUrl, size: 46),
        const SizedBox(width: 10),
        // The name, and under it the symbol with the token's address (tap
        // to copy it).
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Semantics(
                button: true,
                label: l10n.assetCopyAddress,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onCopy,
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          '$symbol · ${Formatters.compactAddress(mintAddress, visibleChars: 5)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.copy_rounded,
                        size: 15,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        if (actions.isEmpty)
          const SizedBox(width: 44)
        else
          _MoreActionsButton(actions: actions),
      ],
    );
  }
}

/// The price with its change on the left, the four figures people look at
/// first on the right.
class _QuoteRow extends StatelessWidget {
  const _QuoteRow({
    required this.isStock,
    required this.stockProfile,
    required this.detail,
    required this.priceUsd,
    required this.changePct,
  });

  final bool isStock;
  final StockProfile? stockProfile;
  final AssetDetailViewData? detail;
  final double? priceUsd;
  final double? changePct;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final profile = stockProfile;
    final quote = profile?.price;

    final Widget price;
    if (profile != null && quote != null) {
      // An xStock shows its listed stock's quote and session.
      final change = profile.change;
      price = _PriceBlock(
        price: _stockMoney(profile, quote),
        change: change == null
            ? null
            : '${change > 0
                      ? '+'
                      : change < 0
                      ? '-'
                      : ''}'
                  '${_stockMoney(profile, change.abs())}',
        changePct: profile.changePct,
        caption: _stockSessionLine(l10n, profile),
      );
    } else if (priceUsd != null) {
      final pct = changePct;
      // The day's change in dollars, from today's price and percentage.
      final change = pct != null && pct > -100
          ? priceUsd! * pct / (100 + pct)
          : null;
      price = _PriceBlock(
        price: Formatters.usdPrice(priceUsd!),
        change: change == null ? null : Formatters.signedUsd(change),
        changePct: pct,
        caption: pct == null ? null : l10n.coinChange24h,
      );
    } else {
      price = Text(
        '--',
        style: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      );
    }

    final detail = this.detail;
    final figures = isStock
        ? <(String, String)>[
            (l10n.stockMarketCap, Formatters.compactUsd(profile?.marketCap)),
            (
              l10n.stockPeRatio,
              profile?.peRatio?.toStringAsFixed(2) ??
                  (profile?.epsTtm != null && profile!.epsTtm! <= 0
                      ? l10n.stockLoss
                      : '--'),
            ),
            (l10n.stockVolume, Formatters.compactNumber(profile?.volume)),
            (
              l10n.stock52wHigh,
              profile == null
                  ? '--'
                  : _stockMoney(profile, profile.fiftyTwoWeekHigh),
            ),
          ]
        : <(String, String)>[
            (l10n.assetMarketCap, Formatters.compactUsd(detail?.marketCapUsd)),
            (l10n.coinLiquidity, Formatters.compactUsd(detail?.liquidityUsd)),
            (
              l10n.assetHolders,
              Formatters.compactNumber(detail?.holderCount?.toDouble()),
            ),
            (l10n.coinVolume24h, Formatters.compactUsd(detail?.volume24hUsd)),
          ];

    // Centred, so a price without a change (a coin nobody traded today)
    // sits level with the figures instead of leaving a gap under it.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(flex: 11, child: price),
        const SizedBox(width: 14),
        Expanded(
          flex: 9,
          child: Column(
            children: [
              for (final (label, value) in figures)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.5),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        value,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MenuAction {
  const _MenuAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class _MoreActionsButton extends StatelessWidget {
  const _MoreActionsButton({required this.actions});

  final List<_MenuAction> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: PopupMenuButton<int>(
        tooltip: context.l10n.assetMoreActions,
        icon: const Icon(Icons.more_horiz_rounded, size: 20),
        position: PopupMenuPosition.under,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        onSelected: (index) => actions[index].onTap(),
        itemBuilder: (context) => [
          for (var index = 0; index < actions.length; index++)
            PopupMenuItem<int>(
              value: index,
              child: Row(
                children: [
                  Icon(actions[index].icon, size: 20, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Text(actions[index].label),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ChildModeActionRow extends StatelessWidget {
  const _ChildModeActionRow({required this.onReceive});

  final VoidCallback onReceive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SizedBox(
        width: 140,
        child: _ActionTile(
          icon: Icons.call_received_rounded,
          label: context.l10n.portfolioReceive,
          onTap: onReceive,
          tint: theme.colorScheme.secondaryContainer,
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.tint,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.03),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
              child: Icon(icon, color: AppColors.primary, size: 19),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    this.trailing,
    this.emphasizeColor,
  });

  final String label;
  final String value;
  final Widget? trailing;
  final Color? emphasizeColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WalletCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontSize: 20,
                    color: emphasizeColor ?? AppColors.textPrimary,
                  ),
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 12), trailing!],
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.rows});

  final List<_InfoRowData> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          for (var index = 0; index < rows.length; index++) ...[
            _InfoRow(data: rows[index]),
            if (index != rows.length - 1)
              Divider(
                height: 1,
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
          ],
        ],
      ),
    );
  }
}

class _InfoRowData {
  const _InfoRowData(this.label, this.value, {this.linkUrl});

  final String label;
  final String value;
  final String? linkUrl;
}

/// A name on the left at its own width, the value filling the rest on the
/// right (two lines at most); links show in the accent color with an
/// outbound mark.
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.data});

  final _InfoRowData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final link = data.linkUrl;
    final valueStyle = theme.textTheme.bodyLarge?.copyWith(
      fontWeight: FontWeight.w600,
      height: 1.35,
      color: link == null
          ? AppColors.textPrimary
          : theme.colorScheme.primary,
    );
    final value = Text(
      data.value,
      textAlign: TextAlign.end,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: valueStyle,
    );

    return InkWell(
      onTap: link == null ? null : () => _openWebsite(context, link),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 120),
              child: Text(
                data.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.35,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: link == null
                  ? value
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(child: value),
                        const SizedBox(width: 4),
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Icon(
                            Icons.north_east_rounded,
                            size: 15,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.item});

  final TransactionActivity item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final swapTitle = switch (item.direction) {
      TransactionDirection.sent =>
        item.relatedSymbol.isEmpty
            ? l10n.assetSwapOut
            : l10n.assetToSymbol(item.relatedSymbol),
      TransactionDirection.received =>
        item.relatedSymbol.isEmpty
            ? l10n.assetSwapIn
            : l10n.assetFromSymbol(item.relatedSymbol),
      TransactionDirection.unknown => l10n.portfolioSwap,
    };
    final title = switch ((item.kind, item.direction)) {
      (TransactionKind.swap, _) => swapTitle,
      (_, TransactionDirection.sent) => l10n.assetSent,
      (_, TransactionDirection.received) => l10n.assetReceived,
      (_, TransactionDirection.unknown) => l10n.assetActivity,
    };
    final amountColor = switch (item.direction) {
      TransactionDirection.sent => AppColors.danger,
      TransactionDirection.received => AppColors.success,
      TransactionDirection.unknown => AppColors.textPrimary,
    };
    final icon = switch ((item.kind, item.direction)) {
      (TransactionKind.swap, _) => Icons.swap_horiz_rounded,
      (_, TransactionDirection.sent) => Icons.north_east_rounded,
      (_, TransactionDirection.received) => Icons.south_west_rounded,
      (_, TransactionDirection.unknown) => Icons.repeat_rounded,
    };
    final subtitle = switch (item.kind) {
      TransactionKind.swap =>
        item.timestamp == null
            ? l10n.portfolioSwap
            : l10n.assetSwapWithTime(_relativeTime(l10n, item.timestamp!)),
      TransactionKind.transfer =>
        item.counterparty.isEmpty
            ? (item.timestamp == null
                  ? l10n.assetTransfer
                  : _relativeTime(l10n, item.timestamp!))
            : (item.timestamp == null
                  ? Formatters.compactAddress(
                      item.counterparty,
                      visibleChars: 5,
                    )
                  : l10n.assetCounterpartyWithTime(
                      Formatters.compactAddress(
                        item.counterparty,
                        visibleChars: 5,
                      ),
                      _relativeTime(l10n, item.timestamp!),
                    )),
    };

    return WalletCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.secondaryContainer,
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            item.amount,
            style: theme.textTheme.titleMedium?.copyWith(color: amountColor),
          ),
        ],
      ),
    );
  }
}

class _InlineNotice extends StatelessWidget {
  const _InlineNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(
        message,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onTertiaryContainer,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return WalletCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: IconButton(onPressed: onTap, icon: Icon(icon, size: 20)),
    );
  }
}

class _TokenLogo extends StatelessWidget {
  const _TokenLogo({required this.symbol, this.iconUrl, this.size = 56});

  final String symbol;
  final String? iconUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ChainBadged(
      size: size,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.7),
        ),
        child: iconUrl == null
            ? Center(
                child: Text(
                  symbol.substring(0, 1),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              )
            : Padding(
                padding: EdgeInsets.all(size * 0.12),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: iconUrl!,
                    fit: BoxFit.cover,
                    memCacheWidth: 160,
                    fadeInDuration: const Duration(milliseconds: 120),
                    errorWidget: (context, url, error) => Center(
                      child: Text(
                        symbol.substring(0, 1),
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

/// Backend profile languages; other app languages read the English one.
String _profileLanguage(Locale locale) {
  if (locale.languageCode == 'zh') {
    // The app's Chinese is written in traditional characters.
    return 'zh-Hant';
  }
  const supported = {'en', 'es', 'ja', 'ko', 'ru'};
  return supported.contains(locale.languageCode) ? locale.languageCode : 'en';
}

/// A token's detail: the header (price, figures and chart), then tabs that
/// stay pinned under the top while their content scrolls: the overview
/// (holding and figures), activity and, for xStocks, the company profile.
class _AssetTabsView extends ConsumerStatefulWidget {
  const _AssetTabsView({
    required this.mintAddress,
    required this.isStock,
    required this.header,
    required this.overview,
    required this.activity,
  });

  final String mintAddress;
  final bool isStock;
  final Widget header;
  final Widget overview;
  final Widget activity;

  @override
  ConsumerState<_AssetTabsView> createState() => _AssetTabsViewState();
}

class _AssetTabsViewState extends ConsumerState<_AssetTabsView> {
  @override
  void initState() {
    super.initState();
    // The page's links open in Benny's browser; get its script ready.
    if (AppFeatures.canOpenDappBrowser) {
      unawaited(DappBrowserPage.preloadScript());
    }
  }

  final _scroll = ScrollController();
  final _headerKey = GlobalKey();
  int _selected = 0;

  /// Tabs are built when first opened (the chart's web view included) and
  /// kept afterwards.
  final Set<int> _opened = {0};

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _select(int index) {
    if (index == _selected) {
      return;
    }
    setState(() {
      _selected = index;
      _opened.add(index);
    });
    // Scrolled past the header, a newly picked tab starts at its top, right
    // under the pinned tabs.
    final header = _headerKey.currentContext?.findRenderObject() as RenderBox?;
    if (header != null &&
        _scroll.hasClients &&
        _scroll.offset > header.size.height) {
      _scroll.jumpTo(header.size.height);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final kind = widget.isStock
        ? ref
              .watch(
                stockProfileProvider(
                  _profileRequest(context, widget.mintAddress),
                ),
              )
              .valueOrNull
              ?.kind
        : null;
    final tabs = <(String, Widget Function())>[
      (l10n.stockTabFundamentals, () => widget.overview),
      (l10n.assetActivity, () => widget.activity),
      if (widget.isStock)
        (
          kind == StockKind.etf ? l10n.stockTabFund : l10n.stockTabCompany,
          () => _StockCompanyTab(mintAddress: widget.mintAddress),
        ),
    ];
    final labelSize = Theme.of(context).textTheme.titleMedium?.fontSize ?? 15;
    final tabBarHeight =
        MediaQuery.textScalerOf(context).scale(labelSize) * 1.6 + 16;

    return CustomScrollView(
      controller: _scroll,
      slivers: [
        SliverToBoxAdapter(
          child: KeyedSubtree(key: _headerKey, child: widget.header),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _PinnedTabBar(
            height: tabBarHeight,
            child: _withMargin(
              _AssetTabBar(
                labels: [for (final tab in tabs) tab.$1],
                selected: _selected,
                onSelected: _select,
              ),
            ),
          ),
        ),
        // At least a screen tall under the tabs, so switching to a short tab
        // while scrolled down keeps the tabs pinned at the top.
        SliverLayoutBuilder(
          builder: (context, constraints) => SliverToBoxAdapter(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: (constraints.viewportMainAxisExtent - tabBarHeight)
                    .clamp(0, double.infinity),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    // Hidden tabs keep their state (the chart's period, its scroll
                    // position) and stop their tickers, which pauses the chart's
                    // polling.
                    for (var index = 0; index < tabs.length; index++)
                      if (_opened.contains(index))
                        Visibility(
                          visible: index == _selected,
                          maintainState: true,
                          child: tabs[index].$2(),
                        ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PinnedTabBar extends SliverPersistentHeaderDelegate {
  const _PinnedTabBar({required this.height, required this.child});

  final double height;
  final Widget child;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // At rest the page background shows through; once content scrolls
    // under the pinned tabs, they turn opaque to hide it.
    return ColoredBox(
      color: shrinkOffset > 0 || overlapsContent
          ? AppColors.background
          : Colors.transparent,
      child: Align(alignment: Alignment.bottomCenter, child: child),
    );
  }

  @override
  bool shouldRebuild(_PinnedTabBar oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}

class _AssetTabBar extends StatelessWidget {
  const _AssetTabBar({
    required this.labels,
    required this.selected,
    required this.onSelected,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.surfaceContainer)),
      ),
      child: Row(
        children: [
          for (var index = 0; index < labels.length; index++)
            Expanded(
              child: Semantics(
                button: true,
                selected: index == selected,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onSelected(index),
                  child: Column(
                    children: [
                      Text(
                        labels[index],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: index == selected
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: index == selected
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        width: 28,
                        height: 3,
                        decoration: BoxDecoration(
                          color: index == selected
                              ? AppColors.primaryBright
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

StockProfileRequest _profileRequest(BuildContext context, String mintAddress) {
  return (
    mintAddress: mintAddress,
    language: _profileLanguage(Localizations.localeOf(context)),
  );
}

/// Loads the xStock's profile and hands it to [builder]; tokens that are not
/// xStocks show nothing.
class _StockProfileLoader extends ConsumerWidget {
  const _StockProfileLoader({required this.mintAddress, required this.builder});

  final String mintAddress;
  final Widget Function(BuildContext context, StockProfile profile) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(
      stockProfileProvider(_profileRequest(context, mintAddress)),
    );

    return profile.when(
      data: (data) =>
          data == null ? const SizedBox.shrink() : builder(context, data),
      error: (_, _) => Padding(
        padding: const EdgeInsets.only(top: 18),
        child: _InlineNotice(message: context.l10n.stockLoadFailed),
      ),
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 18),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

/// Where a tab's figures came from, out of all the profile's sources.
Widget _stockSources(
  BuildContext context,
  StockProfile profile,
  Set<String> shown, {
  bool wikipediaLicense = false,
}) {
  final l10n = context.l10n;
  final sources = profile.sources.where(shown.contains).toList();
  if (sources.isEmpty) {
    return const SizedBox.shrink();
  }
  return Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Text(
      [
        l10n.assetDataSource(sources.join(' · ')),
        if (wikipediaLicense) l10n.stockWikipediaLicense,
      ].join('\n'),
      style: Theme.of(
        context,
      ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
    ),
  );
}

/// A coin's overview after its holding: the figures not already beside
/// the price, then what the coin is.
class _CoinOverviewTab extends ConsumerWidget {
  const _CoinOverviewTab({
    required this.mintAddress,
    required this.symbol,
    required this.detail,
    required this.websiteUrl,
    required this.statsUnavailable,
  });

  final String mintAddress;
  final String symbol;
  final AssetDetailViewData? detail;
  final String? websiteUrl;
  final bool statsUnavailable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final profile = ref.watch(
      tokenProfileProvider(_profileRequest(context, mintAddress)),
    );
    final detail = this.detail;
    _Stat? figure(String label, double? value, String Function(double) format) {
      return value == null ? null : _Stat(label, format(value));
    }

    final rows = <(_Stat?, _Stat?)>[
      (
        figure(l10n.assetFdv, detail?.fdvUsd, Formatters.compactUsd),
        figure(
          l10n.coinTraders24h,
          detail?.traderCount24h?.toDouble(),
          Formatters.compactNumber,
        ),
      ),
      (
        figure(
          l10n.assetCirculatingSupply,
          detail?.circulatingSupply,
          Formatters.compactNumber,
        ),
        figure(
          l10n.assetTotalSupply,
          detail?.totalSupply,
          Formatters.compactNumber,
        ),
      ),
      (
        figure(
          l10n.assetTop10Holders,
          detail?.top10HoldersPct,
          (value) => Formatters.percent(value),
        ),
        _Stat(l10n.commonNetwork, detail?.network ?? l10n.commonSolana),
      ),
      // A date is the widest figure, so it gets the last row to itself.
      (
        detail?.createdAt == null
            ? null
            : _Stat(l10n.assetCreated, _formatDate(l10n, detail!.createdAt)),
        null,
      ),
    ].where((row) => row.$1 != null || row.$2 != null).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionLabel(title: l10n.assetInfo),
        const SizedBox(height: 10),
        WalletCard(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [for (final row in rows) _StatRow(row.$1, row.$2)],
          ),
        ),
        if (statsUnavailable) ...[
          const SizedBox(height: 12),
          _InlineNotice(message: l10n.assetMarketStatsUnavailable),
        ],
        const SizedBox(height: 18),
        _SectionLabel(title: l10n.coinAbout(symbol)),
        const SizedBox(height: 10),
        profile.when(
          data: (data) => _CoinAbout(profile: data, websiteUrl: websiteUrl),
          error: (_, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _InlineNotice(message: l10n.coinDescriptionLoadFailed),
              if (websiteUrl != null) ...[
                const SizedBox(height: 12),
                _CoinAbout(
                  profile: null,
                  websiteUrl: websiteUrl,
                  linksOnly: true,
                ),
              ],
            ],
          ),
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

/// The coin's description and links.
class _CoinAbout extends StatelessWidget {
  const _CoinAbout({
    required this.profile,
    required this.websiteUrl,
    this.linksOnly = false,
  });

  final TokenProfile? profile;
  final String? websiteUrl;
  final bool linksOnly;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final profile = this.profile;
    final description = profile?.description;
    final website = _normalizeWebsiteUrl(profile?.website ?? websiteUrl);
    final launched = profile?.genesisDate;
    // Short enough for one line: an X handle, GitHub's owner/repo, else
    // the site's name (the row's label says what the page is).
    String linkText(String url) {
      final uri = Uri.tryParse(url);
      if (uri == null || uri.host.isEmpty) {
        return url;
      }
      final host = uri.host.replaceFirst(RegExp(r'^www\.'), '');
      final path = uri.path.replaceFirst(RegExp(r'/+$'), '');
      if ((host == 'x.com' || host == 'twitter.com') && path.length > 1) {
        return '@${path.substring(1)}';
      }
      if (host == 'github.com' && path.length > 1) {
        return path.substring(1);
      }
      return host;
    }

    final rows = [
      if (website != null)
        _InfoRowData(
          l10n.assetWebsite,
          _websiteDisplayText(website),
          linkUrl: website,
        ),
      if (profile?.twitter != null)
        _InfoRowData(
          'X',
          linkText(profile!.twitter!),
          linkUrl: profile.twitter,
        ),
      if (profile?.whitepaper != null)
        _InfoRowData(
          l10n.coinWhitepaper,
          linkText(profile!.whitepaper!),
          linkUrl: profile.whitepaper,
        ),
      if (profile?.github != null)
        _InfoRowData(
          'GitHub',
          linkText(profile!.github!),
          linkUrl: profile.github,
        ),
      for (final link in profile?.links ?? const <TokenLink>[])
        _InfoRowData(link.label, linkText(link.url), linkUrl: link.url),
      if (profile != null && profile.categories.isNotEmpty)
        _InfoRowData(l10n.coinCategories, profile.categories.join(' · ')),
      if (launched != null)
        _InfoRowData(l10n.coinLaunched, _formatDate(l10n, launched)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!linksOnly) ...[
          if (description != null)
            _ExpandableText(text: description)
          else
            _EmptyState(message: l10n.coinNoDescription),
          if (rows.isNotEmpty) const SizedBox(height: 12),
        ],
        if (rows.isNotEmpty) _InfoPanel(rows: rows),
        if (!linksOnly && profile != null && profile.sources.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              l10n.assetDataSource(profile.sources.join(' · ')),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ),
      ],
    );
  }
}

/// A stock's overview after its holding: the figures not already beside the
/// price, two to a row, with the less used ones behind a toggle.
class _StockOverviewTab extends StatefulWidget {
  const _StockOverviewTab({required this.mintAddress});

  final String mintAddress;

  @override
  State<_StockOverviewTab> createState() => _StockOverviewTabState();
}

class _StockOverviewTabState extends State<_StockOverviewTab> {
  static const _collapsedRows = 4;

  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return _StockProfileLoader(
      mintAddress: widget.mintAddress,
      builder: (context, profile) {
        final l10n = context.l10n;
        if (profile.kind == StockKind.private) {
          return _InlineNotice(message: l10n.stockPrivateNotice);
        }
        final rows = _statRows(
          context,
          profile,
        ).where((row) => row.$1 != null || row.$2 != null).toList();
        final shownRows = _expanded ? rows : rows.take(_collapsedRows).toList();
        final periodEnd = profile.periodEnd;
        final theme = Theme.of(context);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SectionLabel(title: l10n.assetInfo),
            const SizedBox(height: 10),
            if (profile.price == null) ...[
              _InlineNotice(message: l10n.stockQuoteUnavailable),
              const SizedBox(height: 12),
            ],
            WalletCard(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final row in shownRows) _StatRow(row.$1, row.$2),
                  if (rows.length > _collapsedRows)
                    IconButton(
                      tooltip: _expanded
                          ? l10n.stockShowLess
                          : l10n.stockShowMore,
                      onPressed: () => setState(() => _expanded = !_expanded),
                      icon: Icon(
                        _expanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textSecondary,
                      ),
                    )
                  else
                    const SizedBox(height: 12),
                ],
              ),
            ),
            if (periodEnd != null) ...[
              const SizedBox(height: 6),
              Text(
                l10n.stockFinancialsThrough(_formatDate(l10n, periodEnd)),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            _stockSources(context, profile, const {
              'Yahoo Finance',
              'SEC EDGAR',
            }),
          ],
        );
      },
    );
  }

  /// Pairs of figures, most watched first; a row with neither figure is
  /// dropped (funds have no earnings, foreign companies no SEC filings).
  static List<(_Stat?, _Stat?)> _statRows(
    BuildContext context,
    StockProfile profile,
  ) {
    final l10n = context.l10n;
    final trend = PriceTrendColors.of(context);
    _Stat? money(String label, double? value, {bool versusClose = false}) {
      if (value == null) {
        return null;
      }
      final previous = profile.previousClose;
      return _Stat(
        label,
        _stockMoney(profile, value),
        color: versusClose && previous != null
            ? trend.forChange(value - previous, neutral: AppColors.textPrimary)
            : null,
      );
    }

    _Stat? ratio(String label, double? value, {double? eps}) {
      if (value != null) {
        return _Stat(label, value.toStringAsFixed(2));
      }
      // Without earnings there is no ratio to show, only the loss.
      return eps != null && eps <= 0 ? _Stat(label, l10n.stockLoss) : null;
    }

    _Stat? figure(String label, double? value, String Function(double) format) {
      return value == null ? null : _Stat(label, format(value));
    }

    // Market cap, P/E (TTM), volume and the 52-week high sit beside the
    // price at the top of the page.
    return [
      (
        money(l10n.stockHigh, profile.dayHigh, versusClose: true),
        money(l10n.stockLow, profile.dayLow, versusClose: true),
      ),
      (
        money(l10n.stockOpen, profile.open, versusClose: true),
        money(l10n.stockPrevClose, profile.previousClose),
      ),
      (
        ratio(
          l10n.stockPeStatic,
          profile.peRatioStatic,
          eps: profile.epsAnnual,
        ),
        ratio(
          l10n.stockPeDynamic,
          profile.peRatioDynamic,
          eps: profile.epsAnnualized,
        ),
      ),
      (
        ratio(l10n.stockPbRatio, profile.pbRatio),
        figure(
          l10n.stockDividendYield,
          profile.dividendYieldPct,
          (value) => Formatters.percent(value),
        ),
      ),
      (
        figure(
          l10n.stockShares,
          profile.sharesOutstanding,
          Formatters.compactNumber,
        ),
        money(l10n.stock52wLow, profile.fiftyTwoWeekLow),
      ),
      (
        figure(
          l10n.stockEps,
          profile.epsTtm,
          (value) => Formatters.signedUsd(value, includePositiveSign: false),
        ),
        figure(
          l10n.stockBookValuePerShare,
          profile.bookValuePerShare,
          (value) => Formatters.signedUsd(value, includePositiveSign: false),
        ),
      ),
      (
        figure(l10n.stockRevenue, profile.revenueTtm, Formatters.compactUsd),
        figure(
          l10n.stockNetIncome,
          profile.netIncomeTtm,
          Formatters.compactUsd,
        ),
      ),
    ];
  }
}

class _Stat {
  const _Stat(this.label, this.value, {this.color});

  final String label;
  final String value;
  final Color? color;
}

/// "Trading 10/23 12:15:13 (ET)": the session and the last trade in the
/// exchange's own time.
String? _stockSessionLine(AppLocalizations l10n, StockProfile profile) {
  final time = profile.marketTime;
  if (time == null) {
    return null;
  }
  final local = time.toUtc().add(
    Duration(seconds: profile.gmtOffsetSeconds ?? 0),
  );
  final state = switch (profile.marketState) {
    MarketState.pre => l10n.stockMarketPre,
    MarketState.regular => l10n.stockMarketOpen,
    MarketState.post => l10n.stockMarketPost,
    MarketState.closed => l10n.stockMarketClosed,
    null => null,
  };
  final zone = profile.timeZone == 'America/New_York'
      ? l10n.stockTimeZoneEastern
      : profile.timeZoneName;
  return [
    if (state != null) state,
    DateFormat('MM/dd HH:mm:ss').format(local),
    if (zone != null) '($zone)',
  ].join(' ');
}

/// Two figures side by side; a row whose right figure is missing gives the
/// left one the whole width.
class _StatRow extends StatelessWidget {
  const _StatRow(this.left, this.right);

  final _Stat? left;
  final _Stat? right;

  @override
  Widget build(BuildContext context) {
    final right = this.right;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _StatCell(left)),
          if (right != null) ...[
            const SizedBox(width: 16),
            Expanded(child: _StatCell(right)),
          ],
        ],
      ),
    );
  }
}

/// A figure's name above its value, so a long value (a date) never pushes
/// the name out.
class _StatCell extends StatelessWidget {
  const _StatCell(this.stat);

  final _Stat? stat;

  @override
  Widget build(BuildContext context) {
    final stat = this.stat;
    if (stat == null) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          stat.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          stat.value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: stat.color ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// The price on its own line, then the change in money beside the percent
/// in a tinted chip, then what the change covers (24h, or the session).
class _PriceBlock extends StatelessWidget {
  const _PriceBlock({
    required this.price,
    required this.change,
    required this.changePct,
    required this.caption,
  });

  final String price;
  final String? change;
  final double? changePct;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = changePct;
    final color = PriceTrendColors.of(
      context,
    ).forChange(pct, neutral: AppColors.textSecondary);
    final change = this.change;
    final caption = this.caption;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            price,
            maxLines: 1,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
        ),
        if (change != null || pct != null || caption != null) ...[
          const SizedBox(height: 6),
          // Wraps onto a second line on narrow screens.
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              if (change != null)
                Text(
                  change,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              if (pct != null)
                Container(
                  padding: const EdgeInsets.fromLTRB(6, 3, 8, 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (pct != 0)
                        Icon(
                          pct > 0
                              ? Icons.arrow_drop_up_rounded
                              : Icons.arrow_drop_down_rounded,
                          color: color,
                          size: 20,
                        ),
                      Text(
                        Formatters.percent(pct, signed: true),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              if (caption != null)
                Text(
                  caption,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// The company's (or fund's) Wikipedia summary and Wikidata facts.
class _StockCompanyTab extends StatelessWidget {
  const _StockCompanyTab({required this.mintAddress});

  final String mintAddress;

  @override
  Widget build(BuildContext context) {
    return _StockProfileLoader(
      mintAddress: mintAddress,
      builder: (context, profile) {
        final l10n = context.l10n;
        if (!profile.hasProfile) {
          return _EmptyState(message: l10n.stockNoProfile);
        }
        final website = _normalizeWebsiteUrl(profile.website);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (profile.description != null) ...[
              _ExpandableText(text: profile.description!),
              const SizedBox(height: 12),
            ],
            _InfoPanel(
              rows: [
                if (profile.industry != null)
                  _InfoRowData(l10n.stockIndustry, profile.industry!),
                if (profile.ceo != null)
                  _InfoRowData(l10n.stockCeo, profile.ceo!),
                if (profile.founded != null)
                  _InfoRowData(l10n.stockFounded, profile.founded!),
                if (profile.headquarters != null)
                  _InfoRowData(l10n.stockHeadquarters, profile.headquarters!),
                if (profile.employees != null)
                  _InfoRowData(
                    l10n.stockEmployees,
                    NumberFormat.decimalPattern(
                      l10n.localeName,
                    ).format(profile.employees),
                  ),
                if (website != null)
                  _InfoRowData(
                    l10n.assetWebsite,
                    _websiteDisplayText(website),
                    linkUrl: website,
                  ),
              ],
            ),
            _stockSources(context, profile, const {
              'Wikidata',
              'Wikipedia',
            }, wikipediaLicense: profile.description != null),
          ],
        );
      },
    );
  }
}

/// A quote in its own currency (Xiaomi trades in HK$).
String _stockMoney(StockProfile profile, double? value) {
  if (value == null || !value.isFinite) {
    return '--';
  }
  final currency = profile.currency;
  if (currency == null || currency == 'USD') {
    return Formatters.usdPrice(value);
  }
  return NumberFormat.simpleCurrency(name: currency).format(value);
}

class _ExpandableText extends StatefulWidget {
  const _ExpandableText({required this.text});

  final String text;

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final style = theme.textTheme.bodyMedium?.copyWith(
      color: AppColors.textPrimary,
      height: 1.5,
    );

    return WalletCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Measured exactly as the Text below lays out (the inherited
          // style, the reader's text size and language), so the toggle
          // shows whenever the text is cut.
          final painter = TextPainter(
            text: TextSpan(
              text: widget.text,
              style: DefaultTextStyle.of(context).style.merge(style),
            ),
            maxLines: 4,
            textDirection: Directionality.of(context),
            textScaler: MediaQuery.textScalerOf(context),
            locale: Localizations.maybeLocaleOf(context),
          )..layout(maxWidth: constraints.maxWidth);
          final overflows = painter.didExceedMaxLines;
          painter.dispose();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.text,
                style: style,
                maxLines: _expanded ? null : 4,
                overflow: _expanded ? null : TextOverflow.ellipsis,
              ),
              if (overflows)
                TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 36),
                  ),
                  onPressed: () => setState(() => _expanded = !_expanded),
                  child: Text(
                    _expanded ? l10n.stockShowLess : l10n.stockShowMore,
                  ),
                )
              else
                const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }
}
