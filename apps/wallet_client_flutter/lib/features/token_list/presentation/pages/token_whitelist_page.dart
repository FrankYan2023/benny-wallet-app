import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/di/providers.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../l10n/l10n.dart';
import '../../../asset_detail/presentation/pages/asset_detail_page.dart';
import '../../domain/token_list_item.dart';

final tokenListProvider = FutureProvider<TokenList>((ref) async {
  final payload = await ref.read(backendApiClientProvider).getTokenList();
  return TokenList.fromJson(payload);
});

/// Markets: every coin and xStock the wallet supports (its whitelist), as
/// two paged cards that fit one screen. Before a search they hold the top 20 coins by market cap
/// and the top 20 tech stocks by company value; a search covers the whole
/// list.
class TokenWhitelistPage extends ConsumerStatefulWidget {
  const TokenWhitelistPage({super.key});

  static const routeName = 'tokenWhitelist';
  static const routePath = '/whitelist';

  @override
  ConsumerState<TokenWhitelistPage> createState() => _TokenWhitelistPageState();
}

class _TokenWhitelistPageState extends ConsumerState<TokenWhitelistPage> {
  static const _topCount = 20;

  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final list = ref.watch(tokenListProvider);
    final searching = _query.trim().isNotEmpty;

    // Lists arrive ranked by market value; each card shows its top 20, or
    // every match while searching.
    List<TokenListItem> pick(Iterable<TokenListItem> items) => searching
        ? items.where((item) => item.matches(_query)).toList()
        : items.take(_topCount).toList();

    return AppScaffold(
      title: l10n.whitelistTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _search,
            onChanged: (value) => setState(() => _query = value),
            textInputAction: TextInputAction.search,
            autocorrect: false,
            decoration: InputDecoration(
              hintText: l10n.whitelistSearchHint,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: MaterialLocalizations.of(
                        context,
                      ).deleteButtonTooltip,
                      onPressed: () {
                        _search.clear();
                        setState(() => _query = '');
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
              filled: true,
              fillColor: theme.colorScheme.surface,
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: list.when(
              data: (data) {
                final coins = pick(
                  data.coins.where((item) => item.category != 'stablecoin'),
                );
                final stables = pick(
                  data.coins.where((item) => item.category == 'stablecoin'),
                );
                // Featured stocks are the tech names; the rest only show up
                // in a search.
                final stocks = pick(
                  searching
                      ? data.stocks
                      : data.stocks.where((item) => item.featured),
                );
                return RefreshIndicator(
                  onRefresh: () => ref.refresh(tokenListProvider.future),
                  child: Builder(
                    builder: (context) {
                      // While searching, a card without matches is left
                      // out; with none anywhere, one line says so.
                      final cards = [
                        (
                          'coins',
                          l10n.whitelistCoins,
                          Icons.currency_bitcoin_rounded,
                          coins,
                        ),
                        (
                          'stocks',
                          l10n.whitelistStocks,
                          Icons.show_chart_rounded,
                          stocks,
                        ),
                        (
                          'stables',
                          l10n.whitelistStablecoins,
                          Icons.attach_money_rounded,
                          stables,
                        ),
                      ].where((card) => !searching || card.$4.isNotEmpty);
                      return ListView(
                        padding: const EdgeInsets.only(bottom: 24),
                        children: [
                          if (cards.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 48),
                              child: Center(
                                child: Text(
                                  l10n.whitelistNoResults,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ),
                          for (final (id, title, icon, items) in cards)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _PagedTokenCard(
                                // A new search starts the card on its first
                                // page.
                                key: ValueKey('$id:$_query'),
                                title: title,
                                subtitle: searching
                                    ? l10n.whitelistMatches(items.length)
                                    : null,
                                icon: icon,
                                items: items,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                );
              },
              error: (_, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.whitelistLoadFailed),
                    TextButton(
                      onPressed: () => ref.invalidate(tokenListProvider),
                      child: Text(l10n.commonRetry),
                    ),
                  ],
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }
}

/// A card of tokens, three to a page: swipe sideways or use the arrows in
/// its header, beside the page number.
class _PagedTokenCard extends StatefulWidget {
  const _PagedTokenCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.items,
  });

  static const perPage = 3;
  static const rowHeight = 64.0;

  final String title;

  /// The number of matches while searching; none otherwise.
  final String? subtitle;
  final IconData icon;
  final List<TokenListItem> items;

  @override
  State<_PagedTokenCard> createState() => _PagedTokenCardState();
}

class _PagedTokenCardState extends State<_PagedTokenCard> {
  final _pages = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  int get _pageCount =>
      math.max(1, (widget.items.length / _PagedTokenCard.perPage).ceil());

  void _go(int page) {
    _pages.animateToPage(
      page,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final items = widget.items;
    final pageCount = _pageCount;
    // As tall as a full page, or as the only (shorter) page.
    final rows = math.min(_PagedTokenCard.perPage, math.max(items.length, 1));

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 16, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.primaryBright.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(widget.icon, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Text(
                widget.title,
                style: theme.textTheme.titleMedium?.copyWith(fontSize: 17),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.subtitle ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              if (pageCount > 1) ...[
                Text(
                  '${_page + 1}/$pageCount',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                _PageButton(
                  icon: Icons.chevron_left_rounded,
                  tooltip: l10n.whitelistPreviousPage,
                  onTap: _page > 0 ? () => _go(_page - 1) : null,
                ),
                const SizedBox(width: 6),
                _PageButton(
                  icon: Icons.chevron_right_rounded,
                  tooltip: l10n.whitelistNextPage,
                  onTap: _page < pageCount - 1 ? () => _go(_page + 1) : null,
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: rows * _PagedTokenCard.rowHeight,
            child: items.isEmpty
                ? Center(
                    child: Text(
                      l10n.whitelistNoResults,
                      style: theme.textTheme.bodyMedium,
                    ),
                  )
                : PageView.builder(
                    controller: _pages,
                    itemCount: pageCount,
                    onPageChanged: (page) => setState(() => _page = page),
                    itemBuilder: (context, page) {
                      final start = page * _PagedTokenCard.perPage;
                      final slice = items.sublist(
                        start,
                        math.min(start + _PagedTokenCard.perPage, items.length),
                      );
                      return Column(
                        children: [
                          for (var i = 0; i < slice.length; i++)
                            _TokenRow(item: slice[i], rank: start + i + 1),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({required this.icon, required this.tooltip, this.onTap});

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.surfaceMuted,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox.square(
            dimension: 30,
            child: Icon(
              icon,
              size: 20,
              color: onTap == null ? AppColors.outline : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _TokenRow extends StatelessWidget {
  const _TokenRow({required this.item, required this.rank});

  final TokenListItem item;
  final int rank;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final change = item.change24hPct;
    final changeColor = PriceTrendColors.of(
      context,
    ).forChange(change, neutral: AppColors.textSecondary);
    final isStock = item.category == 'xstock';
    // A stock reads as its listed ticker (AAPL), a coin as its symbol.
    final symbol = isStock ? item.underlyingSymbol ?? item.symbol : item.symbol;
    final cap = item.marketCapUsd;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => context.push(
        AssetDetailPage.pathFor(item.mintAddress),
        extra: AssetDetailArgs(
          symbol: item.symbol,
          name: item.name,
          logoUrl: item.logoUrl,
          category: item.category,
        ),
      ),
      child: SizedBox(
        height: _PagedTokenCard.rowHeight,
        child: Row(
          children: [
            _Logo(url: item.logoUrl, symbol: symbol),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    symbol,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    cap == null
                        ? '#$rank'
                        : '${l10n.whitelistMarketCapShort} '
                              '${_compactMarketCap(cap, l10n)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.priceUsd == null ? '--' : _price(item.priceUsd!),
                  style: theme.textTheme.titleMedium?.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  Formatters.percent(change, signed: true),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: changeColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Prices of $1,000 and more get thousands separators ($81,553.00).
String _price(double value) {
  if (value >= 1000) {
    return NumberFormat.currency(symbol: r'$', decimalDigits: 2).format(value);
  }
  return Formatters.usdPrice(value);
}

/// A market value the reader's way: 19.2億 and 5.02萬億 in Chinese, 億 and 兆
/// in Japanese, 억 and 조 in Korean, K/M/B/T elsewhere.
String _compactMarketCap(double value, AppLocalizations l10n) {
  final units = switch (l10n.localeName.split('_').first) {
    'zh' => const [(1e12, '萬億'), (1e8, '億'), (1e4, '萬')],
    'ja' => const [(1e12, '兆'), (1e8, '億'), (1e4, '万')],
    'ko' => const [(1e12, '조'), (1e8, '억'), (1e4, '만')],
    _ => const <(double, String)>[],
  };
  for (final (size, unit) in units) {
    if (value >= size) {
      final scaled = value / size;
      final digits = scaled >= 100
          ? 0
          : scaled >= 10
          ? 1
          : 2;
      return '\$${scaled.toStringAsFixed(digits)}$unit';
    }
  }
  return Formatters.compactUsd(value);
}

class _Logo extends StatelessWidget {
  const _Logo({required this.url, required this.symbol});

  final String? url;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fallback = Center(
      child: Text(
        symbol.isEmpty ? '?' : symbol.substring(0, 1),
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surfaceMuted,
        border: Border.all(color: AppColors.surfaceContainer),
      ),
      child: url == null || url!.isEmpty
          ? fallback
          : ClipOval(
              child: CachedNetworkImage(
                imageUrl: url!,
                fit: BoxFit.cover,
                memCacheWidth: 132,
                fadeInDuration: const Duration(milliseconds: 120),
                errorWidget: (context, url, error) => fallback,
              ),
            ),
    );
  }
}
