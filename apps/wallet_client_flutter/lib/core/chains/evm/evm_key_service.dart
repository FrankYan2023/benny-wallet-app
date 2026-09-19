import 'dart:typed_data';
import 'package:bip32/bip32.dart' as bip32;
import 'package:bip39/bip39.dart' as bip39;
import 'package:web3dart/web3dart.dart';

/// Independent secp256k1 account; never accepts a Solana private key as a root.
/// No mnemonic, seed, or derived private key is persisted by this service.
class EvmKeyService {
  static const derivationPath = "m/44'/60'/0'/0/0";

  static Uint8List derivePrivateKey(String mnemonic) {
    if (!bip39.validateMnemonic(mnemonic)) {
      throw const FormatException(
        'A valid recovery phrase is required for EVM account derivation.',
      );
    }
    final seed = bip39.mnemonicToSeed(mnemonic);
    try {
      final node = bip32.BIP32.fromSeed(seed).derivePath(derivationPath);
      return Uint8List.fromList(node.privateKey!);
    } finally {
      seed.fillRange(0, seed.length, 0);
    }
  }

  static String deriveAddress(String mnemonic) {
    final key = derivePrivateKey(mnemonic);
    try {
      return EthPrivateKey(key).address.hexEip55;
    } finally {
      key.fillRange(0, key.length, 0);
    }
  }
}
