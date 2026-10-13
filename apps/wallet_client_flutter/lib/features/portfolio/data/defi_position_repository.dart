import '../../../core/network/api_client.dart';
import '../domain/entities/defi_position_view_data.dart';

class DefiPositionRepository {
  const DefiPositionRepository(this._apiClient);

  final BackendApiClient _apiClient;

  Future<DefiPortfolioViewData> loadDefiPositions(String ownerAddress) async {
    final payload = await _apiClient.getDefiPositions(ownerAddress);
    final summary = payload['summary'] is Map<String, dynamic>
        ? payload['summary'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final items = (payload['positions'] as List<dynamic>? ?? const []);
    final positions = items
        .whereType<Map<String, dynamic>>()
        .map(_DefiPositionPayload.fromJson)
        .map(
          (item) => DefiPosition(
            id: item.id,
            protocol: item.protocol,
            type: item.type,
            label: item.label,
            assets: item.assets,
            valueUsd: item.valueUsd,
            change24hPct: item.change24hPct,
            apyPct: item.apyPct,
            logoUrl: item.logoUrl,
            updatedAt: item.updatedAt,
          ),
        )
        .toList();

    positions.sort((left, right) {
      final riskOrder = _riskRank(right.type).compareTo(_riskRank(left.type));
      if (riskOrder != 0) return riskOrder;
      final byValue = right.valueUsd.compareTo(left.valueUsd);
      if (byValue != 0) return byValue;
      return left.protocol.compareTo(right.protocol);
    });

    return DefiPortfolioViewData(
      address: (payload['address'] as String?) ?? ownerAddress,
      totalValueUsd: _readDouble(summary['totalValueUsd']) ?? 0,
      change24hPct: _readDouble(summary['change24hPct']),
      change24hUsd: _readDouble(summary['change24hUsd']),
      positions: positions,
      lastUpdatedAt:
          DateTime.tryParse(payload['lastUpdatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

class _DefiPositionPayload {
  const _DefiPositionPayload({
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

  factory _DefiPositionPayload.fromJson(Map<String, dynamic> json) {
    return _DefiPositionPayload(
      id: json['id'] as String? ?? '',
      protocol: json['protocol'] as String? ?? 'Unknown protocol',
      type: _readDefiPositionType(json['type'] as String?),
      label: json['label'] as String? ?? 'Protocol position',
      assets: (json['assets'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .where((item) => item.trim().isNotEmpty)
          .toList(growable: false),
      valueUsd: _readDouble(json['valueUsd']) ?? 0,
      change24hPct: _readDouble(json['change24hPct']),
      apyPct: _readDouble(json['apyPct']),
      logoUrl: json['logoUrl'] as String?,
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

DefiPositionType _readDefiPositionType(String? value) {
  return switch (value) {
    'deposit' => DefiPositionType.deposit,
    'borrow' => DefiPositionType.borrow,
    'staking' => DefiPositionType.staking,
    'liquidity' => DefiPositionType.liquidity,
    'yield' => DefiPositionType.yield,
    'perps' => DefiPositionType.perps,
    'rewards' => DefiPositionType.rewards,
    _ => DefiPositionType.unknown,
  };
}

int _riskRank(DefiPositionType type) {
  return switch (type) {
    DefiPositionType.borrow => 3,
    DefiPositionType.perps => 2,
    _ => 1,
  };
}

double? _readDouble(Object? value) {
  return switch (value) {
    final num number => number.toDouble(),
    final String text => double.tryParse(text),
    _ => null,
  };
}
