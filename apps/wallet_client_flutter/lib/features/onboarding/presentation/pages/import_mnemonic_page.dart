import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/providers.dart';
import '../../../../core/config/app_features.dart';
import '../../../../core/platform/platform_capabilities.dart';
import '../../../../core/security/secure_screen.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/responsive_action_group.dart';
import '../../../auth/presentation/pages/pin_setup_page.dart';
import 'import_wallet_loading_page.dart';

class ImportMnemonicPage extends ConsumerStatefulWidget {
  const ImportMnemonicPage({super.key});

  static const routeName = 'importMnemonic';
  static const routePath = '/import';

  @override
  ConsumerState<ImportMnemonicPage> createState() => _ImportMnemonicPageState();
}

class _ImportMnemonicPageState extends ConsumerState<ImportMnemonicPage> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _scrollController = ScrollController();
  String? _lastAutoDismissedMnemonic;
  bool _submitting = false;
  bool _connectingVault = false;

  String get _normalizedMnemonic =>
      Validators.normalizeMnemonic(_controller.text);

  bool get _isInputLikelyValid => Validators.isValidMnemonic(_controller.text);

  int get _mnemonicWordCount {
    final normalized = _normalizedMnemonic;
    if (normalized.isEmpty) {
      return 0;
    }
    return normalized.split(' ').length;
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onMnemonicChanged(String value) {
    final normalized = Validators.normalizeMnemonic(value);
    final isComplete =
        Validators.isValidMnemonic(normalized) &&
        _isSupportedMnemonicLength(normalized);

    setState(() {
      _submitting = false;
    });

    if (!isComplete) {
      _lastAutoDismissedMnemonic = null;
      return;
    }

    if (_lastAutoDismissedMnemonic == normalized) {
      return;
    }
    _lastAutoDismissedMnemonic = normalized;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _focusNode.unfocus();
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
        );
      }
    });
  }

  bool _isSupportedMnemonicLength(String normalizedMnemonic) {
    if (normalizedMnemonic.isEmpty) {
      return false;
    }
    final words = normalizedMnemonic.split(' ').length;
    return words == 12 || words == 24;
  }

  Future<void> _continue() async {
    if (!_isInputLikelyValid || _submitting) {
      return;
    }

    _focusNode.unfocus();
    setState(() => _submitting = true);
    if (!mounted) {
      return;
    }

    await context.push(
      ImportWalletLoadingPage.routePath,
      extra: ImportWalletLoadingFlowData(mnemonic: _normalizedMnemonic),
    );

    if (!mounted) {
      return;
    }
    setState(() => _submitting = false);
  }

  Future<void> _connectSeekerVault() async {
    if (_connectingVault) {
      return;
    }

    setState(() => _connectingVault = true);
    try {
      final connection = await ref
          .read(mobileWalletAdapterServiceProvider)
          .connect();
      final authentication = await ref
          .read(backendSessionManagerProvider)
          .authenticateMobileWallet(
            ownerAddress: connection.publicKey,
            authToken: connection.authToken,
          );
      if (!mounted) {
        return;
      }
      await context.push(
        PinSetupPage.routePath,
        extra: PinSetupFlowData(
          publicKey: connection.publicKey,
          mobileWalletAuthToken: authentication.authToken,
          walletLabel: connection.accountLabel,
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_friendlyVaultError(error))));
    } finally {
      if (mounted) {
        setState(() => _connectingVault = false);
      }
    }
  }

  void _clearMnemonic() {
    _controller.clear();
    _lastAutoDismissedMnemonic = null;
    _focusNode.requestFocus();
    setState(() {
      _submitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final seekerVaultAvailable =
        ref.watch(seekerVaultAvailableProvider).valueOrNull ?? false;

    return SecureScreen(
      child: AppScaffold(
        title: 'Import Wallet',
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _focusNode.unfocus,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(bottom: 16),
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        color: theme.colorScheme.secondaryContainer,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.42),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Icon(
                              Icons.download_rounded,
                              size: 32,
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Import recovery phrase',
                            style: theme.textTheme.displaySmall?.copyWith(
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Use 12 or 24 English words.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSecondaryContainer
                                  .withValues(alpha: 0.78),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (PlatformCapabilities.shouldWarnWebStorageRisk)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          'Web is for testing only.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    if (AppFeatures.canConnectSeekerVault &&
                        seekerVaultAvailable) ...[
                      _SeekerVaultCard(
                        connecting: _connectingVault,
                        onConnect: _connectSeekerVault,
                      ),
                      const SizedBox(height: 16),
                    ],
                    WalletCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            maxLines: 6,
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.multiline,
                            decoration: InputDecoration(
                              hintText: 'Paste your recovery phrase here',
                              errorText:
                                  _controller.text.isEmpty ||
                                      _isInputLikelyValid
                                  ? null
                                  : 'Invalid recovery phrase',
                            ),
                            onChanged: _onMnemonicChanged,
                            onSubmitted: (_) => _focusNode.unfocus(),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _mnemonicWordCount == 0
                                ? 'Enter or paste 12 or 24 words.'
                                : '$_mnemonicWordCount words detected',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedPadding(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding: EdgeInsets.only(bottom: bottomInset > 0 ? 12 : 0),
                child: ResponsiveActionGroup(
                  children: [
                    OutlinedButton(
                      onPressed: _controller.text.isEmpty
                          ? null
                          : _clearMnemonic,
                      child: const Text('Clear'),
                    ),
                    PrimaryButton(
                      label: 'Continue',
                      onPressed: _isInputLikelyValid ? _continue : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _friendlyVaultError(Object error) {
    final message = error.toString().toLowerCase();
    if (message.contains('mwa_no_wallet') ||
        message.contains('no compatible wallet')) {
      return 'Install or enable Seeker Wallet, then try again.';
    }
    if (message.contains('unsupported')) {
      return 'Seeker Vault import is available on Android only.';
    }
    if (message.contains('cancel') || message.contains('interrupted')) {
      return 'Seeker Vault connection was cancelled.';
    }
    return 'Unable to connect Seeker Vault right now.';
  }
}

class _SeekerVaultCard extends StatelessWidget {
  const _SeekerVaultCard({required this.connecting, required this.onConnect});

  final bool connecting;
  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WalletCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.security_rounded,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Seeker Vault', style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'Connect the hardware-backed wallet on this Seeker.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.tonal(
            onPressed: connecting ? null : onConnect,
            child: connecting
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Connect'),
          ),
        ],
      ),
    );
  }
}
