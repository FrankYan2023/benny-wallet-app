import 'swap_build_result.dart';
import 'swap_priority_preset.dart';
import 'swap_token_option.dart';

class SwapReviewData {
  const SwapReviewData({
    required this.inputToken,
    required this.outputToken,
    required this.inputAmountUi,
    required this.outputAmountUi,
    required this.buildResult,
    required this.priorityPreset,
    required this.slippageBps,
  });

  final SwapTokenOption inputToken;
  final SwapTokenOption outputToken;
  final double inputAmountUi;
  final double outputAmountUi;
  final SwapBuildResult buildResult;
  final SwapPriorityPreset priorityPreset;
  final int slippageBps;
}
