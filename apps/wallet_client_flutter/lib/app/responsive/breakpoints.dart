import 'package:flutter/material.dart';

abstract final class AppBreakpoints {
  static const compact = 720.0;
  static const medium = 1100.0;
}

enum AppLayoutMode { mobile, tablet, desktop }

extension BreakpointContext on BuildContext {
  AppLayoutMode get layoutMode {
    final width = MediaQuery.sizeOf(this).width;
    if (width >= AppBreakpoints.medium) {
      return AppLayoutMode.desktop;
    }
    if (width >= AppBreakpoints.compact) {
      return AppLayoutMode.tablet;
    }
    return AppLayoutMode.mobile;
  }

  bool get isWideLayout => layoutMode != AppLayoutMode.mobile;
}

