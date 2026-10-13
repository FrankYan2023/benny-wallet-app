import 'package:flutter/foundation.dart';

abstract final class PlatformCapabilities {
  static bool get supportsBiometric => !kIsWeb;
  static bool get shouldWarnWebStorageRisk => kIsWeb;
  static bool get shouldOfferShareOnReceive => !kIsWeb;
}

