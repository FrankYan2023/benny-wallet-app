import 'dart:math';
import 'dart:typed_data';

import 'package:solana/base58.dart';

import 'cbor.dart';
import 'ur.dart';

/// Version of the Benny air-gap QR protocol. Fields are only ever added
/// (as optional keys >= 100); released fields never change meaning, so any
/// wallet can talk to any signer from 0.1.0 on. See the design doc,
/// "签名机升级与版本兼容".
const airGapProtocolVersion = 1;

/// Capabilities a signer can advertise. A wallet degrades to what the
/// paired signer supports (e.g. splits a batch into single requests).
abstract final class AirGapCapability {
  static const signTransaction = 'sign-tx';
  static const signMessage = 'sign-msg';
  static const lookupTables = 'alt';
  static const tokenHints = 'token-hints';

  /// Shows Benny's login message as a login, not as raw text (0.1.1).
  static const signIn = 'sign-in';
}

/// UR type names. The first three follow Keystone's Solana registry so the
/// wallet can later talk to Keystone-compatible signers as well.
abstract final class AirGapUrType {
  static const accounts = 'crypto-multi-accounts';
  static const signRequest = 'sol-sign-request';
  static const signature = 'sol-signature';
}

abstract final class _Tag {
  static const uuid = 37;
  static const hdKey = 303;
  static const keyPath = 304;
  static const multiAccounts = 1103;
  static const solSignRequest = 1101;
  static const solSignature = 1102;
}

/// Wallet-supplied text made safe to show on the review screen: control,
/// format (bidi overrides, zero-width) and line/paragraph separator
/// characters are removed, so a name cannot reorder or hide what follows
/// it, then whitespace is collapsed to single spaces and trimmed.
String cleanDisplayText(String text) => text
    .replaceAll(_lineBreaks, ' ')
    .replaceAll(_invisible, '')
    .replaceAll(_spaces, ' ')
    .trim();

final _lineBreaks = RegExp(r'[\p{Cc}\p{Zl}\p{Zp}]', unicode: true);
final _invisible = RegExp(r'\p{Cf}', unicode: true);
final _spaces = RegExp(r'\s+', unicode: true);

class AirGapProtocolException implements Exception {
  const AirGapProtocolException(this.message);

  final String message;

  @override
  String toString() => 'AirGapProtocolException: $message';
}

enum AirGapSignType {
  transaction(1),
  message(2);

  const AirGapSignType(this.code);

  final int code;

  static AirGapSignType? fromCode(int code) {
    for (final type in values) {
      if (type.code == code) {
        return type;
      }
    }
    return null;
  }
}

/// Signer facts sent with pairing codes and signatures (extension key 100).
class AirGapSignerInfo {
  const AirGapSignerInfo({
    required this.appVersion,
    required this.protocolVersion,
    required this.tokenListVersion,
    required this.capabilities,
  });

  final String appVersion;
  final int protocolVersion;
  final int tokenListVersion;
  final Set<String> capabilities;

  Map<Object?, Object?> toCbor() => {
    1: appVersion,
    2: protocolVersion,
    3: tokenListVersion,
    4: capabilities.toList()..sort(),
  };

  static AirGapSignerInfo? fromCbor(Object? value) {
    if (value is! Map) {
      return null;
    }
    final capabilities = value[4];
    return AirGapSignerInfo(
      appVersion: value[1] is String ? value[1] as String : '',
      protocolVersion: value[2] is int ? value[2] as int : 0,
      tokenListVersion: value[3] is int ? value[3] as int : 0,
      capabilities: capabilities is List
          ? capabilities.whereType<String>().toSet()
          : const {},
    );
  }

  Map<String, dynamic> toJson() => {
    'appVersion': appVersion,
    'protocolVersion': protocolVersion,
    'tokenListVersion': tokenListVersion,
    'capabilities': capabilities.toList()..sort(),
  };

  factory AirGapSignerInfo.fromJson(Map<String, dynamic> json) {
    return AirGapSignerInfo(
      appVersion: json['appVersion'] as String? ?? '',
      protocolVersion: (json['protocolVersion'] as num?)?.toInt() ?? 0,
      tokenListVersion: (json['tokenListVersion'] as num?)?.toInt() ?? 0,
      capabilities: ((json['capabilities'] as List?) ?? const [])
          .whereType<String>()
          .toSet(),
    );
  }
}

/// A hardened BIP-44 path such as `m/44'/501'/0'/0'`.
class AirGapKeyPath {
  const AirGapKeyPath(this.indexes);

  /// All components are hardened (ed25519 / SLIP-0010 only allows that).
  final List<int> indexes;

  static AirGapKeyPath parse(String path) {
    final parts = path.trim().split('/');
    if (parts.isEmpty || parts.first != 'm') {
      throw const AirGapProtocolException('Invalid derivation path.');
    }
    final indexes = <int>[];
    for (final part in parts.skip(1)) {
      if (!part.endsWith("'")) {
        throw const AirGapProtocolException('Path must be fully hardened.');
      }
      final value = int.tryParse(part.substring(0, part.length - 1));
      if (value == null || value < 0 || value >= 0x80000000) {
        throw const AirGapProtocolException('Invalid path index.');
      }
      indexes.add(value);
    }
    return AirGapKeyPath(indexes);
  }

  @override
  String toString() => ['m', for (final i in indexes) "$i'"].join('/');

  CborTag toCbor({int? sourceFingerprint}) => CborTag(_Tag.keyPath, {
    1: [
      for (final index in indexes) ...[index, true],
    ],
    if (sourceFingerprint != null) 2: sourceFingerprint,
  });

  /// The master fingerprint a key path names, or null when it has none.
  static int? sourceFingerprintOf(Object? value) {
    final map = value is CborTag && value.tag == _Tag.keyPath
        ? value.value
        : value;
    final fingerprint = map is Map ? map[2] : null;
    return fingerprint is int && fingerprint >= 0 && fingerprint <= 0xffffffff
        ? fingerprint
        : null;
  }

  static AirGapKeyPath fromCbor(Object? value) {
    final map = value is CborTag && value.tag == _Tag.keyPath
        ? value.value
        : value;
    if (map is! Map || map[1] is! List) {
      throw const AirGapProtocolException('Invalid key path.');
    }
    final components = map[1] as List;
    if (components.length.isOdd || components.length > 20) {
      throw const AirGapProtocolException('Invalid key path.');
    }
    if (components.isEmpty) {
      throw const AirGapProtocolException('Invalid key path.');
    }
    final indexes = <int>[];
    for (var i = 0; i < components.length; i += 2) {
      final index = components[i];
      if (index is! int || components[i + 1] != true) {
        throw const AirGapProtocolException('Path must be fully hardened.');
      }
      // Same range as parse(): the hardened bit is not part of the index.
      if (index < 0 || index >= 0x80000000) {
        throw const AirGapProtocolException('Invalid path index.');
      }
      indexes.add(index);
    }
    return AirGapKeyPath(indexes);
  }

  @override
  bool operator ==(Object other) =>
      other is AirGapKeyPath && toString() == other.toString();

  @override
  int get hashCode => toString().hashCode;
}

class AirGapAccount {
  const AirGapAccount({required this.publicKey, required this.path});

  /// 32-byte ed25519 public key (the Solana address bytes).
  final Uint8List publicKey;
  final AirGapKeyPath path;
}

/// Pairing code: the signer's public keys, nothing secret.
class AirGapAccountsExport {
  const AirGapAccountsExport({
    required this.masterFingerprint,
    required this.deviceName,
    required this.accounts,
    required this.signerInfo,
  });

  final int masterFingerprint;
  final String deviceName;
  final List<AirGapAccount> accounts;
  final AirGapSignerInfo signerInfo;

  Ur toUr() => Ur(
    AirGapUrType.accounts,
    Cbor.encode({
      1: masterFingerprint,
      2: [
        for (final account in accounts)
          CborTag(_Tag.hdKey, {
            3: account.publicKey,
            6: account.path.toCbor(sourceFingerprint: masterFingerprint),
          }),
      ],
      3: deviceName,
      100: signerInfo.toCbor(),
    }),
  );

  static AirGapAccountsExport fromUr(Ur ur) {
    if (ur.type != AirGapUrType.accounts) {
      throw const AirGapProtocolException('Not a pairing code.');
    }
    var value = Cbor.decode(ur.cbor);
    if (value is CborTag && value.tag == _Tag.multiAccounts) {
      value = value.value;
    }
    if (value is! Map || value[1] is! int || value[2] is! List) {
      throw const AirGapProtocolException('Invalid pairing code.');
    }
    final accounts = <AirGapAccount>[];
    for (final raw in value[2] as List) {
      final key = raw is CborTag ? raw.value : raw;
      if (key is! Map || key[3] is! Uint8List) {
        throw const AirGapProtocolException('Invalid account in pairing code.');
      }
      final publicKey = key[3] as Uint8List;
      if (publicKey.length != 32) {
        throw const AirGapProtocolException('Unsupported key type.');
      }
      accounts.add(
        AirGapAccount(
          publicKey: publicKey,
          path: AirGapKeyPath.fromCbor(key[6]),
        ),
      );
    }
    if (accounts.isEmpty) {
      throw const AirGapProtocolException('Pairing code has no accounts.');
    }
    return AirGapAccountsExport(
      masterFingerprint: value[1] as int,
      deviceName: value[3] is String ? value[3] as String : '',
      accounts: accounts,
      signerInfo:
          AirGapSignerInfo.fromCbor(value[100]) ??
          const AirGapSignerInfo(
            appVersion: '',
            protocolVersion: 0,
            tokenListVersion: 0,
            capabilities: {AirGapCapability.signTransaction},
          ),
    );
  }
}

/// Token metadata the wallet attaches to a request. Only shown as verified
/// when [attestation] checks out against the pinned Benny token key; a bare
/// hint is never shown as a name (see the design doc).
class AirGapTokenHint {
  const AirGapTokenHint({
    required this.mint,
    required this.symbol,
    required this.decimals,
    this.name = '',
    this.attestation,
  });

  final Uint8List mint;
  final String symbol;
  final int decimals;
  final String name;

  /// Benny token key's signature, see `token_attestation.dart`.
  final Uint8List? attestation;

  /// SPL mints allow up to 255, but no real token uses more than 18; more
  /// would only serve to make an amount look tiny.
  static const maxDecimals = 18;
  static const maxSymbolLength = 32;
  static const maxNameLength = 64;

  Map<Object?, Object?> toCbor() => {
    1: mint,
    2: symbol,
    3: decimals,
    if (attestation != null) 4: attestation,
    if (name.isNotEmpty) 5: name,
  };

  static AirGapTokenHint? fromCbor(Object? value) {
    if (value is! Map ||
        value[1] is! Uint8List ||
        (value[1] as Uint8List).length != 32 ||
        value[2] is! String ||
        value[3] is! int) {
      return null;
    }
    final decimals = value[3] as int;
    // Cleaned before the attestation check (token_registry.dart verifies
    // exactly what is shown), so a symbol that needed cleaning never
    // verifies.
    final symbol = cleanDisplayText(value[2] as String);
    final name = value[5] is String ? cleanDisplayText(value[5] as String) : '';
    if (decimals < 0 ||
        decimals > maxDecimals ||
        symbol.isEmpty ||
        symbol.runes.length > maxSymbolLength ||
        name.runes.length > maxNameLength) {
      return null;
    }
    final attestation = value[4];
    return AirGapTokenHint(
      mint: value[1] as Uint8List,
      symbol: symbol,
      decimals: decimals,
      name: name,
      attestation: attestation is Uint8List ? attestation : null,
    );
  }
}

/// What the online wallet says a swap pays and gets back (its quote). The
/// signer shows it only for tokens the transaction really touches, and
/// marks it as the wallet's figures, since it cannot check them.
class AirGapSwapSummary {
  const AirGapSwapSummary({
    required this.inputMint,
    required this.inputAmount,
    required this.outputMint,
    required this.outputAmount,
  });

  final Uint8List inputMint;
  final BigInt inputAmount;
  final Uint8List outputMint;
  final BigInt outputAmount;

  Map<Object?, Object?> toCbor() => {
    1: inputMint,
    2: inputAmount.toString(),
    3: outputMint,
    4: outputAmount.toString(),
  };

  static final _maxU64 = (BigInt.one << 64) - BigInt.one;
  static final _digits = RegExp(r'^[0-9]{1,20}$');

  /// A token amount in base units: plain decimal digits, at most u64::MAX.
  /// BigInt.tryParse alone would take hex, signs and padding.
  static BigInt? _amount(Object? value) {
    if (value is! String || !_digits.hasMatch(value)) {
      return null;
    }
    final amount = BigInt.parse(value);
    return amount > _maxU64 ? null : amount;
  }

  static AirGapSwapSummary? fromCbor(Object? value) {
    if (value is! Map) {
      return null;
    }
    final inputMint = value[1];
    final outputMint = value[3];
    final inputAmount = _amount(value[2]);
    final outputAmount = _amount(value[4]);
    if (inputMint is! Uint8List ||
        inputMint.length != 32 ||
        outputMint is! Uint8List ||
        outputMint.length != 32 ||
        inputAmount == null ||
        outputAmount == null ||
        inputAmount.isNegative ||
        outputAmount.isNegative) {
      return null;
    }
    return AirGapSwapSummary(
      inputMint: inputMint,
      inputAmount: inputAmount,
      outputMint: outputMint,
      outputAmount: outputAmount,
    );
  }
}

/// The account a send is meant for and the wallet's name for it (e.g. one
/// of the user's own wallets). The signer shows the address only if the
/// transaction really pays it, and the name as the wallet's label.
class AirGapRecipient {
  const AirGapRecipient({required this.address, this.name = ''});

  final Uint8List address;
  final String name;

  Map<Object?, Object?> toCbor() => {1: address, if (name.isNotEmpty) 2: name};

  static AirGapRecipient? fromCbor(Object? value) {
    if (value is! Map ||
        value[1] is! Uint8List ||
        (value[1] as Uint8List).length != 32) {
      return null;
    }
    final name = value[2] is String ? cleanDisplayText(value[2] as String) : '';
    return AirGapRecipient(
      address: value[1] as Uint8List,
      // Long enough for any wallet name, short enough to stay one line.
      name: String.fromCharCodes(name.runes.take(32)).trimRight(),
    );
  }
}

/// Entries of an address lookup table, supplied by the online wallet
/// because the offline signer cannot read the chain. Only the indexes the
/// transaction uses are sent, keyed by index, so the QR stays small.
class AirGapLookupTable {
  const AirGapLookupTable({required this.address, required this.entries});

  final Uint8List address;
  final Map<int, Uint8List> entries;

  Object toCbor() => [address, entries];

  static AirGapLookupTable? fromCbor(Object? value) {
    if (value is! List ||
        value.length != 2 ||
        value[0] is! Uint8List ||
        (value[0] as Uint8List).length != 32 ||
        value[1] is! Map) {
      return null;
    }
    final entries = <int, Uint8List>{};
    for (final entry in (value[1] as Map).entries) {
      final index = entry.key;
      final key = entry.value;
      if (index is! int ||
          index < 0 ||
          index > 255 ||
          key is! Uint8List ||
          key.length != 32) {
        return null;
      }
      entries[index] = key;
    }
    return AirGapLookupTable(address: value[0] as Uint8List, entries: entries);
  }
}

Uint8List newRequestId([Random? random]) {
  final rng = random ?? Random.secure();
  final bytes = Uint8List.fromList(List.generate(16, (_) => rng.nextInt(256)));
  // RFC 4122 version 4.
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  return bytes;
}

class AirGapSignRequest {
  const AirGapSignRequest({
    required this.requestId,
    required this.signData,
    required this.path,
    required this.address,
    required this.signType,
    this.origin = 'Benny Wallet',
    this.protocolVersion = airGapProtocolVersion,
    this.tokenHints = const [],
    this.lookupTables = const [],
    this.swapSummary,
    this.usdPrices = const {},
    this.recipient,
    this.sourceFingerprint,
    this.standardOnly = false,
  });

  /// Empty when a Keystone-style wallet left the optional id out; the
  /// signature then carries none either.
  final Uint8List requestId;

  /// Transaction message bytes (not the signed transaction) or raw message.
  final Uint8List signData;
  final AirGapKeyPath path;

  /// Optional in the registry. Keystone's own SDK fills it by hex-decoding
  /// whatever string the wallet passes (Backpack passes base58), so a value
  /// that is not a 32-byte key is dropped and the account is found by path
  /// and fingerprint alone, as Keystone does.
  final Uint8List? address;
  final AirGapSignType signType;
  final String origin;
  final int protocolVersion;
  final List<AirGapTokenHint> tokenHints;
  final List<AirGapLookupTable> lookupTables;
  final AirGapSwapSummary? swapSummary;

  /// The wallet's USD price per whole token, by mint (native SOL under the
  /// wrapped SOL mint). Shown as an estimate; the signer cannot check it.
  final Map<String, double> usdPrices;

  /// Who a send is for, as the wallet knows them.
  final AirGapRecipient? recipient;

  /// The signer's master fingerprint, written into the key path. Keystone
  /// refuses a request without it; our signer ignores it.
  final int? sourceFingerprint;

  /// Only the registry keys 1-6, for signers that are not Benny (Keystone).
  /// Their decoder does not skip unknown map keys, so any of our 100+ keys
  /// makes the whole request unreadable there.
  final bool standardOnly;

  static const maxSignDataLength = 4096;

  Ur toUr() => Ur(
    AirGapUrType.signRequest,
    Cbor.encode({
      if (requestId.isNotEmpty) 1: CborTag(_Tag.uuid, requestId),
      2: signData,
      3: path.toCbor(sourceFingerprint: sourceFingerprint),
      if (address != null) 4: address,
      5: origin,
      6: signType.code,
      if (!standardOnly) ...{
        100: protocolVersion,
        if (tokenHints.isNotEmpty)
          101: [for (final hint in tokenHints) hint.toCbor()],
        if (lookupTables.isNotEmpty)
          102: [for (final table in lookupTables) table.toCbor()],
        if (swapSummary != null) 103: swapSummary!.toCbor(),
        if (usdPrices.isNotEmpty)
          104: [
            for (final entry in usdPrices.entries)
              [Uint8List.fromList(base58decode(entry.key)), '${entry.value}'],
          ],
        if (recipient != null) 105: recipient!.toCbor(),
      },
    }),
  );

  static AirGapSignRequest fromUr(Ur ur) {
    if (ur.type != AirGapUrType.signRequest) {
      throw const AirGapProtocolException('Not a signing request.');
    }
    var value = Cbor.decode(ur.cbor);
    if (value is CborTag && value.tag == _Tag.solSignRequest) {
      value = value.value;
    }
    if (value is! Map) {
      throw const AirGapProtocolException('Invalid signing request.');
    }
    final requestId = value[1] == null ? Uint8List(0) : _uuid(value[1]);
    final signData = value[2];
    final rawAddress = value[4];
    final address = rawAddress is Uint8List && rawAddress.length == 32
        ? rawAddress
        : null;
    final typeCode = value[6] is int ? value[6] as int : 1;
    final signType = AirGapSignType.fromCode(typeCode);
    if (signType == null) {
      throw const AirGapProtocolException('Unsupported request type.');
    }
    if (signData is! Uint8List ||
        signData.isEmpty ||
        signData.length > maxSignDataLength) {
      throw const AirGapProtocolException('Invalid data to sign.');
    }
    final hints = value[101];
    final tables = value[102];
    return AirGapSignRequest(
      requestId: requestId,
      signData: signData,
      path: AirGapKeyPath.fromCbor(value[3]),
      sourceFingerprint: AirGapKeyPath.sourceFingerprintOf(value[3]),
      address: address,
      signType: signType,
      origin: value[5] is String ? value[5] as String : '',
      protocolVersion: value[100] is int ? value[100] as int : 0,
      tokenHints: hints is List
          ? hints.map(AirGapTokenHint.fromCbor).nonNulls.toList()
          : const [],
      lookupTables: tables is List
          ? tables.map(AirGapLookupTable.fromCbor).nonNulls.toList()
          : const [],
      swapSummary: AirGapSwapSummary.fromCbor(value[103]),
      usdPrices: _usdPrices(value[104]),
      recipient: AirGapRecipient.fromCbor(value[105]),
    );
  }

  /// Plain decimal, optionally with the exponent Dart's double.toString
  /// writes for tiny prices (1e-7); no sign, padding, hex or NaN.
  static final _pricePattern = RegExp(
    r'^[0-9]{1,20}(\.[0-9]{1,20})?(e-?[0-9]{1,3})?$',
  );

  /// Higher would only overflow the USD value shown for an amount.
  static const maxUsdPrice = 1e9;

  static Map<String, double> _usdPrices(Object? value) {
    final prices = <String, double>{};
    if (value is! List) {
      return prices;
    }
    for (final entry in value) {
      if (entry is! List ||
          entry.length != 2 ||
          entry[0] is! Uint8List ||
          (entry[0] as Uint8List).length != 32 ||
          entry[1] is! String) {
        continue;
      }
      final text = entry[1] as String;
      final price = _pricePattern.hasMatch(text) ? double.parse(text) : null;
      if (price != null &&
          price.isFinite &&
          price > 0 &&
          price <= maxUsdPrice) {
        prices[base58encode(entry[0] as Uint8List)] = price;
      }
    }
    return prices;
  }
}

class AirGapSignature {
  const AirGapSignature({
    required this.requestId,
    required this.signature,
    this.signerInfo,
  });

  final Uint8List requestId;

  /// 64-byte ed25519 signature.
  final Uint8List signature;
  final AirGapSignerInfo? signerInfo;

  Ur toUr() => Ur(
    AirGapUrType.signature,
    Cbor.encode({
      if (requestId.isNotEmpty) 1: CborTag(_Tag.uuid, requestId),
      2: signature,
      if (signerInfo != null) 100: signerInfo!.toCbor(),
    }),
  );

  static AirGapSignature fromUr(Ur ur) {
    if (ur.type != AirGapUrType.signature) {
      throw const AirGapProtocolException('Not a signature.');
    }
    var value = Cbor.decode(ur.cbor);
    if (value is CborTag && value.tag == _Tag.solSignature) {
      value = value.value;
    }
    if (value is! Map) {
      throw const AirGapProtocolException('Invalid signature.');
    }
    final signature = value[2];
    if (signature is! Uint8List || signature.length != 64) {
      throw const AirGapProtocolException('Invalid signature.');
    }
    return AirGapSignature(
      requestId: _uuid(value[1]),
      signature: signature,
      signerInfo: AirGapSignerInfo.fromCbor(value[100]),
    );
  }
}

Uint8List _uuid(Object? value) {
  final raw = value is CborTag && value.tag == _Tag.uuid ? value.value : value;
  if (raw is! Uint8List || raw.length != 16) {
    throw const AirGapProtocolException('Invalid request id.');
  }
  return raw;
}

bool sameBytes(List<int> a, List<int> b) {
  if (a.length != b.length) {
    return false;
  }
  var diff = 0;
  for (var i = 0; i < a.length; i++) {
    diff |= a[i] ^ b[i];
  }
  return diff == 0;
}
