import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../ur.dart';

/// Shows a UR as a QR code. Payloads that do not fit one code are shown as
/// an endless fountain-coded sequence the other phone can join at any frame.
class AnimatedUrQr extends StatefulWidget {
  const AnimatedUrQr({
    super.key,
    required this.ur,
    this.size = 280,
    this.maxFragmentLength = 160,
    this.frameInterval = const Duration(milliseconds: 250),
  });

  final Ur ur;
  final double size;
  final int maxFragmentLength;
  final Duration frameInterval;

  @override
  State<AnimatedUrQr> createState() => _AnimatedUrQrState();
}

class _AnimatedUrQrState extends State<AnimatedUrQr> {
  late UrEncoder _encoder;
  late String _part;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void didUpdateWidget(covariant AnimatedUrQr oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.ur, widget.ur)) {
      _timer?.cancel();
      _start();
    }
  }

  void _start() {
    _encoder = UrEncoder(
      widget.ur,
      maxFragmentLength: widget.maxFragmentLength,
    );
    _part = _encoder.nextPart().toUpperCase();
    if (!_encoder.isSinglePart) {
      _timer = Timer.periodic(widget.frameInterval, (_) {
        setState(() => _part = _encoder.nextPart().toUpperCase());
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: QrImageView(
        data: _part,
        size: widget.size,
        padding: EdgeInsets.zero,
        gapless: true,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
        backgroundColor: Colors.white,
      ),
    );
  }
}
