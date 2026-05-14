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

class AppSettings {
  const AppSettings({
    this.autoLockOption = AutoLockOption.fiveMinutes,
    this.notificationsEnabled = true,
  });

  final AutoLockOption autoLockOption;
  final bool notificationsEnabled;

  AppSettings copyWith({
    AutoLockOption? autoLockOption,
    bool? notificationsEnabled,
  }) {
    return AppSettings(
      autoLockOption: autoLockOption ?? this.autoLockOption,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}
