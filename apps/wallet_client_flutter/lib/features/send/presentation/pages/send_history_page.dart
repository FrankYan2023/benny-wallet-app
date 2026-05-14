import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/di/providers.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/clipboard_utils.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../asset_detail/presentation/pages/asset_detail_page.dart';

final sendHistoryProvider =
    FutureProvider.autoDispose<List<RemoteSendHistoryItem>>((ref) async {
      return ref.read(backendApiClientProvider).getSenderHistory(limit: 50);
    });

final sendHistoryTokensProvider =
    FutureProvider.autoDispose<List<RemoteTokenCatalogItem>>((ref) async {
      return ref.read(backendApiClientProvider).getTokens();
    });

class SendHistoryDetailData {
  const SendHistoryDetailData({required this.item, this.token});

  final RemoteSendHistoryItem item;
  final RemoteTokenCatalogItem? token;
}

class SendHistoryPage extends ConsumerWidget {
  const SendHistoryPage({super.key});

  static const routeName = 'sendHistory';
  static const routePath = '/send/history';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(sendHistoryProvider);
    final tokens = ref.watch(sendHistoryTokensProvider).valueOrNull ?? const [];

    return AppScaffold(
      title: 'Send history',
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(sendHistoryProvider);
          ref.invalidate(sendHistoryTokensProvider);
          await ref.read(sendHistoryProvider.future);
        },
        child: history.when(
          data: (items) {
            final mergedItems = _mergeHistoryItems(items);
            if (mergedItems.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('No send history yet.')),
                ],
              );
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: mergedItems.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = mergedItems[index];
                final token = _findToken(tokens, item.tokenMint);
                return _SendHistoryTile(item: item, token: token);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              const SizedBox(height: 120),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Unable to load send history: $error',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SendHistoryDetailPage extends StatelessWidget {
  const SendHistoryDetailPage({super.key, required this.data});

  static const routeName = 'sendHistoryDetail';
  static const routePath = '/send/history/detail';

  final SendHistoryDetailData data;

  @override
  Widget build(BuildContext context) {
    final item = data.item;
    final token = data.token;
    final theme = Theme.of(context);
    final tokenMint = item.tokenMint;
    final destination = item.destinationAddress;
    final statusColor = _statusColor(theme, item);
    final confirmedAt = item.confirmedAt ?? item.finalizedAt;

    return AppScaffold(
      title: 'Send details',
      child: ListView(
        children: [
          _StatusCard(item: item, color: statusColor),
          const SizedBox(height: 14),
          _TokenInfoCard(token: token, item: item),
          const SizedBox(height: 14),
          _TimelinePanel(item: item),
          const SizedBox(height: 14),
          _DetailPanel(
            rows: [
              _DetailRowData(
                label: 'To',
                value: destination == null || destination.isEmpty
                    ? '--'
                    : _compactAddress(destination),
                copyValue: destination,
              ),
              _DetailRowData(
                label: 'Amount',
                value: item.displayAmountFor(token),
              ),
              _DetailRowData(label: 'Network', value: 'Solana'),
              _DetailRowData(label: 'Network fee', value: item.displayFee),
              _DetailRowData(
                label: 'Submitted',
                value: _formatTime(item.submittedAt),
              ),
              _DetailRowData(
                label: 'Confirmed',
                value: confirmedAt == null || confirmedAt.isEmpty
                    ? 'Not confirmed yet'
                    : _formatTime(confirmedAt),
              ),
              _DetailRowData(label: 'Status', value: _statusLabel(item)),
              _DetailRowData(
                label: 'Signature',
                value: _compactSignature(item.signature),
                copyValue: item.signature.isEmpty ? null : item.signature,
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (tokenMint != null && tokenMint.isNotEmpty)
            OutlinedButton.icon(
              onPressed: () => context.push(AssetDetailPage.pathFor(tokenMint)),
              icon: const Icon(Icons.info_outline_rounded),
              label: const Text('Open token details'),
            ),
          if (item.signature.isNotEmpty) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => launchUrl(
                Uri.parse('https://solscan.io/tx/${item.signature}'),
                mode: LaunchMode.externalApplication,
              ),
              icon: const Icon(Icons.open_in_new_rounded),
              label: const Text('View on Solscan'),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SendHistoryTile extends StatelessWidget {
  const _SendHistoryTile({required this.item, this.token});

  final RemoteSendHistoryItem item;
  final RemoteTokenCatalogItem? token;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _statusColor(theme, item);
    final destination = item.destinationAddress;

    return Material(
      color: theme.colorScheme.surface.withValues(alpha: 0.96),
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: () => context.push(
          SendHistoryDetailPage.routePath,
          extra: SendHistoryDetailData(item: item, token: token),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _TokenAvatar(token: token, fallbackSymbol: item.fallbackSymbol),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.displayTitleFor(token),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      destination == null || destination.isEmpty
                          ? 'To --'
                          : 'To ${_compactAddress(destination)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatTime(item.submittedAt),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary.withValues(alpha: 0.82),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item.displayAmountFor(token),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _statusLabel(item),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 6),
              Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.item, required this.color});

  final RemoteSendHistoryItem item;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(_statusIcon(item), color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _statusLabel(item),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.statusSource,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelinePanel extends StatelessWidget {
  const _TimelinePanel({required this.item});

  final RemoteSendHistoryItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final confirmedAt = item.confirmedAt ?? item.finalizedAt;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transaction timeline',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          _TimelineEntry(
            icon: Icons.outbox_rounded,
            title: 'Submitted to sender',
            subtitle: 'Helius Sender accepted the signed transaction.',
            time: _formatTime(item.submittedAt),
            active: true,
          ),
          const SizedBox(height: 12),
          _TimelineEntry(
            icon: item.result == 'failed'
                ? Icons.error_outline_rounded
                : Icons.done_all_rounded,
            title: item.result == 'failed'
                ? 'Async result failed'
                : confirmedAt == null || confirmedAt.isEmpty
                ? 'Waiting for async confirmation'
                : 'Async confirmation received',
            subtitle: item.statusSource == 'helius_webhook'
                ? 'Updated from Helius webhook.'
                : item.statusSource == 'rpc_sync'
                ? 'Updated from chain status sync.'
                : 'Confirmation has not been received yet.',
            time: confirmedAt == null || confirmedAt.isEmpty
                ? '--'
                : _formatTime(confirmedAt),
            active: confirmedAt != null && confirmedAt.isNotEmpty,
            failed: item.result == 'failed',
          ),
        ],
      ),
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.active,
    this.failed = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final bool active;
  final bool failed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = failed
        ? theme.colorScheme.error
        : active
        ? const Color(0xFF2FA36B)
        : AppColors.textSecondary;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          time,
          textAlign: TextAlign.right,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _TokenInfoCard extends StatelessWidget {
  const _TokenInfoCard({required this.token, required this.item});

  final RemoteTokenCatalogItem? token;
  final RemoteSendHistoryItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = token?.name ?? item.fallbackSymbol;
    final symbol = token?.symbol ?? item.fallbackSymbol;

    return Material(
      color: theme.colorScheme.surface.withValues(alpha: 0.96),
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: item.tokenMint == null || item.tokenMint!.isEmpty
            ? null
            : () => context.push(AssetDetailPage.pathFor(item.tokenMint!)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _TokenAvatar(token: token, fallbackSymbol: symbol, size: 58),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      symbol,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (item.tokenMint != null && item.tokenMint!.isNotEmpty)
                const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailPanel extends StatelessWidget {
  const _DetailPanel({required this.rows});

  final List<_DetailRowData> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          for (var index = 0; index < rows.length; index++) ...[
            _DetailRow(data: rows[index]),
            if (index != rows.length - 1)
              Divider(
                height: 1,
                color: theme.dividerColor.withValues(alpha: 0.5),
              ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.data});

  final _DetailRowData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          SizedBox(
            width: 104,
            child: Text(
              data.label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              data.value,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (data.copyValue != null && data.copyValue!.isNotEmpty) ...[
            const SizedBox(width: 4),
            IconButton(
              tooltip: 'Copy',
              onPressed: () async {
                await ClipboardUtils.setDataWithAutoWipe(
                  data.copyValue!,
                  clearDelay: ClipboardUtils.addressClearDelay,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Copied')));
                }
              },
              icon: const Icon(Icons.copy_rounded, size: 20),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRowData {
  const _DetailRowData({
    required this.label,
    required this.value,
    this.copyValue,
  });

  final String label;
  final String value;
  final String? copyValue;
}

class _TokenAvatar extends StatelessWidget {
  const _TokenAvatar({
    this.token,
    required this.fallbackSymbol,
    this.size = 48,
  });

  final RemoteTokenCatalogItem? token;
  final String fallbackSymbol;
  final double size;

  @override
  Widget build(BuildContext context) {
    final symbol = token?.symbol ?? fallbackSymbol;
    final logoUrl = token?.logoUrl.trim() ?? '';
    final child = logoUrl.isEmpty
        ? _FallbackTokenIcon(symbol: symbol)
        : _NetworkTokenIcon(logoUrl: logoUrl, symbol: symbol);

    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.34),
      child: SizedBox(width: size, height: size, child: child),
    );
  }
}

class _NetworkTokenIcon extends StatelessWidget {
  const _NetworkTokenIcon({required this.logoUrl, required this.symbol});

  final String logoUrl;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    if (logoUrl.toLowerCase().endsWith('.svg')) {
      return SvgPicture.network(
        logoUrl,
        fit: BoxFit.cover,
        placeholderBuilder: (_) => _FallbackTokenIcon(symbol: symbol),
      );
    }

    return Image.network(
      logoUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _FallbackTokenIcon(symbol: symbol),
    );
  }
}

class _FallbackTokenIcon extends StatelessWidget {
  const _FallbackTokenIcon({required this.symbol});

  final String symbol;

  @override
  Widget build(BuildContext context) {
    final normalized = symbol.trim().isEmpty ? '?' : symbol.trim();
    final initial = normalized.characters.first.toUpperCase();
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: _fallbackColors(normalized)),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

extension on RemoteSendHistoryItem {
  String? get tokenMint {
    final to = toMint?.trim();
    if (to != null && to.isNotEmpty) {
      return to;
    }
    final from = fromMint?.trim();
    if (from != null && from.isNotEmpty) {
      return from;
    }
    return null;
  }

  String get displayAmount {
    final value = amount?.trim();
    return value == null || value.isEmpty ? '--' : value;
  }

  String displayAmountFor(RemoteTokenCatalogItem? token) {
    final value = displayAmount;
    if (value == '--') {
      return '--';
    }
    final symbol = token?.symbol.trim();
    if (symbol == null || symbol.isEmpty) {
      return value;
    }
    final parts = value.split(RegExp(r'\s+'));
    if (parts.length > 1 && parts.last.toUpperCase() == symbol.toUpperCase()) {
      return value;
    }
    return '$value $symbol';
  }

  String displayTitleFor(RemoteTokenCatalogItem? token) {
    final amount = displayAmountFor(token);
    if (amount != '--') {
      return amount;
    }
    final symbol = token?.symbol.trim();
    if (symbol != null && symbol.isNotEmpty) {
      return symbol;
    }
    final normalized = fallbackSymbol.trim();
    if (normalized.isEmpty || normalized.toUpperCase() == 'SEND') {
      return 'Send transaction';
    }
    return normalized;
  }

  String get displayFee {
    final fee = feeLamports;
    if (fee == null) {
      return '--';
    }
    final sol = fee / lamportsPerSol;
    return '${sol.toStringAsFixed(9).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '')} SOL';
  }

  String get fallbackSymbol {
    final value = displayAmount;
    if (value != '--') {
      final parts = value.split(RegExp(r'\s+'));
      if (parts.length > 1 && parts.last.trim().isNotEmpty) {
        return parts.last.trim();
      }
    }
    return txType.toUpperCase() == 'SEND' ? 'SOL' : txType.toUpperCase();
  }
}

List<RemoteSendHistoryItem> _mergeHistoryItems(
  List<RemoteSendHistoryItem> items,
) {
  final sorted = [...items]..sort(
      (left, right) =>
          _recordTime(right).compareTo(_recordTime(left)),
    );
  final merged = <RemoteSendHistoryItem>[];

  for (final item in sorted) {
    final matchIndex = merged.indexWhere(
      (candidate) => _shouldMergeHistoryItem(candidate, item),
    );
    if (matchIndex < 0) {
      merged.add(item);
      continue;
    }
    merged[matchIndex] = _mergeHistoryItem(merged[matchIndex], item);
  }

  return merged..sort(
      (left, right) =>
          _recordTime(right).compareTo(_recordTime(left)),
    );
}

bool _shouldMergeHistoryItem(
  RemoteSendHistoryItem left,
  RemoteSendHistoryItem right,
) {
  if (left.signature.isNotEmpty && left.signature == right.signature) {
    return true;
  }
  if (left.referenceId != null &&
      right.referenceId != null &&
      left.referenceId == right.referenceId) {
    return true;
  }

  final leftPlaceholder = _isSubmittedPlaceholder(left);
  final rightPlaceholder = _isSubmittedPlaceholder(right);
  if (leftPlaceholder == rightPlaceholder) {
    return false;
  }

  final delta = _recordTime(left).difference(_recordTime(right)).abs();
  return delta <= const Duration(minutes: 5);
}

bool _isSubmittedPlaceholder(RemoteSendHistoryItem item) {
  final submitted = item.status == 'submitted' || item.result == 'pending';
  return submitted &&
      (item.amount == null || item.amount!.trim().isEmpty) &&
      (item.destinationAddress == null ||
          item.destinationAddress!.trim().isEmpty) &&
      (item.fromMint == null || item.fromMint!.trim().isEmpty) &&
      (item.toMint == null || item.toMint!.trim().isEmpty);
}

RemoteSendHistoryItem _mergeHistoryItem(
  RemoteSendHistoryItem left,
  RemoteSendHistoryItem right,
) {
  final preferred = _historyPriority(right) > _historyPriority(left)
      ? right
      : left;
  final fallback = identical(preferred, right) ? left : right;
  return RemoteSendHistoryItem(
    signature: preferred.signature.isNotEmpty
        ? preferred.signature
        : fallback.signature,
    txType: preferred.txType.isNotEmpty ? preferred.txType : fallback.txType,
    status: preferred.status == 'submitted'
        ? fallback.status
        : preferred.status,
    result: preferred.result == 'pending'
        ? fallback.result
        : preferred.result,
    statusSource: preferred.statusSource.isNotEmpty
        ? preferred.statusSource
        : fallback.statusSource,
    fromMint: preferred.fromMint ?? fallback.fromMint,
    toMint: preferred.toMint ?? fallback.toMint,
    amount: preferred.amount ?? fallback.amount,
    referenceId: preferred.referenceId ?? fallback.referenceId,
    destinationAddress:
        preferred.destinationAddress ?? fallback.destinationAddress,
    feeLamports: preferred.feeLamports ?? fallback.feeLamports,
    errorMessage: preferred.errorMessage ?? fallback.errorMessage,
    description: preferred.description ?? fallback.description,
    submittedAt: _earlierTimeText(preferred.submittedAt, fallback.submittedAt),
    confirmedAt: preferred.confirmedAt ?? fallback.confirmedAt,
    finalizedAt: preferred.finalizedAt ?? fallback.finalizedAt,
  );
}

int _historyPriority(RemoteSendHistoryItem item) {
  if (item.status == 'failed' || item.result == 'failed') {
    return 4;
  }
  if (item.status == 'finalized') {
    return 3;
  }
  if (item.status == 'confirmed' || item.result == 'success') {
    return 2;
  }
  return 1;
}

DateTime _recordTime(RemoteSendHistoryItem item) {
  return DateTime.tryParse(item.submittedAt) ??
      DateTime.tryParse(item.confirmedAt ?? '') ??
      DateTime.tryParse(item.finalizedAt ?? '') ??
      DateTime.fromMillisecondsSinceEpoch(0);
}

String _earlierTimeText(String left, String right) {
  final leftTime = DateTime.tryParse(left);
  final rightTime = DateTime.tryParse(right);
  if (leftTime == null) {
    return right;
  }
  if (rightTime == null) {
    return left;
  }
  return leftTime.isBefore(rightTime) ? left : right;
}

const double lamportsPerSol = 1000000000;

RemoteTokenCatalogItem? _findToken(
  List<RemoteTokenCatalogItem> tokens,
  String? mint,
) {
  if (mint == null || mint.isEmpty) {
    return null;
  }
  for (final token in tokens) {
    if (token.mintAddress == mint) {
      return token;
    }
  }
  return null;
}

String _statusLabel(RemoteSendHistoryItem item) {
  if (item.result == 'failed' || item.status == 'failed') {
    return 'Failed';
  }
  if (item.status == 'finalized') {
    return 'Finalized';
  }
  if (item.status == 'confirmed') {
    return 'Confirmed';
  }
  return 'Submitted';
}

IconData _statusIcon(RemoteSendHistoryItem item) {
  if (item.result == 'failed' || item.status == 'failed') {
    return Icons.error_outline_rounded;
  }
  if (item.status == 'submitted') {
    return Icons.schedule_rounded;
  }
  return Icons.check_rounded;
}

Color _statusColor(ThemeData theme, RemoteSendHistoryItem item) {
  if (item.result == 'failed' || item.status == 'failed') {
    return theme.colorScheme.error;
  }
  if (item.status == 'submitted') {
    return AppColors.primary;
  }
  return const Color(0xFF2FA36B);
}

String _compactAddress(String address) {
  final value = address.trim();
  if (value.length <= 10) {
    return value;
  }
  return '${value.substring(0, 3)}...${value.substring(value.length - 5)}';
}

String _compactSignature(String signature) {
  if (signature.isEmpty) {
    return '--';
  }
  return Formatters.compactAddress(signature, visibleChars: 4);
}

String _formatTime(String value) {
  final parsed = DateTime.tryParse(value);
  if (parsed == null) {
    return value.isEmpty ? '--' : value;
  }
  final local = parsed.toLocal();
  String two(int input) => input.toString().padLeft(2, '0');
  return '${local.year}-${two(local.month)}-${two(local.day)} ${two(local.hour)}:${two(local.minute)}';
}

List<Color> _fallbackColors(String symbol) {
  switch (symbol.toUpperCase()) {
    case 'SOL':
      return const [Color(0xFF2F7DF4), Color(0xFF18D6A4)];
    case 'BYC':
      return const [Color(0xFFD99915), Color(0xFFFFD166)];
    case 'USDC':
      return const [Color(0xFF2775CA), Color(0xFF6BB8FF)];
    case 'USDT':
      return const [Color(0xFF26A17B), Color(0xFF7AE0BF)];
    default:
      return const [Color(0xFF8A4F00), Color(0xFFD99B2B)];
  }
}
