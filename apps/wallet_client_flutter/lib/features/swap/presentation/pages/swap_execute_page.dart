import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/di/providers.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../auth/presentation/providers/wallet_controller.dart';
import '../../../auth/presentation/providers/ephemeral_store.dart';
import '../../../portfolio/presentation/pages/portfolio_page.dart';
import '../../../portfolio/presentation/providers/portfolio_provider.dart';
import '../../domain/swap_review_data.dart';

class SwapExecutePage extends ConsumerStatefulWidget {
  const SwapExecutePage({super.key, required this.review});

  static const routeName = 'swapExecute';
  static const routePath = '/swap/execute';

  final SwapReviewData review;

  @override
  ConsumerState<SwapExecutePage> createState() => _SwapExecutePageState();
}

class _SwapExecutePageState extends ConsumerState<SwapExecutePage> {
  String? _signature;
  String? _errorMessage;
  bool _processing = true;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_executeSwap);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_processing,
      child: AppScaffold(
        title: '',
        showTopBar: false,
        child: _processing ? _buildPending(context) : _buildResult(context),
      ),
    );
  }

  Widget _buildPending(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        const Spacer(),
        Container(
          width: 152,
          height: 152,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0x142D6CDF),
          ),
          child: const Center(
            child: SizedBox(
              width: 54,
              height: 54,
              child: CircularProgressIndicator(strokeWidth: 4),
            ),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Swapping...',
          style: theme.textTheme.displayLarge?.copyWith(fontSize: 40),
        ),
        const SizedBox(height: 12),
        Text(
          '${Formatters.amount(widget.review.inputAmountUi)} ${widget.review.inputToken.token.symbol} to ${Formatters.amount(widget.review.outputAmountUi)} ${widget.review.outputToken.token.symbol}',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge,
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildResult(BuildContext context) {
    final success = _signature != null;
    final theme = Theme.of(context);

    return Column(
      children: [
        const Spacer(),
        Container(
          width: 152,
          height: 152,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: success
                ? const Color(0x192FA36B)
                : theme.colorScheme.errorContainer.withValues(alpha: 0.4),
          ),
          child: Icon(
            success ? Icons.check_rounded : Icons.error_outline_rounded,
            size: 72,
            color: success
                ? const Color(0xFF2FA36B)
                : theme.colorScheme.onErrorContainer,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          success ? 'Swap complete' : 'Swap failed',
          style: theme.textTheme.displayLarge?.copyWith(fontSize: 40),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          success
              ? '${Formatters.amount(widget.review.outputAmountUi)} ${widget.review.outputToken.token.symbol} received'
              : (_errorMessage ?? 'The swap could not be completed.'),
          style: theme.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        if (success) ...[
          const SizedBox(height: 22),
          TextButton(
            onPressed: () => _openTransaction(_signature!),
            child: const Text('View transaction'),
          ),
        ],
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: FilledButton.tonal(
            onPressed: () => context.go(PortfolioPage.routePath),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(58),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
            ),
            child: const Text('Close'),
          ),
        ),
      ],
    );
  }

  Future<void> _executeSwap() async {
    final walletState = ref.read(walletControllerProvider);

    // 🔐 Get mnemonic from ephemeral store using token
    String? mnemonic;
    if (walletState.mnemonicTokenId != null) {
      final ephemeralStore = ref.read(mnemonicEphemeralStoreProvider);
      mnemonic = ephemeralStore.retrieveTemporary(walletState.mnemonicTokenId!);
    } else if (walletState.mnemonic != null) {
      // Fallback for legacy code path
      mnemonic = walletState.mnemonic;
    }

    final publicKey = walletState.publicKey;
    if (mnemonic == null) {
      _finish(errorMessage: 'Unlock the wallet again before swapping.');
      return;
    }
    if (publicKey == null) {
      _finish(errorMessage: 'Wallet address is unavailable.');
      return;
    }

    try {
      final rawAmount = ref
          .read(solanaWalletServiceProvider)
          .tokenUiToAmount(
            widget.review.inputAmountUi,
            widget.review.inputToken.token.decimals,
          )
          .toString();
      final refreshedBuild = await ref
          .read(swapRepositoryProvider)
          .buildSwap(
            ownerAddress: publicKey,
            inputMint: widget.review.inputToken.token.mintAddress,
            outputMint: widget.review.outputToken.token.mintAddress,
            rawAmount: rawAmount,
            slippageBps: widget.review.slippageBps,
            priorityPreset: widget.review.priorityPreset.apiValue,
          );
      final signature = await ref
          .read(solanaWalletServiceProvider)
          .signAndSendPreparedTransaction(
            mnemonic: mnemonic,
            encodedTransaction: refreshedBuild.swapTransaction,
            derivation: walletState.derivation,
          );
      ref.invalidate(portfolioProvider(publicKey));
      _finish(signature: signature);
    } catch (error) {
      debugPrint('Swap execute failed: $error');
      _finish(errorMessage: _friendlyError(error));
    }
  }

  void _finish({String? signature, String? errorMessage}) {
    if (!mounted) {
      return;
    }
    setState(() {
      _processing = false;
      _signature = signature;
      _errorMessage = errorMessage;
    });
  }

  String _friendlyError(Object error) {
    final message = error.toString();
    final lower = message.toLowerCase();
    if (lower.contains('429') || lower.contains('too many requests')) {
      return 'The network is busy. Please try again.';
    }
    if (lower.contains('0x1771') ||
        lower.contains('6001') ||
        lower.contains('slippage tolerance exceeded') ||
        lower.contains('slippage exceeded')) {
      return 'Price moved before the swap was sent. Try again or increase slippage.';
    }
    if (lower.contains('block height') || lower.contains('blockhash')) {
      return 'This quote expired. Review the swap again.';
    }
    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length);
    }
    return message;
  }

  Future<void> _openTransaction(String signature) async {
    final uri = Uri.parse('https://solscan.io/tx/$signature');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
