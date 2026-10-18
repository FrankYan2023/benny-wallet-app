import 'dart:developer' as developer;
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solana/base58.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/di/providers.dart';
import '../../../../core/airgap/airgap_protocol.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../l10n/l10n.dart';
import '../../../auth/domain/wallet_controller_state.dart';
import '../../../auth/presentation/providers/wallet_controller.dart';
import '../../../auth/presentation/providers/ephemeral_store.dart';
import '../../../portfolio/presentation/pages/portfolio_page.dart';
import '../../../portfolio/presentation/providers/portfolio_provider.dart';
import '../../domain/swap_build_result.dart';
import '../../domain/swap_quote_result.dart';
import '../../domain/swap_review_data.dart';
import '../../domain/swap_token_option.dart';

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
          context.l10n.swapProcessing,
          style: theme.textTheme.displayLarge?.copyWith(fontSize: 40),
        ),
        const SizedBox(height: 12),
        Text(
          context.l10n.swapProcessingSummary(
            Formatters.amount(widget.review.inputAmountUi),
            widget.review.inputToken.token.symbol,
            Formatters.amount(widget.review.outputAmountUi),
            widget.review.outputToken.token.symbol,
          ),
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
          success ? context.l10n.swapComplete : context.l10n.swapFailed,
          style: theme.textTheme.displayLarge?.copyWith(fontSize: 40),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          success
              ? context.l10n.swapReceivedAmount(
                  Formatters.amount(widget.review.outputAmountUi),
                  widget.review.outputToken.token.symbol,
                )
              : (_errorMessage ?? context.l10n.swapCouldNotComplete),
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
            child: Text(context.l10n.sendViewTransaction),
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
            child: Text(context.l10n.commonClose),
          ),
        ),
      ],
    );
  }

  Future<void> _executeSwap() async {
    final walletState = ref.read(walletControllerProvider);
    final l10n = context.l10n;

    final publicKey = walletState.publicKey;
    if (publicKey == null) {
      _finish(errorMessage: l10n.walletAddressUnavailable);
      return;
    }
    if (publicKey != widget.review.ownerAddress) {
      // The active wallet changed after the quote; never sign it elsewhere.
      _finish(errorMessage: l10n.swapWalletChanged);
      return;
    }

    try {
      final signature = await _buildSignAndSendSwap(
        ownerAddress: publicKey,
        custody: walletState.custody,
      );
      if (mounted) {
        refreshBalancesAfterTransaction(
          ProviderScope.containerOf(context, listen: false),
          signature: signature,
          addresses: [publicKey],
        );
      }
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
      _finish(errorMessage: _friendlyError(error, l10n));
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
        : custody == WalletCustody.airGap
        ? await _signAndSendSwapWithAirGap(
            ownerAddress: ownerAddress,
            encodedTransactions: refreshedTransactions,
          )
        : await _signAndSendSwapWithLocalMnemonic(
            encodedTransactions: refreshedTransactions,
          );
  }

  Future<SwapBuildResult> _buildFreshSwap({
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
    return buildResult;
  }

  Future<List<String>> _buildFreshSwapTransactions({
    required String ownerAddress,
  }) async =>
      (await _buildFreshSwap(ownerAddress: ownerAddress)).swapTransactions;

  /// The quote shown on the offline signer next to the swap.
  AirGapSwapSummary? _swapSummary(SwapQuoteResult quote) {
    final inputAmount = BigInt.tryParse(quote.inAmount);
    final outputAmount = BigInt.tryParse(quote.outAmount);
    if (inputAmount == null || outputAmount == null) {
      return null;
    }
    try {
      return AirGapSwapSummary(
        // The swap API names native SOL by the wrapped SOL mint.
        inputMint: Uint8List.fromList(base58decode(quote.inputMint)),
        inputAmount: inputAmount,
        outputMint: Uint8List.fromList(base58decode(quote.outputMint)),
        outputAmount: outputAmount,
      );
    } on Object {
      return null;
    }
  }

  /// USD per whole token for the offline signer, keyed like the quote
  /// (native SOL as wrapped SOL). A token the wallet holds none of has no
  /// price of its own, so it is valued at what the quote pays for it.
  Map<String, double> _usdPrices(SwapQuoteResult quote) {
    final review = widget.review;
    double? unit(SwapTokenOption token) =>
        token.availableBalance > 0 && token.totalValueUsd > 0
        ? token.totalValueUsd / token.availableBalance
        : null;
    double? whole(String raw, SwapTokenOption token) {
      final value = double.tryParse(raw);
      return value == null ? null : value / pow(10, token.token.decimals);
    }

    var inPrice = unit(review.inputToken);
    var outPrice = unit(review.outputToken);
    final inAmount = whole(quote.inAmount, review.inputToken);
    final outAmount = whole(quote.outAmount, review.outputToken);
    if (inAmount != null &&
        outAmount != null &&
        inAmount > 0 &&
        outAmount > 0) {
      if (outPrice == null && inPrice != null) {
        outPrice = inPrice * inAmount / outAmount;
      } else if (inPrice == null && outPrice != null) {
        inPrice = outPrice * outAmount / inAmount;
      }
    }
    return {
      if (inPrice != null) quote.inputMint: inPrice,
      if (outPrice != null) quote.outputMint: outPrice,
    };
  }

  /// One QR round trip per transaction; each is sent before the next is
  /// signed. If time runs out while signing, a single-transaction swap is
  /// quoted and built again; otherwise the blockhash is renewed.
  Future<String> _signAndSendSwapWithAirGap({
    required String ownerAddress,
    required List<String> encodedTransactions,
  }) async {
    final solana = ref.read(solanaWalletServiceProvider);
    final signer = ref.read(airGapSigningServiceProvider);
    final review = widget.review;
    final tokens = [review.inputToken.token, review.outputToken.token];
    var summary = _swapSummary(review.buildResult);
    var prices = _usdPrices(review.buildResult);
    String? lastSignature;
    for (final encodedTransaction in encodedTransactions) {
      final requote = encodedTransactions.length == 1;
      final signed = await signer.signTransaction(
        ownerAddress: ownerAddress,
        encodedTransaction: encodedTransaction,
        tokens: tokens,
        swap: () => summary,
        usdPrices: () => prices,
        rebuild: () async {
          if (!requote) {
            return solana.refreshPreparedTransactionBlockhash(
              encodedTransaction: encodedTransaction,
            );
          }
          final fresh = await _buildFreshSwap(ownerAddress: ownerAddress);
          if (fresh.swapTransactions.length != 1) {
            throw StateError('The new quote needs a different route.');
          }
          summary = _swapSummary(fresh);
          prices = _usdPrices(fresh);
          return solana.refreshPreparedTransactionBlockhash(
            encodedTransaction: fresh.swapTransactions.single,
          );
        },
      );
      lastSignature = await solana.sendExternallySignedTransaction(
        encodedTransaction: signed.transaction,
        signature: signed.signature,
      );
    }
    if (lastSignature == null) {
      throw StateError('Swap transaction is unavailable.');
    }
    return lastSignature;
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
          ownerAddress: walletState.publicKey,
          onAccountChanged: (newToken, newPath) => ref
              .read(walletControllerProvider.notifier)
              .updateSeedVaultAccount(
                publicKey: walletState.publicKey!,
                oldToken: authToken,
                newToken: newToken,
                derivationPath: newPath,
              ),
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

  String _friendlyError(Object error, AppLocalizations l10n) {
    final message = error.toString();
    final lower = message.toLowerCase();
    if (lower == 'not_tradable' ||
        lower == 'exception: not_tradable' ||
        lower.contains('token_not_tradable') ||
        lower.contains('not tradable')) {
      return l10n.swapRouteUnavailable;
    }
    if (lower.contains('unlock the wallet')) {
      return l10n.swapUnlockAgain;
    }
    if (lower.contains('swap transaction is unavailable')) {
      return l10n.swapTransactionUnavailable;
    }
    if (lower.contains('connect seeker vault')) {
      return l10n.swapConnectSeekerVaultAgain;
    }
    if (lower.contains('connect seed vault')) {
      return l10n.swapConnectSeedVaultAgain;
    }
    if (lower.contains('unexpected signature count')) {
      return l10n.swapUnexpectedSignatureCount;
    }
    if (lower.contains('429') || lower.contains('too many requests')) {
      return l10n.sendNetworkBusy;
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
      return l10n.swapPriceMoved;
    }
    if (lower.contains('block height') || lower.contains('blockhash')) {
      return l10n.swapQuoteExpired;
    }
    if (_isJupiterInsufficientFundsError(lower)) {
      return l10n.swapNotEnoughTokenBalance;
    }
    if (_isInsufficientSwapBalanceError(lower)) {
      return l10n.swapNotEnoughSolReserve('0.01');
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
