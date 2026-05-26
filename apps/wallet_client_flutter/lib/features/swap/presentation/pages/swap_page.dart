import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/providers.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/amount_parser.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../auth/data/solana_wallet_service.dart';
import '../../../auth/presentation/pages/unlock_page.dart';
import '../../../auth/presentation/providers/wallet_controller.dart';
import '../../../onboarding/presentation/pages/welcome_page.dart';
import '../../../portfolio/domain/entities/portfolio_view_data.dart';
import '../../../portfolio/presentation/providers/portfolio_provider.dart';
import '../../../receive/presentation/pages/receive_page.dart';
import '../../data/swap_repository.dart';
import '../../domain/swap_priority_preset.dart';
import '../../domain/swap_quote_result.dart';
import '../../domain/swap_review_data.dart';
import '../../domain/swap_token_option.dart';
import 'swap_execute_page.dart';

enum SwapExperience { general, xstocks }

class SwapPage extends ConsumerStatefulWidget {
  const SwapPage({
    super.key,
    this.mode = SwapExperience.general,
    this.initialInputMint,
    this.initialOutputMint,
  });

  static const routeName = 'swap';
  static const routePath = '/swap';

  static String pathFor({String? inputMint, String? outputMint}) {
    final queryParameters = <String, String>{
      if (inputMint != null && inputMint.isNotEmpty) 'inputMint': inputMint,
      if (outputMint != null && outputMint.isNotEmpty) 'outputMint': outputMint,
    };
    if (queryParameters.isEmpty) {
      return routePath;
    }
    return Uri(path: routePath, queryParameters: queryParameters).toString();
  }

  final SwapExperience mode;
  final String? initialInputMint;
  final String? initialOutputMint;

  @override
  ConsumerState<SwapPage> createState() => _SwapPageState();
}

class XStocksSwapPage extends StatelessWidget {
  const XStocksSwapPage({
    super.key,
    this.initialInputMint,
    this.initialOutputMint,
  });

  static const routeName = 'xstocksSwap';
  static const routePath = '/xstocks';

  static String pathFor({String? inputMint, String? outputMint}) {
    final queryParameters = <String, String>{
      if (inputMint != null && inputMint.isNotEmpty) 'inputMint': inputMint,
      if (outputMint != null && outputMint.isNotEmpty) 'outputMint': outputMint,
    };
    if (queryParameters.isEmpty) {
      return routePath;
    }
    return Uri(path: routePath, queryParameters: queryParameters).toString();
  }

  final String? initialInputMint;
  final String? initialOutputMint;

  @override
  Widget build(BuildContext context) {
    return SwapPage(
      mode: SwapExperience.xstocks,
      initialInputMint: initialInputMint,
      initialOutputMint: initialOutputMint,
    );
  }
}

class _SwapPageState extends ConsumerState<SwapPage> {
  static const _solMintAddress = 'So11111111111111111111111111111111111111112';
  static const _bennyMintAddress =
      'AGk1gQfsSRZ8sfS16LUYuBm69iMfHTbCksLUZWJNpump';
  static const _presetSlippageBps = [5, 50, 100, 300, 500];
  static const _balanceTolerance = 0.000000001;
  static const _minimumSwapFeeReserveSol = 0.0015;
  static const _minimumSwapSetupReserveSol = 0.01;
  static const _insufficientSwapBalanceMessage =
      'Not enough SOL.\nNeed 0.01 SOL reserve.';
  static const _suggestedOutputMints = [
    'So11111111111111111111111111111111111111112', // SOL
    _bennyMintAddress, // BYC
    'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v', // USDC
    'Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB', // USDT
    'JUPyiwrYJFskUPiHa7hkeR8VUtAeFoSYbKedZNsDvCN', // JUP
    'jtojtomepa8beP8AuQc6eXt5FriJwfFMwQx2v2f9mCL', // JTO
    '4k3Dyjzvzp8eMZWUXbBCjEvwSkkk59S5iCNLY3QrkX6R', // RAY
    'orcaEKTdK7LKz57vaAYr9QeNsVEPfiu6QeMU1kektZE', // ORCA
    'HZ1JovNiVvGrGNiiYvEozEVgZ58xaU3RKwX8eACQBCt3', // PYTH
    'DezXAZ8z7PnrnRJjz3wXBoRgixCa6xjnB7YaB1pPB263', // BONK
    'rndrizKT3MK1iimdxRdWabcF7Zg7AR5T4nud4EkHBof', // RENDER
  ];
  static const _xStocksInputMints = {
    _solMintAddress,
    'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v',
    'Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB',
  };

  final _amountController = TextEditingController();
  final _customSlippageController = TextEditingController(text: '1.0');
  Timer? _quoteDebounce;
  Timer? _quoteRefreshTimer;

  List<SwapTokenOption> _tokenOptions = const [];
  String? _optionsSignature;
  SwapTokenOption? _inputToken;
  SwapTokenOption? _outputToken;
  SwapQuoteResult? _quote;
  String? _quoteError;
  bool _loadingOptions = false;
  bool _loadingQuote = false;
  bool _refreshingQuote = false;
  bool _buildingSwap = false;
  int _slippagePresetIndex = 1;
  bool _usingCustomSlippage = false;
  bool _slippageUserSelected = false;
  SwapPriorityPreset _priorityPreset = SwapPriorityPreset.normal;
  int _quoteRequestId = 0;

  bool get _isXStocksMode => widget.mode == SwapExperience.xstocks;
  String get _pageTitle => _isXStocksMode ? 'xStocks' : 'Swap';
  String get _receiveTitle => _isXStocksMode ? 'Buy' : 'Receive';

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onSwapInputChanged);
    _customSlippageController.addListener(_onSwapInputChanged);
  }

  @override
  void dispose() {
    _quoteDebounce?.cancel();
    _quoteRefreshTimer?.cancel();
    _amountController.dispose();
    _customSlippageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletControllerProvider);

    if (!walletState.isUnlocked) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.go(
            !walletState.hasWallet || walletState.loggedOut
                ? WelcomePage.routePath
                : UnlockPage.routePath,
          );
        }
      });

      return AppScaffold(
        title: _pageTitle,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (walletState.childModeEnabled) {
      return AppScaffold(
        title: _pageTitle,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_rounded, size: 40),
                const SizedBox(height: 12),
                const Text(
                  'Trading is unavailable in child mode.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => context.go(ReceivePage.routePath),
                  child: const Text('Open Receive'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final portfolio = ref.watch(activePortfolioProvider);

    return portfolio.when(
      data: (data) {
        final ownerAddress = walletState.publicKey;
        if (ownerAddress != null) {
          _bootstrapOptions(data, ownerAddress);
        }
        if (_loadingOptions && _tokenOptions.isEmpty) {
          return const AppScaffold(
            title: 'Swap',
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (_availableInputOptions.isEmpty) {
          return AppScaffold(
            title: _pageTitle,
            child: Center(
              child: Text(
                _isXStocksMode
                    ? 'No SOL, USDC, or USDT available to buy xStocks.'
                    : 'No assets available to swap.',
              ),
            ),
          );
        }

        final outputPreview = _outputAmountUi;
        final minReceivePreview = _minReceiveAmountUi;

        return AppScaffold(
          title: _pageTitle,
          actions: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(
                Icons.swap_horiz_rounded,
                color: AppColors.primary,
                size: 18,
              ),
            ),
          ],
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).shadowColor.withValues(alpha: 0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                        child: Column(
                          children: [
                            _SwapSectionCard(
                              tokenSelectorKey: const ValueKey(
                                'androidQaSwapPayToken',
                              ),
                              title: 'Pay',
                              amountField: _AmountDisplayButton(
                                key: const ValueKey('androidQaSwapPayAmount'),
                                value: _displayAmountText,
                                onTap: _editAmount,
                              ),
                              token: _inputToken,
                              onChooseToken: () => _pickInputTokenNoSearch(
                                context,
                                title: 'Pay with',
                                options: _availableInputOptions,
                                current: _inputToken,
                                onSelected: (token) {
                                  setState(() {
                                    _inputToken = token;
                                    if (_outputToken?.token.mintAddress ==
                                        token.token.mintAddress) {
                                      _outputToken = _defaultOutputToken(token);
                                    }
                                    _applyDefaultSlippageForPair();
                                  });
                                  _fetchInitialQuote();
                                },
                              ),
                              footer: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _payAmountUsdText,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.textPrimary,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Available ${Formatters.compactNumber(_inputToken?.availableBalance ?? 0)} ${_inputToken?.token.symbol ?? ''}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(fontSize: 10.5),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Wrap(
                                    spacing: 6,
                                    children: [
                                      _QuickAmountChip(
                                        label: '25%',
                                        onTap: () => _setInputShare(0.25),
                                      ),
                                      _QuickAmountChip(
                                        label: '50%',
                                        onTap: () => _setInputShare(0.50),
                                      ),
                                      _QuickAmountChip(
                                        label: 'Max',
                                        onTap: () => _setInputShare(1),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      height: 1,
                                      thickness: 1,
                                      color: AppColors.surfaceContainerHigh
                                          .withValues(alpha: 0.65),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  InkWell(
                                    onTap: _flipTokens,
                                    borderRadius: BorderRadius.circular(999),
                                    child: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: AppColors.secondary.withValues(
                                          alpha: 0.8,
                                        ),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.secondaryStrong
                                                .withValues(alpha: 0.12),
                                            blurRadius: 12,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.swap_vert_rounded,
                                        color: AppColors.secondaryStrong,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Divider(
                                      height: 1,
                                      thickness: 1,
                                      color: AppColors.surfaceContainerHigh
                                          .withValues(alpha: 0.65),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _SwapSectionCard(
                              tokenSelectorKey: const ValueKey(
                                'androidQaSwapReceiveToken',
                              ),
                              title: _receiveTitle,
                              amountField: SizedBox(
                                height: 54,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: FittedBox(
                                    alignment: Alignment.centerLeft,
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      outputPreview == null
                                          ? '0'
                                          : Formatters.amount(
                                              outputPreview,
                                              maxDecimals: 6,
                                            ),
                                      maxLines: 1,
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayLarge
                                          ?.copyWith(
                                            fontSize: 40,
                                            fontWeight: FontWeight.w800,
                                            height: 0.96,
                                            letterSpacing: -1.4,
                                            color: AppColors.textPrimary,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                              token: _outputToken,
                              onChooseToken: () => _isXStocksMode
                                  ? _pickInputTokenNoSearch(
                                      context,
                                      title: 'Buy xStock',
                                      options: _availableOutputOptionsDefault,
                                      current: _outputToken,
                                      onSelected: (token) {
                                        setState(() {
                                          _outputToken = token;
                                          _applyDefaultSlippageForPair();
                                        });
                                        _fetchInitialQuote();
                                      },
                                    )
                                  : _pickToken(
                                      context,
                                      title: 'Receive',
                                      options: _availableOutputOptionsDefault,
                                      current: _outputToken,
                                      portfolioAssets: data.assets,
                                      excludedCategories: const {'xstock'},
                                      onSelected: (token) {
                                        setState(() {
                                          _outputToken = token;
                                          _applyDefaultSlippageForPair();
                                        });
                                        _fetchInitialQuote();
                                      },
                                    ),
                              footer: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _loadingQuote
                                          ? 'Refreshing quote...'
                                          : _quote?.routeLabels.isNotEmpty ==
                                                true
                                          ? 'Route: ${_quote!.routeLabels.join(' · ')}'
                                          : 'Best route',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(fontSize: 10.5),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    _receiveMetaText(minReceivePreview),
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _SwapSettingsPanel(
                      rateText: _rateSummary,
                      slippageText: _slippageSummary,
                      networkFeeText: _networkFeeSummary,
                      priorityText: _priorityPreset.label,

                      onTapSlippage: _editSlippage,
                      onTapPriority: _editPriority,
                    ),
                    if (_quoteError != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.errorContainer.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Text(
                          _quoteError!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _canReviewSwap && !_buildingSwap
                      ? _reviewSwap
                      : null,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(58),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  child: Text(
                    _buildingSwap
                        ? 'Loading...'
                        : (_isXStocksMode ? 'Buy xStock' : 'Swap'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      error: (error, _) => AppScaffold(
        title: _pageTitle,
        child: Center(child: Text('Failed to load wallet assets: $error')),
      ),
      loading: () => AppScaffold(
        title: _pageTitle,
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }

  void _bootstrapOptions(PortfolioViewData data, String ownerAddress) {
    final signature = data.assets
        .map((item) => '${item.token.mintAddress}:${item.balance}')
        .join(',');
    if (_optionsSignature == signature || _loadingOptions) {
      return;
    }

    _optionsSignature = signature;
    _loadingOptions = true;
    Future<void>.microtask(() async {
      try {
        final onChainBalances = await ref
            .read(solanaWalletServiceProvider)
            .loadPortfolioBalances(ownerAddress: ownerAddress);
        final mergedAssets = _mergePortfolioAssets(
          portfolioAssets: data.assets,
          onChainBalances: onChainBalances,
        );
        final options = await ref
            .read(swapRepositoryProvider)
            .loadTokenOptions(mergedAssets);
        if (!mounted) {
          return;
        }

        setState(() {
          _tokenOptions = options;
          final inputToken = _resolvedInputToken(options);
          final outputToken = _resolvedOutputToken(options, inputToken);
          _inputToken = inputToken;
          _outputToken = outputToken;
          _applyDefaultSlippageForPair();
          _loadingOptions = false;
        });
        // Load an initial 1-unit quote for the preview UI.
        _fetchInitialQuote();
      } catch (error) {
        if (!mounted) {
          return;
        }
        setState(() {
          _loadingOptions = false;
          _quoteError = error.toString();
        });
      }
    });
  }

  List<AssetHolding> _mergePortfolioAssets({
    required List<AssetHolding> portfolioAssets,
    required List<AssetBalanceSnapshot> onChainBalances,
  }) {
    final assetsByMint = {
      for (final asset in portfolioAssets) asset.token.mintAddress: asset,
    };

    for (final snapshot in onChainBalances) {
      final existing = assetsByMint[snapshot.token.mintAddress];
      if (existing != null) {
        assetsByMint[snapshot.token.mintAddress] = AssetHolding(
          token: existing.token,
          category: existing.category,
          balance: snapshot.balance,
          rawAmount: snapshot.rawAmount,
          priceQuote: existing.priceQuote,
          totalValueUsd: existing.totalValueUsd,
          existsOnChain: snapshot.existsOnChain,
          logoUrl: existing.logoUrl,
        );
        continue;
      }

      assetsByMint[snapshot.token.mintAddress] = AssetHolding(
        token: snapshot.token,
        category: 'core',
        balance: snapshot.balance,
        rawAmount: snapshot.rawAmount,
        priceQuote: null,
        totalValueUsd: 0,
        existsOnChain: snapshot.existsOnChain,
        logoUrl: null,
      );
    }

    final merged = assetsByMint.values.toList();
    merged.sort((left, right) {
      final byValue = right.totalValueUsd.compareTo(left.totalValueUsd);
      if (byValue != 0) {
        return byValue;
      }
      final byBalance = right.balance.compareTo(left.balance);
      if (byBalance != 0) {
        return byBalance;
      }
      return left.token.symbol.compareTo(right.token.symbol);
    });
    return merged;
  }

  List<SwapTokenOption> get _availableInputOptions {
    final options = _tokenOptions
        .where((token) => token.isOwned && token.availableBalance > 0)
        .where(
          (token) => !_isXStocksMode
              ? token.category != 'xstock'
              : _xStocksInputMints.contains(token.token.mintAddress) ||
                    token.category == 'xstock',
        )
        .toList();
    options.sort((left, right) {
      final byValue = right.totalValueUsd.compareTo(left.totalValueUsd);
      if (byValue != 0) {
        return byValue;
      }
      final byBalance = right.availableBalance.compareTo(left.availableBalance);
      if (byBalance != 0) {
        return byBalance;
      }
      return left.token.symbol.compareTo(right.token.symbol);
    });
    return options;
  }

  /// Default output choices shown before broader token selection.
  List<SwapTokenOption> get _availableOutputOptionsDefault {
    if (_isXStocksMode) {
      final options =
          _tokenOptions
              .where(
                (token) =>
                    token.category == 'xstock' ||
                    _xStocksInputMints.contains(token.token.mintAddress),
              )
              .where(
                (token) =>
                    token.token.mintAddress != _inputToken?.token.mintAddress,
              )
              .toList()
            ..sort((left, right) {
              final leftIsBase = _xStocksInputMints.contains(
                left.token.mintAddress,
              );
              final rightIsBase = _xStocksInputMints.contains(
                right.token.mintAddress,
              );
              if (leftIsBase != rightIsBase) {
                return leftIsBase ? -1 : 1;
              }
              return left.token.symbol.compareTo(right.token.symbol);
            });
      return options;
    }

    final inputMint = _inputToken?.token.mintAddress;
    final eligibleOptions = _tokenOptions
        .where((token) => token.category != 'xstock')
        .where((token) => token.token.mintAddress != inputMint)
        .toList();
    final ownedOptions =
        eligibleOptions.where((token) => token.isOwned).toList()
          ..sort((left, right) {
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
    final ownedMints = {
      for (final token in ownedOptions) token.token.mintAddress,
    };
    final suggestedOptions = _suggestedOutputMints
        .where((mint) => !ownedMints.contains(mint))
        .map(
          (mint) => eligibleOptions
              .where((token) => token.token.mintAddress == mint)
              .firstOrNull,
        )
        .whereType<SwapTokenOption>()
        .toList();

    return [...ownedOptions, ...suggestedOptions];
  }

  SwapTokenOption? _resolvedInputToken(List<SwapTokenOption> options) {
    final current = _inputToken;
    if (current != null) {
      final matching = options.where(
        (item) => item.token.mintAddress == current.token.mintAddress,
      );
      if (matching.isNotEmpty) {
        return matching.first;
      }
    }
    final initial = _findOptionByMint(
      options,
      widget.initialInputMint,
      requireAvailable: true,
    );
    if (initial != null) {
      return initial;
    }
    if (_isXStocksMode) {
      final preferredBaseOptions =
          options
              .where(
                (item) => _xStocksInputMints.contains(item.token.mintAddress),
              )
              .toList()
            ..sort((left, right) {
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
      if (preferredBaseOptions.isNotEmpty) {
        return preferredBaseOptions.first;
      }
    }
    final solOption = _findOptionByMint(
      options,
      _solMintAddress,
      requireAvailable: true,
    );
    if (solOption != null) {
      return solOption;
    }
    return options
            .where((item) => item.isOwned && item.availableBalance > 0)
            .firstOrNull ??
        options.firstOrNull;
  }

  SwapTokenOption? _resolvedOutputToken(
    List<SwapTokenOption> options,
    SwapTokenOption? inputToken,
  ) {
    final current = _outputToken;
    if (current != null &&
        current.token.mintAddress != inputToken?.token.mintAddress) {
      final matching = options.where(
        (item) => item.token.mintAddress == current.token.mintAddress,
      );
      if (matching.isNotEmpty) {
        return matching.first;
      }
    }
    final initial = _findOptionByMint(options, widget.initialOutputMint);
    if (initial != null &&
        initial.token.mintAddress != inputToken?.token.mintAddress) {
      return initial;
    }
    return _defaultOutputToken(inputToken);
  }

  SwapTokenOption? _defaultOutputToken(SwapTokenOption? inputToken) {
    if (inputToken == null) {
      if (_isXStocksMode) {
        return _tokenOptions
            .where((item) => item.category == 'xstock')
            .firstOrNull;
      }
      return _findOptionByMint(_tokenOptions, _bennyMintAddress) ??
          _tokenOptions.firstOrNull;
    }
    final inputMint = inputToken.token.mintAddress;
    if (_isXStocksMode) {
      final stockOption = _tokenOptions
          .where((item) => item.category == 'xstock')
          .where((item) => item.token.mintAddress != inputMint)
          .firstOrNull;
      if (stockOption != null) {
        return stockOption;
      }
      return _tokenOptions
          .where((item) => _xStocksInputMints.contains(item.token.mintAddress))
          .where((item) => item.token.mintAddress != inputMint)
          .firstOrNull;
    }
    const preferredOutputOrder = [
      _bennyMintAddress,
      'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v',
      'So11111111111111111111111111111111111111112',
      'Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB',
    ];

    for (final mint in preferredOutputOrder) {
      if (mint == inputMint) {
        continue;
      }
      final match = _tokenOptions
          .where((item) => item.token.mintAddress == mint)
          .firstOrNull;
      if (match != null) {
        return match;
      }
    }

    return _tokenOptions
        .where((item) => item.token.mintAddress != inputMint)
        .firstOrNull;
  }

  SwapTokenOption? _findOptionByMint(
    List<SwapTokenOption> options,
    String? mintAddress, {
    bool requireAvailable = false,
  }) {
    if (mintAddress == null || mintAddress.isEmpty) {
      return null;
    }
    return options
        .where((item) => item.token.mintAddress == mintAddress)
        .where(
          (item) =>
              !requireAvailable || (item.isOwned && item.availableBalance > 0),
        )
        .firstOrNull;
  }

  void _applyDefaultSlippageForPair() {
    if (_slippageUserSelected || _usingCustomSlippage) {
      return;
    }
    final defaultBps = _defaultSlippageBpsForPair();
    final presetIndex = _presetSlippageBps.indexOf(defaultBps);
    if (presetIndex >= 0) {
      _slippagePresetIndex = presetIndex;
    }
  }

  int _defaultSlippageBpsForPair() {
    return _isMemeToken(_inputToken) || _isMemeToken(_outputToken) ? 500 : 100;
  }

  bool _isMemeToken(SwapTokenOption? token) {
    if (token == null) {
      return false;
    }
    return token.category == 'meme' ||
        token.token.mintAddress.toLowerCase().endsWith('pump');
  }

  void _onSwapInputChanged() {
    _scheduleQuote();
  }

  void _scheduleQuote() {
    _quoteDebounce?.cancel();
    _quoteRefreshTimer?.cancel();
    if (!_canQuote) {
      setState(() {
        _quote = null;
        _quoteError = null;
        _loadingQuote = false;
      });
      return;
    }

    _quoteDebounce = Timer(const Duration(milliseconds: 350), () {
      _fetchQuote();
      _quoteRefreshTimer = Timer.periodic(const Duration(seconds: 3), (_) {
        if (!_canQuote || _loadingQuote || _refreshingQuote) {
          return;
        }
        _fetchQuote(showLoading: false);
      });
    });
  }

  bool get _canQuote {
    final amount = AmountParser.parse(_amountController.text);
    return _inputToken != null &&
        _outputToken != null &&
        _inputToken!.token.mintAddress != _outputToken!.token.mintAddress &&
        amount != null &&
        amount > 0;
  }

  /// Fetch an initial 1-unit quote used for preview estimates.
  Future<void> _fetchInitialQuote() async {
    final inputToken = _inputToken;
    final outputToken = _outputToken;
    if (inputToken == null || outputToken == null) {
      return;
    }

    try {
      final rawAmount = _decimalTextToRawAmount('1', inputToken.token.decimals);
      if (rawAmount == null || rawAmount == '0') {
        return;
      }
      final quote = await ref
          .read(swapRepositoryProvider)
          .quoteSwap(
            inputMint: inputToken.token.mintAddress,
            outputMint: outputToken.token.mintAddress,
            rawAmount: rawAmount,
            slippageBps: _slippageBps,
          );
      if (!mounted) {
        return;
      }
      setState(() {
        _quote = quote;
        _quoteError = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _quoteError = _friendlyQuoteError(error);
      });
    }
  }

  bool get _canReviewSwap =>
      _canQuote && !_loadingQuote && _quote != null && _quoteError == null;

  String get _displayAmountText {
    final text = _amountController.text.trim();
    return text.isEmpty ? '0' : text;
  }

  String get _rateSummary {
    final inputToken = _inputToken;
    final outputToken = _outputToken;
    final quote = _quote;
    if (inputToken == null || outputToken == null || quote == null) {
      return '--';
    }
    final inputAmount = _rawToUiAmount(
      quote.inAmount,
      inputToken.token.decimals,
    );
    final outputAmount = _rawToUiAmount(
      quote.outAmount,
      outputToken.token.decimals,
    );
    if (inputAmount <= 0) {
      return '--';
    }
    final rate = outputAmount / inputAmount;
    final compactRate = _formatCompactScientific(rate);
    return '1 ${inputToken.token.symbol} ≈ $compactRate ${outputToken.token.symbol}';
  }

  /// Format values using a compact readable representation.
  /// Example: 0.000000047 -> 0.0₇47, 1200000 -> 1.2M.
  String _formatCompactScientific(double value) {
    if (value == 0) return '0';
    if (value.isInfinite || value.isNaN) return '--';

    final absValue = value.abs();
    final sign = value < 0 ? '-' : '';

    // Values between 1e-6 and 1 keep the normal decimal format.
    if (absValue >= 0.000001 && absValue < 1) {
      return '$sign${Formatters.amount(absValue, maxDecimals: 6)}';
    }

    // Values between 1 and 1e6 also keep the normal format.
    if (absValue >= 1 && absValue < 1e6) {
      return '$sign${Formatters.amount(absValue, maxDecimals: 6)}';
    }

    if (absValue < 0.000001) {
      // Very small values use the compact subscript-zero format.
      final exponentStr = absValue.toStringAsExponential(10);
      final parts = exponentStr.split('e');
      final mantissaStr = parts[0];
      final exponent = int.parse(parts[1]);

      // For a negative exponent, the number of leading zeros is -exponent - 1.
      final leadingZeros = -exponent - 1;
      final zerosSubscript = _toSubscript(leadingZeros);

      // Extract the significant digits without the decimal point or leading zeros.
      final mantissaDigits = mantissaStr
          .replaceAll('.', '')
          .replaceAll(RegExp(r'^0+'), '');

      return '${sign}0.0$zerosSubscript${mantissaDigits.substring(0, min(4, mantissaDigits.length))}';
    }

    if (absValue >= 1e6) {
      // Large values switch to an abbreviated millions representation.
      final millionsValue = absValue / 1e6;
      if (millionsValue >= 1) {
        return '$sign${Formatters.amount(millionsValue, maxDecimals: 2)}M';
      }
    }

    return '$sign${Formatters.amount(absValue, maxDecimals: 6)}';
  }

  /// Convert a number into Unicode subscript digits.
  String _toSubscript(int num) {
    const subscripts = ['₀', '₁', '₂', '₃', '₄', '₅', '₆', '₇', '₈', '₉'];
    final numStr = num.toString();
    return numStr.split('').map((c) {
      final digit = int.tryParse(c);
      return digit != null ? subscripts[digit] : c;
    }).join();
  }

  String get _slippageSummary {
    final quoteSlippageBps = _quote?.slippageBps;
    if (quoteSlippageBps != null && quoteSlippageBps > _slippageBps) {
      return '${_slippageLabel(quoteSlippageBps)} min';
    }

    final value = !_usingCustomSlippage
        ? _slippageLabel(_presetSlippageBps[_slippagePresetIndex])
        : '${AmountParser.parse(_customSlippageController.text)?.toStringAsFixed(1) ?? '1.0'}%';
    return _usingCustomSlippage ? 'Custom · $value' : value;
  }

  String get _networkFeeSummary {
    if (!_canQuote || _quote == null) {
      return '--';
    }

    final priorityLamports = _estimatedPriorityLamports;
    if (priorityLamports == null) {
      return 'Auto';
    }

    final solAmount = (5000 + priorityLamports) / 1000000000;
    final solPrice = _solUnitPrice;
    if (solPrice == null || solPrice <= 0) {
      return '≤ ${Formatters.amount(solAmount, maxDecimals: 8)} SOL';
    }
    return '≤ ${Formatters.usdPrice(solAmount * solPrice)}';
  }

  int? get _estimatedPriorityLamports {
    return switch (_priorityPreset) {
      SwapPriorityPreset.auto => null,
      SwapPriorityPreset.normal => 200000,
      SwapPriorityPreset.fast => 500000,
      SwapPriorityPreset.turbo => 1000000,
    };
  }

  double? get _solUnitPrice {
    final sol = _tokenOptions
        .where((token) => token.token.mintAddress == _solMintAddress)
        .firstOrNull;
    return _tokenUnitPrice(sol);
  }

  String get _payAmountUsdText {
    final amount = AmountParser.parse(_amountController.text);
    final price = _tokenUnitPrice(_inputToken);
    if (amount == null || amount <= 0 || price == null || price <= 0) {
      return '--';
    }
    return Formatters.usdPrice(amount * price);
  }

  String _receiveMetaText(double? minReceivePreview) {
    final outputAmount = _outputAmountUi;
    final outputPrice = _tokenUnitPrice(_outputToken);
    final inputAmount = AmountParser.parse(_amountController.text);
    final inputPrice = _tokenUnitPrice(_inputToken);
    final inputValue = inputAmount == null || inputPrice == null
        ? null
        : inputAmount * inputPrice;
    final valueText =
        outputAmount == null || outputPrice == null || outputPrice <= 0
        ? (inputValue == null ? '--' : Formatters.usdPrice(inputValue))
        : Formatters.usdPrice(outputAmount * outputPrice);
    final minText = minReceivePreview == null
        ? '--'
        : 'Min ${Formatters.amount(minReceivePreview, maxDecimals: 6)}';
    return '$valueText  ·  $minText';
  }

  double? _tokenUnitPrice(SwapTokenOption? token) {
    if (token == null ||
        token.availableBalance <= 0 ||
        token.totalValueUsd <= 0) {
      return null;
    }
    return token.totalValueUsd / token.availableBalance;
  }

  Future<void> _fetchQuote({bool showLoading = true}) async {
    final inputToken = _inputToken;
    final outputToken = _outputToken;
    final amount = AmountParser.parse(_amountController.text);
    if (inputToken == null ||
        outputToken == null ||
        amount == null ||
        amount <= 0) {
      return;
    }

    final requestId = ++_quoteRequestId;
    _refreshingQuote = true;
    if (showLoading) {
      setState(() {
        _loadingQuote = true;
        _quoteError = null;
      });
    }

    try {
      final rawAmount = _rawAmountForCurrentInput(inputToken);
      if (rawAmount == null || rawAmount == '0') {
        if (showLoading) {
          setState(() {
            _loadingQuote = false;
            _quoteError = 'This amount is too small for a valid route.';
          });
        }
        return;
      }
      final quote = await ref
          .read(swapRepositoryProvider)
          .quoteSwap(
            inputMint: inputToken.token.mintAddress,
            outputMint: outputToken.token.mintAddress,
            rawAmount: rawAmount,
            slippageBps: _slippageBps,
          );
      if (!mounted || requestId != _quoteRequestId) {
        return;
      }
      setState(() {
        _quote = quote;
        _loadingQuote = false;
        _quoteError = null;
      });
    } catch (error) {
      if (!mounted || requestId != _quoteRequestId) {
        return;
      }
      setState(() {
        _loadingQuote = false;
        if (showLoading || _quote == null) {
          _quoteError = _friendlyQuoteError(error);
        }
      });
    } finally {
      if (mounted && requestId == _quoteRequestId) {
        _refreshingQuote = false;
      }
    }
  }

  double? get _outputAmountUi {
    final output = _outputToken;
    final quote = _quote;
    final inputAmount = AmountParser.parse(_amountController.text);

    // Only show an estimated output after the user enters an amount.
    if (output == null ||
        quote == null ||
        inputAmount == null ||
        inputAmount <= 0) {
      return null;
    }
    return _rawToUiAmount(quote.outAmount, output.token.decimals);
  }

  double? get _minReceiveAmountUi {
    final output = _outputToken;
    final quote = _quote;
    if (output == null || quote == null) {
      return null;
    }
    return _rawToUiAmount(quote.otherAmountThreshold, output.token.decimals);
  }

  int get _slippageBps {
    if (!_usingCustomSlippage) {
      return _presetSlippageBps[_slippagePresetIndex];
    }

    final value = AmountParser.parse(_customSlippageController.text);
    if (value == null || value <= 0) {
      return 100;
    }
    return (value * 100).round();
  }

  String _slippageLabel(int bps) {
    final decimals = bps % 100 == 0 ? 0 : (bps % 10 == 0 ? 1 : 2);
    return '${(bps / 100).toStringAsFixed(decimals)}%';
  }

  String? _rawAmountForCurrentInput(SwapTokenOption inputToken) {
    return _decimalTextToRawAmount(
      _amountController.text,
      inputToken.token.decimals,
    );
  }

  String? _decimalTextToRawAmount(String amountText, int decimals) {
    final rawAmount = AmountParser.toRawUnits(amountText, decimals);
    return rawAmount?.toString();
  }

  double _rawToUiAmount(String rawAmount, int decimals) {
    final raw = BigInt.tryParse(rawAmount) ?? BigInt.zero;
    if (raw == BigInt.zero) {
      return 0;
    }
    return raw.toDouble() / _pow10(decimals);
  }

  double _pow10(int decimals) {
    var value = 1.0;
    for (var i = 0; i < decimals; i++) {
      value *= 10;
    }
    return value;
  }

  void _setInputShare(double share) {
    final inputToken = _inputToken;
    if (inputToken == null) {
      return;
    }
    final rawBalance = BigInt.tryParse(inputToken.rawAvailableAmount ?? '');
    if (rawBalance != null && rawBalance > BigInt.zero) {
      final rawAmount = _rawShareAmount(rawBalance, share);
      _amountController.text = AmountParser.formatRawUnits(
        rawAmount,
        inputToken.token.decimals,
      );
      return;
    }
    final amount = inputToken.availableBalance * share;
    _amountController.text = Formatters.amount(
      amount,
      maxDecimals: min(inputToken.token.decimals, 9),
    );
  }

  BigInt _rawShareAmount(BigInt rawBalance, double share) {
    if (share >= 1) {
      return rawBalance;
    }
    if ((share - 0.5).abs() < 0.000001) {
      return rawBalance ~/ BigInt.from(2);
    }
    if ((share - 0.25).abs() < 0.000001) {
      return rawBalance ~/ BigInt.from(4);
    }
    return BigInt.from((rawBalance.toDouble() * share).floor());
  }

  Future<void> _editAmount() async {
    var workingValue = _amountController.text.trim();
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void append(String value) {
              setModalState(() {
                if (value == '.') {
                  if (workingValue.contains('.')) {
                    return;
                  }
                  workingValue = workingValue.isEmpty ? '0.' : '$workingValue.';
                } else if (workingValue == '0') {
                  workingValue = value;
                } else {
                  workingValue = '$workingValue$value';
                }
              });
            }

            void delete() {
              setModalState(() {
                if (workingValue.isEmpty) {
                  return;
                }
                workingValue = workingValue.substring(
                  0,
                  workingValue.length - 1,
                );
              });
            }

            final receivePreview = _modalReceivePreview(workingValue);

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 42,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 64,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Text(
                                workingValue.isEmpty ? '0' : workingValue,
                                style: Theme.of(context).textTheme.displayLarge
                                    ?.copyWith(
                                      fontSize: 48,
                                      fontWeight: FontWeight.w800,
                                      height: 0.92,
                                      letterSpacing: -1.8,
                                    ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _ReceivePreviewCard(
                          token: _outputToken,
                          amountText: receivePreview,
                        ),
                        const SizedBox(height: 20),
                        _AmountPad(
                          onDigit: append,
                          onDelete: delete,
                          onDone: () =>
                              Navigator.of(sheetContext).pop(workingValue),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (result == null) {
      return;
    }

    setState(() {
      _amountController.text = result;
    });
  }

  String _modalReceivePreview(String inputText) {
    final inputAmount = AmountParser.parse(inputText);
    final quote = _quote;
    final inputToken = _inputToken;
    final outputToken = _outputToken;
    if (inputAmount == null ||
        inputAmount <= 0 ||
        quote == null ||
        inputToken == null ||
        outputToken == null) {
      return '--';
    }

    final quotedInput = _rawToUiAmount(
      quote.inAmount,
      inputToken.token.decimals,
    );
    final quotedOutput = _rawToUiAmount(
      quote.outAmount,
      outputToken.token.decimals,
    );
    if (quotedInput <= 0 || quotedOutput <= 0) {
      return '--';
    }

    final estimatedOutput = inputAmount * (quotedOutput / quotedInput);
    return '${Formatters.amount(estimatedOutput, maxDecimals: 6)} ${outputToken.token.symbol}';
  }

  void _flipTokens() {
    final input = _inputToken;
    final output = _outputToken;
    if (input == null || output == null) {
      return;
    }
    final nextAmount = _outputAmountUi;
    setState(() {
      _inputToken = output;
      _outputToken = input;
      _quote = null;
      _quoteError = null;
      _amountController.text = nextAmount == null || nextAmount <= 0
          ? ''
          : Formatters.amount(nextAmount, maxDecimals: 6);
      _applyDefaultSlippageForPair();
    });
    _fetchInitialQuote();
  }

  Future<void> _editSlippage() async {
    var selectedCustom = _usingCustomSlippage;
    var selectedIndex = _slippagePresetIndex;
    final controller = TextEditingController(
      text: _customSlippageController.text,
    );

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Slippage',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (
                          var index = 0;
                          index < _presetSlippageBps.length;
                          index++
                        )
                          ChoiceChip(
                            label: Text(
                              _slippageLabel(_presetSlippageBps[index]),
                            ),
                            selected: !selectedCustom && selectedIndex == index,
                            onSelected: (_) => setModalState(() {
                              selectedCustom = false;
                              selectedIndex = index;
                            }),
                          ),
                        ChoiceChip(
                          label: const Text('Custom'),
                          selected: selectedCustom,
                          onSelected: (_) =>
                              setModalState(() => selectedCustom = true),
                        ),
                      ],
                    ),
                    if (selectedCustom) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: controller,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Custom slippage %',
                          hintText: '1.0',
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          setState(() {
                            _usingCustomSlippage = selectedCustom;
                            _slippagePresetIndex = selectedIndex;
                            _slippageUserSelected = true;
                            if (selectedCustom) {
                              _customSlippageController.text =
                                  controller.text.trim().isEmpty
                                  ? '1.0'
                                  : controller.text.trim();
                            }
                          });
                          Navigator.of(sheetContext).pop();
                          _scheduleQuote();
                        },
                        child: const Text('Done'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _editPriority() async {
    var selectedPreset = _priorityPreset;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Priority fee',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final preset in SwapPriorityPreset.values)
                      ChoiceChip(
                        label: Text(preset.label),
                        selected: selectedPreset == preset,
                        onSelected: (_) {
                          selectedPreset = preset;
                          setState(() => _priorityPreset = preset);
                          Navigator.of(sheetContext).pop();
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickInputTokenNoSearch(
    BuildContext context, {
    required String title,
    required List<SwapTokenOption> options,
    required SwapTokenOption? current,
    required ValueChanged<SwapTokenOption> onSelected,
  }) async {
    if (options.isEmpty) return;

    final selected = await Navigator.of(context).push<SwapTokenOption>(
      MaterialPageRoute(
        builder: (_) => _TokenPickerRoutePage(
          title: title,
          child: _SimpleTokenListSheet(
            title: title,
            options: options,
            currentOption: current,
          ),
        ),
      ),
    );

    if (selected != null) {
      onSelected(selected);
    }
  }

  Future<void> _pickToken(
    BuildContext context, {
    required String title,
    required List<SwapTokenOption> options,
    required SwapTokenOption? current,
    required List<AssetHolding> portfolioAssets,
    required ValueChanged<SwapTokenOption> onSelected,
    Set<String> excludedCategories = const {},
  }) async {
    final selected = await Navigator.of(context).push<SwapTokenOption>(
      MaterialPageRoute(
        builder: (_) => _TokenPickerRoutePage(
          title: title,
          child: _TokenPickerSheet(
            title: title,
            defaultOptions: options,
            currentOption: current,
            repository: ref.read(swapRepositoryProvider),
            portfolioAssets: portfolioAssets,
            excludedCategories: excludedCategories,
          ),
        ),
      ),
    );

    if (selected != null) {
      onSelected(selected);
    }
  }

  Future<void> _reviewSwap() async {
    final walletAddress = ref.read(walletControllerProvider).publicKey;
    final inputToken = _inputToken;
    final outputToken = _outputToken;
    final quote = _quote;
    final amount = AmountParser.parse(_amountController.text);

    if (walletAddress == null ||
        inputToken == null ||
        outputToken == null ||
        amount == null) {
      return;
    }

    if (amount <= 0) {
      await _showDialog(message: 'Enter a valid amount.');
      return;
    }

    if (amount > inputToken.availableBalance) {
      await _showDialog(message: 'Insufficient balance.');
      return;
    }

    final rawAmount = _rawAmountForCurrentInput(inputToken);
    if (rawAmount == null || rawAmount == '0') {
      await _showDialog(message: 'This amount is too small for a valid route.');
      return;
    }

    if (quote == null) {
      await _showDialog(message: 'Wait for a valid quote before continuing.');
      return;
    }

    setState(() => _buildingSwap = true);
    try {
      final balanceError = await _validateLiveBalances(
        ownerAddress: walletAddress,
        inputToken: inputToken,
        outputToken: outputToken,
        amount: amount,
        rawAmount: rawAmount,
      );
      if (balanceError != null) {
        if (!mounted) {
          return;
        }
        await _showDialog(message: balanceError);
        return;
      }

      final buildResult = await ref
          .read(swapRepositoryProvider)
          .buildSwap(
            ownerAddress: walletAddress,
            inputMint: inputToken.token.mintAddress,
            outputMint: outputToken.token.mintAddress,
            rawAmount: rawAmount,
            slippageBps: _slippageBps,
            priorityPreset: _priorityPreset.apiValue,
          );
      if (!mounted) {
        return;
      }

      final review = SwapReviewData(
        inputToken: inputToken,
        outputToken: outputToken,
        inputAmountUi: amount,
        outputAmountUi: _rawToUiAmount(
          buildResult.outAmount,
          outputToken.token.decimals,
        ),
        buildResult: buildResult,
        priorityPreset: _priorityPreset,
        slippageBps: buildResult.slippageBps,
      );
      if (!mounted) {
        return;
      }
      context.push(SwapExecutePage.routePath, extra: review);
    } catch (error) {
      if (!mounted) {
        return;
      }
      await _showDialog(message: _friendlyQuoteError(error));
    } finally {
      if (mounted) {
        setState(() => _buildingSwap = false);
      }
    }
  }

  Future<void> _showDialog({required String message}) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => MediaQuery.withNoTextScaling(
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          contentPadding: const EdgeInsets.fromLTRB(28, 30, 28, 8),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 18,
              height: 1.35,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Close',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _validateLiveBalances({
    required String ownerAddress,
    required SwapTokenOption inputToken,
    required SwapTokenOption outputToken,
    required double amount,
    required String rawAmount,
  }) async {
    final solana = ref.read(solanaWalletServiceProvider);
    final balances = await solana.loadPortfolioBalances(
      ownerAddress: ownerAddress,
    );
    final inputBalance =
        _liveBalanceForMint(balances, inputToken.token.mintAddress) ??
        inputToken.availableBalance;
    final requestedRawAmount = BigInt.tryParse(rawAmount);
    final inputRawBalance =
        _liveRawBalanceForMint(balances, inputToken.token.mintAddress) ??
        BigInt.tryParse(inputToken.rawAvailableAmount ?? '');
    if (requestedRawAmount != null &&
        inputRawBalance != null &&
        requestedRawAmount > inputRawBalance) {
      return 'Insufficient balance.';
    }
    if (amount > inputBalance + _balanceTolerance) {
      return 'Insufficient balance.';
    }

    final solBalance =
        _liveBalanceForMint(balances, _solMintAddress) ??
        _tokenOptions
            .where((token) => token.token.mintAddress == _solMintAddress)
            .firstOrNull
            ?.availableBalance ??
        0;
    final outputAccountExists = await _outputAccountExists(
      ownerAddress: ownerAddress,
      outputToken: outputToken,
      portfolioBalances: balances,
    );
    final involvesNativeSol =
        inputToken.token.mintAddress == _solMintAddress ||
        outputToken.token.mintAddress == _solMintAddress;
    final requiredSol = _estimatedRequiredSol(
      outputAccountExists: outputAccountExists,
      involvesNativeSol: involvesNativeSol,
    );
    final inputSolAmount = inputToken.token.mintAddress == _solMintAddress
        ? amount
        : 0.0;
    if (solBalance + _balanceTolerance < inputSolAmount + requiredSol) {
      return _insufficientSolForSwapMessage(requiredSol: requiredSol);
    }

    return null;
  }

  double? _liveBalanceForMint(
    List<AssetBalanceSnapshot> balances,
    String mintAddress,
  ) {
    return balances
        .where((item) => item.token.mintAddress == mintAddress)
        .firstOrNull
        ?.balance;
  }

  BigInt? _liveRawBalanceForMint(
    List<AssetBalanceSnapshot> balances,
    String mintAddress,
  ) {
    final rawAmount = balances
        .where((item) => item.token.mintAddress == mintAddress)
        .firstOrNull
        ?.rawAmount;
    return rawAmount == null ? null : BigInt.tryParse(rawAmount);
  }

  Future<bool> _outputAccountExists({
    required String ownerAddress,
    required SwapTokenOption outputToken,
    required List<AssetBalanceSnapshot> portfolioBalances,
  }) async {
    if (outputToken.token.mintAddress == _solMintAddress) {
      return true;
    }
    if (portfolioBalances.any(
      (item) =>
          item.token.mintAddress == outputToken.token.mintAddress &&
          item.existsOnChain,
    )) {
      return true;
    }

    try {
      final outputBalance = await ref
          .read(solanaWalletServiceProvider)
          .loadBalances(
            ownerAddress: ownerAddress,
            tokens: [outputToken.token],
          );
      return outputBalance.firstOrNull?.existsOnChain ?? false;
    } catch (_) {
      return false;
    }
  }

  double _estimatedRequiredSol({
    required bool outputAccountExists,
    required bool involvesNativeSol,
  }) {
    final priorityLamports = _estimatedPriorityLamports ?? 1000000;
    final feeLamports = 5000 + priorityLamports;
    final feeReserve = feeLamports / 1000000000 + _minimumSwapFeeReserveSol;
    if (!outputAccountExists || involvesNativeSol) {
      return max(feeReserve, _minimumSwapSetupReserveSol);
    }
    return feeReserve;
  }

  String _insufficientSolForSwapMessage({required double requiredSol}) {
    final reserve = Formatters.amount(requiredSol, maxDecimals: 4);
    return 'Not enough SOL.\nNeed $reserve SOL reserve.';
  }

  String _friendlyQuoteError(Object error) {
    var message = error.toString();
    if (message.startsWith('Exception: ')) {
      message = message.substring('Exception: '.length);
    }
    final lower = message.toLowerCase();
    if (lower == 'not_tradable' ||
        lower.contains('not tradable') ||
        lower.contains('token_not_tradable')) {
      return "This swap route isn't available right now. Try swapping with SOL or choose another token pair.";
    }
    if (lower.contains('no route') ||
        lower.contains('could not find any route')) {
      return "This swap route isn't available right now. Try swapping with SOL or choose another token pair.";
    }
    if (lower.contains('insufficient') && lower.contains('liquidity')) {
      return 'This amount is too small for a valid route.';
    }
    if (lower.contains('0x1771') ||
        lower.contains('0x1772') ||
        lower.contains('0x1773') ||
        lower.contains('6001') ||
        lower.contains('6002') ||
        lower.contains('6003') ||
        lower.contains('toomuchsolrequired') ||
        lower.contains('toolittlesolreceived') ||
        lower.contains('slippage tolerance exceeded') ||
        lower.contains('slippage exceeded')) {
      return 'Price moved before the swap was sent. Increase slippage and try again.';
    }
    if (_isJupiterInsufficientFundsError(lower)) {
      return 'Not enough token balance. Tap Max again and retry.';
    }
    if (_isInsufficientSwapBalanceError(lower)) {
      return _insufficientSwapBalanceMessage;
    }
    if (lower.contains('could not find any route')) {
      return "This swap route isn't available right now. Try swapping with SOL or choose another token pair.";
    }
    if (lower.contains('429') ||
        lower.contains('too many requests') ||
        lower.contains('rate limit')) {
      return 'Quotes are busy right now. Try again in a moment.';
    }
    return message;
  }

  bool _isInsufficientSwapBalanceError(String lower) {
    return lower.contains('custom program error: 0x1') ||
        lower.contains('{custom: 1}') ||
        lower.contains('{custom:1}') ||
        lower.contains('custom: 1') ||
        lower.contains('insufficient lamports') ||
        lower.contains('insufficient balance') ||
        lower.contains('insufficient account balance') ||
        lower.contains('attempt to debit an account') ||
        (lower.contains('insufficient') && lower.contains('rent'));
  }

  bool _isJupiterInsufficientFundsError(String lower) {
    return lower.contains('custom program error: 0x1788') ||
        lower.contains('{custom: 6024}') ||
        lower.contains('{custom:6024}') ||
        lower.contains('custom: 6024') ||
        lower.contains('insufficient funds');
  }
}

class _SwapSectionCard extends StatelessWidget {
  const _SwapSectionCard({
    this.tokenSelectorKey,
    required this.title,
    required this.amountField,
    required this.token,
    required this.onChooseToken,
    required this.footer,
  });

  final Key? tokenSelectorKey;
  final String title;
  final Widget amountField;
  final SwapTokenOption? token;
  final VoidCallback onChooseToken;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: amountField),
              const SizedBox(width: 12),
              _TokenSelectorPill(
                key: tokenSelectorKey,
                token: token,
                onTap: onChooseToken,
              ),
            ],
          ),
          const SizedBox(height: 18),
          footer,
        ],
      ),
    );
  }
}

class _TokenSelectorPill extends StatelessWidget {
  const _TokenSelectorPill({
    super.key,
    required this.token,
    required this.onTap,
  });

  final SwapTokenOption? token;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: AppColors.surfaceContainerHigh.withValues(alpha: 0.65),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SwapTokenAvatar(option: token, size: 34),
            const SizedBox(width: 10),
            Text(
              token?.token.symbol ?? 'Choose',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(width: 4),
            const Icon(Icons.expand_more_rounded),
          ],
        ),
      ),
    );
  }
}

class _SwapTokenAvatar extends StatelessWidget {
  const _SwapTokenAvatar({required this.option, required this.size});

  final SwapTokenOption? option;
  final double size;

  @override
  Widget build(BuildContext context) {
    final logoUrl = option?.logoUrl;
    if (logoUrl != null && logoUrl.isNotEmpty) {
      final isSvg = logoUrl.toLowerCase().contains('.svg');
      return ClipOval(
        child: SizedBox(
          width: size,
          height: size,
          child: isSvg
              ? SvgPicture.network(
                  logoUrl,
                  fit: BoxFit.cover,
                  placeholderBuilder: (_) => _FallbackAvatar(
                    symbol: option?.token.symbol ?? '?',
                    size: size,
                  ),
                )
              : Image.network(
                  logoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _FallbackAvatar(
                    symbol: option?.token.symbol ?? '?',
                    size: size,
                  ),
                ),
        ),
      );
    }

    return _FallbackAvatar(symbol: option?.token.symbol ?? '?', size: size);
  }
}

class _FallbackAvatar extends StatelessWidget {
  const _FallbackAvatar({required this.symbol, required this.size});

  final String symbol;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        symbol.characters.first.toUpperCase(),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }
}

class _QuickAmountChip extends StatelessWidget {
  const _QuickAmountChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: AppColors.surfaceContainerHigh.withValues(alpha: 0.7),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _AmountDisplayButton extends StatelessWidget {
  const _AmountDisplayButton({
    super.key,
    required this.value,
    required this.onTap,
  });

  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: SizedBox(
        height: 54,
        child: Align(
          alignment: Alignment.centerLeft,
          child: FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 42,
                fontWeight: FontWeight.w800,
                height: 0.94,
                letterSpacing: -1.6,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReceivePreviewCard extends StatelessWidget {
  const _ReceivePreviewCard({required this.token, required this.amountText});

  final SwapTokenOption? token;
  final String amountText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          _SwapTokenAvatar(option: token, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  token?.token.name ?? 'Receive',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Approx. you receive',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontSize: 10.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              amountText,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountPad extends StatelessWidget {
  const _AmountPad({
    required this.onDigit,
    required this.onDelete,
    required this.onDone,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    const rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['.', '0', 'delete'],
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in rows) ...[
          Row(
            children: [
              for (final key in row) ...[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: _AmountPadKey(
                      label: key == 'delete' ? null : key,
                      icon: key == 'delete' ? Icons.backspace_outlined : null,
                      onPressed: () {
                        if (key == 'delete') {
                          onDelete();
                          return;
                        }
                        onDigit(key);
                      },
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: onDone,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(42),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: const Text('Done'),
          ),
        ),
      ],
    );
  }
}

class _AmountPadKey extends StatelessWidget {
  const _AmountPadKey({this.label, this.icon, required this.onPressed});

  final String? label;
  final IconData? icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    const backgroundColor = AppColors.surface;
    const foregroundColor = AppColors.textPrimary;

    return SizedBox(
      height: 44,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onPressed,
          child: Center(
            child: icon != null
                ? Icon(icon, color: foregroundColor)
                : Text(
                    label ?? '',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: foregroundColor,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _SwapSettingsPanel extends StatelessWidget {
  const _SwapSettingsPanel({
    required this.rateText,
    required this.slippageText,
    required this.networkFeeText,
    required this.priorityText,
    required this.onTapSlippage,
    required this.onTapPriority,
  });

  final String rateText;
  final String slippageText;
  final String networkFeeText;
  final String priorityText;
  final VoidCallback onTapSlippage;
  final VoidCallback onTapPriority;

  @override
  Widget build(BuildContext context) {
    final rows = [
      _CompactSettingRowData(label: 'Rate', value: rateText),
      _CompactSettingRowData(
        label: 'Slippage',
        value: slippageText,
        onTap: onTapSlippage,
      ),
      _CompactSettingRowData(label: 'Network fee', value: networkFeeText),
      const _CompactSettingRowData(
        label: 'Platform fee',
        value: '',
        valueWidget: _PlatformFeeValue(),
      ),
      _CompactSettingRowData(
        label: 'Priority fee',
        value: priorityText,
        onTap: onTapPriority,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var index = 0; index < rows.length; index++) ...[
            _CompactSettingRow(data: rows[index]),
            if (index != rows.length - 1)
              Divider(
                height: 1,
                color: AppColors.surfaceContainerHigh.withValues(alpha: 0.6),
              ),
          ],
        ],
      ),
    );
  }
}

class _CompactSettingRowData {
  const _CompactSettingRowData({
    required this.label,
    required this.value,
    this.valueWidget,
    this.onTap,
  });

  final String label;
  final String value;
  final Widget? valueWidget;
  final VoidCallback? onTap;
}

class _CompactSettingRow extends StatelessWidget {
  const _CompactSettingRow({required this.data});

  final _CompactSettingRowData data;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Row(
            children: [
              Text(
                data.label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 5),
              Icon(
                Icons.info_outline_rounded,
                size: 14,
                color: AppColors.textSecondary.withValues(alpha: 0.8),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child:
                  data.valueWidget ??
                  Text(
                    data.value,
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12.5,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
            ),
          ),
          if (data.onTap != null) ...[
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded, size: 18),
          ],
        ],
      ),
    );

    if (data.onTap == null) {
      return content;
    }

    return InkWell(onTap: data.onTap, child: content);
  }
}

class _PlatformFeeValue extends StatelessWidget {
  const _PlatformFeeValue();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontSize: 12.5,
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w700,
    );

    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        children: [
          TextSpan(
            text: '0.02%',
            style: style?.copyWith(
              color: AppColors.textSecondary,
              decoration: TextDecoration.lineThrough,
              decorationColor: AppColors.textSecondary,
              decorationThickness: 1.5,
            ),
          ),
          TextSpan(
            text: '  0.00%',
            style: style?.copyWith(color: AppColors.success),
          ),
        ],
      ),
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) {
      return null;
    }
    return iterator.current;
  }
}

class _TokenPickerRoutePage extends StatelessWidget {
  const _TokenPickerRoutePage({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: title,
      enableTitleNavigation: false,
      actions: const [SizedBox.shrink()],
      child: child,
    );
  }
}

class _TokenPickerSheet extends StatefulWidget {
  const _TokenPickerSheet({
    required this.title,
    required this.defaultOptions,
    required this.currentOption,
    required this.repository,
    required this.portfolioAssets,
    this.excludedCategories = const {},
  });

  final String title;
  final List<SwapTokenOption> defaultOptions;
  final SwapTokenOption? currentOption;
  final SwapRepository repository;
  final List<AssetHolding> portfolioAssets;
  final Set<String> excludedCategories;

  @override
  State<_TokenPickerSheet> createState() => _TokenPickerSheetState();
}

class _TokenPickerSheetState extends State<_TokenPickerSheet> {
  late final TextEditingController _searchController;
  Timer? _searchDebounce;
  List<SwapTokenOption> _searchResults = const [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();

    _searchDebounce?.cancel();
    if (query.isEmpty) {
      setState(() {
        _searchResults = const [];
        _isSearching = false;
      });
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 300), () async {
      if (!mounted) return;
      setState(() => _isSearching = true);
      try {
        final results = await widget.repository.searchTokens(
          query,
          widget.portfolioAssets,
          excludedCategories: widget.excludedCategories,
        );
        if (!mounted) return;
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() => _isSearching = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final query = _searchController.text.trim();
    final displayOptions = query.isEmpty
        ? widget.defaultOptions
        : _searchResults;
    final useSections = query.isEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        children: [
          Text(widget.title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search token name or symbol',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchResults = const [];
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: _isSearching && query.isNotEmpty
                ? Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(
                          theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  )
                : displayOptions.isEmpty
                ? Center(
                    child: Text(
                      query.isEmpty
                          ? 'No tokens available'
                          : 'No results found for "$query"',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : useSections
                ? _SectionedTokenOptionList(
                    options: displayOptions,
                    currentOption: widget.currentOption,
                  )
                : ListView.separated(
                    itemCount: displayOptions.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = displayOptions[index];
                      return _TokenOptionTile(
                        item: item,
                        isSelected:
                            item.token.mintAddress ==
                            widget.currentOption?.token.mintAddress,
                        onTap: () => Navigator.of(context).pop(item),
                        useMutedSurface: true,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SectionedTokenOptionList extends StatelessWidget {
  const _SectionedTokenOptionList({
    required this.options,
    required this.currentOption,
    this.useMutedSurface = true,
  });

  final List<SwapTokenOption> options;
  final SwapTokenOption? currentOption;
  final bool useMutedSurface;

  @override
  Widget build(BuildContext context) {
    final owned = options.where((item) => item.isOwned).toList();
    final suggested = options.where((item) => !item.isOwned).toList();
    final children = <Widget>[];

    if (owned.isNotEmpty) {
      children
        ..add(const _TokenSectionHeader(title: 'Your assets'))
        ..addAll(_tilesFor(context, owned));
    }
    if (suggested.isNotEmpty) {
      if (children.isNotEmpty) {
        children.add(const SizedBox(height: 10));
      }
      children
        ..add(const _TokenSectionHeader(title: 'Suggested tokens'))
        ..addAll(_tilesFor(context, suggested));
    }

    return ListView(children: children);
  }

  List<Widget> _tilesFor(BuildContext context, List<SwapTokenOption> items) {
    return [
      for (var index = 0; index < items.length; index++) ...[
        if (index > 0) const SizedBox(height: 10),
        _TokenOptionTile(
          item: items[index],
          isSelected:
              items[index].token.mintAddress ==
              currentOption?.token.mintAddress,
          onTap: () => Navigator.of(context).pop(items[index]),
          useMutedSurface: useMutedSurface,
        ),
      ],
    ];
  }
}

class _TokenSectionHeader extends StatelessWidget {
  const _TokenSectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 2, 10),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _SimpleTokenListSheet extends StatefulWidget {
  const _SimpleTokenListSheet({
    required this.title,
    required this.options,
    required this.currentOption,
  });

  final String title;
  final List<SwapTokenOption> options;
  final SwapTokenOption? currentOption;

  @override
  State<_SimpleTokenListSheet> createState() => _SimpleTokenListSheetState();
}

class _SimpleTokenListSheetState extends State<_SimpleTokenListSheet> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rawQuery = _searchController.text.trim();
    final query = rawQuery.toLowerCase();
    final filteredOptions = query.isEmpty
        ? widget.options
        : widget.options
              .where((item) {
                final symbol = item.token.symbol.toLowerCase();
                final name = item.token.name.toLowerCase();
                final mintAddress = item.token.mintAddress.toLowerCase();
                return symbol.contains(query) ||
                    name.contains(query) ||
                    mintAddress.contains(query);
              })
              .toList(growable: false);
    final useSections = query.isEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        children: [
          Text(widget.title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search token name or symbol',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: rawQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: _searchController.clear,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: filteredOptions.isEmpty
                ? Center(
                    child: Text(
                      rawQuery.isEmpty
                          ? 'No tokens available'
                          : 'No results found for "$rawQuery"',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : useSections
                ? _SectionedTokenOptionList(
                    options: filteredOptions,
                    currentOption: widget.currentOption,
                    useMutedSurface: false,
                  )
                : ListView.separated(
                    itemCount: filteredOptions.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = filteredOptions[index];
                      return _TokenOptionTile(
                        item: item,
                        isSelected:
                            item.token.mintAddress ==
                            widget.currentOption?.token.mintAddress,
                        onTap: () => Navigator.of(context).pop(item),
                        useMutedSurface: false,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _TokenOptionTile extends StatelessWidget {
  const _TokenOptionTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.useMutedSurface,
  });

  final SwapTokenOption item;
  final bool isSelected;
  final VoidCallback onTap;
  final bool useMutedSurface;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.secondaryContainer.withValues(
                  alpha: useMutedSurface ? 0.7 : 1,
                )
              : (useMutedSurface
                    ? AppColors.surfaceMuted
                    : theme.colorScheme.surface),
          border: useMutedSurface
              ? null
              : Border.all(
                  color: isSelected
                      ? theme.colorScheme.secondary
                      : Colors.transparent,
                  width: 1.5,
                ),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            _SwapTokenAvatar(option: item, size: 42),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.token.symbol, style: theme.textTheme.titleMedium),
                  if (item.isOwned) ...[
                    Text(
                      '${Formatters.compactNumber(item.availableBalance)} available',
                      style: theme.textTheme.bodySmall,
                    ),
                    if (item.totalValueUsd > 0)
                      Text(
                        Formatters.usdPrice(item.totalValueUsd),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                  ],
                  if (!item.isOwned && item.token.name.isNotEmpty)
                    Text(
                      item.token.name,
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_rounded, color: theme.colorScheme.secondary),
          ],
        ),
      ),
    );
  }
}
