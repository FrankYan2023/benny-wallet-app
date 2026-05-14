class AirdropProfileViewData {
  const AirdropProfileViewData({
    required this.ownerAddress,
    required this.joined,
    required this.joinedAt,
    required this.bycPoints,
    required this.streakDays,
    required this.totalCheckIns,
    required this.lastCheckInAt,
    required this.lastCheckInDate,
    required this.canCheckInToday,
    required this.nextCheckInRewardPoints,
    required this.streakBonusEveryDays,
  });

  final String ownerAddress;
  final bool joined;
  final DateTime? joinedAt;
  final int bycPoints;
  final int streakDays;
  final int totalCheckIns;
  final DateTime? lastCheckInAt;
  final DateTime? lastCheckInDate;
  final bool canCheckInToday;
  final int nextCheckInRewardPoints;
  final int streakBonusEveryDays;
}

class AirdropCheckInResult {
  const AirdropCheckInResult({
    required this.awardedPoints,
    required this.rewardType,
    required this.profile,
  });

  final int awardedPoints;
  final String rewardType;
  final AirdropProfileViewData profile;
}
