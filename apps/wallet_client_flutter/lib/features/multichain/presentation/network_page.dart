import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/chains/chain_models.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../auth/presentation/providers/wallet_controller.dart';
import '../providers/multichain_providers.dart';
import 'chain_widgets.dart';

class NetworkPage extends ConsumerWidget {
  const NetworkPage({super.key, required this.chainId});
  final String chainId;
  static const routePath = '/networks/:chainId';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = findChain(ref.watch(chainConfigsProvider), chainId);
    if (config == null) {
      return AppScaffold(
        title: chainText(context, 'Network', '网络'),
        child: Text(
          chainText(context, 'Network is not configured.', '尚未配置此网络。'),
        ),
      );
    }
    final wallet = ref.watch(walletControllerProvider);
    return AppScaffold(
      title: config.displayName,
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(chainAssetsProvider(chainId));
          ref.invalidate(chainActivityProvider(chainId));
          try {
            await ref.read(chainAssetsProvider(chainId).future);
          } catch (_) {
            /* Shown below. */
          }
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            ChainNetworkLabel(config: config),
            if (config.isTestnet) ...[
              const SizedBox(height: 4),
              Text(
                chainText(
                  context,
                  'Test tokens have no monetary value and are excluded from your total balance.',
                  '测试代币无实际货币价值，不计入总余额。',
                ),
              ),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (!wallet.childModeEnabled)
                  FilledButton.icon(
                    onPressed: () => context.push(networkSendPath(chainId)),
                    icon: const Icon(Icons.send_rounded),
                    label: Text(chainText(context, 'Send', '发送')),
                  ),
                OutlinedButton.icon(
                  onPressed: () {
                    ref.read(selectedChainIdProvider.notifier).state = chainId;
                    context.push('/receive');
                  },
                  icon: const Icon(Icons.qr_code_rounded),
                  label: Text(chainText(context, 'Receive', '接收')),
                ),
                OutlinedButton.icon(
                  onPressed: () =>
                      context.push('${networkPath(chainId)}/import-token'),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(chainText(context, 'Import token', '导入代币')),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              chainText(context, 'Assets', '资产'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ref
                .watch(chainAssetsProvider(chainId))
                .when(
                  loading: () => const LinearProgressIndicator(),
                  error: (error, _) => ChainErrorCard(
                    error: error,
                    onRetry: () => ref.invalidate(chainAssetsProvider(chainId)),
                  ),
                  data: (assets) => WalletCard(
                    child: Column(
                      children: [
                        for (final asset in assets)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              asset.symbol,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              asset.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 160),
                              child: Text(
                                asset.balanceText,
                                textAlign: TextAlign.end,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            onTap: wallet.childModeEnabled
                                ? null
                                : () => context.push(
                                    networkSendPath(chainId, assetId: asset.id),
                                  ),
                          ),
                      ],
                    ),
                  ),
                ),
            const SizedBox(height: 24),
            ChainActivitySection(config: config),
          ],
        ),
      ),
    );
  }
}

String chainStatusText(BuildContext context, ChainTransactionStatus status) =>
    switch (status) {
      ChainTransactionStatus.pending => chainText(context, 'Pending', '待确认'),
      ChainTransactionStatus.finalSuccess => chainText(
        context,
        'Finalized',
        '已最终确认',
      ),
      ChainTransactionStatus.failed => chainText(context, 'Failed', '失败'),
      ChainTransactionStatus.unknown => chainText(
        context,
        'Status unavailable',
        '状态暂不可用',
      ),
    };

class ChainActivitySection extends ConsumerWidget {
  const ChainActivitySection({super.key, required this.config, this.focusHash});
  final ChainConfig config;
  final String? focusHash;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              chainText(context, 'Activity', '活动'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          IconButton(
            tooltip: chainText(context, 'Refresh activity', '刷新活动'),
            onPressed: () => ref.invalidate(chainActivityProvider(config.id)),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      Text(
        chainText(
          context,
          'Recent transfers and transactions sent from this device. Older history may not appear. Status updates automatically.',
          '显示近期转账和本设备发送的交易，可能不包含较早记录。状态会自动更新。',
        ),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      const SizedBox(height: 12),
      ref
          .watch(chainActivityProvider(config.id))
          .when(
            loading: () => const LinearProgressIndicator(),
            error: (error, _) => ChainErrorCard(
              error: error,
              onRetry: () => ref.invalidate(chainActivityProvider(config.id)),
            ),
            data: (items) {
              final visible = focusHash == null
                  ? items
                  : items.where((item) => item.hash == focusHash).toList();
              if (visible.isEmpty) {
                return WalletCard(
                  child: Text(
                    chainText(
                      context,
                      focusHash == null
                          ? 'No recent transfers. Receive assets to get started.'
                          : 'Submitted. Waiting for a receipt; check again shortly.',
                      focusHash == null
                          ? '暂无近期转账。可先接收资产。'
                          : '已提交，正在等待回执；请稍后查看。',
                    ),
                  ),
                );
              }
              return Column(
                children: [
                  for (final activity in visible)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: WalletCard(
                        child: ExpansionTile(
                          tilePadding: EdgeInsets.zero,
                          childrenPadding: const EdgeInsets.only(bottom: 12),
                          title: Text(
                            '${formatUnits(activity.amount, activity.asset.decimals)} ${activity.asset.symbol}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            chainStatusText(context, activity.status),
                          ),
                          children: [
                            ChainDetail(
                              label: chainText(context, 'From', '发送地址'),
                              value: activity.from,
                            ),
                            ChainDetail(
                              label: chainText(context, 'To', '接收地址'),
                              value: activity.to,
                            ),
                            if (activity.timestamp != null)
                              ChainDetail(
                                label: chainText(context, 'Time', '时间'),
                                value: activity.timestamp!.toLocal().toString(),
                              ),
                            if (activity.fee != null)
                              ChainDetail(
                                label: chainText(
                                  context,
                                  'Network fee',
                                  '网络费用',
                                ),
                                value:
                                    '${formatUnits(activity.fee!, config.feeDecimals)} ${config.feeSymbol}',
                              ),
                            ChainDetail(
                              label: chainText(
                                context,
                                'Transaction hash',
                                '交易哈希',
                              ),
                              value: activity.hash,
                            ),
                            TextButton.icon(
                              onPressed: () async {
                                final opened = await launchUrl(
                                  config.transactionUrl(activity.hash),
                                  mode: LaunchMode.externalApplication,
                                );
                                if (!opened && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        chainText(
                                          context,
                                          'Unable to open explorer.',
                                          '无法打开区块浏览器。',
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.open_in_new_rounded),
                              label: Text(
                                chainText(
                                  context,
                                  'View in explorer',
                                  '在区块浏览器查看',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
    ],
  );
}

class ChainDetail extends StatelessWidget {
  const ChainDetail({super.key, required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 4),
        SelectableText(value, style: Theme.of(context).textTheme.bodyMedium),
      ],
    ),
  );
}
