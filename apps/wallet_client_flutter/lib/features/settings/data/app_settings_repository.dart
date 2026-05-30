import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../domain/app_settings.dart';

class AppSettingsRepository {
  Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettings(
      autoLockOption: AutoLockOption.fromStorageValue(
        prefs.getString(AppConstants.autoLockOptionKey),
      ),
      languageOption: AppLanguageOption.fromStorageValue(
        prefs.getString(AppConstants.appLanguageOptionKey),
      ),
      notificationsEnabled:
          prefs.getBool(AppConstants.notificationsEnabledKey) ?? true,
    );
  }

  Future<void> setAutoLockOption(AutoLockOption option) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.autoLockOptionKey, option.name);
  }

  Future<void> setLanguageOption(AppLanguageOption option) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.appLanguageOptionKey, option.name);
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.notificationsEnabledKey, enabled);
  }

  Future<String?> getLastIncomingNotificationSignature({
    required String walletPublicKey,
    required String mintAddress,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(
      _incomingNotificationKey(walletPublicKey, mintAddress),
    );
  }

  Future<void> setLastIncomingNotificationSignature({
    required String walletPublicKey,
    required String mintAddress,
    required String signature,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _incomingNotificationKey(walletPublicKey, mintAddress),
      signature,
    );
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    for (final key in keys) {
      if (key == AppConstants.autoLockOptionKey ||
          key == AppConstants.notificationsEnabledKey ||
          key.startsWith('${AppConstants.lastIncomingNotificationPrefix}:')) {
        await prefs.remove(key);
      }
    }
  }

  String _incomingNotificationKey(String walletPublicKey, String mintAddress) {
    return '${AppConstants.lastIncomingNotificationPrefix}:${walletPublicKey}_$mintAddress';
  }
}
