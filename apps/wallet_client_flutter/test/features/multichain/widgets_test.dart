import 'dart:async';
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
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final adapter = fixture.adapterFor(rpc ?? fixture.FakeRpc());
  final store = MultichainStore(MemoryStore());
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
        chainAdapterProvider(arcTestnetConfig.id).overrideWithValue(adapter),
        chainAccountProvider(arcTestnetConfig.id).overrideWith((ref) async {
          if (unsupported)
            throw StateError('External wallet cannot derive an EVM account.');
          return fixture.account;
        }),
        chainAccountProvider(
          SolanaAdapter.networkId,
        ).overrideWith((ref) async => solana),
        chainAssetsProvider(arcTestnetConfig.id).overrideWith(
          (ref) async => [
            adapter.nativeAsset.withBalance(BigInt.from(100000000)),
          ],
        ),
        chainActivityProvider(
          arcTestnetConfig.id,
        ).overrideWith((ref) => Stream.value([])),
        chainTransferControllerProvider.overrideWithValue(
          ChainTransferController(
            adapterFor: (_) => adapter,
            ensureCanSend: (_) async {},
            store: store,
            onSubmitted: (_) {},
          ),
        ),
      ],
      child: RepaintBoundary(
        key: screenshotKey,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: page),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> screenshot(WidgetTester tester, String name) async {
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
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Primary asset row'), findsOneWidget);
    expect(find.textContaining('Arc Testnet'), findsWidgets);
    await tester.tap(find.byKey(const Key('portfolio-network-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Arc Testnet').last);
    await tester.pumpAndSettle();
    expect(find.text('Primary asset row'), findsNothing);
    expect(find.textContaining('Arc Testnet'), findsWidgets);
    await tester.tap(find.byKey(const Key('portfolio-network-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Solana Mainnet').last);
    await tester.pumpAndSettle();
    expect(find.text('Primary asset row'), findsOneWidget);
    expect(find.textContaining('Arc Testnet'), findsNothing);
  });
  testWidgets(
    'shared send selects Arc inline and clears its form on network switch',
    (tester) async {
      await show(tester, const SendPage());
      expect(find.text('Send on Arc Testnet'), findsNothing);
      await tester.tap(find.byType(ChainNetworkSelector));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Arc Testnet').last);
      await tester.pumpAndSettle();
      expect(find.text('Estimate fee & review'), findsOneWidget);
      await tester.enterText(
        find.byType(TextFormField).first,
        fixture.recipient,
      );
      await tester.tap(find.byType(ChainNetworkSelector));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Solana Mainnet').last);
      await tester.pumpAndSettle();
      expect(find.text('Estimate fee & review'), findsNothing);
      await tester.tap(find.byType(ChainNetworkSelector));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Arc Testnet').last);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField).first)
            .controller!
            .text,
        isEmpty,
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
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
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
    'send reviews exact USDC amount and fee before explicit signing',
    (tester) async {
      final rpc = fixture.FakeRpc();
      await show(
        tester,
        const NetworkSendPage(chainId: 'arc-testnet'),
        rpc: rpc,
      );
      await tester.enterText(
        find.byType(TextFormField).at(0),
        fixture.recipient,
      );
      await tester.enterText(find.byType(TextFormField).at(1), '1');
      await tester.ensureVisible(find.text('Estimate fee & review'));
      await tester.tap(find.text('Estimate fee & review'));
      await tester.pumpAndSettle();
      expect(find.text('Review transfer'), findsOneWidget);
      expect(find.text('1 USDC'), findsOneWidget);
      expect(find.textContaining('ETH'), findsNothing);
      expect(rpc.calls, isNot(contains('eth_sendRawTransaction')));
      await screenshot(tester, 'arc-send-review');
      await tester.ensureVisible(find.text('Confirm & send'));
      await tester.tap(find.text('Confirm & send'));
      await tester.pumpAndSettle();
      expect(
        rpc.calls.where((method) => method == 'eth_sendRawTransaction'),
        hasLength(1),
      );
      expect(find.text('Transaction submitted'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('child mode cannot compose or confirm a transfer', (
    tester,
  ) async {
    await show(
      tester,
      const NetworkSendPage(chainId: 'arc-testnet'),
      state: unlocked.copyWith(childModeEnabled: true),
    );
    expect(find.byType(TextFormField), findsNothing);
    expect(find.text('Confirm & send'), findsNothing);
  });
  testWidgets('locked session cannot compose or confirm a transfer', (
    tester,
  ) async {
    await show(
      tester,
      const NetworkSendPage(chainId: 'arc-testnet'),
      state: unlocked.copyWith(status: WalletStatus.locked),
    );
    expect(find.byType(TextFormField), findsNothing);
    expect(find.text('Confirm & send'), findsNothing);
  });
}
