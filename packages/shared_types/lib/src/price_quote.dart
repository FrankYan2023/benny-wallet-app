import 'package:freezed_annotation/freezed_annotation.dart';

part 'price_quote.freezed.dart';
part 'price_quote.g.dart';

@freezed
abstract class PriceQuote with _$PriceQuote {
  const factory PriceQuote({
    required String symbol,
    required String priceUsd,
    String? change24hPct,
    required DateTime updatedAt,
  }) = _PriceQuote;

  factory PriceQuote.fromJson(Map<String, dynamic> json) => _$PriceQuoteFromJson(json);
}
