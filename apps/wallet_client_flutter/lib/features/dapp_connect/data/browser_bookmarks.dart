import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/key_value_store.dart';
import '../../../core/storage/secure_store.dart';

/// A page saved in Benny's browser.
@immutable
class BrowserBookmark {
  const BrowserBookmark({
    required this.url,
    required this.title,
    required this.addedAt,
    this.icon,
  });

  final String url;
  final String title;
  final String? icon;
  final DateTime addedAt;

  String get host => Uri.tryParse(url)?.host ?? url;

  /// The title up to its first separator ("Jupiter: The Home of…" is
  /// "Jupiter"), for small tiles.
  String get shortTitle {
    final short = title.split(RegExp(r'\s*[:|–—]\s*|\s+-\s+')).first.trim();
    return short.isEmpty ? host : short;
  }

  Map<String, Object?> toJson() => {
    'u': url,
    't': title,
    if (icon != null) 'i': icon,
    'a': addedAt.millisecondsSinceEpoch,
  };

  static BrowserBookmark? fromJson(Object? json) {
    if (json is! Map || json['u'] is! String) {
      return null;
    }
    final at = json['a'];
    return BrowserBookmark(
      url: json['u'] as String,
      title: json['t'] as String? ?? json['u'] as String,
      icon: json['i'] as String?,
      addedAt: DateTime.fromMillisecondsSinceEpoch(at is int ? at : 0),
    );
  }
}

/// The browser's bookmarks, newest first, on this phone only (never
/// synced or backed up).
class BrowserBookmarks {
  BrowserBookmarks(this._store) {
    unawaited(_load());
  }

  static const _key = 'browser_bookmarks_v1';
  static const maxBookmarks = 200;

  final KeyValueStore _store;
  final bookmarks = ValueNotifier<List<BrowserBookmark>>(const []);
  Future<void>? _loading;

  Future<void> _load() => _loading ??= () async {
    try {
      final raw = await _store.read(_key);
      if (raw != null && raw.isNotEmpty) {
        bookmarks.value = List.unmodifiable([
          for (final item in jsonDecode(raw) as List)
            if (BrowserBookmark.fromJson(item) case final b?) b,
        ]);
      }
    } on Object {
      // Unreadable: start empty.
    }
  }();

  bool contains(String url) => bookmarks.value.any((b) => b.url == url);

  Future<void> add(BrowserBookmark bookmark) async {
    await _load();
    await _write([
      bookmark,
      for (final b in bookmarks.value)
        if (b.url != bookmark.url) b,
    ]);
  }

  Future<void> remove(String url) async {
    await _load();
    await _write([
      for (final b in bookmarks.value)
        if (b.url != url) b,
    ]);
  }

  Future<void> _write(List<BrowserBookmark> list) async {
    final kept = list.take(maxBookmarks).toList();
    bookmarks.value = List.unmodifiable(kept);
    await _store.write(_key, jsonEncode([for (final b in kept) b.toJson()]));
  }
}

final browserBookmarksProvider = Provider<BrowserBookmarks>(
  (ref) => BrowserBookmarks(SecureStore.deviceOnly()),
);
