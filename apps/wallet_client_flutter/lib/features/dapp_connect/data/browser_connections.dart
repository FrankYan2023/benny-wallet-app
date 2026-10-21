import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/key_value_store.dart';
import '../../../core/storage/secure_store.dart';

/// A site the user connected inside Benny's own browser.
@immutable
class BrowserConnection {
  const BrowserConnection({
    required this.host,
    required this.url,
    required this.name,
    required this.address,
    required this.connectedAt,
    required this.lastUsed,
    this.icon,
  });

  /// The page's host, read by the browser (the site cannot claim another).
  final String host;

  /// The page it was connected on, reopened by "Open".
  final String url;
  final String name;
  final String? icon;

  /// The wallet it is connected to.
  final String address;
  final DateTime connectedAt;
  final DateTime lastUsed;

  BrowserConnection copyWith({DateTime? lastUsed, String? url}) =>
      BrowserConnection(
        host: host,
        url: url ?? this.url,
        name: name,
        icon: icon,
        address: address,
        connectedAt: connectedAt,
        lastUsed: lastUsed ?? this.lastUsed,
      );

  Map<String, Object?> toJson() => {
    'h': host,
    'u': url,
    'n': name,
    if (icon != null) 'i': icon,
    'a': address,
    'c': connectedAt.millisecondsSinceEpoch,
    'l': lastUsed.millisecondsSinceEpoch,
  };

  static BrowserConnection? fromJson(Object? json) {
    if (json is! Map) {
      return null;
    }
    final host = json['h'];
    final address = json['a'];
    if (host is! String || address is! String) {
      return null;
    }
    DateTime at(Object? ms) =>
        DateTime.fromMillisecondsSinceEpoch(ms is int ? ms : 0);
    return BrowserConnection(
      host: host,
      url: json['u'] as String? ?? 'https://$host',
      name: json['n'] as String? ?? host,
      icon: json['i'] as String?,
      address: address,
      connectedAt: at(json['c']),
      lastUsed: at(json['l']),
    );
  }
}

/// Sites connected in the in-app browser, by host, on this phone only.
class BrowserConnections {
  BrowserConnections(this._store) {
    unawaited(_load());
  }

  static const _key = 'browser_connections_v1';

  final KeyValueStore _store;
  final connections = ValueNotifier<List<BrowserConnection>>(const []);
  Future<void>? _loading;

  Future<void> _load() => _loading ??= () async {
    try {
      final raw = await _store.read(_key);
      if (raw != null && raw.isNotEmpty) {
        connections.value = List.unmodifiable([
          for (final item in jsonDecode(raw) as List)
            if (BrowserConnection.fromJson(item) case final c?) c,
        ]);
      }
    } on Object {
      // Unreadable: start empty.
    }
  }();

  Future<BrowserConnection?> find(String host) async {
    await _load();
    return connections.value.where((c) => c.host == host).firstOrNull;
  }

  Future<void> save(BrowserConnection connection) async {
    await _load();
    await _write([
      connection,
      for (final c in connections.value)
        if (c.host != connection.host) c,
    ]);
  }

  Future<void> touch(String host, {String? url}) async {
    final existing = await find(host);
    if (existing != null) {
      await save(existing.copyWith(lastUsed: DateTime.now(), url: url));
    }
  }

  Future<void> remove(String host) async {
    await _load();
    await _write([
      for (final c in connections.value)
        if (c.host != host) c,
    ]);
  }

  /// Ends every connection for [address] (a removed wallet), or all.
  Future<void> removeAll({String? address}) async {
    await _load();
    await _write([
      for (final c in connections.value)
        if (address != null && c.address != address) c,
    ]);
  }

  Future<void> _write(List<BrowserConnection> list) async {
    list.sort((a, b) => b.lastUsed.compareTo(a.lastUsed));
    connections.value = List.unmodifiable(list);
    await _store.write(_key, jsonEncode([for (final c in list) c.toJson()]));
  }
}

final browserConnectionsProvider = Provider<BrowserConnections>(
  (ref) => BrowserConnections(SecureStore.deviceOnly()),
);
