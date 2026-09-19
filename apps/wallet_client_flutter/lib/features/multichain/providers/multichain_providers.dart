import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../core/chains/arc_chain_config.dart';
import '../../../core/chains/chain_adapter.dart';
import '../../../core/chains/chain_models.dart';
import '../../../core/chains/evm/evm_adapter.dart';
import '../../../core/chains/evm/evm_key_service.dart';
import '../../../core/chains/solana_adapter.dart';
import '../../auth/domain/wallet_controller_state.dart';
import '../../auth/presentation/providers/ephemeral_store.dart';
import '../../auth/presentation/providers/wallet_controller.dart';
import '../data/chain_transfer_controller.dart';
import '../data/multichain_store.dart';

final selectedChainIdProvider = StateProvider<String>(
  (ref) => 'solana-mainnet',
);
final additionalChainConfigsProvider = Provider<List<ChainConfig>>(
  (ref) => [configuredArcChain],
);
final chainConfigsProvider = Provider<List<ChainConfig>>(
  (ref) => [
    ref.watch(chainAdapterProvider('solana-mainnet')).config,
    ...ref.watch(additionalChainConfigsProvider),
  ],
);
final multichainStoreProvider = Provider<MultichainStore>(
  (ref) => MultichainStore(ref.read(secureStoreProvider)),
);

String _readMnemonic(Ref ref, {bool forSigning = false}) {
  final state = ref.read(walletControllerProvider);
  if (!state.isUnlocked)
    throw StateError('Unlock the wallet to use this network.');
  if (forSigning && state.childModeEnabled)
    throw StateError('Sending is unavailable in child mode.');
  if (state.custody != WalletCustody.localMnemonic) {
    throw StateError(
      'This external Solana wallet does not expose a recovery phrase. EVM accounts require a locally imported recovery phrase; your Solana wallet remains unchanged.',
    );
  }
  final token = state.mnemonicTokenId;
  final mnemonic = token == null
      ? null
      : ref.read(mnemonicEphemeralStoreProvider).retrieveTemporary(token);
  if (mnemonic == null || mnemonic.isEmpty)
    throw StateError('Your session expired. Unlock the wallet again.');
  return mnemonic;
}

Future<ChainAccount> _account(Ref ref, String chainId) async {
  final state = ref.read(walletControllerProvider);
  final rootId = state.publicKey;
  if (!state.isUnlocked || rootId == null)
    throw StateError('Unlock the wallet to view its account.');
  if (chainId == 'solana-mainnet')
    return ChainAccount(
      rootWalletId: rootId,
      chainId: chainId,
      address: rootId,
      canSign:
          state.custody == WalletCustody.localMnemonic &&
          !state.childModeEnabled,
    );
  final mnemonic = _readMnemonic(ref);
  // Validate against the existing persisted Solana path before exposing a second
  // account. We never rewrite the root record or reinterpret a Solana private key.
  final originalAddress = await ref
      .read(solanaWalletServiceProvider)
      .deriveAddress(mnemonic, derivation: state.derivation);
  if (originalAddress != rootId)
    throw StateError('Recovery phrase does not match the selected wallet.');
  final address = EvmKeyService.deriveAddress(mnemonic);
  final current = ref.read(walletControllerProvider);
  if (!current.isUnlocked ||
      current.publicKey != rootId ||
      current.mnemonicTokenId != state.mnemonicTokenId) {
    throw StateError('Wallet session changed. Try again after unlocking.');
  }
  return ChainAccount(
    rootWalletId: rootId,
    chainId: chainId,
    address: address,
    canSign: !current.childModeEnabled,
  );
}

final chainAdapterProvider = Provider.family<ChainAdapter, String>((
  ref,
  chainId,
) {
  if (chainId == 'solana-mainnet')
    return SolanaAdapter(
      service: ref.read(solanaWalletServiceProvider),
      accountReader: () => _account(ref, chainId),
      mnemonicReader: () async => _readMnemonic(ref, forSigning: true),
      derivationReader: () => ref.read(walletControllerProvider).derivation,
    );
  final config = ref
      .read(additionalChainConfigsProvider)
      .where((config) => config.id == chainId)
      .firstOrNull;
  if (config == null) throw StateError('Unsupported network.');
  return EvmAdapter(
    config: config,
    accountReader: () => _account(ref, chainId),
    mnemonicReader: () async => _readMnemonic(ref, forSigning: true),
    rpcUrls: arcRpcUrls(config),
  );
});

final chainAccountProvider = FutureProvider.autoDispose
    .family<ChainAccount, String>((ref, chainId) {
      ref.watch(walletControllerProvider);
      return ref.watch(chainAdapterProvider(chainId)).getAccount();
    });

final chainTokensProvider = FutureProvider.autoDispose
    .family<List<ChainAsset>, String>((ref, chainId) async {
      final account = await ref.watch(chainAccountProvider(chainId).future);
      final tokens = await ref.read(multichainStoreProvider).tokens(account);
      final adapter = ref.watch(chainAdapterProvider(chainId));
      const bennyContract = String.fromEnvironment('ARC_BENNY_TOKEN_ADDRESS');
      if (bennyContract.isNotEmpty &&
          adapter is EvmAdapter &&
          !tokens.any(
            (token) =>
                token.contractAddress?.toLowerCase() ==
                bennyContract.toLowerCase(),
          )) {
        tokens.add(await adapter.importToken(bennyContract));
      }
      return tokens;
    });

final chainAssetsProvider = FutureProvider.autoDispose
    .family<List<ChainAsset>, String>((ref, chainId) async {
      final account = await ref.watch(chainAccountProvider(chainId).future);
      final tokens = await ref.watch(chainTokensProvider(chainId).future);
      return ref
          .watch(chainAdapterProvider(chainId))
          .getAssets(account, tokens: tokens);
    });

/// Recent on-chain window plus locally submitted transactions (including RPC
/// response-loss cases). Never scan from genesis on a mobile client.
final chainActivityProvider = StreamProvider.autoDispose
    .family<List<ChainActivity>, String>((ref, chainId) {
      final controller = StreamController<List<ChainActivity>>();
      final adapter = ref.watch(chainAdapterProvider(chainId));
      final accountFuture = ref.watch(chainAccountProvider(chainId).future);
      final store = ref.read(multichainStoreProvider);
      final tokensFuture = ref.watch(chainTokensProvider(chainId).future);
      Timer? timer;
      var disposed = false;
      Future<void> refresh() async {
        try {
          final account = await accountFuture;
          final tokens = await tokensFuture;
          final local = await store.submissions(account);
          final resolved = <ChainActivity>[];
          // Recheck pending entries and retain original ERC20 amount/recipient even
          // when the RPC transaction's 'to' is the token contract.
          for (final item in local) {
            if (disposed) return;
            if (item.status == ChainTransactionStatus.finalSuccess ||
                item.status == ChainTransactionStatus.failed) {
              resolved.add(item);
              continue;
            }
            ChainActivity? detail;
            try {
              detail = await adapter.getTransaction(account, item.hash);
            } catch (_) {
              // The signed hash remains visible even if every RPC is unreachable.
              // A missing response is not proof that the transaction failed.
            }
            final updated = ChainActivity(
              chainId: item.chainId,
              hash: item.hash,
              from: item.from,
              to: item.to,
              asset: item.asset,
              amount: item.amount,
              status: detail?.status ?? ChainTransactionStatus.unknown,
              timestamp: detail?.timestamp ?? item.timestamp,
              fee: detail?.fee,
            );
            resolved.add(updated);
            if (updated.status != item.status)
              await store.saveSubmission(account, updated);
          }
          List<ChainActivity> recent;
          try {
            recent = await adapter.getActivity(account, tokens: tokens);
          } catch (_) {
            if (resolved.isEmpty) rethrow;
            // Preserve submitted transaction visibility when log endpoints fail.
            recent = [];
          }
          final logHashes = recent.map((item) => item.hash).toSet();
          final combined =
              [
                ...recent,
                ...resolved.where((item) => !logHashes.contains(item.hash)),
              ]..sort(
                (a, b) => (b.timestamp ?? DateTime(1970)).compareTo(
                  a.timestamp ?? DateTime(1970),
                ),
              );
          if (!disposed) controller.add(combined);
        } catch (error, stack) {
          if (!disposed) controller.addError(error, stack);
        } finally {
          if (!disposed) timer = Timer(const Duration(seconds: 15), refresh);
        }
      }

      ref.onDispose(() {
        disposed = true;
        timer?.cancel();
        controller.close();
      });
      unawaited(refresh());
      return controller.stream;
    });

class TokenImportController {
  TokenImportController(this.ref);
  final Ref ref;
  Future<ChainAsset> inspectToken(String chainId, String address) async {
    await ref.read(chainAccountProvider(chainId).future);
    final adapter = ref.read(chainAdapterProvider(chainId));
    if (adapter is! EvmAdapter)
      throw StateError('Custom token import is unavailable for this network.');
    return adapter.importToken(address);
  }

  Future<void> saveToken(String chainId, ChainAsset asset) async {
    final account = await _account(ref, chainId);
    await ref.read(multichainStoreProvider).saveToken(account, asset);
    ref.invalidate(chainTokensProvider(chainId));
    ref.invalidate(chainAssetsProvider(chainId));
    ref.invalidate(chainActivityProvider(chainId));
  }
}

final tokenImportControllerProvider = Provider<TokenImportController>(
  (ref) => TokenImportController(ref),
);

final chainTransferControllerProvider = Provider<ChainTransferController>(
  (ref) => ChainTransferController(
    adapterFor: (chainId) => ref.read(chainAdapterProvider(chainId)),
    ensureCanSend: (expected) async {
      _readMnemonic(ref, forSigning: true);
      final current = await _account(ref, expected.chainId);
      if (!current.canSign ||
          current.rootWalletId != expected.rootWalletId ||
          current.address != expected.address) {
        throw StateError('Wallet changed. Review this transfer again.');
      }
    },
    store: ref.read(multichainStoreProvider),
    onSubmitted: (chainId) {
      ref.invalidate(chainTokensProvider(chainId));
      ref.invalidate(chainAssetsProvider(chainId));
      ref.invalidate(chainActivityProvider(chainId));
    },
  ),
);
