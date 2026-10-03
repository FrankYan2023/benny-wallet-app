import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/chains/chain_models.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/amount_parser.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../l10n/l10n.dart';
import '../../auth/presentation/providers/wallet_controller.dart';
import '../../portfolio/presentation/pages/portfolio_page.dart';
import '../../send/presentation/pages/scan_address_page.dart';
import '../../send/presentation/widgets/send_widgets.dart';
import '../data/chain_transfer_controller.dart';
import '../providers/multichain_providers.dart';
import 'chain_widgets.dart';

/// Token-specific composer. Asset selection stays in the shared Send list.
class NetworkSendPage extends ConsumerStatefulWidget {
  const NetworkSendPage({
    super.key,
    required this.chainId,
    this.assetId,
    this.recipientAddress,
  });
  static const routePath = '/networks/:chainId/send';
  static const composeRoutePath = '/send/network-compose/:chainId';
  static String composePathFor(
    String chainId, {
    required String assetId,
    String? recipientAddress,
  }) => Uri(
    path: '/send/network-compose/${Uri.encodeComponent(chainId)}',
    queryParameters: {
      'asset': assetId,
      if (recipientAddress != null && recipientAddress.isNotEmpty)
        'recipient': recipientAddress,
    },
  ).toString();

  final String chainId;
  final String? assetId;
  final String? recipientAddress;

  @override
  ConsumerState<NetworkSendPage> createState() => _NetworkSendPageState();
}

class _NetworkSendPageState extends ConsumerState<NetworkSendPage> {
  final _recipient = TextEditingController();
  final _amount = TextEditingController();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _recipient.text = widget.recipientAddress ?? '';
  }

  @override
  void dispose() {
    _recipient.dispose();
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = findChain(ref.watch(chainConfigsProvider), widget.chainId);
    final wallet = ref.watch(walletControllerProvider);
    if (config == null || !wallet.isUnlocked || wallet.childModeEnabled) {
      return AppScaffold(
        title: context.l10n.sendTitle,
        child: Center(
          child: Text(
            chainText(
              context,
              'Unlock an eligible wallet in parent mode to send on this network.',
              '请在家长模式解锁支持此网络的钱包后发送。',
            ),
          ),
        ),
      );
    }
    return PopScope(
      canPop: !_busy,
      child: ref
          .watch(chainAccountProvider(widget.chainId))
          .when(
            loading: () => _loading(),
            error: (error, _) => _failure(
              error,
              () => ref.invalidate(chainAccountProvider(widget.chainId)),
            ),
            data: (account) => ref
                .watch(chainAssetsProvider(widget.chainId))
                .when(
                  loading: () => _loading(),
                  error: (error, _) => _failure(
                    error,
                    () => ref.invalidate(chainAssetsProvider(widget.chainId)),
                  ),
                  data: (assets) {
                    final matches = assets.where(
                      (asset) => asset.id == widget.assetId,
                    );
                    if (matches.isEmpty) {
                      return AppScaffold(
                        title: context.l10n.sendTitle,
                        child: Center(
                          child: Text(context.l10n.sendAssetNotFound),
                        ),
                      );
                    }
                    return _compose(config, account, matches.first);
                  },
                ),
          ),
    );
  }

  Widget _loading() => AppScaffold(
    title: context.l10n.sendTitle,
    child: const Center(child: CircularProgressIndicator()),
  );
  Widget _failure(Object error, VoidCallback retry) => AppScaffold(
    title: context.l10n.sendTitle,
    child: ChainErrorCard(error: error, onRetry: retry),
  );

  Widget _compose(ChainConfig config, ChainAccount account, ChainAsset asset) {
    final l10n = context.l10n;
    final amount = AmountParser.parse(_amount.text) ?? 0;
    return AppScaffold(
      title: l10n.sendAssetTitle(asset.symbol),
      showBackButton: !_busy,
      enableTitleNavigation: !_busy,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                ChainNetworkLabel(config: config),
                const SizedBox(height: 8),
                Center(
                  child: SendTokenAvatar(
                    symbol: asset.symbol,
                    iconUrl: asset.logoUrl,
                  ),
                ),
                const SizedBox(height: 24),
                SendInputCard(
                  trailing: IconButton(
                    tooltip: l10n.sendScanQrCode,
                    onPressed: _busy ? null : _scanAddress,
                    icon: Icon(
                      Icons.qr_code_scanner_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  child: TextField(
                    controller: _recipient,
                    enabled: !_busy,
                    autocorrect: false,
                    enableSuggestions: false,
                    minLines: 1,
                    maxLines: 2,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      hintText: chainText(context, 'Recipient address', '接收地址'),
                      border: InputBorder.none,
                      filled: false,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SendAmountCard(
                  symbol: asset.symbol,
                  amountController: _amount,
                  enabled: !_busy && account.canSign,
                  onChanged: () => setState(() {}),
                  onMax: () => _fillMax(account, asset),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        asset.fiatPrice == null || config.isTestnet
                            ? '--'
                            : '~${Formatters.usd(amount * asset.fiatPrice!)}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.sendAvailableAmount(
                          asset.balanceText,
                          asset.symbol,
                        ),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
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
          SendBottomActionRow(
            leadingLabel: l10n.commonCancel,
            trailingLabel: _busy ? l10n.commonLoading : l10n.commonNext,
            onLeading: _busy ? null : () => context.pop(),
            onTrailing: _busy || !account.canSign
                ? null
                : () => _prepare(account, asset),
          ),
        ],
      ),
    );
  }

  Future<void> _scanAddress() async {
    if (_busy) return;
    final address = await context.push<String>(
      ScanAddressPage.pathFor(widget.chainId),
    );
    if (mounted && address != null && address.isNotEmpty) {
      setState(() => _recipient.text = address);
    }
  }

  Future<void> _fillMax(ChainAccount account, ChainAsset asset) async {
    if (_busy || !account.canSign) return;
    if (!ref
        .read(chainAdapterProvider(widget.chainId))
        .validateAddress(_recipient.text.trim())) {
      await _showError(
        chainText(
          context,
          'Enter a valid address for this network.',
          '请输入此网络的有效地址。',
        ),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      final amount = await ref
          .read(chainTransferControllerProvider)
          .maximumAmount(
            ChainTransferRequest(
              account: account,
              asset: asset,
              to: _recipient.text.trim(),
              amount: BigInt.one,
            ),
          );
      if (mounted)
        setState(() => _amount.text = formatUnits(amount, asset.decimals));
    } catch (error) {
      if (mounted) await _showError(_friendlyError(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _prepare(ChainAccount account, ChainAsset asset) async {
    if (_busy || !account.canSign) return;
    FocusScope.of(context).unfocus();
    if (!ref
        .read(chainAdapterProvider(widget.chainId))
        .validateAddress(_recipient.text.trim())) {
      await _showError(
        chainText(
          context,
          'Enter a valid address for this network.',
          '请输入此网络的有效地址。',
        ),
      );
      return;
    }
    if (!asset.balanceAvailable) {
      await _showError(
        chainText(
          context,
          'Balance unavailable. Refresh and try again.',
          '余额暂不可用，请刷新后重试。',
        ),
      );
      return;
    }
    BigInt amount;
    try {
      amount = parseUnits(
        AmountParser.normalize(_amount.text) ?? '',
        asset.decimals,
      );
    } on FormatException {
      await _showError(context.l10n.sendInvalidAmount);
      return;
    }
    if (amount <= BigInt.zero) {
      await _showError(context.l10n.sendInvalidAmount);
      return;
    }
    if (amount > asset.rawBalance) {
      await _showError(context.l10n.sendInsufficientBalance);
      return;
    }
    setState(() => _busy = true);
    try {
      final prepared = await ref
          .read(chainTransferControllerProvider)
          .prepare(
            ChainTransferRequest(
              account: account,
              asset: asset,
              to: _recipient.text.trim(),
              amount: amount,
            ),
          );
      if (!mounted) return;
      await context.push(NetworkSendConfirmPage.routePath, extra: prepared);
    } catch (error) {
      if (mounted) await _showError(_friendlyError(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _friendlyError(Object error) {
    if (error.toString().toLowerCase().contains('insufficient')) {
      final config = findChain(ref.read(chainConfigsProvider), widget.chainId)!;
      return chainText(
        context,
        'Not enough ${config.feeSymbol} for the amount and network fee.',
        '转账金额与网络费用所需的 ${config.feeSymbol} 余额不足。',
      );
    }
    return context.l10n.sendGenericFailure;
  }

  Future<void> _showError(String message) => showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: Theme.of(dialogContext).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: Theme.of(dialogContext).textTheme.titleMedium,
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(dialogContext.l10n.commonClose),
          ),
        ),
      ],
    ),
  );
}

/// Confirmation has its own route, so back/cancel returns to unchanged inputs.
class NetworkSendConfirmPage extends ConsumerStatefulWidget {
  const NetworkSendConfirmPage({super.key, required this.transaction});
  static const routePath = '/send/network-confirm';
  final PreparedChainTransaction transaction;
  @override
  ConsumerState<NetworkSendConfirmPage> createState() =>
      _NetworkSendConfirmPageState();
}

class _NetworkSendConfirmPageState
    extends ConsumerState<NetworkSendConfirmPage> {
  bool _busy = false;
  bool _finished = false;
  bool _uncertain = false;
  String? _hash;
  Object? _error;

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(walletControllerProvider);
    final transaction = widget.transaction;
    final config = findChain(
      ref.watch(chainConfigsProvider),
      transaction.request.account.chainId,
    );
    if (!wallet.isUnlocked ||
        wallet.childModeEnabled ||
        wallet.publicKey != transaction.request.account.rootWalletId ||
        config == null) {
      return AppScaffold(
        title: context.l10n.sendConfirmTitle,
        child: Center(child: Text(context.l10n.sendUnlockAgain)),
      );
    }
    return PopScope(
      canPop: !_busy,
      child: AppScaffold(
        title: _finished || _busy ? '' : context.l10n.sendConfirmTitle,
        showTopBar: !_finished && !_busy,
        showBackButton: !_busy,
        enableTitleNavigation: !_busy,
        child: _finished || _busy ? _status(config) : _review(),
      ),
    );
  }

  Widget _review() {
    final transaction = widget.transaction;
    final request = transaction.request;
    final asset = request.asset;
    final config = findChain(
      ref.watch(chainConfigsProvider),
      request.account.chainId,
    )!;
    final value = double.tryParse(formatUnits(request.amount, asset.decimals));
    return Column(
      children: [
        Expanded(
          child: SendReviewContent(
            amountText:
                '${formatUnits(request.amount, asset.decimals)} ${asset.symbol}',
            fiatText:
                config.isTestnet || asset.fiatPrice == null || value == null
                ? null
                : '~${Formatters.usd(value * asset.fiatPrice!)}',
            rows: [
              SendInfoRowData(
                context.l10n.commonTo,
                request.to,
                isAddress: true,
                maxLines: null,
              ),
              SendInfoRowData(
                context.l10n.commonNetwork,
                config.displayName,
                valueWidget: ChainNetworkIdentity(
                  chainId: request.account.chainId,
                ),
              ),
              SendInfoRowData(
                context.l10n.commonNetworkFee,
                '${formatUnits(transaction.fee.estimatedFee, transaction.fee.decimals)} ${transaction.fee.symbol}',
              ),
              SendInfoRowData(
                chainText(context, 'Maximum network fee', '最高网络费用'),
                transaction.fee.displayText,
              ),
              if (asset.contractAddress != null)
                SendInfoRowData(
                  chainText(context, 'Token contract', '代币合约'),
                  asset.contractAddress!,
                  isAddress: true,
                  maxLines: null,
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SendBottomActionRow(
          leadingLabel: context.l10n.commonCancel,
          trailingLabel: context.l10n.commonSend,
          onLeading: () => context.pop(),
          onTrailing: _send,
        ),
      ],
    );
  }

  Widget _status(ChainConfig config) {
    final request = widget.transaction.request;
    final success = _hash != null && !_uncertain;
    return Column(
      children: [
        ChainNetworkLabel(config: config),
        const Spacer(),
        Container(
          width: 152,
          height: 152,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _busy
                ? const Color(0x142D6CDF)
                : success
                ? const Color(0x192FA36B)
                : Theme.of(
                    context,
                  ).colorScheme.errorContainer.withValues(alpha: .4),
          ),
          child: _busy
              ? const Center(
                  child: SizedBox(
                    width: 54,
                    height: 54,
                    child: CircularProgressIndicator(strokeWidth: 4),
                  ),
                )
              : Icon(
                  success
                      ? Icons.check_rounded
                      : _uncertain
                      ? Icons.pending_actions_rounded
                      : Icons.error_outline_rounded,
                  size: 72,
                  color: success
                      ? const Color(0xFF2FA36B)
                      : Theme.of(context).colorScheme.onErrorContainer,
                ),
        ),
        const SizedBox(height: 28),
        Text(
          _busy
              ? context.l10n.sendSubmitting
              : _uncertain
              ? chainText(context, 'Check transaction status', '请检查交易状态')
              : success
              ? context.l10n.sendSubmitted
              : context.l10n.sendFailed,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.displayLarge?.copyWith(fontSize: 40),
        ),
        const SizedBox(height: 12),
        Text(
          _busy
              ? context.l10n.sendSubmittingSummary(
                  Formatters.compactAddress(request.to, visibleChars: 5),
                  formatUnits(request.amount, request.asset.decimals),
                  request.asset.symbol,
                )
              : success
              ? context.l10n.sendSubmittedMessage(
                  Formatters.compactAddress(request.to, visibleChars: 5),
                  formatUnits(request.amount, request.asset.decimals),
                  request.asset.symbol,
                )
              : _uncertain
              ? chainText(
                  context,
                  'Check activity before sending again. The network may have received this transaction.',
                  '再次发送前请检查交易记录，网络可能已收到此交易。',
                )
              : _error.toString().contains('Review the latest network fee')
              ? chainText(
                  context,
                  'Review the latest fee before sending again.',
                  '请重新确认最新费用后发送。',
                )
              : context.l10n.sendGenericFailure,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        if (!_busy && _hash != null) ...[
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => launchUrl(
              config.transactionUrl(_hash!),
              mode: LaunchMode.externalApplication,
            ),
            child: Text(context.l10n.sendViewTransaction),
          ),
        ],
        if (!_busy && (success || _uncertain))
          TextButton(
            onPressed: () => context.go(
              '${networkPath(config.id)}${_hash == null ? '' : '?tx=${Uri.encodeComponent(_hash!)}'}',
            ),
            child: Text(
              chainText(context, 'View network activity', '查看网络交易记录'),
            ),
          ),
        if (!_busy && !success && !_uncertain)
          TextButton(
            onPressed: () => context.pop(),
            child: Text(chainText(context, 'Edit transfer', '修改转账')),
          ),
        const Spacer(),
        if (!_busy)
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
    if (_busy || _finished) return;
    setState(() => _busy = true);
    try {
      final hash = await ref
          .read(chainTransferControllerProvider)
          .send(widget.transaction);
      if (mounted) setState(() => _hash = hash);
    } catch (error) {
      if (mounted)
        setState(() {
          _error = error;
          _uncertain = error is ChainSubmissionUncertain;
          if (error is ChainSubmissionUncertain) _hash = error.hash;
        });
    } finally {
      if (mounted)
        setState(() {
          _busy = false;
          _finished = true;
        });
    }
  }
}
