enum StockKind { stock, etf, private }

/// The exchange session at the time of the quote.
enum MarketState { pre, regular, post, closed }

/// The listed company or fund an xStock tracks.
class StockProfile {
  const StockProfile({
    required this.name,
    required this.kind,
    required this.sources,
    this.underlyingSymbol,
    this.exchange,
    this.currency,
    this.localName,
    this.price,
    this.previousClose,
    this.open,
    this.change,
    this.changePct,
    this.marketTime,
    this.marketState,
    this.timeZone,
    this.timeZoneName,
    this.gmtOffsetSeconds,
    this.dayHigh,
    this.dayLow,
    this.fiftyTwoWeekHigh,
    this.fiftyTwoWeekLow,
    this.volume,
    this.marketCap,
    this.peRatio,
    this.peRatioStatic,
    this.peRatioDynamic,
    this.pbRatio,
    this.sharesOutstanding,
    this.epsTtm,
    this.epsAnnual,
    this.epsAnnualized,
    this.bookValuePerShare,
    this.revenueTtm,
    this.netIncomeTtm,
    this.dividendYieldPct,
    this.periodEnd,
    this.description,
    this.wikipediaUrl,
    this.industry,
    this.ceo,
    this.founded,
    this.headquarters,
    this.employees,
    this.website,
  });

  final String name;
  final StockKind kind;
  final List<String> sources;
  final String? underlyingSymbol;
  final String? exchange;

  /// Currency of the quote (fundamentals are always USD).
  final String? currency;

  /// The company's name in the app's language, when Wikidata has one.
  final String? localName;
  final double? price;
  final double? previousClose;

  /// Opening price of the latest session.
  final double? open;
  final double? change;
  final double? changePct;

  /// Time of the last trade.
  final DateTime? marketTime;
  final MarketState? marketState;

  /// IANA zone of the exchange (America/New_York) and its short name (EDT).
  final String? timeZone;
  final String? timeZoneName;
  final int? gmtOffsetSeconds;
  final double? dayHigh;
  final double? dayLow;
  final double? fiftyTwoWeekHigh;
  final double? fiftyTwoWeekLow;
  final double? volume;
  final double? marketCap;
  final double? peRatio;

  /// P/E on the last fiscal year's EPS.
  final double? peRatioStatic;

  /// P/E on this fiscal year's reported EPS, annualized.
  final double? peRatioDynamic;
  final double? pbRatio;
  final double? sharesOutstanding;
  final double? epsTtm;
  final double? epsAnnual;
  final double? epsAnnualized;
  final double? bookValuePerShare;
  final double? revenueTtm;
  final double? netIncomeTtm;
  final double? dividendYieldPct;
  final DateTime? periodEnd;
  final String? description;
  final String? wikipediaUrl;
  final String? industry;
  final String? ceo;
  final String? founded;
  final String? headquarters;
  final int? employees;
  final String? website;

  bool get hasQuote => price != null;

  bool get hasFundamentals =>
      marketCap != null ||
      peRatio != null ||
      sharesOutstanding != null ||
      epsTtm != null ||
      revenueTtm != null ||
      netIncomeTtm != null ||
      dividendYieldPct != null;

  bool get hasProfile =>
      description != null ||
      industry != null ||
      ceo != null ||
      founded != null ||
      headquarters != null ||
      employees != null ||
      website != null;

  static StockProfile fromJson(Map<String, dynamic> json) {
    final quote = json['quote'] as Map<String, dynamic>? ?? const {};
    final fundamentals =
        json['fundamentals'] as Map<String, dynamic>? ?? const {};
    final profile = json['profile'] as Map<String, dynamic>? ?? const {};
    double? number(Map<String, dynamic> map, String key) =>
        (map[key] as num?)?.toDouble();
    return StockProfile(
      name: json['name'] as String? ?? '',
      kind: switch (json['kind']) {
        'etf' => StockKind.etf,
        'private' => StockKind.private,
        _ => StockKind.stock,
      },
      sources: [
        for (final source in json['sources'] as List<dynamic>? ?? const [])
          if (source is String) source,
      ],
      underlyingSymbol: json['underlyingSymbol'] as String?,
      exchange: json['exchange'] as String?,
      currency: json['currency'] as String?,
      localName: profile['name'] as String?,
      price: number(quote, 'price'),
      previousClose: number(quote, 'previousClose'),
      open: number(quote, 'open'),
      change: number(quote, 'change'),
      changePct: number(quote, 'changePct'),
      marketTime: DateTime.tryParse(quote['marketTime'] as String? ?? ''),
      marketState: switch (quote['marketState']) {
        'pre' => MarketState.pre,
        'regular' => MarketState.regular,
        'post' => MarketState.post,
        'closed' => MarketState.closed,
        _ => null,
      },
      timeZone: quote['timeZone'] as String?,
      timeZoneName: quote['timeZoneName'] as String?,
      gmtOffsetSeconds: (quote['gmtOffsetSeconds'] as num?)?.toInt(),
      dayHigh: number(quote, 'dayHigh'),
      dayLow: number(quote, 'dayLow'),
      fiftyTwoWeekHigh: number(quote, 'fiftyTwoWeekHigh'),
      fiftyTwoWeekLow: number(quote, 'fiftyTwoWeekLow'),
      volume: number(quote, 'volume'),
      marketCap: number(fundamentals, 'marketCap'),
      peRatio: number(fundamentals, 'peRatio'),
      peRatioStatic: number(fundamentals, 'peRatioStatic'),
      peRatioDynamic: number(fundamentals, 'peRatioDynamic'),
      pbRatio: number(fundamentals, 'pbRatio'),
      sharesOutstanding: number(fundamentals, 'sharesOutstanding'),
      epsTtm: number(fundamentals, 'epsTtm'),
      epsAnnual: number(fundamentals, 'epsAnnual'),
      epsAnnualized: number(fundamentals, 'epsAnnualized'),
      bookValuePerShare: number(fundamentals, 'bookValuePerShare'),
      revenueTtm: number(fundamentals, 'revenueTtm'),
      netIncomeTtm: number(fundamentals, 'netIncomeTtm'),
      dividendYieldPct: number(fundamentals, 'dividendYieldPct'),
      periodEnd: DateTime.tryParse(fundamentals['periodEnd'] as String? ?? ''),
      description: profile['description'] as String?,
      wikipediaUrl: profile['wikipediaUrl'] as String?,
      industry: profile['industry'] as String?,
      ceo: profile['ceo'] as String?,
      founded: profile['founded'] as String?,
      headquarters: profile['headquarters'] as String?,
      employees: (profile['employees'] as num?)?.toInt(),
      website: profile['website'] as String?,
    );
  }
}
