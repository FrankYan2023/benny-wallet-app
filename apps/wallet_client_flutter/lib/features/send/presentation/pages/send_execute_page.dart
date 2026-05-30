import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/di/providers.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../l10n/l10n.dart';
import '../../../auth/domain/wallet_controller_state.dart';
import '../../../auth/presentation/providers/wallet_controller.dart';
import '../../../auth/presentation/providers/ephemeral_store.dart';
import '../../../portfolio/presentation/pages/portfolio_page.dart';
import '../../../portfolio/presentation/providers/portfolio_provider.dart';
import '../../domain/send_draft_data.dart';
import '../../domain/send_result_data.dart';

class SendExecutePage extends ConsumerStatefulWidget {
  const SendExecutePage({super.key, required this.draft});

  static const routeName = 'sendExecute';
  static const routePath = '/send/execute';

  final SendDraftData draft;

  @override
  ConsumerState<SendExecutePage> createState() => _SendExecutePageState();
}

class _SendExecutePageState extends ConsumerState<SendExecutePage> {
  static const _balanceTolerance = 0.000000001;

  SendResultData? _result;
  bool _sending = true;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_send);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_sending,
      child: AppScaffold(
        title: '',
        showTopBar: false,
        child: _sending ? _buildPending(context) : _buildResult(context),
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
          context.l10n.sendSubmitting,
          style: theme.textTheme.displayLarge?.copyWith(fontSize: 40),
        ),
        const SizedBox(height: 12),
        Text(
          context.l10n.sendSubmittingSummary(
            Formatters.compactAddress(
              widget.draft.destinationAddress,
              visibleChars: 5,
            ),
            widget.draft.amountDisplay,
            Formatters.tokenSymbol(widget.draft.token.symbol),
          ),
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge,
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildResult(BuildContext context) {
    final result = _result!;
    final success = result.success;
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
          success ? context.l10n.sendSubmitted : context.l10n.sendFailed,
          style: theme.textTheme.displayLarge?.copyWith(fontSize: 42),
        ),
        const SizedBox(height: 12),
        Text(
          success
              ? context.l10n.sendSubmittedMessage(
                  Formatters.compactAddress(
                    result.destinationAddress,
                    visibleChars: 5,
                  ),
                  result.amountDisplay,
                  result.symbol,
                )
              : (result.message ??
                    context.l10n.sendTransactionCouldNotComplete),
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge,
        ),
        if (success && result.signature != null) ...[
          const SizedBox(height: 22),
          TextButton(
            onPressed: () => _openTransaction(result.signature!),
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

  Future<void> _send() async {
    final walletState = ref.read(walletControllerProvider);

    try {
      final solana = ref.read(solanaWalletServiceProvider);
      final currentAddress = walletState.publicKey;
      if (currentAddress == null) {
        throw StateError('Wallet address is unavailable.');
      }
      final solBalance = solana.lamportsToSol(
        await solana.getSolBalanceLamports(ownerAddress: currentAddress),
      );
      final reservedRentSol = widget.draft.token.isNative
          ? solana.lamportsToSol(
              await solana.getSystemAccountRentExemptMinimumLamports(),
            )
          : 0.0;
      if (!widget.draft.token.isNative &&
          widget.draft.estimatedNetworkFeeSol >
              solBalance + _balanceTolerance) {
        throw StateError('Not enough SOL to cover the network fee.');
      }
      var amountToSend = widget.draft.amount;
      if (widget.draft.token.isNative &&
          widget.draft.amount +
                  widget.draft.estimatedNetworkFeeSol +
                  reservedRentSol >
              solBalance + _balanceTolerance) {
        if (widget.draft.isMaxAmount) {
          final adjustedAmount =
              solBalance -
              widget.draft.estimatedNetworkFeeSol -
              reservedRentSol;
          if (adjustedAmount <= _balanceTolerance) {
            throw StateError('Not enough SOL after reserving the network fee.');
          }
          amountToSend = adjustedAmount;
        } else {
          throw StateError('Not enough SOL after reserving the network fee.');
        }
      }
      if (widget.draft.token.isNative && amountToSend <= _balanceTolerance) {
        throw StateError('Not enough SOL after reserving the network fee.');
      }

      final signature = walletState.custody == WalletCustody.mobileWalletAdapter
          ? await _sendWithMobileWalletAdapter(
              ownerAddress: currentAddress,
              amountToSend: amountToSend,
            )
          : walletState.custody == WalletCustody.seedVault
          ? await _sendWithSeedVault(
              ownerAddress: currentAddress,
              amountToSend: amountToSend,
            )
          : await _sendWithLocalMnemonic(
              walletState: walletState,
              amountToSend: amountToSend,
            );

      ref.invalidate(portfolioProvider(currentAddress));
      _finishWithResult(
        SendResultData(
          success: true,
          signature: signature,
          amountDisplay: Formatters.amount(amountToSend),
          symbol: Formatters.tokenSymbol(widget.draft.token.symbol),
          destinationAddress: widget.draft.destinationAddress,
        ),
      );
    } catch (error) {
      debugPrint('Send execute failed: $error');
      _finishWithResult(
        SendResultData(
          success: false,
          signature: null,
          amountDisplay: widget.draft.amountDisplay,
          symbol: Formatters.tokenSymbol(widget.draft.token.symbol),
          destinationAddress: widget.draft.destinationAddress,
          message: _friendlySendError(error, context.l10n),
        ),
      );
    }
  }

  Future<String> _sendWithLocalMnemonic({
    required WalletControllerState walletState,
    required double amountToSend,
  }) async {
    String? mnemonic;
    if (walletState.mnemonicTokenId != null) {
      final ephemeralStore = ref.read(mnemonicEphemeralStoreProvider);
      mnemonic = ephemeralStore.retrieveTemporary(walletState.mnemonicTokenId!);
    } else if (walletState.mnemonic != null) {
      mnemonic = walletState.mnemonic;
    }

    if (mnemonic == null) {
      throw StateError('Unlock the wallet again before sending.');
    }

    final solana = ref.read(solanaWalletServiceProvider);
    return widget.draft.token.isNative
        ? solana.sendSol(
            mnemonic: mnemonic,
            destinationAddress: widget.draft.destinationAddress,
            lamports: solana.solToLamports(amountToSend),
            derivation: walletState.derivation,
            submissionAmount:
                '${Formatters.amount(amountToSend)} ${Formatters.tokenSymbol(widget.draft.token.symbol)}',
          )
        : solana.sendSplToken(
            mnemonic: mnemonic,
            token: widget.draft.token,
            destinationAddress: widget.draft.destinationAddress,
            amount: solana.tokenUiToAmount(
              widget.draft.amount,
              widget.draft.token.decimals,
            ),
            derivation: walletState.derivation,
            submissionAmount:
                '${Formatters.amount(widget.draft.amount)} ${Formatters.tokenSymbol(widget.draft.token.symbol)}',
          );
  }

  Future<String> _sendWithMobileWalletAdapter({
    required String ownerAddress,
    required double amountToSend,
  }) async {
    final authToken = ref.read(walletControllerProvider).mwaAuthToken;
    if (authToken == null || authToken.isEmpty) {
      throw StateError('Connect Seeker Vault again before sending.');
    }

    final solana = ref.read(solanaWalletServiceProvider);
    final encodedTransaction = widget.draft.token.isNative
        ? await solana.buildSolTransferTransaction(
            ownerAddress: ownerAddress,
            destinationAddress: widget.draft.destinationAddress,
            lamports: solana.solToLamports(amountToSend),
          )
        : await solana.buildSplTokenTransferTransaction(
            ownerAddress: ownerAddress,
            token: widget.draft.token,
            destinationAddress: widget.draft.destinationAddress,
            amount: solana.tokenUiToAmount(
              widget.draft.amount,
              widget.draft.token.decimals,
            ),
          );
    final result = await ref
        .read(mobileWalletAdapterServiceProvider)
        .signAndSendTransactions(
          authToken: authToken,
          encodedTransactions: [encodedTransaction],
        );
    await ref
        .read(walletControllerProvider.notifier)
        .updateMobileWalletAdapterAuthToken(result.authToken);
    final signature = result.signatures.first;
    await solana.waitForConfirmation(signature);
    return signature;
  }

  Future<String> _sendWithSeedVault({
    required String ownerAddress,
    required double amountToSend,
  }) async {
    final walletState = ref.read(walletControllerProvider);
    final authToken = walletState.mwaAuthToken;
    final derivationPath = walletState.seedVaultDerivationPath;
    if (authToken == null ||
        authToken.isEmpty ||
        derivationPath == null ||
        derivationPath.isEmpty) {
      throw StateError('Connect Seed Vault again before sending.');
    }

    final solana = ref.read(solanaWalletServiceProvider);
    final encodedTransaction = widget.draft.token.isNative
        ? await solana.buildSolTransferTransaction(
            ownerAddress: ownerAddress,
            destinationAddress: widget.draft.destinationAddress,
            lamports: solana.solToLamports(amountToSend),
          )
        : await solana.buildSplTokenTransferTransaction(
            ownerAddress: ownerAddress,
            token: widget.draft.token,
            destinationAddress: widget.draft.destinationAddress,
            amount: solana.tokenUiToAmount(
              widget.draft.amount,
              widget.draft.token.decimals,
            ),
          );
    final result = await ref
        .read(mobileWalletAdapterServiceProvider)
        .signSeedVaultMessages(
          authToken: authToken,
          derivationPath: derivationPath,
          messages: [
            solana.signableTransactionMessageBytes(encodedTransaction),
          ],
        );
    return solana.sendExternallySignedTransaction(
      encodedTransaction: encodedTransaction,
      signature: result.signatures.first,
      submitViaSender: true,
      txType: 'send',
      fromMint: widget.draft.token.mintAddress,
      toMint: widget.draft.token.mintAddress,
      amount:
          '${Formatters.amount(amountToSend)} ${Formatters.tokenSymbol(widget.draft.token.symbol)}',
      destinationAddress: widget.draft.destinationAddress,
    );
  }

  void _finishWithResult(SendResultData result) {
    if (!mounted) {
      return;
    }
    setState(() {
      _sending = false;
      _result = result;
    });
  }

  String _friendlySendError(Object error, AppLocalizations l10n) {
    final message = error.toString();
    final lower = message.toLowerCase();
    final genericSendFailure = l10n.sendGenericFailure;

    if (lower.contains('associated token account')) {
      return l10n.sendRecipientNotReady;
    }
    if (lower.contains('429') || lower.contains('retryable error')) {
      return l10n.sendNetworkBusy;
    }
    if (lower.contains('timed out') || lower.contains('timeout')) {
      return l10n.sendNetworkTakingLonger;
    }
    if (lower.contains('insufficient') ||
        lower.contains('insufficient funds') ||
        lower.contains('insufficient lamports') ||
        lower.contains('fee payer')) {
      return l10n.sendNotEnoughSolForFee;
    }
    if (lower.contains('blockhash')) {
      return l10n.sendNetworkBusy;
    }
    if (lower.contains('http status code') ||
        lower.contains('jsonrpc') ||
        lower.contains('rpc method not allowed') ||
        lower.contains('the following content') ||
        lower.contains('dioexception') ||
        lower.contains('bad response')) {
      return genericSendFailure;
    }

    return genericSendFailure;
  }

  Future<void> _openTransaction(String signature) async {
    final uri = Uri.parse('https://solscan.io/tx/$signature');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

extension on SendDraftData {
  String get amountDisplay => Formatters.amount(amount);
}
