import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:reown_walletkit/reown_walletkit.dart' show PairingMetadata;
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/config/app_features.dart';
import '../../../../core/walletconnect/dapp_actions.dart';
import '../../../../core/walletconnect/dapp_review.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../l10n/l10n.dart';
import '../../data/dapp_activity_store.dart';
import '../widgets/dapp_ui.dart';
import 'dapp_browser_page.dart';

/// Website activity on this phone, one row per website; a row opens that
/// website's records. Kept apart from the wallet's own history.
class DappActivityPage extends ConsumerWidget {
  const DappActivityPage({super.key});

  static const routeName = 'dappActivity';
  static const routePath = '/dapps/activity';

  Future<void> _clear(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: Text(l10n.dappActivityClearConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.dappActivityClear),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(dappActivityStoreProvider).clear();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final store = ref.watch(dappActivityStoreProvider);
    return AppScaffold(
      title: l10n.dappActivityTitle,
      child: ValueListenableBuilder<int>(
        valueListenable: store.revision,
        builder: (context, _, _) => FutureBuilder<List<DappActivity>>(
          future: store.all(),
          builder: (context, snapshot) {
            final all = snapshot.data;
            if (all == null) {
              return const Center(child: CircularProgressIndicator());
            }
            // Newest first already; keep the first entry of each site.
            final sites = <String, List<DappActivity>>{};
            for (final entry in all) {
              sites.putIfAbsent(entry.host, () => []).add(entry);
            }
            return ListView(
              children: [
                const _PrivacyNote(),
                const SizedBox(height: 12),
                if (sites.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      l10n.dappActivityEmpty,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                else ...[
                  for (final MapEntry(key: host, value: entries)
                      in sites.entries) ...[
                    _SiteRow(
                      latest: entries.first,
                      count: entries.length,
                      onTap: () => context.push(
                        DappSiteActivityPage.routePath,
                        extra: host,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => _clear(context, ref),
                    child: Text(l10n.dappActivityClear),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Every record of one website, newest first.
class DappSiteActivityPage extends ConsumerWidget {
  const DappSiteActivityPage({super.key, required this.host});

  static const routeName = 'dappSiteActivity';
  static const routePath = '/dapps/activity/site';

  final String host;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(dappActivityStoreProvider);
    return AppScaffold(
      title: host,
      actions: [
        if (AppFeatures.canOpenDappBrowser)
          IconButton(
            tooltip: context.l10n.browserOpen,
            onPressed: () =>
                context.push(DappBrowserPage.routePath, extra: 'https://$host'),
            icon: const Icon(Icons.open_in_browser_rounded),
          ),
      ],
      child: ValueListenableBuilder<int>(
        valueListenable: store.revision,
        builder: (context, _, _) => FutureBuilder<List<DappActivity>>(
          future: store.forHost(host),
          builder: (context, snapshot) {
            final entries = snapshot.data;
            if (entries == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView(
              children: [
                const _PrivacyNote(),
                const SizedBox(height: 12),
                if (entries.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      context.l10n.dappActivityEmpty,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                for (final entry in entries) ...[
                  DappActivityRow(entry: entry),
                  const SizedBox(height: 10),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.lock_outline_rounded,
          size: 14,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            context.l10n.dappActivityNote,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

PairingMetadata _peerOf(DappActivity entry) => PairingMetadata(
  name: entry.siteName,
  description: '',
  url: 'https://${entry.host}',
  icons: [?entry.icon],
);

String _when(BuildContext context, DateTime at) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  return DateFormat.yMd(locale).add_Hm().format(at);
}

class _SiteRow extends StatelessWidget {
  const _SiteRow({
    required this.latest,
    required this.count,
    required this.onTap,
  });

  final DappActivity latest;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: DappCard(
        child: Row(
          children: [
            DappIcon(peer: _peerOf(latest), size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    latest.siteName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    latest.host,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${l10n.dappActivityCount(count)}  ·  '
                    '${_when(context, latest.at)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class DappActivityRow extends StatelessWidget {
  const DappActivityRow({required this.entry});

  final DappActivity entry;

  static (String, IconData, Color?) headline(
    AppLocalizations l10n,
    DappActivity e,
  ) {
    String action() {
      if (e.action == 'message') {
        return l10n.dappActivityMessage;
      }
      final kind = DappActionKind.values
          .where((k) => k.name == e.action)
          .firstOrNull;
      final label = switch (kind) {
        DappActionKind.swap => l10n.dappActionSwap,
        DappActionKind.transfer => l10n.dappActionTransfer,
        DappActionKind.stake => l10n.dappActionStake,
        DappActionKind.lend => l10n.dappActionLend,
        DappActionKind.perps => l10n.dappActionPerps,
        DappActionKind.nft => l10n.dappActionNft,
        _ => l10n.dappActionOther,
      };
      return e.protocol == null
          ? label
          : '$label · ${l10n.dappActionVia(e.protocol!)}';
    }

    return switch (e.event) {
      DappActivityEvent.connected => (
        l10n.dappActivityConnected,
        Icons.link_rounded,
        DappTrust.safe.color,
      ),
      DappActivityEvent.disconnected => (
        l10n.dappActivityDisconnected,
        Icons.link_off_rounded,
        AppColors.textSecondary,
      ),
      DappActivityEvent.connectRejected => (
        l10n.dappActivityConnectRejected,
        Icons.link_off_rounded,
        AppColors.textSecondary,
      ),
      DappActivityEvent.signed => (
        '${action()}  ·  ${l10n.dappActivitySigned}',
        Icons.draw_rounded,
        DappTrust.safe.color,
      ),
      DappActivityEvent.sent => (
        '${action()}  ·  ${l10n.dappActivitySent}',
        Icons.send_rounded,
        DappTrust.safe.color,
      ),
      DappActivityEvent.rejected => (
        '${action()}  ·  ${l10n.dappActivityRejected}',
        Icons.block_rounded,
        AppColors.textSecondary,
      ),
      DappActivityEvent.failed => (
        '${action()}  ·  ${l10n.dappActivityFailed}',
        Icons.error_outline_rounded,
        DappTrust.danger.color,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final (title, icon, color) = headline(l10n, entry);
    final signature = entry.signature;
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => context.push(DappActivityDetailPage.routePath, extra: entry),
      child: DappCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            if (entry.pay != null) ...[
              const SizedBox(height: 6),
              Text(
                '${l10n.dappActionPay}  ${entry.pay}',
                style: TextStyle(color: DappTrust.danger.color),
              ),
            ],
            if (entry.receive != null) ...[
              const SizedBox(height: 2),
              Text(
                '${l10n.dappActionReceive}  ${entry.receive}',
                style: TextStyle(color: DappTrust.safe.color),
              ),
            ],
            const SizedBox(height: 6),
            Text(
              [
                _when(context, entry.at),
                if (entry.wallet != null)
                  l10n.dappActivityWallet(entry.wallet!),
                if (entry.viaPhone) l10n.dappActivityViaPhone,
                if (entry.inBrowser) l10n.dappActivityInBrowser,
              ].join('  ·  '),
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (signature != null)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  onPressed: () => unawaited(
                    launchUrl(
                      Uri.parse('https://solscan.io/tx/$signature'),
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
                  icon: const Icon(Icons.open_in_new_rounded, size: 16),
                  label: Text(l10n.dappActivityViewTx),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Everything recorded about one website action.
class DappActivityDetailPage extends StatelessWidget {
  const DappActivityDetailPage({super.key, required this.entry});

  static const routeName = 'dappActivityDetail';
  static const routePath = '/dapps/activity/detail';

  final DappActivity entry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final (title, icon, color) = DappActivityRow.headline(l10n, entry);
    final signature = entry.signature;

    Widget row(String label, String value, {Color? valueColor}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: TextStyle(fontWeight: FontWeight.w600, color: valueColor),
            ),
          ),
        ],
      ),
    );

    return AppScaffold(
      title: l10n.dappActivityDetail,
      child: ListView(
        children: [
          const _PrivacyNote(),
          const SizedBox(height: 12),
          DappCard(
            child: Row(
              children: [
                DappIcon(peer: _peerOf(entry), size: 48),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.siteName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        entry.host,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          DappCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (entry.pay != null)
                  row(
                    l10n.dappActionPay,
                    entry.pay!,
                    valueColor: DappTrust.danger.color,
                  ),
                if (entry.receive != null)
                  row(
                    l10n.dappActionReceive,
                    entry.receive!,
                    valueColor: DappTrust.safe.color,
                  ),
                row(l10n.dappActivityTime, _when(context, entry.at)),
                row(
                  l10n.dappActivityVia,
                  entry.viaPhone
                      ? l10n.dappActivityViaPhone
                      : entry.inBrowser
                      ? l10n.dappActivityInBrowser
                      : l10n.dappActivityViaWalletConnect,
                ),
                if (entry.wallet != null)
                  row(l10n.dappActivityWalletLabel, entry.wallet!),
                if (entry.programs.isNotEmpty)
                  row(l10n.dappRequestPrograms, entry.programs.join('\n')),
              ],
            ),
          ),
          if (signature != null) ...[
            const SizedBox(height: 12),
            DappCard(
              title: l10n.dappActivityTxId,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    signature,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () async {
                          await Clipboard.setData(
                            ClipboardData(text: signature),
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.dappActivityCopied)),
                            );
                          }
                        },
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        label: Text(l10n.commonCopy),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => unawaited(
                          launchUrl(
                            Uri.parse('https://solscan.io/tx/$signature'),
                            mode: LaunchMode.externalApplication,
                          ),
                        ),
                        icon: const Icon(Icons.open_in_new_rounded, size: 18),
                        label: Text(l10n.dappActivityViewTx),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
