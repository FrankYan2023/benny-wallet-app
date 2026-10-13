abstract final class Formatters {
  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static const _subscriptDigits = {
    '0': '₀',
    '1': '₁',
    '2': '₂',
    '3': '₃',
    '4': '₄',
    '5': '₅',
    '6': '₆',
    '7': '₇',
    '8': '₈',
    '9': '₉',
  };

  static String address(String value) {
    return compactAddress(value);
  }

  static String compactAddress(String value, {int visibleChars = 4}) {
    if (value.length <= 10) {
      return value;
    }
    return '${value.substring(0, visibleChars)}...${value.substring(value.length - visibleChars)}';
  }

  static String tokenSymbol(String value) {
    if (value.length <= 10) {
      return value;
    }
    return address(value);
  }

  static String amount(double value, {int maxDecimals = 6}) {
    var text = value.toStringAsFixed(maxDecimals);
    text = text.replaceFirst(RegExp(r'\.?0+$'), '');
    return text;
  }

  static String compactNumber(double? value) {
    if (value == null || !value.isFinite) {
      return '--';
    }

    final abs = value.abs();
    final sign = value < 0 ? '-' : '';
    if (abs >= 1e12) {
      return '$sign${_trim((abs / 1e12).toStringAsFixed(2))}T';
    }
    if (abs >= 1e9) {
      return '$sign${_trim((abs / 1e9).toStringAsFixed(2))}B';
    }
    if (abs >= 1e6) {
      return '$sign${_trim((abs / 1e6).toStringAsFixed(2))}M';
    }
    if (abs >= 1e3) {
      return '$sign${_trim((abs / 1e3).toStringAsFixed(2))}K';
    }
    return '$sign${amount(abs, maxDecimals: abs >= 1 ? 2 : 6)}';
  }

  static String usd(double value) => usdPrice(value);

  static String compactUsd(double? value) {
    if (value == null || !value.isFinite) {
      return '--';
    }

    final abs = value.abs();
    if (abs < 1000) {
      return signedUsd(value, includePositiveSign: false);
    }

    final sign = value < 0 ? '-' : '';
    return '$sign\$${compactNumber(abs)}';
  }

  static String usdPrice(double value) {
    if (value <= 0 || !value.isFinite) {
      return '\$0.00';
    }

    if (value >= 1) {
      return '\$${value.toStringAsFixed(2)}';
    }

    if (value >= 0.01) {
      var text = value.toStringAsFixed(4);
      text = text.replaceFirst(RegExp(r'0+$'), '');
      text = text.replaceFirst(RegExp(r'\.$'), '');
      return '\$$text';
    }

    final fixed = value.toStringAsFixed(16);
    final parts = fixed.split('.');
    final decimals = parts.length > 1 ? parts[1] : '';
    final firstNonZeroIndex = decimals.indexOf(RegExp(r'[1-9]'));
    if (firstNonZeroIndex <= 2) {
      var text = value.toStringAsFixed(6);
      text = text.replaceFirst(RegExp(r'0+$'), '');
      text = text.replaceFirst(RegExp(r'\.$'), '');
      return '\$$text';
    }

    final zeroCount = firstNonZeroIndex;
    final significantSource = decimals
        .substring(firstNonZeroIndex)
        .replaceFirst(RegExp(r'0+$'), '');
    final padded = significantSource.padRight(2, '0');
    final take = padded.length < 4 ? padded.length : 4;
    final significant = padded.substring(0, take);
    return '\$0.0${_toSubscript(zeroCount)}$significant';
  }

  static String signedUsd(double? value, {bool includePositiveSign = true}) {
    if (value == null || !value.isFinite) {
      return '--';
    }

    final prefix = value < 0
        ? '-'
        : includePositiveSign && value > 0
            ? '+'
            : '';
    return '$prefix${usdPrice(value.abs())}';
  }

  static String percent(double? value, {bool signed = false}) {
    if (value == null || !value.isFinite) {
      return '--';
    }

    final prefix = signed
        ? value > 0
            ? '+'
            : value < 0
                ? '-'
                : ''
        : '';
    return '$prefix${value.abs().toStringAsFixed(2)}%';
  }

  static String date(DateTime? value) {
    if (value == null) {
      return '--';
    }
    final month = _months[value.month - 1];
    return '$month ${value.day}, ${value.year}';
  }

  static String _toSubscript(int value) {
    return value
        .toString()
        .split('')
        .map((digit) => _subscriptDigits[digit] ?? digit)
        .join();
  }

  static String relativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 60) {
      return '${diff.inSeconds}s ago';
    }
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    }
    return '${diff.inDays}d ago';
  }

  static String _trim(String value) {
    return value.replaceFirst(RegExp(r'\.?0+$'), '');
  }
}
