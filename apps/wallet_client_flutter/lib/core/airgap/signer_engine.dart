import 'dart:convert';
import 'dart:typed_data';

import 'package:bip39/bip39.dart' as bip39;
import 'package:cryptography/dart.dart';
import 'package:solana/base58.dart';
import 'package:solana/solana.dart';

import 'airgap_protocol.dart';
import 'sign_in_message.dart';
import 'solana_message_parser.dart';
import 'token_registry.dart';

class SignerRejection implements Exception {
  const SignerRejection(this.reason);

  final SignerRejectReason reason;

  @override
  String toString() => 'SignerRejection: ${reason.name}';
}

enum SignerRejectReason {
  /// The request is for an account this signer does not have (wrong seed,
  /// or an account number not shown on this signer).
  unknownAccount,

  /// The request address is not a required signer of the transaction.
  notASigner,

  /// The bytes do not parse as a Solana message.
  unreadableTransaction,

  /// A "message" signature whose bytes are really a transaction.
  messageIsTransaction,
}

/// What the confirm screen shows for one request. Built only from the
/// request bytes and the signer's own data.
class SignerReview {
  SignerReview({
    required this.request,
    required this.account,
    this.transaction,
    this.messageText,
  });

  final AirGapSignRequest request;
  final AirGapAccount account;
  final ParsedSolanaMessage? transaction;

  /// UTF-8 text of a message request (null for transactions).
  final String? messageText;

  /// The message read as a "Sign in with Solana" login, if it is one.
  late final SolanaSignInMessage? signIn = messageText == null
      ? null
      : SolanaSignInMessage.parse(messageText!);

  String get signerAddress => base58encode(account.publicKey);

  bool get isTransaction => transaction != null;

  InstructionRisk get risk =>
      transaction?.highestRisk ?? InstructionRisk.notice;
}

/// The offline signing core: derives accounts from the seed, checks a
/// request against them, and signs. It never touches the network and never
/// returns key material, only public keys and signatures.
class SignerEngine {
  SignerEngine._(this._seed, this.accounts, this.masterFingerprint);

  final Uint8List _seed;

  /// Accounts shown on this signer.
  final List<AirGapAccount> accounts;
  final int masterFingerprint;
  final Map<String, Ed25519HDKeyPair> _keyPairs = {};

  static String accountPath(int index) => "m/44'/501'/$index'/0'";

  static Future<SignerEngine> fromMnemonic(
    String mnemonic, {
    required List<int> accountIndexes,
  }) async {
    final seed = Uint8List.fromList(bip39.mnemonicToSeed(mnemonic));
    final keyPairs = <String, Ed25519HDKeyPair>{};
    final accounts = <AirGapAccount>[];
    for (final index in accountIndexes) {
      final path = accountPath(index);
      final keyPair = await Ed25519HDKeyPair.fromSeedWithHdPath(
        seed: seed,
        hdPath: path,
      );
      keyPairs[path] = keyPair;
      accounts.add(
        AirGapAccount(
          publicKey: Uint8List.fromList(keyPair.publicKey.bytes),
          path: AirGapKeyPath.parse(path),
        ),
      );
    }
    // Fingerprint of the seed, from account 0 even when it is hidden.
    final first = await Ed25519HDKeyPair.fromSeedWithHdPath(
      seed: seed,
      hdPath: accountPath(0),
    );
    final digest = const DartSha256().hashSync(first.publicKey.bytes).bytes;
    final fingerprint =
        (digest[0] << 24) | (digest[1] << 16) | (digest[2] << 8) | digest[3];
    return SignerEngine._(seed, accounts, fingerprint)
      .._keyPairs.addAll(keyPairs);
  }

  /// Public account address for display.
  static Future<String> addressFor(String mnemonic, int index) async {
    final keyPair = await Ed25519HDKeyPair.fromMnemonic(
      mnemonic,
      account: index,
      change: 0,
    );
    return keyPair.publicKey.toBase58();
  }

  AirGapAccountsExport exportAccounts({
    required String deviceName,
    required AirGapSignerInfo info,
  }) {
    return AirGapAccountsExport(
      masterFingerprint: masterFingerprint,
      deviceName: deviceName,
      accounts: accounts,
      signerInfo: info,
    );
  }

  SignerReview review(AirGapSignRequest request) {
    // Keystone's rule: the path and the master fingerprint pick the key;
    // an address, when the wallet sends a readable one, must agree.
    final fingerprint = request.sourceFingerprint;
    final wanted = request.address;
    final account = fingerprint != null && fingerprint != masterFingerprint
        ? null
        : accounts
              .where(
                (a) =>
                    a.path == request.path &&
                    (wanted == null || sameBytes(a.publicKey, wanted)),
              )
              .firstOrNull;
    if (account == null) {
      throw const SignerRejection(SignerRejectReason.unknownAccount);
    }
    final address = base58encode(account.publicKey);
    switch (request.signType) {
      case AirGapSignType.transaction:
        final ParsedSolanaMessage parsed;
        try {
          parsed = SolanaMessageParser.parse(
            request.signData,
            lookupTables: request.lookupTables,
          );
        } on Object {
          throw const SignerRejection(SignerRejectReason.unreadableTransaction);
        }
        if (!parsed.requiredSigners.contains(address)) {
          throw const SignerRejection(SignerRejectReason.notASigner);
        }
        return SignerReview(
          request: request,
          account: account,
          transaction: parsed,
        );
      case AirGapSignType.message:
        if (SolanaMessageParser.looksLikeTransaction(request.signData)) {
          throw const SignerRejection(SignerRejectReason.messageIsTransaction);
        }
        return SignerReview(
          request: request,
          account: account,
          messageText: _utf8OrNull(request.signData),
        );
    }
  }

  /// Signs a request the user confirmed on screen.
  Future<AirGapSignature> sign(
    SignerReview review, {
    required AirGapSignerInfo info,
  }) async {
    final path = review.account.path.toString();
    final keyPair =
        _keyPairs[path] ??
        await Ed25519HDKeyPair.fromSeedWithHdPath(seed: _seed, hdPath: path);
    final signature = await keyPair.sign(review.request.signData);
    return AirGapSignature(
      requestId: review.request.requestId,
      signature: Uint8List.fromList(signature.bytes),
      // Only Benny Wallet reads our signer block; other wallets get the
      // plain registry layout.
      signerInfo: review.request.protocolVersion == 0 ? null : info,
    );
  }

  /// Clears the cached seed. The engine must not be used afterwards.
  void dispose() {
    _seed.fillRange(0, _seed.length, 0);
    _keyPairs.clear();
  }
}

String? _utf8OrNull(Uint8List bytes) {
  try {
    return const Utf8Decoder().convert(bytes);
  } on FormatException {
    return null;
  }
}

/// Amount in base units → decimal string, without float rounding.
String formatBaseUnits(BigInt amount, int decimals) {
  if (decimals <= 0) {
    return amount.toString();
  }
  final text = amount.toString().padLeft(decimals + 1, '0');
  final whole = text.substring(0, text.length - decimals);
  final fraction = text
      .substring(text.length - decimals)
      .replaceFirst(RegExp(r'0+$'), '');
  final grouped = whole.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (m) => '${m[1]},',
  );
  return fraction.isEmpty ? grouped : '$grouped.$fraction';
}

/// Convenience for the confirm screen.
ResolvedToken? resolveInstructionToken(
  ParsedInstruction instruction,
  TokenRegistry registry,
) {
  final mint = instruction.mint;
  return mint == null ? null : registry.resolve(mint);
}
