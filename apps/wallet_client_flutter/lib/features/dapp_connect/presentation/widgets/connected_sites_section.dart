import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reown_walletkit/reown_walletkit.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/walletconnect/dapp_review.dart';
import '../../../../l10n/l10n.dart';
import '../../../auth/presentation/providers/wallet_controller.dart';
import '../../../../core/config/app_features.dart';
import '../../data/browser_connections.dart';
import '../../data/dapp_activity_store.dart';
import '../../data/dapp_connect_service.dart';
import '../../data/mwa_connections.dart';
import '../../data/session_namespaces.dart';
import '../pages/dapp_activity_page.dart';
import '../pages/dapp_browser_page.dart';
import 'dapp_ui.dart';

/// One connection in the list: a website over WalletConnect or an app on
/// this phone over Mobile Wallet Adapter.
class _Connection {
  const _Connection({
    required this.key,
    required this.peer,
    required this.host,
    required this.address,
    required this.channel,
    required this.date,
    required this.end,
    this.openUrl,
  });

  final String key;
  final PairingMetadata peer;
  final String host;
  final String? address;
  final DappChannel channel;

  /// The page "Open" loads in Benny's browser.
  final String? openUrl;

  /// Expiry (WalletConnect) or last use (on this phone).
  final DateTime date;
  final Future<void> Function() end;
}

/// The connected websites and phone apps, each with a disconnect button,
/// plus "Disconnect all" and the link to the connection history. Used by
/// the scan page and the connected websites page.
class ConnectedSitesSection extends ConsumerStatefulWidget {
  const ConnectedSitesSection({
    super.key,
    this.showHeader = false,
    this.onOpen,
  });

  /// Opens a site; by default a new browser page. The browser passes its
  /// own, to load the site where it is.
  final ValueChanged<String>? onOpen;

  /// Shows a "Connected websites (n)" heading and the history link.
  final bool showHeader;

  @override
  ConsumerState<ConnectedSitesSection> createState() =>
      _ConnectedSitesSectionState();
}

class _ConnectedSitesSectionState extends ConsumerState<ConnectedSitesSection> {
  final Set<String> _disconnecting = {};

  @override
  void initState() {
    super.initState();
    unawaited(ref.read(mwaConnectionsProvider).refresh());
  }

  /// Records the disconnect in the activity log on this phone.
  Future<void> _record(_Connection c) async {
    try {
      await ref
          .read(dappActivityStoreProvider)
          .add(
            DappActivity(
              at: DateTime.now(),
              host: c.host,
              siteName: c.peer.name.trim().isEmpty ? c.host : c.peer.name,
              icon: c.peer.icons
                  .where((i) => i.startsWith('https://'))
                  .firstOrNull,
              event: DappActivityEvent.disconnected,
              wallet: c.address == null ? null : Formatters.address(c.address!),
              viaPhone: c.channel == DappChannel.phoneApp,
              inBrowser: c.channel == DappChannel.browser,
            ),
          );
    } on Object {
      // The log is a convenience.
    }
  }

  Future<void> _disconnect(_Connection c) async {
    setState(() => _disconnecting.add(c.key));
    try {
      await c.end();
      await _record(c);
    } on Object {
      // Ended on the other side already; the list refreshes either way.
    }
    if (mounted) {
      setState(() => _disconnecting.remove(c.key));
    }
  }

  Future<void> _disconnectAll(List<_Connection> all) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: Text(l10n.dappSitesDisconnectAllConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.dappSitesDisconnectAll),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    for (final c in all) {
      await _disconnect(c);
    }
  }

  List<_Connection> _connections(
    List<SessionData> sessions,
    List<MwaConnection> phoneApps,
    List<BrowserConnection> browserSites,
  ) {
    final service = ref.read(dappConnectServiceProvider);
    final mwa = ref.read(mwaConnectionsProvider);
    final browser = ref.read(browserConnectionsProvider);
    return [
      for (final site in browserSites)
        _Connection(
          key: 'browser:${site.host}',
          peer: PairingMetadata(
            name: site.name,
            description: '',
            url: 'https://${site.host}',
            icons: [?site.icon],
          ),
          host: site.host,
          address: site.address,
          channel: DappChannel.browser,
          date: site.lastUsed,
          end: () => browser.remove(site.host),
          openUrl: site.url,
        ),
      for (final session in sessions)
        _Connection(
          key: session.topic,
          peer: session.peer.metadata,
          host:
              DappReviewer.hostOf(session.peer.metadata.url) ??
              session.peer.metadata.url,
          address: sessionAddress(session),
          channel: DappChannel.walletConnect,
          date: DateTime.fromMillisecondsSinceEpoch(session.expiry * 1000),
          end: () => service.disconnect(session.topic),
        ),
      for (final app in phoneApps)
        _Connection(
          key: 'mwa:${app.uri}',
          peer: PairingMetadata(
            name: app.name.isEmpty ? app.host : app.name,
            description: '',
            url: app.uri,
            icons: [?app.icon],
          ),
          host: app.host,
          address: app.address,
          channel: DappChannel.phoneApp,
          date: app.lastUsed,
          end: () => mwa.revoke(app),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final service = ref.watch(dappConnectServiceProvider);
    final mwa = ref.watch(mwaConnectionsProvider);
    final browser = ref.watch(browserConnectionsProvider);
    final wallets = ref.watch(walletControllerProvider).wallets;
    final walletNames = {for (final w in wallets) w.publicKey: w.name};

    return ValueListenableBuilder<List<SessionData>>(
      valueListenable: service.sessions,
      builder: (context, sessions, _) =>
          ValueListenableBuilder<List<MwaConnection>>(
            valueListenable: mwa.connections,
            builder: (context, phoneApps, _) =>
                ValueListenableBuilder<List<BrowserConnection>>(
                  valueListenable: browser.connections,
                  builder: (context, browserSites, _) {
                    final theme = Theme.of(context);
                    final all = _connections(sessions, phoneApps, browserSites);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (widget.showHeader) ...[
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  all.isEmpty
                                      ? l10n.dappSitesTitle
                                      : '${l10n.dappSitesTitle} (${all.length})',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () =>
                                    context.push(DappActivityPage.routePath),
                                icon: const Icon(
                                  Icons.history_rounded,
                                  size: 18,
                                ),
                                label: Text(l10n.dappActivityTitle),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                        ],
                        if (all.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              l10n.dappSitesEmpty,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          )
                        else ...[
                          for (final c in all) ...[
                            _SiteTile(
                              connection: c,
                              walletName: walletNames[c.address],
                              busy: _disconnecting.contains(c.key),
                              onDisconnect: () => _disconnect(c),
                              onOpen: widget.onOpen,
                            ),
                            const SizedBox(height: 10),
                          ],
                          OutlinedButton(
                            onPressed: () => _disconnectAll(all),
                            child: Text(l10n.dappSitesDisconnectAll),
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

class _SiteTile extends StatelessWidget {
  const _SiteTile({
    required this.connection,
    required this.walletName,
    required this.busy,
    required this.onDisconnect,
    this.onOpen,
  });

  final _Connection connection;
  final String? walletName;
  final bool busy;
  final VoidCallback onDisconnect;
  final ValueChanged<String>? onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final c = connection;
    final name = c.peer.name.trim().isNotEmpty ? c.peer.name.trim() : c.host;
    final address = c.address;
    final wallet =
        walletName ?? (address == null ? null : Formatters.address(address));

    // The card opens what this website did, from the history on this phone.
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => context.push(DappSiteActivityPage.routePath, extra: c.host),
      child: DappCard(
        child: Row(
          children: [
            DappIcon(peer: c.peer, size: 44),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    switch (c.channel) {
                      DappChannel.phoneApp =>
                        '${c.host}  ·  ${l10n.dappActivityViaPhone}',
                      DappChannel.browser =>
                        '${c.host}  ·  ${l10n.dappActivityInBrowser}',
                      DappChannel.walletConnect => c.host,
                    },
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (wallet != null)
                    Text(
                      l10n.dappSitesWallet(wallet),
                      style: theme.textTheme.bodySmall,
                    ),
                  Text(
                    c.channel == DappChannel.walletConnect
                        ? l10n.dappSitesExpires(Formatters.date(c.date))
                        : l10n.dappSitesLastUsed(Formatters.date(c.date)),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (AppFeatures.canOpenDappBrowser)
              IconButton(
                tooltip: l10n.browserOpen,
                onPressed: () {
                  final url = c.openUrl ?? 'https://${c.host}';
                  final open = onOpen;
                  if (open != null) {
                    open(url);
                  } else {
                    context.push(DappBrowserPage.routePath, extra: url);
                  }
                },
                icon: const Icon(Icons.open_in_browser_rounded),
              ),
            busy
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : TextButton(
                    onPressed: onDisconnect,
                    child: Text(l10n.dappSitesDisconnect),
                  ),
          ],
        ),
      ),
    );
  }
}
