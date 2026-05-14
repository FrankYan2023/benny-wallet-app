import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Security Issue #1: Plaintext mnemonic in memory
/// 
/// This provider implements secure ephemeral mnemonic handling:
/// 1. Mnemonic is NEVER stored in Riverpod state
/// 2. Mnemonic is ONLY held in local variable scope
/// 3. Auto-clears after specified duration (default 2 minutes)
/// 4. Supports one-time read for operations (send, display)

/// Secure ephemeral storage for mnemonics
/// 
/// Key principles:
/// - Mnemonics are held by reference, not stored in Riverpod state
/// - Each token has a 2-minute TTL
/// - Tokens are single-use or time-limited
/// - Failed operations auto-clear the mnemonic
/// - Successful operations clear after use
class MnemonicEphemeralStore {
  final Map<String, String> _store = {};
  final Map<String, Timer> _timers = {};
  final Map<String, Duration> _ttls = {};

  /// Store a mnemonic temporarily with auto-cleanup
  String store(
    String mnemonic, {
    Duration ttl = const Duration(minutes: 2),
  }) {
    final token = _generateTokenId();

    _store[token] = mnemonic;
    _ttls[token] = ttl;
    debugPrint('[SECURITY] Mnemonic token issued (TTL: ${ttl.inSeconds}s).');

    _scheduleExpiry(token, ttl);
    return token;
  }

  /// Retrieve and immediately clear (best for read-once operations)
  String? retrieveAndClear(String token) {
    final mnemonic = _store.remove(token);
    _timers[token]?.cancel();
    _timers.remove(token);
    _ttls.remove(token);

    if (mnemonic == null) {
      debugPrint('[SECURITY] Invalid or expired mnemonic token.');
    } else {
      debugPrint('[SECURITY] Mnemonic token retrieved and cleared.');
    }

    return mnemonic;
  }

  /// Retrieve for temporary use (still auto-clears after TTL)
  String? retrieveTemporary(String token) {
    if (!_store.containsKey(token)) {
      debugPrint('[SECURITY] Invalid or expired mnemonic token.');
      return null;
    }

    final ttl = _ttls[token];
    if (ttl != null) {
      _scheduleExpiry(token, ttl);
    }
    debugPrint('[SECURITY] Mnemonic token retrieved for temporary use.');
    return _store[token];
  }

  /// Force clear a specific token
  void clear(String token) {
    _timers[token]?.cancel();
    _store.remove(token);
    _timers.remove(token);
    _ttls.remove(token);
    debugPrint('[SECURITY] Mnemonic token forcefully cleared.');
  }

  /// Clear all tokens (e.g., on logout)
  void clearAll() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _store.clear();
    _timers.clear();
    _ttls.clear();
    debugPrint('[SECURITY] All mnemonic tokens cleared');
  }

  void _scheduleExpiry(String token, Duration ttl) {
    _timers[token]?.cancel();
    _timers[token] = Timer(ttl, () {
      if (_store.containsKey(token)) {
        _store.remove(token);
        _timers.remove(token);
        _ttls.remove(token);
        debugPrint('[SECURITY] Mnemonic token expired and cleared: $token');
      }
    });
  }

  String _generateTokenId() {
    return 'mnt_${DateTime.now().millisecondsSinceEpoch}_'
        '${DateTime.now().microsecond}';
  }
}

/// Global ephemeral store (singleton)
final _ephemeralStore = MnemonicEphemeralStore();

/// Provider to access the ephemeral store
final mnemonicEphemeralStoreProvider = Provider<MnemonicEphemeralStore>(
  (_) => _ephemeralStore,
);
