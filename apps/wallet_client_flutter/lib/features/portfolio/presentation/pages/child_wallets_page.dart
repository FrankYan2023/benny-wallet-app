import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/pin_prompt_dialog.dart';
import '../../../../l10n/l10n.dart';
import '../../../auth/domain/wallet_controller_state.dart';
import '../../../auth/presentation/providers/wallet_controller.dart';
import '../../../send/presentation/pages/scan_address_page.dart';
import 'child_wallet_monitor_page.dart';

class ChildWalletsPage extends ConsumerStatefulWidget {
  const ChildWalletsPage({super.key});

  static const routeName = 'childWallets';
  static const routePath = '/portfolio/children';

  @override
  ConsumerState<ChildWalletsPage> createState() => _ChildWalletsPageState();
}

class _ChildWalletsPageState extends ConsumerState<ChildWalletsPage> {
  Future<String?> _requestPin() {
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) =>
          PinPromptDialog(title: context.l10n.childVerifyPinTitle),
    );
  }

  Future<bool> _verifyPin() async {
    final pin = await _requestPin();
    if (pin == null) {
      return false;
    }

    try {
      await ref.read(walletControllerProvider.notifier).verifyPin(pin);
      return true;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.settingsIncorrectPin)),
        );
      }
      return false;
    }
  }

  Future<String?> _scanChildWalletAddress() async {
    final scannedAddress = await context.push<String>(
      ScanAddressPage.routePath,
    );
    if (!mounted || scannedAddress == null || scannedAddress.isEmpty) {
      return null;
    }

    return scannedAddress.trim();
  }

  Future<_ChildWalletDraft?> _showEditor({
    ChildWallet? child,
    String? scannedAddress,
  }) {
    return showModalBottomSheet<_ChildWalletDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ChildWalletEditorSheet(
        child: child,
        initialAddress: scannedAddress ?? child?.address ?? '',
      ),
    );
  }

  bool _hasChildWalletAddress(String address, {String? exceptChildId}) {
    final normalized = address.trim();
    if (normalized.isEmpty) {
      return false;
    }

    final children = ref.read(walletControllerProvider).childWallets;
    return children.any(
      (child) =>
          child.id != exceptChildId &&
          child.address.trim().toLowerCase() == normalized.toLowerCase(),
    );
  }

  void _showAlreadyAddedMessage() {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.childWalletAlreadyAdded)),
    );
  }

  Future<void> _addChildWallet() async {
    final scannedAddress = await _scanChildWalletAddress();
    if (scannedAddress == null || !mounted) {
      return;
    }

    if (_hasChildWalletAddress(scannedAddress)) {
      _showAlreadyAddedMessage();
      return;
    }

    final draft = await _showEditor(scannedAddress: scannedAddress);
    if (draft == null) {
      return;
    }

    if (_hasChildWalletAddress(draft.address)) {
      _showAlreadyAddedMessage();
      return;
    }

    final verified = await _verifyPin();
    if (!verified) {
      return;
    }

    try {
      await ref
          .read(walletControllerProvider.notifier)
          .addChildWallet(draft.name, draft.address);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.childWalletAdded(draft.name))),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.childWalletAddFailed('$e'))),
      );
    }
  }

  Future<void> _editChildWallet(ChildWallet child) async {
    final draft = await _showEditor(child: child);
    if (draft == null) {
      return;
    }

    if (_hasChildWalletAddress(draft.address, exceptChildId: child.id)) {
      _showAlreadyAddedMessage();
      return;
    }

    final verified = await _verifyPin();
    if (!verified) {
      return;
    }

    try {
      await ref
          .read(walletControllerProvider.notifier)
          .updateChildWallet(child.id, draft.name, draft.address);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.childWalletUpdated(draft.name))),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.childWalletUpdateFailed('$e'))),
      );
    }
  }

  Future<void> _deleteChildWallet(ChildWallet child) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(context.l10n.childWalletDeleteTitle(child.name)),
        content: Text(context.l10n.childWalletDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(context.l10n.commonDelete),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    final verified = await _verifyPin();
    if (!verified) {
      return;
    }

    try {
      await ref
          .read(walletControllerProvider.notifier)
          .removeChildWallet(child.id);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.childWalletDeleted(child.name))),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.childWalletDeleteFailed('$e'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletControllerProvider);
    final childWallets = walletState.childWallets;
    final theme = Theme.of(context);

    if (walletState.childModeEnabled) {
      return AppScaffold(
        title: context.l10n.childAccountsTitle,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_rounded, size: 40),
                const SizedBox(height: 12),
                Text(
                  context.l10n.childManageUnavailable,
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return AppScaffold(
      title: context.l10n.childAccountsTitle,
      actions: [
        IconButton(
          onPressed: _addChildWallet,
          icon: const Icon(Icons.add_rounded),
        ),
      ],
      child: ListView(
        children: [
          WalletCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  childWallets.isEmpty
                      ? context.l10n.childNoAccountsYet
                      : context.l10n.childAccountCount(childWallets.length),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: _addChildWallet,
                  icon: const Icon(Icons.add_rounded),
                  label: Text(context.l10n.childAddAccount),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (childWallets.isNotEmpty)
            ...childWallets.map(
              (child) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ChildWalletListTile(
                  child: child,
                  onOpen: () => context.push(
                    ChildWalletMonitorPage.routePath,
                    extra: child.id,
                  ),
                  onEdit: () => _editChildWallet(child),
                  onDelete: () => _deleteChildWallet(child),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ChildWalletListTile extends StatelessWidget {
  const _ChildWalletListTile({
    required this.child,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  final ChildWallet child;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initial = child.name.trim().isEmpty
        ? '?'
        : child.name.trim().characters.first;

    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onOpen,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F1E7),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFFE8D9FF),
              foregroundColor: const Color(0xFF6C63FF),
              child: Text(initial),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    child.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    Formatters.compactAddress(child.address, visibleChars: 6),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: context.l10n.commonEdit,
              onPressed: onEdit,
              icon: const Icon(Icons.edit_rounded),
            ),
            IconButton(
              tooltip: context.l10n.commonDelete,
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          ],
        ),
      ),
    );
  }
}

class _ChildWalletEditorSheet extends StatefulWidget {
  const _ChildWalletEditorSheet({this.child, required this.initialAddress});

  final ChildWallet? child;
  final String initialAddress;

  @override
  State<_ChildWalletEditorSheet> createState() =>
      _ChildWalletEditorSheetState();
}

class _ChildWalletEditorSheetState extends State<_ChildWalletEditorSheet> {
  late final TextEditingController _nameController;
  late String _address;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.child?.name ?? '');
    _address = widget.initialAddress.trim();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final address = _address.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.childEnterName)));
      return;
    }
    if (!Validators.isValidPublicAddress(address)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.childEnterValidWalletAddress)),
      );
      return;
    }

    Navigator.of(context).pop(_ChildWalletDraft(name: name, address: address));
  }

  Future<void> _scanAddress() async {
    FocusScope.of(context).unfocus();

    final scannedAddress = await context.push<String>(
      ScanAddressPage.routePath,
    );
    if (!mounted || scannedAddress == null || scannedAddress.isEmpty) {
      return;
    }

    _address = scannedAddress.trim();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.child != null;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(32),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing
                      ? context.l10n.childEditAccount
                      : context.l10n.childAddAccount,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _nameController,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: context.l10n.childName,
                    hintText: context.l10n.childNameHint,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  context.l10n.childWalletAddress,
                  style: theme.textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.35,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Text(_address, style: theme.textTheme.bodyMedium),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: _scanAddress,
                    icon: const Icon(Icons.qr_code_scanner_rounded),
                    label: Text(
                      isEditing
                          ? context.l10n.childScanAgain
                          : context.l10n.childScanQrAgain,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(context.l10n.commonCancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _submit,
                        child: Text(
                          isEditing
                              ? context.l10n.commonSave
                              : context.l10n.commonAdd,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChildWalletDraft {
  const _ChildWalletDraft({required this.name, required this.address});

  final String name;
  final String address;
}
