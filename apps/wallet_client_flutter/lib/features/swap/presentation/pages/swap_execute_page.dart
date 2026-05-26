import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/di/providers.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../auth/domain/wallet_controller_state.dart';
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
  static const _insufficientSwapBalanceMessage =
      'Not enough SOL.\nNeed 0.01 SOL reserve.';

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
          style: success
              ? theme.textTheme.titleLarge
              : theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 18,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
          textScaler: success ? null : TextScaler.noScaling,
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

    final publicKey = walletState.publicKey;
    if (publicKey == null) {
      _finish(errorMessage: 'Wallet address is unavailable.');
      return;
    }

    try {
      final signature = await _buildSignAndSendSwap(
        ownerAddress: publicKey,
        custody: walletState.custody,
      );
      ref.invalidate(portfolioProvider(publicKey));
      _finish(signature: signature);
    } catch (error, stackTrace) {
      developer.log(
        'Swap execute failed',
        name: 'BennySwap',
        error: error,
        stackTrace: stackTrace,
      );
      // ignore: avoid_print
      print('BennySwap: Swap execute failed: $error\n$stackTrace');
      _finish(errorMessage: _friendlyError(error));
    }
  }

  Future<String> _buildSignAndSendSwap({
    required String ownerAddress,
    required WalletCustody custody,
  }) async {
    final encodedTransactions = await _buildFreshSwapTransactions(
      ownerAddress: ownerAddress,
    );
    final solana = ref.read(solanaWalletServiceProvider);
    final refreshedTransactions = <String>[];
    for (final encodedTransaction in encodedTransactions) {
      refreshedTransactions.add(
        await solana.refreshPreparedTransactionBlockhash(
          encodedTransaction: encodedTransaction,
        ),
      );
    }
    return custody == WalletCustody.mobileWalletAdapter
        ? await _signAndSendSwapWithMobileWalletAdapter(refreshedTransactions)
        : custody == WalletCustody.seedVault
        ? await _signAndSendSwapWithSeedVault(refreshedTransactions)
        : await _signAndSendSwapWithLocalMnemonic(
            encodedTransactions: refreshedTransactions,
          );
  }

  Future<List<String>> _buildFreshSwapTransactions({
    required String ownerAddress,
  }) async {
    final review = widget.review;
    final buildResult = await ref
        .read(swapRepositoryProvider)
        .buildSwap(
          ownerAddress: ownerAddress,
          inputMint: review.inputToken.token.mintAddress,
          outputMint: review.outputToken.token.mintAddress,
          rawAmount: review.buildResult.inAmount,
          slippageBps: review.slippageBps,
          priorityPreset: review.priorityPreset.apiValue,
        );
    if (buildResult.swapTransactions.isEmpty) {
      throw StateError('Swap transaction is unavailable.');
    }
    return buildResult.swapTransactions;
  }

  Future<String> _signAndSendSwapWithLocalMnemonic({
    required List<String> encodedTransactions,
  }) async {
    final walletState = ref.read(walletControllerProvider);
    String? mnemonic;
    if (walletState.mnemonicTokenId != null) {
      final ephemeralStore = ref.read(mnemonicEphemeralStoreProvider);
      mnemonic = ephemeralStore.retrieveTemporary(walletState.mnemonicTokenId!);
    } else if (walletState.mnemonic != null) {
      mnemonic = walletState.mnemonic;
    }

    if (mnemonic == null) {
      throw StateError('Unlock the wallet again before swapping.');
    }

    final solana = ref.read(solanaWalletServiceProvider);
    String? lastSignature;
    for (final encodedTransaction in encodedTransactions) {
      lastSignature = await solana.signAndSendPreparedTransaction(
        mnemonic: mnemonic,
        encodedTransaction: encodedTransaction,
        derivation: walletState.derivation,
      );
    }
    if (lastSignature == null) {
      throw StateError('Swap transaction is unavailable.');
    }
    return lastSignature;
  }

  Future<String> _signAndSendSwapWithMobileWalletAdapter(
    List<String> encodedTransactions,
  ) async {
    final authToken = ref.read(walletControllerProvider).mwaAuthToken;
    if (authToken == null || authToken.isEmpty) {
      throw StateError('Connect Seeker Vault again before swapping.');
    }
    final result = await ref
        .read(mobileWalletAdapterServiceProvider)
        .signAndSendTransactions(
          authToken: authToken,
          encodedTransactions: encodedTransactions,
        );
    await ref
        .read(walletControllerProvider.notifier)
        .updateMobileWalletAdapterAuthToken(result.authToken);
    if (result.signatures.length != encodedTransactions.length) {
      throw StateError('Seeker Wallet returned an unexpected signature count.');
    }
    final solana = ref.read(solanaWalletServiceProvider);
    for (final signature in result.signatures) {
      await solana.waitForConfirmation(signature);
    }
    return result.signatures.last;
  }

  Future<String> _signAndSendSwapWithSeedVault(
    List<String> encodedTransactions,
  ) async {
    final walletState = ref.read(walletControllerProvider);
    final authToken = walletState.mwaAuthToken;
    final derivationPath = walletState.seedVaultDerivationPath;
    if (authToken == null ||
        authToken.isEmpty ||
        derivationPath == null ||
        derivationPath.isEmpty) {
      throw StateError('Connect Seed Vault again before swapping.');
    }
    final solana = ref.read(solanaWalletServiceProvider);
    final result = await ref
        .read(mobileWalletAdapterServiceProvider)
        .signSeedVaultMessages(
          authToken: authToken,
          derivationPath: derivationPath,
          messages: encodedTransactions
              .map(solana.signableTransactionMessageBytes)
              .toList(growable: false),
        );
    if (result.signatures.length != encodedTransactions.length) {
      throw StateError('Seed Vault returned an unexpected signature count.');
    }

    String? lastSignature;
    for (var index = 0; index < encodedTransactions.length; index += 1) {
      lastSignature = await solana.sendExternallySignedTransaction(
        encodedTransaction: encodedTransactions[index],
        signature: result.signatures[index],
      );
    }
    if (lastSignature == null) {
      throw StateError('Swap transaction is unavailable.');
    }
    return lastSignature;
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
    if (lower == 'not_tradable' ||
        lower == 'exception: not_tradable' ||
        lower.contains('token_not_tradable') ||
        lower.contains('not tradable')) {
      return "This swap route isn't available right now. Try swapping with SOL or choose another token pair.";
    }
    if (lower.contains('429') || lower.contains('too many requests')) {
      return 'The network is busy. Please try again.';
    }
    if (lower.contains('0x1771') ||
        lower.contains('0x1772') ||
        lower.contains('0x1773') ||
        lower.contains('6001') ||
        lower.contains('6002') ||
        lower.contains('6003') ||
        lower.contains('toomuchsolrequired') ||
        lower.contains('toolittlesolreceived') ||
        lower.contains('slippage tolerance exceeded') ||
        lower.contains('slippage exceeded')) {
      return 'Price moved before the swap was sent. Increase slippage and try again.';
    }
    if (lower.contains('block height') || lower.contains('blockhash')) {
      return 'This quote expired. Review the swap again.';
    }
    if (_isJupiterInsufficientFundsError(lower)) {
      return 'Not enough token balance. Tap Max again and retry.';
    }
    if (_isInsufficientSwapBalanceError(lower)) {
      return _insufficientSwapBalanceMessage;
    }
    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length);
    }
    return message;
  }

  bool _isInsufficientSwapBalanceError(String lower) {
    return lower.contains('custom program error: 0x1') ||
        lower.contains('{custom: 1}') ||
        lower.contains('{custom:1}') ||
        lower.contains('custom: 1') ||
        lower.contains('insufficient lamports') ||
        lower.contains('insufficient balance') ||
        lower.contains('insufficient account balance') ||
        lower.contains('attempt to debit an account') ||
        (lower.contains('insufficient') && lower.contains('rent'));
  }

  bool _isJupiterInsufficientFundsError(String lower) {
    return lower.contains('custom program error: 0x1788') ||
        lower.contains('{custom: 6024}') ||
        lower.contains('{custom:6024}') ||
        lower.contains('custom: 6024') ||
        lower.contains('insufficient funds');
  }

  Future<void> _openTransaction(String signature) async {
    final uri = Uri.parse('https://solscan.io/tx/$signature');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
