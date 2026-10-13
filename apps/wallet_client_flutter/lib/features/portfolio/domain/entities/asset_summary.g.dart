// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AssetSummary _$AssetSummaryFromJson(Map<String, dynamic> json) =>
    _AssetSummary(
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      balance: json['balance'] as String,
      priceUsd: json['priceUsd'] as String,
      valueUsd: json['valueUsd'] as String,
    );

Map<String, dynamic> _$AssetSummaryToJson(_AssetSummary instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'name': instance.name,
      'balance': instance.balance,
      'priceUsd': instance.priceUsd,
      'valueUsd': instance.valueUsd,
    };
