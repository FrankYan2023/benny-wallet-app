import 'package:freezed_annotation/freezed_annotation.dart';

part 'asset_summary.freezed.dart';
part 'asset_summary.g.dart';

@freezed
abstract class AssetSummary with _$AssetSummary {
  const factory AssetSummary({
    required String symbol,
    required String name,
    required String balance,
    required String priceUsd,
    required String valueUsd,
  }) = _AssetSummary;

  factory AssetSummary.fromJson(Map<String, dynamic> json) => _$AssetSummaryFromJson(json);
}
