import 'package:flutter/material.dart';

import '../../../../core/airgap/airgap_protocol.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/pin_prompt_dialog.dart';
import '../../../../l10n/l10n.dart';
import '../../data/signer_vault.dart';
import '../signer_controller.dart';
import '../widgets/signer_language.dart';
import '../widgets/signer_ui.dart';
import '../widgets/word_quiz.dart';

class SignerSettingsPage extends StatelessWidget {
  const SignerSettingsPage({super.key, required this.controller});

  final SignerController controller;

  Future<String?> _askPin(BuildContext context, String title) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PinPromptDialog(title: title),
    );
  }

  void _toast(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _toggleBiometric(BuildContext context, bool enabled) async {
    final ok = await controller.setBiometric(
      enabled,
      reason: context.l10n.signerBiometricReason,
    );
    if (!ok && context.mounted) {
      _toast(context, context.l10n.signerBiometricFailed);
    }
  }

  Future<void> _erase(BuildContext context) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.signerEraseTitle),
        content: Text(l10n.signerEraseBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.signerEraseConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) {
      return;
    }
    final pin = await _askPin(context, l10n.signerEraseTitle);
    if (pin == null || !context.mounted) {
      return;
    }
    if (!await controller.verifyPin(pin)) {
      if (context.mounted) {
        _toast(context, l10n.signerEraseWrongPin);
      }
      return;
    }
    await controller.wipe();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final info = controller.info;
        return SignerScaffold(
          title: l10n.signerSettingsTitle,
          children: [
            const SignerLanguageTile(),
            if (info != null) ...[
              signerGap,
              SignerTile(
                icon: Icons.account_tree_outlined,
                title: l10n.signerAccountCount,
                subtitle: l10n.signerAccountCountHint,
                tone: SignerTone.brand,
                trailing: DropdownButton<int>(
                  value: info.accountCount,
                  underline: const SizedBox.shrink(),
                  borderRadius: BorderRadius.circular(18),
                  items: [
                    for (var i = 1; i <= SignerVault.maxAccounts; i++)
                      DropdownMenuItem(value: i, child: Text(i.toString())),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      controller.setAccountCount(value);
                    }
                  },
                ),
              ),
              if (controller.biometricAvailable) ...[
                signerGap,
                SignerTile(
                  icon: Icons.fingerprint_rounded,
                  title: l10n.signerBiometricToggle,
                  tone: SignerTone.success,
                  trailing: Switch(
                    value: info.biometricEnabled,
                    onChanged: (value) => _toggleBiometric(context, value),
                  ),
                ),
              ],
            ],
            signerGap,
            SignerTile(
              icon: Icons.system_update_rounded,
              title: l10n.signerUpgradeTitle,
              tone: SignerTone.warm,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => SignerUpgradePage(controller: controller),
                ),
              ),
            ),
            signerGap,
            SignerTile(
              icon: Icons.info_outline_rounded,
              title: l10n.signerVersionTitle,
              subtitle: l10n.signerVersionDetail(
                controller.appVersion,
                airGapProtocolVersion,
                controller.tokens.version,
              ),
              tone: SignerTone.info,
            ),
            const SizedBox(height: 28),
            SignerTile(
              icon: Icons.delete_forever_rounded,
              title: l10n.signerEraseTitle,
              subtitle: l10n.signerEraseSubtitle,
              tone: SignerTone.danger,
              onTap: () => _erase(context),
            ),
          ],
        );
      },
    );
  }
}

/// How to update the signer: online with the seed kept encrypted, or the
/// most secure way of erasing and restoring from the paper backup.
class SignerUpgradePage extends StatefulWidget {
  const SignerUpgradePage({super.key, required this.controller});

  final SignerController controller;

  @override
  State<SignerUpgradePage> createState() => _SignerUpgradePageState();
}

class _SignerUpgradePageState extends State<SignerUpgradePage> {
  bool _backupChecked = false;

  /// The quiz hints at the recovery words, so it needs the PIN each time
  /// (a wrong PIN uses up an unlock attempt) and ends after a few misses.
  Future<void> _verifyBackup() async {
    final l10n = context.l10n;
    final pin = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PinPromptDialog(title: l10n.signerUpgradeVerifyBackup),
    );
    if (pin == null || !mounted) {
      return;
    }
    try {
      await widget.controller.checkPin(pin);
    } on SignerWrongPin catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.signerWrongPin(error.attemptsLeft))),
        );
      }
      return;
    } on SignerWiped {
      // The controller moved to setup and closes this screen.
      return;
    }
    final words = widget.controller.session?.mnemonic.split(' ');
    if (words == null || !mounted) {
      return;
    }
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => _VerifyBackupPage(words: words)),
    );
    if (!mounted) {
      return;
    }
    if (ok == true) {
      setState(() => _backupChecked = true);
    } else if (ok == false) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.signerQuizTooManyWrong)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    Widget section(String title, String text) => Padding(
      padding: const EdgeInsets.only(top: 14),
      child: SignerSection(
        label: title,
        child: Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
        ),
      ),
    );
    return SignerScaffold(
      title: l10n.signerUpgradeTitle,
      children: [
        SignerHero(
          title: l10n.signerUpgradeTitle,
          subtitle: l10n.signerUpgradeIntro,
          icon: Icons.system_update_rounded,
          tone: SignerTone.warm,
        ),
        signerGap,
        if (_backupChecked)
          SignerNotice(
            text: l10n.signerUpgradeBackupOk,
            icon: Icons.check_circle_rounded,
            tone: SignerTone.success,
          )
        else
          SignerTile(
            icon: Icons.fact_check_outlined,
            title: l10n.signerUpgradeStep0,
            subtitle: l10n.signerUpgradeVerifyBackup,
            tone: SignerTone.brand,
            onTap: _verifyBackup,
          ),
        section(l10n.signerUpgradeOnlineTitle, l10n.signerUpgradeOnlineBody),
        section(l10n.signerUpgradeSecureTitle, l10n.signerUpgradeSecureBody),
        section(
          l10n.signerUpgradeOfflineApkTitle,
          l10n.signerUpgradeOfflineApkBody,
        ),
        section(l10n.signerUpgradeCompatTitle, l10n.signerUpgradeCompatBody),
      ],
    );
  }
}

/// Same pick-the-word check as setup, but it ends after
/// [verifyBackupMaxWrong] wrong picks; trying again needs the PIN again.
class _VerifyBackupPage extends StatelessWidget {
  const _VerifyBackupPage({required this.words});

  final List<String> words;

  @override
  Widget build(BuildContext context) {
    return SignerScaffold(
      title: context.l10n.signerUpgradeVerifyBackup,
      children: [
        WordQuiz(
          words: words,
          maxWrongAnswers: verifyBackupMaxWrong,
          onPassed: () => Navigator.of(context).pop(true),
          onFailed: () => Navigator.of(context).pop(false),
        ),
      ],
    );
  }
}

/// Wrong picks allowed in the settings backup check per PIN entry.
const verifyBackupMaxWrong = 3;
