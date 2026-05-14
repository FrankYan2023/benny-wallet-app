import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/router.dart';
import '../../app/di/providers.dart';
import '../../features/auth/presentation/providers/wallet_controller.dart';
import '../../features/auth/presentation/pages/unlock_page.dart';
import '../../features/settings/domain/app_settings.dart';
import '../../features/settings/presentation/providers/app_settings_controller.dart';

class SessionActivityListener extends ConsumerStatefulWidget {
  const SessionActivityListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SessionActivityListener> createState() =>
      _SessionActivityListenerState();
}

class _SessionActivityListenerState
    extends ConsumerState<SessionActivityListener>
    with WidgetsBindingObserver {
  final _focusNode = FocusNode();
  Timer? _idleTimer;
  DateTime? _backgroundedAt;
  DateTime? _lastActivityAt;
  bool _pendingUnlockNavigation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _idleTimer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final walletState = ref.read(walletControllerProvider);
    final autoLockOption = ref
        .read(appSettingsControllerProvider)
        .autoLockOption;

    if ((state == AppLifecycleState.hidden ||
            state == AppLifecycleState.paused ||
            state == AppLifecycleState.detached) &&
        walletState.isUnlocked) {
      _idleTimer?.cancel();
      final now = DateTime.now();
      _lastActivityAt ??= now;
      _backgroundedAt = now;
      if (autoLockOption == AutoLockOption.immediate) {
        _lockWallet(requireNavigation: true);
      }
      return;
    }

    if (state == AppLifecycleState.resumed) {
      unawaited(ref.read(appBadgeServiceProvider).clearApplicationBadge());
      unawaited(ref.read(localNotificationServiceProvider).cancelAll());

      final currentWalletState = ref.read(walletControllerProvider);
      if (currentWalletState.isUnlocked && _hasTimedOut(autoLockOption)) {
        _lockWallet(requireNavigation: true);
      }
      _backgroundedAt = null;

      _navigateToUnlockIfNeeded();
      _syncIdleTimer();
    }
  }

  void _syncIdleTimer() {
    _idleTimer?.cancel();

    final walletState = ref.read(walletControllerProvider);
    final autoLockOption = ref
        .read(appSettingsControllerProvider)
        .autoLockOption;
    final duration = autoLockOption.duration;
    if (!walletState.isUnlocked || duration == null) {
      if (!walletState.isUnlocked) {
        _lastActivityAt = null;
        _backgroundedAt = null;
      }
      return;
    }

    final now = DateTime.now();
    _lastActivityAt ??= now;
    final elapsed = now.difference(_lastActivityAt!);
    final remaining = duration - elapsed;
    if (remaining <= Duration.zero) {
      _lockWallet(requireNavigation: true);
      _navigateToUnlockIfNeeded();
      return;
    }

    _idleTimer = Timer(remaining, () {
      final currentWalletState = ref.read(walletControllerProvider);
      if (!currentWalletState.isUnlocked) {
        return;
      }

      _lockWallet(requireNavigation: true);
      _navigateToUnlockIfNeeded();
    });
  }

  void _registerActivity() {
    if (!ref.read(walletControllerProvider).isUnlocked) {
      return;
    }

    _lastActivityAt = DateTime.now();
    ref.read(walletControllerProvider.notifier).touch();
    _syncIdleTimer();
  }

  bool _hasTimedOut(AutoLockOption autoLockOption) {
    if (autoLockOption == AutoLockOption.immediate) {
      return true;
    }

    final duration = autoLockOption.duration;
    if (duration == null) {
      return false;
    }

    final now = DateTime.now();
    final activityElapsed = _lastActivityAt == null
        ? Duration.zero
        : now.difference(_lastActivityAt!);
    final backgroundElapsed = _backgroundedAt == null
        ? Duration.zero
        : now.difference(_backgroundedAt!);

    return activityElapsed >= duration || backgroundElapsed >= duration;
  }

  void _lockWallet({required bool requireNavigation}) {
    final walletState = ref.read(walletControllerProvider);
    if (!walletState.isUnlocked) {
      return;
    }

    _idleTimer?.cancel();
    _lastActivityAt = null;
    _backgroundedAt = null;
    _pendingUnlockNavigation = requireNavigation;
    ref.read(walletControllerProvider.notifier).lock();
  }

  void _navigateToUnlockIfNeeded() {
    final walletState = ref.read(walletControllerProvider);
    if (!_pendingUnlockNavigation ||
        !walletState.hasWallet ||
        walletState.isUnlocked) {
      return;
    }

    _pendingUnlockNavigation = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppRouter.router.go(UnlockPage.routePath);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(walletControllerProvider, (previous, next) {
      if (next.isUnlocked && previous?.isUnlocked != true) {
        _lastActivityAt = DateTime.now();
      }
      _navigateToUnlockIfNeeded();
      _syncIdleTimer();
    });
    ref.listen(appSettingsControllerProvider, (_, __) {
      _syncIdleTimer();
    });

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (_, __) {
        _registerActivity();
        return KeyEventResult.ignored;
      },
      child: Listener(
        onPointerDown: (_) => _registerActivity(),
        onPointerMove: (_) => _registerActivity(),
        child: widget.child,
      ),
    );
  }
}
