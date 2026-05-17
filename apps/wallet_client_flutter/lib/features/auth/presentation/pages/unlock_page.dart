import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/providers.dart';
import '../../../../core/security/secure_screen.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/error_alert_dialog.dart';
import '../../../../core/widgets/pin_keypad.dart';
import '../../../onboarding/presentation/pages/welcome_page.dart';
import '../../../portfolio/presentation/pages/portfolio_page.dart';
import '../providers/wallet_controller.dart';

class UnlockPage extends ConsumerStatefulWidget {
  const UnlockPage({super.key});

  static const routeName = 'unlock';
  static const routePath = '/unlock';

  @override
  ConsumerState<UnlockPage> createState() => _UnlockPageState();
}

class _UnlockPageState extends ConsumerState<UnlockPage> {
  String _pin = '';
  bool _biometricPrompted = false;
  bool _submitting = false;
  bool _biometricAttempting = false;
  String? _biometricError;

  Future<void> _tryBiometricUnlock() async {
    if (_biometricPrompted || _submitting) {
      return;
    }

    _biometricPrompted = true;
    debugPrint('[SECURITY] Initiating biometric unlock...');

    setState(() {
      _biometricAttempting = true;
      _biometricError = null;
    });

    try {
      final approved = await ref
          .read(biometricAuthServiceProvider)
          .authenticateForUnlock();

      if (!mounted) return;

      if (!approved) {
        debugPrint('[SECURITY] User cancelled biometric');
        setState(() {
          _biometricAttempting = false;
          _biometricError = 'Biometric cancelled';
        });
        return;
      }

      setState(() => _submitting = true);
      final unlocked = await ref
          .read(walletControllerProvider.notifier)
          .unlockWithBiometrics();

      if (!mounted) return;

      setState(() {
        _submitting = false;
        _biometricAttempting = false;
      });

      if (unlocked) {
        debugPrint('[SECURITY] OK Biometric unlock successful');
        context.go(PortfolioPage.routePath);
      } else {
        debugPrint(
          '[SECURITY] ERROR Biometric unlock failed (invalid session)',
        );
        final walletState = ref.read(walletControllerProvider);
        setState(() {
          _biometricError =
              walletState.isExternalWallet && walletState.biometricEnabled
              ? 'Biometric unlock failed. Try again.'
              : 'Session expired, use PIN';
        });
      }
    } catch (e) {
      debugPrint('[SECURITY] ERROR Biometric error: $e');
      if (mounted) {
        setState(() {
          _biometricAttempting = false;
          _biometricError = 'Biometric unavailable';
        });
      }
    }
  }

  Future<void> _retryBiometric() async {
    setState(() {
      _biometricPrompted = false;
      _biometricError = null;
    });
    await _tryBiometricUnlock();
  }

  Future<void> _unlock() async {
    if (_pin.length != 6 || _submitting) {
      return;
    }

    setState(() => _submitting = true);
    await ref.read(walletControllerProvider.notifier).unlock(_pin);
    setState(() => _submitting = false);

    final state = ref.read(walletControllerProvider);
    if (!mounted) {
      return;
    }

    if (state.isUnlocked) {
      context.go(PortfolioPage.routePath);
      return;
    }

    setState(() => _pin = '');
    await showErrorAlertDialog(
      context,
      title: 'Unlock Failed',
      message: state.errorMessage ?? 'Incorrect PIN.',
    );
  }

  void _appendDigit(String digit) {
    if (_submitting || _pin.length >= 6) {
      return;
    }
    setState(() => _pin = '$_pin$digit');
    if (_pin.length == 6) {
      Future<void>.microtask(_unlock);
    }
  }

  void _removeDigit() {
    if (_submitting || _pin.isEmpty) {
      return;
    }
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletControllerProvider);

    if (walletState.biometricEnabled &&
        !walletState.loggedOut &&
        !_biometricPrompted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !ref.read(walletControllerProvider).isUnlocked) {
          _tryBiometricUnlock();
        }
      });
    }

    if (walletState.isUnlocked) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.go(PortfolioPage.routePath);
        }
      });
    }

    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || _submitting || !mounted) {
          return;
        }
        if (context.canPop()) {
          context.pop();
          return;
        }
        final hasWallet = ref.read(walletControllerProvider).hasWallet;
        if (!hasWallet) {
          context.go(WelcomePage.routePath);
        }
      },
      child: SecureScreen(
        child: AppScaffold(
          title: '',
          showTopBar: false,
          showBackgroundDecorations: false,
          child: SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    tooltip: 'Back',
                    onPressed: _submitting || _biometricAttempting
                        ? null
                        : () {
                            if (context.canPop()) {
                              context.pop();
                              return;
                            }
                            final hasWallet = ref
                                .read(walletControllerProvider)
                                .hasWallet;
                            if (!hasWallet) {
                              context.go(WelcomePage.routePath);
                            }
                          },
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                ),
                const Spacer(),
                if (_biometricAttempting)
                  const Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Use fingerprint',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      PinDots(filledCount: _pin.length),
                      if (_biometricError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Column(
                            children: [
                              Text(
                                _biometricError!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: _retryBiometric,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                const SizedBox(height: 30),
                PinKeypad(
                  onDigit: _submitting || _biometricAttempting
                      ? null
                      : _appendDigit,
                  onDelete: _submitting || _biometricAttempting || _pin.isEmpty
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
