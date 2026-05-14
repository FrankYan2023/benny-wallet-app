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
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() async {
      await ref.read(appBadgeServiceProvider).clearApplicationBadge();
      await ref.read(localNotificationServiceProvider).initialize();
      await ref.read(localNotificationServiceProvider).cancelAll();
      await ref.read(pushNotificationServiceProvider).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Benny Wallet',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: AppTheme.light(),
      darkTheme: AppTheme.light(),
      routerConfig: AppRouter.router,
      builder: (context, child) {
        return SessionActivityListener(child: child ?? const SizedBox.shrink());
      },
    );
  }
}
