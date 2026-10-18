import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/l10n.dart';
import '../../../settings/domain/app_settings.dart';
import '../../../settings/presentation/providers/app_settings_controller.dart';
import 'signer_ui.dart';

/// Same language setting as the wallet, so both modes always match.
String signerLanguageLabel(BuildContext context, AppLanguageOption option) =>
    option.nativeLabel ?? context.l10n.languageSystem;

Future<void> showSignerLanguagePicker(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) => Consumer(
      builder: (sheetContext, ref, _) {
        final l10n = sheetContext.l10n;
        final selected = ref
            .watch(appSettingsControllerProvider)
            .languageOption;
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.settingsLanguageSheetTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(sheetContext).textTheme.titleLarge,
                ),
                const SizedBox(height: 14),
                for (final option in AppLanguageOption.values) ...[
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    tileColor: option == selected
                        ? AppColors.backgroundAccent
                        : AppColors.surfaceMuted,
                    title: Text(signerLanguageLabel(sheetContext, option)),
                    subtitle: option == AppLanguageOption.system
                        ? Text(l10n.settingsLanguageSystemDescription)
                        : null,
                    trailing: option == selected
                        ? const Icon(Icons.check_rounded)
                        : null,
                    onTap: () async {
                      await ref
                          .read(appSettingsControllerProvider.notifier)
                          .setLanguageOption(option);
                      if (sheetContext.mounted) {
                        Navigator.of(sheetContext).pop();
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        );
      },
    ),
  );
}

/// Settings row that opens the language picker.
class SignerLanguageTile extends ConsumerWidget {
  const SignerLanguageTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final option = ref.watch(appSettingsControllerProvider).languageOption;
    return SignerTile(
      icon: Icons.translate_rounded,
      title: context.l10n.settingsLanguage,
      subtitle: signerLanguageLabel(context, option),
      tone: SignerTone.info,
      onTap: () => showSignerLanguagePicker(context, ref),
    );
  }
}

/// App bar button for screens shown before the signer is unlocked.
class SignerLanguageButton extends ConsumerWidget {
  const SignerLanguageButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      tooltip: context.l10n.settingsLanguage,
      icon: const Icon(Icons.translate_rounded),
      onPressed: () => showSignerLanguagePicker(context, ref),
    );
  }
}
