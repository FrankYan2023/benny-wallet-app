import 'chain_models.dart';

// Verified 2026-09-16: https://docs.arc.io/arc/references/rpc-endpoints
// Mainnet is currently permissioned. Never silently select it for public builds.
const arcTestnetConfig = ChainConfig(
  id: 'arc-testnet',
  family: ChainFamily.evm,
  displayName: 'Arc Testnet',
  chainId: 5042002,
  isTestnet: true,
  deterministicFinality: true,
  rpcUrl: String.fromEnvironment(
    'ARC_TESTNET_RPC_URL',
    defaultValue: 'https://rpc.testnet.arc.io',
  ),
  explorerUrl: String.fromEnvironment(
    'ARC_TESTNET_EXPLORER_URL',
    defaultValue: 'https://explorer.testnet.arc.io',
  ),
  feeSymbol: 'USDC',
  feeDecimals: 18,
  nativeTokenContract: '0x3600000000000000000000000000000000000000',
  nativeTokenDecimals: 6,
  nativeTransferEmitter: '0xfffffffffffffffffffffffffffffffffffffffe',
  minimumGasPrice: 20000000000,
);

const arcMainnetConfig = ChainConfig(
  id: 'arc-mainnet',
  family: ChainFamily.evm,
  displayName: 'Arc',
  chainId: 5042,
  deterministicFinality: true,
  rpcUrl: String.fromEnvironment(
    'ARC_MAINNET_RPC_URL',
    defaultValue: 'https://rpc.mainnet.arc.io',
  ),
  explorerUrl: String.fromEnvironment(
    'ARC_MAINNET_EXPLORER_URL',
    defaultValue: 'https://explorer.arc.io',
  ),
  feeSymbol: 'USDC',
  feeDecimals: 18,
  nativeTokenContract: '0x3600000000000000000000000000000000000000',
  nativeTokenDecimals: 6,
  nativeTransferEmitter: '0xfffffffffffffffffffffffffffffffffffffffe',
  minimumGasPrice: 20000000000,
);

const configuredArcChain = bool.fromEnvironment('ENABLE_ARC_MAINNET')
    ? arcMainnetConfig
    : arcTestnetConfig;

List<String> arcRpcUrls(ChainConfig config) => [
  config.rpcUrl,
  if (config.id == arcTestnetConfig.id &&
      !const bool.fromEnvironment('ARC_DISABLE_RPC_FALLBACK'))
    'https://rpc.drpc.testnet.arc.io',
];
