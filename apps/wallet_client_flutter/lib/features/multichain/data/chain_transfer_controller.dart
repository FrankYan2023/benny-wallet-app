import '../../../core/chains/chain_adapter.dart';
import '../../../core/chains/chain_models.dart';
import 'multichain_store.dart';

class ChainSubmissionUncertain implements Exception {
  const ChainSubmissionUncertain(this.hash, this.cause);
  final String? hash;
  final Object cause;
  @override
  String toString() =>
      'Submission status is uncertain. Check activity before sending again. $cause';
}

/// Owns the review -> sign -> submit boundary independently of widgets.
/// A prepared transfer is single-use and cannot be reused after a timeout.
class ChainTransferController {
  ChainTransferController({
    required this.adapterFor,
    required this.ensureCanSend,
    required this.store,
    required this.onSubmitted,
  });
  final ChainAdapter Function(String) adapterFor;
  final Future<void> Function(ChainAccount) ensureCanSend;
  final MultichainStore store;
  final void Function(String) onSubmitted;
  final Map<PreparedChainTransaction, DateTime> _reviews = Map.identity();
  final Set<String> _sending = {};

  Future<PreparedChainTransaction> prepare(ChainTransferRequest request) async {
    await ensureCanSend(request.account);
    final prepared = await adapterFor(
      request.account.chainId,
    ).buildTransaction(request);
    await ensureCanSend(request.account);
    _reviews.removeWhere(
      (_, created) =>
          DateTime.now().difference(created) > const Duration(minutes: 2),
    );
    _reviews[prepared] = DateTime.now();
    return prepared;
  }

  Future<String> send(PreparedChainTransaction prepared) async {
    final reviewedAt = _reviews.remove(prepared);
    if (reviewedAt == null ||
        DateTime.now().difference(reviewedAt) > const Duration(minutes: 2)) {
      throw StateError('Review the latest network fee before sending.');
    }
    final account = prepared.request.account;
    final key = '${account.chainId}:${account.address}';
    if (!_sending.add(key))
      throw StateError('A transfer is already being submitted.');
    try {
      await ensureCanSend(account);
      final adapter = adapterFor(account.chainId);
      final signed = await adapter.signTransaction(prepared);
      await ensureCanSend(account);
      final knownHash = signed.transactionHash;
      // Save the locally computed hash before network submission. A lost RPC
      // response must not make a possibly-broadcast transfer disappear.
      if (knownHash != null) await _record(prepared, knownHash);
      await ensureCanSend(account);
      final String hash;
      try {
        hash = await adapter.broadcastTransaction(signed);
      } catch (error) {
        throw ChainSubmissionUncertain(knownHash, error);
      }
      if (knownHash == null) await _record(prepared, hash);
      onSubmitted(account.chainId);
      return hash;
    } finally {
      _sending.remove(key);
      onSubmitted(account.chainId);
    }
  }

  Future<void> _record(PreparedChainTransaction prepared, String hash) async {
    final request = prepared.request;
    await store.saveSubmission(
      request.account,
      ChainActivity(
        chainId: request.account.chainId,
        hash: hash,
        from: request.account.address,
        to: request.to,
        asset: request.asset,
        amount: request.amount,
        status: ChainTransactionStatus.pending,
        timestamp: DateTime.now().toUtc(),
      ),
    );
  }
}
