import 'dart:typed_data';

import 'chain_models.dart';

abstract class ChainAdapter {
  ChainConfig get config;
  Future<ChainAccount> getAccount();
  Future<String> getAddress() async => (await getAccount()).address;
  bool validateAddress(String address);
  Future<List<ChainAsset>> getAssets(
    ChainAccount account, {
    List<ChainAsset> tokens = const [],
  });
  Future<BigInt> getBalance(ChainAccount account, ChainAsset asset);
  Future<ChainFeeEstimate> estimateFee(ChainTransferRequest request);
  Future<PreparedChainTransaction> buildTransaction(
    ChainTransferRequest request, {
    ChainFeeEstimate? fee,
  });
  Future<SignedChainTransaction> signTransaction(
    PreparedChainTransaction transaction,
  );
  Future<String> broadcastTransaction(SignedChainTransaction transaction);
  Future<ChainActivity?> getTransaction(ChainAccount account, String hash);
  Future<List<ChainActivity>> getActivity(
    ChainAccount account, {
    List<ChainAsset> tokens = const [],
  });
  Future<Uint8List> signMessage(Uint8List message);
}
