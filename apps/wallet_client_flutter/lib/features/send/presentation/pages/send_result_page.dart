import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../l10n/l10n.dart';
import '../../../portfolio/presentation/pages/portfolio_page.dart';
import '../../domain/send_result_data.dart';

class SendResultPage extends StatelessWidget {
  const SendResultPage({super.key, required this.result});

  static const routeName = 'sendResult';
  static const routePath = '/send/result';

  final SendResultData result;

  @override
  Widget build(BuildContext context) {
    final success = result.success;
    final theme = Theme.of(context);

    return AppScaffold(
      title: '',
      showTopBar: false,
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 152,
            height: 152,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: success
                  ? const Color(0x192FA36B)
                  : theme.colorScheme.errorContainer.withValues(alpha: 0.4),
            ),
            child: Icon(
              success ? Icons.check_rounded : Icons.error_outline_rounded,
              size: 72,
              color: success
                  ? const Color(0xFF2FA36B)
                  : theme.colorScheme.onErrorContainer,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            success ? context.l10n.sendSubmitted : context.l10n.sendFailed,
            style: theme.textTheme.displayLarge?.copyWith(fontSize: 42),
          ),
          const SizedBox(height: 12),
          Text(
            success
                ? context.l10n.sendSubmittedMessage(
                    Formatters.compactAddress(
                      result.destinationAddress,
                      visibleChars: 5,
                    ),
                    result.amountDisplay,
                    result.symbol,
                  )
                : (result.message ??
                      context.l10n.sendTransactionCouldNotComplete),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge,
          ),
          if (success && result.signature != null) ...[
            const SizedBox(height: 22),
            TextButton(
              onPressed: () => _openTransaction(result.signature!),
              child: Text(context.l10n.sendViewTransaction),
            ),
          ],
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: () => context.go(PortfolioPage.routePath),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(58),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: Text(context.l10n.commonClose),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openTransaction(String signature) async {
    final uri = Uri.parse('https://solscan.io/tx/$signature');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
