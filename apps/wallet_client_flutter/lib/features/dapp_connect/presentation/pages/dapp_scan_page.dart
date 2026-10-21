import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../l10n/l10n.dart';
import '../../data/dapp_connect_service.dart';

/// Scans or pastes a WalletConnect link, with the connected websites listed
/// below. The connection request that follows opens on its own page once the
/// dApp answers.
class DappScanPage extends ConsumerStatefulWidget {
  const DappScanPage({super.key});

  static const routeName = 'dappScan';
  static const routePath = '/dapps/scan';

  /// Whether [value] is a WalletConnect pairing link.
  static bool isPairingUri(String value) =>
      value.trim().toLowerCase().startsWith('wc:');

  @override
  ConsumerState<DappScanPage> createState() => _DappScanPageState();
}

class _DappScanPageState extends ConsumerState<DappScanPage>
    with WidgetsBindingObserver {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.qrCode],
  );

  bool _pairing = false;
  DateTime? _lastInvalidScanAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final service = ref.read(dappConnectServiceProvider);
    if (service.isAvailable) {
      unawaited(service.start().then((_) {}, onError: (Object _) {}));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_controller.dispose());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_controller.value.hasCameraPermission || _pairing) {
      return;
    }
    switch (state) {
      case AppLifecycleState.resumed:
        unawaited(_controller.start());
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        unawaited(_controller.stop());
    }
  }

  Future<void> _handleDetect(BarcodeCapture capture) async {
    if (_pairing) {
      return;
    }
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue;
      if (value != null && DappScanPage.isPairingUri(value)) {
        await _pair(value);
        return;
      }
    }
    final now = DateTime.now();
    final last = _lastInvalidScanAt;
    if (last != null && now.difference(last).inSeconds < 2) {
      return;
    }
    _lastInvalidScanAt = now;
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.dappScanNotWalletConnect)),
      );
    }
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final value = data?.text?.trim() ?? '';
    if (!mounted) {
      return;
    }
    if (!DappScanPage.isPairingUri(value)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.dappScanNotWalletConnect)),
      );
      return;
    }
    await _pair(value);
  }

  Future<void> _pair(String uri) async {
    setState(() => _pairing = true);
    await _controller.stop();
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      await ref.read(dappConnectServiceProvider).pair(uri);
      if (mounted) {
        context.pop();
      }
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(l10n.dappPairFailed)));
      if (mounted) {
        setState(() => _pairing = false);
        unawaited(_controller.start());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final available = ref.read(dappConnectServiceProvider).isAvailable;
    return AppScaffold(
      title: l10n.dappScanTitle,
      child: !available
          ? Center(child: Text(l10n.dappNotConfigured))
          : LayoutBuilder(
              builder: (context, constraints) {
                // A wide, not too tall camera box so the connected websites
                // fit below; the scan frame fills most of its height.
                final boxHeight = min(300.0, constraints.maxWidth * 0.78);
                final frameSize = min(
                  boxHeight - 36,
                  constraints.maxWidth - 64,
                );
                return ListView(
                  children: [
                    SizedBox(
                      height: boxHeight,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            MobileScanner(
                              controller: _controller,
                              onDetect: _handleDetect,
                            ),
                            IgnorePointer(
                              child: Center(
                                child: Container(
                                  width: frameSize,
                                  height: frameSize,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(28),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.92,
                                      ),
                                      width: 2.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (_pairing)
                              ColoredBox(
                                color: Colors.black54,
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        l10n.dappConnecting,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      l10n.dappScanHint,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: _pairing ? null : _paste,
                      icon: const Icon(Icons.content_paste_rounded),
                      label: Text(l10n.dappPasteLink),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
    );
  }
}
