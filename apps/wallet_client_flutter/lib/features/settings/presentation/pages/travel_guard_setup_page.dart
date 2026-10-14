import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/security/secure_screen.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/pin_keypad.dart';
import '../../../../l10n/l10n.dart';
import '../../../auth/data/wallet_repository.dart';
import '../../../auth/presentation/providers/wallet_controller.dart';
import '../../../wallets/presentation/widgets/wallet_visuals.dart';

enum _GuardStep { wallet, pin, confirm }

/// Choose a wallet → special PIN → confirm. Opened from Settings after the
/// app PIN was verified (the master key is in memory).
class TravelGuardSetupPage extends ConsumerStatefulWidget {
  const TravelGuardSetupPage({super.key});

  static const routeName = 'travelGuardSetup';
  static const routePath = '/travel-guard';

  @override
  ConsumerState<TravelGuardSetupPage> createState() =>
      _TravelGuardSetupPageState();
}

class _TravelGuardSetupPageState extends ConsumerState<TravelGuardSetupPage> {
  _GuardStep _step = _GuardStep.wallet;
  String? _walletKey;
  String _pin = '';
  String _input = '';
  String? _error;
  bool _submitting = false;

  void _pickWallet(String publicKey) {
    setState(() {
      _walletKey = publicKey;
      _step = _GuardStep.pin;
      _input = '';
      _error = null;
    });
  }

  void _appendDigit(String digit) {
    if (_submitting || _input.length >= 6) {
      return;
    }
    setState(() {
      _input = '$_input$digit';
      _error = null;
    });
    if (_input.length == 6) {
      Future<void>.microtask(_submitPin);
    }
  }

  void _removeDigit() {
    if (_submitting || _input.isEmpty) {
      return;
    }
    setState(() => _input = _input.substring(0, _input.length - 1));
  }

  Future<void> _submitPin() async {
    final l10n = context.l10n;
    if (_step == _GuardStep.pin) {
      setState(() {
        _pin = _input;
        _input = '';
        _step = _GuardStep.confirm;
      });
      return;
    }
    if (_input != _pin) {
      _fail(l10n.pinMismatch, restart: true);
      return;
    }
    setState(() => _submitting = true);
    try {
      await ref
          .read(walletControllerProvider.notifier)
          .enableTravelGuard(publicKey: _walletKey!, guardPin: _pin);
      HapticFeedback.mediumImpact();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.travelGuardEnabled)));
      context.pop();
    } on TravelGuardPinConflictException {
      _fail(l10n.travelGuardPinSameAsApp, restart: true);
    } catch (_) {
      _fail(l10n.walletActionFailed, restart: true);
    }
  }

  void _fail(String message, {bool restart = false}) {
    if (!mounted) {
      return;
    }
    HapticFeedback.heavyImpact();
    setState(() {
      _input = '';
      _error = message;
      _submitting = false;
      if (restart) {
        _pin = '';
        _step = _GuardStep.pin;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SecureScreen(
      child: AppScaffold(
        title: l10n.travelGuardTitle,
        child: _step == _GuardStep.wallet
            ? _buildWalletStep(context)
            : _buildPinStep(context),
      ),
    );
  }

  Widget _buildWalletStep(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final wallets = ref.watch(walletControllerProvider).wallets;
    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(6, 0, 6, 16),
          child: Text(
            l10n.travelGuardChooseWallet,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        for (final wallet in wallets) ...[
          WalletActionRow(
            leading: WalletAvatar(wallet: wallet),
            title: walletDisplayName(wallet),
            titleTag: WalletTypeTag(wallet: wallet),
            subtitle: Text(
              walletShortAddress(wallet.publicKey),
              style: theme.textTheme.bodySmall?.copyWith(
                color: WalletPalette.muted,
              ),
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _pickWallet(wallet.publicKey),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _buildPinStep(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final title = _step == _GuardStep.pin
        ? l10n.travelGuardNewPin
        : l10n.travelGuardConfirmPin;
    return Column(
      children: [
        const Spacer(),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            title,
            key: ValueKey(_step),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.travelGuardPinHint,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 18),
        PinDots(filledCount: _input.length),
        SizedBox(
          height: 34,
          child: _error == null
              ? null
              : Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
        ),
        const SizedBox(height: 12),
        PinKeypad(
          onDigit: _submitting ? null : _appendDigit,
          onDelete: _submitting || _input.isEmpty ? null : _removeDigit,
        ),
        const Spacer(),
      ],
    );
  }
}
