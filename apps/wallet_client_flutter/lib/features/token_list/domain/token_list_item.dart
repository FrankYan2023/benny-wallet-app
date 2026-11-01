/// A token on Benny's whitelist (the backend's catalog), with its price.
class TokenListItem {
  const TokenListItem({
    required this.mintAddress,
    required this.symbol,
    required this.name,
    required this.category,
    required this.featured,
    this.logoUrl,
    this.priceUsd,
    this.change24hPct,
    this.marketCapUsd,
    this.underlyingSymbol,
  });

  final String mintAddress;
  final String symbol;
  final String name;
  final String category;
  final String? logoUrl;
  final double? priceUsd;
  final double? change24hPct;

  /// The coin's market cap; for an xStock, the listed company's.
  final double? marketCapUsd;
  final String? underlyingSymbol;

  /// Shown before searching: the top 20 coins or tech stocks.
  final bool featured;

  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      return true;
    }
    return symbol.toLowerCase().contains(q) ||
        name.toLowerCase().contains(q) ||
        (underlyingSymbol?.toLowerCase().contains(q) ?? false) ||
        mintAddress.toLowerCase() == q;
  }

  static TokenListItem fromJson(Map<String, dynamic> json) {
    double? number(Object? value) => switch (value) {
      final num n => n.toDouble(),
      final String s => double.tryParse(s),
      _ => null,
    };
    return TokenListItem(
      mintAddress: json['mintAddress'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      logoUrl: json['logoUrl'] as String?,
      priceUsd: number(json['priceUsd']),
      change24hPct: number(json['change24hPct']),
      marketCapUsd: number(json['marketCapUsd']),
      underlyingSymbol: json['underlyingSymbol'] as String?,
      featured: json['featured'] == true,
    );
  }
}

class TokenList {
  const TokenList({required this.coins, required this.stocks});

  final List<TokenListItem> coins;
  final List<TokenListItem> stocks;

  static TokenList fromJson(Map<String, dynamic> json) {
    List<TokenListItem> items(String key) => [
      for (final item in json[key] as List<dynamic>? ?? const [])
        if (item is Map<String, dynamic>) TokenListItem.fromJson(item),
    ];
    return TokenList(coins: items('coins'), stocks: items('stocks'));
  }
}
