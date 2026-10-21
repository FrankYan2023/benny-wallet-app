import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solana/base58.dart';

import '../../../core/walletconnect/dapp_review.dart';

/// A dApp on this phone that Benny approved over Mobile Wallet Adapter.
@immutable
class MwaConnection {
  const MwaConnection({
    required this.name,
    required this.uri,
    required this.icon,
    required this.address,
    required this.lastUsed,
  });

  final String name;
  final String uri;
  final String? icon;

  /// The wallet it was approved for.
  final String? address;
  final DateTime lastUsed;

  String get host => DappReviewer.hostOf(uri) ?? uri;
}

/// The dApps on this phone with a live MWA approval (kept by the Android
/// side, which reconnects them without asking). Refreshed when the app
/// comes back to the front, since a dApp may have connected meanwhile.
class MwaConnections with WidgetsBindingObserver {
  MwaConnections({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('benny_wallet/mwa_auth') {
    if (_supported) {
      WidgetsBinding.instance.addObserver(this);
      unawaited(refresh());
    }
  }

  final MethodChannel _channel;
  final connections = ValueNotifier<List<MwaConnection>>(const []);

  static bool get _supported => !kIsWeb && Platform.isAndroid;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(refresh());
    }
  }

  Future<void> refresh() async {
    if (!_supported) {
      return;
    }
    try {
      final raw = await _channel.invokeListMethod<Object?>('list') ?? const [];
      final list = <MwaConnection>[
        for (final item in raw)
          if (item is Map)
            MwaConnection(
              name: (item['name'] as String?)?.trim() ?? '',
              uri: item['uri'] as String? ?? '',
              icon: switch (item['icon']) {
                final String icon when icon.startsWith('https://') => icon,
                _ => null,
              },
              address: switch (item['publicKey']) {
                final Uint8List key when key.length == 32 => base58encode(key),
                _ => null,
              },
              lastUsed: DateTime.fromMillisecondsSinceEpoch(
                item['lastUsed'] as int? ?? 0,
              ),
            ),
      ]..sort((a, b) => b.lastUsed.compareTo(a.lastUsed));
      connections.value = List.unmodifiable(list);
    } on Object {
      // Older build without the channel, or the database is busy.
    }
  }

  /// Ends [connection]: the dApp has to ask again next time.
  Future<void> revoke(MwaConnection connection) async {
    if (!_supported) {
      return;
    }
    try {
      await _channel.invokeMethod<bool>('revoke', {'uri': connection.uri});
    } finally {
      await refresh();
    }
  }

  Future<void> revokeAll() async {
    for (final connection in connections.value) {
      try {
        await _channel.invokeMethod<bool>('revoke', {'uri': connection.uri});
      } on Object {
        // Retried on the next disconnect.
      }
    }
    await refresh();
  }

  void dispose() {
    if (_supported) {
      WidgetsBinding.instance.removeObserver(this);
    }
    connections.dispose();
  }
}

final mwaConnectionsProvider = Provider<MwaConnections>((ref) {
  final connections = MwaConnections();
  ref.onDispose(connections.dispose);
  return connections;
});
