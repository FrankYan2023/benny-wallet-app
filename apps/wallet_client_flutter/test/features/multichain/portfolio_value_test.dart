import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_client_flutter/core/chains/arc_chain_config.dart';
import 'package:wallet_client_flutter/core/chains/chain_models.dart';
import 'package:wallet_client_flutter/features/multichain/presentation/portfolio_network_widgets.dart';
import 'package:wallet_client_flutter/features/multichain/providers/multichain_providers.dart';

void main() {
  test(
    'mainnet valuation adds priced holdings and marks unknown tokens incomplete',
    () async {
      final container = ProviderContainer(
        overrides: [
          visibleAdditionalNetworksProvider.overrideWithValue([
            arcMainnetConfig,
          ]),
          chainAssetsProvider(arcMainnetConfig.id).overrideWith(
            (ref) async => [
              ChainAsset(
                chainId: arcMainnetConfig.id,
                name: 'USDC',
                symbol: 'USDC',
                decimals: 6,
                rawBalance: BigInt.from(150000000),
                fiatPrice: 0.998,
              ),
              ChainAsset(
                chainId: arcMainnetConfig.id,
                name: 'Unknown',
                symbol: 'USDC',
                decimals: 6,
                rawBalance: BigInt.from(5000000),
                contractAddress: '0xunknown',
              ),
            ],
          ),
        ],
      );
      addTearDown(container.dispose);
      final subscription = container.listen(
        additionalPortfolioValueProvider,
        (_, _) {},
      );
      addTearDown(subscription.close);
      await container.read(chainAssetsProvider(arcMainnetConfig.id).future);
      final value = container.read(additionalPortfolioValueProvider);
      expect(value.usd, closeTo(149.7, 0.00001));
      expect(value.unpriced, true);
      expect(value.hasHoldings, true);
    },
  );
  test('testnet is excluded even if an upstream supplies a fiat quote', () {
    final container = ProviderContainer(
      overrides: [
        visibleAdditionalNetworksProvider.overrideWithValue([arcTestnetConfig]),
      ],
    );
    addTearDown(container.dispose);
    final value = container.read(additionalPortfolioValueProvider);
    expect(value.usd, 0);
    expect(value.incomplete, false);
  });
  test('a backend outage is unavailable, not a known zero balance', () async {
    final container = ProviderContainer(
      overrides: [
        visibleAdditionalNetworksProvider.overrideWithValue([arcMainnetConfig]),
        chainAssetsProvider(
          arcMainnetConfig.id,
        ).overrideWith((ref) async => throw StateError('offline')),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(
      additionalPortfolioValueProvider,
      (_, _) {},
    );
    addTearDown(subscription.close);
    await expectLater(
      container.read(chainAssetsProvider(arcMainnetConfig.id).future),
      throwsStateError,
    );
    final value = container.read(additionalPortfolioValueProvider);
    expect(value.unavailable, true);
    expect(value.hasData, false);
    expect(value.incomplete, true);
  });
}
