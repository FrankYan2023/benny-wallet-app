import 'dart:convert';
import '../lib/core/chains/arc_chain_config.dart';
import '../lib/core/chains/chain_models.dart';
import '../lib/core/chains/evm/evm_adapter.dart';
import '../lib/core/chains/evm/evm_rpc.dart';

/// Optional read-only public testnet check. No wallet, keys, faucet or broadcast.
Future<void> main(List<String> arguments) async {
  final rpc = DioEvmRpc(
    chainId: arcTestnetConfig.chainId!,
    urls: arcRpcUrls(arcTestnetConfig),
  );
  await rpc.verifyNetwork();
  final decimals = await rpc.call('eth_call', [
    {'to': arcTestnetConfig.nativeTokenContract, 'data': '0x313ce567'},
    'latest',
  ]);
  if (BigInt.parse(decimals as String) != BigInt.from(6)) {
    throw StateError('Unexpected USDC ERC20 decimals.');
  }
  final gasPrice = await rpc.call('eth_gasPrice', []);
  final block = await rpc.call('eth_blockNumber', []);
  final logs = await rpc.call('eth_getLogs', [
    {
      'address': arcTestnetConfig.nativeTransferEmitter,
      'fromBlock': block,
      'toBlock': block,
      'topics': [
        '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef',
      ],
    },
  ]);
  int? activityCount;
  if (arguments.isNotEmpty) {
    final account = ChainAccount(
      rootWalletId: 'read-only-smoke',
      chainId: arcTestnetConfig.id,
      address: arguments.single,
      canSign: false,
    );
    final adapter = EvmAdapter(
      config: arcTestnetConfig,
      rpc: rpc,
      accountReader: () async => account,
      mnemonicReader: () async => throw StateError('Read-only probe'),
    );
    if (!adapter.validateAddress(account.address)) {
      throw ArgumentError('Pass one valid public EVM address.');
    }
    activityCount = (await adapter.getActivity(account)).length;
  }
  print(
    jsonEncode({
      'network': arcTestnetConfig.displayName,
      'chainId': arcTestnetConfig.chainId,
      'usdcDecimals': 6,
      'gasPriceNativeUnits': gasPrice,
      'block': block,
      'nativeTransferEventsInBlock': (logs as List).length,
      if (activityCount != null) 'recentActivityCount': activityCount,
      'broadcasts': 0,
    }),
  );
}
