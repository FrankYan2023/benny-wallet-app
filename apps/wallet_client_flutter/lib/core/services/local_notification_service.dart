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
  }

  Future<void> cancelAll() async {
    await initialize();
    await _plugin.cancelAll();
  }
}
