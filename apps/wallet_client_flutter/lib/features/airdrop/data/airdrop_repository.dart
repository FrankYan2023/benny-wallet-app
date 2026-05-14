import '../../../core/network/api_client.dart';
import '../domain/airdrop_view_data.dart';

class AirdropRepository {
  const AirdropRepository(this._apiClient);

  final BackendApiClient _apiClient;

  Future<AirdropProfileViewData> loadProfile() async {
    final payload = await _apiClient.getAirdropProfile();
    return _parseProfile(payload['profile'] as Map<String, dynamic>? ?? const {});
  }

  Future<AirdropProfileViewData> joinAirdrop({
    required String ownerAddress,
  }) async {
    final payload = await _apiClient.joinAirdrop(ownerAddress: ownerAddress);
    return _parseProfile(payload['profile'] as Map<String, dynamic>? ?? const {});
  }

  Future<AirdropCheckInResult> checkIn({
    required String ownerAddress,
  }) async {
    final payload = await _apiClient.checkInAirdrop(ownerAddress: ownerAddress);

    return AirdropCheckInResult(
      awardedPoints: _readInt(payload['awardedPoints']),
      rewardType: payload['rewardType'] as String? ?? 'daily_check_in',
      profile: _parseProfile(payload['profile'] as Map<String, dynamic>? ?? const {}),
    );
  }

  AirdropProfileViewData _parseProfile(Map<String, dynamic> json) {
    return AirdropProfileViewData(
      ownerAddress: json['ownerAddress'] as String? ?? '',
      joined: json['joined'] as bool? ?? false,
      joinedAt: DateTime.tryParse(json['joinedAt'] as String? ?? ''),
      bycPoints: _readInt(json['bycPoints']),
      streakDays: _readInt(json['streakDays']),
      totalCheckIns: _readInt(json['totalCheckIns']),
      lastCheckInAt: DateTime.tryParse(json['lastCheckInAt'] as String? ?? ''),
      lastCheckInDate: DateTime.tryParse(json['lastCheckInDate'] as String? ?? ''),
      canCheckInToday: json['canCheckInToday'] as bool? ?? false,
      nextCheckInRewardPoints: _readInt(json['nextCheckInRewardPoints']),
      streakBonusEveryDays: _readInt(json['streakBonusEveryDays'], fallback: 10),
    );
  }
}

int _readInt(Object? value, {int fallback = 0}) {
  return switch (value) {
    final num number => number.toInt(),
    final String text => int.tryParse(text) ?? fallback,
    _ => fallback,
  };
}
