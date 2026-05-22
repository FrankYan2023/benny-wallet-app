import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_client_flutter/core/utils/amount_parser.dart';

void main() {
  group('AmountParser', () {
    test('accepts dot decimal input', () {
      expect(AmountParser.parse('0.25'), 0.25);
    });

    test('accepts comma decimal input from localized keyboards', () {
      expect(AmountParser.parse('0,25'), 0.25);
    });

    test('accepts grouped pasted values with dot decimals', () {
      expect(AmountParser.parse('1,234.56'), 1234.56);
    });

    test('accepts grouped pasted values with comma decimals', () {
      expect(AmountParser.parse('1.234,56'), 1234.56);
    });

    test('rejects invalid input', () {
      expect(AmountParser.parse('abc'), isNull);
    });

    test('converts decimal input to raw units without rounding up', () {
      expect(AmountParser.toRawUnits('0.0000019', 6), BigInt.one);
      expect(
        AmountParser.toRawUnits('1.234567891', 9),
        BigInt.from(1234567891),
      );
    });

    test('formats raw units with full token precision', () {
      expect(AmountParser.formatRawUnits(BigInt.from(19), 7), '0.0000019');
      expect(
        AmountParser.formatRawUnits(BigInt.from(1234567891), 9),
        '1.234567891',
      );
    });
  });
}
