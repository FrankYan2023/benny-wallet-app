import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/responsive/layout_shell.dart';
import '../../../../core/config/app_features.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_update_gate.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../../airdrop/presentation/pages/airdrop_page.dart';
import '../../../asset_detail/presentation/pages/asset_detail_page.dart';
import '../../../auth/presentation/pages/unlock_page.dart';
import '../../../auth/presentation/providers/wallet_controller.dart';
import '../../../auth/domain/wallet_controller_state.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';
import '../../../notifications/presentation/providers/notification_inbox_provider.dart';
import '../../../onboarding/presentation/pages/welcome_page.dart';
import '../../../receive/presentation/pages/receive_page.dart';
import '../../../send/presentation/pages/send_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../swap/presentation/pages/swap_page.dart';
import '../../domain/entities/portfolio_view_data.dart';
import '../pages/child_wallets_page.dart';
import '../providers/portfolio_provider.dart';

class PortfolioPage extends ConsumerStatefulWidget {
  const PortfolioPage({super.key});

  static const routeName = 'portfolio';
  static const routePath = '/portfolio';
  static const navLabel = 'Wallet';

  @override
  ConsumerState<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends ConsumerState<PortfolioPage> {
  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletControllerProvider);
    final theme = Theme.of(context);
    final canOpenSwap = AppFeatures.canOpenSwap;
    final canOpenXStocks = AppFeatures.canOpenXStocks;
    final canOpenAirdrop = AppFeatures.canOpenAirdrop;
    final unreadMessageCount = ref.watch(unreadNotificationCountProvider);

    if (!walletState.isUnlocked) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.go(
            !walletState.hasWallet || walletState.loggedOut
                ? WelcomePage.routePath
                : UnlockPage.routePath,
          );
        }
      });

      return LayoutShell(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 1) {
            context.push(SettingsPage.routePath);
          }
        },
        child: const AppScaffold(
          title: 'Benny Wallet',
          showBackButton: false,
          enableTitleNavigation: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final ownerAddress = walletState.publicKey!;
    ref.listen<AsyncValue<PortfolioViewData>>(activePortfolioProvider, (
      previous,
      next,
    ) {
      final nextData = next.valueOrNull;
      if (nextData != null) {
        final cache = ref.read(portfolioCacheProvider);
        ref.read(portfolioCacheProvider.notifier).state = {
          ...cache,
          ownerAddress: nextData,
        };
      }

      final nextError = next.asError?.error;
      final previousError = previous?.asError?.error;
      if (nextError == null || identical(nextError, previousError)) {
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }

        _showRefreshErrorDialog(context, nextError);
      });
    });

    final state = ref.watch(activePortfolioProvider);
    final cachedData = ref.watch(
      portfolioCacheProvider.select((cache) => cache[ownerAddress]),
    );
    final displayData = state.valueOrNull ?? cachedData;

    Future<void> refreshPortfolio() async {
      try {
        ref.invalidate(portfolioProvider(ownerAddress));
        await ref.read(portfolioProvider(ownerAddress).future);
        ref.invalidate(receivedTransfersProvider);
        final receivedTransfers = await ref.read(
          receivedTransfersProvider.future,
        );
        await ref
            .read(notificationInboxProvider.notifier)
            .syncReceivedTransfers(receivedTransfers);
      } catch (_) {
        // Keep the current screen visible and surface the failure through the dialog listener.
      }
    }

    final pageBody = LayoutShell(
      selectedIndex: 0,
      onDestinationSelected: (index) {
        if (index == 1) {
          context.push(SettingsPage.routePath);
        }
      },
      child: AppScaffold(
        title: 'Benny',
        showBackButton: false,
        enableTitleNavigation: false,
        actions: [
          if (canOpenAirdrop)
            IconButton(
              tooltip: 'BYC airdrop',
              onPressed: () => context.push(AirdropPage.routePath),
              icon: const Icon(Icons.card_giftcard_rounded),
            ),
          if (canOpenXStocks && !walletState.childModeEnabled)
            IconButton(
              tooltip: 'xStocks',
              onPressed: () => context.push(XStocksSwapPage.routePath),
              icon: const Icon(Icons.candlestick_chart_rounded),
            ),
          _MessageButton(
            unreadCount: unreadMessageCount,
            onPressed: () => context.push(NotificationsPage.routePath),
          ),
          IconButton(
            onPressed: () => context.push(SettingsPage.routePath),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
        child: displayData == null && state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: refreshPortfolio,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: _buildContent(
                    context: context,
                    theme: theme,
                    data: displayData,
                    isRefreshing: state.isLoading && displayData != null,
                    hasLoadError: state.hasError && displayData == null,
                    walletState: walletState,
                    canOpenSwap: canOpenSwap,
                  ),
                ),
              ),
      ),
    );

    return PopScope<void>(
      canPop: false,
      child: AppFeatures.canCheckForUpdates
          ? AppUpdateGate(child: pageBody)
          : pageBody,
    );
  }

  List<Widget> _buildContent({
    required BuildContext context,
    required ThemeData theme,
    required PortfolioViewData? data,
    required bool isRefreshing,
    required bool hasLoadError,
    required WalletControllerState walletState,
    required bool canOpenSwap,
  }) {
    final assets = [...(data?.assets ?? const <AssetHolding>[])]
      ..sort((a, b) {
        final byValue = b.totalValueUsd.compareTo(a.totalValueUsd);
        if (byValue != 0) {
          return byValue;
        }

        final byBalance = b.balance.compareTo(a.balance);
        if (byBalance != 0) {
          return byBalance;
        }

        return a.token.symbol.compareTo(b.token.symbol);
      });
    final cryptoAssets = assets
        .where((asset) => !_isXStockAsset(asset))
        .toList();
    final stockAssets = assets.where(_isXStockAsset).toList();
    final totalValueUsd = data?.totalValueUsd ?? 0;
    final cryptoValueUsd = cryptoAssets.fold<double>(
      0,
      (sum, asset) => sum + asset.totalValueUsd,
    );
    final stockValueUsd = stockAssets.fold<double>(
      0,
      (sum, asset) => sum + asset.totalValueUsd,
    );
    final totalPerformance = _totalPerformance(assets);
    final cryptoPerformance = _totalPerformance(cryptoAssets);
    final stockPerformance = _totalPerformance(stockAssets);
    return [
      if (!walletState.childModeEnabled &&
          walletState.childWallets.isNotEmpty) ...[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: GestureDetector(
            onTap: () => context.push(ChildWalletsPage.routePath),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0E6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD4C5FF), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.child_care_rounded,
                        color: Color(0xFF6C63FF),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Child accounts',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: const Color(0xFF6C63FF),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${walletState.childWallets.length}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF6C63FF),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: const Color(0xFF6C63FF),
                        size: 18,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
      Container(
        padding: const EdgeInsets.fromLTRB(16, 26, 16, 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primaryContainer,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.08),
              blurRadius: 26,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              Formatters.usd(totalValueUsd),
              textAlign: TextAlign.center,
              style: theme.textTheme.displayLarge?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontSize: 48,
                letterSpacing: -1.8,
              ),
            ),
            const SizedBox(height: 20),
            if (totalPerformance != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    Formatters.signedUsd(totalPerformance.deltaUsd),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: totalPerformance.deltaUsd >= 0
                          ? const Color(0xFFE9FFF1)
                          : const Color(0xFFFFE6DE),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      Formatters.percent(
                        totalPerformance.changePct,
                        signed: true,
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: totalPerformance.deltaUsd >= 0
                            ? const Color(0xFFE9FFF1)
                            : const Color(0xFFFFE6DE),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              )
            else
              Text(
                '--',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onPrimary.withValues(alpha: 0.78),
                ),
              ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _ValueBreakdownChip(
                    label: 'Crypto',
                    value: Formatters.usd(cryptoValueUsd),
                    performance: cryptoPerformance,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ValueBreakdownChip(
                    label: 'Stocks',
                    value: Formatters.usd(stockValueUsd),
                    performance: stockPerformance,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            if (!walletState.childModeEnabled)
              Row(
                children: [
                  Expanded(
                    child: _BalanceActionButton(
                      backgroundColor: Colors.white,
                      foregroundColor: theme.colorScheme.primary,
                      icon: Icons.send_rounded,
                      iconSize: 24,
                      label: 'Send',
                      onTap: () => context.push(SendPage.routePath),
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (canOpenSwap) ...[
                    Expanded(
                      child: _BalanceActionButton(
                        backgroundColor: Colors.white,
                        foregroundColor: theme.colorScheme.primary,
                        icon: Icons.swap_horiz_rounded,
                        iconSize: 24,
                        label: 'Swap',
                        onTap: () => context.push(SwapPage.routePath),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: _BalanceActionButton(
                      backgroundColor: Colors.white,
                      foregroundColor: theme.colorScheme.primary,
                      icon: Icons.qr_code_2_rounded,
                      iconSize: 24,
                      label: 'Receive',
                      onTap: () => context.push(ReceivePage.routePath),
                    ),
                  ),
                ],
              )
            else
              Center(
                child: SizedBox(
                  width: 132,
                  child: _BalanceActionButton(
                    backgroundColor: Colors.white,
                    foregroundColor: theme.colorScheme.primary,
                    icon: Icons.qr_code_2_rounded,
                    iconSize: 24,
                    label: 'Receive',
                    onTap: () => context.push(ReceivePage.routePath),
                  ),
                ),
              ),
            if (isRefreshing) ...[
              const SizedBox(height: 18),
              LinearProgressIndicator(
                minHeight: 4,
                borderRadius: BorderRadius.circular(999),
                backgroundColor: Colors.white.withValues(alpha: 0.22),
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.onPrimary,
                ),
              ),
            ],
          ],
        ),
      ),
      const SizedBox(height: 16),
      if (hasLoadError)
        WalletCard(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 4),
            child: Column(
              children: [
                Icon(
                  Icons.cloud_off_rounded,
                  size: 32,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.48),
                ),
                const SizedBox(height: 12),
                Text(
                  'Couldn\'t refresh assets',
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Pull down to try again.',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        )
      else if (assets.isEmpty)
        WalletCard(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Column(
              children: [
                const BrandLogo(size: 56, radius: 18),
                const SizedBox(height: 12),
                Text('No assets yet', style: theme.textTheme.titleLarge),
                const SizedBox(height: 6),
                Text(
                  'Pull down to refresh after funds arrive.',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        )
      else ...[
        for (final asset in assets) ...[
          TokenRow(
            name: asset.token.name,
            symbol: Formatters.tokenSymbol(asset.token.symbol),
            balanceLine:
                '${Formatters.compactNumber(asset.balance)} ${Formatters.tokenSymbol(asset.token.symbol)}',
            value: asset.priceQuote == null
                ? '--'
                : Formatters.usd(asset.totalValueUsd),
            secondaryValue: _assetPriceLine(asset),
            change: _assetChangePctLine(asset),
            isPositiveChange: _assetChangeDirection(asset),
            iconUrl: asset.logoUrl,
            onTap: () =>
                context.push(AssetDetailPage.pathFor(asset.token.mintAddress)),
          ),
          const SizedBox(height: 12),
        ],
      ],
    ];
  }

  bool _isXStockAsset(AssetHolding asset) => asset.category == 'xstock';

  Future<void> _showRefreshErrorDialog(
    BuildContext context,
    Object error,
  ) async {
    final message = _formatError(error);
    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          title: const Text('Refresh failed'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
          backgroundColor: theme.colorScheme.surface,
        );
      },
    );
  }

  String _formatError(Object error) {
    final raw = error.toString();
    if (raw.contains('429')) {
      return 'The network is busy right now. Pull down to try again.';
    }

    if (raw.startsWith('Exception: ')) {
      return raw.substring('Exception: '.length);
    }

    if (raw.startsWith('DioException ')) {
      return 'Couldn\'t reach the server. Pull down to try again.';
    }

    return raw;
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

  bool? _assetChangeDirection(AssetHolding asset) {
    final changePct = double.tryParse(asset.priceQuote?.change24hPct ?? '');
    if (changePct == null) {
      return null;
    }
    if (changePct == 0) {
      return null;
    }
    return changePct > 0;
  }

  _TotalPerformance? _totalPerformance(List<AssetHolding> assets) {
    var knownCurrent = 0.0;
    var knownPrevious = 0.0;

    for (final asset in assets) {
      final changePct = double.tryParse(asset.priceQuote?.change24hPct ?? '');
      if (changePct == null) {
        continue;
      }

      knownCurrent += asset.totalValueUsd;
      final divisor = 1 + (changePct / 100);
      if (divisor <= 0) {
        continue;
      }
      knownPrevious += asset.totalValueUsd / divisor;
    }

    if (knownCurrent <= 0 || knownPrevious <= 0) {
      return null;
    }

    final deltaUsd = knownCurrent - knownPrevious;
    final changePct = (deltaUsd / knownPrevious) * 100;
    return _TotalPerformance(deltaUsd: deltaUsd, changePct: changePct);
  }
}

class _MessageButton extends StatelessWidget {
  const _MessageButton({required this.unreadCount, required this.onPressed});

  final int unreadCount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final badgeText = unreadCount > 99 ? '99+' : '$unreadCount';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          tooltip: 'Messages',
          onPressed: onPressed,
          icon: const Icon(Icons.notifications_none_rounded),
        ),
        if (unreadCount > 0)
          Positioned(
            right: 4,
            top: 3,
            child: Container(
              constraints: const BoxConstraints(minWidth: 17),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFE1582A),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                badgeText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  height: 1,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _TotalPerformance {
  const _TotalPerformance({required this.deltaUsd, required this.changePct});

  final double deltaUsd;
  final double changePct;
}

class _BalanceActionButton extends StatelessWidget {
  const _BalanceActionButton({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
    required this.iconSize,
    required this.label,
    required this.onTap,
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final IconData icon;
  final double iconSize;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 96),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              child: Icon(icon, color: foregroundColor, size: iconSize),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: foregroundColor,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ValueBreakdownChip extends StatelessWidget {
  const _ValueBreakdownChip({
    required this.label,
    required this.value,
    required this.performance,
  });

  final String label;
  final String value;
  final _TotalPerformance? performance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.76),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            performance == null
                ? '--'
                : Formatters.percent(performance!.changePct, signed: true),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: performance == null
                  ? theme.colorScheme.onPrimary.withValues(alpha: 0.72)
                  : performance!.deltaUsd >= 0
                  ? const Color(0xFFE9FFF1)
                  : const Color(0xFFFFE6DE),
            ),
          ),
        ],
      ),
    );
  }
}
