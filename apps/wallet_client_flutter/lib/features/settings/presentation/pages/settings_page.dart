import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/providers.dart';
import '../../../../core/utils/clipboard_utils.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../app/responsive/layout_shell.dart';
import '../../../../core/config/app_features.dart';
import '../../../../core/security/secure_screen.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_update_gate.dart';
import '../../../../core/widgets/error_alert_dialog.dart';
import '../../../../core/widgets/pin_prompt_dialog.dart';
import '../../domain/app_settings.dart';
import '../providers/app_settings_controller.dart';
import '../../../auth/presentation/providers/wallet_controller.dart';
import '../../../onboarding/presentation/pages/welcome_page.dart';
import '../../../portfolio/presentation/pages/child_wallets_page.dart';
import '../../../portfolio/presentation/pages/portfolio_page.dart';
import '../../../portfolio/presentation/providers/portfolio_provider.dart';
import 'child_mode_pin_page.dart';
import 'contact_feedback_page.dart';
import 'rent_reclaim_page.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  static const routeName = 'settings';
  static const routePath = '/settings';
  static const navLabel = 'Settings';

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _checkingForUpdates = false;

  Future<String?> _requestPin(BuildContext context) {
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const PinPromptDialog(),
    );
  }

  Future<String?> _requestChildModePin({required bool enabling}) {
    return Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (context) => enabling
            ? const ChildModePinPage.create()
            : const ChildModePinPage.verify(),
      ),
    );
  }

  Future<void> _showAutoLockPicker(
    BuildContext context,
    AutoLockOption selectedOption,
  ) async {
    final notifier = ref.read(appSettingsControllerProvider.notifier);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        final maxHeight = MediaQuery.sizeOf(context).height * 0.76;

        return Container(
          constraints: BoxConstraints(maxHeight: maxHeight),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SafeArea(
            top: false,
            child: ListView(
              shrinkWrap: true,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.16,
                      ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Auto lock',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displaySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose when Benny locks again.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                for (final option in AutoLockOption.values) ...[
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    tileColor: option == selectedOption
                        ? const Color(0xFFF8E8B8)
                        : theme.colorScheme.surfaceContainerHigh.withValues(
                            alpha: 0.28,
                          ),
                    title: Text(option.label),
                    trailing: option == selectedOption
                        ? const Icon(Icons.check_rounded)
                        : null,
                    onTap: () async {
                      await notifier.setAutoLockOption(option);
                      if (!context.mounted) {
                        return;
                      }
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleRecoveryPhrase() async {
    final pin = await _requestPin(context);
    if (pin == null || !mounted) {
      return;
    }

    try {
      final mnemonic = await ref
          .read(walletControllerProvider.notifier)
          .revealMnemonic(pin);
      if (!mounted) {
        return;
      }
      await showDialog<void>(
        context: context,
        builder: (context) => _MnemonicDialog(mnemonic: mnemonic),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Incorrect PIN')));
    }
  }

  Future<void> _handleBiometricToggle(bool enabled) async {
    if (enabled) {
      final protector = ref.read(biometricSessionProtectorProvider);
      if (!protector.supportsPersistentSessionProtection) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Persistent biometric unlock is not supported on this device.',
            ),
          ),
        );
        return;
      }

      final service = ref.read(biometricAuthServiceProvider);
      final supported = await service.isSupported();
      if (!supported) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Biometrics are not available on this device.'),
          ),
        );
        return;
      }

      // Use authenticateForSetup() for enabling (more strict security)
      final approved = await service.authenticateForSetup();
      if (!approved) {
        debugPrint('[SECURITY] User cancelled biometric setup');
        return;
      }
    }

    try {
      debugPrint('[SECURITY] Toggling biometric: $enabled');
      await ref
          .read(walletControllerProvider.notifier)
          .setBiometricEnabled(enabled);
      if (mounted) {
        final message = enabled ? 'Biometric enabled' : 'Biometric disabled';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      debugPrint('[SECURITY] ERROR Biometric toggle failed: $e');
      if (!mounted) {
        return;
      }
      final message = e is StateError
          ? e.message.toString()
          : 'Unlock the wallet before enabling biometrics.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _handleNotificationsToggle(bool enabled) async {
    final notifier = ref.read(appSettingsControllerProvider.notifier);
    final previous = ref
        .read(appSettingsControllerProvider)
        .notificationsEnabled;
    final walletState = ref.read(walletControllerProvider);

    await notifier.setNotificationsEnabled(enabled);

    try {
      final registered = await ref
          .read(pushNotificationServiceProvider)
          .requestPermissionAndRegister(
            walletState: walletState,
            enabled: enabled,
          );
      if (enabled && !registered) {
        await notifier.setNotificationsEnabled(previous);
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Notifications are disabled. Enable them in system settings.',
            ),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () {
                ref.read(appBadgeServiceProvider).openNotificationSettings();
              },
            ),
          ),
        );
        return;
      }
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            enabled
                ? 'Receive notifications enabled'
                : 'Receive notifications disabled',
          ),
        ),
      );
    } catch (error) {
      await notifier.setNotificationsEnabled(previous);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update notifications: $error')),
      );
    }
  }

  Future<void> _handleChildModeToggle(bool enabled) async {
    final walletState = ref.read(walletControllerProvider);

    try {
      debugPrint('[SECURITY] Setting child mode from settings: $enabled');
      if (enabled) {
        if (walletState.childWallets.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Remove all child accounts before enabling child mode.',
              ),
            ),
          );
          return;
        }

        final childModePin = await _requestChildModePin(enabling: true);
        if (childModePin == null) {
          return;
        }
        await ref
            .read(walletControllerProvider.notifier)
            .enableChildMode(childModePin);
      } else {
        String childModePin = '';
        if (walletState.hasChildModePin) {
          final requestedPin = await _requestChildModePin(enabling: false);
          if (requestedPin == null) {
            return;
          }
          childModePin = requestedPin;
        }
        await ref
            .read(walletControllerProvider.notifier)
            .disableChildMode(childModePin);
      }
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(enabled ? 'Child mode enabled' : 'Child mode disabled'),
        ),
      );
    } catch (e) {
      debugPrint('[SECURITY] ERROR Child mode toggle failed: $e');
      if (!mounted) {
        return;
      }
      if (_isIncorrectChildModePinError(e)) {
        await showErrorAlertDialog(
          context,
          title: 'Unlock Failed',
          message: 'Incorrect PIN.',
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update child mode: $e')),
      );
    }
  }

  bool _isIncorrectChildModePinError(Object error) {
    return error is ArgumentError &&
        '${error.message}'.contains('Incorrect child mode PIN');
  }

  void _openChildAccounts() {
    context.push(ChildWalletsPage.routePath);
  }

  Future<bool> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Copy your recovery phrase first.'),
        content: const Text(
          'Logging out will clear all local app data on this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    return confirmed == true;
  }

  Future<void> _handleManualUpdateCheck() async {
    if (_checkingForUpdates) {
      return;
    }

    setState(() {
      _checkingForUpdates = true;
    });

    try {
      final result = await ref
          .read(appUpdateRepositoryProvider)
          .checkForUpdate();
      if (!mounted) {
        return;
      }

      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Benny Wallet is up to date.')),
        );
        return;
      }

      await showAppUpdateDialog(context, result);
    } catch (_) {
      if (!mounted) {
        return;
      }

      await showErrorAlertDialog(
        context,
        title: 'Update Check Failed',
        message: 'Unable to check for updates right now.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _checkingForUpdates = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletControllerProvider);
    final settings = ref.watch(appSettingsControllerProvider);
    final packageInfo = ref.watch(packageInfoProvider);
    final isChildMode = walletState.childModeEnabled;
    final isExternalWallet = walletState.isExternalWallet;
    final hasChildAccounts = walletState.childWallets.isNotEmpty;
    final canToggleChildMode =
        walletState.isUnlocked &&
        (walletState.childModeEnabled || !hasChildAccounts);

    if (!walletState.hasWallet) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.go(WelcomePage.routePath);
        }
      });
    }

    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || !context.mounted) {
          return;
        }
        context.go(PortfolioPage.routePath);
      },
      child: LayoutShell(
        selectedIndex: 1,
        onDestinationSelected: (index) {
          if (index == 0) {
            context.go(PortfolioPage.routePath);
          }
        },
        child: AppScaffold(
          title: 'Benny',
          child: ListView(
            children: [
              if (isChildMode)
                WalletCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Child mode is active',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'The wallet stays in receive-only mode until the 4-digit child mode PIN is entered.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              if (!isChildMode && !isExternalWallet) ...[
                _RecoveryPhraseCard(onTap: _handleRecoveryPhrase),
                const SizedBox(height: 18),
              ] else if (!isChildMode && isExternalWallet) ...[
                _SeekerVaultCard(
                  label: walletState.walletLabel,
                  address: walletState.publicKey,
                ),
                const SizedBox(height: 18),
              ],
              _SettingsToggleTile(
                icon: Icons.fingerprint_rounded,
                iconColor: const Color(0xFF4096C9),
                title: 'Biometric unlock',
                subtitle: walletState.isUnlocked
                    ? 'Use fingerprint'
                    : 'Unlock wallet to enable',
                value: walletState.biometricEnabled,
                onChanged: _handleBiometricToggle,
                enabled: walletState.isUnlocked,
              ),
              const SizedBox(height: 10),
              _SettingsActionTile(
                icon: Icons.lock_clock_rounded,
                iconColor: const Color(0xFF8A5B09),
                title: 'Auto lock',
                subtitle: settings.autoLockOption.label,
                trailingText: settings.autoLockOption.label,
                onTap: () =>
                    _showAutoLockPicker(context, settings.autoLockOption),
              ),
              const SizedBox(height: 10),
              _SettingsToggleTile(
                icon: Icons.notifications_active_rounded,
                iconColor: const Color(0xFF4E7A52),
                title: 'Receive notifications',
                subtitle: 'Get an alert when funds arrive',
                value: settings.notificationsEnabled,
                onChanged: _handleNotificationsToggle,
                enabled: walletState.isUnlocked,
              ),
              const SizedBox(height: 10),
              _SettingsToggleTile(
                icon: Icons.child_care_rounded,
                iconColor: const Color(0xFF6C63FF),
                title: 'Child mode',
                subtitle: walletState.childModeEnabled
                    ? 'Protected by a 4-digit child mode PIN'
                    : hasChildAccounts
                    ? 'Remove all child accounts before enabling'
                    : 'Set a separate 4-digit PIN for child mode',
                value: walletState.childModeEnabled,
                onChanged: _handleChildModeToggle,
                enabled: canToggleChildMode,
              ),
              if (!isChildMode) const SizedBox(height: 10),
              if (!isChildMode)
                WalletCard(
                  child: _SettingsActionTile(
                    icon: Icons.groups_2_rounded,
                    iconColor: const Color(0xFF6C63FF),
                    title: 'Child accounts',
                    trailingText: walletState.childWallets.isEmpty
                        ? null
                        : '${walletState.childWallets.length}',
                    onTap: _openChildAccounts,
                  ),
                ),
              const SizedBox(height: 14),
              if (!isChildMode)
                WalletCard(
                  child: _SettingsActionTile(
                    icon: Icons.savings_rounded,
                    iconColor: const Color(0xFF8A5B09),
                    title: 'Rent reclaim',
                    subtitle: 'Close empty token accounts and recover SOL',
                    onTap: () => context.push(RentReclaimPage.routePath),
                  ),
                ),
              if (!isChildMode) const SizedBox(height: 14),
              WalletCard(
                child: _SettingsActionTile(
                  icon: Icons.chat_bubble_outline_rounded,
                  iconColor: const Color(0xFF4E7A52),
                  title: 'Feedback',
                  subtitle: 'Report a problem or ask a question',
                  onTap: () => context.push(ContactFeedbackPage.routePath),
                ),
              ),
              if (!isChildMode) ...[
                const SizedBox(height: 14),
                WalletCard(
                  child: _SettingsActionTile(
                    icon: Icons.logout_rounded,
                    iconColor: Colors.white,
                    iconBackground: const Color(0xFFCC6A4A),
                    title: 'Log out',
                    subtitle: 'Return to the home screen',
                    onTap: () async {
                      final confirmed = await _confirmLogout(context);
                      if (!confirmed || !context.mounted) {
                        return;
                      }
                      final activePublicKey = ref
                          .read(walletControllerProvider)
                          .publicKey;
                      if (activePublicKey != null) {
                        ref.invalidate(portfolioProvider(activePublicKey));
                      }
                      await ref
                          .read(walletControllerProvider.notifier)
                          .logOut();
                      if (!context.mounted) {
                        return;
                      }
                      context.go(WelcomePage.routePath);
                    },
                  ),
                ),
              ],
              const SizedBox(height: 18),
              packageInfo.when(
                data: (value) => _SettingsVersionFooter(
                  versionLabel: _formatVersionLabel(
                    value.version,
                    value.buildNumber,
                  ),
                  isChecking: _checkingForUpdates,
                  onCheckUpdatesTap: AppFeatures.canCheckForUpdates
                      ? _handleManualUpdateCheck
                      : null,
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatVersionLabel(String version, String buildNumber) {
  final normalizedVersion = version.trim();
  final normalizedBuild = buildNumber.trim();
  if (normalizedBuild.isEmpty || normalizedBuild == normalizedVersion) {
    return 'Version $normalizedVersion';
  }

  return 'Version $normalizedVersion+$normalizedBuild';
}

class _RecoveryPhraseCard extends StatelessWidget {
  const _RecoveryPhraseCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1CC),
        borderRadius: BorderRadius.circular(42),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: const BoxDecoration(
              color: Color(0xFFF4CF66),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.key_rounded,
              size: 42,
              color: Color(0xFF5A4411),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Seed Phrase Backup',
            textAlign: TextAlign.center,
            style: theme.textTheme.displaySmall?.copyWith(
              color: const Color(0xFF2D2A23),
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'We recommend a physical copy stored in a secure spot.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF726759),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 170,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFA46708),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(58),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                elevation: 0,
              ),
              onPressed: onTap,
              child: const Text('Secure Now'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsToggleTile extends StatelessWidget {
  const _SettingsToggleTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: enabled
            ? const Color(0xFFF7F1E7)
            : const Color(0xFFF7F1E7).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          _SettingsIconCircle(icon: icon, iconColor: iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: enabled
                        ? const Color(0xFF2D2A23)
                        : const Color(0xFF8A7D6A),
                    fontWeight: FontWeight.w800,
                    fontSize: 19,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF8A7D6A),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeThumbColor: Colors.white,
            activeTrackColor: const Color(0xFFA46708),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFE2DBD2),
            onChanged: enabled ? onChanged : null,
          ),
        ],
      ),
    );
  }
}

class _SeekerVaultCard extends StatelessWidget {
  const _SeekerVaultCard({required this.label, required this.address});

  final String? label;
  final String? address;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayLabel = label?.trim().isNotEmpty == true
        ? label!.trim()
        : 'Seeker Wallet';
    final displayAddress = address == null || address!.isEmpty
        ? null
        : Formatters.compactAddress(address!, visibleChars: 6);

    return WalletCard(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F1E7),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          children: [
            const _SettingsIconCircle(
              icon: Icons.security_rounded,
              iconColor: Color(0xFF235E7A),
              backgroundColor: Colors.white,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: const Color(0xFF2D2A23),
                      fontWeight: FontWeight.w900,
                      fontSize: 19,
                    ),
                  ),
                  if (displayAddress != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      displayAddress,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF6F6353),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsActionTile extends StatelessWidget {
  const _SettingsActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.trailingText,
    this.iconBackground,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final String? trailingText;
  final Color? iconBackground;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F1E7),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          children: [
            _SettingsIconCircle(
              icon: icon,
              iconColor: iconColor,
              backgroundColor: iconBackground,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: const Color(0xFF2D2A23),
                      fontWeight: FontWeight.w800,
                      fontSize: 19,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF8A7D6A),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailingText != null) ...[
              Text(
                trailingText!,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF8A5B09),
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 8),
            ],
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

class _SettingsVersionFooter extends StatelessWidget {
  const _SettingsVersionFooter({
    required this.versionLabel,
    required this.isChecking,
    this.onCheckUpdatesTap,
  });

  final String versionLabel;
  final bool isChecking;
  final VoidCallback? onCheckUpdatesTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodySmall?.copyWith(
      color: const Color(0xFF8F8578),
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(versionLabel, textAlign: TextAlign.center, style: textStyle),
          if (onCheckUpdatesTap != null) ...[
            const SizedBox(width: 10),
            GestureDetector(
              onTap: isChecking ? null : onCheckUpdatesTap,
              child: Text(
                isChecking ? 'Checking...' : 'Check for updates',
                style: textStyle?.copyWith(
                  color: isChecking
                      ? const Color(0xFF8F8578)
                      : theme.colorScheme.primary,
                  decoration: TextDecoration.underline,
                  decorationColor: isChecking
                      ? const Color(0xFF8F8578)
                      : theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SettingsIconCircle extends StatelessWidget {
  const _SettingsIconCircle({
    required this.icon,
    required this.iconColor,
    this.backgroundColor,
  });

  final IconData icon;
  final Color iconColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(icon, color: iconColor),
    );
  }
}

class _MnemonicDialog extends StatelessWidget {
  const _MnemonicDialog({required this.mnemonic});

  final String mnemonic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final words = mnemonic.split(' ');

    return SecureScreen(
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHigh.withValues(
                    alpha: 0.42,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: words.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2.4,
                  ),
                  itemBuilder: (context, index) => Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      words[index],
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FractionallySizedBox(
                widthFactor: 0.75,
                child: PrimaryButton(
                  label: 'Copy phrase',
                  onPressed: () async {
                    await ClipboardUtils.setDataWithAutoWipe(
                      mnemonic,
                      clearDelay: ClipboardUtils.sensitiveClearDelay,
                      isSensitive: true,
                    );
                    if (!context.mounted) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Recovery phrase copied (will clear in 15s)',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
