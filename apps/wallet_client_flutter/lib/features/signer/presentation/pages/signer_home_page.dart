import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:solana/base58.dart';

import '../../../../core/airgap/widgets/animated_ur_qr.dart';
import '../../../../core/airgap/widgets/scan_hint_animation.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../../../l10n/l10n.dart';
import '../signer_controller.dart';
import '../widgets/signer_ui.dart';
import 'signer_settings_page.dart';
import 'signer_sign_pages.dart';

String shortAddress(String address) => address.length <= 12
    ? address
    : '${address.substring(0, 6)}…${address.substring(address.length - 6)}';

class SignerHomePage extends StatelessWidget {
  const SignerHomePage({super.key, required this.controller});

  final SignerController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final engine = controller.engine;
        final info = controller.info;
        if (engine == null || info == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        void open(Widget page) => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => page));
        return SignerScaffold(
          actions: [
            IconButton(
              tooltip: l10n.signerLockNow,
              icon: const Icon(Icons.lock_outline_rounded),
              onPressed: () => controller.lock(byUser: true),
            ),
            IconButton(
              tooltip: l10n.signerSettingsTitle,
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => open(SignerSettingsPage(controller: controller)),
            ),
          ],
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
              decoration: BoxDecoration(
                color: SignerTone.brand.colors(theme).background,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Row(
                children: [
                  const BrandLogo(size: 58),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          info.deviceName,
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: SignerTone.success.colors(theme).background,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.airplanemode_active_rounded,
                                size: 14,
                                color: SignerTone.success
                                    .colors(theme)
                                    .foreground,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                l10n.signerOfflineChip,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: SignerTone.success
                                      .colors(theme)
                                      .foreground,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            signerGap,
            Row(
              children: [
                Expanded(
                  child: _BigAction(
                    tone: SignerTone.info,
                    icon: Icons.qr_code_scanner_rounded,
                    title: l10n.signerScanToSign,
                    subtitle: l10n.signerScanToSignSubtitle,
                    onTap: () => open(SignerScanPage(controller: controller)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _BigAction(
                    tone: SignerTone.warm,
                    icon: Icons.link_rounded,
                    title: l10n.signerPairWallet,
                    subtitle: l10n.signerPairWalletSubtitle,
                    onTap: () => open(SignerPairPage(controller: controller)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 10),
              child: Text(
                l10n.signerAccountsTitle,
                style: theme.textTheme.titleLarge,
              ),
            ),
            for (final account in engine.accounts) ...[
              SignerTile(
                icon: Icons.account_balance_wallet_rounded,
                tone: SignerTone.brand,
                title: l10n.signerAccountName(account.path.indexes[2] + 1),
                subtitle: shortAddress(base58encode(account.publicKey)),
              ),
              const SizedBox(height: 10),
            ],
          ],
        );
      },
    );
  }
}

class _BigAction extends StatelessWidget {
  const _BigAction({
    required this.tone,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final SignerTone tone;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = tone.colors(theme);
    return Material(
      color: colors.background,
      borderRadius: BorderRadius.circular(32),
      child: InkWell(
        borderRadius: BorderRadius.circular(32),
        onTap: onTap,
        child: Container(
          height: 168,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.46),
                  borderRadius: BorderRadius.circular(23),
                ),
                child: Icon(icon, color: colors.foreground, size: 22),
              ),
              const Spacer(),
              Text(
                title,
                style: theme.textTheme.displaySmall?.copyWith(
                  color: colors.foreground,
                  fontSize: 19,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.foreground.withValues(alpha: 0.72),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows the public accounts as a QR the wallet app scans to connect. The
/// code carries this signer's name, so the wallet can show it.
class SignerPairPage extends StatelessWidget {
  const SignerPairPage({super.key, required this.controller});

  final SignerController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final engine = controller.engine;
    final info = controller.info;
    return SignerScaffold(
      title: l10n.signerPairWallet,
      children: [
        ScanHintAnimation(
          qrOnLeft: true,
          leftLabel: info?.deviceName ?? '',
          rightLabel: l10n.signerWalletPhoneLabel,
        ),
        signerGap,
        Text(l10n.signerPairBody, style: Theme.of(context).textTheme.bodyLarge),
        signerGap,
        if (engine != null && info != null)
          WalletCard(
            child: Center(
              child: AnimatedUrQr(
                ur: engine
                    .exportAccounts(
                      deviceName: info.deviceName,
                      info: controller.signerInfo,
                    )
                    .toUr(),
              ),
            ),
          ),
        signerGap,
        SignerNotice(
          text: l10n.signerPairPublicOnly,
          icon: Icons.shield_outlined,
          tone: SignerTone.success,
        ),
      ],
    );
  }
}
