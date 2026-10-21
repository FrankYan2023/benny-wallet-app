import 'dart:async';
import 'dart:collection';

import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reown_walletkit/reown_walletkit.dart';

import '../../../app/di/providers.dart';
import '../../../app/router.dart';
import '../../../l10n/l10n.dart';
import '../../auth/domain/wallet_controller_state.dart';
import '../../auth/presentation/providers/wallet_controller.dart';
import '../data/browser_connections.dart';
import '../data/dapp_blocklist.dart';
import '../data/dapp_connect_service.dart';
import '../data/mwa_wallet_service.dart';
import '../data/session_namespaces.dart';
import 'pages/dapp_proposal_page.dart';
import 'pages/dapp_request_page.dart';

/// Starts WalletConnect once a wallet is unlocked (or, when a dApp on this
/// phone opened the app over Mobile Wallet Adapter, serves that dApp
/// instead) and opens connection and signing requests one at a time, in the
/// order they arrived. Requests wait
/// while the app is locked and are refused outright in travel guard and
/// child mode.
class DappConnectListener extends ConsumerStatefulWidget {
  const DappConnectListener({super.key, required this.child});

  final Widget child;

  /// Reads the pairing link out of a deep link: `wc:...` itself, or
  /// `bennywallet://wc?uri=<wc:...>`. Returns null for the bare
  /// `bennywallet://` links dApps use to bring the wallet to the front.
  static String? pairingUriFrom(Uri link) {
    if (link.scheme == 'wc') {
      return link.toString();
    }
    final nested = link.queryParameters['uri'];
    if (nested != null && nested.trim().toLowerCase().startsWith('wc:')) {
      return nested.trim();
    }
    return null;
  }

  @override
  ConsumerState<DappConnectListener> createState() =>
      _DappConnectListenerState();
}

class _DappConnectListenerState extends ConsumerState<DappConnectListener> {
  final Queue<Object> _queue = Queue();
  final List<StreamSubscription<Object?>> _subscriptions = [];
  StreamSubscription<Uri>? _links;
  String? _pendingPairing;
  bool _started = false;

  /// The item on screen, and a counter that disowns its page once the app
  /// locks over it (go_router may never complete a push it replaced).
  Object? _current;
  int _generation = 0;

  DappConnectService get _service => ref.read(dappConnectServiceProvider);

  /// The app instance a dApp opened to sign serves only that dApp.
  bool get _mwa => MwaWalletService.isWalletActivity;
  bool get _walletConnect => _service.isAvailable && !_mwa;

  DappResponder _responderOf(Object item) => switch (item) {
    DappProposal(:final via?) => via,
    DappRequest(:final via?) => via,
    _ => _service,
  };

  @override
  void initState() {
    super.initState();
    if (!_walletConnect && !_mwa) {
      return;
    }
    if (_walletConnect) {
      _links = AppLinks().uriLinkStream.listen(_onLink, onError: (Object _) {});
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onWalletState(ref.read(walletControllerProvider));
    });
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    unawaited(_links?.cancel());
    super.dispose();
  }

  void _onLink(Uri link) {
    final uri = DappConnectListener.pairingUriFrom(link);
    if (uri == null) {
      return;
    }
    _pendingPairing = uri;
    _pairWhenReady();
  }

  bool _ready(WalletControllerState state) =>
      state.isUnlocked && state.hasWallet;

  void _onWalletState(WalletControllerState state) {
    if (!_walletConnect && !_mwa) {
      return;
    }
    if (!_ready(state)) {
      final current = _current;
      if (current != null) {
        // Shown again after unlocking if the dApp is still waiting.
        _queue.addFirst(current);
        _current = null;
        _generation++;
      }
      return;
    }
    if (!_started) {
      _started = true;
      unawaited(_start());
      return;
    }
    unawaited(_pruneSessions(state));
    _pairWhenReady();
    // The unlock page hands over to the home page first; let it settle.
    Future<void>.delayed(const Duration(milliseconds: 600), _drain);
  }

  Future<void> _start() async {
    // Ready before the first connection page reads it.
    unawaited(ref.read(dappBlocklistProvider).refresh());
    if (_mwa) {
      final mwa = ref.read(mwaWalletServiceProvider);
      _subscriptions
        ..add(mwa.proposals.listen(_enqueue))
        ..add(mwa.requests.listen(_enqueue));
      // Requests are handed over only now, with the wallet unlocked, once
      // the unlock page has handed over to the home page: a page pushed
      // before that is replaced and its request never answered.
      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (!mounted) {
        return;
      }
      await mwa.ready();
      return;
    }
    try {
      await _service.start();
    } on Object {
      _started = false;
      return;
    }
    unawaited(_registerPush());
    _subscriptions
      ..add(_service.proposals.listen(_enqueue))
      ..add(_service.requests.listen(_enqueue));
    final (proposals, requests) = _service.takePending();
    proposals.forEach(_enqueue);
    requests.forEach(_enqueue);
    if (mounted) {
      final state = ref.read(walletControllerProvider);
      unawaited(_pruneSessions(state));
      _pairWhenReady();
    }
  }

  /// Lets a website's request wake the phone (see registerPush). Skipped
  /// without Firebase (website builds) or a push token; retried next start.
  Future<void> _registerPush() async {
    if (Firebase.apps.isEmpty) {
      return;
    }
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) {
        return;
      }
      final store = ref.read(secureStoreProvider);
      await _service.registerPush(
        token,
        alreadyRegistered: (key) async =>
            await store.read(_pushRegisteredKey) == key,
        remember: (key) => store.write(_pushRegisteredKey, key),
      );
    } on Object {
      // Push not enabled for the project yet, or offline.
    }
  }

  static const _pushRegisteredKey = 'dapp_push_registered_v1';

  /// Ends sessions whose wallet was removed from this phone.
  Future<void> _pruneSessions(WalletControllerState state) async {
    final kept = state.walletPublicKeys.toSet();
    // Sites connected in Benny's browser go with their wallet too.
    final browser = ref.read(browserConnectionsProvider);
    for (final site in browser.connections.value) {
      if (!kept.contains(site.address)) {
        await browser.remove(site.host);
      }
    }
    if (!_walletConnect) {
      return;
    }
    final orphaned = <String>{
      for (final session in _service.sessions.value)
        if (sessionAddress(session) case final address?)
          if (!kept.contains(address)) address,
    };
    for (final address in orphaned) {
      try {
        await _service.disconnectAll(address: address);
      } on Object {
        // Retried on the next wallet change.
      }
    }
  }

  void _pairWhenReady() {
    final uri = _pendingPairing;
    final state = ref.read(walletControllerProvider);
    if (uri == null || !_started || !_ready(state) || _blockedMode(state)) {
      return;
    }
    _pendingPairing = null;
    unawaited(
      _service.pair(uri).catchError((Object _) {
        final context = AppRouter.rootNavigatorKey.currentContext;
        if (context != null && context.mounted) {
          ScaffoldMessenger.maybeOf(
            context,
          )?.showSnackBar(SnackBar(content: Text(context.l10n.dappPairFailed)));
        }
      }),
    );
  }

  bool _blockedMode(WalletControllerState state) =>
      state.travelGuardSession || state.childModeEnabled;

  void _enqueue(Object item) {
    final state = ref.read(walletControllerProvider);
    if (_blockedMode(state)) {
      unawaited(_refuse(item));
      return;
    }
    _queue.add(item);
    unawaited(_drain());
  }

  Future<void> _refuse(Object item) async {
    try {
      final responder = _responderOf(item);
      switch (item) {
        case DappProposal proposal:
          await responder.reject(proposal);
        case DappRequest request:
          await responder.refuse(request, error: Errors.USER_REJECTED);
      }
    } on Object {
      // Expired already.
    }
  }

  Future<void> _drain() async {
    if (_current != null || !mounted) {
      return;
    }
    final state = ref.read(walletControllerProvider);
    if (!_ready(state)) {
      return;
    }
    while (_queue.isNotEmpty) {
      final item = _queue.removeFirst();
      if (_blockedMode(state)) {
        await _refuse(item);
        continue;
      }
      final pending = switch (item) {
        DappProposal proposal => _responderOf(item).isProposalPending(proposal),
        DappRequest request => _responderOf(item).isRequestPending(request),
        _ => false,
      };
      if (!pending) {
        continue;
      }
      _current = item;
      final generation = ++_generation;
      Object? result;
      try {
        result = await switch (item) {
          DappProposal _ => AppRouter.router.push<bool>(
            DappProposalPage.routePath,
            extra: item,
          ),
          _ => AppRouter.router.push<bool>(
            DappRequestPage.routePath,
            extra: item,
          ),
        };
      } on Object {
        result = null;
      }
      if (generation != _generation) {
        // The app locked over this page; it is queued again.
        return;
      }
      _current = null;
      // Closed without an answer: offer it again on the next wallet change
      // if the dApp is still waiting.
      if (result == null) {
        _queue.addFirst(item);
        return;
      }
      if (!mounted || !_ready(ref.read(walletControllerProvider))) {
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<WalletControllerState>(
      walletControllerProvider,
      (_, next) => _onWalletState(next),
    );
    return widget.child;
  }
}
