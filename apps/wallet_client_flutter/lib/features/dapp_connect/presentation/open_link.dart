import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/app_features.dart';
import '../../auth/presentation/providers/wallet_controller.dart';
import 'pages/dapp_browser_page.dart';

/// Opens a link from one of the app's pages in a new tab of Benny's
/// browser. Builds without the browser (Lite) and child mode, which keeps
/// children out of it, use the phone's browser instead. False when the
/// link is not a web address or nothing could open it.
Future<bool> openLinkInApp(BuildContext context, String url) async {
  final uri = DappBrowserPage.parseAddress(url);
  if (uri == null) {
    return false;
  }
  final childMode = ProviderScope.containerOf(
    context,
    listen: false,
  ).read(walletControllerProvider).childModeEnabled;
  if (AppFeatures.canOpenDappBrowser && !childMode) {
    unawaited(DappBrowserPage.preloadScript());
    unawaited(context.push(DappBrowserPage.routePath, extra: uri.toString()));
    return true;
  }
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}
