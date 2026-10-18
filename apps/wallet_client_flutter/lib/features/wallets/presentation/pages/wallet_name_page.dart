import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/providers.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../l10n/l10n.dart';
import '../../../auth/data/wallet_repository.dart';
import '../../../auth/presentation/pages/pin_setup_page.dart';
import '../../../auth/presentation/providers/wallet_controller.dart';
import '../../data/seed_vault_seed_names.dart';
import '../wallet_flow.dart';
import '../widgets/wallet_visuals.dart';

/// Name step shown before the PIN (first wallet) or before saving (adding a
/// wallet while unlocked). Pre-filled with the next "Wallet N".
class WalletNamePage extends ConsumerStatefulWidget {
  const WalletNamePage({super.key, required this.flow});

  static const routeName = 'walletName';
  static const routePath = '/wallet-name';

  final PinSetupFlowData flow;

  @override
  ConsumerState<WalletNamePage> createState() => _WalletNamePageState();
}

class _WalletNamePageState extends ConsumerState<WalletNamePage> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _submitting = false;
  bool _showEmptyError = false;

  @override
  void initState() {
    super.initState();
    _controller.text = 'Wallet 1';
    _loadDefaultName();
  }

  Future<void> _loadDefaultName() async {
    final repository = ref.read(walletRepositoryProvider);
    final records = await repository.readRecords();
    var name = repository.nextDefaultWalletName(records);
    // A Seed Vault wallet is named after its seed ("Seeker Main"), numbered
    // when another wallet already uses that name.
    final publicKey = widget.flow.publicKey;
    if (widget.flow.seedVaultAuthToken != null && publicKey != null) {
      final seedName = await ref
          .read(seedVaultSeedNamesProvider)
          .nameFor(publicKey);
      if (seedName != null && seedName.trim().isNotEmpty) {
        final used = {for (final record in records) record.name.trim()};
        name = seedName.trim();
        for (var n = 2; used.contains(name); n++) {
          name = '${seedName.trim()} $n';
        }
      }
    }
    // An offline-signer wallet is named after the signer ("Seeker Signer").
    final signerName = widget.flow.walletLabel?.trim();
    if (widget.flow.isAirGapSetup &&
        signerName != null &&
        signerName.isNotEmpty) {
      final used = {for (final record in records) record.name.trim()};
      name = signerName;
      for (var n = 2; used.contains(name); n++) {
        name = '$signerName $n';
      }
    }
    if (!mounted || _controller.text != 'Wallet 1') {
      return;
    }
    _controller.value = TextEditingValue(
      text: name,
      selection: TextSelection(baseOffset: 0, extentOffset: name.length),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  NewWalletInput _input() {
    final flow = widget.flow;
    if (flow.isAirGapSetup) {
      return NewWalletInput.airGap(
        publicKey: flow.publicKey!,
        derivationPath: flow.airGapDerivationPath!,
        airGapMeta: flow.airGapMeta ?? '',
        walletLabel: flow.walletLabel,
      );
    }
    if (flow.isSeedVaultSetup) {
      return NewWalletInput.seedVault(
        publicKey: flow.publicKey!,
        authToken: flow.seedVaultAuthToken!,
        derivationPath: flow.seedVaultDerivationPath!,
        walletLabel: flow.walletLabel,
      );
    }
    if (flow.isMobileWalletAdapterSetup) {
      return NewWalletInput.mobileWalletAdapter(
        publicKey: flow.publicKey!,
        authToken: flow.mobileWalletAuthToken!,
        walletLabel: flow.walletLabel,
      );
    }
    return NewWalletInput.mnemonic(
      mnemonic: flow.mnemonic!,
      derivation: flow.derivation,
      publicKey: flow.publicKey,
    );
  }

  Future<void> _continue() async {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      setState(() => _showEmptyError = true);
      _focusNode.requestFocus();
      return;
    }
    if (_submitting) {
      return;
    }
    _focusNode.unfocus();

    if (!isAddingWallet(ref)) {
      context.push(
        PinSetupPage.routePath,
        extra: widget.flow.copyWith(walletName: name),
      );
      return;
    }

    setState(() => _submitting = true);
    final added = await completeAddWallet(context, ref, _input(), name: name);
    if (mounted && !added) {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final publicKey = widget.flow.publicKey;

    return AppScaffold(
      title: l10n.walletNameTitle,
      child: ListView(
        padding: const EdgeInsets.only(top: 8),
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              color: theme.colorScheme.tertiaryContainer,
            ),
            child: Column(
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.42),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 32,
                    color: theme.colorScheme.onTertiaryContainer,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.walletNameTitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: theme.colorScheme.onTertiaryContainer,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.walletNameSubtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onTertiaryContainer.withValues(
                      alpha: 0.78,
                    ),
                  ),
                ),
                if (publicKey != null && publicKey.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  WalletBadge(label: walletShortAddress(publicKey)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          WalletCard(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              maxLength: WalletRepository.maxWalletNameLength,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.words,
              enabled: !_submitting,
              onChanged: (_) {
                if (_showEmptyError) {
                  setState(() => _showEmptyError = false);
                }
              },
              onSubmitted: (_) => _continue(),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: WalletPalette.ink,
              ),
              decoration: InputDecoration(
                labelText: l10n.walletNameLabel,
                errorText: _showEmptyError ? l10n.walletNameEmpty : null,
                filled: true,
                fillColor: WalletPalette.tile,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  tooltip: MaterialLocalizations.of(
                    context,
                  ).deleteButtonTooltip,
                  onPressed: _submitting ? null : _controller.clear,
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: _submitting
                ? const Center(
                    key: ValueKey('saving'),
                    child: SizedBox.square(
                      dimension: 48,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    ),
                  )
                : FractionallySizedBox(
                    key: const ValueKey('continue'),
                    widthFactor: 0.75,
                    child: PrimaryButton(
                      label: l10n.commonContinue,
                      onPressed: _continue,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
