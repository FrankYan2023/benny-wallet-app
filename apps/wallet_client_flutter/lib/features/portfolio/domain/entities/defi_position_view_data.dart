enum DefiPositionType {
  deposit,
  borrow,
  staking,
  liquidity,
  yield,
  perps,
  rewards,
  unknown,
}

class DefiPosition {
  const DefiPosition({
    required this.id,
    required this.protocol,
    required this.type,
    required this.label,
    required this.assets,
    required this.valueUsd,
    required this.updatedAt,
    this.change24hPct,
    this.apyPct,
    this.logoUrl,
  });

  final String id;
  final String protocol;
  final DefiPositionType type;
  final String label;
  final List<String> assets;
  final double valueUsd;
  final double? change24hPct;
  final double? apyPct;
  final String? logoUrl;
  final DateTime updatedAt;
}

class DefiPortfolioViewData {
  const DefiPortfolioViewData({
    required this.address,
    required this.totalValueUsd,
    required this.positions,
    required this.lastUpdatedAt,
    this.change24hPct,
    this.change24hUsd,
  });

  final String address;
  final double totalValueUsd;
  final double? change24hPct;
  final double? change24hUsd;
  final List<DefiPosition> positions;
  final DateTime lastUpdatedAt;
}
