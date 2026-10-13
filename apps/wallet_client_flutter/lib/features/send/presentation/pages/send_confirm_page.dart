import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../l10n/l10n.dart';
import '../../../portfolio/presentation/providers/portfolio_provider.dart';
import '../../domain/send_draft_data.dart';
import 'send_execute_page.dart';

class SendConfirmPage extends ConsumerStatefulWidget {
  const SendConfirmPage({super.key, required this.draft});

  static const routeName = 'sendConfirm';
  static const routePath = '/send/confirm';

  final SendDraftData draft;

  @override
  ConsumerState<SendConfirmPage> createState() => _SendConfirmPageState();
}

class _SendConfirmPageState extends ConsumerState<SendConfirmPage> {
  bool _transitioning = false;

  @override
  Widget build(BuildContext context) {
    final symbol = Formatters.tokenSymbol(widget.draft.token.symbol);
    final l10n = context.l10n;

    return AppScaffold(
      title: l10n.sendConfirmTitle,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Icon(
                    Icons.send_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 52,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  '${Formatters.amount(widget.draft.amount)} $symbol',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.displayLarge?.copyWith(fontSize: 40),
                ),
                const SizedBox(height: 6),
                Text(
                  '~${Formatters.usd(widget.draft.approximateUsd)}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                _InfoPanel(
                  rows: [
                    _InfoRowData(
                      l10n.commonTo,
                      _compactAddress(widget.draft.destinationAddress),
                      isAddress: true,
                    ),
                    _InfoRowData(l10n.commonNetwork, l10n.commonSolana),
                    _InfoRowData(
                      l10n.commonNetworkFee,
                      Formatters.usd(
                        widget.draft.estimatedNetworkFeeSol * _solUsd(ref),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _BottomActionRow(
            leadingLabel: l10n.commonCancel,
            trailingLabel: _transitioning
                ? l10n.commonLoading
                : l10n.commonSend,
            onLeading: _transitioning ? null : () => context.pop(),
            onTrailing: _transitioning
                ? null
                : () {
                    setState(() => _transitioning = true);
                    context.pushReplacement(
                      SendExecutePage.routePath,
                      extra: widget.draft,
                    );
                  },
          ),
        ],
      ),
    );
  }

  double _solUsd(WidgetRef ref) {
    final portfolio = ref.read(activePortfolioProvider).valueOrNull;
    if (portfolio == null) {
      return 0;
    }
    final sol = portfolio.assets
        .where((item) => item.token.isNative)
        .firstOrNull;
    return double.tryParse(sol?.priceQuote?.priceUsd ?? '') ?? 0;
  }

  String _compactAddress(String address) {
    final value = address.trim();
    if (value.length <= 10) {
      return value;
    }
    return '${value.substring(0, 3)}...${value.substring(value.length - 5)}';
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
  const _InfoRowData(this.label, this.value, {this.isAddress = false});

  final String label;
  final String value;
  final bool isAddress;
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
          Expanded(
            flex: 2,
            child: Text(
              data.label,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              data.value,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style:
                  (data.isAddress
                          ? theme.textTheme.titleMedium
                          : theme.textTheme.titleLarge)
                      ?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: data.isAddress ? 0.2 : null,
                      ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActionRow extends StatelessWidget {
  const _BottomActionRow({
    required this.leadingLabel,
    required this.trailingLabel,
    required this.onLeading,
    required this.onTrailing,
  });

  final String leadingLabel;
  final String trailingLabel;
  final VoidCallback? onLeading;
  final VoidCallback? onTrailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.tonal(
            onPressed: onLeading,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(58),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
            ),
            child: Text(leadingLabel),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: FilledButton(
            onPressed: onTrailing,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(58),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
            ),
            child: Text(trailingLabel),
          ),
        ),
      ],
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
