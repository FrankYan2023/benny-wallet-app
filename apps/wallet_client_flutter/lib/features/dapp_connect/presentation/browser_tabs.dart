import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One tab of Benny's browser: a page, or Benny's home when [url] is null.
class BrowserTab {
  BrowserTab({required this.id, this.url});

  final int id;
  Uri? url;
  String? title;
  String? icon;
}

/// The browser's tabs for this run of the app. They outlive the browser
/// page, so closing the browser and opening a link from elsewhere adds a
/// tab beside the earlier ones; nothing is saved to the phone.
class BrowserTabs extends ChangeNotifier {
  /// Each tab keeps a web view alive; past this the oldest tab is closed.
  static const maxTabs = 8;

  final List<BrowserTab> _tabs = [];
  int _nextId = 0;
  int? _activeId;

  List<BrowserTab> get tabs => List.unmodifiable(_tabs);

  BrowserTab? get active =>
      _tabs.where((tab) => tab.id == _activeId).firstOrNull;

  /// Opens [url] (Benny's home when null) in a new tab and shows it.
  BrowserTab open(Uri? url) {
    final tab = BrowserTab(id: _nextId++, url: url);
    _tabs.add(tab);
    if (_tabs.length > maxTabs) {
      _tabs.remove(_tabs.firstWhere((other) => other.id != tab.id));
    }
    _activeId = tab.id;
    notifyListeners();
    return tab;
  }

  /// The tab on screen, opening Benny's home when there is none.
  BrowserTab ensureActive() => active ?? open(null);

  void activate(int id) {
    if (_activeId == id || !_tabs.any((tab) => tab.id == id)) {
      return;
    }
    _activeId = id;
    notifyListeners();
  }

  /// Closes a tab; the neighbour takes its place, and closing the last tab
  /// leaves a fresh home tab.
  void close(int id) {
    final index = _tabs.indexWhere((tab) => tab.id == id);
    if (index < 0) {
      return;
    }
    _tabs.removeAt(index);
    if (_activeId == id) {
      _activeId = _tabs.isEmpty
          ? null
          : _tabs[index.clamp(0, _tabs.length - 1)].id;
    }
    if (_tabs.isEmpty) {
      open(null);
      return;
    }
    notifyListeners();
  }

  /// Records where a tab has gone and what the page calls itself.
  void update(
    int id, {
    Uri? url,
    bool clearUrl = false,
    String? title,
    String? icon,
  }) {
    final tab = _tabs.where((tab) => tab.id == id).firstOrNull;
    if (tab == null) {
      return;
    }
    if (clearUrl) {
      tab
        ..url = null
        ..title = null
        ..icon = null;
    } else if (url != null) {
      tab.url = url;
    }
    if (title != null) {
      tab.title = title;
    }
    if (icon != null) {
      tab.icon = icon;
    }
    notifyListeners();
  }
}

/// The browser page listens to the tabs itself, so opening a tab while a
/// page builds does not notify Riverpod.
final browserTabsProvider = Provider<BrowserTabs>((ref) {
  final tabs = BrowserTabs();
  ref.onDispose(tabs.dispose);
  return tabs;
});
