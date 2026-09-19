import 'dart:async';
import 'dart:convert';

import '../../../core/chains/chain_models.dart';
import '../../../core/storage/key_value_store.dart';

/// Additive public metadata only. Existing wallet record keys are never read or
/// rewritten here; seeds, mnemonics and signed transaction bytes are not stored.
class MultichainStore {
  MultichainStore(this._store);
  final KeyValueStore _store;
  final Map<String, Future<void>> _writes = {};
  String _key(String kind, ChainAccount account) =>
      'multichain_v1_${kind}_${account.chainId}_${account.address.startsWith('0x') ? account.address.toLowerCase() : account.address}';

  Future<void> _mutate(String key, Future<void> Function() action) async {
    final previous = _writes[key] ?? Future<void>.value();
    final done = Completer<void>();
    _writes[key] = done.future;
    await previous;
    try {
      await action();
    } finally {
      done.complete();
      if (identical(_writes[key], done.future)) _writes.remove(key);
    }
  }

  Future<List<ChainAsset>> tokens(ChainAccount account) async {
    final raw = await _store.read(_key('tokens', account));
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map(
          (item) => ChainAsset.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .where((asset) => asset.chainId == account.chainId)
        .toList();
  }

  Future<void> saveToken(ChainAccount account, ChainAsset asset) =>
      _mutate(_key('tokens', account), () async {
        if (asset.chainId != account.chainId)
          throw StateError('Token network mismatch.');
        final existing = await tokens(account);
        final byId = {
          for (final token in existing) token.id: token,
          asset.id: asset,
        };
        if (byId.length > 50)
          throw StateError('At most 50 custom tokens per network.');
        await _store.write(
          _key('tokens', account),
          jsonEncode(byId.values.map((token) => token.toJson()).toList()),
        );
      });

  Future<List<ChainActivity>> submissions(ChainAccount account) async {
    final raw = await _store.read(_key('submissions', account));
    if (raw == null) return [];
    return (jsonDecode(raw) as List).map((value) {
      final item = Map<String, dynamic>.from(value as Map);
      return ChainActivity(
        chainId: account.chainId,
        hash: item['hash'] as String,
        from: item['from'] as String,
        to: item['to'] as String,
        asset: ChainAsset.fromJson(
          Map<String, dynamic>.from(item['asset'] as Map),
        ),
        amount: BigInt.parse(item['amount'] as String),
        status: ChainTransactionStatus.values.byName(item['status'] as String),
        timestamp: DateTime.tryParse(item['timestamp'] as String? ?? ''),
        fee: item['fee'] == null ? null : BigInt.parse(item['fee'] as String),
      );
    }).toList();
  }

  Future<void> saveSubmission(ChainAccount account, ChainActivity activity) =>
      _mutate(_key('submissions', account), () async {
        final previous = await submissions(account);
        final items = [
          activity,
          ...previous.where((item) => item.hash != activity.hash),
        ].take(100).toList();
        await _store.write(
          _key('submissions', account),
          jsonEncode(
            items
                .map(
                  (item) => {
                    'hash': item.hash,
                    'from': item.from,
                    'to': item.to,
                    'asset': item.asset.toJson(),
                    'amount': item.amount.toString(),
                    'status': item.status.name,
                    'timestamp': item.timestamp?.toIso8601String(),
                    'fee': item.fee?.toString(),
                  },
                )
                .toList(),
          ),
        );
      });
}
