import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../ur.dart';

/// Camera view that collects single- or multi-part UR codes of the
/// [acceptedTypes] and reports the complete UR once.
class UrScannerView extends StatefulWidget {
  const UrScannerView({
    super.key,
    required this.acceptedTypes,
    required this.onResult,
    this.onWrongCode,
    this.height = 320,
  });

  final Set<String> acceptedTypes;
  final ValueChanged<Ur> onResult;

  /// Called (throttled) when a code is not one of [acceptedTypes].
  final VoidCallback? onWrongCode;
  final double height;

  @override
  State<UrScannerView> createState() => _UrScannerViewState();
}

class _UrScannerViewState extends State<UrScannerView>
    with WidgetsBindingObserver {
  final MobileScannerController _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );
  UrDecoder _decoder = UrDecoder();
  bool _done = false;
  double _progress = 0;
  DateTime? _lastWrongCodeAt;

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
    if (!_controller.value.hasCameraPermission || _done) {
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

  void _handleDetect(BarcodeCapture capture) {
    if (_done) {
      return;
    }
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue?.trim();
      if (raw == null || raw.isEmpty) {
        continue;
      }
      final lower = raw.toLowerCase();
      final type = lower.startsWith('ur:')
          ? lower.substring(3).split('/').first
          : null;
      if (type == null || !widget.acceptedTypes.contains(type)) {
        _reportWrongCode();
        continue;
      }
      try {
        _decoder.receive(raw);
      } on Object {
        // A frame from another message or a misread: start over.
        _decoder = UrDecoder();
        try {
          _decoder.receive(raw);
        } on Object {
          continue;
        }
      }
      final result = _decoder.result;
      if (result != null) {
        _done = true;
        unawaited(_controller.stop());
        widget.onResult(result);
        return;
      }
      if (_decoder.progress != _progress) {
        setState(() => _progress = _decoder.progress);
      }
    }
  }

  void _reportWrongCode() {
    final now = DateTime.now();
    final last = _lastWrongCodeAt;
    if (last != null && now.difference(last) < const Duration(seconds: 3)) {
      return;
    }
    _lastWrongCodeAt = now;
    widget.onWrongCode?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: widget.height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              fit: StackFit.expand,
              children: [
                MobileScanner(controller: _controller, onDetect: _handleDetect),
                IgnorePointer(
                  child: Center(
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.9),
                          width: 2.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        AnimatedOpacity(
          opacity: _progress > 0 && _progress < 1 ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          child: LinearProgressIndicator(
            value: _progress,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
