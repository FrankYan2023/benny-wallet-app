import 'package:design_system/design_system.dart';
import 'package:go_router/go_router.dart';
import 'package:wallet_client_flutter/features/send/presentation/pages/send_history_page.dart';
import 'package:wallet_client_flutter/core/network/api_client.dart';
import 'dart:async';
import 'package:wallet_client_flutter/core/widgets/network_badge.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:wallet_client_flutter/app/di/providers.dart';
import 'package:wallet_client_flutter/app/theme/app_theme.dart';
import 'package:wallet_client_flutter/core/chains/arc_chain_config.dart';
import 'package:wallet_client_flutter/core/chains/chain_models.dart';
import 'package:wallet_client_flutter/core/chains/solana_adapter.dart';
import 'package:wallet_client_flutter/core/crypto/local_cipher.dart';
import 'package:wallet_client_flutter/core/security/biometric_session_protector.dart';
import 'package:wallet_client_flutter/core/storage/memory_store.dart';
import 'package:wallet_client_flutter/features/auth/data/wallet_repository.dart';
import 'package:wallet_client_flutter/features/auth/domain/wallet_controller_state.dart';
import 'package:wallet_client_flutter/features/auth/presentation/providers/wallet_controller.dart';
import 'package:wallet_client_flutter/features/multichain/data/chain_transfer_controller.dart';
import 'package:wallet_client_flutter/features/multichain/data/multichain_store.dart';
import 'package:wallet_client_flutter/features/multichain/presentation/chain_widgets.dart';
import 'package:wallet_client_flutter/features/multichain/presentation/portfolio_network_widgets.dart';
import 'package:wallet_client_flutter/features/send/presentation/pages/send_page.dart';
import 'package:wallet_client_flutter/features/portfolio/presentation/providers/portfolio_provider.dart';
import 'package:wallet_client_flutter/features/portfolio/domain/entities/portfolio_view_data.dart';
import 'package:wallet_client_flutter/features/multichain/presentation/chain_navigation.dart';
import 'package:wallet_client_flutter/features/multichain/presentation/network_page.dart';
import 'package:wallet_client_flutter/features/notifications/presentation/pages/notifications_page.dart';
import 'package:wallet_client_flutter/features/multichain/presentation/network_send_page.dart';
import 'package:wallet_client_flutter/features/multichain/providers/multichain_providers.dart';
import 'package:wallet_client_flutter/features/receive/presentation/pages/receive_page.dart';
import 'package:wallet_client_flutter/l10n/generated/app_localizations.dart';
import '../../core/chains/evm_adapter_test.dart' as fixture;

class PendingRepository extends WalletRepository {
  PendingRepository()
    : super(MemoryStore(), LocalCipher(), const BiometricSessionProtector());
  @override
  Future<List<StoredWalletRecord>> readRecords() =>
      Completer<List<StoredWalletRecord>>().future;
}

class TestWalletController extends WalletController {
  TestWalletController(super.ref, WalletControllerState initial) {
    state = initial;
  }
}

const unlocked = WalletControllerState(
  status: WalletStatus.unlocked,
  publicKey: 'root-1',
  walletPublicKeys: ['root-1'],
  mnemonicTokenId: 'test-session',
);
const solana = ChainAccount(
  rootWalletId: 'root-1',
  chainId: 'solana-mainnet',
  address: 'HAgk14JpMQLgt6rVgv7cBQFJWFto5Dqxi472uT3DKpqk',
);
final screenshotKey = GlobalKey();

Future<void> show(
  WidgetTester tester,
  Widget page, {
  WalletControllerState state = unlocked,
  fixture.FakeRpc? rpc,
  bool unsupported = false,
  bool arcUnavailable = false,
  List<ChainAsset>? arcAssets,
  bool withSendRouter = false,
  List<ChainActivity> activity = const [],
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final adapter = fixture.adapterFor(rpc ?? fixture.FakeRpc());
  final store = MultichainStore(MemoryStore());
  final router = withSendRouter
      ? GoRouter(
          initialLocation: '/test',
          routes: [
            GoRoute(
              path: '/test',
              builder: (_, _) => Scaffold(body: page),
            ),
            GoRoute(
              path: NetworkSendPage.composeRoutePath,
              builder: (_, route) => NetworkSendPage(
                chainId: route.pathParameters['chainId']!,
                assetId: route.uri.queryParameters['asset'],
                recipientAddress: route.uri.queryParameters['recipient'],
              ),
            ),
            GoRoute(
              path: NetworkSendConfirmPage.routePath,
              builder: (_, route) => NetworkSendConfirmPage(
                transaction: route.extra as PreparedChainTransaction,
              ),
            ),
          ],
        )
      : null;
  if (router != null) addTearDown(router.dispose);
  final app = router == null
      ? MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: page),
        )
      : MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        walletRepositoryProvider.overrideWithValue(PendingRepository()),
        activePortfolioProvider.overrideWith(
          (ref) => AsyncData(
            PortfolioViewData(
              address: 'root-1',
              assets: [],
              totalValueUsd: 0,
              lastUpdatedAt: DateTime(2026),
            ),
          ),
        ),
        walletControllerProvider.overrideWith(
          (ref) => TestWalletController(ref, state),
        ),
        chainConfigsProvider.overrideWithValue([
          SolanaAdapter.chainConfig,
          arcTestnetConfig,
        ]),
        additionalChainConfigsProvider.overrideWithValue([arcTestnetConfig]),
        chainBackendProvider(arcTestnetConfig.id).overrideWithValue(null),
        chainAdapterProvider(arcTestnetConfig.id).overrideWithValue(adapter),
        chainAccountProvider(arcTestnetConfig.id).overrideWith((ref) async {
          if (unsupported)
            throw StateError('External wallet cannot derive an EVM account.');
          return fixture.account;
        }),
        chainAccountProvider(
          SolanaAdapter.networkId,
        ).overrideWith((ref) async => solana),
        chainAssetsProvider(arcTestnetConfig.id).overrideWith((ref) async {
          if (arcUnavailable) throw StateError('Arc service unavailable');
          return arcAssets ??
              [adapter.nativeAsset.withBalance(BigInt.from(100000000))];
        }),
        chainActivityProvider(
          arcTestnetConfig.id,
        ).overrideWith((ref) => Stream.value(activity)),
        chainTransferControllerProvider.overrideWithValue(
          ChainTransferController(
            adapterFor: (_) => adapter,
            ensureCanSend: (_) async {},
            store: store,
            onSubmitted: (_) {},
          ),
        ),
      ],
      child: RepaintBoundary(key: screenshotKey, child: app),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> screenshot(WidgetTester tester, String name) async {
  // Wait for local chain artwork to decode before capturing the rendered frame.
  await tester.runAsync(() async {
    for (final widget in tester.widgetList<Image>(find.byType(Image))) {
      if (widget.image is AssetImage) {
        await precacheImage(widget.image, screenshotKey.currentContext!);
      }
    }
  });
  await tester.pump();
  await tester.runAsync(() async {
    final boundary =
        screenshotKey.currentContext!.findRenderObject()!
            as RenderRepaintBoundary;
    final rendered = await boundary.toImage();
    final bytes = await rendered.toByteData(format: ui.ImageByteFormat.png);
    final directory = Directory('build/milestone2_qa');
    await directory.create(recursive: true);
    await File(
      '${directory.path}/$name.png',
    ).writeAsBytes(bytes!.buffer.asUint8List());
    rendered.dispose();
  });
}

void main() {
  test(
    'receive history preserves Solana and routes other networks correctly',
    () {
      expect(
        receiveHistoryPath(SolanaAdapter.networkId),
        ReceivedHistoryPage.routePath,
      );
      expect(
        receiveHistoryPath(arcTestnetConfig.id),
        networkPath(arcTestnetConfig.id),
      );
      expect(receiveHistoryPath('future-evm'), networkPath('future-evm'));
    },
  );
  testWidgets(
    'child mode activity has network selection and no transfer actions',
    (tester) async {
      await show(
        tester,
        NetworkPage(chainId: arcTestnetConfig.id),
        state: unlocked.copyWith(childModeEnabled: true),
      );
      expect(find.byType(ChainNetworkSelector), findsOneWidget);
      expect(find.text('Send'), findsNothing);
      expect(find.text('Import token'), findsNothing);
    },
  );
  testWidgets('legacy send history shows Solana in list and detail', (
    tester,
  ) async {
    const item = RemoteSendHistoryItem(
      signature: 'fixture-solana-signature',
      txType: 'send',
      status: 'finalized',
      result: 'success',
      statusSource: 'rpc_sync',
      submittedAt: '2026-09-29T12:00:00Z',
      amount: '1',
    );
    await show(
      tester,
      ProviderScope(
        overrides: [
          sendHistoryProvider.overrideWith((ref) async => [item]),
          sendHistoryTokensProvider.overrideWith((ref) async => []),
        ],
        child: const SendHistoryPage(),
      ),
    );
    expect(find.text('Solana'), findsOneWidget);
    expect(
      tester.widget<NetworkBadge>(find.byType(NetworkBadge)).iconAsset,
      SolanaAdapter.chainConfig.iconAsset,
    );
    await screenshot(tester, 'solana-history-network');
    await show(
      tester,
      const SendHistoryDetailPage(data: SendHistoryDetailData(item: item)),
    );
    await tester.scrollUntilVisible(
      find.byType(NetworkBadge),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Solana'), findsOneWidget);
    expect(
      tester.widget<NetworkBadge>(find.byType(NetworkBadge)).iconAsset,
      SolanaAdapter.chainConfig.iconAsset,
    );
  });
  testWidgets(
    'activity retains its network in list and detail while another network is selected',
    (tester) async {
      final adapter = fixture.adapterFor(fixture.FakeRpc());
      await show(
        tester,
        SingleChildScrollView(
          child: ChainActivitySection(config: arcTestnetConfig),
        ),
        activity: [
          ChainActivity(
            chainId: arcTestnetConfig.id,
            hash: 'fixture-arc-hash',
            from: fixture.account.address,
            to: fixture.account.address,
            asset: adapter.nativeAsset,
            amount: BigInt.from(1000000),
            status: ChainTransactionStatus.finalSuccess,
          ),
        ],
      );
      final badge = tester.widget<NetworkBadge>(
        find.byType(NetworkBadge).first,
      );
      expect(badge.name, arcTestnetConfig.displayName);
      expect(badge.iconAsset, arcTestnetConfig.iconAsset);
      expect(find.text('Solana'), findsNothing);
      await tester.tap(find.byType(ExpansionTile));
      await tester.pumpAndSettle();
      expect(find.text('Network'), findsOneWidget);
      expect(find.text(arcTestnetConfig.displayName), findsNWidgets(2));
      await screenshot(tester, 'network-activity-labels');
    },
  );
  testWidgets(
    'unknown historical network keeps its identity instead of using selected network',
    (tester) async {
      await show(tester, const ChainNetworkIdentity(chainId: 'future-network'));
      expect(find.text('future-network'), findsOneWidget);
      expect(find.text('Solana'), findsNothing);
      expect(
        tester.widget<NetworkBadge>(find.byType(NetworkBadge)).iconAsset,
        isNull,
      );
    },
  );
  testWidgets('home defaults to both networks and filters shared asset rows', (
    tester,
  ) async {
    await show(
      tester,
      Column(
        children: [
          const PortfolioNetworkMenu(),
          Consumer(
            builder: (_, ref, _) => ref.watch(showPrimaryPortfolioProvider)
                ? const Text('Primary asset row')
                : const SizedBox.shrink(),
          ),
          const AdditionalAssetRows(),
        ],
      ),
    );
    expect(
      find.byKey(const Key('portfolio-all-networks-icon')),
      findsOneWidget,
    );
    expect(find.text('Primary asset row'), findsOneWidget);
    expect(find.textContaining('Arc Testnet'), findsWidgets);
    await tester.tap(find.byKey(const Key('portfolio-network-menu')));
    await tester.pumpAndSettle();
    await screenshot(tester, 'home-network-menu-matched');
    await tester.tap(find.text('Arc Testnet').last);
    await tester.pumpAndSettle();
    expect(find.text('Primary asset row'), findsNothing);
    expect(find.textContaining('Arc Testnet'), findsWidgets);
    await tester.tap(find.byKey(const Key('portfolio-network-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Solana').last);
    await tester.pumpAndSettle();
    expect(find.text('Primary asset row'), findsOneWidget);
    expect(find.textContaining('Arc Testnet'), findsNothing);
  });
  testWidgets(
    'Arc outage does not hide primary assets or prevent network selection',
    (tester) async {
      await show(
        tester,
        Column(
          children: [
            const PortfolioNetworkMenu(),
            Consumer(
              builder: (_, ref, _) => ref.watch(showPrimaryPortfolioProvider)
                  ? const Text('Primary asset row')
                  : const SizedBox.shrink(),
            ),
            const AdditionalAssetRows(),
          ],
        ),
        arcUnavailable: true,
      );
      expect(find.text('Primary asset row'), findsOneWidget);
      expect(find.textContaining('Arc service unavailable'), findsOneWidget);
      await tester.tap(find.byKey(const Key('portfolio-network-menu')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Solana').last);
      await tester.pumpAndSettle();
      expect(find.text('Primary asset row'), findsOneWidget);
      expect(find.textContaining('Arc service unavailable'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'unsupported Arc custody does not block original Solana receive',
    (tester) async {
      await show(
        tester,
        const ReceivePage(),
        unsupported: true,
        arcUnavailable: true,
      );
      expect(find.text(solana.address), findsOneWidget);
      expect(find.byType(QrImageView), findsOneWidget);
      await tester.tap(find.byType(ChainNetworkSelector));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Arc Testnet').last);
      await tester.pumpAndSettle();
      expect(find.textContaining('External wallet cannot'), findsOneWidget);
      expect(find.byType(QrImageView), findsNothing);
      await tester.tap(find.byType(ChainNetworkSelector));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Solana').last);
      await tester.pumpAndSettle();
      expect(find.text(solana.address), findsOneWidget);
      expect(find.byType(QrImageView), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'shared send lists spendable Arc assets and opens the selected asset compose route',
    (tester) async {
      final adapter = fixture.adapterFor(fixture.FakeRpc());
      await show(
        tester,
        const SendPage(
          chainId: 'arc-testnet',
          recipientAddress: fixture.recipient,
        ),
        arcAssets: [
          adapter.nativeAsset.withBalance(BigInt.from(100000000)),
          ChainAsset(
            chainId: arcTestnetConfig.id,
            symbol: 'BENNY',
            name: 'Benny',
            decimals: 9,
            contractAddress: '0x1111111111111111111111111111111111111111',
            rawBalance: BigInt.zero,
          ),
        ],
        withSendRouter: true,
      );
      expect(find.text('Send on Arc Testnet'), findsNothing);
      expect(find.byType(TokenRow), findsOneWidget);
      expect(find.text('BENNY'), findsNothing);
      expect(find.byType(TextField), findsNothing);
      expect(find.text('Next'), findsNothing);
      await screenshot(tester, 'arc-send-assets');
      await tester.tap(find.byType(TokenRow));
      await tester.pumpAndSettle();
      expect(find.text('Send USDC'), findsOneWidget);
      expect(find.text('Arc Testnet'), findsOneWidget);
      expect(find.byType(ChainNetworkSelector), findsNothing);
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.textContaining('Solana'), findsNothing);
      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller!.text,
        fixture.recipient,
      );
      expect(find.byTooltip('Scan QR code'), findsOneWidget);
      expect(find.text('MAX'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Estimate fee & review'), findsNothing);
      await screenshot(tester, 'arc-send-compose');
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(TokenRow), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'zero-balance Arc send has the same empty asset selection as Solana',
    (tester) async {
      final adapter = fixture.adapterFor(fixture.FakeRpc());
      await show(
        tester,
        const SendPage(),
        arcAssets: [adapter.nativeAsset.withBalance(BigInt.zero)],
      );
      expect(find.text('No assets available to send.'), findsOneWidget);
      await tester.tap(find.byType(ChainNetworkSelector));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Arc Testnet').last);
      await tester.pumpAndSettle();
      expect(find.text('No assets available to send.'), findsOneWidget);
      expect(find.byType(TokenRow), findsNothing);
      expect(find.byType(TextField), findsNothing);
      expect(find.text('Next'), findsNothing);
      await tester.tap(find.byType(ChainNetworkSelector));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Solana').last);
      await tester.pumpAndSettle();
      expect(find.text('No assets available to send.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'missing selected Arc asset cannot silently compose another token',
    (tester) async {
      await show(
        tester,
        const NetworkSendPage(
          chainId: 'arc-testnet',
          assetId: 'arc-testnet:missing-token',
        ),
      );
      expect(find.text('Asset not found.'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      expect(find.text('Next'), findsNothing);
      expect(
        find.textContaining(arcTestnetConfig.nativeTokenContract!),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    },
  );
  setUpAll(() async {
    for (final entry in {
      'Manrope': 'assets/fonts/Manrope/Manrope-wght.ttf',
      'Sora': 'assets/fonts/Sora/Sora-wght.ttf',
      'Plus Jakarta Sans':
          'assets/fonts/PlusJakartaSans/PlusJakartaSans-wght.ttf',
      'MaterialIcons': 'fonts/MaterialIcons-Regular.otf',
    }.entries) {
      await (FontLoader(
        entry.key,
      )..addFont(rootBundle.load(entry.value))).load();
    }
  });
  testWidgets(
    'receive switches QR/address with explicit network and no stale Solana address',
    (tester) async {
      await show(tester, const ReceivePage());
      expect(find.text(solana.address), findsOneWidget);
      await tester.tap(find.byType(ChainNetworkSelector));
      await tester.pumpAndSettle();
      await screenshot(tester, 'receive-network-menu-matched');
      await tester.tap(find.text('Arc Testnet').last);
      await tester.pumpAndSettle();
      expect(find.text(fixture.address), findsOneWidget);
      expect(find.text(solana.address), findsNothing);
      expect(
        find.text('Only receive assets on Arc Testnet at this address.'),
        findsOneWidget,
      );
      expect(find.byType(QrImageView), findsOneWidget);
      expect(tester.takeException(), isNull);
      await screenshot(tester, 'arc-receive');
    },
  );
  testWidgets(
    'unsupported custody shows error instead of another networks address',
    (tester) async {
      await show(
        tester,
        const Scaffold(body: ChainReceivePanel(config: arcTestnetConfig)),
        unsupported: true,
      );
      expect(find.byType(QrImageView), findsNothing);
      expect(find.textContaining('External wallet cannot'), findsOneWidget);
    },
  );
  testWidgets(
    'Arc compose rejects wrong addresses, nonpositive amounts and insufficient balance before estimation',
    (tester) async {
      final rpc = fixture.FakeRpc();
      final adapter = fixture.adapterFor(rpc);
      await show(
        tester,
        NetworkSendPage(
          chainId: 'arc-testnet',
          assetId: adapter.nativeAsset.id,
        ),
        rpc: rpc,
        withSendRouter: true,
      );
      await tester.enterText(find.byType(TextField).at(0), 'invalid-address');
      await tester.enterText(find.byType(TextField).at(1), '1');
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(
        find.text('Enter a valid address for this network.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(0), fixture.recipient);
      for (final amount in ['0', '-1', 'invalid']) {
        await tester.enterText(find.byType(TextField).at(1), amount);
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
        expect(find.text('Enter a valid amount.'), findsOneWidget);
        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle();
      }
      await tester.enterText(find.byType(TextField).at(1), '101');
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Insufficient balance.'), findsOneWidget);
      expect(rpc.calls, isNot(contains('eth_estimateGas')));
      expect(rpc.calls, isNot(contains('eth_sendRawTransaction')));
      expect(find.text('Confirm send'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'Arc Next reviews exact amount and fee, Cancel preserves input, Send explicitly submits',
    (tester) async {
      final rpc = fixture.FakeRpc();
      final adapter = fixture.adapterFor(rpc);
      await show(
        tester,
        NetworkSendPage(
          chainId: 'arc-testnet',
          assetId: adapter.nativeAsset.id,
        ),
        rpc: rpc,
        withSendRouter: true,
      );
      await tester.enterText(find.byType(TextField).at(0), fixture.recipient);
      await tester.enterText(find.byType(TextField).at(1), '1');
      await tester.ensureVisible(find.text('Next'));
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Confirm send'), findsOneWidget);
      expect(find.text('1 USDC'), findsOneWidget);
      expect(find.text('Arc Testnet'), findsOneWidget);
      expect(find.text(fixture.recipient), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      expect(find.textContaining('ETH'), findsNothing);
      expect(rpc.calls, isNot(contains('eth_sendRawTransaction')));
      await screenshot(tester, 'arc-send-review');
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Send USDC'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField).at(0)).controller!.text,
        fixture.recipient,
      );
      expect(
        tester.widget<TextField>(find.byType(TextField).at(1)).controller!.text,
        '1',
      );
      expect(rpc.calls, isNot(contains('eth_sendRawTransaction')));
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Confirm send'), findsOneWidget);
      await tester.tap(find.text('Send'));
      await tester.pumpAndSettle();
      expect(
        rpc.calls.where((method) => method == 'eth_sendRawTransaction'),
        hasLength(1),
      );
      expect(find.text('Submitted'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('Arc submission blocks duplicate Send and back while busy', (
    tester,
  ) async {
    final rpc = fixture.FakeRpc();
    final adapter = fixture.adapterFor(rpc);
    final broadcast = Completer<dynamic>();
    rpc.handlers['eth_sendRawTransaction'] = (_) => broadcast.future;
    await show(
      tester,
      NetworkSendPage(chainId: 'arc-testnet', assetId: adapter.nativeAsset.id),
      rpc: rpc,
      withSendRouter: true,
    );
    await tester.enterText(find.byType(TextField).at(0), fixture.recipient);
    await tester.enterText(find.byType(TextField).at(1), '1');
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    final sendCallback = tester
        .widget<FilledButton>(
          find.ancestor(
            of: find.text('Send'),
            matching: find.byType(FilledButton),
          ),
        )
        .onPressed!;
    await tester.tap(find.text('Send'));
    await tester.pump(const Duration(milliseconds: 100));
    // A second queued tap can hold the callback from the preceding frame.
    // It must not reuse the single reviewed transaction while sending.
    sendCallback();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Submitting...'), findsOneWidget);
    expect(find.text('Send'), findsNothing);
    expect(
      rpc.calls.where((method) => method == 'eth_sendRawTransaction'),
      hasLength(1),
    );
    expect(
      tester
          .widgetList<PopScope>(find.byType(PopScope))
          .any((scope) => !scope.canPop),
      isTrue,
    );
    final buttons = tester.widgetList<FilledButton>(find.byType(FilledButton));
    expect(buttons.every((button) => button.onPressed == null), isTrue);
    await tester.binding.handlePopRoute();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Send USDC'), findsNothing);
    expect(
      rpc.calls.where((method) => method == 'eth_sendRawTransaction'),
      hasLength(1),
    );
    broadcast.complete(fixture.expectedHash);
    await tester.pumpAndSettle();
    expect(find.text('Submitted'), findsOneWidget);
    expect(
      rpc.calls.where((method) => method == 'eth_sendRawTransaction'),
      hasLength(1),
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('child mode cannot compose or confirm a transfer', (
    tester,
  ) async {
    await show(
      tester,
      const NetworkSendPage(chainId: 'arc-testnet'),
      state: unlocked.copyWith(childModeEnabled: true),
    );
    expect(find.byType(TextField), findsNothing);
    expect(find.text('Next'), findsNothing);
    expect(find.text('Confirm send'), findsNothing);
  });
  testWidgets('locked session cannot compose or confirm a transfer', (
    tester,
  ) async {
    await show(
      tester,
      const NetworkSendPage(chainId: 'arc-testnet'),
      state: unlocked.copyWith(status: WalletStatus.locked),
    );
    expect(find.byType(TextField), findsNothing);
    expect(find.text('Next'), findsNothing);
    expect(find.text('Confirm send'), findsNothing);
  });
}
