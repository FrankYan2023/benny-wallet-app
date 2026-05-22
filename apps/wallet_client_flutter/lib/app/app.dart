import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'di/providers.dart';
import '../core/widgets/session_activity_listener.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class WalletApp extends ConsumerStatefulWidget {
  const WalletApp({super.key});

  @override
  ConsumerState<WalletApp> createState() => _WalletAppState();
}

class _WalletAppState extends ConsumerState<WalletApp> {
  late final ThemeData _theme = AppTheme.light();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_initializeDeferredServices());
    });
  }

  Future<void> _initializeDeferredServices() async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) {
      return;
    }

    final appBadgeService = ref.read(appBadgeServiceProvider);
    final localNotificationService = ref.read(localNotificationServiceProvider);
    final pushNotificationService = ref.read(pushNotificationServiceProvider);

    await Future.wait<void>([
      appBadgeService.clearApplicationBadge().catchError((Object error) {}),
      localNotificationService
          .initialize()
          .then((_) => localNotificationService.cancelAll())
          .catchError((Object error) {}),
      pushNotificationService.initialize().then((_) {}).catchError((
        Object error,
      ) {}),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Benny Wallet',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: _theme,
      darkTheme: _theme,
      routerConfig: AppRouter.router,
      builder: (context, child) {
        return SessionActivityListener(child: child ?? const SizedBox.shrink());
      },
    );
  }
}
