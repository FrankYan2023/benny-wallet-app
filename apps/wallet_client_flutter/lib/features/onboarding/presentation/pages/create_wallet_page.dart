import 'package:bip39/bip39.dart' as bip39;
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/security/secure_screen.dart';
import '../../../../core/platform/platform_capabilities.dart';
import '../../../../core/utils/clipboard_utils.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../l10n/l10n.dart';
import '../../../auth/presentation/pages/pin_setup_page.dart';
import '../../../auth/domain/wallet_derivation.dart';

class CreateWalletPage extends StatefulWidget {
  const CreateWalletPage({super.key});

  static const routeName = 'createWallet';
  static const routePath = '/create-wallet';

  @override
  State<CreateWalletPage> createState() => _CreateWalletPageState();
}

class _CreateWalletPageState extends State<CreateWalletPage> {
  late String _mnemonic;

  List<String> get _words => _mnemonic.split(' ');

  @override
  void initState() {
    super.initState();
    _mnemonic = bip39.generateMnemonic();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return SecureScreen(
      child: AppScaffold(
        title: l10n.createWalletTitle,
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                color: theme.colorScheme.tertiaryContainer,
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
                      Icons.auto_awesome_rounded,
                      size: 32,
                      color: theme.colorScheme.onTertiaryContainer,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    l10n.createWalletRecoveryTitle,
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: theme.colorScheme.onTertiaryContainer,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.createWalletRecoverySubtitle,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onTertiaryContainer.withValues(
                        alpha: 0.78,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            if (PlatformCapabilities.shouldWarnWebStorageRisk) ...[
              const SizedBox(height: 12),
              Text(
                l10n.webTestingOnly,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 20),
            WalletCard(
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _words.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 2.6,
                ),
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHigh.withValues(
                        alpha: 0.55,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(
                      child: SelectableText(
                        _words[index],
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          height: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: OutlinedButton.icon(
                onPressed: () async {
                  await ClipboardUtils.setDataWithAutoWipe(
                    _mnemonic,
                    clearDelay: ClipboardUtils.sensitiveClearDelay,
                    isSensitive: true,
                  );
                  if (!context.mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.recoveryPhraseCopied)),
                  );
                },
                icon: const Icon(Icons.copy_outlined),
                label: Text(l10n.copyPhrase),
              ),
            ),
            const SizedBox(height: 24),
            FractionallySizedBox(
              widthFactor: 0.75,
              child: PrimaryButton(
                label: l10n.commonContinue,
                onPressed: () => context.push(
                  PinSetupPage.routePath,
                  extra: PinSetupFlowData(
                    mnemonic: _mnemonic,
                    derivation: WalletDerivation.standard,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
