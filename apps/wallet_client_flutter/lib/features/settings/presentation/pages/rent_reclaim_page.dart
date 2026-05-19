import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solana/solana.dart' show lamportsPerSol;

import '../../../../app/di/providers.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/error_alert_dialog.dart';
import '../../../auth/data/solana_wallet_service.dart';
import '../../../auth/domain/wallet_controller_state.dart';
import '../../../auth/presentation/providers/ephemeral_store.dart';
import '../../../auth/presentation/providers/wallet_controller.dart';
import '../../../portfolio/presentation/providers/portfolio_provider.dart';

class RentReclaimPage extends ConsumerStatefulWidget {
  const RentReclaimPage({super.key});

  static const routeName = 'rentReclaim';
  static const routePath = '/settings/rent-reclaim';

  @override
  ConsumerState<RentReclaimPage> createState() => _RentReclaimPageState();
}

class _RentReclaimPageState extends ConsumerState<RentReclaimPage> {
  Future<RentReclaimPreview>? _previewFuture;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _reloadPreview();
  }

  void _reloadPreview() {
    final ownerAddress = ref.read(walletControllerProvider).publicKey;
    if (ownerAddress == null) {
      _previewFuture = Future<RentReclaimPreview>.error(
        StateError('Unlock the wallet again before reclaiming rent.'),
      );
      return;
    }

    setState(() {
      _previewFuture = ref
          .read(solanaWalletServiceProvider)
          .previewRentReclaim(ownerAddress: ownerAddress);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      title: 'Solana Rent Reclaim',
      child: Stack(
        children: [
          FutureBuilder<RentReclaimPreview>(
            future: _previewFuture,
            builder: (context, snapshot) {
              final preview = snapshot.data;

              return ListView(
                children: [
                  WalletCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Close empty token accounts and recover their rent back to your main SOL balance.',
                          style: theme.textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 20),
                        _SummaryRow(
                          label: 'Wallet address',
                          value: preview?.ownerAddress ?? 'Loading...',
                        ),
                        const SizedBox(height: 16),
                        _SummaryRow(
                          label: 'Closable token accounts',
                          value: preview == null
                              ? '...'
                              : '${preview.accounts.length}',
                        ),
                        const SizedBox(height: 16),
                        _SummaryRow(
                          label: 'Reclaimable rent',
                          value: preview == null
                              ? '...'
                              : '${Formatters.amount(preview.reclaimableLamports / lamportsPerSol)} SOL',
                        ),
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) ...[
                          const SizedBox(height: 20),
                          const LinearProgressIndicator(),
                        ],
                        if (snapshot.hasError) ...[
                          const SizedBox(height: 20),
                          Text(
                            _normalizeError(snapshot.error),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (preview != null && preview.accounts.isNotEmpty)
                    WalletCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Accounts to close',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 14),
                          for (final account in preview.accounts.take(12)) ...[
                            _ClosableAccountRow(account: account),
                            const SizedBox(height: 10),
                          ],
                          if (preview.accounts.length > 12)
                            Text(
                              '+${preview.accounts.length - 12} more accounts will be reclaimed.',
                              style: theme.textTheme.bodyMedium,
                            ),
                        ],
                      ),
                    ),
                  if (preview != null) ...[
                    const SizedBox(height: 18),
                    PrimaryButton(
                      label: _submitting
                          ? 'Reclaiming...'
                          : (preview.accounts.isEmpty
                                ? 'Nothing to reclaim'
                                : 'Reclaim all rent'),
                      onPressed: _submitting || preview.accounts.isEmpty
                          ? null
                          : () => _reclaim(preview),
                    ),
                  ],
                ],
              );
            },
          ),
          if (_submitting)
            Positioned.fill(
              child: ColoredBox(
                color: theme.colorScheme.scrim.withValues(alpha: 0.2),
                child: Center(
                  child: WalletCard(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 36,
                          height: 36,
                          child: CircularProgressIndicator(strokeWidth: 3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Reclaiming rent...',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Submitting close-account transactions now.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _reclaim(RentReclaimPreview preview) async {
    final walletState = ref.read(walletControllerProvider);

    if (walletState.custody == WalletCustody.mobileWalletAdapter) {
      await _reclaimWithMobileWalletAdapter(preview, walletState);
      return;
    }
    if (walletState.custody == WalletCustody.seedVault) {
      await _reclaimWithSeedVault(preview, walletState);
      return;
    }

    String? mnemonic;
    if (walletState.mnemonicTokenId != null) {
      mnemonic = ref
          .read(mnemonicEphemeralStoreProvider)
          .retrieveTemporary(walletState.mnemonicTokenId!);
    } else if (walletState.mnemonic != null) {
      mnemonic = walletState.mnemonic;
    }

    if (mnemonic == null) {
      await showErrorAlertDialog(
        context,
        title: 'Unlock Required',
        message: 'Unlock the wallet again before reclaiming rent.',
      );
      return;
    }

    setState(() {
      _submitting = true;
    });
    await Future<void>.delayed(const Duration(milliseconds: 32));

    try {
      final signatures = await ref
          .read(solanaWalletServiceProvider)
          .reclaimAllTokenAccountRent(
            mnemonic: mnemonic,
            derivation: walletState.derivation,
            accounts: preview.accounts,
          );
      final ownerAddress = walletState.publicKey;
      if (ownerAddress != null) {
        ref.invalidate(portfolioProvider(ownerAddress));
      }
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Submitted ${signatures.length} reclaim transaction${signatures.length == 1 ? '' : 's'}.',
          ),
        ),
      );
      _reloadPreview();
    } catch (error) {
      if (!mounted) {
        return;
      }
      await showErrorAlertDialog(
        context,
        title: 'Reclaim Failed',
        message: _normalizeError(error),
      );
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  Future<void> _reclaimWithMobileWalletAdapter(
    RentReclaimPreview preview,
    WalletControllerState walletState,
  ) async {
    final ownerAddress = walletState.publicKey;
    final authToken = walletState.mwaAuthToken;
    if (ownerAddress == null || ownerAddress.isEmpty) {
      await showErrorAlertDialog(
        context,
        title: 'Wallet Required',
        message: 'Connect Seeker Vault again before reclaiming rent.',
      );
      return;
    }
    if (authToken == null || authToken.isEmpty) {
      await showErrorAlertDialog(
        context,
        title: 'Wallet Required',
        message: 'Connect Seeker Vault again before reclaiming rent.',
      );
      return;
    }

    setState(() {
      _submitting = true;
    });
    await Future<void>.delayed(const Duration(milliseconds: 32));

    try {
      final solana = ref.read(solanaWalletServiceProvider);
      final transactions = await solana.buildRentReclaimTransactions(
        ownerAddress: ownerAddress,
        accounts: preview.accounts,
      );
      final result = await ref
          .read(mobileWalletAdapterServiceProvider)
          .signAndSendTransactions(
            authToken: authToken,
            encodedTransactions: transactions,
          );
      await ref
          .read(walletControllerProvider.notifier)
          .updateMobileWalletAdapterAuthToken(result.authToken);
      for (final signature in result.signatures) {
        await solana.waitForConfirmation(signature);
      }
      ref.invalidate(portfolioProvider(ownerAddress));
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Submitted ${result.signatures.length} reclaim transaction${result.signatures.length == 1 ? '' : 's'}.',
          ),
        ),
      );
      _reloadPreview();
    } catch (error) {
      if (!mounted) {
        return;
      }
      await showErrorAlertDialog(
        context,
        title: 'Reclaim Failed',
        message: _normalizeError(error),
      );
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  Future<void> _reclaimWithSeedVault(
    RentReclaimPreview preview,
    WalletControllerState walletState,
  ) async {
    final ownerAddress = walletState.publicKey;
    final authToken = walletState.mwaAuthToken;
    final derivationPath = walletState.seedVaultDerivationPath;
    if (ownerAddress == null ||
        ownerAddress.isEmpty ||
        authToken == null ||
        authToken.isEmpty ||
        derivationPath == null ||
        derivationPath.isEmpty) {
      await showErrorAlertDialog(
        context,
        title: 'Wallet Required',
        message: 'Connect Seed Vault again before reclaiming rent.',
      );
      return;
    }

    setState(() {
      _submitting = true;
    });
    await Future<void>.delayed(const Duration(milliseconds: 32));

    try {
      final solana = ref.read(solanaWalletServiceProvider);
      final transactions = await solana.buildRentReclaimTransactions(
        ownerAddress: ownerAddress,
        accounts: preview.accounts,
      );
      final signatures = <String>[];
      for (final transaction in transactions) {
        final result = await ref
            .read(mobileWalletAdapterServiceProvider)
            .signSeedVaultTransactions(
              authToken: authToken,
              derivationPath: derivationPath,
              encodedTransactions: [transaction],
            );
        signatures.add(
          await solana.sendExternallySignedTransaction(
            encodedTransaction: transaction,
            signature: result.signatures.first,
          ),
        );
      }
      ref.invalidate(portfolioProvider(ownerAddress));
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Submitted ${signatures.length} reclaim transaction${signatures.length == 1 ? '' : 's'}.',
          ),
        ),
      );
      _reloadPreview();
    } catch (error) {
      if (!mounted) {
        return;
      }
      await showErrorAlertDialog(
        context,
        title: 'Reclaim Failed',
        message: _normalizeError(error),
      );
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  String _normalizeError(Object? error) {
    final message = error?.toString().trim() ?? '';
    if (message.isEmpty) {
      return 'Unable to scan reclaimable token accounts right now.';
    }
    if (message.toLowerCase().contains('unlock')) {
      return 'Unlock the wallet again before reclaiming rent.';
    }
    return message;
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(value, style: theme.textTheme.titleMedium),
      ],
    );
  }
}

class _ClosableAccountRow extends StatelessWidget {
  const _ClosableAccountRow({required this.account});

  final ReclaimableTokenAccount account;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                account.symbol,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(account.name, style: theme.textTheme.bodySmall),
              const SizedBox(height: 2),
              Text(
                Formatters.compactAddress(account.address, visibleChars: 5),
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 2),
              Text(
                'Mint ${Formatters.compactAddress(account.mintAddress, visibleChars: 5)}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '${Formatters.amount(account.rentLamports / lamportsPerSol)} SOL',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
