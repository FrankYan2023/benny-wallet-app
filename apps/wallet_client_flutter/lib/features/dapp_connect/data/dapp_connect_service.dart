import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reown_walletkit/reown_walletkit.dart';

import '../../../core/walletconnect/dapp_review.dart';
import '../../../core/walletconnect/solana_wc_request.dart';
import 'session_namespaces.dart';

/// Build-time settings. The project id is passed with
/// `--dart-define=REOWN_PROJECT_ID=...` and kept out of the source.
abstract final class DappConnectConfig {
  static const projectId = String.fromEnvironment('REOWN_PROJECT_ID');

  static bool get isConfigured => projectId.isNotEmpty;

  static const metadata = PairingMetadata(
    name: 'Benny Wallet',
    description: 'Self-custody Solana wallet',
    url: 'https://gobennyapp.com',
    icons: ['https://gobennyapp.com/benny_logo.png'],
    redirect: Redirect(native: 'bennywallet://'),
  );
}

/// Answers proposals and requests for one way of connecting: WalletConnect
/// ([DappConnectService]) or a dApp on this phone ([MwaWalletService]).
/// How a site reaches Benny.
enum DappChannel {
  /// A website, by QR code or link (WalletConnect).
  walletConnect,

  /// An app on this phone (Mobile Wallet Adapter).
  phoneApp,

  /// A page in Benny's own browser.
  browser,
}

abstract interface class DappResponder {
  DappChannel get channel;
  bool isProposalPending(DappProposal proposal);
  bool isRequestPending(DappRequest request);
  Future<void> approve(DappProposal proposal, String address);
  Future<void> reject(DappProposal proposal, {bool unsupported = false});
  Future<void> respond(DappRequest request, Object result);
  Future<void> refuse(
    DappRequest request, {
    String error = Errors.USER_REJECTED_SIGN,
    String? message,
  });
}

/// A connection request waiting for the user.
class DappProposal {
  const DappProposal({
    required this.id,
    required this.peer,
    required this.chains,
    required this.site,
    required this.origin,
    this.via,
  });

  final int id;
  final PairingMetadata peer;
  final ProposalChains chains;
  final SiteCheck site;

  /// The page the request came from, as Verify saw it.
  final String? origin;

  /// Who answers it; WalletConnect when null.
  final DappResponder? via;
}

/// A signing request waiting for the user.
class DappRequest {
  const DappRequest({
    required this.id,
    required this.topic,
    required this.method,
    required this.chainId,
    required this.params,
    required this.address,
    required this.peer,
    required this.site,
    required this.origin,
    required this.receivedAt,
    this.via,
  });

  final int id;
  final String topic;
  final String method;
  final String chainId;
  final Object? params;

  /// The wallet the session is approved for.
  final String address;
  final PairingMetadata peer;
  final SiteCheck site;
  final String? origin;
  final DateTime receivedAt;

  /// Who answers it; WalletConnect when null.
  final DappResponder? via;

  /// The host the request is attributed to: Verify's origin, else the
  /// dApp's own claim.
  String? get siteHost =>
      DappReviewer.hostOf(origin) ?? DappReviewer.hostOf(peer.url);
}

/// WalletConnect for the wallet side: pairing, sessions and requests. Pages
/// read [proposals], [requests] and [sessions]; nothing here signs.
class DappConnectService implements DappResponder {
  DappConnectService({Future<ReownWalletKit> Function()? create})
    : _create = create ?? _defaultCreate;

  final Future<ReownWalletKit> Function() _create;
  ReownWalletKit? _kit;
  Future<ReownWalletKit>? _starting;

  final _proposals = StreamController<DappProposal>.broadcast();
  final _requests = StreamController<DappRequest>.broadcast();

  /// Approved connections, newest first.
  final sessions = ValueNotifier<List<SessionData>>(const []);

  /// Proposals and requests that arrived before anyone listened.
  final _pendingProposals = <DappProposal>[];
  final _pendingRequests = <DappRequest>[];

  Stream<DappProposal> get proposals => _proposals.stream;
  Stream<DappRequest> get requests => _requests.stream;

  bool get isAvailable => DappConnectConfig.isConfigured;

  @override
  DappChannel get channel => DappChannel.walletConnect;

  static Future<ReownWalletKit> _defaultCreate() {
    return ReownWalletKit.createInstance(
      projectId: DappConnectConfig.projectId,
      metadata: DappConnectConfig.metadata,
    );
  }

  /// Starts WalletConnect once; later calls return the same instance.
  Future<ReownWalletKit> start() {
    final kit = _kit;
    if (kit != null) {
      return Future.value(kit);
    }
    return _starting ??= _start();
  }

  Future<ReownWalletKit> _start() async {
    if (!isAvailable) {
      throw StateError('WalletConnect is not configured in this build.');
    }
    try {
      final kit = await _create();
      kit.onSessionProposal.subscribe(_onProposal);
      kit.onSessionRequest.subscribe(_onRequest);
      kit.onSessionConnect.subscribe((_) => _refreshSessions());
      kit.onSessionDelete.subscribe((_) => _refreshSessions());
      kit.onSessionExpire.subscribe((_) => _refreshSessions());
      _kit = kit;
      _refreshSessions();
      // Requests that arrived while the app was closed.
      for (final request in kit.getPendingSessionRequests().values) {
        _onRequest(SessionRequestEvent.fromSessionRequest(request));
      }
      return kit;
    } catch (_) {
      _starting = null;
      rethrow;
    }
  }

  /// Registers this phone's push [token] with Reown's push server, so a
  /// website's request wakes the phone while the app is closed. Done once
  /// per token and WalletConnect client ([alreadyRegistered] / [remember]
  /// keep track); needs push enabled for the project in Reown Cloud.
  Future<void> registerPush(
    String token, {
    required Future<bool> Function(String key) alreadyRegistered,
    required Future<void> Function(String key) remember,
  }) async {
    final kit = await start();
    final key = '${await kit.core.crypto.getClientId()}:$token';
    if (await alreadyRegistered(key)) {
      return;
    }
    await kit.core.echo.register(token);
    await remember(key);
  }

  /// Pairs with a `wc:` URI from a QR code or link.
  Future<void> pair(String uri) async {
    final parsed = Uri.tryParse(uri.trim());
    if (parsed == null || parsed.scheme != 'wc') {
      throw const FormatException('Not a WalletConnect link.');
    }
    final kit = await start();
    await kit.pair(uri: parsed);
  }

  /// Takes the proposals and requests waiting since before [proposals] and
  /// [requests] had a listener.
  (List<DappProposal>, List<DappRequest>) takePending() {
    final pending = (List.of(_pendingProposals), List.of(_pendingRequests));
    _pendingProposals.clear();
    _pendingRequests.clear();
    return pending;
  }

  /// Whether [proposal] still waits for an answer (not expired or answered).
  @override
  bool isProposalPending(DappProposal proposal) =>
      _kit?.proposals.get(proposal.id.toString()) != null;

  /// Whether [request] still waits for an answer (not expired or answered).
  @override
  bool isRequestPending(DappRequest request) =>
      _kit?.pendingRequests.get(request.id.toString()) != null;

  @override
  Future<void> approve(DappProposal proposal, String address) async {
    final kit = await start();
    await kit.approveSession(
      id: proposal.id,
      namespaces: proposal.chains.namespacesFor(address),
    );
    _refreshSessions();
  }

  @override
  Future<void> reject(DappProposal proposal, {bool unsupported = false}) async {
    final kit = await start();
    await kit.rejectSession(
      id: proposal.id,
      reason: Errors.getSdkError(
        unsupported ? Errors.UNSUPPORTED_CHAINS : Errors.USER_REJECTED,
      ).toSignError(),
    );
  }

  @override
  Future<void> respond(DappRequest request, Object result) async {
    final kit = await start();
    await kit.respondSessionRequest(
      topic: request.topic,
      response: JsonRpcResponse(id: request.id, jsonrpc: '2.0', result: result),
    );
  }

  /// Answers [request] with an error: the user said no by default.
  @override
  Future<void> refuse(
    DappRequest request, {
    String error = Errors.USER_REJECTED_SIGN,
    String? message,
  }) async {
    final kit = await start();
    final sdkError = Errors.getSdkError(error);
    await kit.respondSessionRequest(
      topic: request.topic,
      response: JsonRpcResponse(
        id: request.id,
        jsonrpc: '2.0',
        error: JsonRpcError(
          code: sdkError.code,
          message: message ?? sdkError.message,
        ),
      ),
    );
  }

  Future<void> disconnect(String topic) async {
    final kit = await start();
    try {
      await kit.disconnectSession(
        topic: topic,
        reason: Errors.getSdkError(Errors.USER_DISCONNECTED).toSignError(),
      );
    } finally {
      _refreshSessions();
    }
  }

  /// Ends every session for [address], or all sessions when null.
  Future<void> disconnectAll({String? address}) async {
    if (_kit == null && !isAvailable) {
      return;
    }
    final kit = await start();
    for (final session in kit.sessions.getAll()) {
      if (address == null || sessionAddress(session) == address) {
        try {
          await kit.disconnectSession(
            topic: session.topic,
            reason: Errors.getSdkError(Errors.USER_DISCONNECTED).toSignError(),
          );
        } on Object {
          // Already gone on the dApp's side.
        }
      }
    }
    _refreshSessions();
  }

  void _refreshSessions() {
    final kit = _kit;
    if (kit == null) {
      return;
    }
    final all = kit.sessions.getAll()
      ..sort((a, b) => b.expiry.compareTo(a.expiry));
    sessions.value = List.unmodifiable(all);
  }

  static SiteCheck _site(VerifyContext? context) {
    if (context == null) {
      return SiteCheck.unknown;
    }
    if (context.isScam == true || context.validation == Validation.SCAM) {
      return SiteCheck.scam;
    }
    return switch (context.validation) {
      Validation.VALID => SiteCheck.verified,
      Validation.INVALID => SiteCheck.mismatch,
      Validation.SCAM => SiteCheck.scam,
      Validation.UNKNOWN => SiteCheck.unknown,
    };
  }

  void _onProposal(SessionProposalEvent? event) {
    if (event == null) {
      return;
    }
    final proposal = DappProposal(
      id: event.id,
      peer: event.params.proposer.metadata,
      chains: ProposalChains.read(
        required: event.params.requiredNamespaces,
        optional: event.params.optionalNamespaces,
      ),
      site: _site(event.verifyContext),
      origin: event.verifyContext?.origin,
    );
    if (_proposals.hasListener) {
      _proposals.add(proposal);
    } else {
      _pendingProposals.add(proposal);
    }
  }

  void _onRequest(SessionRequestEvent? event) {
    final kit = _kit;
    if (event == null || kit == null) {
      return;
    }
    final session = kit.sessions.get(event.topic);
    final address = session == null ? null : sessionAddress(session);
    if (session == null || address == null) {
      return;
    }
    final verify = kit.pendingRequests.get(event.id.toString())?.verifyContext;
    final request = DappRequest(
      id: event.id,
      topic: event.topic,
      method: event.method,
      chainId: event.chainId,
      params: event.params,
      address: address,
      peer: session.peer.metadata,
      site: _site(verify),
      origin: verify?.origin,
      receivedAt: DateTime.now(),
    );
    // Reading the approved address needs no one's approval.
    if (SolanaWc.isAccountQuery(request.method)) {
      unawaited(
        respond(request, DappSignResult.accounts(address)).catchError((_) {}),
      );
      return;
    }
    if (_requests.hasListener) {
      _requests.add(request);
    } else {
      _pendingRequests.add(request);
    }
  }

  void dispose() {
    _proposals.close();
    _requests.close();
    sessions.dispose();
  }
}

final dappConnectServiceProvider = Provider<DappConnectService>((ref) {
  final service = DappConnectService();
  ref.onDispose(service.dispose);
  return service;
});
