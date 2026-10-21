import 'dart:convert';
import 'dart:typed_data';

import 'package:solana/base58.dart';

import 'raw_transaction.dart';

/// Solana chains and methods Benny Wallet answers over WalletConnect.
abstract final class SolanaWc {
  static const namespace = 'solana';

  /// Mainnet by its genesis hash, and the shorter id older dApps still send.
  static const mainnet = 'solana:5eykt4UsFv8P8NJdTREpY1vzqKqZKvdp';
  static const mainnetLegacy = 'solana:4sGjMW1sUnHzSxGspuhpqLDx6wiyjNtZ';
  static const chains = [mainnet, mainnetLegacy];

  static const signMessage = 'solana_signMessage';
  static const signTransaction = 'solana_signTransaction';
  static const signAllTransactions = 'solana_signAllTransactions';
  static const signAndSendTransaction = 'solana_signAndSendTransaction';
  static const getAccounts = 'solana_getAccounts';
  static const requestAccounts = 'solana_requestAccounts';

  static const methods = [
    signMessage,
    signTransaction,
    signAllTransactions,
    signAndSendTransaction,
    getAccounts,
    requestAccounts,
  ];

  static const events = ['accountsChanged', 'chainChanged'];

  /// Methods that never need the user: they only read the approved address.
  static bool isAccountQuery(String method) =>
      method == getAccounts || method == requestAccounts;

  static bool isSupportedChain(String chainId) => chains.contains(chainId);

  /// "solana:<chain>:<address>" for each chain the dApp asked for.
  static List<String> accountsFor(String address, Iterable<String> chains) => [
    for (final chain in chains) '$chain:$address',
  ];
}

enum DappRequestKind { message, transaction, allTransactions, signAndSend }

/// A signing request from a dApp, decoded and checked before review.
class DappSignRequest {
  const DappSignRequest._({
    required this.kind,
    this.message,
    this.transactions = const [],
  });

  final DappRequestKind kind;

  /// The bytes to sign for [DappRequestKind.message].
  final Uint8List? message;

  /// The transactions to sign, as sent.
  final List<RawTransaction> transactions;

  /// Reads `params` of [method]; throws [FormatException] for anything that
  /// is not a well-formed request for [address] to sign.
  static DappSignRequest parse({
    required String method,
    required Object? params,
    required String address,
  }) {
    if (params is! Map) {
      throw const FormatException('Request parameters are missing.');
    }
    switch (method) {
      case SolanaWc.signMessage:
        final encoded = params['message'];
        if (encoded is! String || encoded.isEmpty) {
          throw const FormatException('Message is missing.');
        }
        final pubkey = params['pubkey'];
        if (pubkey is String && pubkey.isNotEmpty && pubkey != address) {
          throw const FormatException('Message is for another account.');
        }
        final bytes = Uint8List.fromList(base58decode(encoded));
        if (bytes.isEmpty) {
          throw const FormatException('Message is empty.');
        }
        return DappSignRequest._(kind: DappRequestKind.message, message: bytes);
      case SolanaWc.signTransaction:
      case SolanaWc.signAndSendTransaction:
        final transaction = _transaction(params['transaction'], address);
        return DappSignRequest._(
          kind: method == SolanaWc.signTransaction
              ? DappRequestKind.transaction
              : DappRequestKind.signAndSend,
          transactions: [transaction],
        );
      case SolanaWc.signAllTransactions:
        final list = params['transactions'];
        if (list is! List || list.isEmpty) {
          throw const FormatException('Transactions are missing.');
        }
        if (list.length > 20) {
          throw const FormatException('Too many transactions.');
        }
        return DappSignRequest._(
          kind: DappRequestKind.allTransactions,
          transactions: [for (final t in list) _transaction(t, address)],
        );
      default:
        throw FormatException('Unsupported method $method.');
    }
  }

  static RawTransaction _transaction(Object? encoded, String address) {
    if (encoded is! String || encoded.isEmpty) {
      throw const FormatException('Transaction is missing.');
    }
    final transaction = RawTransaction.parse(decodeTransaction(encoded));
    if (transaction.signerIndex(address) == null) {
      throw const FormatException('Transaction is not for this account.');
    }
    return transaction;
  }

  /// dApps send base64; a few older ones send base58.
  static Uint8List decodeTransaction(String encoded) {
    try {
      return base64Decode(encoded);
    } on FormatException {
      return Uint8List.fromList(base58decode(encoded));
    }
  }
}

/// The JSON-RPC `result` objects the WalletConnect Solana spec defines.
abstract final class DappSignResult {
  static Map<String, Object> message(Uint8List signature) => {
    'signature': base58encode(signature),
  };

  /// The signature alone keeps older dApps working; newer ones read the
  /// signed transaction.
  static Map<String, Object> transaction(
    Uint8List signedTransaction,
    Uint8List signature,
  ) => {
    'signature': base58encode(signature),
    'transaction': base64Encode(signedTransaction),
  };

  static Map<String, Object> allTransactions(List<Uint8List> signed) => {
    'transactions': [for (final t in signed) base64Encode(t)],
  };

  static Map<String, Object> sent(String transactionSignature) => {
    'signature': transactionSignature,
  };

  static List<Map<String, String>> accounts(String address) => [
    {'pubkey': address},
  ];
}
