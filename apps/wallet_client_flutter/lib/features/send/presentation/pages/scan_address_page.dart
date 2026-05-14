import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_scaffold.dart';

class ScanAddressPage extends StatefulWidget {
  const ScanAddressPage({super.key});

  static const routeName = 'scanAddress';
  static const routePath = '/send/scan-address';

  @override
  State<ScanAddressPage> createState() => _ScanAddressPageState();
}

class _ScanAddressPageState extends State<ScanAddressPage>
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

      final address = _extractSolanaAddress(rawValue);
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
      const SnackBar(content: Text('No Solana address found in this QR code.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Scan address',
      child: Column(
        children: [
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
            'Point the camera at a Solana QR code.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String? _extractSolanaAddress(String rawValue) {
    final trimmed = rawValue.trim();
    if (Validators.isValidPublicAddress(trimmed)) {
      return trimmed;
    }

    final uri = Uri.tryParse(trimmed);
    if (uri != null) {
      final candidates = <String>{
        if (uri.host.isNotEmpty) uri.host,
        if (uri.path.isNotEmpty) uri.path.replaceFirst('/', ''),
        if (uri.scheme.toLowerCase() == 'solana' && uri.path.isNotEmpty)
          uri.path.replaceFirst('/', ''),
        if (uri.scheme.toLowerCase() == 'solana' && uri.host.isNotEmpty) uri.host,
      };

      for (final candidate in candidates) {
        if (candidate.isNotEmpty && Validators.isValidPublicAddress(candidate)) {
          return candidate;
        }
      }
    }

    final match = RegExp(r'[1-9A-HJ-NP-Za-km-z]{32,44}').firstMatch(trimmed);
    final fallback = match?.group(0);
    if (fallback != null && Validators.isValidPublicAddress(fallback)) {
      return fallback;
    }

    return null;
  }
}
