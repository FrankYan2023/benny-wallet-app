class AssetDetailViewData {
  const AssetDetailViewData({
    required this.mintAddress,
    required this.symbol,
    required this.name,
    required this.network,
    required this.updatedAt,
    this.logoUrl,
    this.websiteUrl,
    this.priceUsd,
    this.change24hPct,
    this.marketCapUsd,
    this.fdvUsd,
    this.totalSupply,
    this.circulatingSupply,
    this.holderCount,
    this.top10HoldersPct,
    this.createdAt,
    this.volume24hUsd,
    this.traderCount24h,
  });

  final String mintAddress;
  final String symbol;
  final String name;
  final String network;
  final DateTime updatedAt;
  final String? logoUrl;
  final String? websiteUrl;
  final double? priceUsd;
  final double? change24hPct;
  final double? marketCapUsd;
  final double? fdvUsd;
  final double? totalSupply;
  final double? circulatingSupply;
  final int? holderCount;
  final double? top10HoldersPct;
  final DateTime? createdAt;
  final double? volume24hUsd;
  final int? traderCount24h;
}
