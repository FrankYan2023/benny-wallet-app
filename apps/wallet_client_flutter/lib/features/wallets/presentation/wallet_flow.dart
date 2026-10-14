import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di/providers.dart';
import '../../../core/config/app_features.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/error_alert_dialog.dart';
import '../../../core/widgets/pin_prompt_dialog.dart';
import '../../../l10n/l10n.dart';
import '../../auth/data/wallet_repository.dart';
import '../../auth/domain/wallet_controller_state.dart';
import '../../auth/presentation/providers/wallet_controller.dart';
import '../../onboarding/presentation/pages/create_wallet_page.dart';
import '../../onboarding/presentation/pages/import_mnemonic_page.dart';
import '../../portfolio/presentation/pages/portfolio_page.dart';
import '../../portfolio/presentation/providers/portfolio_provider.dart';
import '../../settings/presentation/pages/child_mode_pin_page.dart';
import 'pages/wallets_page.dart';
import 'widgets/wallet_balance_text.dart';
import 'widgets/wallet_visuals.dart';

/// True while the user is adding a wallet from inside the unlocked app. The
/// onboarding pages are reused for this; the route guard lets them open and
/// the name step saves without a new PIN.
final walletAddFlowProvider = StateProvider<bool>((ref) => false);

bool isAddingWallet(WidgetRef ref) {
  return ref.read(walletAddFlowProvider) &&
      ref.read(walletControllerProvider).isUnlocked;
}

// ---------------------------------------------------------------------------
// Switcher
// ---------------------------------------------------------------------------

Future<void> showWalletSwitcherSheet(
  BuildContext context,
  WidgetRef ref,
) async {
  HapticFeedback.selectionClick();
  prefetchWalletPortfolios(ref);
  final action = await showModalBottomSheet<_SwitcherAction>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => const _WalletSwitcherSheet(),
  );
  // The sheet's own context and ref are gone once it closes, so every
  // follow-up runs on the caller's.
  if (action == null || !context.mounted) {
    return;
  }
  switch (action) {
    case _SwitchTo(:final wallet):
      await switchWallet(context, ref, wallet);
    case _AddWallet():
      await startAddWallet(context, ref);
    case _ManageWallets():
      await context.push(WalletsPage.routePath);
  }
}

sealed class _SwitcherAction {
  const _SwitcherAction();
}

final class _SwitchTo extends _SwitcherAction {
  const _SwitchTo(this.wallet);

  final WalletSummary wallet;
}

final class _AddWallet extends _SwitcherAction {
  const _AddWallet();
}

final class _ManageWallets extends _SwitcherAction {
  const _ManageWallets();
}

class _WalletSwitcherSheet extends ConsumerWidget {
  const _WalletSwitcherSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final walletState = ref.watch(walletControllerProvider);
    final wallets = walletState.wallets;
    final canAdd = wallets.length < AppConstants.maxWalletCount;
    final childLocked = walletState.childModeEnabled;

    return WalletSheetFrame(
      title: l10n.walletSwitcherTitle,
      subtitle: childLocked
          ? l10n.walletChildModeLocked
          : l10n.walletSwitcherCount(
              wallets.length,
              AppConstants.maxWalletCount,
            ),
      children: [
        for (final wallet in wallets) ...[
          WalletActionRow(
            leading: WalletAvatar(
              wallet: wallet,
              ringColor: wallet.publicKey == walletState.publicKey
                  ? WalletPalette.tileSelected
                  : WalletPalette.tile,
            ),
            title: walletDisplayName(wallet),
            titleTag: WalletTypeTag(wallet: wallet),
            subtitle: WalletTypeLabel(wallet: wallet),
            selected: wallet.publicKey == walletState.publicKey,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                WalletBalanceText(publicKey: wallet.publicKey),
                if (wallet.publicKey == walletState.publicKey) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.check_circle_rounded,
                    color: WalletPalette.accent,
                  ),
                ],
              ],
            ),
            onTap: childLocked && wallet.publicKey != walletState.publicKey
                ? null
                : () => Navigator.of(context).pop(_SwitchTo(wallet)),
          ),
          const SizedBox(height: 10),
        ],
        if (!childLocked) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: _SheetButton(
                  icon: Icons.add_rounded,
                  label: l10n.walletAddWallet,
                  filled: true,
                  onPressed: canAdd
                      ? () => Navigator.of(context).pop(const _AddWallet())
                      : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SheetButton(
                  icon: Icons.tune_rounded,
                  label: l10n.walletManage,
                  onPressed: () =>
                      Navigator.of(context).pop(const _ManageWallets()),
                ),
              ),
            ],
          ),
          if (!canAdd) ...[
            const SizedBox(height: 10),
            Text(
              l10n.walletAddLimitReached(AppConstants.maxWalletCount),
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: WalletPalette.muted),
            ),
          ],
        ],
      ],
    );
  }
}

class _SheetButton extends StatelessWidget {
  const _SheetButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(999),
    );
    const padding = EdgeInsets.symmetric(vertical: 14);
    return filled
        ? FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: WalletPalette.accent,
              foregroundColor: Colors.white,
              shape: shape,
              padding: padding,
            ),
            onPressed: onPressed,
            icon: Icon(icon),
            label: Text(label),
          )
        : OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: WalletPalette.ink,
              shape: shape,
              padding: padding,
            ),
            onPressed: onPressed,
            icon: Icon(icon),
            label: Text(label),
          );
  }
}

/// Switching is instant while unlocked (one AES decrypt); the portfolio of
/// each wallet is cached so the home screen redraws without a spinner.
Future<void> switchWallet(
  BuildContext context,
  WidgetRef ref,
  WalletSummary wallet,
) async {
  final controller = ref.read(walletControllerProvider.notifier);
  if (ref.read(walletControllerProvider).publicKey == wallet.publicKey) {
    return;
  }
  final messenger = ScaffoldMessenger.maybeOf(context);
  final l10n = context.l10n;
  try {
    await controller.selectWallet(wallet.publicKey);
    // Show the cached balance at once but reload it, since funds may have
    // arrived while another wallet was active.
    ref.invalidate(portfolioProvider(wallet.publicKey));
    HapticFeedback.lightImpact();
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.walletSwitched(walletDisplayName(wallet))),
          duration: const Duration(milliseconds: 1400),
        ),
      );
  } on ChildModeRestrictionException {
    messenger?.showSnackBar(
      SnackBar(content: Text(l10n.walletChildModeLocked)),
    );
  } catch (error) {
    debugPrint('[WALLET] Switch failed: $error');
    messenger?.showSnackBar(SnackBar(content: Text(l10n.walletActionFailed)));
  }
}

/// Warms the portfolio of every other wallet while the user is choosing, so
/// the home screen shows balances immediately after a switch.
void prefetchWalletPortfolios(WidgetRef ref) {
  final walletState = ref.read(walletControllerProvider);
  if (!walletState.isUnlocked) {
    return;
  }
  for (final wallet in walletState.wallets) {
    if (wallet.publicKey == walletState.publicKey) {
      continue;
    }
    final cached = ref.read(portfolioProvider(wallet.publicKey));
    if (!cached.hasValue && !cached.isLoading) {
      ref.read(portfolioProvider(wallet.publicKey).future).ignore();
    }
  }
}

// ---------------------------------------------------------------------------
// Add
// ---------------------------------------------------------------------------

Future<void> startAddWallet(BuildContext context, WidgetRef ref) async {
  final l10n = context.l10n;
  final walletState = ref.read(walletControllerProvider);
  if (walletState.childModeEnabled) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.walletChildModeLocked)));
    return;
  }
  if (walletState.travelGuardSession) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.walletActionFailed)));
    return;
  }
  if (walletState.wallets.length >= AppConstants.maxWalletCount) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.walletAddLimitReached(AppConstants.maxWalletCount)),
      ),
    );
    return;
  }

  final seedVaultAvailable =
      AppFeatures.canConnectSeekerVault &&
      (await ref
          .read(seekerVaultAvailableProvider.future)
          .catchError((_) => false));
  if (!context.mounted) {
    return;
  }

  final route = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => WalletSheetFrame(
      title: l10n.walletAddSheetTitle,
      subtitle: l10n.walletAddSheetSubtitle,
      children: [
        WalletActionRow(
          leading: const WalletIconCircle(icon: Icons.auto_awesome_rounded),
          title: l10n.walletAddCreate,
          subtitle: _RowSubtitle(l10n.walletAddCreateSubtitle),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () =>
              Navigator.of(sheetContext).pop(CreateWalletPage.routePath),
        ),
        const SizedBox(height: 10),
        WalletActionRow(
          leading: const WalletIconCircle(
            icon: Icons.key_rounded,
            color: Color(0xFF4096C9),
          ),
          title: l10n.walletAddImport,
          subtitle: _RowSubtitle(l10n.walletAddImportSubtitle),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () =>
              Navigator.of(sheetContext).pop(ImportMnemonicPage.routePath),
        ),
        if (seedVaultAvailable) ...[
          const SizedBox(height: 10),
          WalletActionRow(
            leading: const WalletIconCircle(
              icon: Icons.security_rounded,
              color: Color(0xFF235E7A),
            ),
            title: l10n.walletAddSeedVault,
            subtitle: _RowSubtitle(l10n.walletAddSeedVaultSubtitle),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.of(
              sheetContext,
            ).pop(ImportMnemonicPage.seedVaultRoutePath),
          ),
        ],
      ],
    ),
  );
  if (route == null || !context.mounted) {
    return;
  }

  ref.read(walletAddFlowProvider.notifier).state = true;
  await context.push(route);
}

class _RowSubtitle extends StatelessWidget {
  const _RowSubtitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: WalletPalette.muted,
        fontSize: 13,
      ),
    );
  }
}

/// Saves the wallet collected by the add flow. Asks for the PIN only if the
/// in-memory master key expired. Returns true when the wallet was added.
Future<bool> completeAddWallet(
  BuildContext context,
  WidgetRef ref,
  NewWalletInput input, {
  required String name,
}) async {
  final l10n = context.l10n;
  final controller = ref.read(walletControllerProvider.notifier);
  String? pin;

  // A child wallet locks the app into child mode once added, so the parent
  // has to agree to that first.
  final childCheck = await controller.checkChildModeWallet(input);
  String? childModePin;
  if (childCheck != ChildWalletCheck.notChild) {
    if (!context.mounted) {
      return false;
    }
    final needsPin = childCheck == ChildWalletCheck.childWithoutPin;
    final agreed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l10n.walletAddChildModeTitle),
        content: Text(
          needsPin
              ? '${l10n.walletAddChildModeMessage}\n\n'
                    '${l10n.walletAddChildModeSetPin}'
              : l10n.walletAddChildModeMessage,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.walletAddChildModeConfirm),
          ),
        ],
      ),
    );
    if (agreed != true || !context.mounted) {
      return false;
    }
    if (needsPin) {
      // Without a PIN anyone could switch child mode off again.
      childModePin = await Navigator.of(context).push<String>(
        MaterialPageRoute<String>(
          builder: (_) => const ChildModePinPage.create(),
        ),
      );
      if (childModePin == null || !context.mounted) {
        return false;
      }
    }
  }

  while (true) {
    try {
      await controller.addWallet(
        input,
        name: name,
        pin: pin,
        childModePin: childModePin,
      );
      ref.read(walletAddFlowProvider.notifier).state = false;
      HapticFeedback.mediumImpact();
      if (context.mounted) {
        context.go(PortfolioPage.routePath);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.walletAdded(name))));
      }
      return true;
    } on MasterKeyLockedException {
      if (!context.mounted) {
        return false;
      }
      pin = await showDialog<String>(
        context: context,
        builder: (_) => PinPromptDialog(title: l10n.walletPinToContinue),
      );
      if (pin == null) {
        return false;
      }
    } on DuplicateWalletException {
      if (context.mounted) {
        await showErrorAlertDialog(
          context,
          title: l10n.walletDuplicateTitle,
          message: l10n.walletDuplicateMessage,
        );
      }
      return false;
    } on WalletLimitReachedException {
      if (context.mounted) {
        await showErrorAlertDialog(
          context,
          title: l10n.walletAddWallet,
          message: l10n.walletAddLimitReached(AppConstants.maxWalletCount),
        );
      }
      return false;
    } on ChildModeRestrictionException {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.walletChildModeLocked)));
      }
      return false;
    } catch (error) {
      debugPrint('[WALLET] Add wallet failed: $error');
      if (!context.mounted) {
        return false;
      }
      final wrongPin = pin != null && error is! ArgumentError;
      await showErrorAlertDialog(
        context,
        title: wrongPin ? l10n.unlockFailedTitle : l10n.walletAddWallet,
        message: wrongPin ? l10n.unlockIncorrectPin : l10n.walletActionFailed,
      );
      if (!wrongPin) {
        return false;
      }
      pin = null;
    }
  }
}
