import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/formatters.dart';
import '../../../portfolio/presentation/providers/portfolio_provider.dart';
import 'wallet_visuals.dart';

/// Total USD value of a wallet's tokens, loaded (and cached) per wallet.
class WalletBalanceText extends ConsumerWidget {
  const WalletBalanceText({super.key, required this.publicKey});

  final String publicKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolio = ref.watch(displayPortfolioProvider(publicKey));
    final style = Theme.of(context).textTheme.titleMedium?.copyWith(
      color: WalletPalette.ink,
      fontWeight: FontWeight.w800,
    );
    return portfolio.when(
      data: (data) => Text(Formatters.usd(data.totalValueUsd), style: style),
      error: (_, _) =>
          Text('--', style: style?.copyWith(color: WalletPalette.muted)),
      loading: () => const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}
