import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_client_flutter/features/settings/data/app_settings_repository.dart';
import 'package:wallet_client_flutter/features/settings/domain/app_settings.dart';

void main() {
  test('clearAll preserves the selected language', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = AppSettingsRepository();

    await repository.setLanguageOption(AppLanguageOption.traditionalChinese);
    await repository.setAutoLockOption(AutoLockOption.immediate);
    await repository.setNotificationsEnabled(false);
    await repository.clearAll();

    final settings = await repository.load();

    expect(settings.languageOption, AppLanguageOption.traditionalChinese);
    expect(settings.autoLockOption, AutoLockOption.fiveMinutes);
    expect(settings.notificationsEnabled, isTrue);
  });
}
