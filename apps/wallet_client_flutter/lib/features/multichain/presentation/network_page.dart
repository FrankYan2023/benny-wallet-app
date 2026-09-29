import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/chains/chain_models.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../providers/multichain_providers.dart';
import 'chain_widgets.dart';

class NetworkPage extends ConsumerWidget {
  const NetworkPage({super.key, required this.chainId, this.focusHash});
  final String chainId;
  final String? focusHash;
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
    return AppScaffold(
      title: chainText(context, 'Activity', '活动'),
      child: ListView(
        children: [
          ChainNetworkSelector(
            value: config.id,
            onChanged: (id) => context.replace(networkPath(id)),
          ),
          const SizedBox(height: 16),
          ChainActivitySection(config: config, focusHash: focusHash),
        ],
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
            onPressed: () {
              ref.invalidate(chainActivityProvider(config.id));
              ref.invalidate(backendChainHistoryProvider(config.id));
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      Text(
        chainText(
          context,
          ref.watch(chainBackendProvider(config.id)) == null
              ? 'Recent transfers and transactions sent from this device. Older history may not appear.'
              : (ref
                            .watch(backendChainHistoryProvider(config.id))
                            .valueOrNull
                            ?.backfillComplete ==
                        true
                    ? 'Synced history. Status updates automatically.'
                    : 'Syncing earlier history. Recent activity updates automatically.'),
          ref.watch(chainBackendProvider(config.id)) == null
              ? '显示近期转账和本设备发送的交易，可能不包含较早记录。'
              : (ref
                            .watch(backendChainHistoryProvider(config.id))
                            .valueOrNull
                            ?.backfillComplete ==
                        true
                    ? '历史已同步，状态会自动更新。'
                    : '正在同步较早记录，近期活动会自动更新。'),
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
              onRetry: () {
                ref.invalidate(chainActivityProvider(config.id));
                ref.invalidate(backendChainHistoryProvider(config.id));
              },
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
                        child: Material(
                          type: MaterialType.transparency,
                          child: ExpansionTile(
                            tilePadding: EdgeInsets.zero,
                            childrenPadding: const EdgeInsets.only(bottom: 12),
                            title: Text(
                              '${formatUnits(activity.amount, activity.asset.decimals)} ${activity.asset.symbol}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ChainNetworkIdentity(chainId: activity.chainId),
                                Text(chainStatusText(context, activity.status)),
                              ],
                            ),
                            children: [
                              ChainDetail(
                                label: chainText(context, 'Network', '网络'),
                                value: config.displayName,
                                valueWidget: ChainNetworkIdentity(
                                  chainId: activity.chainId,
                                ),
                              ),
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
                                  value: activity.timestamp!
                                      .toLocal()
                                      .toString(),
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
                    ),
                ],
              );
            },
          ),
      if (focusHash == null &&
          ref.watch(chainBackendProvider(config.id)) != null &&
          ref
                  .watch(backendChainHistoryProvider(config.id))
                  .valueOrNull
                  ?.nextCursor !=
              null)
        TextButton(
          onPressed: () async {
            try {
              await ref
                  .read(backendChainHistoryProvider(config.id).notifier)
                  .loadMore();
            } catch (_) {
              if (context.mounted)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      chainText(
                        context,
                        'Unable to load earlier history. Try again.',
                        '较早记录加载失败，请重试。',
                      ),
                    ),
                  ),
                );
            }
          },
          child: Text(chainText(context, 'Load earlier activity', '加载更早记录')),
        ),
    ],
  );
}

class ChainDetail extends StatelessWidget {
  const ChainDetail({
    super.key,
    required this.label,
    required this.value,
    this.valueWidget,
  });
  final String label;
  final String value;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 4),
        valueWidget ??
            SelectableText(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
      ],
    ),
  );
}
