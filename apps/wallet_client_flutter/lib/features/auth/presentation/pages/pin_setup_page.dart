import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/security/secure_screen.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/pin_keypad.dart';
import '../../../../l10n/l10n.dart';
import '../../../onboarding/presentation/pages/welcome_page.dart';
import '../../../portfolio/presentation/pages/portfolio_page.dart';
import '../../domain/wallet_derivation.dart';
import '../providers/wallet_controller.dart';

class PinSetupFlowData {
  const PinSetupFlowData({
    this.mnemonic,
    this.returnHomeOnSuccess = false,
    this.derivation = WalletDerivation.standard,
    this.publicKey,
    this.mobileWalletAuthToken,
    this.seedVaultAuthToken,
    this.seedVaultDerivationPath,
    this.walletLabel,
  });

  final String? mnemonic;
  final bool returnHomeOnSuccess;
  final WalletDerivation derivation;
  final String? publicKey;
  final String? mobileWalletAuthToken;
  final String? seedVaultAuthToken;
  final String? seedVaultDerivationPath;
  final String? walletLabel;

  PinSetupFlowData copyWith({
    String? mnemonic,
    bool? returnHomeOnSuccess,
    WalletDerivation? derivation,
    String? publicKey,
    String? mobileWalletAuthToken,
    String? seedVaultAuthToken,
    String? seedVaultDerivationPath,
    String? walletLabel,
  }) {
    return PinSetupFlowData(
      mnemonic: mnemonic ?? this.mnemonic,
      returnHomeOnSuccess: returnHomeOnSuccess ?? this.returnHomeOnSuccess,
      derivation: derivation ?? this.derivation,
      publicKey: publicKey ?? this.publicKey,
      mobileWalletAuthToken:
          mobileWalletAuthToken ?? this.mobileWalletAuthToken,
      seedVaultAuthToken: seedVaultAuthToken ?? this.seedVaultAuthToken,
      seedVaultDerivationPath:
          seedVaultDerivationPath ?? this.seedVaultDerivationPath,
      walletLabel: walletLabel ?? this.walletLabel,
    );
  }
}

class PinSetupPage extends ConsumerStatefulWidget {
  const PinSetupPage({
    super.key,
    this.mnemonic,
    this.returnHomeOnSuccess = false,
    this.derivation = WalletDerivation.standard,
    this.publicKey,
    this.mobileWalletAuthToken,
    this.seedVaultAuthToken,
    this.seedVaultDerivationPath,
    this.walletLabel,
  });

  static const routeName = 'pinSetup';
  static const routePath = '/pin-setup';
  final String? mnemonic;
  final bool returnHomeOnSuccess;
  final WalletDerivation derivation;
  final String? publicKey;
  final String? mobileWalletAuthToken;
  final String? seedVaultAuthToken;
  final String? seedVaultDerivationPath;
  final String? walletLabel;

  bool get isMobileWalletAdapterSetup =>
      mobileWalletAuthToken != null && mobileWalletAuthToken!.isNotEmpty;
  bool get isSeedVaultSetup =>
      seedVaultAuthToken != null &&
      seedVaultAuthToken!.isNotEmpty &&
      seedVaultDerivationPath != null &&
      seedVaultDerivationPath!.isNotEmpty;

  @override
  ConsumerState<PinSetupPage> createState() => _PinSetupPageState();
}

class _PinSetupPageState extends ConsumerState<PinSetupPage> {
  String _pin = '';
  String _confirmPin = '';
  bool _confirming = false;
  bool _submitting = false;

  String get _activePin => _confirming ? _confirmPin : _pin;

  void _appendDigit(String digit) {
    if (_submitting || _activePin.length >= 6) {
      return;
    }
    setState(() {
      if (_confirming) {
        _confirmPin = '$_confirmPin$digit';
      } else {
        _pin = '$_pin$digit';
      }
    });
    if (_activePin.length == 6) {
      Future<void>.microtask(_submitStep);
    }
  }

  void _removeDigit() {
    if (_submitting || _activePin.isEmpty) {
      return;
    }
    setState(() {
      if (_confirming) {
        _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
      } else {
        _pin = _pin.substring(0, _pin.length - 1);
      }
    });
  }

  Future<void> _submitStep() async {
    if (_activePin.length != 6 || _submitting) {
      return;
    }

    if (!_confirming) {
      setState(() => _confirming = true);
      return;
    }

    if (_pin != _confirmPin) {
      setState(() => _confirmPin = '');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.pinMismatch)));
      return;
    }

    setState(() => _submitting = true);
    if (widget.isSeedVaultSetup) {
      await ref
          .read(walletControllerProvider.notifier)
          .importSeedVaultWallet(
            publicKey: widget.publicKey!,
            authToken: widget.seedVaultAuthToken!,
            derivationPath: widget.seedVaultDerivationPath!,
            pin: _pin,
            walletLabel: widget.walletLabel,
          );
    } else if (widget.isMobileWalletAdapterSetup) {
      await ref
          .read(walletControllerProvider.notifier)
          .importMobileWalletAdapterWallet(
            publicKey: widget.publicKey!,
            authToken: widget.mobileWalletAuthToken!,
            pin: _pin,
            walletLabel: widget.walletLabel,
          );
    } else {
      await ref
          .read(walletControllerProvider.notifier)
          .importWallet(
            mnemonic: widget.mnemonic!,
            pin: _pin,
            biometricEnabled: false,
            derivation: widget.derivation,
            publicKey: widget.publicKey,
          );
    }
    if (!mounted) {
      return;
    }
    setState(() => _submitting = false);

    final state = ref.read(walletControllerProvider);
    if (state.isUnlocked) {
      context.go(PortfolioPage.routePath);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage ?? context.l10n.pinImportFailed),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || _submitting || !mounted) {
          return;
        }
        if (_confirming) {
          setState(() {
            _confirming = false;
            _confirmPin = '';
          });
          return;
        }
        if (context.canPop()) {
          context.pop();
          return;
        }
        context.go(WelcomePage.routePath);
      },
      child: SecureScreen(
        child: AppScaffold(
          title: '',
          showTopBar: false,
          child: SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    tooltip: l10n.commonBack,
                    onPressed: _submitting
                        ? null
                        : () {
                            if (_confirming) {
                              setState(() {
                                _confirming = false;
                                _confirmPin = '';
                              });
                              return;
                            }
                            if (context.canPop()) {
                              context.pop();
                              return;
                            }
                            context.go(WelcomePage.routePath);
                          },
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                ),
                const Spacer(),
                Text(
                  _confirming ? l10n.pinConfirm : l10n.pinSet,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (widget.isMobileWalletAdapterSetup) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      l10n.pinExternalWalletSetupDescription,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                PinDots(filledCount: _activePin.length),
                const SizedBox(height: 30),
                PinKeypad(
                  onDigit: _submitting ? null : _appendDigit,
                  onDelete: _submitting || _activePin.isEmpty
                      ? null
                      : _removeDigit,
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
