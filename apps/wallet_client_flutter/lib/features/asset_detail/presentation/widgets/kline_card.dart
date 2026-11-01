import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/providers.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../l10n/l10n.dart';
import '../../domain/token_candles.dart';
import 'kline_chart_view.dart';

typedef CandleRequest = ({String mintAddress, CandleInterval interval});

final tokenCandlesProvider = FutureProvider.autoDispose
    .family<TokenCandles?, CandleRequest>((ref, request) {
      return ref
          .read(assetDetailRepositoryProvider)
          .loadCandles(request.mintAddress, request.interval);
    });

/// Day, week, month and year candles for a catalog token. Tokens the
/// backend has no chart for show nothing.
class KlineCard extends ConsumerStatefulWidget {
  const KlineCard({
    super.key,
    required this.mintAddress,
    this.header,
    this.framed = true,
  });

  final String mintAddress;

  /// In a card; unframed, the chart sits on the page under a row of
  /// periods, as at the top of a token's detail page.
  final bool framed;

  /// Shown above the card, and hidden with it.
  final Widget? header;

  @override
  ConsumerState<KlineCard> createState() => _KlineCardState();
}

class _KlineCardState extends ConsumerState<KlineCard>
    with WidgetsBindingObserver {
  static const _chartHeight = 300.0;

  // Opens on 15-minute candles, the most recent view.
  CandleInterval _interval = CandleInterval.minutes15;
  TokenCandles? _shown;
  Timer? _refreshTimer;
  bool _inForeground = true;

  CandleRequest get _request =>
      (mintAddress: widget.mintAddress, interval: _interval);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _inForeground = state == AppLifecycleState.resumed;
    if (_inForeground && _shown != null) {
      _refresh();
    }
  }

  /// Polls while the chart is on screen so the newest candle stays live.
  void _scheduleRefresh(int seconds) {
    _refreshTimer?.cancel();
    _refreshTimer = Timer(Duration(seconds: seconds), _refresh);
  }

  void _refresh() {
    if (!mounted) {
      return;
    }
    final route = ModalRoute.of(context);
    final hidden = !TickerMode.getValuesNotifier(context).value.enabled;
    if (!_inForeground || hidden || (route != null && !route.isCurrent)) {
      // Try again later; the page is covered, the chart sits in a hidden
      // tab or the app is in the background.
      _scheduleRefresh(_shown?.refreshSeconds ?? 30);
      return;
    }
    ref.invalidate(tokenCandlesProvider(_request));
  }

  void _select(CandleInterval interval) {
    if (interval == _interval) {
      return;
    }
    setState(() => _interval = interval);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final request = _request;
    ref.listen<AsyncValue<TokenCandles?>>(tokenCandlesProvider(request), (
      _,
      next,
    ) {
      final data = next.valueOrNull;
      if (data != null) {
        setState(() => _shown = data);
        _scheduleRefresh(data.refreshSeconds);
      } else if (next.hasError) {
        _scheduleRefresh(60);
      }
    });
    final candles = ref.watch(tokenCandlesProvider(request));
    final current = candles.valueOrNull;
    if (candles.hasValue && current == null) {
      // Not in the catalog: the backend has no chart for this token.
      return const SizedBox.shrink();
    }
    final shown = current ?? _shown;
    final trend = PriceTrendColors.of(context);
    final theme = Theme.of(context);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.framed)
          _IntervalTabs(selected: _interval, onSelected: _select)
        else
          // Unframed, the chart runs the screen's full width and the
          // controls keep the page's margin.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _IntervalRow(selected: _interval, onSelected: _select),
          ),
        const SizedBox(height: 8),
        SizedBox(
          height: _chartHeight,
          child: Stack(
            children: [
              if (shown != null && shown.candles.isNotEmpty)
                Positioned.fill(
                  child: KlineChartView(
                    candles: shown,
                    upColor: trend.up,
                    downColor: trend.down,
                    locale: Localizations.localeOf(context).toLanguageTag(),
                    labels: KlineChartLabels(
                      open: l10n.assetChartOpen,
                      high: l10n.assetChartHigh,
                      low: l10n.assetChartLow,
                      close: l10n.assetChartClose,
                      volume: l10n.assetChartVolume,
                    ),
                  ),
                ),
              if (shown == null && candles.hasError)
                Positioned.fill(
                  child: _ChartError(
                    onRetry: () =>
                        ref.invalidate(tokenCandlesProvider(request)),
                  ),
                )
              else if (shown != null && shown.candles.isEmpty)
                Positioned.fill(
                  child: Center(
                    child: Text(
                      l10n.assetChartEmpty,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ),
              if (candles.isLoading && shown == null)
                const Positioned.fill(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (candles.isLoading && current == null)
                // Switching period: the old chart stays until the new one loads.
                const Positioned(
                  top: 2,
                  right: 2,
                  child: SizedBox.square(
                    dimension: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
            ],
          ),
        ),
        if (shown != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.framed ? 0 : 16),
            child: Text(
              _sourceLine(l10n, shown),
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ],
    );
    final card = widget.framed
        ? WalletCard(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
            child: content,
          )
        : content;
    final header = widget.header;
    if (header == null) {
      return card;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [header, const SizedBox(height: 10), card],
    );
  }

  static String _sourceLine(AppLocalizations l10n, TokenCandles candles) {
    final source = l10n.assetDataSource(candles.sourceName);
    final symbol = candles.underlyingSymbol;
    if (!candles.isStock || symbol == null) {
      return source;
    }
    final market = candles.exchange == null
        ? symbol
        : '$symbol · ${candles.exchange}';
    return '${l10n.assetChartUnderlying(market)} · $source';
  }
}

class _IntervalTabs extends StatelessWidget {
  const _IntervalTabs({required this.selected, required this.onSelected});

  final CandleInterval selected;
  final ValueChanged<CandleInterval> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final labels = {
      CandleInterval.minutes15: l10n.assetChart15m,
      CandleInterval.hour: l10n.assetChart1h,
      CandleInterval.hours4: l10n.assetChart4h,
      CandleInterval.day: l10n.assetChartDay,
      CandleInterval.week: l10n.assetChartWeek,
      CandleInterval.month: l10n.assetChartMonth,
      CandleInterval.year: l10n.assetChartYear,
    };

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          for (final interval in CandleInterval.values)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelected(interval),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  decoration: BoxDecoration(
                    color: interval == selected
                        ? theme.colorScheme.surface
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(11),
                    boxShadow: interval == selected
                        ? const [
                            BoxShadow(color: AppColors.shadow, blurRadius: 6),
                          ]
                        : null,
                  ),
                  child: Text(
                    labels[interval]!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: interval == selected
                          ? FontWeight.w700
                          : FontWeight.w600,
                      color: interval == selected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The periods as a row of words, the picked one on a light pill.
class _IntervalRow extends StatelessWidget {
  const _IntervalRow({required this.selected, required this.onSelected});

  final CandleInterval selected;
  final ValueChanged<CandleInterval> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final labels = {
      CandleInterval.minutes15: l10n.assetChart15m,
      CandleInterval.hour: l10n.assetChart1h,
      CandleInterval.hours4: l10n.assetChart4h,
      CandleInterval.day: l10n.assetChartDay,
      CandleInterval.week: l10n.assetChartWeek,
      CandleInterval.month: l10n.assetChartMonth,
      CandleInterval.year: l10n.assetChartYear,
    };

    // Seven periods may not fit a narrow screen: the row scrolls sideways.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final interval in CandleInterval.values) ...[
            Semantics(
              button: true,
              selected: interval == selected,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelected(interval),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: interval == selected
                        ? theme.colorScheme.surface
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    labels[interval]!,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: interval == selected
                          ? FontWeight.w700
                          : FontWeight.w600,
                      color: interval == selected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 2),
          ],
        ],
      ),
    );
  }
}

class _ChartError extends StatelessWidget {
  const _ChartError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.assetChartLoadFailed,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: onRetry, child: Text(l10n.commonRetry)),
        ],
      ),
    );
  }
}
