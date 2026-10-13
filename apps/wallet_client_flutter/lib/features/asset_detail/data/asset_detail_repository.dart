import '../../../core/network/api_client.dart';
import '../../transaction_history/domain/transaction_activity.dart';
import '../domain/asset_detail_view_data.dart';

class AssetDetailRepository {
  const AssetDetailRepository(this._apiClient);

  final BackendApiClient _apiClient;

  Future<AssetDetailViewData> loadTokenDetail(String mintAddress) async {
    final payload = await _apiClient.getTokenDetail(mintAddress);

    return AssetDetailViewData(
      mintAddress: payload['mintAddress'] as String? ?? mintAddress,
      symbol: payload['symbol'] as String? ?? mintAddress,
      name: payload['name'] as String? ?? mintAddress,
      network: payload['network'] as String? ?? 'Solana',
      updatedAt:
          DateTime.tryParse(payload['updatedAt'] as String? ?? '') ??
          DateTime.now(),
      logoUrl: payload['logoUrl'] as String?,
      websiteUrl: payload['websiteUrl'] as String?,
      priceUsd: _readDouble(payload['priceUsd']),
      change24hPct: _readDouble(payload['change24hPct']),
      marketCapUsd: _readDouble(payload['marketCapUsd']),
      fdvUsd: _readDouble(payload['fdvUsd']),
      totalSupply: _readDouble(payload['totalSupply']),
      circulatingSupply: _readDouble(payload['circulatingSupply']),
      holderCount: (payload['holderCount'] as num?)?.toInt(),
      top10HoldersPct: _readDouble(payload['top10HoldersPct']),
      createdAt: DateTime.tryParse(payload['createdAt'] as String? ?? ''),
      volume24hUsd: _readDouble(payload['volume24hUsd']),
      traderCount24h: (payload['traderCount24h'] as num?)?.toInt(),
    );
  }

  Future<List<TransactionActivity>> loadTokenActivity({
    required String ownerAddress,
    required String mintAddress,
    required String symbol,
    int limit = 10,
  }) async {
    final payload = await _apiClient.getAssetActivity(
      ownerAddress: ownerAddress,
      mintAddress: mintAddress,
      limit: limit,
    );
    final items = payload['items'] as List<dynamic>? ?? const [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(
          (item) =>
              TransactionActivity.fromBackendJson(json: item, symbol: symbol),
        )
        .toList();
  }
}

double? _readDouble(Object? value) {
  return switch (value) {
    final num number => number.toDouble(),
    final String text => double.tryParse(text),
    _ => null,
  };
}
