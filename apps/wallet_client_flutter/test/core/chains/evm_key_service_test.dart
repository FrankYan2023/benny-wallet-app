import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:web3dart/crypto.dart';
import 'package:wallet_client_flutter/core/chains/evm/evm_key_service.dart';

// Public Hardhat fixture and independent ethers vectors already used in the
// adapter suite. Never fund this phrase or expose an actual wallet to tests.
const phrase = 'test test test test test test test test test test test junk';
const address = '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266';
const expectedSignature =
    '0x12d910701d4d766791f223c9709187bfe9b9288a3c88f956515201618ccd67741e01f3c3d7398f172f9b8f5b13865bd46ddd990a8f9927105ed9c87dd1df4eda1b';

void main() {
  test(
    'background EVM derivation preserves address and rejects invalid roots',
    () async {
      expect(await EvmKeyService.deriveAddressAsync(phrase), address);
      await expectLater(
        EvmKeyService.deriveAddressAsync('not a recovery phrase'),
        throwsFormatException,
      );
    },
  );

  test(
    'background personal signing matches independent ethers vector',
    () async {
      final signature = await EvmKeyService.signPersonalMessageAsync(
        phrase,
        Uint8List.fromList(utf8.encode('hello Benny')),
        expectedAddress: address.toLowerCase(),
      );
      expect(bytesToHex(signature, include0x: true), expectedSignature);
    },
  );

  test('background personal signing rejects a mismatched account', () async {
    await expectLater(
      EvmKeyService.signPersonalMessageAsync(
        phrase,
        Uint8List.fromList(utf8.encode('hello Benny')),
        expectedAddress: '0x000000000000000000000000000000000000dEaD',
      ),
      throwsStateError,
    );
  });

  test('background personal signing snapshots mutable message bytes', () async {
    final message = Uint8List.fromList(utf8.encode('hello Benny'));
    final pending = EvmKeyService.signPersonalMessageAsync(
      phrase,
      message,
      expectedAddress: address,
    );
    message.fillRange(0, message.length, 0);
    expect(bytesToHex(await pending, include0x: true), expectedSignature);
  });

  test(
    'background EVM derivation keeps the main event loop responsive',
    () async {
      var mainLoopRan = false;
      final heartbeat = Timer(Duration.zero, () => mainLoopRan = true);
      try {
        expect(await EvmKeyService.deriveAddressAsync(phrase), address);
        expect(mainLoopRan, isTrue);
      } finally {
        heartbeat.cancel();
      }
    },
  );
}
