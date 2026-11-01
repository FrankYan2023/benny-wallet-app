import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../../dapp_connect/presentation/open_link.dart';
import '../../domain/token_candles.dart';

/// Text the chart draws itself: the legend labels.
class KlineChartLabels {
  const KlineChartLabels({
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  final String open;
  final String high;
  final String low;
  final String close;
  final String volume;

  Map<String, String> toJson() => {
    'open': open,
    'high': high,
    'low': low,
    'close': close,
    'volume': volume,
  };
}

/// A TradingView Lightweight Charts candlestick chart. The library ships in
/// the app's assets and runs in a web view that never loads anything else.
class KlineChartView extends StatefulWidget {
  const KlineChartView({
    super.key,
    required this.candles,
    required this.upColor,
    required this.downColor,
    required this.locale,
    required this.labels,
  });

  final TokenCandles candles;
  final Color upColor;
  final Color downColor;
  final String locale;
  final KlineChartLabels labels;

  @override
  State<KlineChartView> createState() => _KlineChartViewState();
}

class _KlineChartViewState extends State<KlineChartView> {
  static Future<String>? _page;

  InAppWebViewController? _controller;
  bool _loaded = false;

  /// The chart page with the library inlined, so it needs no file access.
  static Future<String> _loadPage() {
    return _page ??= Future(() async {
      final page = await rootBundle.loadString('assets/kline/kline.html');
      final library = await rootBundle.loadString(
        'assets/kline/lightweight-charts.standalone.production.js',
      );
      return page.replaceFirst('/*LIGHTWEIGHT_CHARTS*/', library);
    });
  }

  @override
  void didUpdateWidget(covariant KlineChartView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.upColor != widget.upColor ||
        oldWidget.downColor != widget.downColor ||
        oldWidget.locale != widget.locale) {
      _configure();
    }
    if (!identical(oldWidget.candles, widget.candles)) {
      _pushData();
    }
  }

  Future<void> _configure() async {
    final controller = _controller;
    if (controller == null || !_loaded) {
      return;
    }
    final options = jsonEncode({
      'up': _cssColor(widget.upColor),
      'down': _cssColor(widget.downColor),
      'locale': widget.locale,
      'labels': widget.labels.toJson(),
    });
    await controller.evaluateJavascript(
      source: 'window.bennyChart.configure($options);',
    );
  }

  Future<void> _pushData() async {
    final controller = _controller;
    if (controller == null || !_loaded) {
      return;
    }
    final candles = widget.candles;
    final payload = jsonEncode({
      'key': '${candles.mintAddress}:${candles.interval.apiValue}',
      'interval': candles.interval.apiValue,
      'candles': [
        for (final candle in candles.candles)
          [
            candle.time,
            candle.open,
            candle.high,
            candle.low,
            candle.close,
            candle.volume,
          ],
      ],
    });
    await controller.evaluateJavascript(
      source: 'window.bennyChart.setData($payload);',
    );
  }

  static String _cssColor(Color color) {
    final rgb = color.toARGB32() & 0xFFFFFF;
    return '#${rgb.toRadixString(16).padLeft(6, '0')}';
  }

  /// The chart's only link is TradingView's attribution logo; it opens in
  /// a tab of Benny's browser, never inside the chart.
  Future<void> _openLink(WebUri? url) async {
    if (url == null || !(url.scheme == 'https' || url.scheme == 'http')) {
      return;
    }
    await openLinkInApp(context, url.toString());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _loadPage(),
      builder: (context, snapshot) {
        final page = snapshot.data;
        if (page == null) {
          return const SizedBox.expand();
        }
        return InAppWebView(
          initialData: InAppWebViewInitialData(data: page),
          initialSettings: InAppWebViewSettings(
            transparentBackground: true,
            supportZoom: false,
            disableContextMenu: true,
            disallowOverScroll: true,
            verticalScrollBarEnabled: false,
            horizontalScrollBarEnabled: false,
            useShouldOverrideUrlLoading: true,
            javaScriptCanOpenWindowsAutomatically: false,
            supportMultipleWindows: true,
            allowFileAccess: false,
            allowContentAccess: false,
            mediaPlaybackRequiresUserGesture: true,
            // Android: draw into a texture rather than a hybrid-composition
            // view, which stutters while the page scrolls around it. The
            // chart takes no text input, the case hybrid composition is for.
            useHybridComposition: false,
          ),
          // Sideways drags pan the chart, a long press shows the crosshair
          // and two fingers zoom it; one-finger vertical swipes still scroll
          // the page.
          gestureRecognizers: {
            Factory<HorizontalDragGestureRecognizer>(
              HorizontalDragGestureRecognizer.new,
            ),
            Factory<LongPressGestureRecognizer>(LongPressGestureRecognizer.new),
            Factory<_TwoFingerGestureRecognizer>(
              _TwoFingerGestureRecognizer.new,
            ),
          },
          onWebViewCreated: (controller) => _controller = controller,
          onLoadStop: (controller, _) async {
            _loaded = true;
            await _configure();
            await _pushData();
          },
          shouldOverrideUrlLoading: (controller, action) async {
            final url = action.request.url;
            if (url == null || url.scheme == 'about' || url.scheme == 'data') {
              return NavigationActionPolicy.ALLOW;
            }
            await _openLink(url);
            return NavigationActionPolicy.CANCEL;
          },
          onCreateWindow: (controller, action) async {
            await _openLink(action.request.url);
            return false;
          },
        );
      },
    );
  }
}

/// Claims the gesture for the chart as soon as a second finger lands, so a
/// pinch zooms the chart. With one finger it never claims, leaving vertical
/// swipes to the page around the chart.
class _TwoFingerGestureRecognizer extends OneSequenceGestureRecognizer {
  final Set<int> _pointers = {};

  @override
  void addAllowedPointer(PointerDownEvent event) {
    startTrackingPointer(event.pointer, event.transform);
    _pointers.add(event.pointer);
    if (_pointers.length >= 2) {
      resolve(GestureDisposition.accepted);
    }
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerUpEvent || event is PointerCancelEvent) {
      _pointers.remove(event.pointer);
      stopTrackingPointer(event.pointer);
    }
  }

  @override
  void didStopTrackingLastPointer(int pointer) {
    _pointers.clear();
  }

  @override
  void rejectGesture(int pointer) {
    _pointers.remove(pointer);
    super.rejectGesture(pointer);
  }

  @override
  String get debugDescription => 'two fingers';
}
