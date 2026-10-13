import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/platform/platform_capabilities.dart';
import '../../../../core/utils/clipboard_utils.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/responsive_action_group.dart';
import '../../../../l10n/l10n.dart';
import '../../../auth/presentation/providers/wallet_controller.dart';
import '../../../auth/domain/wallet_controller_state.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';
import '../../../wallets/presentation/widgets/wallet_visuals.dart';

class ReceivePage extends ConsumerWidget {
  const ReceivePage({super.key});

  static const routeName = 'receive';
  static const routePath = '/receive';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletState = ref.watch(walletControllerProvider);
    final address = walletState.publicKey;
    final activeWallet = walletState.activeWallet;
    final hasAddress = address != null && address.isNotEmpty;
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return AppScaffold(
      title: l10n.receiveTitle,
      actions: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(22),
          ),
          child: IconButton(
            tooltip: l10n.receivedHistoryTitle,
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
                    l10n.receiveNoAddress,
                    style: theme.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.receiveNoAddressSubtitle,
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
                  if (activeWallet != null) ...[
                    _ReceivingWallet(wallet: activeWallet),
                    const SizedBox(height: 16),
                  ],
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
                              SnackBar(
                                content: Text(l10n.receiveAddressCopied),
                              ),
                            );
                          }
                        },
                        child: Text(l10n.receiveCopyAddress),
                      ),
                      PrimaryButton(
                        label: PlatformCapabilities.shouldOfferShareOnReceive
                            ? l10n.commonShare
                            : l10n.commonDone,
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

/// Which wallet this QR code receives into, so funds land where intended
/// when several wallets exist.
class _ReceivingWallet extends StatelessWidget {
  const _ReceivingWallet({required this.wallet});

  final WalletSummary wallet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 14, 8),
      decoration: BoxDecoration(
        color: WalletPalette.tile,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          WalletAvatar(wallet: wallet, size: 36),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        walletDisplayName(wallet),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: WalletPalette.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    WalletTypeTag(wallet: wallet),
                  ],
                ),
                const SizedBox(height: 2),
                WalletTypeLabel(wallet: wallet),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
