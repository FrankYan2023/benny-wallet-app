import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/pin_prompt_dialog.dart';
import '../../../../l10n/l10n.dart';
import '../../../auth/data/wallet_repository.dart';
import '../../../auth/domain/wallet_controller_state.dart';
import '../../../auth/presentation/providers/wallet_controller.dart';
import '../../../onboarding/presentation/pages/welcome_page.dart';
import '../wallet_flow.dart';
import '../widgets/wallet_visuals.dart';

/// Lists every wallet: tap to switch, rename, remove, or add a new one.
class WalletsPage extends ConsumerWidget {
  const WalletsPage({super.key});

  static const routeName = 'wallets';
  static const routePath = '/wallets';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final walletState = ref.watch(walletControllerProvider);
    final wallets = walletState.wallets;
    final childLocked = walletState.childModeEnabled;
    final canAdd = wallets.length < AppConstants.maxWalletCount;

    return AppScaffold(
      title: l10n.walletsTitle,
      child: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 0, 6, 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    childLocked
                        ? l10n.walletChildModeLocked
                        : l10n.walletAddSheetSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: WalletPalette.muted,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                WalletBadge(
                  label: l10n.walletSwitcherCount(
                    wallets.length,
                    AppConstants.maxWalletCount,
                  ),
                ),
              ],
            ),
          ),
          for (final wallet in wallets) ...[
            _WalletManageRow(
              wallet: wallet,
              active: wallet.publicKey == walletState.publicKey,
              locked: childLocked,
            ),
            const SizedBox(height: 10),
          ],
          if (!childLocked && !walletState.travelGuardSession) ...[
            const SizedBox(height: 6),
            WalletActionRow(
              leading: const WalletIconCircle(icon: Icons.add_rounded),
              title: l10n.walletAddWallet,
              subtitle: canAdd
                  ? null
                  : Text(
                      l10n.walletAddLimitReached(AppConstants.maxWalletCount),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: WalletPalette.muted,
                      ),
                    ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: canAdd ? () => startAddWallet(context, ref) : null,
            ),
          ],
        ],
      ),
    );
  }
}

enum _WalletMenuAction { rename, remove }

class _WalletManageRow extends ConsumerWidget {
  const _WalletManageRow({
    required this.wallet,
    required this.active,
    required this.locked,
  });

  final WalletSummary wallet;
  final bool active;
  final bool locked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return WalletActionRow(
      leading: WalletAvatar(
        wallet: wallet,
        ringColor: active ? WalletPalette.tileSelected : WalletPalette.tile,
      ),
      title: walletDisplayName(wallet),
      titleTag: WalletTypeTag(wallet: wallet),
      subtitle: WalletTypeLabel(wallet: wallet),
      selected: active,
      onTap: locked && !active
          ? null
          : () => switchWallet(context, ref, wallet),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (active)
            Tooltip(
              message: l10n.walletActiveBadge,
              child: const Icon(
                Icons.check_circle_rounded,
                color: WalletPalette.accent,
              ),
            ),
          if (!locked)
            PopupMenuButton<_WalletMenuAction>(
              tooltip: l10n.walletManage,
              icon: const Icon(Icons.more_horiz_rounded),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              onSelected: (action) => switch (action) {
                _WalletMenuAction.rename => _rename(context, ref),
                _WalletMenuAction.remove => _remove(context, ref),
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: _WalletMenuAction.rename,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.edit_rounded),
                    title: Text(l10n.walletRename),
                  ),
                ),
                PopupMenuItem(
                  value: _WalletMenuAction.remove,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.delete_outline_rounded,
                      color: WalletPalette.danger,
                    ),
                    title: Text(
                      l10n.walletRemove,
                      style: const TextStyle(color: WalletPalette.danger),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _rename(BuildContext context, WidgetRef ref) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _RenameDialog(initialName: wallet.name),
    );
    if (name == null || name.trim().isEmpty || !context.mounted) {
      return;
    }
    try {
      await ref
          .read(walletControllerProvider.notifier)
          .renameWallet(wallet.publicKey, name);
      HapticFeedback.selectionClick();
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.walletActionFailed)),
        );
      }
    }
  }

  Future<void> _remove(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final name = walletDisplayName(wallet);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l10n.walletRemoveTitle(name)),
        content: Text(
          wallet.isExternal
              ? l10n.walletRemoveExternalMessage
              : l10n.walletRemoveMessage,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: WalletPalette.danger,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.walletRemove),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) {
      return;
    }

    // Removing any wallet, Seed Vault ones included, requires the PIN.
    final controller = ref.read(walletControllerProvider.notifier);
    final pin = await showDialog<String>(
      context: context,
      builder: (_) => PinPromptDialog(title: l10n.walletRemoveTitle(name)),
    );
    if (pin == null || !context.mounted) {
      return;
    }
    try {
      await controller.verifyPin(pin);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.unlockIncorrectPin)));
      }
      return;
    }

    final wasLast = ref.read(walletControllerProvider).wallets.length == 1;
    await controller.removeWallet(wallet.publicKey);
    HapticFeedback.mediumImpact();
    if (!context.mounted) {
      return;
    }
    if (wasLast) {
      context.go(WelcomePage.routePath);
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.walletRemoved(name))));
  }
}

class _RenameDialog extends StatefulWidget {
  const _RenameDialog({required this.initialName});

  final String initialName;

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  late final _controller = TextEditingController(text: widget.initialName)
    ..selection = TextSelection(
      baseOffset: 0,
      extentOffset: widget.initialName.length,
    );
  bool _empty = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      setState(() => _empty = true);
      return;
    }
    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(l10n.walletRenameTitle),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: WalletRepository.maxWalletNameLength,
        textCapitalization: TextCapitalization.words,
        onSubmitted: (_) => _save(),
        onChanged: (_) {
          if (_empty) {
            setState(() => _empty = false);
          }
        },
        decoration: InputDecoration(
          labelText: l10n.walletNameLabel,
          errorText: _empty ? l10n.walletNameEmpty : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(onPressed: _save, child: Text(l10n.walletRename)),
      ],
    );
  }
}
