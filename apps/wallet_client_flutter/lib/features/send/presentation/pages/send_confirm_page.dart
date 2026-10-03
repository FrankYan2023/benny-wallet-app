import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/network_badge.dart';
import '../../../../l10n/l10n.dart';
import '../../../portfolio/presentation/providers/portfolio_provider.dart';
import '../../domain/send_draft_data.dart';
import '../widgets/send_widgets.dart';
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
            child: SendReviewContent(
              amountText: '${Formatters.amount(widget.draft.amount)} $symbol',
              fiatText: '~${Formatters.usd(widget.draft.approximateUsd)}',
              rows: [
                SendInfoRowData(
                  l10n.commonTo,
                  _compactAddress(widget.draft.destinationAddress),
                  isAddress: true,
                ),
                SendInfoRowData(
                  l10n.commonNetwork,
                  l10n.commonSolana,
                  valueWidget: NetworkBadge.solana(
                    alignment: MainAxisAlignment.end,
                  ),
                ),
                SendInfoRowData(
                  l10n.commonNetworkFee,
                  Formatters.usd(
                    widget.draft.estimatedNetworkFeeSol * _solUsd(ref),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SendBottomActionRow(
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

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) {
      return null;
    }
    return iterator.current;
  }
}
