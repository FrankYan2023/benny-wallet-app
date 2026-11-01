import '../../../core/network/api_client.dart';
import '../../transaction_history/domain/transaction_activity.dart';
import '../domain/asset_detail_view_data.dart';
import '../domain/stock_profile.dart';
import '../domain/token_candles.dart';
import '../domain/token_profile.dart';

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
      liquidityUsd: _readDouble(payload['liquidityUsd']),
    );
  }

  /// Null when the token has no chart (it is not in the backend catalog).
  Future<TokenCandles?> loadCandles(
    String mintAddress,
    CandleInterval interval,
  ) async {
    final payload = await _apiClient.getTokenCandles(
      mintAddress: mintAddress,
      interval: interval.apiValue,
    );
    if (payload == null) {
      return null;
    }
    return TokenCandles.fromJson(
      payload,
      mintAddress: mintAddress,
      interval: interval,
    );
  }

  /// Null for tokens that are not xStocks.
  Future<StockProfile?> loadStockProfile(
    String mintAddress, {
    required String language,
  }) async {
    final payload = await _apiClient.getStockProfile(
      mintAddress: mintAddress,
      language: language,
    );
    return payload == null ? null : StockProfile.fromJson(payload);
  }

  /// Null when the token is not a catalog coin.
  Future<TokenProfile?> loadTokenProfile(
    String mintAddress, {
    required String language,
  }) async {
    final payload = await _apiClient.getTokenProfile(
      mintAddress: mintAddress,
      language: language,
    );
    return payload == null ? null : TokenProfile.fromJson(payload);
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
