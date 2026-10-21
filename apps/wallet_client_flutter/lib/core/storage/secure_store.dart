import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'key_value_store.dart';

class SecureStore implements KeyValueStore {
  SecureStore()
    : _storage = const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
      );

  /// Kept on this phone only: on iOS the keychain item never leaves the
  /// device (no backup, no migration); Android excludes app data from
  /// backup (allowBackup=false).
  SecureStore.deviceOnly()
    : _storage = const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
        iOptions: IOSOptions(
          accessibility: KeychainAccessibility.first_unlock_this_device,
        ),
      );

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);

  @override
  Future<void> deleteAll(Iterable<String> keys) async {
    for (final key in keys) {
      await delete(key);
    }
  }
}
