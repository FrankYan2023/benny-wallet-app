import 'swap_build_result.dart';
import 'swap_priority_preset.dart';
import 'swap_token_option.dart';

class SwapReviewData {
  const SwapReviewData({
    required this.ownerAddress,
    required this.inputToken,
    required this.outputToken,
    required this.inputAmountUi,
    required this.outputAmountUi,
    required this.buildResult,
    required this.priorityPreset,
    required this.slippageBps,
  });

  /// Wallet the swap was quoted and reviewed for; execution refuses to run
  /// for any other wallet.
  final String ownerAddress;
  final SwapTokenOption inputToken;
  final SwapTokenOption outputToken;
  final double inputAmountUi;
  final double outputAmountUi;
  final SwapBuildResult buildResult;
  final SwapPriorityPreset priorityPreset;
  final int slippageBps;
}
