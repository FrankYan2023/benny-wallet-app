import 'dart:async';
import 'dart:convert' show base64Encode, utf8;
import 'dart:isolate';
import 'dart:math';

import 'package:bip39/bip39.dart' as bip39;
import 'package:shared_types/shared_types.dart';
import 'package:solana/base58.dart';
import 'package:solana/encoder.dart' show Instruction, Signature, SignedTx;
import 'package:solana/dto.dart'
    show
        AccountData,
        Encoding,
        ParsedAccountData,
        ParsedSplTokenProgramAccountData,
        ParsedSplToken2022ProgramAccountData,
        ProgramAccount,
        SplTokenAccountDataInfo,
        TokenAmount,
        TokenAccountData,
        TokenAccountsFilter,
        TransactionDetails;
import 'package:solana/solana.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/backend_session_manager.dart';
import '../../../core/utils/formatters.dart';
import '../../../features/transaction_history/domain/transaction_activity.dart';
import '../domain/wallet_derivation.dart';

class AssetBalanceSnapshot {
  const AssetBalanceSnapshot({
    required this.token,
    required this.balance,
    required this.existsOnChain,
  });

  final TokenInfo token;
  final double balance;
  final bool existsOnChain;
}

class SolanaImportCandidate {
  const SolanaImportCandidate({
    required this.address,
    required this.derivation,
  });

  final String address;
  final WalletDerivation derivation;
}

class ReclaimableTokenAccount {
  const ReclaimableTokenAccount({
    required this.address,
    required this.mintAddress,
    required this.symbol,
    required this.name,
    required this.rentLamports,
    required this.tokenProgramKind,
  });

  final String address;
  final String mintAddress;
  final String symbol;
  final String name;
  final int rentLamports;
  final TokenProgramKind tokenProgramKind;
}

class RentReclaimPreview {
  const RentReclaimPreview({
    required this.ownerAddress,
    required this.accounts,
  });

  final String ownerAddress;
  final List<ReclaimableTokenAccount> accounts;

  int get reclaimableLamports =>
      accounts.fold(0, (total, item) => total + item.rentLamports);
}

class SolanaWalletService {
  SolanaWalletService({
    BackendApiClient? backendApiClient,
    BackendSessionManager? sessionManager,
  }) : _backendApiClient = backendApiClient,
       _sessionManager = sessionManager;

  static const _solMintAddress = 'So11111111111111111111111111111111111111112';
  static const _usdcMintAddress =
      'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v';
  static const _senderComputeUnitLimit = 200000;
  static const _senderPriorityFeeMicroLamports = 200000;
  static const _senderTipLamports = 200000;
  static const _senderSafetyBufferLamports = 10000;
  static const _systemAccountRentExemptFallbackLamports = 890880;
  static const _heliusTipAccounts = [
    '4ACfpUFoaSD9bfPdeu6DBt89gB6ENTeHBXCAi87NhDEE',
    'D2L6yPZ2FmmmTKPgzaMKdhu6EWZcTpLy1Vhx8uvZe7NZ',
    '9bnz4RShgq1hAnLnZbP8kbgBg1kEmcJBYQq3gQbmnSta',
    '5VY91ws6B2hMmBFRsXkoAAdsPHBJwRfBht4DXox3xkwn',
    '2nyhqdwKcJZR2vcqCyrYsaPVdAnFoJjiksCXJ7hfEYgD',
    '2q5pghRs6arqVjRvT5gfgWfWcHWmw1ZuCzphgd5KfWGJ',
    'wyvPkWjVZz1M8fHQnMMCDTQDbkManefNNhweYk5WkcF',
    '3KCKozbAaF75qEU33jtzozcJ29yJuaLJTy2jFdzUY8bT',
    '4vieeGHPYPG2MmyPRcYjdiDmmhN3ww7hsFNap8pVN3Ey',
    '4TQLFNWK8AovT1gFvda5jfw2oJeRMKEmw7aH6MGBJ3or',
  ];

  static int get _senderPriorityFeeLamports =>
      ((_senderComputeUnitLimit * _senderPriorityFeeMicroLamports) / 1000000)
          .ceil();

  final BackendApiClient? _backendApiClient;
  final BackendSessionManager? _sessionManager;
  RpcClient? _rpcClient;
  DateTime? _rpcClientExpiresAt;
  String? _rpcClientOwnerAddress;

  Future<Ed25519HDKeyPair> keyPairFromMnemonic(
    String mnemonic, {
    WalletDerivation derivation = WalletDerivation.legacy,
  }) {
    return Ed25519HDKeyPair.fromMnemonic(
      mnemonic,
      account: derivation.accountIndex,
      change: derivation.changeIndex,
    );
  }

  Future<String> deriveAddress(
    String mnemonic, {
    WalletDerivation derivation = WalletDerivation.legacy,
  }) async {
    final keypair = await keyPairFromMnemonic(mnemonic, derivation: derivation);
    return keypair.address;
  }

  Future<List<SolanaImportCandidate>> discoverImportCandidates(
    String mnemonic,
  ) async {
    final rawCandidates = await Isolate.run(
      () => _discoverImportCandidatesInIsolate(mnemonic),
    );

    final deduped = <String, SolanaImportCandidate>{};
    for (final rawCandidate in rawCandidates) {
      final candidate = SolanaImportCandidate(
        address: rawCandidate['address']! as String,
        derivation: WalletDerivation.fromJson(
          Map<String, dynamic>.from(rawCandidate['derivation']! as Map),
        ),
      );
      deduped.putIfAbsent(candidate.address, () => candidate);
    }

    return deduped.values.toList(growable: false);
  }

  Future<String> signArbitraryMessage({
    required String mnemonic,
    required String message,
    WalletDerivation derivation = WalletDerivation.legacy,
  }) async {
    final signer = await keyPairFromMnemonic(mnemonic, derivation: derivation);
    final signature = await signer.sign(utf8.encode(message));
    return base58encode(signature.bytes.toList(growable: false));
  }

  Future<List<TokenInfo>> discoverTrackedTokens({
    required String ownerAddress,
  }) async {
    final rpcClient = await _getRpcClient();
    final tokensByKey = <String, TokenInfo>{
      for (final token in _defaultTrackedTokens) _tokenKey(token): token,
    };

    final tokenAccounts = await _loadTokenAccountsByOwner(
      rpcClient: rpcClient,
      ownerAddress: ownerAddress,
      commitment: Commitment.confirmed,
    );

    for (final account in tokenAccounts) {
      final info = _readTokenAccountInfo(account.account.data);
      if (info == null) {
        continue;
      }

      final rawAmount = BigInt.tryParse(info.tokenAmount.amount) ?? BigInt.zero;
      if (rawAmount <= BigInt.zero) {
        continue;
      }

      final mintAddress = info.mint;
      if (mintAddress == _solMintAddress) {
        continue;
      }

      final discoveredToken =
          _knownSplToken(mintAddress) ??
          TokenInfo(
            mintAddress: mintAddress,
            symbol: mintAddress,
            name: 'Token ${Formatters.address(mintAddress)}',
            decimals: info.tokenAmount.decimals,
            isNative: false,
            isVisible: true,
            tokenProgramType: _readTokenProgramType(account.account.data),
          );
      tokensByKey[_tokenKey(discoveredToken)] = discoveredToken;
    }

    return [
      for (final token in _defaultTrackedTokens)
        tokensByKey.remove(_tokenKey(token)) ?? token,
      ...tokensByKey.values.toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase())),
    ];
  }

  Future<List<AssetBalanceSnapshot>> loadPortfolioBalances({
    required String ownerAddress,
  }) async {
    final rpcClient = await _getRpcClient();
    final lamports = (await rpcClient.getBalance(
      ownerAddress,
      commitment: Commitment.confirmed,
    )).value;
    final snapshots = <AssetBalanceSnapshot>[];

    if (lamports > 0) {
      final solToken = _defaultTrackedTokens.firstWhere(
        (token) => token.isNative,
      );
      snapshots.add(
        AssetBalanceSnapshot(
          token: solToken,
          balance: lamports / lamportsPerSol,
          existsOnChain: true,
        ),
      );
    }

    final tokenAccounts = await _loadTokenAccountsByOwner(
      rpcClient: rpcClient,
      ownerAddress: ownerAddress,
      commitment: Commitment.confirmed,
    );

    for (final account in tokenAccounts) {
      final info = _readTokenAccountInfo(account.account.data);
      if (info == null) {
        continue;
      }

      final mintAddress = info.mint;
      if (mintAddress == _solMintAddress) {
        continue;
      }

      final rawAmount = BigInt.tryParse(info.tokenAmount.amount) ?? BigInt.zero;
      final balance =
          double.tryParse(
            info.tokenAmount.uiAmountString ?? info.tokenAmount.amount,
          ) ??
          0;
      final token =
          _knownSplToken(mintAddress) ??
          TokenInfo(
            mintAddress: mintAddress,
            symbol: mintAddress,
            name: 'Token ${Formatters.address(mintAddress)}',
            decimals: info.tokenAmount.decimals,
            isNative: false,
            isVisible: true,
            tokenProgramType: _readTokenProgramType(account.account.data),
          );

      if (rawAmount <= BigInt.zero) {
        continue;
      }

      snapshots.add(
        AssetBalanceSnapshot(
          token: token,
          balance: balance,
          existsOnChain: true,
        ),
      );
    }

    snapshots.sort(
      (a, b) =>
          a.token.name.toLowerCase().compareTo(b.token.name.toLowerCase()),
    );

    return snapshots;
  }

  Future<List<AssetBalanceSnapshot>> loadBalances({
    required String ownerAddress,
    required List<TokenInfo> tokens,
  }) async {
    final rpcClient = await _getRpcClient();
    final owner = Ed25519HDPublicKey.fromBase58(ownerAddress);
    final snapshots = <AssetBalanceSnapshot>[];

    for (final token in tokens) {
      if (token.isNative) {
        final lamports = (await rpcClient.getBalance(
          ownerAddress,
          commitment: Commitment.confirmed,
        )).value;
        snapshots.add(
          AssetBalanceSnapshot(
            token: token,
            balance: lamports / lamportsPerSol,
            existsOnChain: lamports > 0,
          ),
        );
        continue;
      }

      try {
        final mint = Ed25519HDPublicKey.fromBase58(token.mintAddress);
        final hasAta = await _hasAssociatedTokenAccount(
          rpcClient: rpcClient,
          owner: owner,
          mint: mint,
          commitment: Commitment.confirmed,
        );
        if (!hasAta) {
          snapshots.add(
            AssetBalanceSnapshot(
              token: token,
              balance: 0,
              existsOnChain: false,
            ),
          );
          continue;
        }

        final amount = await _getTokenBalance(
          rpcClient: rpcClient,
          owner: owner,
          mint: mint,
          commitment: Commitment.confirmed,
        );
        snapshots.add(
          AssetBalanceSnapshot(
            token: token,
            balance:
                double.tryParse(amount.uiAmountString ?? amount.amount) ?? 0,
            existsOnChain: true,
          ),
        );
      } catch (error) {
        if (_isMissingMintError(error)) {
          // Treat tokens that do not exist on the current RPC cluster as absent
          // so a single mismatched mint does not break the entire portfolio.
          snapshots.add(
            AssetBalanceSnapshot(
              token: token,
              balance: 0,
              existsOnChain: false,
            ),
          );
          continue;
        }
        rethrow;
      }
    }

    return snapshots;
  }

  Future<int> getSolBalanceLamports({required String ownerAddress}) async {
    final rpcClient = await _getRpcClient();
    return (await rpcClient.getBalance(
      ownerAddress,
      commitment: Commitment.confirmed,
    )).value;
  }

  Future<int> getSystemAccountRentExemptMinimumLamports() async {
    final rpcClient = await _getRpcClient();
    try {
      return await rpcClient.getMinimumBalanceForRentExemption(
        0,
        commitment: Commitment.confirmed,
      );
    } catch (_) {
      return _systemAccountRentExemptFallbackLamports;
    }
  }

  Future<RentReclaimPreview> previewRentReclaim({
    required String ownerAddress,
  }) async {
    final rpcClient = await _getRpcClient();
    final tokenAccounts = await _loadTokenAccountsByOwner(
      rpcClient: rpcClient,
      ownerAddress: ownerAddress,
      commitment: Commitment.confirmed,
    );

    final reclaimableAccounts = <ReclaimableTokenAccount>[];
    for (final account in tokenAccounts) {
      final info = _readTokenAccountInfo(account.account.data);
      if (info == null) {
        continue;
      }

      final rawAmount = _tokenAccountRawAmount(account);
      if (rawAmount > BigInt.zero) {
        continue;
      }

      final mintAddress = info.mint;
      final token =
          _knownSplToken(mintAddress) ??
          TokenInfo(
            mintAddress: mintAddress,
            symbol: mintAddress == _solMintAddress ? 'wSOL' : mintAddress,
            name: mintAddress == _solMintAddress
                ? 'Wrapped SOL'
                : 'Token ${Formatters.address(mintAddress)}',
            decimals: info.tokenAmount.decimals,
            isNative: false,
            isVisible: true,
            tokenProgramType: _readTokenProgramType(account.account.data),
          );

      reclaimableAccounts.add(
        ReclaimableTokenAccount(
          address: account.pubkey,
          mintAddress: mintAddress,
          symbol: token.symbol,
          name: token.name,
          rentLamports: account.account.lamports,
          tokenProgramKind: _readTokenProgramType(account.account.data),
        ),
      );
    }

    reclaimableAccounts.sort((left, right) {
      final rentComparison = right.rentLamports.compareTo(left.rentLamports);
      if (rentComparison != 0) {
        return rentComparison;
      }
      final symbolComparison = left.symbol.toLowerCase().compareTo(
        right.symbol.toLowerCase(),
      );
      if (symbolComparison != 0) {
        return symbolComparison;
      }
      return left.address.compareTo(right.address);
    });

    return RentReclaimPreview(
      ownerAddress: ownerAddress,
      accounts: reclaimableAccounts,
    );
  }

  Future<double> estimateSolFee({
    required String ownerAddress,
    required String destinationAddress,
    required int lamports,
  }) async {
    final rpcClient = await _getRpcClient();
    final owner = Ed25519HDPublicKey.fromBase58(ownerAddress);
    final destination = Ed25519HDPublicKey.fromBase58(destinationAddress);
    final instruction = SystemInstruction.transfer(
      fundingAccount: owner,
      recipientAccount: destination,
      lamports: lamports,
    );
    final blockhash = (await rpcClient.getLatestBlockhash()).value;
    final compiled = Message(
      instructions: _buildSenderInstructions(
        owner: owner,
        instructions: [instruction],
      ),
    ).compile(recentBlockhash: blockhash.blockhash, feePayer: owner);
    final fee = await rpcClient.getFeeForMessage(
      base64Encode(compiled.toByteArray().toList()),
    );
    return ((fee ?? 0) +
            _senderTipLamports +
            _senderPriorityFeeLamports +
            _senderSafetyBufferLamports) /
        lamportsPerSol;
  }

  Future<double> estimateSplFee({
    required String ownerAddress,
    required String destinationAddress,
    required TokenInfo token,
    required int amount,
  }) async {
    final rpcClient = await _getRpcClient();
    final owner = Ed25519HDPublicKey.fromBase58(ownerAddress);
    final destination = Ed25519HDPublicKey.fromBase58(destinationAddress);
    final mint = Ed25519HDPublicKey.fromBase58(token.mintAddress);
    final tokenProgramType = await _resolveTokenProgramType(
      rpcClient: rpcClient,
      owner: owner,
      mint: mint,
      fallback: token.tokenProgramType,
    );
    final senderAta = await _getAssociatedTokenAccount(
      rpcClient: rpcClient,
      owner: owner,
      mint: mint,
      tokenProgramType: tokenProgramType,
      commitment: Commitment.confirmed,
    );
    final recipientAta = await _getAssociatedTokenAccount(
      rpcClient: rpcClient,
      owner: destination,
      mint: mint,
      tokenProgramType: tokenProgramType,
      commitment: Commitment.confirmed,
    );

    if (senderAta == null) {
      throw StateError('Wallet has no token account for ${token.symbol}.');
    }

    final instructions = <Instruction>[];
    final recipientTokenAddress = await _resolveRecipientTokenAccountAddress(
      recipientAccount: recipientAta,
      owner: destination,
      mint: mint,
      tokenProgramType: tokenProgramType,
      instructions: instructions,
      funder: owner,
    );

    instructions.add(
      TokenInstruction.transferChecked(
        mint: mint,
        source: Ed25519HDPublicKey.fromBase58(senderAta.pubkey),
        destination: recipientTokenAddress,
        owner: owner,
        amount: amount,
        decimals: token.decimals,
        tokenProgram: tokenProgramType,
      ),
    );
    final blockhash = (await rpcClient.getLatestBlockhash()).value;
    final compiled = Message(
      instructions: _buildSenderInstructions(
        owner: owner,
        instructions: instructions,
      ),
    ).compile(recentBlockhash: blockhash.blockhash, feePayer: owner);
    final fee = await rpcClient.getFeeForMessage(
      base64Encode(compiled.toByteArray().toList()),
    );
    return ((fee ?? 0) +
            _senderTipLamports +
            _senderPriorityFeeLamports +
            _senderSafetyBufferLamports) /
        lamportsPerSol;
  }

  Future<String> sendSol({
    required String mnemonic,
    required String destinationAddress,
    required int lamports,
    WalletDerivation derivation = WalletDerivation.legacy,
    String? submissionAmount,
  }) async {
    final rpcClient = await _getRpcClient();
    final owner = await keyPairFromMnemonic(mnemonic, derivation: derivation);
    final destination = Ed25519HDPublicKey.fromBase58(destinationAddress);
    final message = Message(
      instructions: _buildSenderInstructions(
        owner: owner.publicKey,
        instructions: [
          SystemInstruction.transfer(
            fundingAccount: owner.publicKey,
            recipientAccount: destination,
            lamports: lamports,
          ),
        ],
      ),
    );
    final signature = await _signAndSubmitViaSender(
      rpcClient: rpcClient,
      message: message,
      signer: owner,
      txType: 'send',
      fromMint: _solMintAddress,
      toMint: _solMintAddress,
      amount: submissionAmount ?? lamportsToSol(lamports).toString(),
      destinationAddress: destinationAddress,
    );
    return signature;
  }

  Future<String> buildSolTransferTransaction({
    required String ownerAddress,
    required String destinationAddress,
    required int lamports,
  }) async {
    final rpcClient = await _getRpcClient();
    final owner = Ed25519HDPublicKey.fromBase58(ownerAddress);
    final destination = Ed25519HDPublicKey.fromBase58(destinationAddress);
    final message = Message(
      instructions: _buildSenderInstructions(
        owner: owner,
        instructions: [
          SystemInstruction.transfer(
            fundingAccount: owner,
            recipientAccount: destination,
            lamports: lamports,
          ),
        ],
      ),
    );
    return _compileUnsignedTransaction(
      rpcClient: rpcClient,
      message: message,
      feePayer: owner,
    );
  }

  Future<String> sendSplToken({
    required String mnemonic,
    required TokenInfo token,
    required String destinationAddress,
    required int amount,
    WalletDerivation derivation = WalletDerivation.legacy,
    String? submissionAmount,
  }) async {
    final rpcClient = await _getRpcClient();
    final owner = await keyPairFromMnemonic(mnemonic, derivation: derivation);
    final destination = Ed25519HDPublicKey.fromBase58(destinationAddress);
    final mint = Ed25519HDPublicKey.fromBase58(token.mintAddress);
    final tokenProgramType = await _resolveTokenProgramType(
      rpcClient: rpcClient,
      owner: owner.publicKey,
      mint: mint,
      fallback: token.tokenProgramType,
    );
    final senderAta = await _getAssociatedTokenAccount(
      rpcClient: rpcClient,
      owner: owner.publicKey,
      mint: mint,
      tokenProgramType: tokenProgramType,
      commitment: Commitment.confirmed,
    );
    final recipientAta = await _getAssociatedTokenAccount(
      rpcClient: rpcClient,
      owner: destination,
      mint: mint,
      tokenProgramType: tokenProgramType,
      commitment: Commitment.confirmed,
    );

    if (senderAta == null) {
      throw StateError('Wallet has no token account for ${token.symbol}.');
    }

    final instructions = <Instruction>[];
    final recipientTokenAddress = await _resolveRecipientTokenAccountAddress(
      recipientAccount: recipientAta,
      owner: destination,
      mint: mint,
      tokenProgramType: tokenProgramType,
      instructions: instructions,
      funder: owner.publicKey,
    );

    final transferInstructions = <Instruction>[
      TokenInstruction.transferChecked(
        source: Ed25519HDPublicKey.fromBase58(senderAta.pubkey),
        mint: mint,
        destination: recipientTokenAddress,
        owner: owner.publicKey,
        amount: amount,
        decimals: token.decimals,
        tokenProgram: tokenProgramType,
      ),
    ];
    final message = Message(
      instructions: _buildSenderInstructions(
        owner: owner.publicKey,
        instructions: [...instructions, ...transferInstructions],
      ),
    );
    final signature = await _signAndSubmitViaSender(
      rpcClient: rpcClient,
      message: message,
      signer: owner,
      txType: 'send',
      fromMint: token.mintAddress,
      toMint: token.mintAddress,
      amount: submissionAmount ?? amount.toString(),
      destinationAddress: destinationAddress,
    );
    return signature;
  }

  Future<String> buildSplTokenTransferTransaction({
    required String ownerAddress,
    required TokenInfo token,
    required String destinationAddress,
    required int amount,
  }) async {
    final rpcClient = await _getRpcClient();
    final owner = Ed25519HDPublicKey.fromBase58(ownerAddress);
    final destination = Ed25519HDPublicKey.fromBase58(destinationAddress);
    final mint = Ed25519HDPublicKey.fromBase58(token.mintAddress);
    final tokenProgramType = await _resolveTokenProgramType(
      rpcClient: rpcClient,
      owner: owner,
      mint: mint,
      fallback: token.tokenProgramType,
    );
    final senderAta = await _getAssociatedTokenAccount(
      rpcClient: rpcClient,
      owner: owner,
      mint: mint,
      tokenProgramType: tokenProgramType,
      commitment: Commitment.confirmed,
    );
    final recipientAta = await _getAssociatedTokenAccount(
      rpcClient: rpcClient,
      owner: destination,
      mint: mint,
      tokenProgramType: tokenProgramType,
      commitment: Commitment.confirmed,
    );

    if (senderAta == null) {
      throw StateError('Wallet has no token account for ${token.symbol}.');
    }

    final instructions = <Instruction>[];
    final recipientTokenAddress = await _resolveRecipientTokenAccountAddress(
      recipientAccount: recipientAta,
      owner: destination,
      mint: mint,
      tokenProgramType: tokenProgramType,
      instructions: instructions,
      funder: owner,
    );

    final message = Message(
      instructions: _buildSenderInstructions(
        owner: owner,
        instructions: [
          ...instructions,
          TokenInstruction.transferChecked(
            source: Ed25519HDPublicKey.fromBase58(senderAta.pubkey),
            mint: mint,
            destination: recipientTokenAddress,
            owner: owner,
            amount: amount,
            decimals: token.decimals,
            tokenProgram: tokenProgramType,
          ),
        ],
      ),
    );
    return _compileUnsignedTransaction(
      rpcClient: rpcClient,
      message: message,
      feePayer: owner,
    );
  }

  Future<String> signAndSendPreparedTransaction({
    required String mnemonic,
    required String encodedTransaction,
    WalletDerivation derivation = WalletDerivation.legacy,
  }) async {
    final signer = await keyPairFromMnemonic(mnemonic, derivation: derivation);
    final signedTransaction = await _signPreparedTransaction(
      encodedTransaction: encodedTransaction,
      signer: signer,
    );
    final rpcClient = await _getRpcClient();
    final signature = await _broadcastEncodedTransaction(
      rpcClient: rpcClient,
      encodedTransaction: signedTransaction.encode(),
    );
    await _waitForConfirmation(signature);
    return signature;
  }

  Future<String> sendExternallySignedTransaction({
    required String encodedTransaction,
    required String signature,
    bool submitViaSender = false,
    String? txType,
    String? fromMint,
    String? toMint,
    String? amount,
    String? referenceId,
    String? destinationAddress,
  }) async {
    final transaction = SignedTx.decode(encodedTransaction);
    if (transaction.signatures.isEmpty) {
      throw StateError('Prepared transaction has no signature slot.');
    }
    final primaryPublicKey = transaction.signatures.first.publicKey;
    if (primaryPublicKey is! Ed25519HDPublicKey) {
      throw StateError('Prepared transaction uses an unsupported signer key.');
    }
    final signatureBytes = base58decode(signature);
    final validSignature = await verifySignature(
      message: transaction.compiledMessage.toByteArray().toList(),
      signature: signatureBytes,
      publicKey: primaryPublicKey,
    );
    if (!validSignature) {
      throw StateError('Seed Vault returned an invalid transaction signature.');
    }
    final signedTransaction = SignedTx(
      signatures: _injectPrimarySignature(
        existing: transaction.signatures,
        primary: Signature(signatureBytes, publicKey: primaryPublicKey),
      ),
      compiledMessage: transaction.compiledMessage,
    );
    final encodedSignedTransaction = signedTransaction.encode();
    final backendApiClient = _backendApiClient;
    if (submitViaSender && backendApiClient != null) {
      return backendApiClient.submitSenderTransaction(
        encodedTransaction: encodedSignedTransaction,
        txType: txType,
        fromMint: fromMint,
        toMint: toMint,
        amount: amount,
        referenceId: referenceId,
        destinationAddress: destinationAddress,
      );
    }

    final rpcClient = await _getRpcClient();
    final transactionSignature = await _broadcastEncodedTransaction(
      rpcClient: rpcClient,
      encodedTransaction: encodedSignedTransaction,
    );
    await _waitForConfirmation(transactionSignature);
    return transactionSignature;
  }

  String signableTransactionMessage(String encodedTransaction) {
    return base64Encode(
      SignedTx.decode(
        encodedTransaction,
      ).compiledMessage.toByteArray().toList(),
    );
  }

  List<int> signableTransactionMessageBytes(String encodedTransaction) {
    return SignedTx.decode(
      encodedTransaction,
    ).compiledMessage.toByteArray().toList();
  }

  Future<void> waitForConfirmation(String signature) {
    return _waitForConfirmation(signature);
  }

  Future<List<String>> reclaimAllTokenAccountRent({
    required String mnemonic,
    required WalletDerivation derivation,
    required List<ReclaimableTokenAccount> accounts,
  }) async {
    if (accounts.isEmpty) {
      return const [];
    }

    final rpcClient = await _getRpcClient();
    final signer = await keyPairFromMnemonic(mnemonic, derivation: derivation);
    final owner = signer.publicKey;
    final signatures = <String>[];

    for (var start = 0; start < accounts.length; start += 8) {
      final chunk = accounts.skip(start).take(8);
      final instructions = <Instruction>[
        for (final account in chunk)
          TokenInstruction.closeAccount(
            accountToClose: Ed25519HDPublicKey.fromBase58(account.address),
            destination: owner,
            owner: owner,
            tokenProgram: _toSolanaTokenProgramType(account.tokenProgramKind),
          ),
      ];
      final message = Message(
        instructions: _buildSenderInstructions(
          owner: owner,
          instructions: instructions,
        ),
      );
      final signature = await _signAndSubmitViaSender(
        rpcClient: rpcClient,
        message: message,
        signer: signer,
      );
      signatures.add(signature);
    }

    return signatures;
  }

  Future<List<String>> buildRentReclaimTransactions({
    required String ownerAddress,
    required List<ReclaimableTokenAccount> accounts,
  }) async {
    if (accounts.isEmpty) {
      return const [];
    }

    final rpcClient = await _getRpcClient();
    final owner = Ed25519HDPublicKey.fromBase58(ownerAddress);
    final transactions = <String>[];

    for (var start = 0; start < accounts.length; start += 8) {
      final chunk = accounts.skip(start).take(8);
      final instructions = <Instruction>[
        for (final account in chunk)
          TokenInstruction.closeAccount(
            accountToClose: Ed25519HDPublicKey.fromBase58(account.address),
            destination: owner,
            owner: owner,
            tokenProgram: _toSolanaTokenProgramType(account.tokenProgramKind),
          ),
      ];
      final message = Message(
        instructions: _buildSenderInstructions(
          owner: owner,
          instructions: instructions,
        ),
      );
      transactions.add(
        await _compileUnsignedTransaction(
          rpcClient: rpcClient,
          message: message,
          feePayer: owner,
        ),
      );
    }

    return transactions;
  }

  Future<List<TransactionActivity>> getRecentTransactions({
    required String ownerAddress,
    required TokenInfo token,
    int limit = 10,
  }) async {
    final rpcClient = await _getRpcClient();
    final owner = Ed25519HDPublicKey.fromBase58(ownerAddress);
    Ed25519HDPublicKey target = owner;

    if (!token.isNative) {
      try {
        final ata = await _getAssociatedTokenAccount(
          rpcClient: rpcClient,
          owner: owner,
          mint: Ed25519HDPublicKey.fromBase58(token.mintAddress),
          commitment: Commitment.confirmed,
        );
        if (ata == null) {
          return [];
        }
        target = Ed25519HDPublicKey.fromBase58(ata.pubkey);
      } catch (error) {
        if (_isMissingMintError(error)) {
          return [];
        }
        rethrow;
      }
    }

    final signatures = await rpcClient.getSignaturesForAddress(
      target.toBase58(),
      limit: limit,
      commitment: Commitment.confirmed,
    );
    final details = <TransactionDetails>[];
    for (final item in signatures) {
      final detail = await rpcClient.getTransaction(
        item.signature,
        encoding: Encoding.jsonParsed,
        commitment: Commitment.confirmed,
      );
      if (detail != null) {
        details.add(detail);
      }
    }

    return details
        .map(
          (tx) => TransactionActivity.fromTransaction(
            tx: tx,
            ownerAddress: ownerAddress,
            trackedAddress: target.toBase58(),
            symbol: token.symbol,
          ),
        )
        .toList();
  }

  double lamportsToSol(int lamports) => lamports / lamportsPerSol;

  int solToLamports(double value) => (value * lamportsPerSol).round();

  int tokenUiToAmount(double value, int decimals) =>
      (value * _pow10(decimals)).round();

  int _pow10(int value) {
    var result = 1;
    for (var i = 0; i < value; i++) {
      result *= 10;
    }
    return result;
  }

  bool _isMissingMintError(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('could not find mint') ||
        message.contains('invalid param');
  }

  bool _isRetryableRpcError(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('retryable error') ||
        message.contains('http status code 400') && message.contains('429') ||
        message.contains('too many requests') ||
        message.contains('status: 429') ||
        message.contains('timed out');
  }

  SplTokenAccountDataInfo? _readTokenAccountInfo(AccountData? data) {
    if (data is! ParsedAccountData) {
      return null;
    }

    final parsed = switch (data) {
      ParsedSplTokenProgramAccountData(:final parsed) => parsed,
      ParsedSplToken2022ProgramAccountData(:final parsed) => parsed,
      _ => null,
    };
    if (parsed == null) {
      return null;
    }

    return switch (parsed) {
      TokenAccountData(:final info) => info,
      _ => null,
    };
  }

  TokenInfo? _knownSplToken(String mintAddress) {
    if (mintAddress == _usdcMintAddress) {
      return const TokenInfo(
        mintAddress: _usdcMintAddress,
        symbol: 'USDC',
        name: 'USD Coin',
        decimals: 6,
        isNative: false,
        isVisible: true,
      );
    }

    return null;
  }

  List<TokenInfo> get _defaultTrackedTokens => const [
    TokenInfo(
      mintAddress: _usdcMintAddress,
      symbol: 'USDC',
      name: 'USD Coin',
      decimals: 6,
      isNative: false,
      isVisible: true,
    ),
    TokenInfo(
      mintAddress: _solMintAddress,
      symbol: 'SOL',
      name: 'Solana',
      decimals: 9,
      isNative: true,
      isVisible: true,
    ),
  ];

  String _tokenKey(TokenInfo token) =>
      '${token.isNative ? 'native' : 'spl'}:${token.mintAddress}';

  TokenProgramKind _readTokenProgramType(AccountData? data) {
    return switch (data) {
      ParsedSplToken2022ProgramAccountData() =>
        TokenProgramKind.token2022Program,
      _ => TokenProgramKind.tokenProgram,
    };
  }

  TokenProgramType _toSolanaTokenProgramType(TokenProgramKind kind) {
    return switch (kind) {
      TokenProgramKind.token2022Program => TokenProgramType.token2022Program,
      TokenProgramKind.tokenProgram => TokenProgramType.tokenProgram,
    };
  }

  Future<TokenProgramType> _resolveTokenProgramType({
    required RpcClient rpcClient,
    required Ed25519HDPublicKey owner,
    required Ed25519HDPublicKey mint,
    required TokenProgramKind fallback,
  }) async {
    try {
      final mintAccount = await rpcClient.getAccountInfo(
        mint.toBase58(),
        commitment: Commitment.confirmed,
      );
      final mintOwner = mintAccount.value?.owner;
      if (mintOwner == Token2022Program.programId) {
        return TokenProgramType.token2022Program;
      }
      if (mintOwner == TokenProgram.programId) {
        return TokenProgramType.tokenProgram;
      }
    } catch (_) {
      // Fall through to account-based detection if mint lookup fails.
    }

    final fallbackProgram = _toSolanaTokenProgramType(fallback);
    final fallbackAccount = await _getAssociatedTokenAccount(
      rpcClient: rpcClient,
      owner: owner,
      mint: mint,
      tokenProgramType: fallbackProgram,
      commitment: Commitment.confirmed,
    );
    if (fallbackAccount != null) {
      return fallbackProgram;
    }

    for (final candidate in TokenProgramType.values) {
      if (candidate == fallbackProgram) {
        continue;
      }

      final candidateAccount = await _getAssociatedTokenAccount(
        rpcClient: rpcClient,
        owner: owner,
        mint: mint,
        tokenProgramType: candidate,
        commitment: Commitment.confirmed,
      );
      if (candidateAccount != null) {
        return candidate;
      }
    }

    return fallbackProgram;
  }

  String formatTxAmount(double amount) => Formatters.amount(amount);

  Future<RpcClient> _getRpcClient() async {
    final now = DateTime.now().toUtc();
    final sessionManager = _sessionManager;
    if (sessionManager == null) {
      final currentClient = _rpcClient;
      final currentExpiry = _rpcClientExpiresAt;
      if (currentClient != null &&
          currentExpiry != null &&
          now.isBefore(currentExpiry)) {
        return currentClient;
      }

      final rpcClient = RpcClient(
        AppConstants.solanaRpcUrl,
        timeout: const Duration(seconds: 30),
      );
      _rpcClient = rpcClient;
      _rpcClientExpiresAt = now.add(const Duration(minutes: 5));
      _rpcClientOwnerAddress = null;
      return rpcClient;
    }

    final session = await sessionManager.currentSession();
    final currentClient = _rpcClient;
    final currentExpiry = _rpcClientExpiresAt;
    if (currentClient != null &&
        currentExpiry != null &&
        _rpcClientOwnerAddress == session.ownerAddress &&
        now.isBefore(currentExpiry)) {
      return currentClient;
    }

    final rpcClient = RpcClient(
      AppConstants.solanaRpcUrl,
      timeout: const Duration(seconds: 30),
      customHeaders: {'Authorization': 'Bearer ${session.accessToken}'},
    );
    _rpcClient = rpcClient;
    _rpcClientExpiresAt = session.expiresAt;
    _rpcClientOwnerAddress = session.ownerAddress;
    return rpcClient;
  }

  Future<bool> _hasAssociatedTokenAccount({
    required RpcClient rpcClient,
    required Ed25519HDPublicKey owner,
    required Ed25519HDPublicKey mint,
    TokenProgramType tokenProgramType = TokenProgramType.tokenProgram,
    Commitment commitment = Commitment.finalized,
  }) async {
    final account = await _getAssociatedTokenAccount(
      rpcClient: rpcClient,
      owner: owner,
      mint: mint,
      tokenProgramType: tokenProgramType,
      commitment: commitment,
    );
    return account != null;
  }

  Future<ProgramAccount?> _getAssociatedTokenAccount({
    required RpcClient rpcClient,
    required Ed25519HDPublicKey owner,
    required Ed25519HDPublicKey mint,
    TokenProgramType tokenProgramType = TokenProgramType.tokenProgram,
    Commitment commitment = Commitment.finalized,
  }) async {
    final accounts = await rpcClient.getTokenAccountsByOwner(
      owner.toBase58(),
      TokenAccountsFilter.byProgramId(tokenProgramType.programId),
      encoding: Encoding.jsonParsed,
      commitment: commitment,
    );
    final matchingAccounts = accounts.value.where((account) {
      final info = _readTokenAccountInfo(account.account.data);
      return info?.mint == mint.toBase58();
    }).toList();

    if (matchingAccounts.isEmpty) {
      return null;
    }

    final associatedTokenAddress = await findAssociatedTokenAddress(
      owner: owner,
      mint: mint,
      tokenProgramType: tokenProgramType,
    );

    matchingAccounts.sort((left, right) {
      final leftIsAssociated = left.pubkey == associatedTokenAddress.toBase58();
      final rightIsAssociated =
          right.pubkey == associatedTokenAddress.toBase58();
      if (leftIsAssociated != rightIsAssociated) {
        return leftIsAssociated ? -1 : 1;
      }

      final balanceComparison = _tokenAccountRawAmount(
        right,
      ).compareTo(_tokenAccountRawAmount(left));
      if (balanceComparison != 0) {
        return balanceComparison;
      }

      return left.pubkey.compareTo(right.pubkey);
    });

    return matchingAccounts.first;
  }

  Future<List<ProgramAccount>> _loadTokenAccountsByOwner({
    required RpcClient rpcClient,
    required String ownerAddress,
    Commitment commitment = Commitment.finalized,
  }) async {
    final groups = await Future.wait([
      rpcClient.getTokenAccountsByOwner(
        ownerAddress,
        TokenAccountsFilter.byProgramId(TokenProgram.programId),
        commitment: commitment,
        encoding: Encoding.jsonParsed,
      ),
      rpcClient.getTokenAccountsByOwner(
        ownerAddress,
        TokenAccountsFilter.byProgramId(Token2022Program.programId),
        commitment: commitment,
        encoding: Encoding.jsonParsed,
      ),
    ]);

    final accountsByPubkey = <String, ProgramAccount>{};
    for (final group in groups) {
      for (final account in group.value) {
        accountsByPubkey[account.pubkey] = account;
      }
    }

    return accountsByPubkey.values.toList();
  }

  Future<TokenAmount> _getTokenBalance({
    required RpcClient rpcClient,
    required Ed25519HDPublicKey owner,
    required Ed25519HDPublicKey mint,
    TokenProgramType tokenProgramType = TokenProgramType.tokenProgram,
    Commitment commitment = Commitment.finalized,
  }) async {
    final ata = await findAssociatedTokenAddress(
      owner: owner,
      mint: mint,
      tokenProgramType: tokenProgramType,
    );

    return (await rpcClient.getTokenAccountBalance(
      ata.toBase58(),
      commitment: commitment,
    )).value;
  }

  Future<Ed25519HDPublicKey> _resolveRecipientTokenAccountAddress({
    required ProgramAccount? recipientAccount,
    required Ed25519HDPublicKey owner,
    required Ed25519HDPublicKey mint,
    required TokenProgramType tokenProgramType,
    required List<Instruction> instructions,
    required Ed25519HDPublicKey funder,
  }) async {
    if (recipientAccount != null) {
      return Ed25519HDPublicKey.fromBase58(recipientAccount.pubkey);
    }

    final associatedTokenAddress = await findAssociatedTokenAddress(
      owner: owner,
      mint: mint,
      tokenProgramType: tokenProgramType,
    );
    instructions.add(
      AssociatedTokenAccountInstruction.createAccountIdempotent(
        funder: funder,
        address: associatedTokenAddress,
        owner: owner,
        mint: mint,
        tokenProgramId: Ed25519HDPublicKey.fromBase58(
          tokenProgramType.programId,
        ),
      ),
    );
    return associatedTokenAddress;
  }

  List<Instruction> _buildSenderInstructions({
    required Ed25519HDPublicKey owner,
    required List<Instruction> instructions,
  }) {
    return [
      ComputeBudgetInstruction.setComputeUnitLimit(
        units: _senderComputeUnitLimit,
      ),
      ComputeBudgetInstruction.setComputeUnitPrice(
        microLamports: _senderPriorityFeeMicroLamports,
      ),
      ...instructions,
      SystemInstruction.transfer(
        fundingAccount: owner,
        recipientAccount: Ed25519HDPublicKey.fromBase58(
          _randomHeliusTipAccount(),
        ),
        lamports: _senderTipLamports,
      ),
    ];
  }

  String _randomHeliusTipAccount() {
    return _heliusTipAccounts[Random().nextInt(_heliusTipAccounts.length)];
  }

  Future<String> _signAndSubmitViaSender({
    required RpcClient rpcClient,
    required Message message,
    required Ed25519HDKeyPair signer,
    String? txType,
    String? fromMint,
    String? toMint,
    String? amount,
    String? referenceId,
    String? destinationAddress,
  }) async {
    final signedTx = await _signWithLatestBlockhash(
      rpcClient: rpcClient,
      message: message,
      signer: signer,
    );
    final encodedTx = signedTx.encode();
    final backendApiClient = _backendApiClient;
    if (backendApiClient == null) {
      return _broadcastEncodedTransaction(
        rpcClient: rpcClient,
        encodedTransaction: encodedTx,
      );
    }

    return backendApiClient.submitSenderTransaction(
      encodedTransaction: encodedTx,
      txType: txType,
      fromMint: fromMint,
      toMint: toMint,
      amount: amount,
      referenceId: referenceId,
      destinationAddress: destinationAddress,
    );
  }

  Future<String> _compileUnsignedTransaction({
    required RpcClient rpcClient,
    required Message message,
    required Ed25519HDPublicKey feePayer,
  }) async {
    final blockhash = await rpcClient.getLatestBlockhash(
      commitment: Commitment.confirmed,
    );
    final compiled = message.compile(
      recentBlockhash: blockhash.value.blockhash,
      feePayer: feePayer,
    );
    return SignedTx(
      signatures: [Signature(List.filled(64, 0), publicKey: feePayer)],
      compiledMessage: compiled,
    ).encode();
  }

  Future<SignedTx> _signPreparedTransaction({
    required String encodedTransaction,
    required Ed25519HDKeyPair signer,
  }) async {
    final transaction = SignedTx.decode(encodedTransaction);
    final signature = await signer.sign(
      transaction.compiledMessage.toByteArray(),
    );
    final signatures = _injectPrimarySignature(
      existing: transaction.signatures,
      primary: signature,
    );
    return SignedTx(
      signatures: signatures,
      compiledMessage: transaction.compiledMessage,
    );
  }

  List<Signature> _injectPrimarySignature({
    required List<Signature> existing,
    required Signature primary,
  }) {
    if (existing.isEmpty) {
      return [primary];
    }

    return [primary, ...existing.skip(1)];
  }

  Future<String> _broadcastEncodedTransaction({
    required RpcClient rpcClient,
    required String encodedTransaction,
  }) async {
    const retryBackoff = [1000, 2000, 4000];
    Object? lastError;

    for (var attempt = 0; attempt <= retryBackoff.length; attempt++) {
      try {
        return await rpcClient.sendTransaction(
          encodedTransaction,
          preflightCommitment: Commitment.confirmed,
          skipPreflight: false,
          maxRetries: 5,
        );
      } catch (error) {
        lastError = error;
        if (!_isRetryableRpcError(error) || attempt >= retryBackoff.length) {
          break;
        }
        await Future<void>.delayed(
          Duration(milliseconds: retryBackoff[attempt]),
        );
      }
    }

    if (lastError case final Object error) {
      throw error;
    }

    throw StateError('Failed to broadcast transaction');
  }

  BigInt _tokenAccountRawAmount(ProgramAccount account) {
    final info = _readTokenAccountInfo(account.account.data);
    return BigInt.tryParse(info?.tokenAmount.amount ?? '') ?? BigInt.zero;
  }

  Future<void> _waitForConfirmation(
    String signature, {
    Commitment requiredStatus = Commitment.confirmed,
    Duration timeout = const Duration(seconds: 60),
    Duration pollInterval = const Duration(seconds: 1),
  }) async {
    final rpcClient = await _getRpcClient();
    final deadline = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(deadline)) {
      try {
        final statuses = await rpcClient.getSignatureStatuses([
          signature,
        ], searchTransactionHistory: true);
        final status = statuses.value.isEmpty ? null : statuses.value.first;

        if (status != null) {
          if (status.err != null) {
            throw StateError('Transaction failed: ${status.err}');
          }
          if (_matchesCommitment(status.confirmationStatus, requiredStatus)) {
            return;
          }
        }
      } catch (error) {
        if (!_isRetryableRpcError(error)) {
          rethrow;
        }
      }

      await Future<void>.delayed(pollInterval);
    }

    throw TimeoutException('Transaction confirmation timed out');
  }

  bool _matchesCommitment(Commitment current, Commitment required) {
    int rank(Commitment value) => switch (value) {
      Commitment.processed => 0,
      Commitment.confirmed => 1,
      Commitment.finalized => 2,
    };

    return rank(current) >= rank(required);
  }

  Future<SignedTx> _signWithLatestBlockhash({
    required RpcClient rpcClient,
    required Message message,
    required Ed25519HDKeyPair signer,
  }) async {
    const retryBackoff = [500, 1000, 2000];
    Object? lastError;

    for (var attempt = 0; attempt <= retryBackoff.length; attempt++) {
      try {
        return await rpcClient.signMessage(message, [
          signer,
        ], commitment: Commitment.confirmed);
      } catch (error) {
        lastError = error;
        if (!_isRetryableRpcError(error)) {
          rethrow;
        }
        if (attempt >= retryBackoff.length) {
          break;
        }
        await Future<void>.delayed(
          Duration(milliseconds: retryBackoff[attempt]),
        );
      }
    }

    if (lastError case final Object error) {
      throw error;
    }

    throw StateError('Failed to prepare transaction');
  }
}

Future<List<Map<String, Object?>>> _discoverImportCandidatesInIsolate(
  String mnemonic,
) async {
  final derivations = <WalletDerivation>[
    WalletDerivation.standard,
    WalletDerivation.legacy,
    for (var accountIndex = 1; accountIndex < 8; accountIndex += 1)
      WalletDerivation(accountIndex: accountIndex, changeIndex: 0),
    for (var accountIndex = 0; accountIndex < 3; accountIndex += 1)
      WalletDerivation(accountIndex: accountIndex),
  ];

  final seed = bip39.mnemonicToSeed(mnemonic);
  final candidates = <Map<String, Object?>>[];
  for (final derivation in derivations) {
    final keypair = await Ed25519HDKeyPair.fromSeedWithHdPath(
      seed: seed,
      hdPath: derivation.hdPath,
    );
    candidates.add({
      'address': keypair.address,
      'derivation': derivation.toJson(),
    });
  }

  return candidates;
}
