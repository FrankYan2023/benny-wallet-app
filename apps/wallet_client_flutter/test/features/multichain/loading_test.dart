import 'dart:async';
import 'package:wallet_client_flutter/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_client_flutter/app/di/providers.dart';
import 'package:wallet_client_flutter/core/chains/arc_chain_config.dart';
import 'package:wallet_client_flutter/core/chains/chain_backend_client.dart';
import 'package:wallet_client_flutter/core/chains/chain_models.dart';
import 'package:wallet_client_flutter/features/auth/data/solana_wallet_service.dart';
import 'package:wallet_client_flutter/features/auth/domain/wallet_controller_state.dart';
import 'package:wallet_client_flutter/features/auth/domain/wallet_derivation.dart';
import 'package:wallet_client_flutter/features/auth/presentation/providers/ephemeral_store.dart';
import 'package:wallet_client_flutter/features/auth/presentation/providers/wallet_controller.dart';
import 'package:wallet_client_flutter/features/multichain/data/multichain_store.dart';
import 'package:wallet_client_flutter/features/multichain/presentation/portfolio_network_widgets.dart';
import 'package:wallet_client_flutter/features/multichain/providers/multichain_providers.dart';
import 'package:wallet_client_flutter/l10n/generated/app_localizations.dart';
import 'package:wallet_client_flutter/core/storage/memory_store.dart';
import 'widgets_test.dart'
    show PendingRepository, TestWalletController, unlocked;

const id = 'arc-mainnet';
const address = '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266';
// Public unfunded Hardhat vector; never use this phrase for funds.
const phrase = 'test test test test test test test test test test test junk';
ChainAsset usdc(int amount) => ChainAsset(
  chainId: id,
  name: 'USD Coin',
  symbol: 'USDC',
  decimals: 6,
  rawBalance: BigInt.from(amount * 1000000),
  fiatPrice: 1,
  isFeeAsset: true,
  contractAddress: arcMainnetConfig.nativeTokenContract,
);
final custom = ChainAsset(
  chainId: id,
  name: 'Benny',
  symbol: 'BENNY',
  decimals: 6,
  rawBalance: BigInt.zero,
  contractAddress: '0x0000000000000000000000000000000000000002',
);

class MutableWallet extends TestWalletController {
  MutableWallet(super.ref, super.initial);
  void update(WalletControllerState value) => state = value;
}

class CountingSolana extends SolanaWalletService {
  int calls = 0;
  @override
  Future<String> deriveAddress(
    String mnemonic, {
    WalletDerivation derivation = WalletDerivation.legacy,
  }) async {
    calls++;
    return 'root-1';
  }
}

class CountingBackend extends ChainBackendClient {
  CountingBackend()
    : super(
        config: arcMainnetConfig,
        baseUrl: 'https://example.test',
        accountReader: () async => throw StateError('fixture'),
        headersReader: () async => {},
        proofSigner: (_) async => '',
        guard: () {},
      );
  int portfolios = 0, tokenReads = 0, imports = 0;
  List<ChainAsset> current = [usdc(1)];
  Future<List<ChainAsset>> Function()? load;
  @override
  Future<List<ChainAsset>> portfolio() async {
    portfolios++;
    return load == null ? current : await load!();
  }

  @override
  Future<List<ChainAsset>> tokens() async {
    tokenReads++;
    return [];
  }

  @override
  Future<ChainAsset> importToken(String contract) async {
    imports++;
    current = [usdc(1), custom];
    return custom;
  }
}

ProviderContainer setup(CountingBackend backend, {MultichainStore? store}) =>
    ProviderContainer(
      overrides: [
        walletRepositoryProvider.overrideWithValue(PendingRepository()),
        walletControllerProvider.overrideWith(
          (ref) => MutableWallet(ref, unlocked),
        ),
        additionalChainConfigsProvider.overrideWithValue([arcMainnetConfig]),
        multichainStoreProvider.overrideWithValue(
          store ?? MultichainStore(MemoryStore()),
        ),
        chainBackendProvider(id).overrideWithValue(backend),
        chainAccountProvider(id).overrideWith((ref) async {
          final session = ref.watch(chainWalletSessionProvider);
          return ChainAccount(
            rootWalletId: session.owner!,
            chainId: id,
            address: address,
          );
        }),
        visibleAdditionalNetworksProvider.overrideWithValue([arcMainnetConfig]),
      ],
    );

void main() {
  test(
    'public EVM address is derived once per unlock, not once per caller',
    () async {
      final ephemeral = MnemonicEphemeralStore();
      final token = ephemeral.store(phrase);
      final checker = CountingSolana();
      final container = ProviderContainer(
        overrides: [
          walletRepositoryProvider.overrideWithValue(PendingRepository()),
          walletControllerProvider.overrideWith(
            (ref) =>
                MutableWallet(ref, unlocked.copyWith(mnemonicTokenId: token)),
          ),
          mnemonicEphemeralStoreProvider.overrideWithValue(ephemeral),
          solanaWalletServiceProvider.overrideWithValue(checker),
        ],
      );
      addTearDown(container.dispose);
      addTearDown(ephemeral.clearAll);
      final adapter = container.read(chainAdapterProvider(id));
      final accounts = await Future.wait([
        adapter.getAccount(),
        adapter.getAccount(),
        adapter.getAccount(),
      ]);
      expect(accounts.map((a) => a.address), everyElement(address));
      expect(checker.calls, 1);
      final wallet =
          container.read(walletControllerProvider.notifier) as MutableWallet;
      wallet.update(wallet.state.copyWith(walletLabel: 'Renamed'));
      expect((await adapter.getAccount()).address, address);
      expect(checker.calls, 1);
      wallet.update(
        wallet.state.copyWith(mnemonicTokenId: ephemeral.store(phrase)),
      );
      expect(
        (await container.read(chainAdapterProvider(id)).getAccount()).address,
        address,
      );
      expect(checker.calls, 2);
    },
  );

  test(
    'portfolio skips redundant tokens read and survives a brief network switch',
    () async {
      final backend = CountingBackend();
      final container = setup(backend);
      addTearDown(container.dispose);
      var sub = container.listen(chainAssetsProvider(id), (_, _) {});
      expect(
        await container.read(chainAssetsProvider(id).future),
        hasLength(1),
      );
      sub.close();
      await container.pump();
      sub = container.listen(chainAssetsProvider(id), (_, _) {});
      addTearDown(sub.close);
      expect(
        await container.read(chainAssetsProvider(id).future),
        hasLength(1),
      );
      expect(backend.portfolios, 1);
      expect(backend.tokenReads, 0);
    },
  );

  test(
    'local-only custom tokens still synchronize and appear in portfolio',
    () async {
      final backend = CountingBackend();
      final store = MultichainStore(MemoryStore());
      await store.saveToken(
        const ChainAccount(
          rootWalletId: 'root-1',
          chainId: id,
          address: address,
        ),
        custom,
      );
      final container = setup(backend, store: store);
      addTearDown(container.dispose);
      final sub = container.listen(chainAssetsProvider(id), (_, _) {});
      addTearDown(sub.close);
      final assets = await container.read(chainAssetsProvider(id).future);
      expect(assets.map((a) => a.symbol), ['USDC', 'BENNY']);
      expect(backend.imports, 1);
      expect(backend.tokenReads, 1);
      expect(backend.portfolios, 2);
    },
  );

  test(
    'an owner change hides prior assets even if the new request fails',
    () async {
      final backend = CountingBackend();
      final container = setup(backend);
      addTearDown(container.dispose);
      final sub = container.listen(chainAssetsDisplayProvider(id), (_, _) {});
      addTearDown(sub.close);
      await container.read(chainAssetsProvider(id).future);
      expect(
        container.read(chainAssetsDisplayProvider(id)).valueOrNull,
        hasLength(1),
      );
      final gate = Completer<List<ChainAsset>>();
      gate.future.ignore();
      backend.load = () => gate.future;
      (container.read(walletControllerProvider.notifier) as MutableWallet)
          .update(
            unlocked.copyWith(
              publicKey: 'root-2',
              mnemonicTokenId: 'new-session',
            ),
          );
      await container.pump();
      expect(
        container.read(chainAssetsDisplayProvider(id)).valueOrNull,
        isNull,
      );
      expect(container.read(additionalPortfolioValueProvider).hasData, false);
      final next = container.read(chainAssetsProvider(id).future);
      final rejected = expectLater(next, throwsStateError);
      gate.completeError(StateError('offline'));
      await rejected;
      expect(
        container.read(chainAssetsDisplayProvider(id)).valueOrNull,
        isNull,
      );
      expect(container.read(additionalPortfolioValueProvider).usd, 0);
    },
  );

  testWidgets(
    'refresh retains rows and shows stale failure until retry succeeds',
    (tester) async {
      final backend = CountingBackend();
      final container = setup(backend);
      var disposed = false;
      addTearDown(() {
        if (!disposed) container.dispose();
      });
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light(),
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(body: AdditionalAssetRows()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('1 USDC'), findsOneWidget);
      final gate = Completer<List<ChainAsset>>();
      gate.future.ignore();
      backend.load = () => gate.future;
      container.invalidate(chainAssetsProvider(id));
      await tester.pump();
      expect(find.text('1 USDC'), findsOneWidget);
      await tester.pump();
      expect(find.text('Updating balance…'), findsOneWidget);
      gate.completeError(StateError('offline'));
      await tester.pumpAndSettle();
      expect(find.text('1 USDC'), findsOneWidget);
      expect(
        find.text('Balance update failed. Showing previous data.'),
        findsOneWidget,
      );
      expect(container.read(additionalPortfolioValueProvider).incomplete, true);
      backend.load = () async => [usdc(2)];
      await tester.tap(find.byTooltip('Retry'));
      await tester.pumpAndSettle();
      expect(find.text('2 USDC'), findsOneWidget);
      expect(find.textContaining('Showing previous'), findsNothing);
      expect(
        container.read(additionalPortfolioValueProvider).incomplete,
        false,
      );
      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
      disposed = true;
    },
  );
}
