import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/di/providers.dart';
import '../../../../core/services/mobile_wallet_adapter_service.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../l10n/l10n.dart';
import '../../../auth/domain/wallet_controller_state.dart';
import '../../../auth/presentation/providers/wallet_controller.dart';
import '../../../auth/presentation/providers/ephemeral_store.dart';
import '../../../portfolio/domain/entities/portfolio_view_data.dart';
import '../../../portfolio/presentation/pages/portfolio_page.dart';
import '../../../wallets/data/seed_vault_seed_names.dart';
import '../../../wallets/presentation/widgets/wallet_visuals.dart';
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

  /// Exact amount for a "send all SOL" transfer, so no rounding is left over.
  int? _exactLamports;
  // SPL tokens: exact base units resolved at send time.
  int? _exactTokenAmount;
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
      if (widget.draft.token.isNative && widget.draft.isMaxAmount) {
        // "Max" empties the wallet to exactly 0 SOL, priced at send time.
        final maxLamports = await solana.maxSendableSolLamports(
          ownerAddress: currentAddress,
          destinationAddress: widget.draft.destinationAddress,
        );
        if (maxLamports <= 0) {
          throw StateError('Not enough SOL to cover the network fee.');
        }
        _exactLamports = maxLamports;
        amountToSend = solana.lamportsToSol(maxLamports);
      } else if (!widget.draft.token.isNative) {
        // Exact base units: the whole raw balance for max, otherwise the
        // typed amount converted with the account's own scale (xStocks).
        final rawAmount = widget.draft.isMaxAmount
            ? await solana.tokenRawBalance(
                ownerAddress: currentAddress,
                token: widget.draft.token,
              )
            : await solana.tokenRawAmountForUi(
                ownerAddress: currentAddress,
                token: widget.draft.token,
                uiAmount: widget.draft.amount,
              );
        if (rawAmount <= 0) {
          throw StateError('Nothing to send.');
        }
        _exactTokenAmount = rawAmount;
      } else if (widget.draft.token.isNative &&
          widget.draft.amount +
                  widget.draft.estimatedNetworkFeeSol +
                  reservedRentSol >
              solBalance + _balanceTolerance) {
        throw StateError('Not enough SOL after reserving the network fee.');
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

      // Sender submissions return before the transaction lands; a transfer
      // that fails on chain must not be shown as sent.
      try {
        await solana.waitForConfirmation(signature);
      } on TimeoutException {
        // Still pending: keep the submitted result, balances refresh later.
      }

      _recordPendingTransfer(
        fromAddress: currentAddress,
        amountSent: amountToSend,
        emptiedSol: _exactLamports != null,
      );
      _refreshBalancesAfterSend(
        signature: signature,
        // The recipient may be another of the user's wallets.
        addresses: [currentAddress, widget.draft.destinationAddress],
      );
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
            lamports: _exactLamports ?? solana.solToLamports(amountToSend),
            derivation: walletState.derivation,
            submissionAmount:
                '${Formatters.amount(amountToSend)} ${Formatters.tokenSymbol(widget.draft.token.symbol)}',
          )
        : solana.sendSplToken(
            mnemonic: mnemonic,
            token: widget.draft.token,
            destinationAddress: widget.draft.destinationAddress,
            amount:
                _exactTokenAmount ??
                solana.tokenUiToAmount(
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
            lamports: _exactLamports ?? solana.solToLamports(amountToSend),
          )
        : await solana.buildSplTokenTransferTransaction(
            ownerAddress: ownerAddress,
            token: widget.draft.token,
            destinationAddress: widget.draft.destinationAddress,
            amount:
                _exactTokenAmount ??
                solana.tokenUiToAmount(
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
            lamports: _exactLamports ?? solana.solToLamports(amountToSend),
          )
        : await solana.buildSplTokenTransferTransaction(
            ownerAddress: ownerAddress,
            token: widget.draft.token,
            destinationAddress: widget.draft.destinationAddress,
            amount:
                _exactTokenAmount ??
                solana.tokenUiToAmount(
                  widget.draft.amount,
                  widget.draft.token.decimals,
                ),
          );
    final messages = [
      solana.signableTransactionMessageBytes(encodedTransaction),
    ];
    final seedVault = ref.read(mobileWalletAdapterServiceProvider);
    SeedVaultSignResult result;
    try {
      result = await seedVault.signSeedVaultMessages(
        authToken: authToken,
        derivationPath: derivationPath,
        messages: messages,
        ownerAddress: ownerAddress,
        onAccountChanged: (newToken, newPath) => ref
            .read(walletControllerProvider.notifier)
            .updateSeedVaultAccount(
              publicKey: ownerAddress,
              oldToken: authToken,
              newToken: newToken,
              derivationPath: newPath,
            ),
      );
    } on PlatformException catch (error) {
      if (error.code != 'seed_vault_sign_failed') {
        rethrow;
      }
      // Seed Vault drops an app's authorization when the app is reinstalled
      // or updated; re-authorize once and retry with the new token.
      final freshToken = await _reauthorizeSeedVault(
        ownerAddress: ownerAddress,
        staleAuthToken: authToken,
      );
      if (freshToken == null) {
        rethrow;
      }
      result = await seedVault.signSeedVaultMessages(
        authToken: freshToken,
        derivationPath: derivationPath,
        messages: messages,
      );
    }
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

  /// New Seed Vault auth token for [ownerAddress] when the stored one is no
  /// longer authorized, or null when authorization is not the problem (e.g.
  /// the user cancelled) or the user gives up.
  Future<String?> _reauthorizeSeedVault({
    required String ownerAddress,
    required String staleAuthToken,
  }) async {
    final seedVault = ref.read(mobileWalletAdapterServiceProvider);
    final seedNames = ref.read(seedVaultSeedNamesProvider);
    SeedVaultAccount? findAccount(SeedVaultAccountSnapshot snapshot) => snapshot
        .accounts
        .where((account) => account.publicKey == ownerAddress)
        .firstOrNull;

    final authorized = await seedVault.listSeedVaultAccounts();
    await seedNames.remember(authorized.accounts);
    var account = findAccount(authorized);
    if (account != null && account.seedAuthToken == staleAuthToken) {
      return null;
    }

    if (account == null) {
      debugPrint('[SEED VAULT] Authorization lost; asking to re-authorize.');
      final inUse = await ref
          .read(walletControllerProvider.notifier)
          .seedVaultAuthTokensInUse();
      final seedName = await seedNames.nameFor(ownerAddress);
      // Seeds picked by mistake stay authorized until we're done, which keeps
      // them out of Seed Vault's picker on the next try.
      final wrongTokens = <String>[];
      String? wrongSeedName;
      try {
        while (account == null) {
          if (!mounted ||
              !await _confirmSeedVaultReauthorize(
                ownerAddress: ownerAddress,
                seedName: seedName,
                wrongSeedName: wrongSeedName,
              )) {
            return null;
          }
          final snapshot = await seedVault.authorizeSeedVaultSeed(
            keepAuthTokens: [...inUse, ...wrongTokens],
          );
          account = findAccount(snapshot);
          if (account == null) {
            final picked = snapshot.accounts.firstOrNull;
            if (picked == null) {
              return null;
            }
            wrongTokens.add(picked.seedAuthToken);
            wrongSeedName = picked.seedName ?? '';
          }
        }
      } finally {
        for (final token in wrongTokens) {
          await seedVault.deauthorizeSeedVaultSeed(token);
        }
      }
      await seedNames.remember([account]);
    }
    if (account.seedAuthToken.isEmpty) {
      return null;
    }
    await ref
        .read(walletControllerProvider.notifier)
        .updateMobileWalletAdapterAuthToken(account.seedAuthToken);
    return account.seedAuthToken;
  }

  Future<bool> _confirmSeedVaultReauthorize({
    required String ownerAddress,
    required String? seedName,
    required String? wrongSeedName,
  }) async {
    final l10n = context.l10n;
    final wallet = ref.read(walletControllerProvider).activeWallet;
    final walletLabel =
        '${wallet == null ? '' : walletDisplayName(wallet)}'
        ' (${walletShortAddress(ownerAddress)})';
    final lines = [
      if (wrongSeedName != null) l10n.seedVaultWrongSeedNamed(wrongSeedName),
      if (seedName != null && seedName.isNotEmpty)
        l10n.seedVaultPickNamedSeed(seedName, walletLabel)
      else
        l10n.seedVaultPickUnknownSeed(walletLabel),
    ];
    final proceed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l10n.seedVaultReauthorizeTitle),
        content: Text(lines.join('\n\n')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.commonContinue),
          ),
        ],
      ),
    );
    return proceed == true;
  }

  /// Shows the transfer in both wallets' balances immediately, before the
  /// backend's cached balances catch up.
  void _recordPendingTransfer({
    required String fromAddress,
    required double amountSent,
    required bool emptiedSol,
  }) {
    final container = ProviderScope.containerOf(context, listen: false);
    final token = widget.draft.token;
    final now = DateTime.now();
    final changes = <PendingBalanceChange>[];

    AssetHolding? holding(String address, {required bool native}) {
      final data = container.read(portfolioProvider(address)).valueOrNull;
      return data?.assets
          .where(
            (asset) => native
                ? asset.token.isNative
                : asset.token.mintAddress == token.mintAddress,
          )
          .firstOrNull;
    }

    void add(String address, AssetHolding? asset, double delta) {
      if (asset == null || delta == 0) {
        return;
      }
      changes.add(
        PendingBalanceChange(
          address: address,
          mintAddress: asset.token.mintAddress,
          delta: delta,
          baseline: asset.balance,
          createdAt: now,
        ),
      );
    }

    final fee = widget.draft.estimatedNetworkFeeSol;
    final senderSol = holding(fromAddress, native: true);
    if (token.isNative) {
      add(
        fromAddress,
        senderSol,
        emptiedSol ? -(senderSol?.balance ?? 0) : -(amountSent + fee),
      );
    } else {
      add(fromAddress, holding(fromAddress, native: false), -amountSent);
      add(fromAddress, senderSol, -fee);
    }
    final destination = widget.draft.destinationAddress;
    add(destination, holding(destination, native: token.isNative), amountSent);

    if (changes.isNotEmpty) {
      final pending = container.read(pendingBalanceChangesProvider.notifier);
      pending.state = [
        for (final change in pending.state)
          if (now.difference(change.createdAt) < const Duration(minutes: 2))
            change,
        ...changes,
      ];
    }
  }

  void _refreshBalancesAfterSend({
    required String signature,
    required List<String> addresses,
  }) {
    refreshBalancesAfterTransaction(
      ProviderScope.containerOf(context, listen: false),
      signature: signature,
      addresses: addresses,
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
    // The token program refused the amount (simulated by the backend before
    // sending, or the landed transaction's InstructionError Custom 1).
    if (!widget.draft.token.isNative &&
        (lower.contains('would fail: insufficient funds') ||
            (lower.contains('transaction failed') &&
                lower.contains('custom: 1')))) {
      return l10n.sendInsufficientBalance;
    }
    if (lower.contains('transaction failed')) {
      return genericSendFailure;
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
