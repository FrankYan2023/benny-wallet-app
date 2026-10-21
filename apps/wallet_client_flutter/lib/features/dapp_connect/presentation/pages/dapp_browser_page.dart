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
import '../widgets/connected_sites_section.dart';
import '../widgets/dapp_ui.dart';
import 'dapp_scan_page.dart';

/// Benny's own browser: pages see Benny as a Solana wallet (Wallet
/// Standard and window.benny / window.solana) and connect and sign without
/// leaving the app. Requests are reviewed on the usual pages.
///
/// The page gets the whole screen: one slim bar on top that takes the
/// site's own colour, no bottom bar (back is the system back gesture; the
/// rest is in the menu). With no address it shows Benny's home.
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

  @override
  ConsumerState<DappBrowserPage> createState() => _DappBrowserPageState();
}

class _DappBrowserPageState extends ConsumerState<DappBrowserPage> {
  static const _homeColor = Color(0xFF0E1116);

  final _address = TextEditingController();
  final _addressFocus = FocusNode();
  InAppWebViewController? _controller;
  late final BrowserWalletBridge _bridge;
  Future<UserScript>? _script;
  Uri? _url;
  double _progress = 1;
  bool _canGoBack = false;
  bool _canGoForward = false;
  bool _editing = false;

  /// The site's colour (theme-color, else its background); the bar and the
  /// screen edges take it so the page looks full screen.
  Color _barColor = _homeColor;

  @override
  void initState() {
    super.initState();
    _bridge = BrowserWalletBridge(ref.read, currentPage: _currentPage);
    _script = _loadScript();
    _url = widget.initialUrl == null
        ? null
        : DappBrowserPage.parseAddress(widget.initialUrl!);
    _addressFocus.addListener(() {
      if (!_addressFocus.hasFocus && _editing) {
        setState(() => _editing = false);
      }
    });
  }

  @override
  void dispose() {
    _address.dispose();
    _addressFocus.dispose();
    super.dispose();
  }

  Future<UserScript> _loadScript() async {
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

  Future<BrowserPage?> _currentPage() async {
    final controller = _controller;
    if (controller == null) {
      return null;
    }
    // A page still starting up may not answer yet: fall back to the
    // address in the bar.
    WebUri? url;
    try {
      url = await controller.getUrl();
    } on Object {
      url = null;
    }
    final address = url?.toString() ?? _url?.toString();
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
    setState(() {
      _editing = false;
      _url = uri;
    });
    final controller = _controller;
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
    setState(() {
      _url = null;
      _controller = null;
      _canGoBack = false;
      _canGoForward = false;
      _barColor = _homeColor;
      _editing = false;
    });
  }

  Future<void> _afterLoad() async {
    final controller = _controller;
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
    if (mounted) {
      setState(() {
        _canGoBack = back;
        _canGoForward = forward;
        if (color != null) {
          _barColor = color;
        }
      });
    }
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
    final page = await _currentPage();
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
                            ?.copyWith(fontWeight: FontWeight.w800),
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

  Future<void> _showMenu(BrowserConnection? connection) async {
    final l10n = context.l10n;
    final connections = ref.read(browserConnectionsProvider);
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
                    onPressed: _canGoBack
                        ? () => Navigator.of(sheetContext).pop('back')
                        : null,
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  IconButton(
                    tooltip: l10n.browserForward,
                    onPressed: _canGoForward
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
        final host = _url?.host;
        if (host != null) {
          await connections.remove(host);
          await _controller?.reload();
        }
      case 'back':
        await _controller?.goBack();
      case 'forward':
        await _controller?.goForward();
      case 'reload':
        await _controller?.reload();
      case 'bookmark':
        await _toggleBookmark();
      case 'copy':
        await Clipboard.setData(ClipboardData(text: _url?.toString() ?? ''));
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.dappActivityCopied)));
        }
      case 'home':
        _goHome();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final connections = ref.watch(browserConnectionsProvider);
    final dark = _barColor.computeLuminance() < 0.4;
    final onBar = dark ? Colors.white : const Color(0xFF111418);
    final overlay =
        (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
            .copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: _barColor,
              systemNavigationBarIconBrightness: dark
                  ? Brightness.light
                  : Brightness.dark,
            );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: PopScope(
        canPop: !_canGoBack && !_editing,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) {
            return;
          }
          if (_editing) {
            _addressFocus.unfocus();
            return;
          }
          unawaited(_controller?.goBack());
        },
        child: Scaffold(
          backgroundColor: _barColor,
          body: Column(
            children: [
              // Slim bar in the site's colour, under the status bar.
              Material(
                color: _barColor,
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
                            url: _url,
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
                        ValueListenableBuilder<List<BrowserConnection>>(
                          valueListenable: connections.connections,
                          builder: (context, list, _) {
                            final connection = _url == null
                                ? null
                                : list
                                      .where((c) => c.host == _url!.host)
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
                                            color: _barColor,
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
                child: _progress < 1
                    ? LinearProgressIndicator(
                        value: _progress,
                        minHeight: 2,
                        backgroundColor: Colors.transparent,
                      )
                    : null,
              ),
              Expanded(
                child: SafeArea(
                  top: false,
                  child: _url == null
                      ? _BennyHome(onOpen: _open)
                      : FutureBuilder<UserScript>(
                          future: _script,
                          builder: (context, snapshot) {
                            final script = snapshot.data;
                            if (script == null) {
                              return const SizedBox.shrink();
                            }
                            return InAppWebView(
                              initialUrlRequest: URLRequest(
                                url: WebUri.uri(_url!),
                              ),
                              initialUserScripts: UnmodifiableListView([
                                script,
                              ]),
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
                                _controller = controller;
                                controller.addJavaScriptHandler(
                                  handlerName: 'bennyWallet',
                                  callback: (args) => _bridge.handle(
                                    args.isEmpty ? null : args.first,
                                  ),
                                );
                              },
                              shouldOverrideUrlLoading:
                                  (controller, action) async {
                                    final scheme = action.request.url?.scheme;
                                    // Only web pages: wallet links (wc:,
                                    // solana-wallet:) and app intents are
                                    // not followed from inside the wallet.
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
                                  setState(
                                    () => _url = Uri.parse(url.toString()),
                                  );
                                }
                                unawaited(_afterLoad());
                              },
                              onUpdateVisitedHistory: (controller, url, _) {
                                if (url != null) {
                                  setState(
                                    () => _url = Uri.parse(url.toString()),
                                  );
                                }
                                unawaited(_afterLoad());
                              },
                              onProgressChanged: (controller, progress) {
                                setState(() => _progress = progress / 100);
                              },
                            );
                          },
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
          fontWeight: FontWeight.w800,
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
                      fontWeight: FontWeight.w800,
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
