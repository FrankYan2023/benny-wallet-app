class SendResultData {
  const SendResultData({
    required this.success,
    required this.signature,
    required this.amountDisplay,
    required this.symbol,
    required this.destinationAddress,
    this.message,
  });

  final bool success;
  final String? signature;
  final String amountDisplay;
  final String symbol;
  final String destinationAddress;
  final String? message;
}
