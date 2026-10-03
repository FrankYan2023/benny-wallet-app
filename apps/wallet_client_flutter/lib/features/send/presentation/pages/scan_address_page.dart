import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/chains/recipient_decoder.dart';
import '../../../multichain/presentation/chain_widgets.dart';
import '../../../multichain/providers/multichain_providers.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../l10n/l10n.dart';

class ScanAddressPage extends ConsumerStatefulWidget {
  const ScanAddressPage({super.key, this.chainId});
  final String? chainId;
  static String pathFor(String chainId) =>
      Uri(path: routePath, queryParameters: {'network': chainId}).toString();

  static const routeName = 'scanAddress';
  static const routePath = '/send/scan-address';

  @override
  ConsumerState<ScanAddressPage> createState() => _ScanAddressPageState();
}

class _ScanAddressPageState extends ConsumerState<ScanAddressPage>
    with WidgetsBindingObserver {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.qrCode],
  );

  bool _handled = false;
  DateTime? _lastInvalidScanAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_controller.dispose());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_controller.value.hasCameraPermission || _handled) {
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
    if (_handled) {
      return;
    }

    for (final barcode in capture.barcodes) {
      final rawValue = barcode.rawValue;
      if (rawValue == null || rawValue.trim().isEmpty) {
        continue;
      }

      final configs = ref.read(chainConfigsProvider);
      final chainId = widget.chainId ?? configs.first.id;
      final config = findChain(configs, chainId);
      if (config == null) continue;
      final address = decodeRecipient(
        rawValue,
        config,
        ref.read(chainAdapterProvider(chainId)).validateAddress,
      );
      if (address == null) {
        continue;
      }

      _handled = true;
      await _controller.stop();
      if (!mounted) {
        return;
      }
      context.pop(address);
      return;
    }

    final now = DateTime.now();
    final last = _lastInvalidScanAt;
    if (last != null && now.difference(last).inSeconds < 2) {
      return;
    }
    _lastInvalidScanAt = now;

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.chainId == null
              ? context.l10n.scanNoSolanaAddress
              : chainText(
                  context,
                  'No valid address for the selected network was found in this QR code.',
                  '二维码中没有所选网络的有效地址。',
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: context.l10n.scanAddressTitle,
      child: Column(
        children: [
          ChainNetworkLabel(
            config:
                findChain(
                  ref.watch(chainConfigsProvider),
                  widget.chainId ?? ref.watch(chainConfigsProvider).first.id,
                ) ??
                ref.watch(chainConfigsProvider).first,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
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
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.92),
                              width: 2.5,
                            ),
                            color: Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            context.l10n.scanPointCamera,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
