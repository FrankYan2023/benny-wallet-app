import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/di/providers.dart';
import '../../app/router.dart';
import '../../app/theme/app_colors.dart';
import '../../features/update/data/app_update_repository.dart';
import 'error_alert_dialog.dart';

enum AppUpdateDialogAction { later, updated }

class AppUpdateGate extends ConsumerStatefulWidget {
  const AppUpdateGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppUpdateGate> createState() => _AppUpdateGateState();
}

class _AppUpdateGateState extends ConsumerState<AppUpdateGate>
    with WidgetsBindingObserver {
  static const _minimumCheckInterval = Duration(seconds: 30);
  static const _initialPromptDelay = Duration(seconds: 3);
  static const _dismissedDateKey = 'app_update.dismissed_date';

  bool _checkInFlight = false;
  bool _dialogOpen = false;
  DateTime? _lastCheckedAt;
  Timer? _scheduledCheck;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scheduleCheck(force: true);
  }

  @override
  void dispose() {
    _scheduledCheck?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _scheduleCheck();
    }
  }

  void _scheduleCheck({bool force = false}) {
    _scheduledCheck?.cancel();
    _scheduledCheck = Timer(_initialPromptDelay, () {
      if (!mounted) {
        return;
      }
      unawaited(_checkForUpdate(force: force));
    });
  }

  Future<void> _checkForUpdate({bool force = false}) async {
    if (!mounted || _dialogOpen || _checkInFlight) {
      return;
    }

    if (await _wasDismissedToday()) {
      return;
    }

    final now = DateTime.now();
    if (!force &&
        _lastCheckedAt != null &&
        now.difference(_lastCheckedAt!) < _minimumCheckInterval) {
      return;
    }

    _checkInFlight = true;
    _lastCheckedAt = now;

    try {
      final result = await ref
          .read(appUpdateRepositoryProvider)
          .checkForUpdate()
          .catchError((_) {
            return null;
          });

      if (!mounted || result == null) {
        return;
      }

      final rootNavigator = AppRouter.rootNavigatorKey.currentState;
      if (rootNavigator == null || !rootNavigator.mounted) {
        return;
      }

      _dialogOpen = true;
      try {
        final action = await showAppUpdateDialog(rootNavigator.context, result);

        if (!result.required && action != AppUpdateDialogAction.updated) {
          await _markDismissedToday();
        }
      } finally {
        _dialogOpen = false;
      }
    } finally {
      _checkInFlight = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  Future<bool> _wasDismissedToday() async {
    final preferences = await SharedPreferences.getInstance();
    final dismissedDate = preferences.getString(_dismissedDateKey);
    if (dismissedDate == null || dismissedDate.isEmpty) {
      return false;
    }

    return dismissedDate == _todayKey();
  }

  Future<void> _markDismissedToday() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_dismissedDateKey, _todayKey());
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}

Future<AppUpdateDialogAction?> showAppUpdateDialog(
  BuildContext context,
  AppUpdateCheckResult result,
) {
  return showDialog<AppUpdateDialogAction>(
    context: context,
    barrierDismissible: !result.required,
    builder: (dialogContext) {
      return PopScope(
        canPop: !result.required,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(result.title),
          content: Text(result.message),
          actions: [
            if (!result.required)
              TextButton(
                onPressed: () => Navigator.of(
                  dialogContext,
                ).pop(AppUpdateDialogAction.later),
                child: const Text('Later'),
              ),
            FilledButton(
              onPressed: () async {
                final didLaunch = await launchAppUpdate(result);
                if (!dialogContext.mounted) {
                  return;
                }

                if (didLaunch) {
                  if (!result.required) {
                    Navigator.of(
                      dialogContext,
                    ).pop(AppUpdateDialogAction.updated);
                  }
                  return;
                }

                await showErrorAlertDialog(
                  dialogContext,
                  title: 'Update Failed',
                  message:
                      'Unable to open the Benny Wallet update link right now.',
                );
              },
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Update'),
            ),
          ],
        ),
      );
    },
  );
}

Future<bool> launchAppUpdate(AppUpdateCheckResult result) async {
  final target = result.downloadUrl ?? result.storeUrl;
  if (target == null || target.isEmpty) {
    return false;
  }

  final uri = Uri.tryParse(target);
  if (uri == null) {
    return false;
  }

  return launchUrl(uri, mode: LaunchMode.externalApplication);
}
