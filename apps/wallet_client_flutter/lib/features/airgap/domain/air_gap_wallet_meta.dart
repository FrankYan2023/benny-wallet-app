import 'dart:convert';

import '../../../core/airgap/airgap_protocol.dart';

/// What the wallet keeps about the signer behind an air-gapped account. The
/// signer info is refreshed from signatures, but only upwards (see
/// [acceptSignerInfo]): that block is not covered by any signature.
class AirGapWalletMeta {
  const AirGapWalletMeta({
    required this.masterFingerprint,
    required this.deviceName,
    required this.signerInfo,
  });

  final int masterFingerprint;
  final String deviceName;
  final AirGapSignerInfo signerInfo;

  bool supports(String capability) =>
      signerInfo.capabilities.contains(capability);

  /// The meta to store after a signature QR carried [info], or null to keep
  /// this one. The block is unauthenticated (anyone can edit it in the QR),
  /// so it may only keep or raise what was stored at pairing: no lower
  /// protocol / token-list / app version and no dropped capability (e.g.
  /// lookupTables or tokenHints). A signer that really went back to an older
  /// version is picked up by pairing again.
  AirGapWalletMeta? acceptSignerInfo(AirGapSignerInfo info) {
    final stored = signerInfo;
    final keepsOrRaises =
        info.protocolVersion >= stored.protocolVersion &&
        info.tokenListVersion >= stored.tokenListVersion &&
        info.capabilities.containsAll(stored.capabilities) &&
        !(stored.appVersion.isNotEmpty &&
            (info.appVersion.isEmpty ||
                isOlderVersion(info.appVersion, stored.appVersion)));
    if (!keepsOrRaises) {
      return null;
    }
    final unchanged =
        info.protocolVersion == stored.protocolVersion &&
        info.tokenListVersion == stored.tokenListVersion &&
        info.capabilities.length == stored.capabilities.length &&
        info.appVersion == stored.appVersion;
    return unchanged ? null : withSignerInfo(info);
  }

  AirGapWalletMeta withSignerInfo(AirGapSignerInfo info) => AirGapWalletMeta(
    masterFingerprint: masterFingerprint,
    deviceName: deviceName,
    signerInfo: info,
  );

  String encode() => jsonEncode({
    'fingerprint': masterFingerprint,
    'deviceName': deviceName,
    'signerInfo': signerInfo.toJson(),
  });

  static AirGapWalletMeta parse(String raw) {
    if (raw.isEmpty) {
      return const AirGapWalletMeta(
        masterFingerprint: 0,
        deviceName: '',
        signerInfo: AirGapSignerInfo(
          appVersion: '',
          protocolVersion: 0,
          tokenListVersion: 0,
          capabilities: {AirGapCapability.signTransaction},
        ),
      );
    }
    final json = Map<String, dynamic>.from(jsonDecode(raw) as Map);
    return AirGapWalletMeta(
      masterFingerprint: (json['fingerprint'] as num?)?.toInt() ?? 0,
      deviceName: json['deviceName'] as String? ?? '',
      signerInfo: AirGapSignerInfo.fromJson(
        Map<String, dynamic>.from(json['signerInfo'] as Map? ?? const {}),
      ),
    );
  }
}

/// True when [a] is an older dotted version than [b] ("0.1.0" < "0.1.2").
bool isOlderVersion(String a, String b) {
  List<int> parts(String v) =>
      v.split('+').first.split('.').map((p) => int.tryParse(p) ?? 0).toList();
  final left = parts(a);
  final right = parts(b);
  for (var i = 0; i < 3; i++) {
    final l = i < left.length ? left[i] : 0;
    final r = i < right.length ? right[i] : 0;
    if (l != r) {
      return l < r;
    }
  }
  return false;
}
