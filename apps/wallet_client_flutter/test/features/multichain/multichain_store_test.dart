import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_client_flutter/core/chains/chain_models.dart';
import 'package:wallet_client_flutter/core/storage/memory_store.dart';
import 'package:wallet_client_flutter/features/multichain/data/multichain_store.dart';

void main() {
  const account = ChainAccount(
    rootWalletId: 'root',
    chainId: 'arc-testnet',
    address: '0xAbc',
  );
  ChainAsset token(String address) => ChainAsset(
    chainId: 'arc-testnet',
    symbol: 'BENNY',
    name: 'Benny',
    decimals: 18,
    rawBalance: BigInt.zero,
    contractAddress: address,
  );
  test(
    'concurrent imports preserve both tokens and never rewrite old wallet data',
    () async {
      final storage = MemoryStore();
      await storage.write('wallet_records_v1', 'encrypted-existing-record');
      final store = MultichainStore(storage);
      await Future.wait([
        store.saveToken(account, token('0xAA')),
        store.saveToken(account, token('0xBB')),
      ]);
      expect((await store.tokens(account)).length, 2);
      await store.saveToken(account, token('0xaa'));
      expect((await store.tokens(account)).length, 2);
      expect(
        await storage.read('wallet_records_v1'),
        'encrypted-existing-record',
      );
    },
  );
  test('token lists are scoped to network and address', () async {
    final store = MultichainStore(MemoryStore());
    await store.saveToken(account, token('0xAA'));
    expect(
      await store.tokens(
        const ChainAccount(
          rootWalletId: 'root',
          chainId: 'arc-mainnet',
          address: '0xAbc',
        ),
      ),
      isEmpty,
    );
    expect(
      await store.tokens(
        const ChainAccount(
          rootWalletId: 'other',
          chainId: 'arc-testnet',
          address: '0xDef',
        ),
      ),
      isEmpty,
    );
    await expectLater(
      store.saveToken(
        const ChainAccount(
          rootWalletId: 'root',
          chainId: 'arc-mainnet',
          address: '0xAbc',
        ),
        token('0xAA'),
      ),
      throwsStateError,
    );
  });
  test('Solana mint IDs remain case-sensitive', () {
    final first = ChainAsset(
      chainId: 'solana-mainnet',
      symbol: 'T',
      name: 'Token',
      decimals: 9,
      rawBalance: BigInt.zero,
      contractAddress: 'AbC',
    );
    final second = ChainAsset(
      chainId: 'solana-mainnet',
      symbol: 'T',
      name: 'Token',
      decimals: 9,
      rawBalance: BigInt.zero,
      contractAddress: 'abc',
    );
    expect(first.id, isNot(second.id));
  });
  test(
    'base units round-trip at large amounts without floating-point loss',
    () {
      const amount = '12345678901234567890.123456';
      expect(formatUnits(parseUnits(amount, 6), 6), amount);
      expect(() => parseUnits('1.0000001', 6), throwsFormatException);
      expect(() => parseUnits('1e18', 18), throwsFormatException);
      expect(formatUnits(BigInt.one, 18), '0.000000000000000001');
    },
  );
}
