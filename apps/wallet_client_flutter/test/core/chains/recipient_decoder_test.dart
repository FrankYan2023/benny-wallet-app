import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_client_flutter/core/chains/arc_chain_config.dart';
import 'package:wallet_client_flutter/core/chains/recipient_decoder.dart';
import 'package:wallet_client_flutter/core/chains/solana_adapter.dart';
import 'evm_adapter_test.dart' as fixture;

void main() {
  final adapter = fixture.adapterFor(fixture.FakeRpc());
  String? evm(String raw) =>
      decodeRecipient(raw, arcTestnetConfig, adapter.validateAddress);
  test('EVM QR accepts only recipient and matching explicit network', () {
    expect(evm(fixture.recipient), fixture.recipient);
    expect(
      evm('ethereum:${fixture.recipient}@${arcTestnetConfig.chainId}'),
      fixture.recipient,
    );
    expect(evm('ethereum:${fixture.recipient}?value=1'), fixture.recipient);
    expect(evm('ethereum:${fixture.recipient}@1'), isNull);
    expect(evm('ethereum:${fixture.recipient}@5042'), isNull);
  });
  test(
    'EVM QR rejects token-transfer targets and arbitrary embedded addresses',
    () {
      expect(
        evm(
          'ethereum:${fixture.recipient}@${arcTestnetConfig.chainId}/transfer?address=${fixture.address}',
        ),
        isNull,
      );
      expect(evm('https://example.com/${fixture.recipient}'), isNull);
      expect(evm('send to ${fixture.recipient}'), isNull);
      expect(evm('0x0000000000000000000000000000000000000000'), isNull);
      expect(
        evm('solana:HAgk14JpMQLgt6rVgv7cBQFJWFto5Dqxi472uT3DKpqk'),
        isNull,
      );
    },
  );
  test('existing Solana raw and payment QR extraction remains compatible', () {
    const address = 'HAgk14JpMQLgt6rVgv7cBQFJWFto5Dqxi472uT3DKpqk';
    String? solana(String raw) =>
        decodeRecipient(raw, SolanaAdapter.chainConfig, (_) => false);
    expect(solana(address), address);
    expect(solana('solana:$address?amount=1'), address);
    expect(solana('https://example.com/$address'), address);
    expect(solana('receive $address'), address);
    expect(solana(fixture.recipient), isNull);
  });
}
