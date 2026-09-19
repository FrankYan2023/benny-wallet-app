import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:web3dart/crypto.dart';
import 'package:wallet_client_flutter/core/chains/arc_chain_config.dart';
import 'package:wallet_client_flutter/core/chains/chain_models.dart';
import 'package:wallet_client_flutter/core/chains/evm/evm_adapter.dart';
import 'package:wallet_client_flutter/core/chains/evm/evm_key_service.dart';
import 'package:wallet_client_flutter/core/chains/evm/evm_rpc.dart';
import 'package:wallet_client_flutter/core/chains/evm/evm_signing_intent.dart';

// Public Hardhat test mnemonic. Never fund it. Vectors independently generated
// with ethers 6.17.0 (HDNodeWallet/signTransaction/signMessage/signTypedData).
const phrase = 'test test test test test test test test test test test junk';
const address = '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266';
const recipient = '0x000000000000000000000000000000000000dEaD';
const account = ChainAccount(
  rootWalletId: 'root-1',
  chainId: 'arc-testnet',
  address: address,
);
const expectedRaw =
    '0x02f8b3834cef5207843b9aca0085098bca5a0082ea6094360000000000000000000000000000000000000080b844a9059cbb000000000000000000000000000000000000000000000000000000000000dead00000000000000000000000000000000000000000000000000000000000f4240c080a04eb8d76591128120957c380cf588c9c15dafbb898c1f78b5a3046553dbf8eefba02a0761602696950c24cb1b1ad89319935201273d91829bba2ac72a4f9a44acd2';
const expectedHash =
    '0x73eba77110031be35d079ceef00426952494172ab2f6fc00a3ddc032005993a1';
const topic =
    '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef';
String quantity(BigInt value) => '0x${value.toRadixString(16)}';
String word(BigInt value) => value.toRadixString(16).padLeft(64, '0');
String addressTopic(String value) =>
    '0x${value.substring(2).toLowerCase().padLeft(64, '0')}';
String abiString(String value) {
  final encoded = bytesToHex(Uint8List.fromList(utf8.encode(value)));
  return '0x${word(BigInt.from(32))}${word(BigInt.from(value.length))}${encoded.padRight(((encoded.length + 63) ~/ 64) * 64, '0')}';
}

class FakeRpc implements EvmRpc {
  final calls = <String>[];
  final parameters = <String, List<List<dynamic>>>{};
  final handlers = <String, FutureOr<dynamic> Function(List<dynamic>)>{};
  bool wrongNetwork = false;
  BigInt balance = BigInt.from(100) * BigInt.from(10).pow(18);
  int nonce = 7;
  Map<String, dynamic>? tx;
  Map<String, dynamic>? receipt;
  @override
  Future<void> verifyNetwork() async {
    if (wrongNetwork) throw const EvmNetworkMismatch();
  }

  @override
  Future<dynamic> call(String method, List<dynamic> params) async {
    calls.add(method);
    parameters.putIfAbsent(method, () => []).add(params);
    if (handlers.containsKey(method)) return handlers[method]!(params);
    switch (method) {
      case 'eth_getBalance':
        return quantity(balance);
      case 'eth_gasPrice':
        return quantity(BigInt.from(30000000000));
      case 'eth_feeHistory':
        return {
          'baseFeePerGas': ['0x4a817c800'],
          'reward': [
            ['0x3b9aca00'],
          ],
        };
      case 'eth_estimateGas':
        return '0xc350';
      case 'eth_getTransactionCount':
        return quantity(BigInt.from(nonce));
      case 'eth_sendRawTransaction':
        return bytesToHex(
          keccak256(hexToBytes(params.single as String)),
          include0x: true,
        );
      case 'eth_getTransactionByHash':
        return tx;
      case 'eth_getTransactionReceipt':
        return receipt;
      case 'eth_getBlockByNumber':
        return {'number': '0x64', 'timestamp': '0x64'};
      case 'eth_blockNumber':
        return '0x7d0';
      case 'eth_getLogs':
        return [];
      case 'eth_getCode':
        return '0x6000';
      case 'eth_call':
        final data = (params.first as Map)['data'] as String;
        if (data == '0x06fdde03') return abiString('Benny Token');
        if (data == '0x95d89b41') return abiString('BENNY');
        if (data == '0x313ce567') return '0x${word(BigInt.from(9))}';
        if (data.startsWith('0x70a08231'))
          return '0x${word(BigInt.from(5000000000))}';
        throw StateError('Unexpected token call');
      default:
        throw StateError('Unexpected RPC $method');
    }
  }
}

EvmAdapter adapterFor(
  FakeRpc rpc, {
  ChainConfig config = arcTestnetConfig,
  Future<ChainAccount> Function()? reader,
  String mnemonic = phrase,
}) => EvmAdapter(
  config: config,
  rpc: rpc,
  accountReader: reader ?? () async => account,
  mnemonicReader: () async => mnemonic,
);

ChainTransferRequest requestFor(
  EvmAdapter adapter, {
  ChainAsset? asset,
  BigInt? amount,
}) => ChainTransferRequest(
  account: account,
  asset: asset ?? adapter.nativeAsset,
  to: recipient,
  amount: amount ?? BigInt.from(1000000),
);

Map<String, dynamic> typedData() => {
  'types': {
    'EIP712Domain': [
      {'name': 'name', 'type': 'string'},
      {'name': 'version', 'type': 'string'},
      {'name': 'chainId', 'type': 'uint256'},
      {'name': 'verifyingContract', 'type': 'address'},
    ],
    'Payment': [
      {'name': 'recipient', 'type': 'address'},
      {'name': 'amount', 'type': 'uint256'},
    ],
  },
  'primaryType': 'Payment',
  'domain': {
    'name': 'Benny Wallet',
    'version': '1',
    'chainId': 5042002,
    'verifyingContract': '0x3600000000000000000000000000000000000000',
  },
  'message': {'recipient': recipient, 'amount': '1000000'},
};

void main() {
  test('BIP44 derivation matches independent Ethereum vector', () {
    expect(EvmKeyService.deriveAddress(phrase), address);
    expect(
      bytesToHex(EvmKeyService.derivePrivateKey(phrase)),
      'ac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80',
    );
    expect(
      () => EvmKeyService.deriveAddress('not a recovery phrase'),
      throwsFormatException,
    );
  });

  test('EVM address rejects bad EIP55 mixed case, zero and missing prefix', () {
    final adapter = adapterFor(FakeRpc());
    expect(adapter.validateAddress(address), isTrue);
    expect(adapter.validateAddress(address.toLowerCase()), isTrue);
    expect(
      adapter.validateAddress(address.replaceFirst('f39F', 'F39F')),
      isFalse,
    );
    expect(adapter.validateAddress('0x${'0' * 40}'), isFalse);
    expect(adapter.validateAddress(address.substring(2)), isFalse);
  });

  test(
    'native/ERC20 USDC aliases deduplicate and preserve fee dust separately',
    () async {
      final rpc = FakeRpc()..balance += BigInt.from(123);
      final adapter = adapterFor(rpc);
      final assets = await adapter.getAssets(
        account,
        tokens: [
          adapter.nativeAsset,
          ChainAsset(
            chainId: account.chainId,
            symbol: 'USDC',
            name: 'USDC',
            decimals: 18,
            rawBalance: BigInt.zero,
          ),
        ],
      );
      expect(assets, hasLength(1));
      expect(assets.single.decimals, 6);
      expect(assets.single.rawBalance, BigInt.from(100000000));
      expect(await adapter.getNativeBalance(account), rpc.balance);
      expect(
        (await adapter.importToken(arcTestnetConfig.nativeTokenContract!)).id,
        adapter.nativeAsset.id,
      );
      expect(rpc.calls, isNot(contains('eth_call')));
    },
  );

  test(
    'custom ERC20 metadata, exact balance and ABI transfer encoding',
    () async {
      final rpc = FakeRpc();
      final adapter = adapterFor(rpc);
      final token = await adapter.importToken(recipient);
      expect(token.symbol, 'BENNY');
      expect(token.decimals, 9);
      expect(await adapter.getBalance(account, token), BigInt.from(5000000000));
      await adapter.estimateFee(
        requestFor(adapter, asset: token, amount: BigInt.from(123)),
      );
      final call = rpc.parameters['eth_estimateGas']!.single.single as Map;
      expect(call['to'], recipient.toLowerCase());
      expect(call['value'], '0x0');
      expect(
        call['data'],
        '0xa9059cbb${recipient.substring(2).toLowerCase().padLeft(64, '0')}${word(BigInt.from(123))}',
      );
    },
  );

  test(
    'invalid metadata decimals, malformed ABI and non-contract import fail',
    () async {
      final rpc = FakeRpc();
      final adapter = adapterFor(rpc);
      rpc.handlers['eth_getCode'] = (_) => '0x';
      await expectLater(adapter.importToken(recipient), throwsFormatException);
      rpc.handlers.remove('eth_getCode');
      rpc.handlers['eth_call'] = (p) => (p.first as Map)['data'] == '0x313ce567'
          ? '0x${word(BigInt.from(255))}'
          : abiString('TEST');
      await expectLater(adapter.importToken(recipient), throwsFormatException);
      rpc.handlers['eth_call'] = (_) => '0x';
      await expectLater(
        adapter.importToken(recipient),
        throwsA(isA<EvmRpcException>()),
      );
    },
  );

  test(
    'fee estimation applies Arc floor and reserves combined USDC spend',
    () async {
      final rpc = FakeRpc();
      final adapter = adapterFor(rpc);
      final fee = await adapter.estimateFee(requestFor(adapter));
      expect(fee.gasLimit, BigInt.from(60000));
      expect(fee.maxFeePerGas, BigInt.from(41000000000));
      expect(fee.maxFee, BigInt.from(2460000000000000));
      rpc.handlers['eth_gasPrice'] = (_) => '0x1';
      rpc.handlers['eth_feeHistory'] = (_) =>
          throw const EvmRpcException('unsupported', code: -32601);
      expect(
        (await adapter.estimateFee(requestFor(adapter))).maxFeePerGas!,
        greaterThanOrEqualTo(BigInt.from(20000000000)),
      );
      rpc.balance = BigInt.from(
        10,
      ).pow(18); // exactly the transfer, no gas headroom
      await expectLater(
        adapter.estimateFee(requestFor(adapter)),
        throwsStateError,
      );
    },
  );

  test('custom token needs both token balance and USDC fee balance', () async {
    final rpc = FakeRpc();
    final adapter = adapterFor(rpc);
    final token = await adapter.importToken(recipient);
    await expectLater(
      adapter.estimateFee(
        requestFor(adapter, asset: token, amount: BigInt.from(6000000000)),
      ),
      throwsStateError,
    );
    rpc.balance = BigInt.zero;
    await expectLater(
      adapter.estimateFee(requestFor(adapter, asset: token)),
      throwsStateError,
    );
  });

  test(
    'typed EIP1559 envelope and hash match independent ethers vector',
    () async {
      final rpc = FakeRpc();
      final adapter = adapterFor(rpc);
      final prepared = await adapter.buildTransaction(requestFor(adapter));
      final signed = await adapter.signTransaction(prepared);
      expect(signed.encoded, expectedRaw);
      expect(signed.transactionHash, expectedHash);
      expect(
        rpc.parameters['eth_getTransactionCount']!.every(
          (p) => p.last == 'pending',
        ),
        isTrue,
      );
      expect(await adapter.broadcastTransaction(signed), expectedHash);
      expect(await adapter.broadcastTransaction(signed), expectedHash);
      expect(
        rpc.calls.where((m) => m == 'eth_sendRawTransaction'),
        hasLength(1),
      );
    },
  );

  test(
    'network mismatch, wrong root mnemonic, stale nonce prevent signing',
    () async {
      final rpc = FakeRpc();
      final adapter = adapterFor(rpc);
      final prepared = await adapter.buildTransaction(requestFor(adapter));
      rpc.wrongNetwork = true;
      await expectLater(
        adapter.signTransaction(prepared),
        throwsA(isA<EvmNetworkMismatch>()),
      );
      rpc.wrongNetwork = false;
      final wrong = adapterFor(
        rpc,
        mnemonic:
            'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about',
      );
      await expectLater(wrong.signTransaction(prepared), throwsStateError);
      rpc.nonce = 8;
      await expectLater(adapter.signTransaction(prepared), throwsStateError);
      expect(rpc.calls, isNot(contains('eth_sendRawTransaction')));
    },
  );

  test('altered reviewed amount or signed envelope cannot broadcast', () async {
    final rpc = FakeRpc();
    final adapter = adapterFor(rpc);
    final prepared = await adapter.buildTransaction(requestFor(adapter));
    final changed = PreparedChainTransaction(
      request: requestFor(adapter, amount: BigInt.two),
      fee: prepared.fee,
      payload: prepared.payload,
    );
    await expectLater(adapter.signTransaction(changed), throwsStateError);
    final signed = await adapter.signTransaction(prepared);
    await expectLater(
      adapter.broadcastTransaction(
        SignedChainTransaction(
          prepared: prepared,
          encoded: '${signed.encoded}00',
          transactionHash: signed.transactionHash,
        ),
      ),
      throwsStateError,
    );
    expect(rpc.calls, isNot(contains('eth_sendRawTransaction')));
  });

  test(
    'concurrent duplicate broadcast and ambiguous response never resubmit',
    () async {
      final rpc = FakeRpc();
      final adapter = adapterFor(rpc);
      final signed = await adapter.signTransaction(
        await adapter.buildTransaction(requestFor(adapter)),
      );
      final blocked = Completer<dynamic>();
      rpc.handlers['eth_sendRawTransaction'] = (_) => blocked.future;
      final first = adapter.broadcastTransaction(signed);
      await Future<void>.delayed(Duration.zero);
      await expectLater(adapter.broadcastTransaction(signed), throwsStateError);
      blocked.completeError(const EvmRpcException('response interrupted'));
      await expectLater(first, throwsA(isA<EvmRpcException>()));
      expect(await adapter.broadcastTransaction(signed), expectedHash);
      expect(
        rpc.calls.where((m) => m == 'eth_sendRawTransaction'),
        hasLength(1),
      );
    },
  );

  test(
    'Arc receipt pending, success and reverted failure are distinguished',
    () async {
      final rpc = FakeRpc()
        ..tx = {
          'from': address,
          'to': recipient,
          'input': '0x',
          'value': '0xde0b6b3a7640000',
        };
      final adapter = adapterFor(rpc);
      expect(
        (await adapter.getTransaction(account, expectedHash))!.status,
        ChainTransactionStatus.pending,
      );
      rpc.receipt = {
        'blockNumber': '0x64',
        'status': '0x1',
        'gasUsed': '0x5208',
        'effectiveGasPrice': '0x4a817c800',
      };
      final activity = (await adapter.getTransaction(account, expectedHash))!;
      expect(activity.status, ChainTransactionStatus.finalSuccess);
      expect(activity.amount, BigInt.from(1000000));
      expect(activity.fee, BigInt.from(420000000000000));
      rpc.receipt!['status'] = '0x0';
      expect(
        (await adapter.getTransaction(account, expectedHash))!.status,
        ChainTransactionStatus.failed,
      );
    },
  );

  test(
    'other EVM networks await finalized block rather than Arc finality',
    () async {
      const config = ChainConfig(
        id: 'arc-testnet',
        family: ChainFamily.evm,
        displayName: 'Example EVM',
        rpcUrl: 'https://example.org',
        explorerUrl: 'https://example.org',
        feeSymbol: 'ETH',
        feeDecimals: 18,
        chainId: 1,
      );
      final rpc = FakeRpc()
        ..tx = {'from': address, 'to': recipient, 'input': '0x', 'value': '0x1'}
        ..receipt = {'blockNumber': '0x65', 'status': '0x1'};
      final adapter = adapterFor(rpc, config: config);
      expect(
        (await adapter.getTransaction(account, expectedHash))!.status,
        ChainTransactionStatus.pending,
      );
      rpc.receipt!['blockNumber'] = '0x64';
      expect(
        (await adapter.getTransaction(account, expectedHash))!.status,
        ChainTransactionStatus.finalSuccess,
      );
    },
  );

  test(
    'bounded history deduplicates incoming/outgoing logs and excludes USDC ERC20 alias',
    () async {
      final rpc = FakeRpc()
        ..receipt = {'blockNumber': '0x7d0', 'status': '0x1'};
      final adapter = adapterFor(rpc);
      final log = {
        'address': arcTestnetConfig.nativeTransferEmitter,
        'transactionHash': expectedHash,
        'blockNumber': '0x7d0',
        'logIndex': '0x0',
        'removed': false,
        'topics': [topic, addressTopic(address), addressTopic(recipient)],
        'data': '0x${word(BigInt.from(10).pow(18))}',
      };
      rpc.handlers['eth_getLogs'] = (_) => [log];
      final activity = await adapter.getActivity(
        account,
        tokens: [adapter.nativeAsset],
      );
      expect(activity, hasLength(1));
      expect(activity.single.amount, BigInt.from(1000000));
      expect(activity.single.asset.decimals, 6);
      final filters = rpc.parameters['eth_getLogs']!
          .map((p) => p.single as Map)
          .toList();
      expect(filters, hasLength(8));
      expect(
        filters.every(
          (p) => p['address'] == arcTestnetConfig.nativeTransferEmitter,
        ),
        isTrue,
      );
      expect(filters.first['fromBlock'], '0x3e9'); // 2000 - 1000 + 1
      log['data'] = '0x${word(BigInt.one)}';
      final dust = (await adapter.getActivity(account)).single;
      expect(dust.asset.decimals, 18);
      expect(dust.amount, BigInt.one);
    },
  );

  test(
    'tracked unknown submissions never leak to a different root wallet',
    () async {
      final rpc = FakeRpc();
      final adapter = adapterFor(rpc);
      final signed = await adapter.signTransaction(
        await adapter.buildTransaction(requestFor(adapter)),
      );
      await adapter.broadcastTransaction(signed);
      expect(
        (await adapter.getTransaction(account, expectedHash))!.status,
        ChainTransactionStatus.unknown,
      );
      const other = ChainAccount(
        rootWalletId: 'root-2',
        chainId: 'arc-testnet',
        address: recipient,
      );
      expect(await adapter.getTransaction(other, expectedHash), isNull);
      expect(await adapter.getActivity(other), isEmpty);
    },
  );

  test('EIP191 and EIP712 match independent ethers signatures', () async {
    final adapter = adapterFor(FakeRpc());
    expect(
      bytesToHex(
        await adapter.signMessage(
          Uint8List.fromList(utf8.encode('hello Benny')),
        ),
        include0x: true,
      ),
      '0x12d910701d4d766791f223c9709187bfe9b9288a3c88f956515201618ccd67741e01f3c3d7398f172f9b8f5b13865bd46ddd990a8f9927105ed9c87dd1df4eda1b',
    );
    expect(
      await adapter.signTypedData(typedData()),
      '0x063e88335020f58eda445a2ed1a277e3dbf4654b62ccb8b8e14a708b251feb0e0d07a1143b16e5915f3a2b9607a3f607856ca425a16948a34e987b8d3bc5c4bd1c',
    );
    final wrongDomain = typedData();
    (wrongDomain['domain'] as Map)['chainId'] = 1;
    await expectLater(adapter.signTypedData(wrongDomain), throwsStateError);
    expect(arcTestnetConfig.namespace, 'eip155:5042002');
  });

  test(
    'future signing intent decodes transfers and unlimited approvals, blocks blind review',
    () {
      final decoder = Erc20SigningIntentDecoder();
      final args =
          '${recipient.substring(2).toLowerCase().padLeft(64, '0')}${word((BigInt.one << 256) - BigInt.one)}';
      expect(decoder.decode('0x095ea7b3$args').unlimitedApproval, isTrue);
      expect(decoder.decode('0xa9059cbb$args').action, 'transfer');
      expect(decoder.decode('0x12345678').requiresAdditionalReview, isTrue);
    },
  );
}
