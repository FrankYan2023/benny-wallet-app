import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wallet_client_flutter/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  const mnemonic = String.fromEnvironment('ANDROID_QA_IMPORT_MNEMONIC');
  const expectedWalletAddress = String.fromEnvironment(
    'ANDROID_QA_EXPECTED_WALLET_ADDRESS',
  );
  const recipientAddress = String.fromEnvironment(
    'ANDROID_QA_RECIPIENT_ADDRESS',
  );
  const pin = String.fromEnvironment('ANDROID_QA_PIN', defaultValue: '258025');
  const tokenName = String.fromEnvironment(
    'ANDROID_QA_SEND_TOKEN_NAME',
    defaultValue: 'Benny Coin',
  );
  const tokenSymbol = String.fromEnvironment(
    'ANDROID_QA_SEND_TOKEN_SYMBOL',
    defaultValue: 'BYC',
  );
  const tokenAmount = String.fromEnvironment(
    'ANDROID_QA_SEND_TOKEN_AMOUNT',
    defaultValue: '100',
  );
  const swapTokenSymbol = String.fromEnvironment(
    'ANDROID_QA_SWAP_TOKEN_SYMBOL',
    defaultValue: 'SOL',
  );
  const swapAmount = String.fromEnvironment(
    'ANDROID_QA_SWAP_AMOUNT',
    defaultValue: '0.0001',
  );

  testWidgets('QA full import wallet, history screens, send BYC, and swap', (
    tester,
  ) async {
    _require(mnemonic.isNotEmpty, 'ANDROID_QA_IMPORT_MNEMONIC is required.');
    _require(
      expectedWalletAddress.isNotEmpty,
      'ANDROID_QA_EXPECTED_WALLET_ADDRESS is required.',
    );
    _require(
      recipientAddress.isNotEmpty,
      'ANDROID_QA_RECIPIENT_ADDRESS is required.',
    );
    _require(pin.length == 6, 'ANDROID_QA_PIN must be 6 digits.');

    await app.main();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    await _waitForAny(tester, [
      find.text('Import wallet'),
      find.text('Benny'),
      find.text('Set Benny PIN'),
    ]);
    await tester.pump(const Duration(seconds: 2));

    if (find.text('Benny').evaluate().isEmpty) {
      await _tapVisible(
        tester,
        find
            .ancestor(
              of: find.text('Import wallet'),
              matching: find.byType(InkWell),
            )
            .last,
      );
      await _waitFor(tester, find.text('Import recovery phrase'));

      await tester.enterText(find.byType(TextField).first, mnemonic);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump(const Duration(milliseconds: 500));
      await _tapVisible(tester, find.text('Continue').last);

      await _waitForAny(tester, [
        find.text('Solana Mainnet'),
        find.text('Unable to scan this recovery phrase right now.'),
      ], timeout: const Duration(seconds: 90));
      expect(
        find.text('Unable to scan this recovery phrase right now.'),
        findsNothing,
      );

      final expectedCompact = _compactAddress(expectedWalletAddress, 6);
      await _waitForAny(tester, [
        find.text(expectedCompact),
        find.text('Active account'),
        find.text('Default main wallet'),
      ], timeout: const Duration(seconds: 90));
      await _scrollUntilMaybeVisible(tester, find.text(expectedCompact));
      if (find.text(expectedCompact).evaluate().isNotEmpty) {
        await _tapVisible(tester, find.text(expectedCompact));
      }
      await _tapVisible(tester, find.text('Continue').last);

      await _waitFor(tester, find.text('Set Benny PIN'));
      await _enterPin(tester, pin);
      await _waitFor(tester, find.text('Confirm PIN'));
      await _enterPin(tester, pin);
    }

    await _waitFor(
      tester,
      find.text('Benny'),
      timeout: const Duration(seconds: 90),
    );
    await _waitFor(
      tester,
      find.text('Send'),
      timeout: const Duration(seconds: 90),
    );
    await _waitFor(tester, find.text('Receive'));

    await _tapVisible(tester, find.text('Receive'));
    await _waitFor(tester, find.text('Share this address'));
    expect(find.text(expectedWalletAddress), findsOneWidget);

    await _tapVisible(tester, find.byTooltip('Received history'));
    await _waitFor(tester, find.text('Received history'));
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            (widget.data?.contains('No received history yet.') == true ||
                widget.data?.contains('You received') == true ||
                widget.data?.contains('Unable to load received history') ==
                    true),
      ),
      findsWidgets,
    );
    await tester.pageBack();
    await _waitFor(tester, find.text('Share this address'));
    await tester.pageBack();

    await _waitFor(tester, find.text('Benny'));
    await _tapVisible(tester, find.text('Send'));
    await _waitFor(tester, find.text('Choose asset'));

    await _tapVisible(tester, find.byTooltip('Send history'));
    await _waitFor(tester, find.text('Send history'));
    await tester.pageBack();

    await _waitFor(tester, find.text('Choose asset'));
    await _scrollUntilMaybeVisible(tester, find.text(tokenName));
    if (find.text(tokenName).evaluate().isNotEmpty) {
      await _tapVisible(tester, find.text(tokenName));
    } else {
      await _scrollUntilMaybeVisible(tester, find.text(tokenSymbol));
      await _tapVisible(tester, find.text(tokenSymbol).first);
    }

    await _waitFor(tester, find.text('Send $tokenSymbol'));
    final fields = find.byType(TextField);
    expect(fields, findsNWidgets(2));
    await tester.enterText(fields.at(0), recipientAddress);
    await tester.pump(const Duration(milliseconds: 250));
    await tester.enterText(fields.at(1), tokenAmount);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump(const Duration(milliseconds: 250));
    await _tapVisible(tester, find.text('Next'));

    await _waitForAny(tester, [
      find.text('Confirm send'),
      find.text('Enter a valid Solana address.'),
      find.text('Insufficient balance.'),
      find.text('Not enough SOL to cover the network fee.'),
    ], timeout: const Duration(seconds: 90));
    expect(find.text('Enter a valid Solana address.'), findsNothing);
    expect(find.text('Insufficient balance.'), findsNothing);
    expect(find.text('Not enough SOL to cover the network fee.'), findsNothing);

    await _tapVisible(tester, find.text('Send'));
    await _waitForAny(tester, [
      find.text('Submitted'),
      find.text('Send failed'),
    ], timeout: const Duration(seconds: 180));
    expect(find.text('Send failed'), findsNothing);
    expect(find.text('Submitted'), findsOneWidget);

    await _tapVisible(tester, find.text('Close'));
    await _waitFor(
      tester,
      find.text('Benny'),
      timeout: const Duration(seconds: 90),
    );
    await _waitFor(
      tester,
      find.text('Swap'),
      timeout: const Duration(seconds: 90),
    );
    await _tapVisible(tester, find.text('Swap'));
    await _waitFor(
      tester,
      find.byKey(const ValueKey('androidQaSwapPayToken')),
      timeout: const Duration(seconds: 90),
    );

    await _selectSwapInputToken(tester, swapTokenSymbol);
    await _enterSwapAmount(tester, swapAmount);
    await _tapEnabledButtonWithText(
      tester,
      'Swap',
      timeout: const Duration(seconds: 120),
    );

    await _waitForAny(tester, [
      find.text('Swapping...'),
      find.text('Swap complete'),
      find.text('Swap failed'),
      find.text('Enter a valid amount.'),
      find.text('Insufficient balance.'),
      find.text('This amount is too small for a valid route.'),
      find.text('Wait for a valid quote before continuing.'),
      find.text('Not enough token balance. Tap Max again and retry.'),
      find.textContaining('Not enough SOL'),
    ], timeout: const Duration(seconds: 180));
    if (find.text('Swapping...').evaluate().isNotEmpty) {
      await _waitForAny(tester, [
        find.text('Swap complete'),
        find.text('Swap failed'),
      ], timeout: const Duration(seconds: 180));
    }
    expect(find.text('Swap failed'), findsNothing);
    expect(find.text('Enter a valid amount.'), findsNothing);
    expect(find.text('Insufficient balance.'), findsNothing);
    expect(
      find.text('This amount is too small for a valid route.'),
      findsNothing,
    );
    expect(
      find.text('Wait for a valid quote before continuing.'),
      findsNothing,
    );
    expect(
      find.text('Not enough token balance. Tap Max again and retry.'),
      findsNothing,
    );
    expect(find.textContaining('Not enough SOL'), findsNothing);
    expect(find.text('Swap complete'), findsOneWidget);
  });
}

Future<void> _selectSwapInputToken(
  WidgetTester tester,
  String tokenSymbol,
) async {
  await _tapVisible(
    tester,
    find.byKey(const ValueKey('androidQaSwapPayToken')),
  );
  await _waitFor(tester, find.text('Pay with'));

  await tester.enterText(find.byType(TextField).first, tokenSymbol);
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pump(const Duration(milliseconds: 750));
  await _waitFor(tester, find.text(tokenSymbol));

  await _tapVisible(
    tester,
    find
        .ancestor(
          of: find.text(tokenSymbol).last,
          matching: find.byType(InkWell),
        )
        .last,
  );
  await _waitFor(tester, find.byKey(const ValueKey('androidQaSwapPayAmount')));
}

Future<void> _enterSwapAmount(WidgetTester tester, String amount) async {
  _require(amount.isNotEmpty, 'ANDROID_QA_SWAP_AMOUNT must not be empty.');
  await _tapVisible(
    tester,
    find.byKey(const ValueKey('androidQaSwapPayAmount')),
  );
  await _waitFor(tester, find.text('Done'));

  for (final character in amount.split('')) {
    await _tapVisible(tester, find.text(character).last);
    await tester.pump(const Duration(milliseconds: 80));
  }

  await _tapVisible(tester, find.text('Done'));
  await _waitFor(tester, find.byKey(const ValueKey('androidQaSwapPayAmount')));
}

Future<void> _tapEnabledButtonWithText(
  WidgetTester tester,
  String label, {
  Duration timeout = const Duration(seconds: 45),
}) async {
  final deadline = DateTime.now().add(timeout);
  final finder = find.widgetWithText(FilledButton, label);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 500));
    final elements = finder.evaluate().toList(growable: false);
    for (var i = 0; i < elements.length; i++) {
      final widget = elements[i].widget;
      if (widget is FilledButton && widget.onPressed != null) {
        final candidate = finder.at(i);
        await tester.ensureVisible(candidate);
        await tester.tap(candidate);
        await tester.pump(const Duration(milliseconds: 350));
        return;
      }
    }
  }
  fail('Timed out waiting for enabled $label button');
}

Future<void> _enterPin(WidgetTester tester, String pin) async {
  for (final digit in pin.split('')) {
    await _tapVisible(tester, find.text(digit).first);
    await tester.pump(const Duration(milliseconds: 120));
  }
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await _waitFor(tester, finder);
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pump(const Duration(milliseconds: 350));
}

Future<void> _scrollUntilMaybeVisible(
  WidgetTester tester,
  Finder finder,
) async {
  if (finder.evaluate().isNotEmpty) {
    return;
  }
  final scrollables = find.byType(Scrollable);
  if (scrollables.evaluate().isEmpty) {
    return;
  }
  final scrollable = scrollables.last;
  for (var i = 0; i < 12 && finder.evaluate().isEmpty; i++) {
    await tester.drag(scrollable, const Offset(0, -320));
    await tester.pump(const Duration(milliseconds: 250));
  }
}

Future<void> _waitFor(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 45),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 500));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }
  fail('Timed out waiting for $finder');
}

Future<void> _waitForAny(
  WidgetTester tester,
  List<Finder> finders, {
  Duration timeout = const Duration(seconds: 45),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 500));
    if (finders.any((finder) => finder.evaluate().isNotEmpty)) {
      return;
    }
  }
  fail('Timed out waiting for any of ${finders.join(', ')}');
}

String _compactAddress(String value, int visibleChars) {
  if (value.length <= 10) {
    return value;
  }
  return '${value.substring(0, visibleChars)}...'
      '${value.substring(value.length - visibleChars)}';
}

void _require(bool condition, String message) {
  if (!condition) {
    throw StateError(message);
  }
}
