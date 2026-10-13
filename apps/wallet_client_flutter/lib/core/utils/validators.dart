import 'package:bip39/bip39.dart' as bip39;
import 'package:solana/solana.dart';

abstract final class Validators {
  static String normalizeMnemonic(String input) {
    return input
        .trim()
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .join(' ');
  }

  static bool isValidMnemonic(String input) {
    final normalized = normalizeMnemonic(input);
    return bip39.validateMnemonic(normalized);
  }

  static bool isValidPublicAddress(String input) {
    try {
      Ed25519HDPublicKey.fromBase58(input.trim());
      return true;
    } catch (_) {
      return false;
    }
  }
}

