import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/di/providers.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/clipboard_utils.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../l10n/l10n.dart';
import '../../../asset_detail/presentation/pages/asset_detail_page.dart';
import '../../../auth/domain/wallet_controller_state.dart';
import '../../../auth/presentation/providers/wallet_controller.dart';
import '../../../transaction_history/domain/transaction_activity.dart';
import '../../domain/notification_message.dart';
import '../providers/notification_inbox_provider.dart';

final receivedTransferDetailProvider = FutureProvider.autoDispose
    .family<RemoteReceivedTransferItem, String>((ref, id) async {
      final walletState = ref.read(walletControllerProvider);
      if (await _canUseBackendHistory(ref, walletState)) {
        try {
          return await ref
              .read(backendApiClientProvider)
              .getReceivedTransfer(id);
        } catch (_) {
          // Fall back to the chain-derived list below without asking Seed Vault
          // for another backend authentication signature.
        }
      }

      final items = await _loadChainReceivedHistory(ref, walletState);
      for (final item in items) {
        if (item.id == id || item.signature == id || item.id == 'chain:$id') {
          return item;
        }
      }
      throw StateError('Received transfer details are not available yet.');
    });

final receivedTransfersProvider =
    FutureProvider.autoDispose<List<RemoteReceivedTransferItem>>((ref) async {
      final walletState = ref.read(walletControllerProvider);
      var backendItems = const <RemoteReceivedTransferItem>[];
      if (await _canUseBackendHistory(ref, walletState)) {
        try {
          backendItems = await ref
              .read(backendApiClientProvider)
              .getReceivedTransfers(limit: 50);
        } catch (_) {
          if (!walletState.isExternalWallet) {
            rethrow;
          }
        }
      }
      if (backendItems.isNotEmpty) {
        return backendItems;
      }

      return _loadChainReceivedHistory(ref, walletState);
    });

const _chainHistoryRequestTimeout = Duration(seconds: 3);

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  static const routeName = 'notifications';
  static const routePath = '/notifications';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inbox = ref.watch(notificationInboxProvider);
    final receivedTransfers = ref.watch(receivedTransfersProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);
    final l10n = context.l10n;

    ref.listen<AsyncValue<List<RemoteReceivedTransferItem>>>(
      receivedTransfersProvider,
      (_, next) {
        next.whenData(
          ref.read(notificationInboxProvider.notifier).syncReceivedTransfers,
        );
      },
    );

    return AppScaffold(
      title: l10n.portfolioMessages,
      actions: [
        TextButton(
          onPressed: unreadCount == 0
              ? null
              : () async {
                  await ref
                      .read(notificationInboxProvider.notifier)
                      .markAllRead();
                  await ref.read(localNotificationServiceProvider).cancelAll();
                  await ref
                      .read(appBadgeServiceProvider)
                      .clearApplicationBadge();
                },
          child: Text(l10n.notificationsMarkAllRead),
        ),
      ],
      child: inbox.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _EmptyState(
          icon: Icons.error_outline_rounded,
          title: l10n.notificationsUnavailableTitle,
          subtitle: l10n.notificationsUnavailableSubtitle,
        ),
        data: (messages) {
          if (messages.isEmpty && receivedTransfers.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (messages.isEmpty) {
            return _EmptyState(
              icon: Icons.notifications_none_rounded,
              title: l10n.notificationsEmptyTitle,
              subtitle: l10n.notificationsEmptySubtitle,
            );
          }

          return ListView.separated(
            itemCount: messages.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              return _MessageCard(message: messages[index]);
            },
          );
        },
      ),
    );
  }
}

class ReceivedHistoryPage extends ConsumerWidget {
  const ReceivedHistoryPage({super.key});

  static const routeName = 'receivedHistory';
  static const routePath = '/receive/history';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(receivedTransfersProvider);

    return AppScaffold(
      title: context.l10n.receivedHistoryTitle,
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(receivedTransfersProvider);
          final transfers = await ref.read(receivedTransfersProvider.future);
          await ref
              .read(notificationInboxProvider.notifier)
              .syncReceivedTransfers(transfers);
        },
        child: history.when(
          data: (items) {
            if (items.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 120),
                  Center(child: Text(context.l10n.receivedHistoryEmpty)),
                ],
              );
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _ReceivedHistoryTile(item: items[index]);
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
                    context.l10n.receivedHistoryLoadFailed('$error'),
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

class ReceivedNotificationDetailPage extends ConsumerWidget {
  const ReceivedNotificationDetailPage({super.key, required this.message});

  static const routeName = 'receivedNotificationDetail';
  static const routePath = '/notifications/received-detail';

  final NotificationMessage message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventId = message.eventId;
    if (eventId == null || eventId.isEmpty) {
      return AppScaffold(
        title: context.l10n.receivedDetailsTitle,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              context.l10n.receivedDetailsMissingId,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final detail = ref.watch(receivedTransferDetailProvider(eventId));
    return AppScaffold(
      title: context.l10n.receivedDetailsTitle,
      child: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.receivedDetailsLoadFailed('$error'),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () =>
                      ref.invalidate(receivedTransferDetailProvider(eventId)),
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(context.l10n.commonRetry),
                ),
              ],
            ),
          ),
        ),
        data: (item) => _ReceivedTransferDetailBody(item: item),
      ),
    );
  }
}

class _ReceivedTransferDetailBody extends StatelessWidget {
  const _ReceivedTransferDetailBody({required this.item});

  final RemoteReceivedTransferItem item;

  @override
  Widget build(BuildContext context) {
    final sender = item.senderAddress;
    final timestamp =
        _parseTimestamp(item.confirmedAt) ??
        _parseTimestamp(item.createdAt) ??
        DateTime.now();

    return ListView(
      children: [
        _ReceivedStatusCard(item: item, timestamp: timestamp),
        const SizedBox(height: 14),
        _ReceivedTokenInfoCard(item: item),
        const SizedBox(height: 14),
        _ReceivedTimelinePanel(item: item, timestamp: timestamp),
        const SizedBox(height: 14),
        if (item.relatedTransfers.isNotEmpty) ...[
          _RelatedTransfersPanel(items: item.relatedTransfers),
          const SizedBox(height: 14),
        ],
        _DetailPanel(
          rows: [
            _DetailRowData(
              label: context.l10n.commonToken,
              value: item.symbol.isEmpty ? '--' : item.symbol,
            ),
            _DetailRowData(
              label: context.l10n.commonAmount,
              value: item.displayAmount,
            ),
            _DetailRowData(
              label: context.l10n.commonFrom,
              value: sender == null ? '--' : _compactAddress(sender),
              copyValue: sender,
            ),
            _DetailRowData(
              label: context.l10n.commonNetwork,
              value: context.l10n.commonSolana,
            ),
            _DetailRowData(
              label: context.l10n.commonStatus,
              value: _receivedStatusLabel(context.l10n, item.status),
            ),
            _DetailRowData(
              label: context.l10n.commonSignature,
              value: item.signature.isEmpty
                  ? '--'
                  : _compactAddress(item.signature),
              copyValue: item.signature,
            ),
          ],
        ),
        if (item.mintAddress.isNotEmpty) ...[
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () =>
                context.push(AssetDetailPage.pathFor(item.mintAddress)),
            icon: const Icon(Icons.info_outline_rounded),
            label: Text(context.l10n.sendOpenTokenDetails),
          ),
        ],
        if (item.signature.isNotEmpty) ...[
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => launchUrl(
              Uri.parse('https://solscan.io/tx/${item.signature}'),
              mode: LaunchMode.externalApplication,
            ),
            icon: const Icon(Icons.open_in_new_rounded),
            label: Text(context.l10n.sendViewOnSolscan),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}

class _ReceivedHistoryTile extends StatelessWidget {
  const _ReceivedHistoryTile({required this.item});

  final RemoteReceivedTransferItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sender = item.senderAddress;
    final timestamp =
        _parseTimestamp(item.confirmedAt) ??
        _parseTimestamp(item.createdAt) ??
        DateTime.now();

    return Material(
      color: theme.colorScheme.surface.withValues(alpha: 0.96),
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: () {
          if (item.id.startsWith('chain:') && item.signature.isNotEmpty) {
            launchUrl(
              Uri.parse('https://solscan.io/tx/${item.signature}'),
              mode: LaunchMode.externalApplication,
            );
            return;
          }
          context.push(
            ReceivedNotificationDetailPage.routePath,
            extra: NotificationMessage(
              id: 'received:${item.id}',
              title: context.l10n.receivedFundsTitle,
              body: context.l10n.receivedYouReceived(item.displayAmount),
              receivedAt: timestamp,
              type: 'incoming_funds',
              eventId: item.id,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _CoinAvatar(item: item, size: 42),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.receivedYouReceived(item.displayAmount),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF2FA36B),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sender == null || sender.isEmpty
                          ? context.l10n.receivedFromEmpty
                          : context.l10n.receivedFromAddress(
                              _compactAddress(sender),
                            ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatTimestamp(timestamp),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary.withValues(alpha: 0.82),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageCard extends ConsumerWidget {
  const _MessageCard({required this.message});

  final NotificationMessage message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isReceived = message.isIncomingFunds;
    final l10n = context.l10n;
    final body = _localizedMessageBody(l10n, message);

    return Dismissible(
      key: ValueKey(message.id),
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 22),
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.circular(28),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 22),
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.circular(28),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      onDismissed: (_) {
        ref.read(notificationInboxProvider.notifier).deleteMessage(message.id);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.notificationDeleted)));
      },
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: () async {
          await ref
              .read(notificationInboxProvider.notifier)
              .markRead(message.id);
          if (context.mounted) {
            context.push(
              ReceivedNotificationDetailPage.routePath,
              extra: message.copyWith(isRead: true),
            );
          }
        },
        child: WalletCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                child: _NotificationAvatar(isRead: message.isRead),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            _localizedMessageTitle(l10n, message),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: message.isRead
                                  ? FontWeight.w700
                                  : FontWeight.w900,
                            ),
                          ),
                        ),
                        if (!message.isRead) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 9,
                            height: 9,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE1582A),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      body,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isReceived ? const Color(0xFF2FA36B) : null,
                        fontWeight: isReceived ? FontWeight.w900 : null,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _formatTimestamp(message.receivedAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF8A7D6A),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF8A7D6A)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationAvatar extends StatelessWidget {
  const _NotificationAvatar({required this.isRead});

  final bool isRead;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: isRead ? const Color(0xFFF3EEE6) : const Color(0xFFFFE3A3),
        borderRadius: BorderRadius.circular(21),
      ),
      child: Icon(
        isRead
            ? Icons.notifications_none_rounded
            : Icons.notifications_active_rounded,
        color: const Color(0xFF8A5700),
        size: 20,
      ),
    );
  }
}

class _RelatedTransfersPanel extends StatelessWidget {
  const _RelatedTransfersPanel({required this.items});

  final List<RemoteReceivedTransferItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
            context.l10n.receivedRelatedChanges,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          for (var index = 0; index < items.length; index++) ...[
            Row(
              children: [
                _CoinAvatar(item: items[index], size: 34),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    items[index].symbol.isEmpty
                        ? context.l10n.commonToken
                        : items[index].symbol,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  items[index].displayAmount,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF2FA36B),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            if (index != items.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _ReceivedStatusCard extends StatelessWidget {
  const _ReceivedStatusCard({required this.item, required this.timestamp});

  final RemoteReceivedTransferItem item;
  final DateTime timestamp;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const color = Color(0xFF2FA36B);
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
            child: const Icon(Icons.call_received_rounded, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.assetReceived,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTimestamp(timestamp),
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

class _ReceivedTokenInfoCard extends StatelessWidget {
  const _ReceivedTokenInfoCard({required this.item});

  final RemoteReceivedTransferItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = item.name.isEmpty ? item.symbol : item.name;
    final symbol = item.symbol.isEmpty ? context.l10n.commonToken : item.symbol;
    return Material(
      color: theme.colorScheme.surface.withValues(alpha: 0.96),
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: item.mintAddress.isEmpty
            ? null
            : () => context.push(AssetDetailPage.pathFor(item.mintAddress)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _CoinAvatar(item: item, size: 58),
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
              if (item.mintAddress.isNotEmpty)
                const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReceivedTimelinePanel extends StatelessWidget {
  const _ReceivedTimelinePanel({required this.item, required this.timestamp});

  final RemoteReceivedTransferItem item;
  final DateTime timestamp;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
            context.l10n.transactionTimeline,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          _TimelineEntry(
            icon: Icons.call_received_rounded,
            title: context.l10n.receivedOnSolana,
            subtitle: item.status == 'failed'
                ? context.l10n.receivedMarkedFailed
                : context.l10n.receivedArrived,
            time: _formatTimestamp(timestamp),
            active: item.status != 'failed',
            failed: item.status == 'failed',
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

class _CoinAvatar extends StatelessWidget {
  const _CoinAvatar({required this.item, this.size = 26});

  final RemoteReceivedTransferItem item;
  final double size;

  @override
  Widget build(BuildContext context) {
    final logoUrl = item.logoUrl.trim();
    if (logoUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: Image.network(
          logoUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              _FallbackCoinAvatar(symbol: item.symbol, size: size),
        ),
      );
    }
    return _FallbackCoinAvatar(symbol: item.symbol, size: size);
  }
}

class _FallbackCoinAvatar extends StatelessWidget {
  const _FallbackCoinAvatar({required this.symbol, required this.size});

  final String symbol;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFFFE3A3),
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Text(
        symbol.isEmpty ? '?' : symbol.substring(0, 1).toUpperCase(),
        style: TextStyle(
          color: const Color(0xFF8A5700),
          fontSize: size * 0.46,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 42, color: const Color(0xFF8A5700)),
            const SizedBox(height: 14),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
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
            width: 88,
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
              tooltip: context.l10n.commonCopy,
              onPressed: () async {
                await ClipboardUtils.setDataWithAutoWipe(
                  data.copyValue!,
                  clearDelay: ClipboardUtils.addressClearDelay,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.l10n.commonCopied)),
                  );
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

String _formatTimestamp(DateTime value) {
  final local = value.toLocal();
  String twoDigits(int number) => number.toString().padLeft(2, '0');
  return '${local.year}-${twoDigits(local.month)}-${twoDigits(local.day)} '
      '${twoDigits(local.hour)}:${twoDigits(local.minute)}';
}

String _compactAddress(String value) {
  if (value.length <= 14) {
    return value;
  }
  return '${value.substring(0, 6)}...${value.substring(value.length - 6)}';
}

DateTime? _parseTimestamp(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  return DateTime.tryParse(value);
}

String _receivedStatusLabel(AppLocalizations l10n, String status) {
  return switch (status) {
    'failed' => l10n.sendStatusFailed,
    'confirmed' => l10n.sendStatusConfirmed,
    'finalized' => l10n.sendStatusFinalized,
    'success' => l10n.sendStatusConfirmed,
    _ => status.isEmpty ? '--' : status,
  };
}

String _localizedMessageTitle(
  AppLocalizations l10n,
  NotificationMessage message,
) {
  return message.isIncomingFunds ? l10n.receivedFundsTitle : message.title;
}

String _localizedMessageBody(
  AppLocalizations l10n,
  NotificationMessage message,
) {
  if (!message.isIncomingFunds) {
    return message.body;
  }

  const prefix = 'You received ';
  if (message.body.startsWith(prefix)) {
    return l10n.receivedYouReceived(message.body.substring(prefix.length));
  }
  if (message.body.trim().isEmpty ||
      message.body == 'New funds arrived in your wallet.') {
    return l10n.receivedNewFundsArrived;
  }
  return message.body;
}

Future<bool> _canUseBackendHistory(
  Ref ref,
  WalletControllerState walletState,
) async {
  final publicKey = walletState.publicKey;
  if (!walletState.isExternalWallet) {
    return true;
  }
  if (!walletState.isUnlocked || publicKey == null || publicKey.isEmpty) {
    return false;
  }
  return ref
      .read(backendSessionManagerProvider)
      .hasUsableStoredSession(publicKey);
}

Future<List<RemoteReceivedTransferItem>> _loadChainReceivedHistory(
  Ref ref,
  WalletControllerState walletState,
) async {
  final ownerAddress = walletState.publicKey;
  if (!walletState.isUnlocked || ownerAddress == null) {
    return const [];
  }

  final portfolio = await ref
      .read(portfolioRepositoryProvider)
      .loadPortfolio(ownerAddress);
  final assetDetailRepository = ref.read(assetDetailRepositoryProvider);
  final transfers = await Future.wait(
    portfolio.assets.map((asset) async {
      try {
        final items = await assetDetailRepository
            .loadTokenActivity(
              ownerAddress: ownerAddress,
              mintAddress: asset.token.mintAddress,
              symbol: asset.token.symbol,
              limit: 20,
            )
            .timeout(
              _chainHistoryRequestTimeout,
              onTimeout: () => const <TransactionActivity>[],
            );
        return [
          for (final item in items)
            if (item.direction == TransactionDirection.received)
              _receivedTransferFromActivity(
                item,
                ownerAddress: ownerAddress,
                mintAddress: asset.token.mintAddress,
                symbol: asset.token.symbol,
                name: asset.token.name,
                logoUrl: asset.logoUrl ?? '',
              ),
        ];
      } catch (_) {
        return const <RemoteReceivedTransferItem>[];
      }
    }),
  );

  final items = transfers.expand((items) => items).toList();
  items.sort((left, right) {
    final leftTime =
        _parseTimestamp(left.confirmedAt) ?? _parseTimestamp(left.createdAt);
    final rightTime =
        _parseTimestamp(right.confirmedAt) ?? _parseTimestamp(right.createdAt);
    return (rightTime ?? DateTime.fromMillisecondsSinceEpoch(0)).compareTo(
      leftTime ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  });
  return items;
}

RemoteReceivedTransferItem _receivedTransferFromActivity(
  TransactionActivity activity, {
  required String ownerAddress,
  required String mintAddress,
  required String symbol,
  required String name,
  required String logoUrl,
}) {
  final timestamp = activity.timestamp ?? DateTime.now();
  final timestampText = timestamp.toUtc().toIso8601String();
  final signature = activity.signature == '--' ? '' : activity.signature;
  return RemoteReceivedTransferItem(
    id: signature.isEmpty
        ? 'chain:$mintAddress:$timestampText'
        : 'chain:$signature',
    signature: signature,
    recipientAddress: ownerAddress,
    senderAddress: activity.counterparty == '--' ? null : activity.counterparty,
    mintAddress: mintAddress,
    symbol: symbol,
    name: name,
    logoUrl: logoUrl,
    amountText: activity.amount == '--' ? '' : activity.amount,
    status: activity.status,
    createdAt: timestampText,
    confirmedAt: timestampText,
  );
}
