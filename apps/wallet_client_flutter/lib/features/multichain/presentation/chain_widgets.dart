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

class ChainNetworkLabel extends StatelessWidget {
  const ChainNetworkLabel({super.key, required this.config});
  final ChainConfig config;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Text(config.displayName, style: Theme.of(context).textTheme.titleMedium),
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
  Widget build(BuildContext context, WidgetRef ref) =>
      DropdownButtonFormField<String>(
        initialValue: value,
        key: ValueKey(value),
        isExpanded: true,
        decoration: InputDecoration(
          labelText: chainText(context, 'Network', '网络'),
        ),
        items: [
          for (final config in ref.watch(chainConfigsProvider))
            DropdownMenuItem(value: config.id, child: Text(config.displayName)),
        ],
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
      );
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
