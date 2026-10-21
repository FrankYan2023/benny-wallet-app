import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/key_value_store.dart';
import '../../../core/storage/secure_store.dart';

/// What happened with a website.
enum DappActivityEvent {
  connected,
  connectRejected,
  disconnected,
  signed,
  sent,
  rejected,
  failed,
}

/// One entry of the website activity log. Kept on this phone only and
/// limited to what the user needs to recognise the action: no message
/// text, no transaction contents and no full addresses.
@immutable
class DappActivity {
  const DappActivity({
    required this.at,
    required this.host,
    required this.siteName,
    required this.event,
    this.icon,
    this.action,
    this.protocol,
    this.pay,
    this.receive,
    this.signature,
    this.wallet,
    this.programs = const [],
    this.viaPhone = false,
    this.inBrowser = false,
  });

  final DateTime at;

  /// The site's host, e.g. jup.ag; entries are grouped by it.
  final String host;
  final String siteName;
  final String? icon;
  final DappActivityEvent event;

  /// DappActionKind name, or "message" for a message signature.
  final String? action;
  final String? protocol;

  /// What the user paid and received, as shown on the review page.
  final String? pay;
  final String? receive;

  /// The transaction id when known, for an explorer link.
  final String? signature;

  /// The wallet, shortened (e.g. 9ua5…ayCT).
  final String? wallet;

  /// The programs a transaction called, by name (short address when
  /// unknown).
  final List<String> programs;

  /// A dApp on this phone (Mobile Wallet Adapter) rather than WalletConnect.
  final bool viaPhone;

  /// A page in Benny's own browser.
  final bool inBrowser;

  Map<String, Object?> toJson() => {
    't': at.millisecondsSinceEpoch,
    'h': host,
    'n': siteName,
    if (icon != null) 'i': icon,
    'e': event.name,
    if (action != null) 'a': action,
    if (protocol != null) 'p': protocol,
    if (pay != null) 'pay': pay,
    if (receive != null) 'rcv': receive,
    if (signature != null) 's': signature,
    if (wallet != null) 'w': wallet,
    if (programs.isNotEmpty) 'pg': programs,
    if (viaPhone) 'mwa': true,
    if (inBrowser) 'br': true,
  };

  static DappActivity? fromJson(Object? json) {
    if (json is! Map) {
      return null;
    }
    final event = DappActivityEvent.values
        .where((e) => e.name == json['e'])
        .firstOrNull;
    final t = json['t'];
    final host = json['h'];
    if (event == null || t is! int || host is! String) {
      return null;
    }
    return DappActivity(
      at: DateTime.fromMillisecondsSinceEpoch(t),
      host: host,
      siteName: json['n'] as String? ?? host,
      icon: json['i'] as String?,
      event: event,
      action: json['a'] as String?,
      protocol: json['p'] as String?,
      pay: json['pay'] as String?,
      receive: json['rcv'] as String?,
      signature: json['s'] as String?,
      wallet: json['w'] as String?,
      programs: [
        for (final p in json['pg'] as List? ?? const [])
          if (p is String) p,
      ],
      viaPhone: json['mwa'] == true,
      inBrowser: json['br'] == true,
    );
  }
}

/// The website activity log, newest first, in device-only encrypted
/// storage. Never sent anywhere.
class DappActivityStore {
  DappActivityStore(this._store);

  static const _key = 'dapp_activity_v1';
  static const maxEntries = 300;

  final KeyValueStore _store;

  /// Changes whenever an entry is added or the log is cleared.
  final revision = ValueNotifier<int>(0);

  /// Read from storage every time: the app instance a dApp opens on this
  /// phone writes to the same log.
  Future<List<DappActivity>> all() async {
    List<DappActivity> loaded = const [];
    try {
      final raw = await _store.read(_key);
      if (raw != null && raw.isNotEmpty) {
        loaded = [
          for (final item in jsonDecode(raw) as List)
            if (DappActivity.fromJson(item) case final entry?) entry,
        ];
      }
    } on Object {
      loaded = const [];
    }
    return loaded;
  }

  Future<void> add(DappActivity entry) async {
    final updated = [entry, ...await all()].take(maxEntries).toList();
    await _store.write(_key, jsonEncode([for (final e in updated) e.toJson()]));
    revision.value++;
  }

  Future<void> clear() async {
    await _store.delete(_key);
    revision.value++;
  }

  /// Entries for [host], newest first.
  Future<List<DappActivity>> forHost(String host) async => [
    for (final e in await all())
      if (e.host == host) e,
  ];
}

final dappActivityStoreProvider = Provider<DappActivityStore>(
  (ref) => DappActivityStore(SecureStore.deviceOnly()),
);
