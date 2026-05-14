import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/platform/platform_capabilities.dart';
import '../../../../core/security/secure_screen.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/responsive_action_group.dart';
import 'import_wallet_loading_page.dart';

class ImportMnemonicPage extends StatefulWidget {
  const ImportMnemonicPage({super.key});

  static const routeName = 'importMnemonic';
  static const routePath = '/import';

  @override
  State<ImportMnemonicPage> createState() => _ImportMnemonicPageState();
}

class _ImportMnemonicPageState extends State<ImportMnemonicPage> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _scrollController = ScrollController();
  String? _lastAutoDismissedMnemonic;
  bool _submitting = false;

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
}
