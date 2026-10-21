import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reown_walletkit/reown_walletkit.dart';
import 'package:solana/base58.dart';

import '../../../app/di/providers.dart';
import '../../../core/walletconnect/dapp_review.dart';
import '../../../core/walletconnect/raw_transaction.dart';
import '../../../core/walletconnect/solana_wc_request.dart';
import '../../auth/presentation/providers/wallet_controller.dart';
import 'dapp_connect_service.dart';
import 'session_namespaces.dart';

/// Benny as a Mobile Wallet Adapter wallet for dApps on this phone. The
/// Android side (MwaActivity) runs the MWA session and hands each request
/// over; this turns them into the same [DappProposal] / [DappRequest] the
/// WalletConnect pages review, and sends the answers back.
class MwaWalletService implements DappResponder {
  MwaWalletService(this._ref) {
    _channel.setMethodCallHandler(_onCall);
  }

  static const _channel = MethodChannel('benny_wallet/mwa_wallet');

  /// Set at startup: this app instance was opened by a dApp to sign.
  static bool isWalletActivity = false;

  /// Whether this instance runs in the MWA activity (Android only).
  static Future<bool> detect() async {
    if (kIsWeb || !Platform.isAndroid) {
      return false;
    }
    try {
      return await _channel.invokeMethod<bool>('hello') ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  final Ref _ref;

  @override
  DappChannel get channel => DappChannel.phoneApp;

  final _proposals = StreamController<DappProposal>.broadcast();
  final _requests = StreamController<DappRequest>.broadcast();

  /// Ids the Android side still waits on.
  final _open = <int>{};

  /// Authorize requests that asked for Sign In With Solana, by id.
  final _signInFor = <int>{};

  /// Sign-in message requests, by their own id: the authorize id and the
  /// address it answers for.
  final _signInRequests = <int, ({int authorizeId, String address})>{};

  /// Requests whose transactions are sent after signing (several at once).
  final _sendAfterSigning = <int>{};

  /// Ids for requests made here (sign-in messages); negative so they never
  /// clash with the Android side's.
  int _localId = -1;

  Stream<DappProposal> get proposals => _proposals.stream;
  Stream<DappRequest> get requests => _requests.stream;

  /// Tells the Android side it may hand over requests.
  Future<void> ready() async {
    if (!isWalletActivity) {
      return;
    }
    try {
      await _channel.invokeMethod<bool>('ready');
    } on Object {
      // Not the wallet activity after all.
    }
  }

  Future<dynamic> _onCall(MethodCall call) async {
    final args = call.arguments is Map
        ? Map<String, Object?>.from(call.arguments as Map)
        : const <String, Object?>{};
    switch (call.method) {
      case 'authorize':
        _onAuthorize(args);
      case 'request':
        _onRequest(args);
      case 'closed':
        _open.clear();
        _signInRequests.clear();
    }
    return null;
  }

  static PairingMetadata _peer(Map<String, Object?> args) {
    final uri = args['uri'] as String? ?? '';
    final name = (args['name'] as String?)?.trim();
    final icon = args['icon'] as String?;
    return PairingMetadata(
      name: name == null || name.isEmpty
          ? (DappReviewer.hostOf(uri) ?? '')
          : name,
      description: '',
      url: uri,
      icons: [if (icon != null && icon.startsWith('https://')) icon],
    );
  }

  void _onAuthorize(Map<String, Object?> args) {
    final id = args['id']! as int;
    _open.add(id);
    if (args['signIn'] == true) {
      _signInFor.add(id);
    }
    _proposals.add(
      DappProposal(
        id: id,
        peer: _peer(args),
        chains: ProposalChains.fromMwaChain(args['chain'] as String?),
        // A dApp on this phone cannot be verified; its name and site are
        // its own claim.
        site: SiteCheck.unknown,
        origin: args['uri'] as String?,
        via: this,
      ),
    );
  }

  void _onRequest(Map<String, Object?> args) {
    final id = args['id']! as int;
    _open.add(id);
    final address = base58encode(args['address']! as Uint8List);
    final payloads = [
      for (final p in args['payloads']! as List) p as Uint8List,
    ];
    final (method, params) = switch (args['kind']) {
      'signMessages' => (
        SolanaWc.signMessage,
        <String, Object>{
          'message': base58encode(payloads.single),
          'pubkey': address,
        },
      ),
      'signAndSend' when payloads.length == 1 => (
        SolanaWc.signAndSendTransaction,
        <String, Object>{'transaction': base64Encode(payloads.single)},
      ),
      _ when payloads.length == 1 => (
        SolanaWc.signTransaction,
        <String, Object>{'transaction': base64Encode(payloads.single)},
      ),
      _ => (
        SolanaWc.signAllTransactions,
        <String, Object>{
          'transactions': [for (final p in payloads) base64Encode(p)],
        },
      ),
    };
    if (args['kind'] == 'signAndSend' && payloads.length > 1) {
      _sendAfterSigning.add(id);
    }
    _requests.add(_request(id, method, params, address, args));
  }

  DappRequest _request(
    int id,
    String method,
    Map<String, Object> params,
    String address,
    Map<String, Object?> identity,
  ) => DappRequest(
    id: id,
    topic: 'mwa',
    method: method,
    chainId: SolanaWc.mainnet,
    params: params,
    address: address,
    peer: _peer(identity),
    site: SiteCheck.unknown,
    origin: identity['uri'] as String?,
    // When the dApp asked, not when it was handed over after unlocking:
    // its MWA client counts from then.
    receivedAt: switch (identity['receivedAt']) {
      final int ms => DateTime.fromMillisecondsSinceEpoch(ms),
      _ => DateTime.now(),
    },
    via: this,
  );

  @override
  bool isProposalPending(DappProposal proposal) => _open.contains(proposal.id);

  @override
  bool isRequestPending(DappRequest request) =>
      _open.contains(request.id) || _signInRequests.containsKey(request.id);

  @override
  Future<void> approve(DappProposal proposal, String address) async {
    final publicKey = Uint8List.fromList(base58decode(address));
    if (_signInFor.remove(proposal.id)) {
      // Sign In With Solana: the connection is answered once the sign-in
      // message is signed (or refused) on its own review page.
      final message = await _channel.invokeMethod<String>('signInMessage', {
        'id': proposal.id,
        'address': publicKey,
      });
      if (message != null) {
        final id = _localId--;
        _signInRequests[id] = (authorizeId: proposal.id, address: address);
        _requests.add(
          _request(
            id,
            SolanaWc.signMessage,
            {'message': base58encode(utf8.encode(message)), 'pubkey': address},
            address,
            {'name': proposal.peer.name, 'uri': proposal.peer.url},
          ),
        );
        return;
      }
    }
    await _authorize(proposal.id, publicKey, address);
  }

  Future<void> _authorize(
    int id,
    Uint8List publicKey,
    String address, {
    Uint8List? signedMessage,
    Uint8List? signature,
  }) async {
    final wallets = _ref.read(walletControllerProvider).wallets;
    final label = wallets
        .where((w) => w.publicKey == address)
        .map((w) => w.name)
        .firstOrNull;
    _open.remove(id);
    await _channel.invokeMethod<bool>('authorize', {
      'id': id,
      'decision': 'approve',
      'publicKey': publicKey,
      'label': label,
      if (signedMessage != null) 'signedMessage': signedMessage,
      if (signature != null) 'signature': signature,
    });
  }

  @override
  Future<void> reject(DappProposal proposal, {bool unsupported = false}) async {
    _open.remove(proposal.id);
    _signInFor.remove(proposal.id);
    await _channel.invokeMethod<bool>('authorize', {
      'id': proposal.id,
      'decision': unsupported ? 'unsupportedChain' : 'decline',
    });
  }

  @override
  Future<void> respond(DappRequest request, Object result) async {
    final signIn = _signInRequests.remove(request.id);
    if (signIn != null) {
      final signature = _signatureOf(result);
      final message = base58decode(
        (request.params! as Map)['message']! as String,
      );
      await _authorize(
        signIn.authorizeId,
        Uint8List.fromList(base58decode(signIn.address)),
        signIn.address,
        signedMessage: Uint8List.fromList(message),
        signature: signature,
      );
      return;
    }
    _open.remove(request.id);
    final map = result as Map;
    switch (request.method) {
      case SolanaWc.signMessage:
        // MWA returns each message with its signature appended.
        final message = base58decode(
          (request.params! as Map)['message']! as String,
        );
        await _complete(request.id, 'signed', [
          Uint8List.fromList([...message, ..._signatureOf(result)]),
        ]);
      case SolanaWc.signTransaction:
        await _complete(request.id, 'signed', [
          base64Decode(map['transaction']! as String),
        ]);
      case SolanaWc.signAndSendTransaction:
        await _complete(request.id, 'signed', [
          Uint8List.fromList(base58decode(map['signature']! as String)),
        ]);
      case SolanaWc.signAllTransactions:
        final signed = [
          for (final t in map['transactions']! as List)
            base64Decode(t as String),
        ];
        if (_sendAfterSigning.remove(request.id)) {
          await _sendAll(request, signed);
        } else {
          await _complete(request.id, 'signed', signed);
        }
    }
  }

  /// Sends signed transactions in order and answers with their signatures;
  /// when one fails, the rest are not sent and the dApp is told which.
  Future<void> _sendAll(DappRequest request, List<Uint8List> signed) async {
    final solana = _ref.read(solanaWalletServiceProvider);
    final signatures = <Uint8List>[];
    for (final transaction in signed) {
      final parsed = RawTransaction.parse(transaction);
      signatures.add(
        parsed.signatureAt(parsed.signerIndex(request.address)!) ??
            Uint8List(64),
      );
    }
    for (final transaction in signed) {
      try {
        await solana.broadcastSignedTransaction(transaction);
      } on Object {
        await _complete(request.id, 'notSubmitted', signatures);
        rethrow;
      }
    }
    await _complete(request.id, 'signed', signatures);
  }

  static Uint8List _signatureOf(Object result) =>
      Uint8List.fromList(base58decode((result as Map)['signature']! as String));

  Future<void> _complete(int id, String outcome, List<Uint8List> payloads) =>
      _channel.invokeMethod<bool>('complete', {
        'id': id,
        'outcome': outcome,
        'payloads': payloads,
      });

  @override
  Future<void> refuse(
    DappRequest request, {
    String error = Errors.USER_REJECTED_SIGN,
    String? message,
  }) async {
    final signIn = _signInRequests.remove(request.id);
    if (signIn != null) {
      await _channel.invokeMethod<bool>('authorize', {
        'id': signIn.authorizeId,
        'decision': 'decline',
      });
      return;
    }
    _open.remove(request.id);
    _sendAfterSigning.remove(request.id);
    await _channel.invokeMethod<bool>('complete', {
      'id': request.id,
      'outcome': 'decline',
    });
  }

  void dispose() {
    _proposals.close();
    _requests.close();
  }
}

final mwaWalletServiceProvider = Provider<MwaWalletService>((ref) {
  final service = MwaWalletService(ref);
  ref.onDispose(service.dispose);
  return service;
});
