import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_client_flutter/features/settings/domain/app_settings.dart';
import 'package:wallet_client_flutter/l10n/generated/app_localizations.dart';

const _targetLocaleFiles = [
  'lib/l10n/app_es.arb',
  'lib/l10n/app_zh_Hant.arb',
  'lib/l10n/app_ja.arb',
  'lib/l10n/app_ru.arb',
  'lib/l10n/app_ko.arb',
];

void main() {
  group('localization coverage', () {
    test('target locales have every template message key', () {
      final templateKeys = _messageKeys('lib/l10n/app_en.arb');

      for (final localeFile in _targetLocaleFiles) {
        final localeKeys = _messageKeys(localeFile);
        final missing = templateKeys.difference(localeKeys).toList()..sort();

        expect(
          missing,
          isEmpty,
          reason: '$localeFile is missing localized message keys.',
        );
      }
    });

    test('supported locales include every language option', () {
      expect(AppLocalizations.supportedLocales, contains(const Locale('en')));
      expect(AppLocalizations.supportedLocales, contains(const Locale('es')));
      expect(AppLocalizations.supportedLocales, contains(const Locale('ja')));
      expect(AppLocalizations.supportedLocales, contains(const Locale('ru')));
      expect(AppLocalizations.supportedLocales, contains(const Locale('ko')));
      expect(
        AppLocalizations.supportedLocales,
        contains(
          const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
        ),
      );
    });

    test('language picker order is stable', () {
      expect(AppLanguageOption.values, const [
        AppLanguageOption.system,
        AppLanguageOption.english,
        AppLanguageOption.traditionalChinese,
        AppLanguageOption.spanish,
        AppLanguageOption.japanese,
        AppLanguageOption.russian,
        AppLanguageOption.korean,
      ]);
    });

    test('language picker options use native language names', () {
      expect(AppLanguageOption.system.nativeLabel, isNull);
      expect(AppLanguageOption.english.nativeLabel, 'English');
      expect(AppLanguageOption.traditionalChinese.nativeLabel, '繁體中文');
      expect(AppLanguageOption.spanish.nativeLabel, 'Español');
      expect(AppLanguageOption.japanese.nativeLabel, '日本語');
      expect(AppLanguageOption.russian.nativeLabel, 'Русский');
      expect(AppLanguageOption.korean.nativeLabel, '한국어');
    });

    test('Android and iOS native localization resources exist', () {
      for (final flavor in const ['liteStore', 'liteSeeker', 'full']) {
        expect(
          File('android/app/src/$flavor/res/values/strings.xml').existsSync(),
          isTrue,
          reason: '$flavor is missing default Android resources.',
        );
        expect(
          File(
            'android/app/src/$flavor/res/values-es/strings.xml',
          ).existsSync(),
          isTrue,
          reason: '$flavor is missing Spanish Android resources.',
        );
        expect(
          File(
            'android/app/src/$flavor/res/values-b+zh+Hant/strings.xml',
          ).existsSync(),
          isTrue,
          reason: '$flavor is missing Traditional Chinese Android resources.',
        );
        for (final locale in const ['ja', 'ru', 'ko']) {
          expect(
            File(
              'android/app/src/$flavor/res/values-$locale/strings.xml',
            ).existsSync(),
            isTrue,
            reason: '$flavor is missing $locale Android resources.',
          );
        }
      }

      for (final locale in const ['es', 'zh-Hant', 'ja', 'ru', 'ko']) {
        expect(
          File('ios/Runner/$locale.lproj/InfoPlist.strings').existsSync(),
          isTrue,
          reason: 'iOS is missing $locale InfoPlist.strings.',
        );
      }
    });

    test('presentation pages do not contain unlocalized visible literals', () {
      final violations = <String>[];

      for (final file in _dartFilesToScan()) {
        final lines = file.readAsLinesSync();
        for (var index = 0; index < lines.length; index += 1) {
          final line = lines[index];
          for (final literal in _visibleStringLiterals(line)) {
            if (_allowedVisibleLiteral(literal)) {
              continue;
            }
            violations.add(
              '${file.path}:${index + 1}: use AppLocalizations for "$literal"',
            );
          }
        }
      }

      expect(
        violations,
        isEmpty,
        reason: 'User-visible page copy should come from AppLocalizations.',
      );
    });

    test('used AppLocalizations keys exist in target locale ARB files', () {
      final usedKeys = _usedLocalizationKeys();

      for (final localeFile in _targetLocaleFiles) {
        final localeKeys = _messageKeys(localeFile);
        final missing = usedKeys.difference(localeKeys).toList()..sort();

        expect(
          missing,
          isEmpty,
          reason: '$localeFile is missing keys referenced by Dart code.',
        );
      }
    });
  });
}

Set<String> _messageKeys(String path) {
  final contents = File(path).readAsStringSync();
  final decoded = jsonDecode(contents) as Map<String, dynamic>;
  return decoded.keys
      .where((key) => !key.startsWith('@') && !key.startsWith('@@'))
      .toSet();
}

Iterable<File> _dartFilesToScan() sync* {
  final roots = [
    Directory('lib/app'),
    Directory('lib/core/widgets'),
    Directory('lib/features'),
  ];

  for (final root in roots) {
    if (!root.existsSync()) {
      continue;
    }
    for (final entity in root.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }
      if (entity.path.contains('/l10n/generated/')) {
        continue;
      }
      if (entity.path.contains('/features/') &&
          !entity.path.contains('/presentation/pages/')) {
        continue;
      }
      yield entity;
    }
  }
}

Iterable<String> _visibleStringLiterals(String line) sync* {
  const patterns = [
    r'''(?:const\s+)?(?:Text|SelectableText)\s*\(\s*(['"])(.*?)\1''',
    r'''SnackBar\s*\(\s*content:\s*(?:const\s+)?Text\s*\(\s*(['"])(.*?)\1''',
    r'''\b(?:title|label|hintText|labelText|tooltip|helperText|errorText)\s*:\s*(['"])(.*?)\1''',
  ];

  for (final pattern in patterns) {
    for (final match in RegExp(pattern).allMatches(line)) {
      final value = match.group(2)?.trim();
      if (value == null || value.isEmpty) {
        continue;
      }
      if (!RegExp(r'[A-Za-z]').hasMatch(value)) {
        continue;
      }
      yield value;
    }
  }
}

bool _allowedVisibleLiteral(String value) {
  const allowed = {
    'B',
    'BTC',
    'KEY',
    'NFT',
    'SOL',
    'USDC',
    'xStocks',
    'you@example.com',
  };

  return allowed.contains(value);
}

Set<String> _usedLocalizationKeys() {
  final keys = <String>{};
  final expression = RegExp(r'(?:context\.)?l10n\.([A-Za-z][A-Za-z0-9_]*)');

  for (final entity in Directory('lib').listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) {
      continue;
    }
    if (entity.path.contains('/l10n/generated/')) {
      continue;
    }
    final contents = entity.readAsStringSync();
    for (final match in expression.allMatches(contents)) {
      final key = match.group(1);
      if (key == null || key == 'localeName' || key == 'dart') {
        continue;
      }
      keys.add(key);
    }
  }

  return keys;
}
