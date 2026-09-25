import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/chains/chain_models.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../auth/presentation/providers/wallet_controller.dart';
import '../data/chain_transfer_controller.dart';
import '../providers/multichain_providers.dart';
import 'chain_widgets.dart';
import 'network_page.dart';

class NetworkSendPage extends ConsumerStatefulWidget {
  const NetworkSendPage({
    super.key,
    required this.chainId,
    this.assetId,
    this.embedded = false,
    this.recipientAddress,
    this.onBusyChanged,
  });
  final bool embedded;
  final String? recipientAddress;
  final ValueChanged<bool>? onBusyChanged;
  static const routePath = '/networks/:chainId/send';
  final String chainId;
  final String? assetId;

  @override
  ConsumerState<NetworkSendPage> createState() => _NetworkSendPageState();
}

class _NetworkSendPageState extends ConsumerState<NetworkSendPage> {
  final _form = GlobalKey<FormState>();
  final _recipient = TextEditingController();
  final _amount = TextEditingController();
  String? _selectedAssetId;
  PreparedChainTransaction? _prepared;
  String? _hash;
  Object? _error;
  bool _busy = false;
  bool _submissionUncertain = false;

  @override
  void initState() {
    super.initState();
    _selectedAssetId = widget.assetId;
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
        title: chainText(context, 'Send', '发送'),
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
      child: _layout(
        context,
        ListView(
          children: [
            if (!widget.embedded) ChainNetworkLabel(config: config),
            if (config.isTestnet)
              Text(
                chainText(
                  context,
                  'Test tokens only · no monetary value',
                  '仅限测试代币 · 无实际货币价值',
                ),
              ),
            const SizedBox(height: 18),
            if (_hash != null) ...[
              WalletCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chainText(context, 'Transaction submitted', '交易已提交'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    SelectableText(_hash!),
                    const SizedBox(height: 12),
                    Text(
                      chainText(
                        context,
                        'Submission does not mean finality. The receipt below shows the result.',
                        '提交不代表最终确认，请查看下方交易回执。',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ChainActivitySection(config: config, focusHash: _hash),
            ] else if (_submissionUncertain) ...[
              WalletCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chainText(context, 'Check transaction status', '请检查交易状态'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Text('$_error'),
                    const SizedBox(height: 12),
                    Text(
                      chainText(
                        context,
                        'A network error can occur after a transaction was sent. Check activity before creating another transfer.',
                        '交易发送后也可能出现网络错误。再次转账前，请先检查交易记录。',
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go(networkPath(widget.chainId)),
                      child: Text(
                        chainText(context, 'View network activity', '查看网络交易记录'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ChainActivitySection(config: config),
            ] else if (_prepared != null) ...[
              _review(context, _prepared!),
            ] else ...[
              ref
                  .watch(chainAccountProvider(widget.chainId))
                  .when(
                    loading: () => const LinearProgressIndicator(),
                    error: (error, _) => ChainErrorCard(
                      error: error,
                      onRetry: () =>
                          ref.invalidate(chainAccountProvider(widget.chainId)),
                    ),
                    data: (account) => ref
                        .watch(chainAssetsProvider(widget.chainId))
                        .when(
                          loading: () => const LinearProgressIndicator(),
                          error: (error, _) => ChainErrorCard(
                            error: error,
                            onRetry: () => ref.invalidate(
                              chainAssetsProvider(widget.chainId),
                            ),
                          ),
                          data: (assets) => _compose(context, account, assets),
                        ),
                  ),
            ],
            if (_error != null && !_submissionUncertain) ...[
              const SizedBox(height: 12),
              Text(
                '$_error',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            if (_busy)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: LinearProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _layout(BuildContext context, Widget child) => widget.embedded
      ? child
      : AppScaffold(
          title: chainText(context, 'Send assets', '发送资产'),
          enableTitleNavigation: !_busy,
          showBackButton: !_busy,
          child: child,
        );

  Widget _compose(
    BuildContext context,
    ChainAccount account,
    List<ChainAsset> assets,
  ) {
    if (assets.isEmpty)
      return Text(chainText(context, 'No assets available.', '暂无可用资产。'));
    final asset =
        assets.where((item) => item.id == _selectedAssetId).firstOrNull ??
        assets.first;
    return WalletCard(
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              key: ValueKey(asset.id),
              initialValue: asset.id,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: chainText(context, 'Asset', '资产'),
              ),
              items: [
                for (final item in assets)
                  DropdownMenuItem(
                    value: item.id,
                    child: Text(
                      item.symbol,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: _busy
                  ? null
                  : (value) => setState(() {
                      _selectedAssetId = value;
                      _error = null;
                    }),
            ),
            const SizedBox(height: 10),
            Text(
              chainText(
                context,
                'Available: ${asset.balanceText} ${asset.symbol}',
                '可用：${asset.balanceText} ${asset.symbol}',
              ),
            ),
            if (asset.contractAddress != null) ...[
              const SizedBox(height: 8),
              Text(
                asset.contractAddress!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 20),
            TextFormField(
              controller: _recipient,
              enabled: !_busy,
              autocorrect: false,
              enableSuggestions: false,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: chainText(context, 'Recipient address', '接收地址'),
              ),
              validator: (value) =>
                  ref
                      .read(chainAdapterProvider(widget.chainId))
                      .validateAddress(value?.trim() ?? '')
                  ? null
                  : chainText(
                      context,
                      'Enter a valid address for this network.',
                      '请输入此网络的有效地址。',
                    ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amount,
              enabled: !_busy,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: chainText(context, 'Amount', '金额'),
                suffixText: asset.symbol,
              ),
              validator: (value) {
                try {
                  final amount = parseUnits(
                    value?.trim() ?? '',
                    asset.decimals,
                  );
                  if (amount <= BigInt.zero)
                    return chainText(
                      context,
                      'Enter an amount greater than zero.',
                      '请输入大于零的金额。',
                    );
                  if (amount > asset.rawBalance)
                    return chainText(
                      context,
                      'Insufficient asset balance.',
                      '资产余额不足。',
                    );
                  return null;
                } on FormatException {
                  return chainText(
                    context,
                    'Enter a decimal amount with up to ${asset.decimals} decimal places.',
                    '请输入不超过 ${asset.decimals} 位小数的金额。',
                  );
                }
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _busy || !account.canSign
                  ? null
                  : () => _prepare(account, asset),
              child: Text(
                chainText(context, 'Estimate fee & review', '估算费用并确认'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _review(
    BuildContext context,
    PreparedChainTransaction transaction,
  ) => WalletCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          chainText(context, 'Review transfer', '确认转账'),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 18),
        ChainDetail(
          label: chainText(context, 'Amount', '金额'),
          value:
              '${formatUnits(transaction.request.amount, transaction.request.asset.decimals)} ${transaction.request.asset.symbol}',
        ),
        ChainDetail(
          label: chainText(context, 'From', '发送地址'),
          value: transaction.request.account.address,
        ),
        ChainDetail(
          label: chainText(context, 'To', '接收地址'),
          value: transaction.request.to,
        ),
        if (transaction.request.asset.contractAddress != null)
          ChainDetail(
            label: chainText(context, 'Token contract', '代币合约'),
            value: transaction.request.asset.contractAddress!,
          ),
        ChainDetail(
          label: chainText(context, 'Estimated network fee', '预估网络费用'),
          value:
              '${formatUnits(transaction.fee.estimatedFee, transaction.fee.decimals)} ${transaction.fee.symbol}',
        ),
        ChainDetail(
          label: chainText(context, 'Maximum network fee', '最高网络费用'),
          value: transaction.fee.displayText,
        ),
        Text(
          chainText(
            context,
            'Check the network, token contract and full recipient address before sending.',
            '发送前，请核对网络、代币合约和完整接收地址。',
          ),
        ),
        const SizedBox(height: 18),
        FilledButton(
          onPressed: _busy ? null : () => _send(transaction),
          child: Text(chainText(context, 'Confirm & send', '确认并发送')),
        ),
        TextButton(
          onPressed: _busy
              ? null
              : () => setState(() {
                  _prepared = null;
                  _error = null;
                }),
          child: Text(chainText(context, 'Edit transfer', '修改转账')),
        ),
      ],
    ),
  );

  Future<void> _prepare(ChainAccount account, ChainAsset asset) async {
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    widget.onBusyChanged?.call(true);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final prepared = await ref
          .read(chainTransferControllerProvider)
          .prepare(
            ChainTransferRequest(
              account: account,
              asset: asset,
              to: _recipient.text.trim(),
              amount: parseUnits(_amount.text.trim(), asset.decimals),
            ),
          );
      if (mounted) setState(() => _prepared = prepared);
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) {
        setState(() => _busy = false);
        widget.onBusyChanged?.call(false);
      }
    }
  }

  Future<void> _send(PreparedChainTransaction transaction) async {
    widget.onBusyChanged?.call(true);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final hash = await ref
          .read(chainTransferControllerProvider)
          .send(transaction);
      if (mounted) setState(() => _hash = hash);
    } catch (error) {
      if (mounted)
        setState(() {
          _error = error;
          _submissionUncertain = error is ChainSubmissionUncertain;
          _prepared = null;
        });
    } finally {
      if (mounted) {
        setState(() => _busy = false);
        widget.onBusyChanged?.call(false);
      }
    }
  }
}
