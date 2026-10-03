import '../../../core/widgets/network_badge.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/chains/chain_models.dart';
import '../../../core/utils/clipboard_utils.dart';
import '../providers/multichain_providers.dart';

String chainText(BuildContext context, String english, String chinese) =>
    Localizations.localeOf(context).languageCode == 'zh' ? chinese : english;

String networkPath(String chainId) =>
    '/networks/${Uri.encodeComponent(chainId)}';
String networkSendPath(String chainId, {String? assetId}) => Uri(
  path: '/send',
  queryParameters: {'network': chainId, if (assetId != null) 'asset': assetId},
).toString();

ChainConfig? findChain(List<ChainConfig> configs, String id) {
  for (final config in configs) {
    if (config.id == id) return config;
  }
  return null;
}

/// Resolves a stored transaction network independently of the current selection.
class ChainNetworkIdentity extends ConsumerWidget {
  const ChainNetworkIdentity({super.key, required this.chainId});
  final String chainId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = findChain(ref.watch(chainConfigsProvider), chainId);
    return config == null
        ? NetworkBadge(name: chainId)
        : NetworkBadge.fromConfig(config);
  }
}

class ChainNetworkLabel extends StatelessWidget {
  const ChainNetworkLabel({super.key, required this.config});
  final ChainConfig config;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      NetworkBadge.fromConfig(config, compact: false),
      if (config.isTestnet)
        Chip(
          label: Text(chainText(context, 'Testnet', '测试网')),
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
        ),
    ],
  );
}

class ChainNetworkSelector extends ConsumerWidget {
  const ChainNetworkSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configs = ref.watch(chainConfigsProvider);
    final selected = findChain(configs, value);
    final theme = Theme.of(context);
    return PopupMenuButton<String>(
      tooltip: chainText(context, 'Choose network', '选择网络'),
      position: PopupMenuPosition.under,
      offset: const Offset(0, 8),
      constraints: const BoxConstraints.tightFor(width: 224),
      menuPadding: const EdgeInsets.all(8),
      color: theme.colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: .65),
        ),
      ),
      onSelected: onChanged,
      itemBuilder: (_) => [
        for (final config in configs)
          PopupMenuItem<String>(
            value: config.id,
            height: 56,
            padding: EdgeInsets.zero,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: config.id == value
                    ? theme.colorScheme.primary.withValues(alpha: .08)
                    : null,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: NetworkBadge.fromConfig(config, compact: false),
                  ),
                  if (config.id == value) ...[
                    const SizedBox(width: 10),
                    Icon(
                      Icons.check_rounded,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
      child: SizedBox(
        width: double.infinity,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: chainText(context, 'Network', '网络'),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            filled: true,
            fillColor: theme.colorScheme.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 18,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: selected == null
                    ? NetworkBadge(name: value, compact: false)
                    : NetworkBadge.fromConfig(selected, compact: false),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.expand_more_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChainErrorCard extends StatelessWidget {
  const ChainErrorCard({super.key, required this.error, required this.onRetry});
  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => WalletCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          chainText(context, 'Unable to load this network', '无法加载此网络'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text('$error'),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: Text(chainText(context, 'Try again', '重试')),
        ),
      ],
    ),
  );
}

class ChainReceivePanel extends ConsumerWidget {
  const ChainReceivePanel({super.key, required this.config});
  final ChainConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(chainAccountProvider(config.id));
    return account.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => ChainErrorCard(
        error: error,
        onRetry: () => ref.invalidate(chainAccountProvider(config.id)),
      ),
      data: (account) => WalletCard(
        child: Column(
          children: [
            ChainNetworkLabel(config: config),
            const SizedBox(height: 8),
            Text(
              chainText(
                context,
                'Only receive assets on ${config.displayName} at this address.',
                '请仅通过 ${config.displayName} 网络向此地址接收资产。',
              ),
              textAlign: TextAlign.center,
            ),
            if (config.isTestnet) ...[
              const SizedBox(height: 6),
              Text(
                chainText(
                  context,
                  'Test tokens have no monetary value.',
                  '测试代币无实际货币价值。',
                ),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
              ),
              child: QrImageView(
                data: account.address,
                size: 208,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            SelectableText(
              account.address,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              icon: const Icon(Icons.copy_rounded),
              label: Text(chainText(context, 'Copy address', '复制地址')),
              onPressed: () async {
                await ClipboardUtils.setDataWithAutoWipe(
                  account.address,
                  clearDelay: ClipboardUtils.addressClearDelay,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        chainText(context, 'Address copied', '地址已复制'),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
