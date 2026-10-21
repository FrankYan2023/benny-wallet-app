import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/key_value_store.dart';

/// Websites and programs Benny Wallet refuses to connect to or sign for,
/// maintained on the backend.
@immutable
class DappBlocklist {
  const DappBlocklist({
    this.domains = const {},
    this.programs = const {},
    this.version = '',
    this.fetchedAt,
  });

  final Set<String> domains;
  final Set<String> programs;
  final String version;
  final DateTime? fetchedAt;

  static const empty = DappBlocklist();

  /// [host] or any site under it is on the list (lowercase hosts).
  bool blocksHost(String? host) {
    if (host == null || host.isEmpty || domains.isEmpty) {
      return false;
    }
    var candidate = host.toLowerCase();
    while (true) {
      if (domains.contains(candidate)) {
        return true;
      }
      final dot = candidate.indexOf('.');
      if (dot < 0 || candidate.indexOf('.', dot + 1) < 0) {
        return false;
      }
      candidate = candidate.substring(dot + 1);
    }
  }

  bool blocksProgram(String programId) => programs.contains(programId);

  Map<String, Object?> toJson() => {
    'version': version,
    'domains': domains.toList(),
    'programs': programs.toList(),
    'fetchedAt': fetchedAt?.millisecondsSinceEpoch,
  };

  static DappBlocklist fromJson(Map<String, dynamic> json, {DateTime? at}) {
    Set<String> strings(Object? list) => {
      for (final item in list is List ? list : const [])
        if (item is String && item.isNotEmpty) item.trim(),
    };
    final fetched = json['fetchedAt'];
    return DappBlocklist(
      domains: {for (final d in strings(json['domains'])) d.toLowerCase()},
      programs: strings(json['programs']),
      version: json['version'] as String? ?? '',
      fetchedAt:
          at ??
          (fetched is int
              ? DateTime.fromMillisecondsSinceEpoch(fetched)
              : null),
    );
  }
}

/// Keeps the blocklist: the last copy from this phone at once, a fresh one
/// from the backend at most every few hours. Without either, nothing is
/// blocked by the list (WalletConnect's own scam check still applies).
class DappBlocklistService {
  DappBlocklistService({
    required KeyValueStore store,
    required BackendApiClient api,
  }) : _store = store,
       _api = api;

  static const _key = 'dapp_blocklist_v1';
  static const refreshAfter = Duration(hours: 6);

  final KeyValueStore _store;
  final BackendApiClient _api;
  DappBlocklist _current = DappBlocklist.empty;
  bool _loaded = false;

  DappBlocklist get current => _current;

  Future<DappBlocklist> refresh({bool force = false}) async {
    if (!_loaded) {
      _loaded = true;
      try {
        final raw = await _store.read(_key);
        if (raw != null && raw.isNotEmpty) {
          _current = DappBlocklist.fromJson(
            jsonDecode(raw) as Map<String, dynamic>,
          );
        }
      } on Object {
        // Unreadable copy: fetched again below.
      }
    }
    final fetchedAt = _current.fetchedAt;
    if (!force &&
        fetchedAt != null &&
        DateTime.now().difference(fetchedAt) < refreshAfter) {
      return _current;
    }
    try {
      final json = await _api.getDappBlocklist();
      final fresh = DappBlocklist.fromJson(json, at: DateTime.now());
      _current = fresh;
      await _store.write(_key, jsonEncode(fresh.toJson()));
    } on Object {
      // Offline or the backend has no list yet: keep the last copy.
    }
    return _current;
  }
}

final dappBlocklistProvider = Provider<DappBlocklistService>(
  (ref) => DappBlocklistService(
    store: ref.read(secureStoreProvider),
    api: ref.read(backendApiClientProvider),
  ),
);
