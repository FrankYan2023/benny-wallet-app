import 'package:shared_types/shared_types.dart';

import '../../../core/network/api_client.dart';
import '../../portfolio/domain/entities/portfolio_view_data.dart';
import '../domain/swap_build_result.dart';
import '../domain/swap_quote_result.dart';
import '../domain/swap_token_option.dart';

class SwapRepository {
  const SwapRepository(this._apiClient);

  final BackendApiClient _apiClient;

  Future<List<SwapTokenOption>> loadTokenOptions(
    List<AssetHolding> portfolioAssets,
  ) async {
    final catalog = await _apiClient.getTokens();
    final catalogByMint = {
      for (final item in catalog.where((entry) => entry.isVisible))
        item.mintAddress: item,
    };
    final optionsByMint = <String, SwapTokenOption>{};

    for (final asset in portfolioAssets) {
      final catalogItem = catalogByMint[asset.token.mintAddress];
      optionsByMint[asset.token.mintAddress] = SwapTokenOption(
        token: TokenInfo(
          mintAddress: asset.token.mintAddress,
          symbol: catalogItem?.symbol ?? asset.token.symbol,
          name: catalogItem?.name ?? asset.token.name,
          decimals: catalogItem?.decimals ?? asset.token.decimals,
          isNative: catalogItem?.isNative ?? asset.token.isNative,
          isVisible: catalogItem?.isVisible ?? asset.token.isVisible,
        ),
        category: catalogItem?.category ?? asset.category,
        logoUrl: (asset.logoUrl != null && asset.logoUrl!.isNotEmpty)
            ? asset.logoUrl
            : (catalogItem == null || catalogItem.logoUrl.isEmpty
                  ? null
                  : catalogItem.logoUrl),
        availableBalance: asset.balance,
        rawAvailableAmount: asset.rawAmount,
        isOwned: true,
        totalValueUsd: asset.totalValueUsd,
      );
    }

    for (final item in catalog.where((entry) => entry.isVisible)) {
      optionsByMint.putIfAbsent(
        item.mintAddress,
        () => SwapTokenOption(
          token: TokenInfo(
            mintAddress: item.mintAddress,
            symbol: item.symbol,
            name: item.name,
            decimals: item.decimals,
            isNative: item.isNative,
            isVisible: item.isVisible,
          ),
          category: item.category,
          logoUrl: item.logoUrl.isEmpty ? null : item.logoUrl,
          availableBalance: 0,
          rawAvailableAmount: '0',
          isOwned: false,
          totalValueUsd: 0,
        ),
      );
    }

    final options = optionsByMint.values.toList()
      ..sort((left, right) {
        if (left.isOwned != right.isOwned) {
          return left.isOwned ? -1 : 1;
        }
        final byValue = right.totalValueUsd.compareTo(left.totalValueUsd);
        if (byValue != 0) {
          return byValue;
        }
        final byBalance = right.availableBalance.compareTo(
          left.availableBalance,
        );
        if (byBalance != 0) {
          return byBalance;
        }
        return left.token.symbol.compareTo(right.token.symbol);
      });

    return options;
  }

  Future<List<SwapTokenOption>> searchTokens(
    String query,
    List<AssetHolding> portfolioAssets, {
    Set<String> excludedCategories = const {},
  }) async {
    if (query.isEmpty) {
      return const [];
    }

    final results = await _apiClient.searchTokens(query);
    final ownedMints = {
      for (final asset in portfolioAssets) asset.token.mintAddress,
    };
    final ownedAssetsMap = {
      for (final asset in portfolioAssets) asset.token.mintAddress: asset,
    };

    return results
        .where((item) => !excludedCategories.contains(item.category))
        .map((item) {
          final isOwned = ownedMints.contains(item.mintAddress);
          final ownedAsset = ownedAssetsMap[item.mintAddress];

          return SwapTokenOption(
            token: TokenInfo(
              mintAddress: item.mintAddress,
              symbol: item.symbol,
              name: item.name,
              decimals: item.decimals,
              isNative: item.isNative,
              isVisible: item.isVisible,
            ),
            category: item.category,
            logoUrl: item.logoUrl.isEmpty ? null : item.logoUrl,
            availableBalance: isOwned ? ownedAsset?.balance ?? 0 : 0,
            rawAvailableAmount: isOwned ? ownedAsset?.rawAmount : '0',
            isOwned: isOwned,
            totalValueUsd: isOwned ? ownedAsset?.totalValueUsd ?? 0 : 0,
          );
        })
        .toList();
  }

  Future<SwapQuoteResult> quoteSwap({
    required String inputMint,
    required String outputMint,
    required String rawAmount,
    required int slippageBps,
  }) async {
    final payload = await _apiClient.quoteSwap(
      inputMint: inputMint,
      outputMint: outputMint,
      amount: rawAmount,
      slippageBps: slippageBps,
    );
    return SwapQuoteResult.fromJson(payload);
  }

  Future<SwapBuildResult> buildSwap({
    required String ownerAddress,
    required String inputMint,
    required String outputMint,
    required String rawAmount,
    required int slippageBps,
    required String priorityPreset,
  }) async {
    final payload = await _apiClient.buildSwap(
      ownerAddress: ownerAddress,
      inputMint: inputMint,
      outputMint: outputMint,
      amount: rawAmount,
      slippageBps: slippageBps,
      priorityPreset: priorityPreset,
    );
    return SwapBuildResult.fromJson(payload);
  }
}
