import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reown_walletkit/reown_walletkit.dart';
import 'package:solana/base58.dart';

import '../../../app/di/providers.dart';
import '../../../app/router.dart';
import '../../../core/walletconnect/dapp_review.dart';
import '../../../core/walletconnect/raw_transaction.dart';
import '../../../core/walletconnect/solana_wc_request.dart';
import '../../auth/presentation/providers/wallet_controller.dart';
import '../presentation/pages/dapp_proposal_page.dart';
import '../presentation/pages/dapp_request_page.dart';
import 'browser_connections.dart';
import 'dapp_blocklist.dart';
import 'dapp_connect_service.dart';
import 'dapp_signer.dart';
import 'session_namespaces.dart';

/// The page a request comes from, as the browser sees it (never as the
/// page claims).
typedef BrowserPage = ({Uri url, String? title, String? icon});

/// Answers the wallet provider Benny's browser injects into each page:
/// connect, disconnect and the signing requests, each reviewed on the same
/// pages as WalletConnect. One bridge per browser page.
class BrowserWalletBridge implements DappResponder {
  BrowserWalletBridge(this._read, {required this.currentPage});

  /// Reads providers (a widget's ref.read).
  final T Function<T>(ProviderListenable<T> provider) _read;

  /// Reads the page on screen when a request arrives.
  final Future<BrowserPage?> Function() currentPage;

  @override
  DappChannel get channel => DappChannel.browser;

  int _nextId = 1;
  final _proposals = <int, Completer<String?>>{};
  final _requests = <int, Completer<Map<String, Object?>?>>{};
  final _requestHosts = <int, String>{};
  final _sendAfterSigning = <int>{};

  BrowserConnections get _connections => _read(browserConnectionsProvider);

  /// Handles one call from the page; returns {result} or {error, code}.
  Future<Map<String, Object?>> handle(Object? raw) async {
    final call = raw is Map ? raw : const {};
    final method = call['method'];
    final params = call['params'] is Map
        ? Map<String, Object?>.from(call['params'] as Map)
        : const <String, Object?>{};
    final page = await currentPage();
    if (page == null || !_isWebOrigin(page.url)) {
      return _error('This page cannot connect to a wallet.', 4100);
    }
    try {
      switch (method) {
        case 'connect':
          return await _connect(page, silent: params['silent'] == true);
        case 'disconnect':
          await _connections.remove(page.url.host);
          return {'result': true};
        case 'signTransactions':
        case 'signAndSendTransactions':
        case 'signMessage':
          return await _sign(page, method as String, params);
        default:
          return _error('Unsupported request.', 4200);
      }
    } on Object catch (error) {
      return _error(error.toString(), 4001);
    }
  }

  static bool _isWebOrigin(Uri url) =>
      url.scheme == 'https' ||
      (url.scheme == 'http' &&
          (url.host == 'localhost' || url.host == '127.0.0.1'));

  static Map<String, Object?> _error(String message, int code) => {
    'error': message,
    'code': code,
  };

  PairingMetadata _peer(BrowserPage page) => PairingMetadata(
    name: (page.title ?? '').trim().isEmpty ? page.url.host : page.title!,
    description: '',
    url: page.url.origin,
    icons: [if (page.icon case final i? when i.startsWith('https://')) i],
  );

  /// Accounts the page may see: the approved wallet, if it still exists.
  Future<Map<String, Object?>?> _account(String address) async {
    final wallets = _read(walletControllerProvider).wallets;
    final wallet = wallets.where((w) => w.publicKey == address).firstOrNull;
    if (wallet == null || !canConnectDapps(wallet.custody)) {
      return null;
    }
    return {
      'address': address,
      'publicKey': base64Encode(base58decode(address)),
      'label': wallet.name,
    };
  }

  Future<Map<String, Object?>> _connect(
    BrowserPage page, {
    required bool silent,
  }) async {
    final host = page.url.host;
    final blocklist = await _read(dappBlocklistProvider).refresh();
    if (blocklist.blocksHost(host)) {
      return _error('This site is blocked.', 4100);
    }
    final active = _read(walletControllerProvider).publicKey;
    var existing = await _connections.find(host);
    // Connected with another wallet before the user switched: ask again
    // for the wallet selected now.
    if (existing != null && existing.address != active) {
      await _connections.remove(host);
      existing = null;
    }
    if (existing != null) {
      final account = await _account(existing.address);
      if (account != null) {
        await _connections.touch(host, url: page.url.toString());
        return {'result': account};
      }
      await _connections.remove(host);
    }
    if (silent) {
      return _error('Not connected.', 4100);
    }
    final id = _nextId++;
    final completer = Completer<String?>();
    _proposals[id] = completer;
    final proposal = DappProposal(
      id: id,
      peer: _peer(page),
      chains: ProposalChains.fromMwaChain(null),
      // The host is read by the browser itself, so it is the real site.
      site: page.url.scheme == 'https' ? SiteCheck.verified : SiteCheck.unknown,
      origin: page.url.origin,
      via: this,
    );
    try {
      await AppRouter.router.push<bool>(
        DappProposalPage.routePath,
        extra: proposal,
      );
    } on Object {
      // Closed: answered below as rejected.
    }
    if (!completer.isCompleted) {
      completer.complete(null);
    }
    _proposals.remove(id);
    final address = await completer.future;
    if (address == null) {
      return _error('The user rejected the request.', 4001);
    }
    await _connections.save(
      BrowserConnection(
        host: host,
        url: page.url.toString(),
        name: proposal.peer.name,
        icon: proposal.peer.icons.firstOrNull,
        address: address,
        connectedAt: DateTime.now(),
        lastUsed: DateTime.now(),
      ),
    );
    return {'result': await _account(address)};
  }

  Future<Map<String, Object?>> _sign(
    BrowserPage page,
    String method,
    Map<String, Object?> params,
  ) async {
    final connection = await _connections.find(page.url.host);
    if (connection == null || await _account(connection.address) == null) {
      return _error('Connect the wallet first.', 4100);
    }
    if (connection.address != _read(walletControllerProvider).publicKey) {
      await _connections.remove(page.url.host);
      return _error('The wallet was switched. Connect again.', 4100);
    }
    final address = connection.address;
    final (wcMethod, wcParams) = switch (method) {
      'signMessage' => (
        SolanaWc.signMessage,
        <String, Object>{
          'message': base58encode(base64Decode(params['message']! as String)),
          'pubkey': address,
        },
      ),
      _ => () {
        final txs = [
          for (final t in params['transactions']! as List) t as String,
        ];
        if (method == 'signAndSendTransactions' && txs.length == 1) {
          return (
            SolanaWc.signAndSendTransaction,
            <String, Object>{'transaction': txs.single},
          );
        }
        if (txs.length == 1) {
          return (
            SolanaWc.signTransaction,
            <String, Object>{'transaction': txs.single},
          );
        }
        return (
          SolanaWc.signAllTransactions,
          <String, Object>{'transactions': txs},
        );
      }(),
    };
    final id = _nextId++;
    if (method == 'signAndSendTransactions' &&
        wcMethod == SolanaWc.signAllTransactions) {
      _sendAfterSigning.add(id);
    }
    final completer = Completer<Map<String, Object?>?>();
    _requests[id] = completer;
    _requestHosts[id] = page.url.host;
    final request = DappRequest(
      id: id,
      topic: 'browser',
      method: wcMethod,
      chainId: SolanaWc.mainnet,
      params: wcParams,
      address: address,
      peer: _peer(page),
      site: page.url.scheme == 'https' ? SiteCheck.verified : SiteCheck.unknown,
      origin: page.url.origin,
      receivedAt: DateTime.now(),
      via: this,
    );
    try {
      await AppRouter.router.push<bool>(
        DappRequestPage.routePath,
        extra: request,
      );
    } on Object {
      // Closed: answered below as rejected.
    }
    if (!completer.isCompleted) {
      completer.complete(null);
    }
    _requests.remove(id);
    _requestHosts.remove(id);
    _sendAfterSigning.remove(id);
    final result = await completer.future;
    if (result == null) {
      return _error('The user rejected the request.', 4001);
    }
    unawaited(_connections.touch(page.url.host));
    return {'result': result};
  }

  @override
  bool isProposalPending(DappProposal proposal) =>
      _proposals[proposal.id]?.isCompleted == false;

  @override
  bool isRequestPending(DappRequest request) =>
      _requests[request.id]?.isCompleted == false;

  @override
  Future<void> approve(DappProposal proposal, String address) async {
    final completer = _proposals[proposal.id];
    if (completer != null && !completer.isCompleted) {
      completer.complete(address);
    }
  }

  @override
  Future<void> reject(DappProposal proposal, {bool unsupported = false}) async {
    final completer = _proposals[proposal.id];
    if (completer != null && !completer.isCompleted) {
      completer.complete(null);
    }
  }

  @override
  Future<void> respond(DappRequest request, Object result) async {
    final completer = _requests[request.id];
    if (completer == null || completer.isCompleted) {
      return;
    }
    final map = result as Map;
    final Map<String, Object?> reply;
    switch (request.method) {
      case SolanaWc.signMessage:
        reply = {
          'signature': base64Encode(base58decode(map['signature']! as String)),
        };
      case SolanaWc.signTransaction:
        reply = {
          'transactions': [map['transaction']! as String],
        };
      case SolanaWc.signAndSendTransaction:
        final signature = map['signature']! as String;
        reply = {
          'signatures': [base64Encode(base58decode(signature))],
          'base58Signatures': [signature],
        };
      default:
        final signed = [
          for (final t in map['transactions']! as List) t as String,
        ];
        if (_sendAfterSigning.contains(request.id)) {
          reply = await _sendAll(request.address, signed);
        } else {
          reply = {'transactions': signed};
        }
    }
    completer.complete(reply);
  }

  /// Sends signed transactions in order and returns their signatures.
  Future<Map<String, Object?>> _sendAll(
    String address,
    List<String> signed,
  ) async {
    final solana = _read(solanaWalletServiceProvider);
    final signatures = <String>[];
    for (final encoded in signed) {
      final bytes = base64Decode(encoded);
      await solana.broadcastSignedTransaction(Uint8List.fromList(bytes));
      final parsed = RawTransaction.parse(bytes);
      final first = parsed.signatureAt(0) ?? Uint8List(64);
      signatures.add(base58encode(first));
    }
    return {
      'signatures': [for (final s in signatures) base64Encode(base58decode(s))],
      'base58Signatures': signatures,
    };
  }

  @override
  Future<void> refuse(
    DappRequest request, {
    String error = Errors.USER_REJECTED_SIGN,
    String? message,
  }) async {
    final completer = _requests[request.id];
    if (completer != null && !completer.isCompleted) {
      completer.complete(null);
    }
  }
}
