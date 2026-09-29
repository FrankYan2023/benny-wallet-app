import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_types/shared_types.dart';
import 'package:wallet_client_flutter/app/di/providers.dart';
import 'package:wallet_client_flutter/core/network/api_client.dart';
import 'package:wallet_client_flutter/features/auth/presentation/providers/wallet_controller.dart';
import 'package:wallet_client_flutter/features/portfolio/domain/entities/portfolio_view_data.dart';
import 'package:wallet_client_flutter/features/portfolio/presentation/providers/portfolio_provider.dart';
import 'package:wallet_client_flutter/features/settings/data/app_settings_repository.dart';
import 'package:wallet_client_flutter/features/swap/data/swap_repository.dart';
import 'package:wallet_client_flutter/features/swap/presentation/pages/swap_page.dart';
import 'package:wallet_client_flutter/l10n/generated/app_localizations.dart';
import '../multichain/widgets_test.dart' as fixture;

const solMint = 'So11111111111111111111111111111111111111112';
const usdcMint = 'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v';
// Unfunded syntactic EVM address, deliberately shares the USDC symbol.
const evmMint = '0x0000000000000000000000000000000000000001';

RemoteTokenCatalogItem catalogToken(String mint) => RemoteTokenCatalogItem(
  mintAddress: mint,
  symbol: 'USDC',
  name: 'USDC',
  decimals: 6,
  logoUrl: '',
  isNative: false,
  isVisible: true,
  category: 'core',
);

AssetHolding holding(String mint) => AssetHolding(
  token: TokenInfo(
    mintAddress: mint,
    symbol: 'USDC',
    name: 'USDC',
    decimals: 6,
    isNative: false,
    isVisible: true,
  ),
  category: 'core',
  balance: 10,
  rawAmount: '10000000',
  priceQuote: null,
  totalValueUsd: 10,
  existsOnChain: true,
);

class MixedCatalogApi extends BackendApiClient {
  @override
  Future<List<RemoteTokenCatalogItem>> getTokens() async => [
    catalogToken(solMint),
    catalogToken(usdcMint),
    catalogToken(evmMint),
  ];
  @override
  Future<List<RemoteTokenCatalogItem>> searchTokens(String query) =>
      getTokens();

  @override
  Future<Map<String, dynamic>> quoteSwap({
    required String inputMint,
    required String outputMint,
    required String amount,
    required int slippageBps,
  }) async => throw StateError('Quote transport must not be reached');

  @override
  Future<Map<String, dynamic>> buildSwap({
    required String ownerAddress,
    required String inputMint,
    required String outputMint,
    required String amount,
    required int slippageBps,
    required String priorityPreset,
  }) async => throw StateError('Build transport must not be reached');
}

void main() {
  test(
    'Solana swap excludes EVM holdings, catalog and search results',
    () async {
      final repository = SwapRepository(MixedCatalogApi());
      final assets = [holding(usdcMint), holding(evmMint)];
      final options = await repository.loadTokenOptions(assets);
      expect(
        options.map((item) => item.token.mintAddress),
        containsAll([solMint, usdcMint]),
      );
      expect(options.any((item) => item.token.mintAddress == evmMint), isFalse);
      expect(
        options
            .singleWhere((item) => item.token.mintAddress == usdcMint)
            .availableBalance,
        10,
      );
      final results = await repository.searchTokens('USDC', assets);
      expect(results.map((item) => item.token.mintAddress), [
        solMint,
        usdcMint,
      ]);
    },
  );

  test('EVM pairs cannot reach Solana quote or build endpoints', () async {
    final repository = SwapRepository(MixedCatalogApi());
    await expectLater(
      repository.quoteSwap(
        inputMint: solMint,
        outputMint: evmMint,
        rawAmount: '1',
        slippageBps: 50,
      ),
      throwsArgumentError,
    );
    await expectLater(
      repository.buildSwap(
        ownerAddress: solMint,
        inputMint: evmMint,
        outputMint: usdcMint,
        rawAmount: '1',
        slippageBps: 50,
        priorityPreset: 'normal',
      ),
      throwsArgumentError,
    );
  });

  testWidgets('Arc swap notice is acknowledged once across page recreation', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    Future<void> openSwap() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            walletRepositoryProvider.overrideWithValue(
              fixture.PendingRepository(),
            ),
            walletControllerProvider.overrideWith(
              (ref) => fixture.TestWalletController(ref, fixture.unlocked),
            ),
            activePortfolioProvider.overrideWith((ref) => const AsyncLoading()),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: SwapPage(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }

    await openSwap();
    expect(find.text('ARC Swap coming soon'), findsOneWidget);
    expect(find.text('Solana'), findsOneWidget);
    await tester.tap(find.text('Got it'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      await AppSettingsRepository().hasAcknowledgedArcSwapNotice(),
      isTrue,
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await openSwap();
    expect(find.text('ARC Swap coming soon'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
