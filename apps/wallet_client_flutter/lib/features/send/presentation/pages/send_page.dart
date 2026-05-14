import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../auth/presentation/providers/wallet_controller.dart';
import '../../../portfolio/domain/entities/portfolio_view_data.dart';
import '../../../portfolio/presentation/providers/portfolio_provider.dart';
import '../../../receive/presentation/pages/receive_page.dart';
import 'send_compose_page.dart';
import 'send_history_page.dart';

class SendPage extends ConsumerWidget {
  const SendPage({super.key, this.recipientAddress});

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
  Widget build(BuildContext context, WidgetRef ref) {
    final walletState = ref.watch(walletControllerProvider);
    final normalizedRecipient = recipientAddress?.trim();

    if (walletState.childModeEnabled) {
      return AppScaffold(
        title: 'Send',
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_rounded, size: 40),
                const SizedBox(height: 12),
                const Text(
                  'Send is unavailable in child mode.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => context.go(ReceivePage.routePath),
                  child: const Text('Open Receive'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final portfolio = ref.watch(activePortfolioProvider);

    return AppScaffold(
      title: 'Choose asset',
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
            tooltip: 'Send history',
            onPressed: () => context.push(SendHistoryPage.routePath),
            icon: const Icon(Icons.history_rounded),
          ),
        ),
      ],
      child: portfolio.when(
        data: (data) {
          final assets = data.assets
              .where((asset) => asset.balance > 0)
              .toList();

          if (assets.isEmpty) {
            return const Center(child: Text('No assets available to send.'));
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
                        'Recipient prefilled',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        Formatters.compactAddress(
                          normalizedRecipient,
                          visibleChars: 6,
                        ),
                        style: Theme.of(context).textTheme.bodyMedium,
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
                  symbol: Formatters.tokenSymbol(asset.token.symbol),
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
        error: (error, _) =>
            Center(child: Text('Failed to load assets: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
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
