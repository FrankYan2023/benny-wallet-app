import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/platform/platform_capabilities.dart';
import '../../../../core/utils/clipboard_utils.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/responsive_action_group.dart';
import '../../../auth/presentation/providers/wallet_controller.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';

class ReceivePage extends ConsumerWidget {
  const ReceivePage({super.key});

  static const routeName = 'receive';
  static const routePath = '/receive';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final address = ref.watch(walletControllerProvider).publicKey;
    final hasAddress = address != null && address.isNotEmpty;
    final theme = Theme.of(context);

    return AppScaffold(
      title: 'Receive',
      actions: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(22),
          ),
          child: IconButton(
            tooltip: 'Received history',
            onPressed: () => context.push(ReceivedHistoryPage.routePath),
            icon: const Icon(Icons.history_rounded),
          ),
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
                  'Share this address',
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Scan or copy it.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer.withValues(
                      alpha: 0.78,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (!hasAddress)
            WalletCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No wallet address available',
                    style: theme.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Create or unlock a wallet to receive funds.',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            WalletCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: QrImageView(
                      data: address,
                      size: 208,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SelectableText(
                    address,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 18),
                  ResponsiveActionGroup(
                    breakpoint: 440,
                    children: [
                      OutlinedButton(
                        onPressed: () async {
                          await ClipboardUtils.setDataWithAutoWipe(
                            address,
                            clearDelay: ClipboardUtils.addressClearDelay,
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Address copied (will clear in 60s)',
                                ),
                              ),
                            );
                          }
                        },
                        child: const Text('Copy address'),
                      ),
                      PrimaryButton(
                        label: PlatformCapabilities.shouldOfferShareOnReceive
                            ? 'Share'
                            : 'Done',
                        onPressed: () async {
                          await ClipboardUtils.setDataWithAutoWipe(
                            address,
                            clearDelay: ClipboardUtils.addressClearDelay,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
