class SwapQuoteResult {
  const SwapQuoteResult({
    required this.inputMint,
    required this.inAmount,
    required this.outputMint,
    required this.outAmount,
    required this.otherAmountThreshold,
    required this.priceImpactPct,
    required this.routeLabels,
    required this.slippageBps,
    this.contextSlot,
    this.timeTaken,
  });

  final String inputMint;
  final String inAmount;
  final String outputMint;
  final String outAmount;
  final String otherAmountThreshold;
  final String priceImpactPct;
  final List<String> routeLabels;
  final int slippageBps;
  final int? contextSlot;
  final double? timeTaken;

  factory SwapQuoteResult.fromJson(Map<String, dynamic> json) {
    return SwapQuoteResult(
      inputMint: json['inputMint'] as String,
      inAmount: json['inAmount'] as String,
      outputMint: json['outputMint'] as String,
      outAmount: json['outAmount'] as String,
      otherAmountThreshold: json['otherAmountThreshold'] as String,
      priceImpactPct: json['priceImpactPct'] as String? ?? '0',
      routeLabels:
          (json['routeLabels'] as List<dynamic>? ?? const [])
              .map((item) => item.toString())
              .toList(),
      slippageBps: json['slippageBps'] as int? ?? 50,
      contextSlot: json['contextSlot'] as int?,
      timeTaken: (json['timeTaken'] as num?)?.toDouble(),
    );
  }
}
