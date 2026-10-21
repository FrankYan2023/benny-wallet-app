import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_scaffold.dart';
import '../../../../l10n/l10n.dart';
import '../../data/dapp_connect_service.dart';
import '../widgets/connected_sites_section.dart';
import 'dapp_activity_page.dart';
import 'dapp_scan_page.dart';

/// Lists the websites connected over WalletConnect and lets the user end
/// those connections. The scan page shows the same list under the camera.
class DappSitesPage extends ConsumerStatefulWidget {
  const DappSitesPage({super.key});

  static const routeName = 'dappSites';
  static const routePath = '/dapps';

  @override
  ConsumerState<DappSitesPage> createState() => _DappSitesPageState();
}

class _DappSitesPageState extends ConsumerState<DappSitesPage> {
  @override
  void initState() {
    super.initState();
    final service = ref.read(dappConnectServiceProvider);
    if (service.isAvailable) {
      unawaited(service.start().then((_) {}, onError: (Object _) {}));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final service = ref.watch(dappConnectServiceProvider);

    return AppScaffold(
      title: l10n.dappSitesTitle,
      actions: [
        IconButton(
          tooltip: l10n.dappActivityTitle,
          onPressed: () => context.push(DappActivityPage.routePath),
          icon: const Icon(Icons.history_rounded),
        ),
        if (service.isAvailable)
          IconButton(
            tooltip: l10n.dappScanTitle,
            onPressed: () => context.push(DappScanPage.routePath),
            icon: const Icon(Icons.qr_code_scanner_rounded),
          ),
      ],
      child: !service.isAvailable
          ? Center(child: Text(l10n.dappNotConfigured))
          : ListView(
              children: const [
                SizedBox(height: 8),
                ConnectedSitesSection(),
                SizedBox(height: 8),
              ],
            ),
    );
  }
}
