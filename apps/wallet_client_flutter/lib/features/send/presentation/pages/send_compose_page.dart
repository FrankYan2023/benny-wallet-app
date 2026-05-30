import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/providers.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/amount_parser.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../l10n/l10n.dart';
import '../../../auth/presentation/providers/wallet_controller.dart';
import '../../../portfolio/domain/entities/portfolio_view_data.dart';
import '../../../portfolio/presentation/providers/portfolio_provider.dart';
import '../../domain/send_draft_data.dart';
import 'scan_address_page.dart';
import 'send_confirm_page.dart';

class SendComposePage extends ConsumerStatefulWidget {
  const SendComposePage({
    super.key,
    required this.mintAddress,
    this.recipientAddress,
  });

  static const routeName = 'sendCompose';
  static const routePath = '/send/compose/:mint';

  static String pathFor(String mintAddress, {String? recipientAddress}) {
    if (recipientAddress != null) {
      return '/send/compose/$mintAddress?recipient=$recipientAddress';
    }
    return '/send/compose/$mintAddress';
  }

  final String mintAddress;
  final String? recipientAddress;

  @override
  ConsumerState<SendComposePage> createState() => _SendComposePageState();
}

class _SendComposePageState extends ConsumerState<SendComposePage> {
  static const _displayEstimatedFeeSol = 0.00022;
  static const _balanceTolerance = 0.000000001;

  final _addressController = TextEditingController();
  final _amountController = TextEditingController();
  bool _submitting = false;
  bool _isMaxAmount = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill recipient address if provided
    if (widget.recipientAddress != null &&
        widget.recipientAddress!.isNotEmpty) {
      _addressController.text = widget.recipientAddress!;
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final portfolio = ref.watch(activePortfolioProvider);
    final l10n = context.l10n;

    return portfolio.when(
      data: (data) {
        final asset = _findAsset(data.assets, widget.mintAddress);
        if (asset == null) {
          return AppScaffold(
            title: l10n.sendTitle,
            child: Center(child: Text(l10n.sendAssetNotFound)),
          );
        }

        final symbol = Formatters.tokenSymbol(asset.token.symbol);
        final amountValue = AmountParser.parse(_amountController.text) ?? 0;
        final approximateUsd = amountValue * _priceOf(asset);

        return AppScaffold(
          title: l10n.sendAssetTitle(symbol),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    const SizedBox(height: 8),
                    Center(
                      child: _TokenAvatar(
                        symbol: symbol,
                        iconUrl: asset.logoUrl,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _SendInputCard(
                      trailing: IconButton(
                        tooltip: l10n.sendScanQrCode,
                        onPressed: () => _scanAddress(context),
                        icon: Icon(
                          Icons.qr_code_scanner_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      child: TextField(
                        controller: _addressController,
                        onChanged: (_) {
                          _isMaxAmount = false;
                          setState(() {});
                        },
                        minLines: 1,
                        maxLines: 2,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          hintText: l10n.sendRecipientAddressHint,
                          border: InputBorder.none,
                          filled: false,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _AmountCard(
                      symbol: symbol,
                      amountController: _amountController,
                      onChanged: () {
                        _isMaxAmount = false;
                        setState(() {});
                      },
                      onMax: () => _fillMaxAmount(
                        asset: asset,
                        availableSolBalance:
                            data.assets
                                .where((holding) => holding.token.isNative)
                                .firstOrNull
                                ?.balance ??
                            0,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '~${Formatters.usd(approximateUsd)}',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.sendAvailableAmount(
                              Formatters.compactNumber(asset.balance),
                              symbol,
                            ),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                            textAlign: TextAlign.end,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _BottomActionRow(
                leadingLabel: l10n.commonCancel,
                trailingLabel: _submitting
                    ? l10n.commonLoading
                    : l10n.commonNext,
                onLeading: _submitting ? null : () => context.pop(),
                onTrailing: _submitting
                    ? null
                    : () => _continueToConfirm(
                        context: context,
                        asset: asset,
                        availableSolBalance:
                            data.assets
                                .where((holding) => holding.token.isNative)
                                .firstOrNull
                                ?.balance ??
                            0,
                      ),
              ),
            ],
          ),
        );
      },
      error: (error, _) => AppScaffold(
        title: l10n.sendTitle,
        child: Center(child: Text(l10n.sendLoadFormFailed('$error'))),
      ),
      loading: () => AppScaffold(
        title: l10n.sendTitle,
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  AssetHolding? _findAsset(List<AssetHolding> assets, String mintAddress) {
    for (final asset in assets) {
      if (asset.token.mintAddress == mintAddress) {
        return asset;
      }
    }
    return null;
  }

  double _priceOf(AssetHolding asset) {
    return double.tryParse(asset.priceQuote?.priceUsd ?? '') ?? 0;
  }

  Future<void> _scanAddress(BuildContext context) async {
    if (_submitting) {
      return;
    }

    final scannedAddress = await context.push<String>(
      ScanAddressPage.routePath,
    );
    if (!mounted || scannedAddress == null || scannedAddress.isEmpty) {
      return;
    }

    _addressController.text = scannedAddress;
    _isMaxAmount = false;
    setState(() {});
  }

  Future<void> _continueToConfirm({
    required BuildContext context,
    required AssetHolding asset,
    required double availableSolBalance,
  }) async {
    if (_submitting) {
      return;
    }

    FocusScope.of(context).unfocus();
    final destination = _addressController.text.trim();
    final amountValue = AmountParser.parse(_amountController.text);

    if (!Validators.isValidPublicAddress(destination)) {
      await _showValidationDialog(
        context,
        message: context.l10n.sendInvalidAddress,
      );
      return;
    }

    if (amountValue == null || amountValue <= 0) {
      await _showValidationDialog(
        context,
        message: context.l10n.sendInvalidAmount,
      );
      return;
    }

    if (amountValue > asset.balance) {
      await _showValidationDialog(
        context,
        message: context.l10n.sendInsufficientBalance,
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final walletState = ref.read(walletControllerProvider);
      final solana = ref.read(solanaWalletServiceProvider);
      final ownerAddress = walletState.publicKey;
      if (ownerAddress == null) {
        throw StateError('unlock_wallet_again');
      }

      final estimatedNetworkFeeSol = asset.token.isNative
          ? await solana.estimateSolFee(
              ownerAddress: ownerAddress,
              destinationAddress: destination,
              lamports: solana.solToLamports(amountValue),
            )
          : await solana.estimateSplFee(
              ownerAddress: ownerAddress,
              destinationAddress: destination,
              token: asset.token,
              amount: solana.tokenUiToAmount(amountValue, asset.token.decimals),
            );

      if (asset.token.isNative &&
          amountValue + estimatedNetworkFeeSol >
              asset.balance + _balanceTolerance) {
        if (!context.mounted) {
          return;
        }
        await _showValidationDialog(
          context,
          message: context.l10n.sendNotEnoughSolAfterFee,
        );
        return;
      }

      if (!asset.token.isNative &&
          estimatedNetworkFeeSol > availableSolBalance + _balanceTolerance) {
        if (!context.mounted) {
          return;
        }
        await _showValidationDialog(
          context,
          message: context.l10n.sendNotEnoughSolForFee,
        );
        return;
      }

      if (!context.mounted) {
        return;
      }

      context.push(
        SendConfirmPage.routePath,
        extra: SendDraftData(
          token: asset.token,
          logoUrl: asset.logoUrl,
          destinationAddress: destination,
          amount: amountValue,
          availableBalance: asset.balance,
          estimatedNetworkFeeSol: estimatedNetworkFeeSol,
          approximateUsd: amountValue * _priceOf(asset),
          isMaxAmount: _isMaxAmount,
        ),
      );
    } catch (error) {
      debugPrint('Send compose validation failed: $error');
      if (!context.mounted) {
        return;
      }
      await _showValidationDialog(
        context,
        message: _friendlyComposeError(context, error),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _fillMaxAmount({
    required AssetHolding asset,
    required double availableSolBalance,
  }) async {
    if (_submitting) {
      return;
    }

    if (!asset.token.isNative) {
      _amountController.text = Formatters.amount(asset.balance);
      _isMaxAmount = true;
      setState(() {});
      return;
    }

    final destination = _addressController.text.trim();
    final walletState = ref.read(walletControllerProvider);
    final ownerAddress = walletState.publicKey;
    var estimatedFeeSol = _displayEstimatedFeeSol;
    var reservedRentSol = 0.0;
    final solana = ref.read(solanaWalletServiceProvider);

    if (ownerAddress != null &&
        Validators.isValidPublicAddress(destination) &&
        asset.balance > 0) {
      try {
        estimatedFeeSol = await solana.estimateSolFee(
          ownerAddress: ownerAddress,
          destinationAddress: destination,
          lamports: solana.solToLamports(asset.balance),
        );
        reservedRentSol = solana.lamportsToSol(
          await solana.getSystemAccountRentExemptMinimumLamports(),
        );
      } catch (_) {
        estimatedFeeSol = _displayEstimatedFeeSol;
        reservedRentSol = 0.00089088;
      }
    }

    final spendable = availableSolBalance - estimatedFeeSol - reservedRentSol;
    _amountController.text = Formatters.amount(spendable > 0 ? spendable : 0);
    _isMaxAmount = true;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _showValidationDialog(
    BuildContext context, {
    required String message,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          content: Text(
            message,
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          actions: [
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(dialogContext.l10n.commonClose),
              ),
            ),
          ],
        );
      },
    );
  }

  String _friendlyComposeError(BuildContext context, Object error) {
    final message = error.toString();
    final lower = message.toLowerCase();

    if (lower.contains('unlock_wallet_again')) {
      return context.l10n.sendUnlockAgain;
    }
    if (lower.contains('insufficient') ||
        lower.contains('insufficient funds') ||
        lower.contains('insufficient lamports') ||
        lower.contains('fee payer')) {
      return context.l10n.sendNotEnoughSolForFee;
    }
    if (lower.contains('http status code') ||
        lower.contains('jsonrpc') ||
        lower.contains('rpc method not allowed') ||
        lower.contains('the following content') ||
        lower.contains('dioexception') ||
        lower.contains('bad response')) {
      return context.l10n.sendGenericFailure;
    }

    return context.l10n.sendGenericFailure;
  }
}

class _SendInputCard extends StatelessWidget {
  const _SendInputCard({required this.child, this.trailing});

  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        children: [
          Expanded(child: child),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}

class _AmountCard extends StatelessWidget {
  const _AmountCard({
    required this.symbol,
    required this.amountController,
    required this.onChanged,
    required this.onMax,
  });

  final String symbol;
  final TextEditingController amountController;
  final VoidCallback onChanged;
  final VoidCallback onMax;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (_) {
                onChanged();
              },
              decoration: InputDecoration(
                hintText: context.l10n.sendAmountHint,
                border: InputBorder.none,
                filled: false,
              ),
            ),
          ),
          Text(symbol, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(width: 10),
          TextButton(onPressed: onMax, child: Text(context.l10n.commonMax)),
        ],
      ),
    );
  }
}

class _TokenAvatar extends StatelessWidget {
  const _TokenAvatar({required this.symbol, this.iconUrl});

  final String symbol;
  final String? iconUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.7),
      ),
      child: iconUrl == null
          ? Center(
              child: Text(
                symbol.substring(0, 1),
                style: theme.textTheme.displayMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(8),
              child: ClipOval(
                child: Image.network(
                  iconUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Text(
                      symbol.substring(0, 1),
                      style: theme.textTheme.displayMedium?.copyWith(
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

class _BottomActionRow extends StatelessWidget {
  const _BottomActionRow({
    required this.leadingLabel,
    required this.trailingLabel,
    required this.onLeading,
    required this.onTrailing,
  });

  final String leadingLabel;
  final String trailingLabel;
  final VoidCallback? onLeading;
  final VoidCallback? onTrailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.tonal(
            onPressed: onLeading,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(58),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
            ),
            child: Text(leadingLabel),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: FilledButton(
            onPressed: onTrailing,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(58),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
            ),
            child: Text(trailingLabel),
          ),
        ),
      ],
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
