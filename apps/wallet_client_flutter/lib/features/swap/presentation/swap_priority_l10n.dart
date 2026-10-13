import '../../../l10n/generated/app_localizations.dart';
import '../domain/swap_priority_preset.dart';

extension SwapPriorityPresetL10n on SwapPriorityPreset {
  String localizedLabel(AppLocalizations l10n) {
    return switch (this) {
      SwapPriorityPreset.auto => l10n.commonAuto,
      SwapPriorityPreset.normal => l10n.swapPriorityNormal,
      SwapPriorityPreset.fast => l10n.swapPriorityFast,
      SwapPriorityPreset.turbo => l10n.swapPriorityTurbo,
    };
  }
}
