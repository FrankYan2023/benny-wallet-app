import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reown_walletkit/reown_walletkit.dart' show PairingMetadata;

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/l10n.dart';
import '../../data/browser_bookmarks.dart';
import '../../data/browser_connections.dart';
import '../../data/browser_wallet_bridge.dart';
import '../../data/dapp_connect_service.dart';
import '../browser_tabs.dart';
import '../widgets/connected_sites_section.dart';
import '../widgets/dapp_ui.dart';
import 'dapp_scan_page.dart';

/// Benny's own browser: pages see Benny as a Solana wallet (Wallet
/// Standard and window.benny / window.solana) and connect and sign without
/// leaving the app. Requests are reviewed on the usual pages.
///
/// The page gets the whole screen: one slim bar on top that takes the
/// site's own colour, no bottom bar (back is the system back gesture; the
/// rest is in the menu). Pages open in tabs (the count in the bar lists
/// them); a new tab shows Benny's home.
class DappBrowserPage extends ConsumerStatefulWidget {
  const DappBrowserPage({super.key, this.initialUrl});

  static const routeName = 'dappBrowser';
  static const routePath = '/browser';

  final String? initialUrl;

  /// A typed address as a URL: https:// is added when missing; null when
  /// it is not a web address.
  static Uri? parseAddress(String text) {
    var value = text.trim();
    if (value.isEmpty) {
      return null;
    }
    if (!value.contains('://')) {
      value = 'https://$value';
    }
    final uri = Uri.tryParse(value);
    if (uri == null ||
        (uri.scheme != 'https' && uri.scheme != 'http') ||
        !uri.host.contains('.') && uri.host != 'localhost') {
      return null;
    }
    return uri;
  }

  static Future<UserScript>? _script;

  /// The wallet provider every page gets, read and encoded once per run;
  /// pages that link here call it ahead so the browser opens at once.
  static Future<UserScript> preloadScript() {
    return _script ??= _DappBrowserPageState._loadScript();
  }

  @override
  ConsumerState<DappBrowserPage> createState() => _DappBrowserPageState();
}

/// What a tab needs while its page is loaded: its web view, and a wallet
/// bridge that answers for that page only, so a tab in the background can
/// never borrow the address of the one on screen.
class _TabSession {
  // A page shows a sliver of progress at once, before the web view is up.
  _TabSession(this.tab) : progress = tab.url == null ? 1 : 0.05;

  final BrowserTab tab;
  late final BrowserWalletBridge bridge;
  InAppWebViewController? controller;
  double progress;
  bool canGoBack = false;
  bool canGoForward = false;

  /// The site's colour (theme-color, else its background); the bar and the
  /// screen edges take it so the page looks full screen.
  Color barColor = _DappBrowserPageState._homeColor;
}

class _DappBrowserPageState extends ConsumerState<DappBrowserPage> {
  static const _homeColor = Color(0xFF0E1116);

  final _address = TextEditingController();
  final _addressFocus = FocusNode();
  late final BrowserTabs _tabs;
  final Map<int, _TabSession> _sessions = {};
  Future<UserScript>? _script;
  bool _editing = false;

  BrowserTab get _tab => _tabs.ensureActive();

  _TabSession get _session => _sessionFor(_tab);

  Uri? get _url => _tab.url;

  _TabSession _sessionFor(BrowserTab tab) {
    return _sessions.putIfAbsent(tab.id, () {
      final session = _TabSession(tab);
      session.bridge = BrowserWalletBridge(
        ref.read,
        currentPage: () => _currentPage(session),
      );
      return session;
    });
  }

  @override
  void initState() {
    super.initState();
    _tabs = ref.read(browserTabsProvider);
    _script = DappBrowserPage.preloadScript();
    final initial = widget.initialUrl == null
        ? null
        : DappBrowserPage.parseAddress(widget.initialUrl!);
    // A link from elsewhere in the app gets a tab of its own; opening the
    // browser itself returns to the tab left on screen.
    if (initial != null) {
      _tabs.open(initial);
    } else {
      _tabs.ensureActive();
    }
    _tabs.addListener(_onTabsChanged);
    _addressFocus.addListener(() {
      if (!_addressFocus.hasFocus && _editing) {
        setState(() => _editing = false);
      }
    });
  }

  @override
  void dispose() {
    _tabs.removeListener(_onTabsChanged);
    _address.dispose();
    _addressFocus.dispose();
    super.dispose();
  }

  void _onTabsChanged() {
    final open = {for (final tab in _tabs.tabs) tab.id};
    _sessions.removeWhere((id, _) => !open.contains(id));
    if (mounted) {
      setState(() {});
    }
  }

  static Future<UserScript> _loadScript() async {
    final source = await rootBundle.loadString(
      'assets/browser/benny_provider.js',
    );
    final icon = await rootBundle.load('assets/brand/benny_wallet_icon_96.png');
    final dataUri =
        'data:image/png;base64,${base64Encode(icon.buffer.asUint8List())}';
    return UserScript(
      source: source.replaceAll('__BENNY_ICON__', dataUri),
      injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
      forMainFrameOnly: true,
    );
  }

  Future<BrowserPage?> _currentPage(_TabSession session) async {
    final controller = session.controller;
    if (controller == null) {
      return null;
    }
    // A page still starting up may not answer yet: fall back to the
    // tab's address.
    WebUri? url;
    try {
      url = await controller.getUrl();
    } on Object {
      url = null;
    }
    final address = url?.toString() ?? session.tab.url?.toString();
    if (address == null) {
      return null;
    }
    String? icon;
    try {
      final favicons = await controller.getFavicons();
      icon = favicons
          .map((f) => f.url.toString())
          .where((u) => u.startsWith('https://'))
          .firstOrNull;
    } on Object {
      icon = null;
    }
    String? title;
    try {
      title = await controller.getTitle();
    } on Object {
      title = null;
    }
    return (url: Uri.parse(address), title: title, icon: icon);
  }

  void _open(String text) {
    final uri = DappBrowserPage.parseAddress(text);
    if (uri == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.browserInvalidUrl)));
      return;
    }
    _addressFocus.unfocus();
    _editing = false;
    final session = _session;
    if (session.controller == null) {
      session.progress = 0.05;
    }
    _tabs.update(session.tab.id, url: uri);
    final controller = session.controller;
    if (controller != null) {
      unawaited(
        controller.loadUrl(urlRequest: URLRequest(url: WebUri.uri(uri))),
      );
    }
  }

  void _startEditing() {
    _address.text = _url?.toString() ?? '';
    setState(() => _editing = true);
    _addressFocus.requestFocus();
    _address.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _address.text.length,
    );
  }

  void _goHome() {
    final session = _session;
    session
      ..controller = null
      ..canGoBack = false
      ..canGoForward = false
      ..progress = 1
      ..barColor = _homeColor;
    _editing = false;
    _tabs.update(session.tab.id, clearUrl: true);
  }

  /// Shows another tab. The one left behind is paused (Android stops its
  /// scripts and timers) and keeps its page and history.
  void _activate(int id) {
    if (id == _tab.id) {
      return;
    }
    unawaited(_pause(_session.controller));
    _addressFocus.unfocus();
    _editing = false;
    _tabs.activate(id);
    unawaited(_resume(_sessions[id]?.controller));
  }

  void _newTab() {
    unawaited(_pause(_session.controller));
    _editing = false;
    _tabs.open(null);
  }

  static Future<void> _pause(InAppWebViewController? controller) async {
    try {
      await controller?.pause();
    } on Object {
      // Not every platform pauses a web view.
    }
  }

  static Future<void> _resume(InAppWebViewController? controller) async {
    try {
      await controller?.resume();
    } on Object {
      // Not every platform pauses a web view.
    }
  }

  Future<void> _afterLoad(_TabSession session) async {
    final controller = session.controller;
    if (controller == null || !mounted) {
      return;
    }
    final back = await controller.canGoBack();
    final forward = await controller.canGoForward();
    Color? color;
    try {
      final value = await controller.evaluateJavascript(
        source: '''(function(){
          var m = document.querySelector('meta[name="theme-color"]');
          if (m && m.content) return m.content;
          var b = getComputedStyle(document.body || document.documentElement).backgroundColor;
          if (!b || b === 'rgba(0, 0, 0, 0)' || b === 'transparent') {
            b = getComputedStyle(document.documentElement).backgroundColor;
          }
          return b;
        })()''',
      );
      color = _parseCssColor(value?.toString());
    } on Object {
      color = null;
    }
    String? title;
    try {
      title = await controller.getTitle();
    } on Object {
      title = null;
    }
    if (!mounted || session.controller != controller) {
      return;
    }
    session
      ..canGoBack = back
      ..canGoForward = forward;
    if (color != null) {
      session.barColor = color;
    }
    final trimmed = title?.trim();
    _tabs.update(
      session.tab.id,
      title: trimmed == null || trimmed.isEmpty ? null : trimmed,
    );
    setState(() {});
  }

  /// "#rgb", "#rrggbb" or "rgb(a)(r, g, b[, a])"; null for anything else
  /// or a transparent colour.
  static Color? _parseCssColor(String? css) {
    if (css == null) {
      return null;
    }
    final value = css.trim().toLowerCase();
    if (value.startsWith('#')) {
      var hex = value.substring(1);
      if (hex.length == 3) {
        hex = hex.split('').map((c) => '$c$c').join();
      }
      if (hex.length != 6) {
        return null;
      }
      final rgb = int.tryParse(hex, radix: 16);
      return rgb == null ? null : Color(0xFF000000 | rgb);
    }
    final match = RegExp(
      r'rgba?\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*(?:,\s*([\d.]+)\s*)?\)',
    ).firstMatch(value);
    if (match == null) {
      return null;
    }
    final alpha = double.tryParse(match.group(4) ?? '1') ?? 1;
    if (alpha < 0.5) {
      return null;
    }
    return Color.fromARGB(
      255,
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    );
  }

  /// Saves or removes the page on screen (on this phone only).
  Future<void> _toggleBookmark() async {
    final url = _url?.toString();
    if (url == null) {
      return;
    }
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final bookmarks = ref.read(browserBookmarksProvider);
    if (bookmarks.contains(url)) {
      await bookmarks.remove(url);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.browserBookmarkRemoved)),
      );
      return;
    }
    final page = await _currentPage(_session);
    final title = (page?.title ?? '').trim();
    await bookmarks.add(
      BrowserBookmark(
        url: url,
        title: title.isEmpty ? (_url?.host ?? url) : title,
        icon: page?.icon,
        addedAt: DateTime.now(),
      ),
    );
    messenger.showSnackBar(SnackBar(content: Text(l10n.browserBookmarked)));
  }

  /// Every bookmark in a sheet 80% of the screen tall; a tap opens it.
  Future<void> _showBookmarks() async {
    final l10n = context.l10n;
    final bookmarks = ref.read(browserBookmarksProvider);
    final url = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.8,
      ),
      builder: (sheetContext) => SizedBox(
        height: MediaQuery.sizeOf(sheetContext).height * 0.8,
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 8, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.browserBookmarks,
                        style: Theme.of(sheetContext).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    IconButton(
                      tooltip: MaterialLocalizations.of(
                        sheetContext,
                      ).closeButtonTooltip,
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ValueListenableBuilder<List<BrowserBookmark>>(
                  valueListenable: bookmarks.bookmarks,
                  builder: (context, saved, _) => saved.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              l10n.browserBookmarksEmpty,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        )
                      : ListView(
                          children: [
                            for (final b in saved)
                              ListTile(
                                onTap: () =>
                                    Navigator.of(sheetContext).pop(b.url),
                                leading: DappIcon(
                                  peer: PairingMetadata(
                                    name: b.title,
                                    description: '',
                                    url: 'https://${b.host}',
                                    icons: [?b.icon],
                                  ),
                                  size: 36,
                                ),
                                title: Text(
                                  b.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                subtitle: Text(b.host),
                                trailing: IconButton(
                                  tooltip: l10n.browserBookmarkRemove,
                                  onPressed: () => bookmarks.remove(b.url),
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                  ),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                              child: Text(
                                l10n.browserBookmarksLocal,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (url != null && mounted) {
      _open(url);
    }
  }

  /// The open tabs: tap one to show it, close it with its button, or start
  /// a new tab on Benny's home.
  Future<void> _showTabs() async {
    const newTab = -1;
    final picked = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.8,
      ),
      builder: (sheetContext) => ListenableBuilder(
        listenable: _tabs,
        builder: (sheetContext, _) {
          final l10n = sheetContext.l10n;
          final tabs = _tabs.tabs;
          final activeId = _tabs.active?.id;
          return SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 12, 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.browserTabsCount(tabs.length),
                          style: Theme.of(sheetContext).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => Navigator.of(sheetContext).pop(newTab),
                        icon: const Icon(Icons.add_rounded),
                        label: Text(l10n.browserNewTab),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    children: [
                      for (final tab in tabs.reversed)
                        ListTile(
                          selected: tab.id == activeId,
                          selectedTileColor: AppColors.surfaceMuted,
                          onTap: () => Navigator.of(sheetContext).pop(tab.id),
                          leading: tab.url == null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.asset(
                                    'assets/brand/benny_logo.png',
                                    width: 36,
                                    height: 36,
                                  ),
                                )
                              : DappIcon(
                                  peer: PairingMetadata(
                                    name: tab.title ?? tab.url!.host,
                                    description: '',
                                    url: 'https://${tab.url!.host}',
                                    icons: [?tab.icon],
                                  ),
                                  size: 36,
                                ),
                          title: Text(
                            tab.url == null
                                ? l10n.appTitle
                                : tab.title ?? tab.url!.host,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            tab.url == null ? l10n.browserHome : tab.url!.host,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            tooltip: l10n.browserCloseTab,
                            onPressed: () => _tabs.close(tab.id),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
    if (!mounted || picked == null) {
      return;
    }
    if (picked == newTab) {
      _newTab();
    } else {
      _activate(picked);
    }
  }

  Future<void> _showMenu(BrowserConnection? connection) async {
    final l10n = context.l10n;
    final connections = ref.read(browserConnectionsProvider);
    final session = _session;
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.92,
        builder: (sheetContext, scrollController) => SafeArea(
          child: ListView(
            controller: scrollController,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    tooltip: l10n.browserBack,
                    onPressed: session.canGoBack
                        ? () => Navigator.of(sheetContext).pop('back')
                        : null,
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  IconButton(
                    tooltip: l10n.browserForward,
                    onPressed: session.canGoForward
                        ? () => Navigator.of(sheetContext).pop('forward')
                        : null,
                    icon: const Icon(Icons.arrow_forward_rounded),
                  ),
                  IconButton(
                    tooltip: l10n.browserReload,
                    onPressed: () => Navigator.of(sheetContext).pop('reload'),
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                  IconButton(
                    tooltip: l10n.browserCopyLink,
                    onPressed: () => Navigator.of(sheetContext).pop('copy'),
                    icon: const Icon(Icons.copy_rounded),
                  ),
                ],
              ),
              const Divider(height: 1),
              // Every connected site (scanned, phone apps, this browser),
              // with the connection history; Open loads a site here.
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: ConnectedSitesSection(
                  showHeader: true,
                  onOpen: (url) => Navigator.of(sheetContext).pop('open:$url'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted || action == null) {
      return;
    }
    if (action.startsWith('open:')) {
      _open(action.substring('open:'.length));
      return;
    }
    switch (action) {
      case 'disconnect':
        final host = session.tab.url?.host;
        if (host != null) {
          await connections.remove(host);
          await session.controller?.reload();
        }
      case 'back':
        await session.controller?.goBack();
      case 'forward':
        await session.controller?.goForward();
      case 'reload':
        await session.controller?.reload();
      case 'bookmark':
        await _toggleBookmark();
      case 'copy':
        await Clipboard.setData(
          ClipboardData(text: session.tab.url?.toString() ?? ''),
        );
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.dappActivityCopied)));
        }
      case 'home':
        _goHome();
    }
  }

  /// A tab's page: Benny's home, or the site in a web view of its own.
  Widget _tabBody(_TabSession session) {
    final tab = session.tab;
    final url = tab.url;
    if (url == null) {
      return _BennyHome(onOpen: _open);
    }
    return FutureBuilder<UserScript>(
      future: _script,
      builder: (context, snapshot) {
        final script = snapshot.data;
        if (script == null) {
          return const SizedBox.shrink();
        }
        bool onScreen() => _tabs.active?.id == tab.id;
        return InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri.uri(url)),
          initialUserScripts: UnmodifiableListView([script]),
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            useShouldOverrideUrlLoading: true,
            supportMultipleWindows: false,
            mediaPlaybackRequiresUserGesture: true,
            allowsInlineMediaPlayback: true,
            isFraudulentWebsiteWarningEnabled: true,
            safeBrowsingEnabled: true,
            overScrollMode: OverScrollMode.NEVER,
            transparentBackground: true,
          ),
          onWebViewCreated: (controller) {
            session.controller = controller;
            controller.addJavaScriptHandler(
              handlerName: 'bennyWallet',
              callback: (args) =>
                  session.bridge.handle(args.isEmpty ? null : args.first),
            );
          },
          shouldOverrideUrlLoading: (controller, action) async {
            final scheme = action.request.url?.scheme;
            // Only web pages: wallet links (wc:, solana-wallet:) and app
            // intents are not followed from inside the wallet.
            return scheme == 'https' ||
                    scheme == 'http' ||
                    scheme == 'about' ||
                    scheme == 'data' ||
                    scheme == 'blob'
                ? NavigationActionPolicy.ALLOW
                : NavigationActionPolicy.CANCEL;
          },
          onLoadStop: (controller, url) {
            if (url != null) {
              _tabs.update(tab.id, url: Uri.parse(url.toString()));
            }
            unawaited(_afterLoad(session));
          },
          onUpdateVisitedHistory: (controller, url, _) {
            if (url != null) {
              _tabs.update(tab.id, url: Uri.parse(url.toString()));
            }
            unawaited(_afterLoad(session));
          },
          onProgressChanged: (controller, progress) {
            session.progress = progress / 100;
            if (onScreen() && mounted) {
              setState(() {});
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final connections = ref.watch(browserConnectionsProvider);
    final tab = _tab;
    final session = _sessionFor(tab);
    final url = tab.url;
    final barColor = url == null ? _homeColor : session.barColor;
    final dark = barColor.computeLuminance() < 0.4;
    final onBar = dark ? Colors.white : const Color(0xFF111418);
    final overlay =
        (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
            .copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: barColor,
              systemNavigationBarIconBrightness: dark
                  ? Brightness.light
                  : Brightness.dark,
            );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: PopScope(
        canPop: !session.canGoBack && !_editing,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) {
            return;
          }
          if (_editing) {
            _addressFocus.unfocus();
            return;
          }
          unawaited(session.controller?.goBack());
        },
        child: Scaffold(
          backgroundColor: barColor,
          body: Column(
            children: [
              // Slim bar in the site's colour, under the status bar.
              Material(
                color: barColor,
                child: SafeArea(
                  bottom: false,
                  child: SizedBox(
                    height: 48,
                    child: Row(
                      children: [
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          tooltip: MaterialLocalizations.of(
                            context,
                          ).closeButtonTooltip,
                          onPressed: () => context.pop(),
                          icon: Icon(Icons.close_rounded, color: onBar),
                        ),
                        Expanded(
                          child: _AddressPill(
                            url: url,
                            editing: _editing,
                            controller: _address,
                            focusNode: _addressFocus,
                            onBar: onBar,
                            hint: l10n.browserAddressHint,
                            onTap: _startEditing,
                            onSubmitted: _open,
                            bookmarks: ref.watch(browserBookmarksProvider),
                            onBookmark: () => unawaited(_toggleBookmark()),
                            onHome: _goHome,
                            bookmarkTooltip: l10n.browserBookmark,
                            homeTooltip: l10n.browserHome,
                          ),
                        ),
                        // Scan a WalletConnect QR code (and see every
                        // connected site) from the browser.
                        if (ref.read(dappConnectServiceProvider).isAvailable)
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            tooltip: l10n.dappScanTitle,
                            onPressed: () =>
                                context.push(DappScanPage.routePath),
                            icon: Icon(
                              Icons.qr_code_scanner_rounded,
                              color: onBar,
                            ),
                          ),
                        // All bookmarks, in a sheet like the menu's.
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          tooltip: l10n.browserBookmarks,
                          onPressed: _showBookmarks,
                          icon: Icon(Icons.bookmarks_outlined, color: onBar),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          tooltip: l10n.browserTabsCount(_tabs.tabs.length),
                          onPressed: _showTabs,
                          icon: _TabCount(
                            count: _tabs.tabs.length,
                            color: onBar,
                          ),
                        ),
                        ValueListenableBuilder<List<BrowserConnection>>(
                          valueListenable: connections.connections,
                          builder: (context, list, _) {
                            final connection = url == null
                                ? null
                                : list
                                      .where((c) => c.host == url.host)
                                      .firstOrNull;
                            return IconButton(
                              visualDensity: VisualDensity.compact,
                              onPressed: () => _showMenu(connection),
                              icon: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Icon(Icons.more_horiz_rounded, color: onBar),
                                  if (connection != null)
                                    Positioned(
                                      right: -1,
                                      top: -1,
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: AppColors.success,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: barColor,
                                            width: 1.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 2,
                child: url != null && session.progress < 1
                    ? LinearProgressIndicator(
                        value: session.progress,
                        minHeight: 2,
                        backgroundColor: Colors.transparent,
                      )
                    : null,
              ),
              Expanded(
                child: SafeArea(
                  top: false,
                  // Every tab opened so far stays built, out of sight when
                  // it is not the one on screen.
                  child: Stack(
                    children: [
                      for (final other in _tabs.tabs)
                        if (_sessions.containsKey(other.id))
                          Offstage(
                            key: ValueKey(other.id),
                            offstage: other.id != tab.id,
                            child: TickerMode(
                              enabled: other.id == tab.id,
                              child: _tabBody(_sessions[other.id]!),
                            ),
                          ),
                    ],
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

/// The tab count in a rounded square, as browsers show it.
class _TabCount extends StatelessWidget {
  const _TabCount({required this.count, required this.color});

  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1.6),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}

/// The address in the bar: the host in bold, tap to type a new one.
class _AddressPill extends StatelessWidget {
  const _AddressPill({
    required this.url,
    required this.editing,
    required this.controller,
    required this.focusNode,
    required this.onBar,
    required this.hint,
    required this.onTap,
    required this.onSubmitted,
    required this.bookmarks,
    required this.onBookmark,
    required this.onHome,
    required this.bookmarkTooltip,
    required this.homeTooltip,
  });

  final BrowserBookmarks bookmarks;
  final VoidCallback onBookmark;
  final VoidCallback onHome;
  final String bookmarkTooltip;
  final String homeTooltip;
  final Uri? url;
  final bool editing;
  final TextEditingController controller;
  final FocusNode focusNode;
  final Color onBar;
  final String hint;
  final VoidCallback onTap;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontSize: 15, fontWeight: FontWeight.w700);
    final fill = onBar.withValues(alpha: 0.1);
    if (editing || url == null) {
      return SizedBox(
        height: 36,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.go,
          autocorrect: false,
          onSubmitted: onSubmitted,
          onTap: url == null ? null : onTap,
          style: style.copyWith(color: onBar),
          cursorColor: onBar,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: fill,
            hintText: hint,
            hintStyle: TextStyle(
              color: onBar.withValues(alpha: 0.55),
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              size: 18,
              color: onBar.withValues(alpha: 0.7),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 34),
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      );
    }
    final secure = url!.scheme == 'https';
    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: SizedBox(
          height: 36,
          child: Row(
            children: [
              const SizedBox(width: 12),
              Icon(
                secure ? Icons.lock_rounded : Icons.public_rounded,
                size: 14,
                color: onBar.withValues(alpha: 0.75),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  url!.host,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: style.copyWith(color: onBar),
                ),
              ),
              // Bookmark this page, then Benny's home, at the right end.
              ValueListenableBuilder<List<BrowserBookmark>>(
                valueListenable: bookmarks.bookmarks,
                builder: (context, _, _) {
                  final saved = bookmarks.contains(url.toString());
                  return IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    tooltip: bookmarkTooltip,
                    onPressed: onBookmark,
                    icon: Icon(
                      saved ? Icons.star_rounded : Icons.star_border_rounded,
                      size: 20,
                      color: saved
                          ? const Color(0xFFF6C54B)
                          : onBar.withValues(alpha: 0.8),
                    ),
                  );
                },
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                tooltip: homeTooltip,
                onPressed: onHome,
                icon: Icon(
                  Icons.home_outlined,
                  size: 20,
                  color: onBar.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }
}

/// A dApp on Benny's home page.
typedef _HomeApp = ({String name, String host, String url});

/// Benny Wallet's start page: the first bookmarks, Benny Apps (reserved
/// for now), the sites connected in this browser and recommended apps.
class _BennyHome extends ConsumerWidget {
  const _BennyHome({required this.onOpen});

  final ValueChanged<String> onOpen;

  static const _homeBookmarks = 8;

  static const List<_HomeApp> _recommended = [
    (name: 'Jupiter', host: 'jup.ag', url: 'https://jup.ag'),
    (name: 'Raydium', host: 'raydium.io', url: 'https://raydium.io/swap'),
    (name: 'Orca', host: 'orca.so', url: 'https://www.orca.so'),
    (name: 'Kamino', host: 'kamino.finance', url: 'https://app.kamino.finance'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final connections = ref.watch(browserConnectionsProvider);
    final bookmarks = ref.watch(browserBookmarksProvider);
    const onHome = Colors.white;
    final muted = onHome.withValues(alpha: 0.6);

    Widget section(String title) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: onHome,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    Widget grid(List<Widget> tiles) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.count(
        crossAxisCount: 4,
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 0.82,
        children: tiles,
      ),
    );

    Future<void> confirmRemove(BrowserBookmark b) async {
      final remove = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(b.title),
          content: Text(b.host),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.browserBookmarkRemove),
            ),
          ],
        ),
      );
      if (remove == true) {
        await bookmarks.remove(b.url);
      }
    }

    return ValueListenableBuilder<List<BrowserBookmark>>(
      valueListenable: bookmarks.bookmarks,
      builder: (context, saved, _) =>
          ValueListenableBuilder<List<BrowserConnection>>(
            valueListenable: connections.connections,
            builder: (context, sites, _) => ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                const SizedBox(height: 18),
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.asset(
                      'assets/brand/benny_logo.png',
                      width: 64,
                      height: 64,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    'Benny Wallet',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: onHome,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    l10n.browserHomeTagline,
                    style: TextStyle(color: muted),
                  ),
                ),

                // The first bookmarks (all of them drop down from the bar).
                section(l10n.browserBookmarks),
                if (saved.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      l10n.browserBookmarksEmpty,
                      style: TextStyle(color: muted, fontSize: 13),
                    ),
                  )
                else ...[
                  grid([
                    for (final b in saved.take(_homeBookmarks))
                      _AppTile(
                        name: b.shortTitle,
                        host: b.host,
                        icon: b.icon,
                        onTap: () => onOpen(b.url),
                        onLongPress: () => confirmRemove(b),
                      ),
                  ]),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 13,
                          color: muted,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            l10n.browserBookmarksLocal,
                            style: TextStyle(color: muted, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Reserved for Benny's own features (its own dApp pages).
                section(l10n.browserBennyFeatures),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2A2F3A), Color(0xFF1A1E26)],
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome_rounded,
                          color: Color(0xFFF6C54B),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.browserComingSoon,
                            style: const TextStyle(
                              color: onHome,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (sites.isNotEmpty) ...[
                  section(l10n.browserYourSites),
                  for (final c in sites)
                    ListTile(
                      onTap: () => onOpen(c.url),
                      leading: DappIcon(
                        peer: PairingMetadata(
                          name: c.name,
                          description: '',
                          url: 'https://${c.host}',
                          icons: [?c.icon],
                        ),
                        size: 40,
                      ),
                      title: Text(
                        c.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: onHome,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        '${c.host}  ·  ${Formatters.address(c.address)}',
                        style: TextStyle(color: muted),
                      ),
                      trailing: Icon(Icons.chevron_right_rounded, color: muted),
                    ),
                ],

                // Recommended apps last.
                section(l10n.browserPopular),
                grid([
                  for (final app in _recommended)
                    _AppTile(
                      name: app.name,
                      host: app.host,
                      icon: 'https://${app.host}/favicon.ico',
                      onTap: () => onOpen(app.url),
                    ),
                ]),
              ],
            ),
          ),
    );
  }
}

/// An app or bookmark on the home page: icon and name; long press when
/// [onLongPress] is set.
class _AppTile extends StatelessWidget {
  const _AppTile({
    required this.name,
    required this.host,
    required this.icon,
    required this.onTap,
    this.onLongPress,
  });

  final String name;
  final String host;
  final String? icon;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DappIcon(
            peer: PairingMetadata(
              name: name,
              description: '',
              url: 'https://$host',
              icons: [?icon],
            ),
            size: 48,
          ),
          const SizedBox(height: 8),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
