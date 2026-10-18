import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:solana/base58.dart';

/// Offline signers trust token names from two places only: the list built
/// into the app, and tokens signed with the Benny token key. That key is
/// kept off the servers; tool/token_attest signs the catalog with it and
/// writes the signatures to the backend, which hands them to the wallet,
/// which passes them to the signer with each request. A phone that has
/// been tampered with cannot forge them.
abstract final class TokenAttestation {
  static const _domain = 'benny-token-attestation-v1';

  /// Public keys (base58) whose signatures the signer accepts.
  static const trustedKeys = <String>[
    'FF5XhQ96rbYb48EW3Wi1n5SjLFj2pZ5nnfDyGniE9gGj',
  ];

  /// The exact bytes that are signed.
  static Uint8List message({
    required String mint,
    required String symbol,
    required String name,
    required int decimals,
  }) {
    final symbolBytes = utf8.encode(symbol);
    final nameBytes = utf8.encode(name);
    if (symbolBytes.length > 255 || nameBytes.length > 255) {
      throw ArgumentError('symbol or name too long');
    }
    // One byte on the wire: anything else must not alias a valid value
    // (262 would otherwise sign as 6).
    if (decimals < 0 || decimals > 255) {
      throw ArgumentError.value(decimals, 'decimals', 'must be 0..255');
    }
    return Uint8List.fromList([
      ...utf8.encode(_domain),
      0,
      ...base58decode(mint),
      decimals,
      symbolBytes.length,
      ...symbolBytes,
      nameBytes.length,
      ...nameBytes,
    ]);
  }

  /// True when [signature] was made by one of [keys] over this token.
  static Future<bool> verify({
    required String mint,
    required String symbol,
    required String name,
    required int decimals,
    required List<int> signature,
    List<String> keys = trustedKeys,
  }) async {
    if (signature.length != 64 || keys.isEmpty) {
      return false;
    }
    final Uint8List data;
    try {
      data = message(
        mint: mint,
        symbol: symbol,
        name: name,
        decimals: decimals,
      );
    } on Object {
      return false;
    }
    for (final key in keys) {
      final ok = await Ed25519().verify(
        data,
        signature: Signature(
          signature,
          publicKey: SimplePublicKey(
            base58decode(key),
            type: KeyPairType.ed25519,
          ),
        ),
      );
      if (ok) {
        return true;
      }
    }
    return false;
  }
}
