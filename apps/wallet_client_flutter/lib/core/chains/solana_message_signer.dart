import 'dart:convert';
import 'dart:isolate';
import 'package:solana/base58.dart';
import 'package:solana/solana.dart';
import '../../features/auth/domain/wallet_derivation.dart';

/// Local authentication proof only. Preserve the existing Solana derivation and
/// return just its public signature from a short-lived background isolate.
abstract final class SolanaMessageSigner {
  static Future<String> sign({
    required String mnemonic,
    required WalletDerivation derivation,
    required String expectedOwner,
    required String message,
  }) => Isolate.run(() async {
    final pair = await Ed25519HDKeyPair.fromMnemonic(
      mnemonic,
      account: derivation.accountIndex,
      change: derivation.changeIndex,
    );
    if (pair.address != expectedOwner)
      throw StateError('Wallet changed during authentication.');
    final signature = await pair.sign(utf8.encode(message));
    return base58encode(signature.bytes.toList(growable: false));
  });
}
