import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../l10n/l10n.dart';
import '../../../auth/domain/wallet_controller_state.dart';
import '../../../auth/presentation/providers/wallet_controller.dart';
import '../wallet_flow.dart';
import 'wallet_visuals.dart';

/// Home-screen pill showing the active wallet; opens the switcher sheet.
class WalletSwitcherChip extends ConsumerWidget {
  const WalletSwitcherChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(
      walletControllerProvider.select((state) => state.activeWallet),
    );
    final walletCount = ref.watch(
      walletControllerProvider.select((state) => state.wallets.length),
    );
    final childMode = ref.watch(
      walletControllerProvider.select((state) => state.childModeEnabled),
    );
    // A travel guard session cannot add wallets (no master key).
    final guardSession = ref.watch(
      walletControllerProvider.select((state) => state.travelGuardSession),
    );
    // Child mode hides wallet switching entirely.
    if (active == null || childMode) {
      return const SizedBox.shrink();
    }

    final l10n = context.l10n;
    final canAdd =
        !childMode &&
        !guardSession &&
        walletCount < AppConstants.maxWalletCount;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          // Full-width selector; the add button stays pinned to the right.
          Expanded(
            child: Semantics(
              button: true,
              label: l10n.walletSwitcherTitle,
              child: Material(
                color: WalletPalette.tile,
                shape: const StadiumBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => showWalletSwitcherSheet(context, ref),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 14, 8),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      switchInCurve: Curves.easeOutCubic,
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween(
                            begin: const Offset(0, 0.25),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      ),
                      child: _ChipContent(
                        key: ValueKey(active.publicKey + active.name),
                        wallet: active,
                        showChevron: walletCount > 1 || !childMode,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (canAdd) ...[
            const SizedBox(width: 10),
            Material(
              color: WalletPalette.tile,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: IconButton(
                constraints: const BoxConstraints.tightFor(
                  width: 52,
                  height: 52,
                ),
                tooltip: l10n.walletAddWallet,
                onPressed: () => startAddWallet(context, ref),
                icon: const Icon(
                  Icons.add_rounded,
                  color: WalletPalette.accent,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ChipContent extends StatelessWidget {
  const _ChipContent({
    super.key,
    required this.wallet,
    required this.showChevron,
  });

  final WalletSummary wallet;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        WalletAvatar(wallet: wallet, size: 40),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      walletDisplayName(wallet),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: WalletPalette.ink,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                  ),
                  // Same marker as the wallet lists; standard wallets need none.
                  if (wallet.isExternal) ...[
                    const SizedBox(width: 6),
                    WalletTypeTag(wallet: wallet),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              WalletTypeLabel(wallet: wallet),
            ],
          ),
        ),
        if (showChevron) ...[
          const SizedBox(width: 8),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: WalletPalette.muted,
            size: 22,
          ),
        ],
      ],
    );
  }
}
