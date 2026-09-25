import 'dart:async';

import 'package:bip39/bip39.dart' as bip39;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_client_flutter/main.dart' as app;
import 'package:wallet_client_flutter/core/chains/arc_chain_config.dart';
import 'package:wallet_client_flutter/core/chains/solana_adapter.dart';
import 'package:wallet_client_flutter/core/config/app_features.dart';
import 'package:wallet_client_flutter/core/chains/evm/evm_key_service.dart';
import 'package:wallet_client_flutter/core/crypto/local_cipher.dart';
import 'package:wallet_client_flutter/core/security/biometric_session_protector.dart';
import 'package:wallet_client_flutter/core/storage/secure_store.dart';
import 'package:wallet_client_flutter/features/auth/data/solana_wallet_service.dart';
import 'package:wallet_client_flutter/features/auth/data/wallet_repository.dart';
import 'package:wallet_client_flutter/features/auth/domain/wallet_derivation.dart';
import 'package:wallet_client_flutter/features/settings/data/app_settings_repository.dart';
import 'package:wallet_client_flutter/features/settings/domain/app_settings.dart';

// Runs only on a dedicated emulator. A fresh random, unfunded QA wallet is kept
// in the real Android secure store. Never logs/exports its recovery phrase.
// Existing unmarked wallets are refused. No transfer is signed or broadcast.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'Android real storage, PIN, Arc receive, forms and token import',
    (tester) async {
      expect(
        const bool.fromEnvironment('BENNY_EMULATOR_QA'),
        isTrue,
        reason: 'Enable BENNY_EMULATOR_QA only on the dedicated test emulator.',
      );
      const pin = '258025';
      final preferences = await SharedPreferences.getInstance();
      final repository = WalletRepository(
        SecureStore(),
        LocalCipher(),
        const BiometricSessionProtector(),
      );
      final records = await repository.readRecords();
      final String mnemonic;
      final String solanaAddress;
      if (records.isEmpty) {
        mnemonic = bip39.generateMnemonic();
        solanaAddress = await SolanaWalletService().deriveAddress(
          mnemonic,
          derivation: WalletDerivation.standard,
        );
        await repository.saveWallet(
          mnemonic: mnemonic,
          pin: pin,
          publicKey: solanaAddress,
          derivation: WalletDerivation.standard,
          biometricEnabled: false,
        );
        await preferences.setString('arc_emulator_qa_root', solanaAddress);
      } else {
        expect(records.length, 1);
        expect(
          preferences.getString('arc_emulator_qa_root'),
          records.single.publicKey,
          reason: 'Refusing to use an existing non-QA wallet.',
        );
        mnemonic = await repository.decryptMnemonic(
          pin: pin,
          record: records.single,
        );
        solanaAddress = records.single.publicKey;
      }
      final evmAddress = EvmKeyService.deriveAddress(mnemonic);
      final settings = AppSettingsRepository();
      await settings.setLanguageOption(AppLanguageOption.english);
      await settings.setNotificationsEnabled(false);
      await app.main();
      await waitFor(tester, find.text('Enter PIN'));
      for (final digit in pin.split('')) {
        await tester.tap(find.text(digit).last);
        await tester.pump(const Duration(milliseconds: 160));
      }
      await waitFor(
        tester,
        find.text('Receive'),
        timeout: const Duration(seconds: 100),
      );
      await waitFor(tester, find.byKey(const Key('portfolio-network-menu')));
      await waitFor(tester, find.textContaining('0 USDC'));
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Solana Mainnet'), findsWidgets);
      expect(
        tester.getCenter(find.text('Send')).dx,
        lessThan(tester.getCenter(find.text('Receive')).dx),
      );
      if (AppFeatures.canOpenSwap) {
        expect(
          tester.getCenter(find.text('Receive')).dx,
          lessThan(tester.getCenter(find.text('Swap')).dx),
        );
      } else {
        expect(find.text('Swap'), findsNothing);
      }
      for (final config in [SolanaAdapter.chainConfig, arcTestnetConfig]) {
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is Image &&
                widget.image is AssetImage &&
                (widget.image as AssetImage).assetName == config.iconAsset,
          ),
          findsOneWidget,
        );
      }
      await tap(tester, find.byKey(const Key('portfolio-network-menu')));
      await selectNetworkMenu(tester, 'Arc Testnet');
      expect(find.text('Solana Mainnet'), findsNothing);
      expect(find.text('Swap'), findsNothing);
      await tap(tester, find.byKey(const Key('portfolio-network-menu')));
      await selectNetworkMenu(tester, 'Solana Mainnet');
      await tap(tester, find.byKey(const Key('portfolio-network-menu')));
      await selectNetworkMenu(tester, 'All networks');
      await tap(tester, find.text('Receive').first);
      await waitFor(tester, find.text(solanaAddress));
      await tap(tester, find.byType(DropdownButtonFormField<String>));
      await tap(tester, find.text('Arc Testnet').last);
      await waitFor(tester, find.text(evmAddress));
      expect(find.text(solanaAddress), findsNothing);
      expect(
        find.text('Only receive assets on Arc Testnet at this address.'),
        findsOneWidget,
      );
      await tap(tester, find.text('Copy address'));
      await waitFor(tester, find.text('Address copied'));
      await tap(tester, find.byIcon(Icons.history_rounded));
      await waitFor(tester, find.text('Activity'));
      expect(find.text('Arc Testnet'), findsWidgets);
      await waitFor(
        tester,
        find.text('No recent transfers. Receive assets to get started.'),
        timeout: const Duration(seconds: 90),
      );
      expect(find.text('Unable to load this network'), findsNothing);
      await back(tester);
      await waitFor(tester, find.text(evmAddress));
      await back(tester);
      await waitFor(tester, find.text('Send'));
      await tap(tester, find.text('Send').first);
      expect(find.text('Send on Arc Testnet'), findsNothing);
      expect(find.text('Arc Testnet'), findsWidgets);
      await waitFor(
        tester,
        find.text('Estimate fee & review'),
        timeout: const Duration(seconds: 90),
      );
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'invalid-address',
      );
      await tester.enterText(find.byType(TextFormField).at(1), '0');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tap(tester, find.text('Estimate fee & review'));
      await waitFor(
        tester,
        find.text('Enter a valid address for this network.'),
      );
      expect(find.text('Enter an amount greater than zero.'), findsOneWidget);
      await tester.enterText(
        find.byType(TextFormField).at(0),
        '0x000000000000000000000000000000000000dEaD',
      );
      await tester.enterText(find.byType(TextFormField).at(1), '1');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tap(tester, find.text('Estimate fee & review'));
      await waitFor(tester, find.text('Insufficient asset balance.'));
      expect(find.text('Confirm & send'), findsNothing);
      await back(tester);
      await waitFor(tester, find.byTooltip('Import token'));
      await tap(tester, find.byTooltip('Import token'));
      await waitFor(tester, find.text('Look up token'));
      await tester.enterText(
        find.byType(TextField).first,
        arcTestnetConfig.nativeTokenContract!,
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tap(tester, find.text('Look up token'));
      await waitFor(tester, find.text('Import this token'));
      await tap(tester, find.text('Import this token'));
      await waitFor(tester, find.text('Token imported'));
      await waitFor(tester, find.textContaining('0 USDC'));
      expect(find.textContaining('0 USDC'), findsOneWidget);
      expect(find.text('Confirm & send'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}

Future<void> waitFor(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 30),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (finder.evaluate().isEmpty) {
    if (DateTime.now().isAfter(deadline))
      throw TimeoutException('UI not ready: $finder');
    await tester.pump(const Duration(milliseconds: 250));
  }
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> tap(WidgetTester tester, Finder finder) async {
  await waitFor(tester, finder);
  await tester.ensureVisible(finder);
  await tester.pump(const Duration(milliseconds: 150));
  await tester.tap(finder);
  await tester.pump(const Duration(milliseconds: 350));
}

Future<void> back(WidgetTester tester) async {
  await tester.pageBack();
  await tester.pump(const Duration(milliseconds: 500));
}

Future<void> selectNetworkMenu(WidgetTester tester, String label) => tap(
  tester,
  find.ancestor(
    of: find.text(label).last,
    matching: find.byType(CheckedPopupMenuItem<String>),
  ),
);
