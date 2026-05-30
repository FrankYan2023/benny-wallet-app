import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_client_flutter/core/constants/app_constants.dart';

void main() {
  test('default API configuration uses the production backend', () {
    expect(AppConstants.apiBaseUrl, AppConstants.productionApiBaseUrl);
    expect(AppConstants.apiBaseUrl, isNot(contains('example.invalid')));
  });
}
