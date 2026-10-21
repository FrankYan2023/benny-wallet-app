import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    const androidSettings = AndroidInitializationSettings('ic_stat_benny');
    const iosSettings = DarwinInitializationSettings();

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );
    await _createAndroidChannels();

    _initialized = true;
  }

  Future<bool> requestPermission() async {
    await initialize();

    final androidImplementation = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidImplementation != null) {
      final granted = await androidImplementation
          .requestNotificationsPermission();
      return granted ?? false;
    }

    final iosImplementation = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (iosImplementation != null) {
      final granted = await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  Future<void> showIncomingFundsNotification({required String amountText}) {
    return showNotification(
      id: 1001,
      title: 'Funds received',
      body: 'You received $amountText',
    );
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await initialize();

    const androidDetails = AndroidNotificationDetails(
      'incoming-funds',
      'Incoming funds',
      channelDescription: 'Alerts when new funds arrive in the wallet.',
      importance: Importance.max,
      priority: Priority.high,
      icon: 'ic_stat_benny',
      largeIcon: DrawableResourceAndroidBitmap('ic_launcher'),
      color: Color(0xFF111827),
    );
    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(id, title, body, details);
  }

  /// A website sent a request while the app was closed; tapping opens the
  /// app, which shows the request once the wallet is unlocked. The text is
  /// generic: the push carries the request encrypted.
  Future<void> showDappRequestNotification({
    required String languageCode,
  }) async {
    await initialize();
    final chinese = languageCode.startsWith('zh');
    const androidDetails = AndroidNotificationDetails(
      dappRequestChannel,
      'Website requests',
      channelDescription: 'A connected website asks you to sign.',
      importance: Importance.max,
      priority: Priority.high,
      icon: 'ic_stat_benny',
      largeIcon: DrawableResourceAndroidBitmap('ic_launcher'),
      color: Color(0xFF111827),
    );
    await _plugin.show(
      dappRequestNotificationId,
      chinese ? '網站請求簽名' : 'Website request',
      chinese
          ? '已連接的網站請你簽名。打開 Benny 查看並確認。'
          : 'A connected website asks you to sign. Open Benny to review it.',
      const NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  static const dappRequestChannel = 'dapp-requests';

  /// One notification at a time for website requests: the app shows them
  /// all once opened.
  static const dappRequestNotificationId = 2001;

  Future<void> _createAndroidChannels() async {
    final androidImplementation = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidImplementation == null) {
      return;
    }

    await androidImplementation.createNotificationChannel(
      const AndroidNotificationChannel(
        'incoming-funds',
        'Incoming funds',
        description: 'Alerts when new funds arrive in the wallet.',
        importance: Importance.max,
      ),
    );
    await androidImplementation.createNotificationChannel(
      const AndroidNotificationChannel(
        dappRequestChannel,
        'Website requests',
        description: 'A connected website asks you to sign.',
        importance: Importance.max,
      ),
    );
  }

  Future<void> cancelAll() async {
    await initialize();
    await _plugin.cancelAll();
  }
}
