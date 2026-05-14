// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_quote.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PriceQuote _$PriceQuoteFromJson(Map<String, dynamic> json) => _PriceQuote(
  symbol: json['symbol'] as String,
  priceUsd: json['priceUsd'] as String,
  change24hPct: json['change24hPct'] as String?,
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$PriceQuoteToJson(_PriceQuote instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'priceUsd': instance.priceUsd,
      'change24hPct': instance.change24hPct,
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
