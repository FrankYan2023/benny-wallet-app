import 'dart:async';
import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solana/base58.dart';
import 'package:wallet_client_flutter/core/chains/solana_message_signer.dart';
import 'package:wallet_client_flutter/features/auth/domain/wallet_derivation.dart';

// Public BIP39/storage fixture only. Never fund this phrase.
const phrase =
    'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';
const owner = 'D2PPQSYFe83nDzk96FqGumVU8JA7J8vj2Rhjc2oXzEi5';
void main() {
  test(
    'background Solana authentication preserves legacy owner and main event loop',
    () async {
      var heartbeat = false;
      final timer = Timer(Duration.zero, () => heartbeat = true);
      addTearDown(timer.cancel);
      final signature = await SolanaMessageSigner.sign(
        mnemonic: phrase,
        derivation: WalletDerivation.legacy,
        expectedOwner: owner,
        message: 'public fixture challenge',
      );
      expect(heartbeat, true);
      expect(
        await Ed25519().verify(
          utf8.encode('public fixture challenge'),
          signature: Signature(
            base58decode(signature),
            publicKey: SimplePublicKey(
              base58decode(owner),
              type: KeyPairType.ed25519,
            ),
          ),
        ),
        true,
      );
    },
  );
  test(
    'background Solana authentication rejects another owner or derivation',
    () async {
      for (final derivation in [
        WalletDerivation.standard,
        const WalletDerivation(accountIndex: 1, changeIndex: 0),
      ]) {
        await expectLater(
          SolanaMessageSigner.sign(
            mnemonic: phrase,
            derivation: derivation,
            expectedOwner: owner,
            message: 'public fixture challenge',
          ),
          throwsStateError,
        );
      }
    },
  );
}
