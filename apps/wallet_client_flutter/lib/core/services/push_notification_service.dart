import 'dart:async';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../features/auth/domain/wallet_controller_state.dart';
import '../config/firebase_runtime_options.dart';
import '../constants/app_constants.dart';
import '../network/api_client.dart';
import '../storage/key_value_store.dart';
import 'local_notification_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final options = FirebaseRuntimeOptions.currentPlatform;
  if (options == null) {
    return;
  }
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: options);
  }
}

class PushNotificationService {
  PushNotificationService({
    required KeyValueStore store,
    required BackendApiClient apiClient,
    required LocalNotificationService localNotificationService,
    Future<bool> Function()? notificationsEnabledReader,
    Future<void> Function(RemoteMessage message)? onRemoteMessageReceived,
  }) : _store = store,
       _apiClient = apiClient,
       _localNotificationService = localNotificationService,
       _notificationsEnabledReader = notificationsEnabledReader,
       _onRemoteMessageReceived = onRemoteMessageReceived;

  final KeyValueStore _store;
  final BackendApiClient _apiClient;
  final LocalNotificationService _localNotificationService;
  final Future<bool> Function()? _notificationsEnabledReader;
  final Future<void> Function(RemoteMessage message)? _onRemoteMessageReceived;

  bool _initialized = false;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;
  StreamSubscription<String>? _tokenRefreshSubscription;

  bool get isConfigured => FirebaseRuntimeOptions.isConfigured;

  Future<bool> initialize() async {
    if (!isConfigured) {
      debugPrint('[PUSH] Firebase runtime options are not configured.');
      return false;
    }
    if (_initialized) {
      return true;
    }

    final options = FirebaseRuntimeOptions.currentPlatform;
    if (options == null) {
      debugPrint('[PUSH] Firebase options are unavailable for this platform.');
      return false;
    }

    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: options);
    }
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

    _foregroundSubscription ??= FirebaseMessaging.onMessage.listen(
      _handleForegroundMessage,
    );
    _openedSubscription ??= FirebaseMessaging.onMessageOpenedApp.listen(
      _handleOpenedMessage,
    );
    _tokenRefreshSubscription ??= FirebaseMessaging.instance.onTokenRefresh
        .listen(_handleTokenRefresh);

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      await _recordMessage(initialMessage);
    }

    _initialized = true;
    return true;
  }

  Future<bool> requestPermissionAndRegister({
    required WalletControllerState walletState,
    required bool enabled,
  }) async {
    if (!walletState.isUnlocked || walletState.publicKey == null) {
      debugPrint(
        '[PUSH] Register skipped: wallet is locked or missing public key.',
      );
      return false;
    }

    if (!enabled) {
      await unregisterCurrentDevice(walletState: walletState);
      return true;
    }

    final initialized = await initialize();
    if (!initialized) {
      debugPrint('[PUSH] Register skipped: Firebase initialization failed.');
      return false;
    }

    final permissionStatus = await _ensureNotificationPermission();
    if (!_canReceiveRemoteNotifications(permissionStatus)) {
      debugPrint(
        '[PUSH] Register skipped: notification permission is ${_permissionStatusName(permissionStatus)}.',
      );
      await _store.write(
        AppConstants.lastPushPermissionStatusKey,
        _permissionStatusName(permissionStatus),
      );
      return false;
    }

    final token = await _readMessagingToken();
    if (token == null || token.isEmpty) {
      debugPrint('[PUSH] Register skipped: FCM token is empty.');
      return false;
    }

    await _registerDeviceToken(
      token: token,
      enabled: true,
      permissionStatus: _permissionStatusName(permissionStatus),
      walletState: walletState,
    );
    debugPrint('[PUSH] Notification device registered.');

    return true;
  }

  Future<void> unregisterCurrentDevice({
    required WalletControllerState walletState,
  }) async {
    if (!walletState.isUnlocked || walletState.publicKey == null) {
      debugPrint(
        '[PUSH] Unregister skipped: wallet is locked or missing public key.',
      );
      return;
    }

    final installId = await _readOrCreateInstallId();
    final lastToken = await _store.read(AppConstants.lastPushFcmTokenKey);
    final permissionStatus = await _readPermissionStatusName();
    await _unregisterDeviceToken(
      installId: installId,
      token: lastToken,
      permissionStatus: permissionStatus,
    );
    await _clearRegisteredDeviceCache();
    debugPrint('[PUSH] Notification device unregistered.');
  }

  Future<void> syncEnabledDevice({
    required WalletControllerState walletState,
    required bool notificationsEnabled,
  }) async {
    if (!notificationsEnabled) {
      debugPrint('[PUSH] Sync skipped: receive notifications disabled.');
      return;
    }
    if (!isConfigured) {
      debugPrint('[PUSH] Sync skipped: Firebase is not configured.');
      return;
    }

    try {
      await requestPermissionAndRegister(
        walletState: walletState,
        enabled: true,
      );
    } catch (error, stack) {
      debugPrint('[PUSH] Failed to sync notification device: $error');
      debugPrintStack(stackTrace: stack, label: '[PUSH] Stack');
    }
  }

  void dispose() {
    unawaited(_foregroundSubscription?.cancel());
    unawaited(_openedSubscription?.cancel());
    unawaited(_tokenRefreshSubscription?.cancel());
    _foregroundSubscription = null;
    _openedSubscription = null;
    _tokenRefreshSubscription = null;
    _initialized = false;
  }

  Future<void> _handleTokenRefresh(String token) async {
    if (token.isEmpty) {
      return;
    }

    try {
      final notificationsEnabled =
          await _notificationsEnabledReader?.call() ?? false;
      if (!notificationsEnabled) {
        debugPrint('[PUSH] Token refresh skipped: notifications disabled.');
        return;
      }

      final previousToken = await _store.read(AppConstants.lastPushFcmTokenKey);
      final installId = await _readOrCreateInstallId();
      final permissionStatus = await _readPermissionStatusName();
      if (previousToken != null &&
          previousToken.isNotEmpty &&
          previousToken != token) {
        await _unregisterDeviceToken(
          installId: installId,
          token: previousToken,
          permissionStatus: permissionStatus,
        );
      }

      await _registerDeviceToken(
        token: token,
        enabled: true,
        permissionStatus: permissionStatus,
      );
      debugPrint('[PUSH] Notification device refreshed.');
    } catch (error, stack) {
      debugPrint('[PUSH] Token refresh registration failed: $error');
      debugPrintStack(stackTrace: stack, label: '[PUSH] Stack');
    }
  }

  Future<String?> _readMessagingToken() async {
    if (_isApplePlatform && !await _waitForApnsToken()) {
      debugPrint('[PUSH] APNs token is not ready; FCM token read skipped.');
      return null;
    }

    const retryDelays = [
      Duration.zero,
      Duration(milliseconds: 500),
      Duration(seconds: 1),
      Duration(seconds: 2),
    ];

    for (final delay in retryDelays) {
      if (delay > Duration.zero) {
        await Future<void>.delayed(delay);
      }

      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        return token;
      }
    }

    return null;
  }

  Future<void> _registerDeviceToken({
    required String token,
    required bool enabled,
    required String permissionStatus,
    WalletControllerState? walletState,
  }) async {
    final installId = await _readOrCreateInstallId();
    final packageInfo = await PackageInfo.fromPlatform();
    await _apiClient.registerNotificationDevice(
      appVersion: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
      fcmToken: token,
      installId: installId,
      notificationsEnabled: enabled,
      permissionStatus: permissionStatus,
      platform: _platformName(),
    );
    await _store.write(AppConstants.lastPushFcmTokenKey, token);
    await _store.write(
      AppConstants.lastPushPermissionStatusKey,
      permissionStatus,
    );
    await _store.write(
      AppConstants.lastPushRegisteredAtKey,
      DateTime.now().toUtc().toIso8601String(),
    );
    final publicKey = walletState?.publicKey;
    if (publicKey != null && publicKey.isNotEmpty) {
      await _store.write(AppConstants.lastPushWalletPublicKeyKey, publicKey);
    }
  }

  Future<void> _unregisterDeviceToken({
    required String installId,
    required String? token,
    required String permissionStatus,
  }) async {
    final packageInfo = await PackageInfo.fromPlatform();
    await _apiClient.unregisterNotificationDevice(
      appVersion: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
      fcmToken: token,
      installId: installId,
      permissionStatus: permissionStatus,
      platform: _platformName(),
    );
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    await _recordMessage(message);
    final title = message.notification?.title ?? 'Funds received';
    final body = message.notification?.body ?? _bodyFromData(message.data);
    await _localNotificationService.showNotification(
      id: _notificationId(message.messageId),
      title: title,
      body: body,
    );
  }

  Future<void> _handleOpenedMessage(RemoteMessage message) {
    return _recordMessage(message);
  }

  Future<void> _recordMessage(RemoteMessage message) async {
    await _onRemoteMessageReceived?.call(message);
  }

  String _bodyFromData(Map<String, dynamic> data) {
    final amount = data['amountText'];
    final symbol = data['symbol'];
    if (amount is String &&
        amount.isNotEmpty &&
        symbol is String &&
        symbol.isNotEmpty) {
      return 'You received $amount $symbol';
    }
    return 'New funds arrived in your wallet.';
  }

  int _notificationId(String? messageId) {
    if (messageId == null || messageId.isEmpty) {
      return DateTime.now().millisecondsSinceEpoch.remainder(100000);
    }
    return messageId.hashCode & 0x7fffffff;
  }

  Future<String> _readOrCreateInstallId() async {
    final existing = await _store.read(AppConstants.installAnalyticsIdKey);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final installId = _generateUuidV4();
    await _store.write(AppConstants.installAnalyticsIdKey, installId);
    return installId;
  }

  Future<AuthorizationStatus> _ensureNotificationPermission() async {
    var settings = await FirebaseMessaging.instance.getNotificationSettings();
    if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
      settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    if (_canReceiveRemoteNotifications(settings.authorizationStatus)) {
      await _localNotificationService.requestPermission();
    }

    return settings.authorizationStatus;
  }

  Future<String> _readPermissionStatusName() async {
    if (!isConfigured) {
      return 'unknown';
    }

    try {
      if (await initialize()) {
        final settings = await FirebaseMessaging.instance
            .getNotificationSettings();
        return _permissionStatusName(settings.authorizationStatus);
      }
    } catch (_) {
      // Permission status is diagnostic only; keep unregister/register best-effort.
    }

    return await _store.read(AppConstants.lastPushPermissionStatusKey) ??
        'unknown';
  }

  Future<bool> _waitForApnsToken() async {
    const retryDelays = [
      Duration.zero,
      Duration(milliseconds: 500),
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 3),
    ];

    for (final delay in retryDelays) {
      if (delay > Duration.zero) {
        await Future<void>.delayed(delay);
      }

      try {
        final token = await FirebaseMessaging.instance.getAPNSToken();
        if (token != null && token.isNotEmpty) {
          return true;
        }
      } catch (error) {
        debugPrint('[PUSH] APNs token read failed: $error');
      }
    }

    return false;
  }

  Future<void> _clearRegisteredDeviceCache() async {
    await _store.deleteAll(const [
      AppConstants.lastPushFcmTokenKey,
      AppConstants.lastPushWalletPublicKeyKey,
      AppConstants.lastPushPermissionStatusKey,
      AppConstants.lastPushRegisteredAtKey,
    ]);
  }

  bool get _isApplePlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  bool _canReceiveRemoteNotifications(AuthorizationStatus status) {
    return status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional;
  }

  String _permissionStatusName(AuthorizationStatus status) {
    switch (status) {
      case AuthorizationStatus.authorized:
        return 'authorized';
      case AuthorizationStatus.provisional:
        return 'provisional';
      case AuthorizationStatus.denied:
        return 'denied';
      case AuthorizationStatus.notDetermined:
        return 'not_determined';
    }
  }

  String _platformName() {
    if (kIsWeb) {
      return 'web';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.macOS:
        return 'macos';
      case TargetPlatform.windows:
        return 'windows';
      case TargetPlatform.linux:
        return 'linux';
      case TargetPlatform.fuchsia:
        return 'unknown';
    }
  }
}

String _generateUuidV4() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;

  String hexByte(int value) => value.toRadixString(16).padLeft(2, '0');

  return [for (final value in bytes) hexByte(value)].join().replaceFirstMapped(
    RegExp(r'^(.{8})(.{4})(.{4})(.{4})(.{12})$'),
    (match) =>
        '${match.group(1)}-${match.group(2)}-${match.group(3)}-${match.group(4)}-${match.group(5)}',
  );
}
