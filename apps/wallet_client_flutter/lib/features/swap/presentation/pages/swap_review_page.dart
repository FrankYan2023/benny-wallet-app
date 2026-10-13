import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../l10n/l10n.dart';
import '../../domain/swap_review_data.dart';
import '../swap_priority_l10n.dart';
import 'swap_execute_page.dart';

class SwapReviewPage extends StatefulWidget {
  const SwapReviewPage({super.key, required this.review});

  static const routeName = 'swapReview';
  static const routePath = '/swap/review';

  final SwapReviewData review;

  @override
  State<SwapReviewPage> createState() => _SwapReviewPageState();
}

class _SwapReviewPageState extends State<SwapReviewPage> {
  bool _transitioning = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final review = widget.review;
    final l10n = context.l10n;

    return AppScaffold(
      title: l10n.swapReviewTitle,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Icon(
                    Icons.swap_vert_rounded,
                    color: theme.colorScheme.primary,
                    size: 52,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  '${Formatters.amount(review.inputAmountUi)} ${review.inputToken.token.symbol}',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displayLarge?.copyWith(fontSize: 38),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.swapForAmount(
                    Formatters.amount(review.outputAmountUi),
                    review.outputToken.token.symbol,
                  ),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displaySmall,
                ),
                const SizedBox(height: 24),
                _InfoPanel(
                  rows: [
                    _InfoRowData(
                      l10n.swapPay,
                      '${Formatters.amount(review.inputAmountUi)} ${review.inputToken.token.symbol}',
                    ),
                    _InfoRowData(
                      l10n.swapReceive,
                      '${Formatters.amount(review.outputAmountUi)} ${review.outputToken.token.symbol}',
                    ),
                    _InfoRowData(
                      l10n.swapMinimumReceive,
                      '${Formatters.amount(_minimumReceive(review))} ${review.outputToken.token.symbol}',
                    ),
                    _InfoRowData(
                      l10n.swapSlippage,
                      '${(review.slippageBps / 100).toStringAsFixed(review.slippageBps % 100 == 0 ? 0 : 1)}%',
                    ),
                    _InfoRowData(
                      l10n.swapPriorityFee,
                      review.priorityPreset.localizedLabel(l10n),
                    ),
                    _InfoRowData(
                      l10n.commonNetworkFee,
                      review.buildResult.prioritizationFeeLamports == null
                          ? l10n.commonAuto
                          : l10n.swapLamports(
                              review.buildResult.prioritizationFeeLamports!,
                            ),
                    ),
                    _InfoRowData(
                      l10n.swapRoute,
                      review.buildResult.routeLabels.isEmpty
                          ? 'Jupiter'
                          : review.buildResult.routeLabels.join(', '),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonal(
                  onPressed: _transitioning ? null : () => context.pop(),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(58),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  child: Text(l10n.commonCancel),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: FilledButton(
                  onPressed: _transitioning
                      ? null
                      : () {
                          setState(() => _transitioning = true);
                          context.pushReplacement(
                            SwapExecutePage.routePath,
                            extra: review,
                          );
                        },
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(58),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  child: Text(
                    _transitioning ? l10n.commonLoading : l10n.swapButton,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _minimumReceive(SwapReviewData review) {
    final raw =
        BigInt.tryParse(review.buildResult.otherAmountThreshold) ?? BigInt.zero;
    var divisor = 1.0;
    for (var index = 0; index < review.outputToken.token.decimals; index++) {
      divisor *= 10;
    }
    return raw.toDouble() / divisor;
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.rows});

  final List<_InfoRowData> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          for (var index = 0; index < rows.length; index++) ...[
            _InfoRow(data: rows[index]),
            if (index != rows.length - 1)
              Divider(
                height: 1,
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
          ],
        ],
      ),
    );
  }
}

class _InfoRowData {
  const _InfoRowData(this.label, this.value);

  final String label;
  final String value;
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.data});

  final _InfoRowData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Row(
        children: [
          Expanded(child: Text(data.label, style: theme.textTheme.bodyLarge)),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              data.value,
              textAlign: TextAlign.end,
              style: theme.textTheme.titleLarge,
            ),
          ),
        ],
      ),
    );
  }
}
