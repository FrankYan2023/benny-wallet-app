import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:shared_types/shared_types.dart';
import 'package:solana/base58.dart';

import '../../../app/router.dart';
import '../../../core/airgap/airgap_protocol.dart';
import '../../../core/airgap/solana_message_parser.dart';
import '../../auth/data/solana_wallet_service.dart';
import '../../auth/data/wallet_repository.dart';
import '../../auth/domain/wallet_controller_state.dart';
import '../domain/air_gap_wallet_meta.dart';
import 'pages/air_gap_sign_page.dart';

class AirGapSigningCancelled implements Exception {
  const AirGapSigningCancelled();

  @override
  String toString() => 'Signing on the offline signer was cancelled.';
}

/// Gets signatures from the offline signer: shows the request as a QR code,
/// scans the signature back and checks it before anyone uses it.
class AirGapSigningService {
  AirGapSigningService({
    required WalletRepository repository,
    required SolanaWalletService solana,
  }) : _repository = repository,
       _solana = solana;

  final WalletRepository _repository;
  final SolanaWalletService _solana;

  /// Signs [encodedTransaction] by [ownerAddress] on the offline signer.
  /// A transaction is only valid for about 90 seconds; when that runs out
  /// before the signature comes back, the code on screen is replaced by a
  /// fresh transaction from [rebuild] (by default the same one with a new
  /// blockhash) and the user scans again. Returns the transaction that was
  /// actually signed, and its signature (base58).
  ///
  /// [tokens] are passed on so the signer can name them (it trusts only
  /// those signed with the Benny token key); [swap] gives the current
  /// quote of a swap, read again for each fresh transaction. [usdPrices]
  /// (per whole token, by mint) and [recipient] let the signer show what a
  /// send or swap is worth and who it is for.
  Future<({String transaction, String signature})> signTransaction({
    required String ownerAddress,
    required String encodedTransaction,
    Future<String> Function()? rebuild,
    List<TokenInfo> tokens = const [],
    AirGapSwapSummary? Function()? swap,
    Map<String, double> Function()? usdPrices,
    AirGapRecipient? recipient,
  }) async {
    final byMessage = <String, String>{};
    Uint8List messageOf(String transaction) {
      final message = Uint8List.fromList(
        _solana.signableTransactionMessageBytes(transaction),
      );
      byMessage[base64Encode(message)] = transaction;
      return message;
    }

    final rebuildTransaction =
        rebuild ??
        () => _solana.refreshPreparedTransactionBlockhash(
          encodedTransaction: encodedTransaction,
        );
    final result = await _sign(
      ownerAddress: ownerAddress,
      signData: messageOf(encodedTransaction),
      type: AirGapSignType.transaction,
      rebuild: () async => messageOf(await rebuildTransaction()),
      tokenHints: tokenHintsFor(tokens),
      swap: swap,
      usdPrices: usdPrices,
      recipient: recipient,
    );
    return (
      transaction: byMessage[base64Encode(result.signData)]!,
      signature: base58encode(result.signature),
    );
  }

  /// Signature (base58) of a plain-text [message]. [signIn] marks Benny's
  /// login challenge, so the sign page says what it is for.
  Future<String> signMessage({
    required String ownerAddress,
    required Uint8List message,
    bool signIn = false,
  }) async {
    final result = await _sign(
      ownerAddress: ownerAddress,
      signData: message,
      type: AirGapSignType.message,
      signIn: signIn,
    );
    return base58encode(result.signature);
  }

  Future<({Uint8List signData, Uint8List signature})> _sign({
    required String ownerAddress,
    required Uint8List signData,
    required AirGapSignType type,
    bool signIn = false,
    Future<Uint8List> Function()? rebuild,
    List<AirGapTokenHint> tokenHints = const [],
    AirGapSwapSummary? Function()? swap,
    Map<String, double> Function()? usdPrices,
    AirGapRecipient? recipient,
  }) async {
    final startedAt = DateTime.now();
    final record = (await _repository.readRecords())
        .where(
          (r) =>
              r.publicKey == ownerAddress && r.custody == WalletCustody.airGap,
        )
        .firstOrNull;
    if (record == null) {
      throw StateError('This wallet is not connected to an offline signer.');
    }
    final meta = AirGapWalletMeta.parse(record.airGapMeta);
    final address = Uint8List.fromList(base58decode(ownerAddress));

    Future<AirGapSignRequest> requestFor(Uint8List data) async {
      // Older signers simply do not get fields they cannot use.
      var lookupTables = const <AirGapLookupTable>[];
      if (type == AirGapSignType.transaction &&
          meta.supports(AirGapCapability.lookupTables)) {
        try {
          final references = SolanaMessageParser.parse(data).lookupReferences;
          lookupTables = await _solana.fetchLookupTableEntries(references);
        } on Object {
          // The signer then shows the unread accounts as a warning.
        }
      }
      return AirGapSignRequest(
        requestId: newRequestId(),
        signData: data,
        path: AirGapKeyPath.parse(record.seedVaultDerivationPath),
        address: address,
        signType: type,
        lookupTables: lookupTables,
        // Every signer reads these keys or skips them, so they are sent
        // without checking capabilities.
        tokenHints: tokenHints,
        swapSummary: swap?.call(),
        usdPrices: {
          for (final MapEntry(:key, :value)
              in (usdPrices?.call() ?? const <String, double>{}).entries)
            if (value.isFinite && value > 0 && _isAddress(key)) key: value,
        },
        recipient: recipient,
        sourceFingerprint: meta.masterFingerprint == 0
            ? null
            : meta.masterFingerprint,
        // A pairing code without our signer block came from another
        // signer (Keystone), which cannot read our extra keys.
        standardOnly: meta.signerInfo.protocolVersion == 0,
      );
    }

    final request = await requestFor(signData);
    final navigator = AppRouter.rootNavigatorKey.currentState;
    if (navigator == null) {
      throw StateError('The app is not ready to show the signing code.');
    }
    final popped = await navigator.push<AirGapSignResult>(
      MaterialPageRoute<AirGapSignResult>(
        fullscreenDialog: true,
        builder: (_) => AirGapSignPage(
          request: request,
          meta: meta,
          startedAt: startedAt,
          signIn: signIn,
          refresh: rebuild == null
              ? null
              : () async => requestFor(await rebuild()),
        ),
      ),
    );
    if (popped == null) {
      throw const AirGapSigningCancelled();
    }
    final result = popped.signature;
    final signedData = popped.request.signData;

    final valid = await Ed25519().verify(
      signedData,
      signature: Signature(
        result.signature,
        publicKey: SimplePublicKey(address, type: KeyPairType.ed25519),
      ),
    );
    if (!valid) {
      throw StateError('The signer returned a signature for another account.');
    }

    // signerInfo sits outside the signed bytes: it may only raise what
    // pairing stored, never drop a capability or lower a version.
    final info = result.signerInfo;
    final updated = info == null ? null : meta.acceptSignerInfo(info);
    if (updated != null) {
      await _repository.updateAirGapMeta(
        publicKey: ownerAddress,
        airGapMeta: updated.encode(),
      );
    }
    return (signData: signedData, signature: result.signature);
  }
}

bool _isAddress(String value) {
  try {
    return base58decode(value).length == 32;
  } on Object {
    return false;
  }
}

/// Hints for the offline signer about [tokens] (native SOL needs none).
List<AirGapTokenHint> tokenHintsFor(Iterable<TokenInfo> tokens) {
  final hints = <String, AirGapTokenHint>{};
  for (final token in tokens) {
    if (token.isNative || hints.containsKey(token.mintAddress)) {
      continue;
    }
    final Uint8List mint;
    try {
      mint = Uint8List.fromList(base58decode(token.mintAddress));
    } on Object {
      continue;
    }
    if (mint.length != 32) {
      continue;
    }
    Uint8List? attestation;
    final encoded = token.signerAttestation;
    if (encoded != null && encoded.isNotEmpty) {
      try {
        attestation = base64Decode(encoded);
      } on FormatException {
        attestation = null;
      }
    }
    hints[token.mintAddress] = AirGapTokenHint(
      mint: mint,
      symbol: token.symbol,
      name: token.name,
      decimals: token.decimals,
      attestation: attestation,
    );
  }
  return hints.values.toList();
}
