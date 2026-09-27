import 'chain_models.dart';

// Verified 2026-09-26: https://docs.arc.io/arc/references/rpc-endpoints
// Production transport uses the authenticated wallet backend. Public test RPC is explicit QA only.
const arcTestnetConfig = ChainConfig(
  id: 'arc-testnet',
  family: ChainFamily.evm,
  displayName: 'Arc Testnet',
  iconAsset: 'assets/chain_logos/arc.png',
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
  // Public fallback rejected 250-block queries in emulator QA (2026-09-24).
  maxLogBlockRange: 100,
);

const arcMainnetConfig = ChainConfig(
  id: 'arc-mainnet',
  family: ChainFamily.evm,
  displayName: 'Arc',
  iconAsset: 'assets/chain_logos/arc.png',
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
  // Mainnet fee floor is read from RPC; documented 20 Gwei is testnet-only.
  minimumGasPrice: 0,
  maxLogBlockRange: 100,
);

const configuredArcChain = bool.fromEnvironment('ARC_USE_TESTNET')
    ? arcTestnetConfig
    : arcMainnetConfig;

// Never bypass the backend for mainnet transactions.
const useDirectTestnetRpc =
    bool.fromEnvironment('ARC_USE_TESTNET') &&
    bool.fromEnvironment('ARC_DIRECT_TESTNET_RPC');

List<String> arcRpcUrls(ChainConfig config) => [
  config.rpcUrl,
  if (config.id == arcTestnetConfig.id &&
      !const bool.fromEnvironment('ARC_DISABLE_RPC_FALLBACK'))
    'https://rpc.drpc.testnet.arc.io',
];
