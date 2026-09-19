import 'package:flutter_test/flutter_test.dart';
import 'package:shared_types/shared_types.dart';
import 'package:solana/encoder.dart';
import 'package:solana/solana.dart';
import 'package:wallet_client_flutter/core/chains/chain_models.dart';
import 'package:wallet_client_flutter/core/chains/solana_adapter.dart';
import 'package:wallet_client_flutter/features/auth/data/solana_wallet_service.dart';
import 'package:wallet_client_flutter/features/auth/domain/wallet_derivation.dart';

const owner = 'HAgk14JpMQLgt6rVgv7cBQFJWFto5Dqxi472uT3DKpqk';
const recipient = '7WktogJEd2wQ9eH2oWusmcoFTgeYi6rS632UviTBJ2jm';
const account = ChainAccount(
  rootWalletId: owner,
  chainId: SolanaAdapter.networkId,
  address: owner,
);
const token = TokenInfo(
  mintAddress: 'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v',
  symbol: 'USDC',
  name: 'USD Coin',
  decimals: 6,
  isNative: false,
  isVisible: true,
);
const phrase =
    'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';

void main() {
  late _Service service;
  late SolanaAdapter adapter;
  setUp(() {
    service = _Service();
    adapter = SolanaAdapter(
      service: service,
      accountReader: () async => account,
      mnemonicReader: () async => phrase,
      derivationReader: () => WalletDerivation.standard,
    );
  });

  test('validates base58 addresses and rejects EVM addresses', () {
    expect(adapter.validateAddress(owner), isTrue);
    expect(
      adapter.validateAddress('0x0000000000000000000000000000000000000001'),
      isFalse,
    );
    expect(adapter.validateAddress('111'), isFalse);
  });

  test('aggregates token accounts using exact base units', () async {
    service.snapshots = [
      AssetBalanceSnapshot(
        token: token,
        balance: 0,
        rawAmount: '9007199254740993',
        existsOnChain: true,
      ),
      AssetBalanceSnapshot(
        token: token,
        balance: 0,
        rawAmount: '17',
        existsOnChain: true,
      ),
    ];
    final assets = await adapter.getAssets(account);
    expect(assets.where((asset) => asset.isNative).single.balanceText, '0');
    expect(
      assets.where((asset) => !asset.isNative).single.rawBalance,
      BigInt.parse('9007199254741010'),
    );
  });

  test('fee estimate retains exact Sender budget and destination', () async {
    service.fee = 9007199254740993;
    final fee = await adapter.estimateFee(_request(BigInt.from(1)));
    expect(fee.maxFee, BigInt.parse('9007199254740993'));
    expect(fee.symbol, 'SOL');
    expect(service.lastDestination, recipient);
  });

  test('native send reserves network fee and rent before building', () async {
    service.solBalance = 1000000000;
    service.rent = 890880;
    service.fee = 255000;
    await expectLater(
      adapter.buildTransaction(_request(BigInt.from(999000000))),
      throwsStateError,
    );
    expect(service.buildCount, 0);
    final transfer = await adapter.buildTransaction(
      _request(BigInt.from(998000000)),
    );
    expect(transfer.fee.maxFee, BigInt.from(255000));
    expect(service.buildCount, 1);
  });

  test('external custody does not invoke mnemonic reader', () async {
    var mnemonicReads = 0;
    const external = ChainAccount(
      rootWalletId: owner,
      chainId: SolanaAdapter.networkId,
      address: owner,
      canSign: false,
    );
    final externalAdapter = SolanaAdapter(
      service: service,
      accountReader: () async => external,
      mnemonicReader: () async {
        mnemonicReads++;
        return phrase;
      },
      derivationReader: () => WalletDerivation.standard,
    );
    final prepared = await externalAdapter.buildTransaction(
      _request(BigInt.one, external),
    );
    await expectLater(
      externalAdapter.signTransaction(prepared),
      throwsUnsupportedError,
    );
    expect(mnemonicReads, 0);
  });

  test(
    'signs the reviewed transfer and preserves Sender submission metadata',
    () async {
      final prepared = await adapter.buildTransaction(
        _request(BigInt.from(1000000)),
      );
      final signed = await adapter.signTransaction(prepared);
      final decoded = SignedTx.decode(signed.encoded);
      expect(
        await verifySignature(
          message: decoded.compiledMessage.toByteArray().toList(),
          signature: decoded.signatures.single.bytes.toList(),
          publicKey: Ed25519HDPublicKey.fromBase58(owner),
        ),
        isTrue,
      );
      expect(await adapter.broadcastTransaction(signed), 'submitted-signature');
      expect(service.submittedMint, SolanaAdapter.nativeMint);
      expect(service.submittedAmount, '0.001 SOL');
      expect(service.submittedDestination, recipient);
    },
  );

  test(
    'does not sign a prepared payload attached to a changed request',
    () async {
      final prepared = await adapter.buildTransaction(
        _request(BigInt.from(1000000)),
      );
      final altered = PreparedChainTransaction(
        request: _request(BigInt.from(2000000)),
        fee: prepared.fee,
        payload: prepared.payload,
      );
      await expectLater(adapter.signTransaction(altered), throwsStateError);
    },
  );

  test('cross-network and negative requests are rejected before RPC', () async {
    const wrongAccount = ChainAccount(
      rootWalletId: owner,
      chainId: 'arc-testnet',
      address: owner,
    );
    await expectLater(
      adapter.estimateFee(_request(BigInt.one, wrongAccount)),
      throwsArgumentError,
    );
    await expectLater(
      adapter.estimateFee(_request(-BigInt.one)),
      throwsArgumentError,
    );
    expect(service.lastDestination, isNull);
  });
}

ChainTransferRequest _request(
  BigInt amount, [
  ChainAccount selected = account,
]) => ChainTransferRequest(
  account: selected,
  asset: SolanaAdapter.nativeAsset,
  to: recipient,
  amount: amount,
);

class _Service extends SolanaWalletService {
  List<AssetBalanceSnapshot> snapshots = [];
  int solBalance = 1000000000;
  int rent = 890880;
  int fee = 255000;
  int buildCount = 0;
  String? lastDestination;
  String? submittedMint;
  String? submittedAmount;
  String? submittedDestination;

  @override
  Future<List<AssetBalanceSnapshot>> loadPortfolioBalances({
    required String ownerAddress,
  }) async => snapshots;
  @override
  Future<int> getSolBalanceLamports({required String ownerAddress}) async =>
      solBalance;
  @override
  Future<int> getSystemAccountRentExemptMinimumLamports() async => rent;
  @override
  Future<int> estimateSolFeeLamports({
    required String ownerAddress,
    required String destinationAddress,
    required int lamports,
  }) async {
    lastDestination = destinationAddress;
    return fee;
  }

  @override
  Future<String> broadcastSignedTransfer({
    required String encodedTransaction,
    required String mintAddress,
    required String amount,
    required String destinationAddress,
  }) async {
    submittedMint = mintAddress;
    submittedAmount = amount;
    submittedDestination = destinationAddress;
    return 'submitted-signature';
  }

  @override
  Future<String> buildSolTransferTransaction({
    required String ownerAddress,
    required String destinationAddress,
    required int lamports,
  }) async {
    buildCount++;
    final payer = Ed25519HDPublicKey.fromBase58(ownerAddress);
    final message = Message(
      instructions: [
        SystemInstruction.transfer(
          fundingAccount: payer,
          recipientAccount: Ed25519HDPublicKey.fromBase58(destinationAddress),
          lamports: lamports,
        ),
      ],
    ).compile(recentBlockhash: SystemProgram.programId, feePayer: payer);
    return SignedTx(
      signatures: [Signature(List.filled(64, 0), publicKey: payer)],
      compiledMessage: message,
    ).encode();
  }
}
