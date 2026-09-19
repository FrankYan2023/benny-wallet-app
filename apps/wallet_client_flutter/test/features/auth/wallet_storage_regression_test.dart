import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_client_flutter/core/constants/app_constants.dart';
import 'package:wallet_client_flutter/core/crypto/local_cipher.dart';
import 'package:wallet_client_flutter/core/security/biometric_session_protector.dart';
import 'package:wallet_client_flutter/core/storage/memory_store.dart';
import 'package:wallet_client_flutter/features/auth/data/solana_wallet_service.dart';
import 'package:wallet_client_flutter/features/auth/data/wallet_repository.dart';
import 'package:wallet_client_flutter/features/auth/domain/wallet_controller_state.dart';
import 'package:wallet_client_flutter/features/auth/domain/wallet_derivation.dart';

// Public BIP39 test phrase. The fixed ciphertext below was independently made
// with Node crypto AES-256-GCM/PBKDF2-SHA256, matching the shipped storage format.
const phrase =
    'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';
const fixture = <String, Object>{
  'cipherText':
      'O3LUUO4w73YIQh/dH5Palscfm+PYjTNTt9vbp6gbwGY0ORcJH1nZhE0dRnYe+wh1iyfb9xfb17IbJ0ZT4QWbyPCJxCju7TWVYutu64C6BSrcqntT5g/I+Ivk0L65zn3XCwYqaJLUHCMRKo8sRQ==',
  'nonce': 'EBESExQVFhcYGRob',
  'salt': 'AAECAwQFBgcICQoLDA0ODw==',
  'publicKey': 'D2PPQSYFe83nDzk96FqGumVU8JA7J8vj2Rhjc2oXzEi5',
  'biometricEnabled': false,
};

void main() {
  test(
    'pre-existing encrypted mnemonic record decrypts without rewriting storage',
    () async {
      final store = MemoryStore();
      final encoded = jsonEncode([fixture]);
      await store.write(AppConstants.walletRecordsKey, encoded);
      final repository = WalletRepository(
        store,
        LocalCipher(),
        const BiometricSessionProtector(),
      );
      final record = (await repository.readRecords()).single;
      expect(record.custody, WalletCustody.localMnemonic);
      expect(record.derivation.hdPath, "m/44'/501'");
      expect(
        await repository.decryptMnemonic(pin: '123456', record: record),
        phrase,
      );
      expect(await store.read(AppConstants.walletRecordsKey), encoded);
      expect(await store.read(AppConstants.unlockedSessionMnemonicKey), isNull);
      await expectLater(
        repository.decryptMnemonic(pin: '000000', record: record),
        throwsA(anything),
      );
    },
  );

  test(
    'persisted account derivation remains attached to its ciphertext',
    () async {
      final record = StoredWalletRecord.fromJson({
        ...fixture,
        'publicKey': '7WktogJEd2wQ9eH2oWusmcoFTgeYi6rS632UviTBJ2jm',
        'derivation': {'accountIndex': 2, 'changeIndex': 0},
      });
      final restored = StoredWalletRecord.fromJson(record.toJson());
      expect(restored.cipherText, fixture['cipherText']);
      expect(restored.derivation.hdPath, "m/44'/501'/2'/0'");
      expect(
        await SolanaWalletService().deriveAddress(
          phrase,
          derivation: restored.derivation,
        ),
        restored.publicKey,
      );
    },
  );

  test(
    'external custody cannot expose its encrypted PIN marker as mnemonic',
    () async {
      final repository = WalletRepository(
        MemoryStore(),
        LocalCipher(),
        const BiometricSessionProtector(),
      );
      for (final custody in [
        WalletCustody.mobileWalletAdapter,
        WalletCustody.seedVault,
      ]) {
        final record = StoredWalletRecord.fromJson({
          ...fixture,
          'custody': custody.name,
        });
        expect(
          () => repository.decryptMnemonic(pin: '123456', record: record),
          throwsStateError,
        );
      }
    },
  );

  test(
    'legacy standard and imported Solana addresses match independent SLIP-0010 vectors',
    () async {
      // Independently checked with Node crypto PBKDF2/HMAC-SHA512/Ed25519.
      final service = SolanaWalletService();
      expect(await service.deriveAddress(phrase), fixture['publicKey']);
      expect(
        await service.deriveAddress(
          phrase,
          derivation: WalletDerivation.standard,
        ),
        'HAgk14JpMQLgt6rVgv7cBQFJWFto5Dqxi472uT3DKpqk',
      );
      expect(
        await service.deriveAddress(
          phrase,
          derivation: const WalletDerivation(accountIndex: 2, changeIndex: 0),
        ),
        '7WktogJEd2wQ9eH2oWusmcoFTgeYi6rS632UviTBJ2jm',
      );
    },
  );
}
