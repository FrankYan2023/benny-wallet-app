enum SwapPriorityPreset {
  auto('Auto', 'auto'),
  normal('Normal', 'normal'),
  fast('Fast', 'fast'),
  turbo('Turbo', 'turbo');

  const SwapPriorityPreset(this.label, this.apiValue);

  final String label;
  final String apiValue;
}
