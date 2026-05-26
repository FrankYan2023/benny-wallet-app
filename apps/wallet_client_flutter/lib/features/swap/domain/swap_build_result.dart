import 'swap_quote_result.dart';

class SwapBuildResult extends SwapQuoteResult {
  SwapBuildResult({
    required super.inputMint,
    required super.inAmount,
    required super.outputMint,
    required super.outAmount,
    required super.otherAmountThreshold,
    required super.priceImpactPct,
    required super.routeLabels,
    required super.slippageBps,
    required this.swapTransaction,
    required List<String> swapTransactions,
    required this.lastValidBlockHeight,
    this.prioritizationFeeLamports,
    super.contextSlot,
    super.timeTaken,
  }) : swapTransactions = List.unmodifiable(swapTransactions);

  final String swapTransaction;
  final List<String> swapTransactions;
  final int lastValidBlockHeight;
  final int? prioritizationFeeLamports;

  factory SwapBuildResult.fromJson(Map<String, dynamic> json) {
    final swapTransaction = json['swapTransaction'] as String?;
    final swapTransactions =
        (json['swapTransactions'] as List<dynamic>? ?? const [])
            .whereType<String>()
            .where((transaction) => transaction.isNotEmpty)
            .toList();
    if (swapTransactions.isEmpty &&
        swapTransaction != null &&
        swapTransaction.isNotEmpty) {
      swapTransactions.add(swapTransaction);
    }
    if (swapTransactions.isEmpty) {
      throw const FormatException('Swap build response has no transaction.');
    }

    return SwapBuildResult(
      inputMint: json['inputMint'] as String,
      inAmount: json['inAmount'] as String,
      outputMint: json['outputMint'] as String,
      outAmount: json['outAmount'] as String,
      otherAmountThreshold: json['otherAmountThreshold'] as String,
      priceImpactPct: json['priceImpactPct'] as String? ?? '0',
      routeLabels: (json['routeLabels'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      slippageBps: json['slippageBps'] as int? ?? 50,
      contextSlot: json['contextSlot'] as int?,
      timeTaken: (json['timeTaken'] as num?)?.toDouble(),
      swapTransaction: swapTransaction ?? swapTransactions.first,
      swapTransactions: swapTransactions,
      lastValidBlockHeight: json['lastValidBlockHeight'] as int,
      prioritizationFeeLamports: json['prioritizationFeeLamports'] as int?,
    );
  }
}
