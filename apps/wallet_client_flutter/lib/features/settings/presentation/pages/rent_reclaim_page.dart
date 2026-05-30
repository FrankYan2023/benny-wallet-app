import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solana/solana.dart' show lamportsPerSol;

import '../../../../app/di/providers.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/error_alert_dialog.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../l10n/l10n.dart';
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
    final l10n = context.l10n;

    return AppScaffold(
      title: l10n.rentTitle,
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
                          l10n.rentDescription,
                          style: theme.textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 20),
                        _SummaryRow(
                          label: l10n.rentWalletAddress,
                          value: preview?.ownerAddress ?? l10n.commonLoading,
                        ),
                        const SizedBox(height: 16),
                        _SummaryRow(
                          label: l10n.rentClosableTokenAccounts,
                          value: preview == null
                              ? '...'
                              : '${preview.accounts.length}',
                        ),
                        const SizedBox(height: 16),
                        _SummaryRow(
                          label: l10n.rentReclaimableRent,
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
                            _normalizeError(snapshot.error, l10n),
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
                            l10n.rentAccountsToClose,
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
                              l10n.rentMoreAccounts(
                                preview.accounts.length - 12,
                              ),
                              style: theme.textTheme.bodyMedium,
                            ),
                        ],
                      ),
                    ),
                  if (preview != null) ...[
                    const SizedBox(height: 18),
                    PrimaryButton(
                      label: _submitting
                          ? l10n.rentReclaiming
                          : (preview.accounts.isEmpty
                                ? l10n.rentNothingToReclaim
                                : l10n.rentReclaimAll),
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
                          l10n.rentReclaimingRent,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.rentSubmittingTransactions,
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
        title: context.l10n.rentUnlockRequiredTitle,
        message: context.l10n.rentUnlockRequiredMessage,
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
            context.l10n.rentSubmittedTransactions(signatures.length),
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
        title: context.l10n.rentReclaimFailedTitle,
        message: _normalizeError(error, context.l10n),
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
        title: context.l10n.rentWalletRequiredTitle,
        message: context.l10n.rentConnectSeekerVaultAgain,
      );
      return;
    }
    if (authToken == null || authToken.isEmpty) {
      await showErrorAlertDialog(
        context,
        title: context.l10n.rentWalletRequiredTitle,
        message: context.l10n.rentConnectSeekerVaultAgain,
      );
      return;
    }

    setState(() {
      _submitting = true;
    });
    await Future<void>.delayed(const Duration(milliseconds: 32));

    try {
      final solana = ref.read(solanaWalletServiceProvider);
      final signatures = <String>[];
      final failures = <Object>[];
      var nextAuthToken = authToken;
      for (final account in preview.accounts) {
        try {
          final transactions = await solana.buildRentReclaimTransactions(
            ownerAddress: ownerAddress,
            accounts: [account],
            chunkSize: 1,
            includeSenderInstructions: false,
          );
          final result = await ref
              .read(mobileWalletAdapterServiceProvider)
              .signAndSendTransactions(
                authToken: nextAuthToken,
                encodedTransactions: transactions,
              );
          nextAuthToken = result.authToken;
          signatures.addAll(result.signatures);
        } catch (error) {
          debugPrint('Rent reclaim MWA failed for ${account.address}: $error');
          if (_isUserCancelled(error)) {
            rethrow;
          }
          failures.add(error);
        }
      }
      await ref
          .read(walletControllerProvider.notifier)
          .updateMobileWalletAdapterAuthToken(nextAuthToken);
      if (signatures.isEmpty && failures.isNotEmpty) {
        throw failures.first;
      }
      for (final signature in signatures) {
        await solana.waitForConfirmation(signature);
      }
      ref.invalidate(portfolioProvider(ownerAddress));
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            failures.isEmpty
                ? context.l10n.rentSubmittedTransactions(signatures.length)
                : context.l10n.rentSubmittedTransactionsWithSkipped(
                    failures.length,
                    signatures.length,
                  ),
          ),
        ),
      );
      _reloadPreview();
    } catch (error) {
      debugPrint('Rent reclaim MWA failed: $error');
      if (!mounted) {
        return;
      }
      await showErrorAlertDialog(
        context,
        title: context.l10n.rentReclaimFailedTitle,
        message: _normalizeError(error, context.l10n),
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
        title: context.l10n.rentWalletRequiredTitle,
        message: context.l10n.rentConnectSeedVaultAgain,
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
        includeSenderInstructions: false,
      );
      final signatures = <String>[];
      for (final transaction in transactions) {
        final result = await ref
            .read(mobileWalletAdapterServiceProvider)
            .signSeedVaultMessages(
              authToken: authToken,
              derivationPath: derivationPath,
              messages: [solana.signableTransactionMessageBytes(transaction)],
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
            context.l10n.rentSubmittedTransactions(signatures.length),
          ),
        ),
      );
      _reloadPreview();
    } catch (error) {
      debugPrint('Rent reclaim Seed Vault failed: $error');
      if (!mounted) {
        return;
      }
      await showErrorAlertDialog(
        context,
        title: context.l10n.rentReclaimFailedTitle,
        message: _normalizeError(error, context.l10n),
      );
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  String _normalizeError(Object? error, AppLocalizations l10n) {
    final message = error?.toString().trim() ?? '';
    if (message.isEmpty) {
      return l10n.rentUnableScan;
    }
    if (message.toLowerCase().contains('unlock')) {
      return l10n.rentUnlockRequiredMessage;
    }
    return message;
  }

  bool _isUserCancelled(Object error) {
    final lower = error.toString().toLowerCase();
    return lower.contains('cancel') ||
        lower.contains('reject') ||
        lower.contains('declin') ||
        lower.contains('user denied');
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
                context.l10n.rentMintAddress(
                  Formatters.compactAddress(
                    account.mintAddress,
                    visibleChars: 5,
                  ),
                ),
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
