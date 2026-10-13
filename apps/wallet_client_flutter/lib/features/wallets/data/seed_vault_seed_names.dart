import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/mobile_wallet_adapter_service.dart';
import '../../../core/storage/key_value_store.dart';

final seedVaultSeedNamesProvider = Provider<SeedVaultSeedNames>(
  (ref) => SeedVaultSeedNames(ref.read(secureStoreProvider)),
);

/// Remembers which Seed Vault seed each wallet lives in, so a lost
/// authorization can name the seed to pick. Seed Vault only reveals seed
/// names for seeds the app is authorized for.
class SeedVaultSeedNames {
  SeedVaultSeedNames(this._store);

  final KeyValueStore _store;

  Future<Map<String, String>> _readAll() async {
    final raw = await _store.read(AppConstants.seedVaultSeedNamesKey);
    if (raw == null || raw.isEmpty) {
      return {};
    }
    try {
      return (jsonDecode(raw) as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, '$value'),
      );
    } catch (_) {
      return {};
    }
  }

  Future<String?> nameFor(String publicKey) async {
    return (await _readAll())[publicKey];
  }

  /// Records the seed name of every listed account.
  Future<void> remember(Iterable<SeedVaultAccount> accounts) async {
    final names = await _readAll();
    var changed = false;
    for (final account in accounts) {
      final seedName = account.seedName?.trim();
      if (seedName == null ||
          seedName.isEmpty ||
          names[account.publicKey] == seedName) {
        continue;
      }
      names[account.publicKey] = seedName;
      changed = true;
    }
    if (changed) {
      await _store.write(AppConstants.seedVaultSeedNamesKey, jsonEncode(names));
    }
  }
}
