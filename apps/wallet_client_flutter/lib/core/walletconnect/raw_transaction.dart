import 'dart:typed_data';

import 'package:solana/base58.dart';

/// A serialized Solana transaction read at the byte level, so a dApp's
/// transaction can be signed without re-encoding it: the signatures other
/// parties already placed and the message bytes stay exactly as sent.
///
/// Layout: compact-u16 signature count, 64 bytes per signature, then the
/// message (legacy, or v0 with a 0x80 prefix byte).
class RawTransaction {
  RawTransaction._(this._bytes, this._signatureCount, this._messageOffset);

  /// Reads [bytes]; throws [FormatException] when they are not a transaction.
  factory RawTransaction.parse(Uint8List bytes) {
    final (count, countLength) = _readCompactU16(bytes, 0);
    final messageOffset = countLength + 64 * count;
    if (count == 0 || messageOffset >= bytes.length) {
      throw const FormatException('Not a Solana transaction.');
    }
    final transaction = RawTransaction._(
      Uint8List.fromList(bytes),
      count,
      messageOffset,
    );
    if (transaction.requiredSigners.length != count) {
      throw const FormatException('Signature count does not match message.');
    }
    return transaction;
  }

  final Uint8List _bytes;
  final int _signatureCount;
  final int _messageOffset;

  /// The whole transaction as sent.
  Uint8List get bytes => Uint8List.fromList(_bytes);

  /// The bytes every signer signs.
  Uint8List get message => Uint8List.sublistView(_bytes, _messageOffset);

  /// The accounts that must sign, in signature-slot order.
  List<String> get requiredSigners {
    var offset = _messageOffset;
    if (_bytes[offset] & 0x80 != 0) {
      offset += 1; // version prefix
    }
    final required = _bytes[offset];
    offset += 3; // header
    final (keyCount, keyCountLength) = _readCompactU16(_bytes, offset);
    offset += keyCountLength;
    if (required > keyCount || offset + 32 * required > _bytes.length) {
      throw const FormatException('Truncated account keys.');
    }
    return [
      for (var i = 0; i < required; i++)
        base58encode(_bytes.sublist(offset + 32 * i, offset + 32 * (i + 1))),
    ];
  }

  /// The signature slot [address] signs in, or null when it is not a signer.
  int? signerIndex(String address) {
    final index = requiredSigners.indexOf(address);
    return index < 0 ? null : index;
  }

  /// The signature in [index], or null while that slot is still empty.
  Uint8List? signatureAt(int index) {
    final start = _messageOffset - 64 * (_signatureCount - index);
    final signature = _bytes.sublist(start, start + 64);
    return signature.every((b) => b == 0) ? null : signature;
  }

  /// A copy of the transaction with [signature] in [address]'s slot.
  Uint8List withSignature(String address, Uint8List signature) {
    if (signature.length != 64) {
      throw ArgumentError('A signature is 64 bytes.');
    }
    final index = signerIndex(address);
    if (index == null) {
      throw StateError('$address does not sign this transaction.');
    }
    final out = Uint8List.fromList(_bytes);
    final start = _messageOffset - 64 * (_signatureCount - index);
    out.setRange(start, start + 64, signature);
    return out;
  }

  static (int value, int length) _readCompactU16(Uint8List bytes, int offset) {
    var value = 0;
    for (var i = 0; i < 3; i++) {
      if (offset + i >= bytes.length) {
        throw const FormatException('Truncated length.');
      }
      final byte = bytes[offset + i];
      value |= (byte & 0x7f) << (7 * i);
      if (byte & 0x80 == 0) {
        return (value, i + 1);
      }
    }
    throw const FormatException('Invalid length.');
  }
}
