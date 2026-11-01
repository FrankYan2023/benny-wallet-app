/// Candle period of a chart: 15 minutes, an hour, 4 hours, a day, week,
/// month or year.
enum CandleInterval {
  minutes15('15m'),
  hour('1h'),
  hours4('4h'),
  day('1d'),
  week('1w'),
  month('1M'),
  year('1y');

  const CandleInterval(this.apiValue);

  final String apiValue;
}

class Candle {
  const Candle({
    required this.time,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  /// Start of the period, in seconds since the epoch (UTC).
  final int time;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;
}

class TokenCandles {
  const TokenCandles({
    required this.mintAddress,
    required this.interval,
    required this.isStock,
    required this.sourceName,
    required this.volumeInShares,
    required this.refreshSeconds,
    required this.candles,
    this.underlyingSymbol,
    this.exchange,
  });

  final String mintAddress;
  final CandleInterval interval;
  final bool isStock;
  final String sourceName;
  final String? underlyingSymbol;
  final String? exchange;
  final bool volumeInShares;
  final int refreshSeconds;
  final List<Candle> candles;

  static TokenCandles fromJson(
    Map<String, dynamic> json, {
    required String mintAddress,
    required CandleInterval interval,
  }) {
    final rows = json['candles'] as List<dynamic>? ?? const [];
    return TokenCandles(
      mintAddress: mintAddress,
      interval: interval,
      isStock: json['market'] == 'stock',
      sourceName: json['sourceName'] as String? ?? '',
      underlyingSymbol: json['underlyingSymbol'] as String?,
      exchange: json['exchange'] as String?,
      volumeInShares: json['volumeUnit'] == 'shares',
      refreshSeconds: ((json['refreshSeconds'] as num?)?.toInt() ?? 30).clamp(
        10,
        300,
      ),
      candles: [
        for (final row in rows)
          if (row is List && row.length >= 6)
            Candle(
              time: (row[0] as num).toInt(),
              open: (row[1] as num).toDouble(),
              high: (row[2] as num).toDouble(),
              low: (row[3] as num).toDouble(),
              close: (row[4] as num).toDouble(),
              volume: (row[5] as num).toDouble(),
            ),
      ],
    );
  }
}
