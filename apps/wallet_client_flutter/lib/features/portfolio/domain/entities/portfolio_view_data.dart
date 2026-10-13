import 'package:shared_types/shared_types.dart';

class AssetHolding {
  const AssetHolding({
    required this.token,
    required this.category,
    required this.balance,
    required this.priceQuote,
    required this.totalValueUsd,
    required this.existsOnChain,
    this.logoUrl,
    this.rawAmount,
  });

  final TokenInfo token;
  final String category;
  final double balance;
  final PriceQuote? priceQuote;
  final double totalValueUsd;
  final bool existsOnChain;
  final String? logoUrl;
  final String? rawAmount;
}

class PortfolioViewData {
  const PortfolioViewData({
    required this.address,
    required this.assets,
    required this.totalValueUsd,
    required this.lastUpdatedAt,
  });

  final String address;
  final List<AssetHolding> assets;
  final double totalValueUsd;
  final DateTime lastUpdatedAt;
}
