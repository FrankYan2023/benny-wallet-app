abstract final class AmountParser {
  static double? parse(String input) {
    final normalized = normalize(input);
    if (normalized == null) {
      return null;
    }

    final value = double.tryParse(normalized);
    if (value == null || !value.isFinite) {
      return null;
    }
    return value;
  }

  static String? normalize(String input) {
    var text = input
        .trim()
        .replaceAll('\u00A0', '')
        .replaceAll('\u202F', '')
        .replaceAll(' ', '');
    if (text.isEmpty) {
      return null;
    }

    final lastComma = text.lastIndexOf(',');
    final lastDot = text.lastIndexOf('.');
    if (lastComma >= 0 && lastDot >= 0) {
      final commaIsDecimal = lastComma > lastDot;
      text = commaIsDecimal
          ? text.replaceAll('.', '').replaceAll(',', '.')
          : text.replaceAll(',', '');
    } else if (lastComma >= 0) {
      text = text.replaceAll(',', '.');
    }

    return text;
  }

  static BigInt? toRawUnits(String input, int decimals) {
    final normalized = normalize(input);
    if (normalized == null || decimals < 0) {
      return null;
    }

    var text = normalized;
    if (text.startsWith('+')) {
      text = text.substring(1);
    }
    if (text.startsWith('-')) {
      return null;
    }

    final parts = text.split('.');
    if (parts.length > 2) {
      return null;
    }

    final whole = parts[0].isEmpty ? '0' : parts[0];
    final fraction = parts.length == 2 ? parts[1] : '';
    final digitsOnly = RegExp(r'^\d+$');
    if (!digitsOnly.hasMatch(whole) ||
        (fraction.isNotEmpty && !digitsOnly.hasMatch(fraction))) {
      return null;
    }

    final scaledFraction = decimals == 0
        ? ''
        : fraction.padRight(decimals, '0').substring(0, decimals);
    final rawText = '$whole$scaledFraction'.replaceFirst(RegExp(r'^0+'), '');
    return BigInt.parse(rawText.isEmpty ? '0' : rawText);
  }

  static String formatRawUnits(BigInt rawAmount, int decimals) {
    if (decimals <= 0) {
      return rawAmount.toString();
    }

    final negative = rawAmount < BigInt.zero;
    final absolute = negative ? -rawAmount : rawAmount;
    final scale = BigInt.from(10).pow(decimals);
    final whole = absolute ~/ scale;
    final fraction = (absolute % scale).toString().padLeft(decimals, '0');
    final trimmedFraction = fraction.replaceFirst(RegExp(r'0+$'), '');
    final sign = negative ? '-' : '';
    if (trimmedFraction.isEmpty) {
      return '$sign$whole';
    }
    return '$sign$whole.$trimmedFraction';
  }
}
