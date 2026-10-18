import 'dart:async';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/crypto/local_cipher.dart';
import '../../../core/security/biometric_session_protector.dart';
import '../../../core/security/secure_screen.dart';
import '../../../core/services/biometric_auth_service.dart';
import '../../../core/storage/secure_store.dart';
import '../../../core/widgets/brand_logo.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../l10n/l10n.dart';
import '../data/offline_status.dart';
import '../data/signer_vault.dart';
import 'pages/signer_home_page.dart';
import 'pages/signer_setup_flow.dart';
import 'pages/signer_unlock_page.dart';
import 'signer_controller.dart';

/// The whole app in signer mode: no wallet screens, no network, no
/// notifications. Locks whenever it leaves the foreground.
class SignerApp extends StatefulWidget {
  const SignerApp({super.key, required this.locale, required this.onExit});

  final Locale? locale;

  /// Back to wallet mode. Only reachable while no seed is stored.
  final Future<void> Function() onExit;

  @override
  State<SignerApp> createState() => _SignerAppState();
}

class _SignerAppState extends State<SignerApp> with WidgetsBindingObserver {
  final _navigatorKey = GlobalKey<NavigatorState>();
  SignerController? _controller;
  SignerStage? _lastStage;
  bool _covered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_init());
  }

  Future<void> _init() async {
    // "version+build": a new build with the same version name is an update
    // too. Unknown (empty) makes the controller ask for the offline check
    // before every unlock (fail closed).
    var version = '';
    try {
      final info = await PackageInfo.fromPlatform();
      if (info.version.isNotEmpty) {
        version = info.buildNumber.isEmpty
            ? info.version
            : '${info.version}+${info.buildNumber}';
      }
    } on Object {
      version = '';
    }
    final controller = SignerController(
      vault: SignerVault(
        SecureStore(),
        LocalCipher(),
        const BiometricSessionProtector(),
      ),
      offline: OfflineStatusService(),
      biometricAuth: BiometricAuthService(),
      appVersion: version,
    )..addListener(_onControllerChanged);
    await controller.load();
    if (mounted) {
      setState(() => _controller = controller);
    } else {
      controller.dispose();
    }
  }

  void _onControllerChanged() {
    final stage = _controller?.stage;
    if (stage != _lastStage) {
      _lastStage = stage;
      // Locking or wiping closes every open screen (scan, review, settings).
      _navigatorKey.currentState?.popUntil((route) => route.isFirst);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Cover the screen as soon as the app stops being in front, so the app
    // switcher snapshot and the first frame after waking the phone never
    // show a QR code or the recovery phrase.
    final covered = state != AppLifecycleState.resumed;
    if (covered != _covered) {
      setState(() => _covered = covered);
    }
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _controller?.lock();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.removeListener(_onControllerChanged);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = signerTheme();
    final app = MaterialApp(
      navigatorKey: _navigatorKey,
      onGenerateTitle: (context) => context.l10n.signerAppTitle,
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: theme,
      darkTheme: theme,
      locale: widget.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => Stack(
        fit: StackFit.expand,
        children: [
          child ?? const SizedBox.shrink(),
          if (_covered) const _PrivacyCover(),
        ],
      ),
      home: _SignerRoot(controller: _controller, onExit: widget.onExit),
    );
    // Android: blank in recents and no screenshots or screen recording.
    return SecureScreen(child: app);
  }
}

class _PrivacyCover extends StatelessWidget {
  const _PrivacyCover();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Colors.black,
      child: Center(child: Opacity(opacity: 0.5, child: BrandLogo(size: 72))),
    );
  }
}

class _SignerRoot extends StatelessWidget {
  const _SignerRoot({required this.controller, required this.onExit});

  final SignerController? controller;
  final Future<void> Function() onExit;

  @override
  Widget build(BuildContext context) {
    final controller = this.controller;
    if (controller == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => switch (controller.stage) {
        SignerStage.loading => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        SignerStage.setup => SignerSetupFlow(
          controller: controller,
          onCancel: () => unawaited(onExit()),
        ),
        SignerStage.locked => SignerUnlockPage(controller: controller),
        SignerStage.unlocked => SignerHomePage(controller: controller),
      },
    );
  }
}

/// The signer uses the wallet's own warm light theme so both modes look
/// like the same app. Shared with the screen renders in tool/.
ThemeData signerTheme() => _signerTheme;

final ThemeData _signerTheme = AppTheme.light();
