import 'dart:typed_data';

import 'package:shared_types/shared_types.dart';
import 'package:solana/dto.dart';
import 'package:solana/solana.dart';

import '../../features/auth/data/solana_wallet_service.dart';
import '../../features/auth/domain/wallet_derivation.dart';
import '../../features/transaction_history/domain/transaction_activity.dart';
import '../constants/app_constants.dart';
import 'chain_adapter.dart';
import 'chain_models.dart';

/// Wraps the existing Solana implementation without changing stored derivations,
/// custody integrations, or the backend Sender route used by existing screens.
class SolanaAdapter extends ChainAdapter {
  SolanaAdapter({
    required SolanaWalletService service,
    required Future<ChainAccount> Function() accountReader,
    required Future<String> Function() mnemonicReader,
    required WalletDerivation Function() derivationReader,
  }) : _service = service,
       _accountReader = accountReader,
       _mnemonicReader = mnemonicReader,
       _derivationReader = derivationReader;

  static const networkId = 'solana-mainnet';
  static const nativeMint = 'So11111111111111111111111111111111111111112';
  static const chainConfig = ChainConfig(
    id: networkId,
    family: ChainFamily.solana,
    displayName: AppConstants.supportedNetwork,
    iconAsset: 'assets/market_logos/sol.png',
    rpcUrl: AppConstants.solanaRpcUrl,
    explorerUrl: 'https://solscan.io',
    feeSymbol: 'SOL',
    feeDecimals: 9,
  );
  static final nativeAsset = ChainAsset(
    chainId: networkId,
    symbol: 'SOL',
    name: 'Solana',
    decimals: 9,
    rawBalance: BigInt.zero,
    isFeeAsset: true,
  );

  final SolanaWalletService _service;
  final Future<ChainAccount> Function() _accountReader;
  final Future<String> Function() _mnemonicReader;
  final WalletDerivation Function() _derivationReader;
  final Map<String, TokenInfo> _knownTokens = {};

  @override
  ChainConfig get config => chainConfig;

  @override
  Future<ChainAccount> getAccount() => _accountReader();

  @override
  bool validateAddress(String address) {
    try {
      return Ed25519HDPublicKey.fromBase58(address).bytes.length == 32;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<ChainAsset>> getAssets(
    ChainAccount account, {
    List<ChainAsset> tokens = const [],
  }) async {
    _validateAccount(account);
    final snapshots = await _service.loadPortfolioBalances(
      ownerAddress: account.address,
    );
    final balances = <String, ChainAsset>{'native': nativeAsset};
    for (final snapshot in snapshots) {
      final token = snapshot.token;
      _knownTokens[token.mintAddress] = token;
      final key = token.isNative ? 'native' : token.mintAddress;
      final amount = BigInt.parse(snapshot.rawAmount);
      final previous = balances[key];
      balances[key] = ChainAsset(
        chainId: networkId,
        symbol: token.symbol,
        name: token.name,
        decimals: token.decimals,
        contractAddress: token.isNative ? null : token.mintAddress,
        rawBalance: (previous?.rawBalance ?? BigInt.zero) + amount,
        isFeeAsset: token.isNative,
      );
    }
    for (final token in tokens) {
      _validateAsset(token);
      final key = token.contractAddress ?? 'native';
      if (!balances.containsKey(key)) {
        balances[key] = token.withBalance(await getBalance(account, token));
      }
    }
    return balances.values.toList(growable: false);
  }

  @override
  Future<BigInt> getBalance(ChainAccount account, ChainAsset asset) async {
    _validateAccount(account);
    _validateAsset(asset);
    if (asset.isNative) {
      return BigInt.from(
        await _service.getSolBalanceLamports(ownerAddress: account.address),
      );
    }
    final balances = await _service.loadBalances(
      ownerAddress: account.address,
      tokens: [_token(asset)],
    );
    return balances.fold<BigInt>(
      BigInt.zero,
      (sum, balance) => sum + BigInt.parse(balance.rawAmount),
    );
  }

  @override
  Future<ChainFeeEstimate> estimateFee(ChainTransferRequest request) async {
    _validateRequest(request);
    final amount = _checkedAmount(request.amount);
    final fee = request.asset.isNative
        ? await _service.estimateSolFeeLamports(
            ownerAddress: request.account.address,
            destinationAddress: request.to,
            lamports: amount,
          )
        : await _service.estimateSplFeeLamports(
            ownerAddress: request.account.address,
            destinationAddress: request.to,
            token: _token(request.asset),
            amount: amount,
          );
    return ChainFeeEstimate(
      chainId: networkId,
      symbol: 'SOL',
      decimals: 9,
      maxFee: BigInt.from(fee),
      estimatedFee: BigInt.from(fee),
    );
  }

  @override
  Future<PreparedChainTransaction> buildTransaction(
    ChainTransferRequest request, {
    ChainFeeEstimate? fee,
  }) async {
    _validateRequest(request);
    final estimate = fee ?? await estimateFee(request);
    if (estimate.chainId != networkId || estimate.maxFee.isNegative) {
      throw StateError('The fee estimate belongs to another network.');
    }
    final solBalance = await getBalance(request.account, nativeAsset);
    final reserve = request.asset.isNative
        ? BigInt.from(
            await _service.getSystemAccountRentExemptMinimumLamports(),
          )
        : BigInt.zero;
    final nativeValue = request.asset.isNative ? request.amount : BigInt.zero;
    if (solBalance < nativeValue + estimate.maxFee + reserve) {
      throw StateError(
        'Not enough SOL after reserving the network fee and rent.',
      );
    }
    if (!request.asset.isNative &&
        await getBalance(request.account, request.asset) < request.amount) {
      throw StateError(
        'Not enough ${request.asset.symbol} to send this amount.',
      );
    }
    final encoded = request.asset.isNative
        ? await _service.buildSolTransferTransaction(
            ownerAddress: request.account.address,
            destinationAddress: request.to,
            lamports: _checkedAmount(request.amount),
          )
        : await _service.buildSplTokenTransferTransaction(
            ownerAddress: request.account.address,
            destinationAddress: request.to,
            token: _token(request.asset),
            amount: _checkedAmount(request.amount),
          );
    return PreparedChainTransaction(
      request: request,
      fee: estimate,
      payload: _SolanaTransferPayload(encoded, request),
    );
  }

  @override
  Future<SignedChainTransaction> signTransaction(
    PreparedChainTransaction transaction,
  ) async {
    _validateRequest(transaction.request);
    final payload = transaction.payload;
    if (payload is! _SolanaTransferPayload ||
        !identical(payload.request, transaction.request)) {
      throw StateError(
        'Only transfers prepared by this adapter can be signed.',
      );
    }
    final mnemonic = await _authorizedMnemonic(transaction.request.account);
    return SignedChainTransaction(
      prepared: transaction,
      encoded: await _service.signPreparedTransfer(
        mnemonic: mnemonic,
        encodedTransaction: payload.encoded,
        derivation: _derivationReader(),
      ),
    );
  }

  @override
  Future<String> broadcastTransaction(SignedChainTransaction transaction) {
    final request = transaction.prepared.request;
    _validateRequest(request);
    final payload = transaction.prepared.payload;
    if (payload is! _SolanaTransferPayload ||
        !identical(payload.request, request) ||
        _service.signableTransactionMessage(payload.encoded) !=
            _service.signableTransactionMessage(transaction.encoded)) {
      throw StateError(
        'The signed transfer does not match the reviewed transfer.',
      );
    }
    return _service.broadcastSignedTransfer(
      encodedTransaction: transaction.encoded,
      mintAddress: request.asset.contractAddress ?? nativeMint,
      amount:
          '${formatUnits(request.amount, request.asset.decimals)} ${request.asset.symbol}',
      destinationAddress: request.to,
    );
  }

  @override
  Future<ChainActivity?> getTransaction(
    ChainAccount account,
    String hash,
  ) async {
    _validateAccount(account);
    final details = await _service.getTransactionDetails(hash);
    if (details == null) return null;
    final parsed = details.transaction;
    if (parsed is! ParsedTransaction) return null;
    if (parsed.message.instructions.any(
      (item) => item is ParsedInstructionSplToken,
    )) {
      final assets = await getAssets(account);
      final activity = await _activityForAssets(
        account,
        assets.where((asset) => !asset.isNative).toList(),
        hash: hash,
      );
      if (activity.isNotEmpty) return activity.first;
      // Never misrepresent the Sender SOL tip as the main SPL transfer.
      return null;
    }
    for (final instruction in parsed.message.instructions) {
      if (instruction is! ParsedInstructionSystem) continue;
      ChainActivity? result;
      instruction.parsed.map(
        transfer: (transfer) {
          if (transfer.info.source == account.address ||
              transfer.info.destination == account.address) {
            result = ChainActivity(
              chainId: networkId,
              hash: hash,
              from: transfer.info.source,
              to: transfer.info.destination,
              asset: nativeAsset,
              amount: BigInt.from(transfer.info.lamports),
              status: ChainTransactionStatus.pending,
              fee: details.meta == null ? null : BigInt.from(details.meta!.fee),
              timestamp: _timestamp(details),
            );
          }
        },
        transferChecked: (_) {},
        unsupported: (_) {},
      );
      if (result != null) return _withStatus(result!, await _status(hash));
    }
    // Token transfers need the tracked token account to identify direction. The
    // existing activity service resolves that ATA and normalizes counterparties.
    final assets = await getAssets(account);
    final activity = await _activityForAssets(account, assets, hash: hash);
    return activity.firstOrNull;
  }

  @override
  Future<List<ChainActivity>> getActivity(
    ChainAccount account, {
    List<ChainAsset> tokens = const [],
  }) async {
    _validateAccount(account);
    final assets = await getAssets(account, tokens: tokens);
    return _activityForAssets(account, assets);
  }

  Future<List<ChainActivity>> _activityForAssets(
    ChainAccount account,
    List<ChainAsset> assets, {
    String? hash,
  }) async {
    final activities = <String, ChainActivity>{};
    for (final asset in assets) {
      final entries = await _service.getRecentTransactions(
        ownerAddress: account.address,
        token: _token(asset),
      );
      for (final entry in entries) {
        if (hash != null && entry.signature != hash) continue;
        final details = await _service.getTransactionDetails(entry.signature);
        if (details == null) continue;
        final amount = _rawTransferAmount(details, asset, entry.counterparty);
        if (amount == null) continue;
        final sent = entry.direction == TransactionDirection.sent;
        final activity = ChainActivity(
          chainId: networkId,
          hash: entry.signature,
          from: sent ? account.address : entry.counterparty,
          to: sent ? entry.counterparty : account.address,
          asset: asset,
          amount: amount,
          status: await _status(entry.signature),
          timestamp: entry.timestamp,
          fee: details.meta == null ? null : BigInt.from(details.meta!.fee),
          type: entry.kind.name,
        );
        activities['${entry.signature}:${asset.id}'] = activity;
      }
    }
    return activities.values.toList()..sort(
      (a, b) => (b.timestamp ?? DateTime(1970)).compareTo(
        a.timestamp ?? DateTime(1970),
      ),
    );
  }

  BigInt? _rawTransferAmount(
    TransactionDetails details,
    ChainAsset asset,
    String counterparty,
  ) {
    final parsed = details.transaction;
    if (parsed is! ParsedTransaction) return null;
    for (final instruction in parsed.message.instructions) {
      BigInt? value;
      if (asset.isNative && instruction is ParsedInstructionSystem) {
        instruction.parsed.map(
          transfer: (transfer) {
            if ([
              transfer.info.source,
              transfer.info.destination,
            ].contains(counterparty)) {
              value = BigInt.from(transfer.info.lamports);
            }
          },
          transferChecked: (_) {},
          unsupported: (_) {},
        );
      } else if (!asset.isNative && instruction is ParsedInstructionSplToken) {
        instruction.parsed.map(
          transfer: (transfer) {
            if ([
              transfer.info.source,
              transfer.info.destination,
            ].contains(counterparty)) {
              value = BigInt.parse(transfer.info.amount);
            }
          },
          transferChecked: (transfer) {
            if ([
              transfer.info.source,
              transfer.info.destination,
            ].contains(counterparty)) {
              value = BigInt.parse(transfer.info.tokenAmount.amount);
            }
          },
          generic: (_) {},
        );
      }
      if (value != null) return value;
    }
    return null;
  }

  Future<ChainTransactionStatus> _status(String hash) async {
    final status = await _service.getTransactionStatus(hash);
    if (status == null) return ChainTransactionStatus.unknown;
    if (status.err != null) return ChainTransactionStatus.failed;
    return status.confirmationStatus == Commitment.finalized
        ? ChainTransactionStatus.finalSuccess
        : ChainTransactionStatus.pending;
  }

  @override
  Future<Uint8List> signMessage(Uint8List message) async {
    final mnemonic = await _authorizedMnemonic(await getAccount());
    final signer = await _service.keyPairFromMnemonic(
      mnemonic,
      derivation: _derivationReader(),
    );
    return Uint8List.fromList((await signer.sign(message)).bytes.toList());
  }

  Future<String> _authorizedMnemonic(ChainAccount requested) async {
    final current = await getAccount();
    if (!current.canSign || !requested.canSign) {
      throw UnsupportedError(
        'Use the existing external Solana wallet approval flow.',
      );
    }
    if (current.rootWalletId != requested.rootWalletId ||
        current.address != requested.address) {
      throw StateError(
        'The selected wallet changed. Review the transfer again.',
      );
    }
    final mnemonic = await _mnemonicReader();
    final derived = await _service.deriveAddress(
      mnemonic,
      derivation: _derivationReader(),
    );
    if (derived != current.address) {
      throw StateError(
        'The recovery phrase does not match the stored Solana account.',
      );
    }
    return mnemonic;
  }

  TokenInfo _token(ChainAsset asset) =>
      _knownTokens[asset.contractAddress] ??
      TokenInfo(
        mintAddress: asset.contractAddress ?? nativeMint,
        symbol: asset.symbol,
        name: asset.name,
        decimals: asset.decimals,
        isNative: asset.isNative,
        isVisible: true,
      );

  void _validateAccount(ChainAccount account) {
    if (account.chainId != networkId || !validateAddress(account.address)) {
      throw ArgumentError('Invalid Solana account.');
    }
  }

  void _validateAsset(ChainAsset asset) {
    if (asset.chainId != networkId ||
        (asset.isNative
            ? asset.decimals != 9
            : !validateAddress(asset.contractAddress!))) {
      throw ArgumentError('Invalid Solana asset.');
    }
  }

  void _validateRequest(ChainTransferRequest request) {
    _validateAccount(request.account);
    _validateAsset(request.asset);
    if (!validateAddress(request.to) || request.amount <= BigInt.zero) {
      throw ArgumentError(
        'Enter a valid Solana destination and positive amount.',
      );
    }
    _checkedAmount(request.amount);
  }

  int _checkedAmount(BigInt amount) {
    if (amount < BigInt.zero || amount > BigInt.from(0x7fffffffffffffff)) {
      throw ArgumentError(
        'Amount exceeds the supported Solana transaction range.',
      );
    }
    return amount.toInt();
  }

  DateTime? _timestamp(TransactionDetails details) => details.blockTime == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(
          details.blockTime! * 1000,
          isUtc: true,
        );

  ChainActivity _withStatus(
    ChainActivity value,
    ChainTransactionStatus status,
  ) => ChainActivity(
    chainId: value.chainId,
    hash: value.hash,
    from: value.from,
    to: value.to,
    asset: value.asset,
    amount: value.amount,
    status: status,
    timestamp: value.timestamp,
    fee: value.fee,
    type: value.type,
  );
}

class _SolanaTransferPayload {
  const _SolanaTransferPayload(this.encoded, this.request);
  final String encoded;
  final ChainTransferRequest request;
}
