import 'package:shared_types/shared_types.dart';

class SendDraftData {
  const SendDraftData({
    required this.token,
    required this.logoUrl,
    required this.destinationAddress,
    required this.amount,
    required this.availableBalance,
    required this.estimatedNetworkFeeSol,
    required this.approximateUsd,
    this.isMaxAmount = false,
  });

  final TokenInfo token;
  final String? logoUrl;
  final String destinationAddress;
  final double amount;
  final double availableBalance;
  final double estimatedNetworkFeeSol;
  final double approximateUsd;
  final bool isMaxAmount;
}
