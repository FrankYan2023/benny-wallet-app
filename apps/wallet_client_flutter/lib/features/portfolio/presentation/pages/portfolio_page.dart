import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/responsive/layout_shell.dart';
import '../../../../core/config/app_features.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_update_gate.dart';
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
import '../../domain/entities/defi_position_view_data.dart';
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
  _PortfolioAssetTab _selectedTab = _PortfolioAssetTab.tokens;

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

      final hasVisibleData =
          next.valueOrNull != null ||
          previous?.valueOrNull != null ||
          ref.read(portfolioCacheProvider)[ownerAddress] != null;
      if (!hasVisibleData) {
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }

        _showRefreshErrorDialog(context, nextError);
      });
    });
    ref.listen<AsyncValue<DefiPortfolioViewData>>(activeDefiPortfolioProvider, (
      previous,
      next,
    ) {
      final nextData = next.valueOrNull;
      if (nextData != null) {
        final cache = ref.read(defiPortfolioCacheProvider);
        ref.read(defiPortfolioCacheProvider.notifier).state = {
          ...cache,
          ownerAddress: nextData,
        };
      }
    });

    final state = ref.watch(activePortfolioProvider);
    final defiState = ref.watch(activeDefiPortfolioProvider);
    final cachedData = ref.watch(
      portfolioCacheProvider.select((cache) => cache[ownerAddress]),
    );
    final cachedDefiData = ref.watch(
      defiPortfolioCacheProvider.select((cache) => cache[ownerAddress]),
    );
    final displayData = state.valueOrNull ?? cachedData;
    final displayDefiData = defiState.valueOrNull ?? cachedDefiData;
    final hasDefiPositions = _hasDefiPositions(displayDefiData);

    if (!hasDefiPositions && _selectedTab == _PortfolioAssetTab.defi) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _selectedTab == _PortfolioAssetTab.defi) {
          setState(() => _selectedTab = _PortfolioAssetTab.tokens);
        }
      });
    }

    Future<void> refreshPortfolio() async {
      try {
        ref.invalidate(portfolioProvider(ownerAddress));
        ref.invalidate(defiPortfolioProvider(ownerAddress));
        await Future.wait([
          ref.read(portfolioProvider(ownerAddress).future),
          ref
              .read(defiPortfolioProvider(ownerAddress).future)
              .catchError(
                (_) => DefiPortfolioViewData(
                  address: ownerAddress,
                  totalValueUsd: 0,
                  positions: const [],
                  lastUpdatedAt: DateTime.now(),
                ),
              ),
        ]);
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
                    defiData: displayDefiData,
                    hasDefiPositions: hasDefiPositions,
                    isRefreshing: state.isLoading && displayData != null,
                    isDefiRefreshing:
                        defiState.isLoading && displayDefiData != null,
                    hasLoadError: state.hasError && displayData == null,
                    hasDefiLoadError:
                        defiState.hasError && displayDefiData == null,
                    walletState: walletState,
                    canOpenSwap: canOpenSwap,
                    selectedTab: _selectedTab,
                    onSelectedTabChanged: (tab) {
                      setState(() => _selectedTab = tab);
                    },
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
    required DefiPortfolioViewData? defiData,
    required bool hasDefiPositions,
    required bool isRefreshing,
    required bool isDefiRefreshing,
    required bool hasLoadError,
    required bool hasDefiLoadError,
    required WalletControllerState walletState,
    required bool canOpenSwap,
    required _PortfolioAssetTab selectedTab,
    required ValueChanged<_PortfolioAssetTab> onSelectedTabChanged,
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
    final cryptoValueUsd = cryptoAssets.fold<double>(
      0,
      (sum, asset) => sum + asset.totalValueUsd,
    );
    final stockValueUsd = stockAssets.fold<double>(
      0,
      (sum, asset) => sum + asset.totalValueUsd,
    );
    final defiValueUsd = hasDefiPositions
        ? defiData?.totalValueUsd ?? 0.0
        : 0.0;
    final totalValueUsd = (data?.totalValueUsd ?? 0) + defiValueUsd;
    final cryptoPerformance = _totalPerformance(cryptoAssets);
    final stockPerformance = _totalPerformance(stockAssets);
    final totalPerformance = _totalPerformanceWithDefi(
      assets,
      hasDefiPositions ? defiData : null,
    );
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
                    showPerformance: true,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ValueBreakdownChip(
                    label: 'Stocks',
                    value: Formatters.usd(stockValueUsd),
                    performance: stockPerformance,
                    showPerformance: true,
                  ),
                ),
                if (hasDefiPositions) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ValueBreakdownChip(
                      label: 'DeFi',
                      value: Formatters.usd(defiValueUsd),
                      reservePerformanceSpace: true,
                      onTap: () =>
                          onSelectedTabChanged(_PortfolioAssetTab.defi),
                    ),
                  ),
                ],
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
      else if (assets.isEmpty && !hasDefiPositions)
        _ReceiveSolPromptCard(onTap: () => context.push(ReceivePage.routePath))
      else ...[
        if (hasDefiPositions) ...[
          _PortfolioAssetTabs(
            selectedTab: selectedTab,
            onChanged: onSelectedTabChanged,
          ),
          const SizedBox(height: 12),
        ],
        if (!hasDefiPositions || selectedTab == _PortfolioAssetTab.tokens)
          ..._buildTokenRows(context, assets)
        else
          ..._buildDefiRows(
            context: context,
            defiData: defiData,
            hasDefiLoadError: hasDefiLoadError,
            isDefiRefreshing: isDefiRefreshing,
            walletState: walletState,
          ),
      ],
    ];
  }

  List<Widget> _buildTokenRows(
    BuildContext context,
    List<AssetHolding> assets,
  ) {
    if (assets.isEmpty) {
      return [
        _ReceiveSolPromptCard(onTap: () => context.push(ReceivePage.routePath)),
      ];
    }

    return [
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
    ];
  }

  bool _hasDefiPositions(DefiPortfolioViewData? data) {
    if (data == null) {
      return false;
    }
    return data.totalValueUsd > 0 || data.positions.isNotEmpty;
  }

  List<Widget> _buildDefiRows({
    required BuildContext context,
    required DefiPortfolioViewData? defiData,
    required bool hasDefiLoadError,
    required bool isDefiRefreshing,
    required WalletControllerState walletState,
  }) {
    final positions = defiData?.positions ?? const <DefiPosition>[];
    if (walletState.childModeEnabled) {
      return [
        _DefiStateCard(
          icon: Icons.lock_outline_rounded,
          title: 'DeFi is parent-only',
          message: 'Switch back to parent mode to review protocol positions.',
        ),
      ];
    }

    if (hasDefiLoadError) {
      return const [
        _DefiStateCard(
          icon: Icons.cloud_off_rounded,
          title: 'DeFi data is temporarily unavailable',
          message: 'Tokens are still up to date.',
        ),
      ];
    }

    if (positions.isEmpty) {
      return [
        _DefiStateCard(
          icon: Icons.account_tree_rounded,
          title: 'No DeFi positions yet',
          message: isDefiRefreshing
              ? 'Refreshing protocol positions...'
              : 'Your wallet has no active DeFi positions.',
        ),
      ];
    }

    return [
      if (isDefiRefreshing) ...[
        const LinearProgressIndicator(minHeight: 3),
        const SizedBox(height: 12),
      ],
      for (final position in positions) ...[
        _DefiPositionRow(position: position),
        const SizedBox(height: 12),
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
    var raw = error.toString().trim();
    while (raw.startsWith('Exception: ')) {
      raw = raw.substring('Exception: '.length).trim();
    }

    final lower = raw.toLowerCase();
    if (lower.contains('429') || lower.contains('too many requests')) {
      return 'The network is busy right now. Pull down to try again.';
    }

    if (_looksLikeTransportError(lower)) {
      return 'Couldn\'t reach the server. Check your connection and pull down to try again.';
    }

    return raw.isEmpty
        ? 'Couldn\'t refresh assets. Pull down to try again.'
        : raw;
  }

  bool _looksLikeTransportError(String lower) {
    return lower.contains('dioexception') ||
        lower.contains('requestoptions') ||
        lower.contains('socketexception') ||
        lower.contains('failed host lookup') ||
        lower.contains('network is unreachable') ||
        lower.contains('connection error') ||
        lower.contains('connection took longer') ||
        lower.contains('connection timeout') ||
        lower.contains('receivetimeout') ||
        lower.contains('sendtimeout') ||
        lower.contains('timed out') ||
        lower.contains('timeout');
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

      final divisor = 1 + (changePct / 100);
      if (divisor <= 0) {
        continue;
      }

      knownCurrent += asset.totalValueUsd;
      knownPrevious += asset.totalValueUsd / divisor;
    }

    if (knownCurrent <= 0 || knownPrevious <= 0) {
      return null;
    }

    final deltaUsd = knownCurrent - knownPrevious;
    return _TotalPerformance(
      deltaUsd: deltaUsd,
      changePct: (deltaUsd / knownPrevious) * 100,
    );
  }

  _TotalPerformance? _totalPerformanceWithDefi(
    List<AssetHolding> assets,
    DefiPortfolioViewData? defiData,
  ) {
    var knownCurrent = 0.0;
    var knownPrevious = 0.0;

    for (final asset in assets) {
      final changePct = double.tryParse(asset.priceQuote?.change24hPct ?? '');
      if (changePct == null) {
        continue;
      }

      final divisor = 1 + (changePct / 100);
      if (divisor <= 0) {
        continue;
      }

      knownCurrent += asset.totalValueUsd;
      knownPrevious += asset.totalValueUsd / divisor;
    }

    if (defiData != null && defiData.totalValueUsd > 0) {
      knownCurrent += defiData.totalValueUsd;
      if (defiData.change24hPct == null) {
        knownPrevious += defiData.totalValueUsd;
      } else {
        final divisor = 1 + (defiData.change24hPct! / 100);
        if (divisor > 0) {
          knownPrevious += defiData.totalValueUsd / divisor;
        }
      }
    }

    if (knownCurrent <= 0 || knownPrevious <= 0) {
      return null;
    }

    final deltaUsd = knownCurrent - knownPrevious;
    return _TotalPerformance(
      deltaUsd: deltaUsd,
      changePct: (deltaUsd / knownPrevious) * 100,
    );
  }
}

enum _PortfolioAssetTab { tokens, defi }

class _TotalPerformance {
  const _TotalPerformance({required this.deltaUsd, required this.changePct});

  final double deltaUsd;
  final double changePct;
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

class _PortfolioAssetTabs extends StatelessWidget {
  const _PortfolioAssetTabs({
    required this.selectedTab,
    required this.onChanged,
  });

  final _PortfolioAssetTab selectedTab;
  final ValueChanged<_PortfolioAssetTab> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _PortfolioAssetTabButton(
              label: 'Tokens',
              selected: selectedTab == _PortfolioAssetTab.tokens,
              onTap: () => onChanged(_PortfolioAssetTab.tokens),
            ),
          ),
          Expanded(
            child: _PortfolioAssetTabButton(
              label: 'DeFi',
              selected: selectedTab == _PortfolioAssetTab.defi,
              onTap: () => onChanged(_PortfolioAssetTab.defi),
            ),
          ),
        ],
      ),
    );
  }
}

class _PortfolioAssetTabButton extends StatelessWidget {
  const _PortfolioAssetTabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            color: selected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface.withValues(alpha: 0.58),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _DefiPositionRow extends StatelessWidget {
  const _DefiPositionRow({required this.position});

  final DefiPosition position;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryText = theme.colorScheme.onSurface;
    final secondaryText = theme.colorScheme.onSurface.withValues(alpha: 0.58);
    final apyText = position.apyPct == null
        ? null
        : '${Formatters.percent(position.apyPct)} APY';
    final assetText = position.assets.isEmpty
        ? _defiTypeLabel(position.type)
        : '${position.assets.join(' / ')} ${_defiTypeLabel(position.type)}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1DA),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              _protocolInitials(position.protocol),
              style: theme.textTheme.titleMedium?.copyWith(
                color: const Color(0xFF9B5C00),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  position.protocol,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: primaryText,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: position.label),
                      if (apyText != null)
                        TextSpan(
                          text: '  $apyText',
                          style: TextStyle(
                            color: const Color(0xFF30A46C),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                    ],
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  assetText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: secondaryText,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            Formatters.usd(position.valueUsd),
            style: theme.textTheme.titleLarge?.copyWith(
              color: primaryText,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  static String _protocolInitials(String value) {
    final words = value
        .split(RegExp(r'\s+'))
        .where((item) => item.trim().isNotEmpty)
        .toList();
    if (words.isEmpty) return 'D';
    if (words.length == 1) {
      final word = words.first;
      return word.substring(0, word.length < 2 ? word.length : 2).toUpperCase();
    }
    return words
        .take(2)
        .map((word) => word.substring(0, 1))
        .join()
        .toUpperCase();
  }

  static String _defiTypeLabel(DefiPositionType type) {
    return switch (type) {
      DefiPositionType.deposit => 'deposit',
      DefiPositionType.borrow => 'borrow',
      DefiPositionType.staking => 'staking',
      DefiPositionType.liquidity => 'liquidity',
      DefiPositionType.yield => 'yield',
      DefiPositionType.perps => 'perps',
      DefiPositionType.rewards => 'rewards',
      DefiPositionType.unknown => 'position',
    };
  }
}

class _DefiStateCard extends StatelessWidget {
  const _DefiStateCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return WalletCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 4),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.48),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceiveSolPromptCard extends StatelessWidget {
  const _ReceiveSolPromptCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const promptText = Color(0xFF7A5B2D);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFBF2), Color(0xFFFFF4DC)],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.tertiary.withValues(alpha: 0.28)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBright.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 74,
            height: 74,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryStrong.withValues(alpha: 0.42),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: SizedBox(
              width: 40,
              height: 30,
              child: _SolanaMark(
                color: AppColors.tertiary.withValues(alpha: 0.68),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Receive SOL',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: AppColors.primaryStrong.withValues(alpha: 0.72),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Receive SOL to get started with Benny Wallet.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: promptText.withValues(alpha: 0.72),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFA46708),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(58),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: onTap,
              child: const Text('Receive SOL'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SolanaMark extends StatelessWidget {
  const _SolanaMark({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _SolanaMarkPainter(color));
  }
}

class _SolanaMarkPainter extends CustomPainter {
  const _SolanaMarkPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final barHeight = size.height * 0.22;
    final gap = size.height * 0.17;
    final slant = size.width * 0.18;

    void drawBar(double top, {required bool reversed}) {
      final path = Path();
      if (reversed) {
        path
          ..moveTo(0, top)
          ..lineTo(size.width - slant, top)
          ..lineTo(size.width, top + barHeight)
          ..lineTo(slant, top + barHeight);
      } else {
        path
          ..moveTo(slant, top)
          ..lineTo(size.width, top)
          ..lineTo(size.width - slant, top + barHeight)
          ..lineTo(0, top + barHeight);
      }
      canvas.drawPath(path..close(), paint);
    }

    drawBar(0, reversed: false);
    drawBar(barHeight + gap, reversed: true);
    drawBar((barHeight + gap) * 2, reversed: false);
  }

  @override
  bool shouldRepaint(covariant _SolanaMarkPainter oldDelegate) {
    return oldDelegate.color != color;
  }
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
    this.onTap,
    this.performance,
    this.showPerformance = false,
    this.reservePerformanceSpace = false,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;
  final _TotalPerformance? performance;
  final bool showPerformance;
  final bool reservePerformanceSpace;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = Container(
      constraints: const BoxConstraints(minHeight: 88),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.76),
              fontWeight: FontWeight.w700,
              fontSize: 11,
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
          if (showPerformance || reservePerformanceSpace) ...[
            const SizedBox(height: 4),
            Text(
              showPerformance
                  ? performance == null
                        ? '--'
                        : Formatters.percent(
                            performance!.changePct,
                            signed: true,
                          )
                  : '  ',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 11,
                color: !showPerformance
                    ? Colors.transparent
                    : performance == null
                    ? theme.colorScheme.onPrimary.withValues(alpha: 0.72)
                    : performance!.deltaUsd >= 0
                    ? const Color(0xFFE9FFF1)
                    : const Color(0xFFFFE6DE),
              ),
            ),
          ],
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: content,
    );
  }
}
