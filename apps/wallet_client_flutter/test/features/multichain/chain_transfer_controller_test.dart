import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_client_flutter/core/chains/chain_adapter.dart';
import 'package:wallet_client_flutter/core/chains/chain_models.dart';
import 'package:wallet_client_flutter/core/chains/arc_chain_config.dart';
import 'package:wallet_client_flutter/core/storage/memory_store.dart';
import 'package:wallet_client_flutter/features/multichain/data/chain_transfer_controller.dart';
import 'package:wallet_client_flutter/features/multichain/data/multichain_store.dart';

const account = ChainAccount(
  rootWalletId: 'root',
  chainId: 'arc-testnet',
  address: '0x1234',
);
final asset = ChainAsset(
  chainId: 'arc-testnet',
  symbol: 'USDC',
  name: 'USDC',
  decimals: 6,
  rawBalance: BigInt.from(10000000),
  contractAddress: arcTestnetConfig.nativeTokenContract,
  isFeeAsset: true,
);
final request = ChainTransferRequest(
  account: account,
  asset: asset,
  to: '0xabcd',
  amount: BigInt.from(1234567),
);
const hash =
    '0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';

class TestAdapter extends ChainAdapter {
  bool broadcastFails = false;
  bool beforeBroadcastSaved = false;
  int signed = 0;
  int broadcasts = 0;
  Completer<void>? signGate;
  late MultichainStore store;
  @override
  ChainConfig get config => arcTestnetConfig;
  @override
  Future<ChainAccount> getAccount() async => account;
  @override
  bool validateAddress(String address) => true;
  @override
  Future<List<ChainAsset>> getAssets(
    ChainAccount account, {
    List<ChainAsset> tokens = const [],
  }) async => [asset];
  @override
  Future<BigInt> getBalance(ChainAccount account, ChainAsset asset) async =>
      asset.rawBalance;
  @override
  Future<ChainFeeEstimate> estimateFee(ChainTransferRequest request) async =>
      ChainFeeEstimate(
        chainId: config.id,
        symbol: 'USDC',
        decimals: 18,
        maxFee: BigInt.from(420000000000000),
        estimatedFee: BigInt.from(420000000000000),
      );
  @override
  Future<PreparedChainTransaction> buildTransaction(
    ChainTransferRequest request, {
    ChainFeeEstimate? fee,
  }) async => PreparedChainTransaction(
    request: request,
    fee: fee ?? await estimateFee(request),
    payload: Object(),
  );
  @override
  Future<SignedChainTransaction> signTransaction(
    PreparedChainTransaction tx,
  ) async {
    signed++;
    if (signGate != null) await signGate!.future;
    return SignedChainTransaction(
      prepared: tx,
      encoded: 'private-signed-bytes-never-persisted',
      transactionHash: hash,
    );
  }

  @override
  Future<String> broadcastTransaction(SignedChainTransaction tx) async {
    broadcasts++;
    beforeBroadcastSaved = (await store.submissions(
      account,
    )).any((item) => item.hash == hash);
    if (broadcastFails) throw TimeoutException('Response lost');
    return hash;
  }

  @override
  Future<ChainActivity?> getTransaction(
    ChainAccount account,
    String hash,
  ) async => null;
  @override
  Future<List<ChainActivity>> getActivity(
    ChainAccount account, {
    List<ChainAsset> tokens = const [],
  }) async => [];
  @override
  Future<Uint8List> signMessage(Uint8List message) async => Uint8List(0);
}

void main() {
  late TestAdapter adapter;
  late MultichainStore store;
  late ChainTransferController controller;
  var unlocked = true;
  setUp(() {
    unlocked = true;
    store = MultichainStore(MemoryStore());
    adapter = TestAdapter()..store = store;
    controller = ChainTransferController(
      adapterFor: (_) => adapter,
      store: store,
      ensureCanSend: (_) async {
        if (!unlocked) throw StateError('Locked');
      },
      onSubmitted: (_) {},
    );
  });
  test(
    'broadcast response loss retains exact transfer and known hash before submission',
    () async {
      adapter.broadcastFails = true;
      final prepared = await controller.prepare(request);
      await expectLater(
        controller.send(prepared),
        throwsA(isA<ChainSubmissionUncertain>()),
      );
      expect(adapter.beforeBroadcastSaved, isTrue);
      final saved = (await store.submissions(account)).single;
      expect(saved.hash, hash);
      expect(saved.amount, BigInt.from(1234567));
      expect(saved.to, request.to);
      expect(saved.status, ChainTransactionStatus.pending);
      await expectLater(controller.send(prepared), throwsStateError);
      expect(adapter.broadcasts, 1);
    },
  );
  test('locking after review prevents any signing', () async {
    final prepared = await controller.prepare(request);
    unlocked = false;
    await expectLater(controller.send(prepared), throwsStateError);
    expect(adapter.signed, 0);
    expect(adapter.broadcasts, 0);
  });
  test('locking during signing prevents broadcast', () async {
    adapter.signGate = Completer<void>();
    final prepared = await controller.prepare(request);
    final sent = controller.send(prepared);
    await Future<void>.delayed(Duration.zero);
    unlocked = false;
    adapter.signGate!.complete();
    await expectLater(sent, throwsStateError);
    expect(adapter.broadcasts, 0);
  });
  test(
    'parallel confirmations serialize account signing and block duplicates',
    () async {
      final first = await controller.prepare(request);
      final second = await controller.prepare(request);
      adapter.signGate = Completer<void>();
      final sent = controller.send(first);
      await Future<void>.delayed(Duration.zero);
      await expectLater(controller.send(second), throwsStateError);
      adapter.signGate!.complete();
      expect(await sent, hash);
      expect(adapter.signed, 1);
    },
  );
  test('fabricated unreviewed payload is rejected', () async {
    final prepared = await adapter.buildTransaction(request);
    await expectLater(controller.send(prepared), throwsStateError);
    expect(adapter.signed, 0);
  });
}
