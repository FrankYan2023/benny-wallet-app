import 'package:shared_types/shared_types.dart';

class SwapTokenOption {
  const SwapTokenOption({
    required this.token,
    required this.category,
    required this.logoUrl,
    required this.availableBalance,
    required this.isOwned,
    required this.totalValueUsd,
    this.rawAvailableAmount,
  });

  final TokenInfo token;
  final String category;
  final String? logoUrl;
  final double availableBalance;
  final bool isOwned;
  final double totalValueUsd;
  final String? rawAvailableAmount;
}
