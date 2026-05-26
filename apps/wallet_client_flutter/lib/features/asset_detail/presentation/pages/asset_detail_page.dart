import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/di/providers.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/config/app_features.dart';
import '../../../../core/utils/clipboard_utils.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../auth/presentation/providers/wallet_controller.dart';
import '../../../portfolio/domain/entities/portfolio_view_data.dart';
import '../../../portfolio/presentation/providers/portfolio_provider.dart';
import '../../../receive/presentation/pages/receive_page.dart';
import '../../../send/presentation/pages/send_page.dart';
import '../../../swap/presentation/pages/swap_page.dart';
import '../../../transaction_history/domain/transaction_activity.dart';
import '../../domain/asset_detail_view_data.dart';

final tokenDetailProvider = FutureProvider.family<AssetDetailViewData, String>((
  ref,
  mintAddress,
) async {
  return ref.read(assetDetailRepositoryProvider).loadTokenDetail(mintAddress);
});

final assetTransactionsProvider =
    FutureProvider.family<List<TransactionActivity>, AssetHolding>((
      ref,
      asset,
    ) async {
      final walletState = ref.watch(walletControllerProvider);
      if (walletState.publicKey == null) {
        return [];
      }
      return ref
          .read(assetDetailRepositoryProvider)
          .loadTokenActivity(
            ownerAddress: walletState.publicKey!,
            mintAddress: asset.token.mintAddress,
            symbol: asset.token.symbol,
            limit: 10,
          );
    });

class AssetDetailPage extends ConsumerWidget {
  const AssetDetailPage({super.key, required this.mintAddress});

  static const routeName = 'assetDetail';
  static const routePath = '/asset/:mint';

  static String pathFor(String mintAddress) => '/asset/$mintAddress';

  final String mintAddress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletState = ref.watch(walletControllerProvider);
    final isChildMode = walletState.childModeEnabled;
    final portfolio = ref.watch(activePortfolioProvider);
    final tokenDetail = ref.watch(tokenDetailProvider(mintAddress));

    return AppScaffold(
      title: '',
      showTopBar: false,
      child: portfolio.when(
        data: (data) {
          final asset = _findAsset(data.assets, mintAddress);
          if (asset == null) {
            return const Center(child: Text('Asset not found.'));
          }

          final transactions = ref.watch(assetTransactionsProvider(asset));
          final detail = tokenDetail.valueOrNull;
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

          return ListView(
            children: [
              _HeaderBar(
                name: detail?.name ?? asset.token.name,
                symbol: detail?.symbol ?? asset.token.symbol,
                logoUrl: detail?.logoUrl ?? asset.logoUrl,
              ),
              const SizedBox(height: 18),
              if (isChildMode)
                _ChildModeActionRow(
                  onReceive: () => context.push(ReceivePage.routePath),
                )
              else
                _ActionRow(
                  primaryIcon: primaryAction.icon,
                  primaryLabel: primaryAction.label,
                  onPrimaryAction: primaryAction.onTap,
                  onSend: () => context.push(SendPage.routePath),
                  onCopy: () => _copyMint(context, mintAddress),
                ),
              const SizedBox(height: 18),
              _SectionLabel(title: 'Position'),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      label: 'Value',
                      value: Formatters.usd(asset.totalValueUsd),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricCard(
                      label: 'Balance',
                      value:
                          '${Formatters.compactNumber(asset.balance)} ${Formatters.tokenSymbol(detail?.symbol ?? asset.token.symbol)}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _MetricCard(
                label: '24h return',
                value: profitLoss24h == null
                    ? '--'
                    : Formatters.signedUsd(profitLoss24h),
                trailing: priceChangePct == null
                    ? null
                    : Text(
                        Formatters.percent(priceChangePct, signed: true),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: _deltaColor(context, priceChangePct),
                            ),
                      ),
                emphasizeColor: priceChangePct == null
                    ? null
                    : _deltaColor(context, priceChangePct),
              ),
              const SizedBox(height: 18),
              _SectionLabel(title: 'Info'),
              const SizedBox(height: 10),
              _InfoPanel(
                rows: [
                  _InfoRowData('Name', detail?.name ?? asset.token.name),
                  _InfoRowData('Symbol', detail?.symbol ?? asset.token.symbol),
                  _InfoRowData('Network', detail?.network ?? 'Solana'),
                  _InfoRowData(
                    'Mint',
                    Formatters.compactAddress(mintAddress, visibleChars: 5),
                  ),
                  if (websiteUrl != null)
                    _InfoRowData(
                      'Website',
                      _websiteDisplayText(websiteUrl),
                      linkUrl: websiteUrl,
                    ),
                  _InfoRowData(
                    'Price',
                    priceUsd == null ? '--' : Formatters.usdPrice(priceUsd),
                  ),
                  _InfoRowData(
                    'Market cap',
                    Formatters.compactUsd(detail?.marketCapUsd),
                  ),
                  _InfoRowData('FDV', Formatters.compactUsd(detail?.fdvUsd)),
                  _InfoRowData(
                    'Total supply',
                    Formatters.compactNumber(detail?.totalSupply),
                  ),
                  _InfoRowData(
                    'Circulating supply',
                    Formatters.compactNumber(detail?.circulatingSupply),
                  ),
                  _InfoRowData(
                    'Holders',
                    detail?.holderCount == null
                        ? '--'
                        : Formatters.compactNumber(
                            detail!.holderCount!.toDouble(),
                          ),
                  ),
                  _InfoRowData('Created', Formatters.date(detail?.createdAt)),
                ],
              ),
              const SizedBox(height: 18),
              _SectionLabel(title: '24h performance'),
              const SizedBox(height: 10),
              _InfoPanel(
                rows: [
                  _InfoRowData(
                    'Volume',
                    Formatters.compactUsd(detail?.volume24hUsd),
                  ),
                  _InfoRowData(
                    'Traders',
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
                _SectionLabel(title: 'Safety'),
                const SizedBox(height: 10),
                _InfoPanel(
                  rows: [
                    _InfoRowData(
                      'Top 10 holders',
                      Formatters.percent(detail!.top10HoldersPct),
                    ),
                  ],
                ),
              ],
              if (showMarketStatsUnavailableNotice) ...[
                const SizedBox(height: 18),
                _InlineNotice(
                  message: 'Some market stats are unavailable right now.',
                ),
              ],
              const SizedBox(height: 18),
              _SectionLabel(title: 'Activity'),
              const SizedBox(height: 10),
              transactions.when(
                data: (items) {
                  if (items.isEmpty) {
                    return const _EmptyState(message: 'No activity yet.');
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
                error: (_, _) => const _InlineNotice(
                  message: 'Activity could not be loaded.',
                ),
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              const SizedBox(height: 12),
            ],
          );
        },
        error: (error, _) =>
            Center(child: Text('Failed to load asset details: $error')),
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mint copied (will clear in 60s)')),
    );
  }

  static Color _deltaColor(BuildContext context, double value) {
    if (value > 0) {
      return AppColors.success;
    }
    if (value < 0) {
      return AppColors.danger;
    }
    return Theme.of(context).colorScheme.onSurface;
  }

  static _AssetPrimaryAction _primaryActionForAsset(
    BuildContext context,
    AssetHolding asset,
  ) {
    if (!AppFeatures.canOpenSwap) {
      return _AssetPrimaryAction.receive(
        () => context.push(ReceivePage.routePath),
      );
    }

    if (asset.category == 'xstock') {
      if (!AppFeatures.canOpenXStocks) {
        return _AssetPrimaryAction.receive(
          () => context.push(ReceivePage.routePath),
        );
      }
      return _AssetPrimaryAction.swap(
        () => context.push(
          XStocksSwapPage.pathFor(outputMint: asset.token.mintAddress),
        ),
      );
    }

    return _AssetPrimaryAction.swap(
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

  factory _AssetPrimaryAction.receive(VoidCallback onTap) {
    return _AssetPrimaryAction(
      icon: Icons.call_received_rounded,
      label: 'Receive',
      onTap: onTap,
    );
  }

  factory _AssetPrimaryAction.swap(VoidCallback onTap) {
    return _AssetPrimaryAction(
      icon: Icons.swap_horiz_rounded,
      label: 'Swap',
      onTap: onTap,
    );
  }

  final IconData icon;
  final String label;
  final VoidCallback onTap;
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

Future<void> _openWebsite(BuildContext context, String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) {
    return;
  }

  final didLaunch = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!didLaunch && context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Could not open website.')));
  }
}

class _HeaderBar extends StatelessWidget {
  const _HeaderBar({required this.name, required this.symbol, this.logoUrl});

  final String name;
  final String symbol;
  final String? logoUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _TokenLogo(
                symbol: Formatters.tokenSymbol(symbol),
                iconUrl: logoUrl,
                size: 40,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontSize: 22,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 56),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.primaryIcon,
    required this.primaryLabel,
    required this.onPrimaryAction,
    required this.onSend,
    required this.onCopy,
  });

  final IconData primaryIcon;
  final String primaryLabel;
  final VoidCallback onPrimaryAction;
  final VoidCallback onSend;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: _ActionTile(
            icon: primaryIcon,
            label: primaryLabel,
            onTap: onPrimaryAction,
            tint: theme.colorScheme.secondaryContainer,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionTile(
            icon: Icons.send_rounded,
            label: 'Send',
            onTap: onSend,
            tint: theme.colorScheme.tertiaryContainer,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionTile(
            icon: Icons.copy_rounded,
            label: 'Copy',
            onTap: onCopy,
            tint: theme.colorScheme.primaryContainer,
          ),
        ),
      ],
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
          label: 'Receive',
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
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.data});

  final _InfoRowData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Row(
        children: [
          Expanded(
            child: Text(
              data.label,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: GestureDetector(
              onTap: data.linkUrl == null
                  ? null
                  : () => _openWebsite(context, data.linkUrl!),
              child: Text(
                data.value,
                textAlign: TextAlign.end,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: data.linkUrl == null
                      ? AppColors.textPrimary
                      : theme.colorScheme.primary,
                  decoration: data.linkUrl == null
                      ? null
                      : TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
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
    final swapTitle = switch (item.direction) {
      TransactionDirection.sent =>
        item.relatedSymbol.isEmpty ? 'Swap Out' : 'To ${item.relatedSymbol}',
      TransactionDirection.received =>
        item.relatedSymbol.isEmpty ? 'Swap In' : 'From ${item.relatedSymbol}',
      TransactionDirection.unknown => 'Swap',
    };
    final title = switch ((item.kind, item.direction)) {
      (TransactionKind.swap, _) => swapTitle,
      (_, TransactionDirection.sent) => 'Sent',
      (_, TransactionDirection.received) => 'Received',
      (_, TransactionDirection.unknown) => 'Activity',
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
            ? 'Swap'
            : 'Swap  •  ${Formatters.relativeTime(item.timestamp!)}',
      TransactionKind.transfer =>
        item.counterparty.isEmpty
            ? (item.timestamp == null
                  ? 'Transfer'
                  : Formatters.relativeTime(item.timestamp!))
            : (item.timestamp == null
                  ? Formatters.compactAddress(
                      item.counterparty,
                      visibleChars: 5,
                    )
                  : '${Formatters.compactAddress(item.counterparty, visibleChars: 5)}  •  ${Formatters.relativeTime(item.timestamp!)}'),
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

    return Container(
      width: size,
      height: size,
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
                child: Image.network(
                  iconUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Center(
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
    );
  }
}
