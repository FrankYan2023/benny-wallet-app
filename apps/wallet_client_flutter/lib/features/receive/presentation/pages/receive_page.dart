import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_scaffold.dart';
import '../../../../l10n/l10n.dart';
import '../../../multichain/presentation/chain_widgets.dart';
import '../../../multichain/providers/multichain_providers.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';

class ReceivePage extends ConsumerWidget {
  const ReceivePage({super.key});

  static const routeName = 'receive';
  static const routePath = '/receive';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configs = ref.watch(chainConfigsProvider);
    final selected = ref.watch(selectedChainIdProvider);
    final config = findChain(configs, selected) ?? configs.first;
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return AppScaffold(
      title: l10n.receiveTitle,
      actions: [
        IconButton(
          tooltip:
              '${configs.first.displayName} · ${l10n.receivedHistoryTitle}',
          onPressed: () => context.push(ReceivedHistoryPage.routePath),
          icon: const Icon(Icons.history_rounded),
        ),
      ],
      child: ListView(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              children: [
                Text(
                  l10n.receiveShareAddressTitle,
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.receiveShareAddressSubtitle,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer.withValues(
                      alpha: 0.78,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ChainNetworkSelector(
            value: config.id,
            onChanged: (id) =>
                ref.read(selectedChainIdProvider.notifier).state = id,
          ),
          const SizedBox(height: 16),
          ChainReceivePanel(config: config),
        ],
      ),
    );
  }
}
