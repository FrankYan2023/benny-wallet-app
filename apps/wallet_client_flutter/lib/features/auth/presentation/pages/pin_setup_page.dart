import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/security/secure_screen.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/pin_keypad.dart';
import '../../../onboarding/presentation/pages/welcome_page.dart';
import '../../../portfolio/presentation/pages/portfolio_page.dart';
import '../../domain/wallet_derivation.dart';
import '../providers/wallet_controller.dart';

class PinSetupFlowData {
  const PinSetupFlowData({
    required this.mnemonic,
    this.returnHomeOnSuccess = false,
    this.derivation = WalletDerivation.standard,
    this.publicKey,
  });

  final String mnemonic;
  final bool returnHomeOnSuccess;
  final WalletDerivation derivation;
  final String? publicKey;

  PinSetupFlowData copyWith({
    String? mnemonic,
    bool? returnHomeOnSuccess,
    WalletDerivation? derivation,
    String? publicKey,
  }) {
    return PinSetupFlowData(
      mnemonic: mnemonic ?? this.mnemonic,
      returnHomeOnSuccess: returnHomeOnSuccess ?? this.returnHomeOnSuccess,
      derivation: derivation ?? this.derivation,
      publicKey: publicKey ?? this.publicKey,
    );
  }
}

class PinSetupPage extends ConsumerStatefulWidget {
  const PinSetupPage({
    super.key,
    required this.mnemonic,
    this.returnHomeOnSuccess = false,
    this.derivation = WalletDerivation.standard,
    this.publicKey,
  });

  static const routeName = 'pinSetup';
  static const routePath = '/pin-setup';
  final String mnemonic;
  final bool returnHomeOnSuccess;
  final WalletDerivation derivation;
  final String? publicKey;

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
      ).showSnackBar(const SnackBar(content: Text('PINs do not match')));
      return;
    }

    setState(() => _submitting = true);
    await ref
        .read(walletControllerProvider.notifier)
        .importWallet(
          mnemonic: widget.mnemonic,
          pin: _pin,
          biometricEnabled: false,
          derivation: widget.derivation,
          publicKey: widget.publicKey,
        );
    if (!mounted) {
      return;
    }
    setState(() => _submitting = false);

    final state = ref.read(walletControllerProvider);
    if (state.isUnlocked) {
      context.go(PortfolioPage.routePath);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.errorMessage ?? 'Import failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    tooltip: 'Back',
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
                  _confirming ? 'Confirm PIN' : 'Set PIN',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
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
