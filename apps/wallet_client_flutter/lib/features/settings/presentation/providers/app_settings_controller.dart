import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/providers.dart';
import '../../domain/app_settings.dart';

class AppSettingsController extends StateNotifier<AppSettings> {
  AppSettingsController(this.ref) : super(const AppSettings()) {
    _bootstrap();
  }

  final Ref ref;

  Future<void> _bootstrap() async {
    state = await ref.read(appSettingsRepositoryProvider).load();
  }

  Future<void> setAutoLockOption(AutoLockOption option) async {
    await ref.read(appSettingsRepositoryProvider).setAutoLockOption(option);
    state = state.copyWith(autoLockOption: option);
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await ref.read(appSettingsRepositoryProvider).setNotificationsEnabled(enabled);
    state = state.copyWith(notificationsEnabled: enabled);
  }
}

final appSettingsControllerProvider =
    StateNotifierProvider<AppSettingsController, AppSettings>((ref) {
      return AppSettingsController(ref);
    });
