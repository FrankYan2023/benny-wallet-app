import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:web3dart/crypto.dart';
import '../../../core/chains/chain_backend_client.dart';
import '../../../core/constants/app_constants.dart';
import '../data/backend_history_controller.dart';

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

/// Only changes that invalidate chain ownership restart network work. Labels,
/// notification settings and child-list changes do not recreate RPC clients.
typedef ChainWalletSession = ({
  bool unlocked,
  String? owner,
  String? token,
  WalletCustody custody,
  int? accountIndex,
  int? changeIndex,
});

ChainWalletSession _sessionOf(WalletControllerState state) => (
  unlocked: state.isUnlocked,
  owner: state.publicKey,
  token: state.mnemonicTokenId,
  custody: state.custody,
  accountIndex: state.derivation.accountIndex,
  changeIndex: state.derivation.changeIndex,
);

final chainWalletSessionProvider = Provider<ChainWalletSession>(
  (ref) => ref.watch(walletControllerProvider.select(_sessionOf)),
);

void _guardSession(Ref ref, ChainWalletSession expected) {
  final current = _sessionOf(ref.read(walletControllerProvider));
  if (!current.unlocked || current != expected) {
    throw StateError('Wallet session changed. Unlock again.');
  }
}

/// Public address only, retained for this unlock session. No root/key cache.
final evmAddressProvider = FutureProvider<String>((ref) async {
  final session = ref.watch(chainWalletSessionProvider);
  final state = ref.read(walletControllerProvider);
  final mnemonic = _readMnemonic(ref);
  final original = await ref
      .read(solanaWalletServiceProvider)
      .deriveAddress(mnemonic, derivation: state.derivation);
  _guardSession(ref, session);
  if (original != session.owner) {
    throw StateError('Recovery phrase does not match the selected wallet.');
  }
  final address = await EvmKeyService.deriveAddressAsync(mnemonic);
  _guardSession(ref, session);
  return address;
});

void _retainNetworkData(Ref<Object?> ref) {
  final link = ref.keepAlive();
  Timer? expiry;
  ref.onCancel(() {
    expiry?.cancel();
    expiry = Timer(const Duration(minutes: 2), link.close);
  });
  ref.onResume(() => expiry?.cancel());
  ref.onDispose(() => expiry?.cancel());
}

// Stamps contain only public ownership and an opaque session ID. They prevent
// Riverpod's previous AsyncValue from showing another unlock session's balance.
final _loadedAssetSessionsProvider = Provider(
  (ref) => <String, ChainWalletSession>{},
);

final chainAssetsDisplayProvider = Provider.autoDispose
    .family<AsyncValue<List<ChainAsset>>, String>((ref, chainId) {
      final value = ref.watch(chainAssetsProvider(chainId));
      final loaded = ref.read(_loadedAssetSessionsProvider)[chainId];
      final session = loaded == null
          ? null
          : ref.watch(chainWalletSessionProvider);
      if (loaded != null && loaded != session || value.isReloading) {
        if (value.hasError && !value.isLoading) {
          return AsyncError(
            value.error!,
            value.stackTrace ?? StackTrace.current,
          );
        }
        return const AsyncLoading();
      }
      return value;
    });

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
  // Validate ephemeral access even when the public address is already cached.
  _readMnemonic(ref);
  final session = _sessionOf(state);
  final address = await ref.read(evmAddressProvider.future);
  _guardSession(ref, session);
  final current = ref.read(walletControllerProvider);
  return ChainAccount(
    rootWalletId: rootId,
    chainId: chainId,
    address: address,
    canSign: !current.childModeEnabled,
  );
}

/// Session-scoped client; stale asynchronous work cannot bind/send for a new wallet.
final chainBackendProvider = Provider.family<ChainBackendClient?, String>((
  ref,
  chainId,
) {
  if (chainId == 'solana-mainnet' || useDirectTestnetRpc) return null;
  final config = ref
      .watch(additionalChainConfigsProvider)
      .where((c) => c.id == chainId)
      .firstOrNull;
  if (config == null) return null;
  final snapshot = ref.watch(chainWalletSessionProvider);
  void guard() => _guardSession(ref, snapshot);

  return ChainBackendClient(
    config: config,
    baseUrl: AppConstants.apiBaseUrl,
    guard: guard,
    accountReader: () => _account(ref, chainId),
    headersReader: () async {
      final session = await ref
          .read(backendSessionManagerProvider)
          .currentSession();
      guard();
      if (session.ownerAddress != snapshot.owner)
        throw StateError('Wallet session mismatch.');
      return {'Authorization': 'Bearer ${session.accessToken}'};
    },
    proofSigner: (message) async {
      guard();
      final address = await _account(ref, chainId);
      final signature = await EvmKeyService.signPersonalMessageAsync(
        _readMnemonic(ref),
        Uint8List.fromList(utf8.encode(message)),
        expectedAddress: address.address,
      );
      guard();
      return bytesToHex(signature, include0x: true);
    },
  );
});

final backendChainHistoryProvider = StateNotifierProvider.autoDispose
    .family<BackendHistoryController, AsyncValue<ChainHistoryPage>, String>((
      ref,
      chainId,
    ) {
      return BackendHistoryController(
        ref.watch(chainBackendProvider(chainId))!,
        ref.read(multichainStoreProvider),
        ref.watch(chainAccountProvider(chainId).future),
      );
    });

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
  final backend = ref.watch(chainBackendProvider(chainId));
  return EvmAdapter(
    config: config,
    accountReader: () => _account(ref, chainId),
    mnemonicReader: () async => _readMnemonic(ref, forSigning: true),
    rpcUrls: arcRpcUrls(config),
    rpc: backend == null ? null : BackendEvmRpc(backend),
  );
});

final chainAccountProvider = FutureProvider.autoDispose
    .family<ChainAccount, String>((ref, chainId) {
      ref.watch(chainWalletSessionProvider);
      ref.watch(
        walletControllerProvider.select((state) => state.childModeEnabled),
      );
      _retainNetworkData(ref);
      return ref.watch(chainAdapterProvider(chainId)).getAccount();
    });

final chainTokensProvider = FutureProvider.autoDispose
    .family<List<ChainAsset>, String>((ref, chainId) async {
      _retainNetworkData(ref);
      ref.watch(chainWalletSessionProvider);
      final account = await ref.watch(chainAccountProvider(chainId).future);
      final tokens = await ref.read(multichainStoreProvider).tokens(account);
      final adapter = ref.watch(chainAdapterProvider(chainId));
      final backend = ref.watch(chainBackendProvider(chainId));
      if (backend != null) {
        final remote = await backend.tokens();
        final byId = {for (final token in remote) token.id: token};
        for (final token in tokens) {
          if (!byId.containsKey(token.id) && token.contractAddress != null) {
            final verified = await backend.importToken(token.contractAddress!);
            byId[verified.id] = verified;
          }
        }
        return byId.values.toList();
      }
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
      _retainNetworkData(ref);
      final session = ref.watch(chainWalletSessionProvider);
      final account = await ref.watch(chainAccountProvider(chainId).future);
      final backend = ref.watch(chainBackendProvider(chainId));
      Timer? poll;
      DateTime? loadedAt;
      var listening = true;
      var disposed = false;
      void scheduleRefresh() {
        poll?.cancel();
        if (backend == null || !listening || disposed || loadedAt == null)
          return;
        final remaining =
            const Duration(seconds: 20) - DateTime.now().difference(loadedAt);
        poll = Timer(
          remaining.isNegative ? Duration.zero : remaining,
          ref.invalidateSelf,
        );
      }

      ref.onCancel(() {
        listening = false;
        poll?.cancel();
      });
      ref.onResume(() {
        listening = true;
        scheduleRefresh();
      });
      ref.onDispose(() {
        disposed = true;
        poll?.cancel();
      });
      List<ChainAsset> assets;
      if (backend != null) {
        // Portfolio already contains remote token metadata and balances. Do not
        // serialize an extra tokens request before every ordinary balance load.
        final results = await Future.wait<List<ChainAsset>>([
          backend.portfolio(),
          ref.read(multichainStoreProvider).tokens(account),
        ]);
        assets = results[0];
        final ids = assets.map((asset) => asset.id).toSet();
        final missingLocal = results[1].any(
          (token) =>
              !token.isFeeAsset &&
              token.contractAddress != null &&
              !ids.contains(token.id),
        );
        if (missingLocal) {
          // Preserve local-only custom tokens from earlier app versions. Only
          // accounts that need synchronization take this additional path.
          await ref.watch(chainTokensProvider(chainId).future);
          assets = await backend.portfolio();
        }
      } else {
        final tokens = await ref.watch(chainTokensProvider(chainId).future);
        assets = await ref
            .watch(chainAdapterProvider(chainId))
            .getAssets(account, tokens: tokens);
      }
      _guardSession(ref, session);
      ref.read(_loadedAssetSessionsProvider)[chainId] = session;
      loadedAt = DateTime.now();
      scheduleRefresh();
      return assets;
    });

/// Recent on-chain window plus locally submitted transactions (including RPC
/// response-loss cases). Never scan from genesis on a mobile client.
final chainActivityProvider = StreamProvider.autoDispose
    .family<List<ChainActivity>, String>((ref, chainId) {
      final controller = StreamController<List<ChainActivity>>();
      if (ref.watch(chainBackendProvider(chainId)) != null) {
        ref.listen<AsyncValue<ChainHistoryPage>>(
          backendChainHistoryProvider(chainId),
          (_, next) {
            next.when(
              data: (page) => controller.add(page.items),
              error: controller.addError,
              loading: () {},
            );
          },
          fireImmediately: true,
        );
        ref.onDispose(controller.close);
        return controller.stream;
      }
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
    final backend = ref.read(chainBackendProvider(chainId));
    final verified = backend == null
        ? asset
        : await backend.importToken(asset.contractAddress!);
    if (!verified.isFeeAsset)
      await ref.read(multichainStoreProvider).saveToken(account, verified);
    ref.invalidate(chainTokensProvider(chainId));
    ref.invalidate(chainAssetsProvider(chainId));
    ref.invalidate(chainActivityProvider(chainId));
    ref.invalidate(backendChainHistoryProvider(chainId));
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
      ref.invalidate(backendChainHistoryProvider(chainId));
    },
  ),
);
