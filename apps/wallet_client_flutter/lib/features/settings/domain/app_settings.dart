import 'dart:ui';

enum AutoLockOption {
  immediate('Immediately', null),
  oneMinute('1 minute', Duration(minutes: 1)),
  fiveMinutes('5 minutes', Duration(minutes: 5)),
  tenMinutes('10 minutes', Duration(minutes: 10)),
  thirtyMinutes('30 minutes', Duration(minutes: 30));

  const AutoLockOption(this.label, this.duration);

  final String label;
  final Duration? duration;

  static AutoLockOption fromStorageValue(String? value) {
    return AutoLockOption.values.firstWhere(
      (option) => option.name == value,
      orElse: () => AutoLockOption.fiveMinutes,
    );
  }
}

enum AppLanguageOption {
  system(null, null),
  english('en', null),
  traditionalChinese('zh', 'Hant'),
  spanish('es', null),
  japanese('ja', null),
  russian('ru', null),
  korean('ko', null);

  const AppLanguageOption(this.languageCode, this.scriptCode);

  final String? languageCode;
  final String? scriptCode;

  String? get nativeLabel {
    return switch (this) {
      AppLanguageOption.system => null,
      AppLanguageOption.english => 'English',
      AppLanguageOption.traditionalChinese => '繁體中文',
      AppLanguageOption.spanish => 'Español',
      AppLanguageOption.japanese => '日本語',
      AppLanguageOption.russian => 'Русский',
      AppLanguageOption.korean => '한국어',
    };
  }

  Locale? get locale {
    final code = languageCode;
    if (code == null) {
      return null;
    }
    return Locale.fromSubtags(languageCode: code, scriptCode: scriptCode);
  }

  static AppLanguageOption fromStorageValue(String? value) {
    return AppLanguageOption.values.firstWhere(
      (option) => option.name == value,
      orElse: () => AppLanguageOption.system,
    );
  }
}

class AppSettings {
  const AppSettings({
    this.autoLockOption = AutoLockOption.fiveMinutes,
    this.languageOption = AppLanguageOption.system,
    this.notificationsEnabled = true,
  });

  final AutoLockOption autoLockOption;
  final AppLanguageOption languageOption;
  final bool notificationsEnabled;

  AppSettings copyWith({
    AutoLockOption? autoLockOption,
    AppLanguageOption? languageOption,
    bool? notificationsEnabled,
  }) {
    return AppSettings(
      autoLockOption: autoLockOption ?? this.autoLockOption,
      languageOption: languageOption ?? this.languageOption,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}
