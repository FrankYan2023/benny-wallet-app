import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solana/base58.dart';

import '../../../../core/airgap/airgap_protocol.dart';
import '../../../../core/airgap/ur.dart';
import '../../../../core/airgap/widgets/scan_hint_animation.dart';
import '../../../../core/airgap/widgets/ur_scanner_view.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../l10n/l10n.dart';
import '../../../auth/presentation/pages/pin_setup_page.dart';
import '../../../auth/presentation/providers/wallet_controller.dart';
import '../../../signer/presentation/widgets/signer_ui.dart';
import '../../../wallets/presentation/pages/wallet_name_page.dart';
import '../../domain/air_gap_wallet_meta.dart';

/// Connects an account of an offline signer: scans its pairing code (public
/// keys only), lets the user pick an account, then continues with the
/// usual name (and first-time PIN) steps.
class ConnectSignerPage extends ConsumerStatefulWidget {
  const ConnectSignerPage({super.key});

  static const routeName = 'connectSigner';
  static const routePath = '/connect-signer';

  @override
  ConsumerState<ConnectSignerPage> createState() => _ConnectSignerPageState();
}

class _ConnectSignerPageState extends ConsumerState<ConnectSignerPage> {
  AirGapAccountsExport? _export;
  int? _selected;
  String? _error;

  void _onResult(Ur ur) {
    try {
      final export = AirGapAccountsExport.fromUr(ur);
      setState(() {
        _export = export;
        _error = null;
        _selected = null;
      });
    } on Object {
      setState(() => _error = context.l10n.airGapConnectInvalid);
    }
  }

  void _continue() {
    final export = _export;
    final index = _selected;
    if (export == null || index == null) {
      return;
    }
    final account = export.accounts[index];
    final meta = AirGapWalletMeta(
      masterFingerprint: export.masterFingerprint,
      deviceName: export.deviceName,
      signerInfo: export.signerInfo,
    );
    context.push(
      WalletNamePage.routePath,
      extra: PinSetupFlowData(
        publicKey: base58encode(account.publicKey),
        airGapDerivationPath: account.path.toString(),
        airGapMeta: meta.encode(),
        walletLabel: export.deviceName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final export = _export;
    final existing = ref.watch(walletControllerProvider).walletPublicKeys;
    return AppScaffold(
      title: l10n.airGapConnectTitle,
      child: ListView(
        children: [
          if (export == null) ...[
            WalletCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ScanHintAnimation(
                    qrOnLeft: true,
                    leftLabel: l10n.airGapSignerLabel,
                    rightLabel: l10n.airGapThisPhone,
                    height: 130,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    l10n.airGapConnectBody,
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: UrScannerView(
                acceptedTypes: const {AirGapUrType.accounts},
                onResult: _onResult,
                onWrongCode: () =>
                    setState(() => _error = l10n.airGapConnectInvalid),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              SignerNotice(
                text: _error!,
                icon: Icons.error_outline_rounded,
                tone: SignerTone.danger,
              ),
            ],
          ] else ...[
            SignerHero(
              title: export.deviceName,
              subtitle: l10n.airGapConnectFound,
              icon: Icons.verified_user_rounded,
              tone: SignerTone.brand,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.airGapConnectChoose(export.deviceName),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < export.accounts.length; i++)
              Builder(
                builder: (context) {
                  final account = export.accounts[i];
                  final address = base58encode(account.publicKey);
                  final added = existing.contains(address);
                  final number = account.path.indexes[2] + 1;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Opacity(
                      opacity: added ? 0.5 : 1,
                      child: SignerTile(
                        icon: _selected == i
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        tone: _selected == i
                            ? SignerTone.brand
                            : SignerTone.info,
                        title: added
                            ? l10n.airGapConnectAccountAdded(number)
                            : l10n.airGapConnectAccount(number),
                        subtitle: address,
                        trailing: const SizedBox.shrink(),
                        onTap: added
                            ? null
                            : () => setState(() => _selected = i),
                      ),
                    ),
                  );
                },
              ),
            SignerNotice(
              text: l10n.airGapConnectCompare,
              icon: Icons.compare_arrows_rounded,
              tone: SignerTone.warm,
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: l10n.commonContinue,
              onPressed: _selected == null ? null : _continue,
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: () => setState(() => _export = null),
              child: Text(l10n.airGapConnectScanAgain),
            ),
          ],
        ],
      ),
    );
  }
}
