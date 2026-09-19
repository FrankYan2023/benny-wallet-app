/// A future dapp approval UI must refuse unknown calldata until a suitable
/// decoder/simulation provides a human-readable review. This MVP has no dapp UI.
class EvmSigningIntent {
  const EvmSigningIntent({
    required this.action,
    this.target,
    this.amount,
    this.unlimitedApproval = false,
    this.requiresAdditionalReview = false,
  });
  final String action;
  final String? target;
  final BigInt? amount;
  final bool unlimitedApproval;
  final bool requiresAdditionalReview;
}

abstract class EvmSigningIntentDecoder {
  EvmSigningIntent decode(String calldata);
}

class Erc20SigningIntentDecoder implements EvmSigningIntentDecoder {
  @override
  EvmSigningIntent decode(String calldata) {
    if (RegExp(r'^0x(a9059cbb|095ea7b3)[0-9a-fA-F]{128}$').hasMatch(calldata) &&
        calldata.substring(10, 34) == '0' * 24) {
      final approve = calldata.startsWith('0x095ea7b3');
      final amount = BigInt.parse(calldata.substring(74), radix: 16);
      return EvmSigningIntent(
        action: approve ? 'approve' : 'transfer',
        target: '0x${calldata.substring(34, 74)}',
        amount: amount,
        unlimitedApproval:
            approve && amount == (BigInt.one << 256) - BigInt.one,
      );
    }
    return const EvmSigningIntent(
      action: 'unknown',
      requiresAdditionalReview: true,
    );
  }
}
