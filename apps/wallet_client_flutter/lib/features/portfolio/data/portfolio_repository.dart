import 'package:shared_types/shared_types.dart';

import '../../../core/network/api_client.dart';
import '../domain/entities/portfolio_view_data.dart';

class PortfolioRepository {
  const PortfolioRepository(this._apiClient);

  final BackendApiClient _apiClient;

  Future<PortfolioViewData> loadPortfolio(String ownerAddress) async {
    final payload = await _apiClient.getPortfolio(ownerAddress);
    final items = (payload['assets'] as List<dynamic>? ?? const []);
    final assets = items
        .map(
          (item) =>
              _PortfolioAssetPayload.fromJson(item as Map<String, dynamic>),
        )
        .map(
          (item) => AssetHolding(
            token: TokenInfo(
              mintAddress: item.mintAddress,
              symbol: item.symbol,
              name: item.name,
              decimals: item.decimals,
              isNative: item.isNative,
              isVisible: true,
              tokenProgramType: item.tokenProgramType,
            ),
            category: item.category,
            balance: item.balance,
            priceQuote: item.priceUsd == null
                ? null
                : PriceQuote(
                    symbol: item.symbol,
                    priceUsd: item.priceUsd!,
                    change24hPct: item.change24hPct,
                    updatedAt: item.updatedAt,
                  ),
            totalValueUsd: item.totalValueUsd,
            existsOnChain: item.balance > 0,
            logoUrl: item.logoUrl,
          ),
        )
        .toList();

    assets.sort((a, b) {
      final byValue = b.totalValueUsd.compareTo(a.totalValueUsd);
      if (byValue != 0) {
        return byValue;
      }

      final byBalance = b.balance.compareTo(a.balance);
      if (byBalance != 0) {
        return byBalance;
      }

      return a.token.symbol.compareTo(b.token.symbol);
    });

    return PortfolioViewData(
      address: (payload['address'] as String?) ?? ownerAddress,
      assets: assets,
      totalValueUsd: _readDouble(payload['totalValueUsd']) ?? 0,
      lastUpdatedAt:
          DateTime.tryParse(payload['lastUpdatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

class _PortfolioAssetPayload {
  const _PortfolioAssetPayload({
    required this.mintAddress,
    required this.symbol,
    required this.name,
    required this.category,
    required this.decimals,
    required this.isNative,
    required this.tokenProgramType,
    required this.balance,
    required this.totalValueUsd,
    required this.updatedAt,
    this.logoUrl,
    this.priceUsd,
    this.change24hPct,
  });

  final String mintAddress;
  final String symbol;
  final String name;
  final String category;
  final int decimals;
  final bool isNative;
  final TokenProgramKind tokenProgramType;
  final double balance;
  final double totalValueUsd;
  final DateTime updatedAt;
  final String? logoUrl;
  final String? priceUsd;
  final String? change24hPct;

  factory _PortfolioAssetPayload.fromJson(Map<String, dynamic> json) {
    return _PortfolioAssetPayload(
      mintAddress: json['mintAddress'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? 'core',
      decimals: (json['decimals'] as num?)?.toInt() ?? 0,
      isNative: json['isNative'] as bool? ?? false,
      tokenProgramType: _readTokenProgramKind(
        json['tokenProgramType'] as String?,
      ),
      balance: _readDouble(json['balance']) ?? 0,
      totalValueUsd: _readDouble(json['totalValueUsd']) ?? 0,
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
      logoUrl: json['logoUrl'] as String?,
      priceUsd: json['priceUsd'] as String?,
      change24hPct: json['change24hPct'] as String?,
    );
  }
}

double? _readDouble(Object? value) {
  return switch (value) {
    final num number => number.toDouble(),
    final String text => double.tryParse(text),
    _ => null,
  };
}

TokenProgramKind _readTokenProgramKind(String? value) {
  return switch (value) {
    'token2022Program' => TokenProgramKind.token2022Program,
    _ => TokenProgramKind.tokenProgram,
  };
}
