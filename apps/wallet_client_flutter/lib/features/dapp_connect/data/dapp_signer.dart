import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_types/shared_types.dart';
import 'package:solana/base58.dart';
import 'package:solana/solana.dart' show Ed25519HDPublicKey, verifySignature;

import '../../../app/di/providers.dart';
import '../../../core/airgap/airgap_protocol.dart';
import '../../../core/airgap/solana_message_parser.dart';
import '../../../core/walletconnect/balance_changes.dart';
import '../../../core/walletconnect/dapp_review.dart';
import '../../../core/walletconnect/raw_transaction.dart';
import '../../../core/walletconnect/solana_wc_request.dart';
import '../../auth/domain/wallet_controller_state.dart';
import '../../auth/presentation/providers/ephemeral_store.dart';
import '../../auth/presentation/providers/wallet_controller.dart';
import 'dapp_blocklist.dart';

/// Custodies that can sign for a website in this version.
bool canConnectDapps(WalletCustody custody) =>
    custody == WalletCustody.localMnemonic ||
    custody == WalletCustody.seedVault ||
    custody == WalletCustody.airGap;

/// What the review page shows: the decoded request and its findings.
class PreparedDappRequest {
  const PreparedDappRequest({
    required this.request,
    required this.review,
    this.messages = const [],
    this.simulation,
  });

  final DappSignRequest request;
  final DappReview review;
  final List<ParsedSolanaMessage> messages;
  final SimulationOutcome? simulation;
}

/// Decodes, reviews and signs dApp requests with the wallet's own keys.
class DappSigner {
  DappSigner(this._ref);

  final Ref _ref;

  /// Decodes [params] and works out the trust colour. Lookup tables and the
  /// simulation are fetched from the RPC; when that fails the review says
  /// so instead of failing.
  Future<PreparedDappRequest> prepare({
    required String method,
    required Object? params,
    required String address,
    required SiteCheck site,
    required String? siteHost,
  }) async {
    final request = DappSignRequest.parse(
      method: method,
      params: params,
      address: address,
    );
    // A site on Benny Wallet's blocklist is treated as a known scam.
    final blocklist = await _ref.read(dappBlocklistProvider).refresh();
    if (blocklist.blocksHost(siteHost)) {
      site = SiteCheck.scam;
    }
    if (request.kind == DappRequestKind.message) {
      return PreparedDappRequest(
        request: request,
        review: DappReviewer.message(
          bytes: request.message!,
          address: address,
          site: site,
          siteHost: siteHost,
        ),
      );
    }

    final solana = _ref.read(solanaWalletServiceProvider);
    final messages = <ParsedSolanaMessage>[];
    for (final transaction in request.transactions) {
      var parsed = SolanaMessageParser.parse(transaction.message);
      if (parsed.usesLookupTables) {
        try {
          final tables = await solana.fetchLookupTableEntries(
            parsed.lookupReferences,
          );
          parsed = SolanaMessageParser.parse(
            transaction.message,
            lookupTables: tables,
          );
        } on Object {
          // Shown as unresolved accounts.
        }
      }
      messages.add(parsed);
    }

    SimulationOutcome? simulation;
    try {
      simulation = await _simulate(
        transactions: request.transactions,
        messages: messages,
        address: address,
      );
    } on Object {
      simulation = null;
    }

    return PreparedDappRequest(
      request: request,
      review: DappReviewer.transactions(
        messages: messages,
        address: address,
        site: site,
        simulation: simulation,
        blockedPrograms: blocklist.programs,
      ),
      messages: messages,
      simulation: simulation,
    );
  }

  Future<SimulationOutcome> _simulate({
    required List<RawTransaction> transactions,
    required List<ParsedSolanaMessage> messages,
    required String address,
  }) async {
    final solana = _ref.read(solanaWalletServiceProvider);
    final outcomes = <SimulationOutcome>[];
    for (var i = 0; i < transactions.length; i++) {
      // The owner first, then every account the transaction touches that
      // could hold the owner's tokens (programs excluded); RPCs cap the list.
      final programs = {
        for (final ix in messages[i].instructions) ix.programId,
      };
      final addresses = <String>{
        address,
        ...messages[i].accountKeys.where((k) => !programs.contains(k)),
      }.take(64).toList();
      final (before, after, error) = await solana.simulateAccounts(
        transaction: transactions[i].bytes,
        addresses: addresses,
      );
      if (error != null) {
        // Later transactions often depend on earlier ones, which a
        // one-by-one simulation cannot reproduce.
        if (i == 0) {
          return SimulationOutcome(failed: error);
        }
        throw StateError('Simulation of a dependent transaction failed.');
      }
      outcomes.add(
        BalanceChanges.compute(owner: address, before: before, after: after),
      );
    }
    return BalanceChanges.combine(outcomes);
  }

  /// Signs [prepared] for [address] and returns the JSON-RPC result.
  /// Switches the active wallet for the signature when another one is
  /// selected, and switches back afterwards.
  Future<Object> sign({
    required PreparedDappRequest prepared,
    required String address,
    AirGapDappSource? source,
    DateTime? requestedAt,
    Duration? requestWindow,
  }) async {
    final controller = _ref.read(walletControllerProvider.notifier);
    final previous = _ref.read(walletControllerProvider).publicKey;
    if (previous != address) {
      await controller.selectWallet(address);
    }
    try {
      return await _signActive(
        prepared,
        address,
        source,
        requestedAt,
        requestWindow,
      );
    } finally {
      if (previous != null && previous != address) {
        try {
          await controller.selectWallet(previous);
        } on Object {
          // The signed wallet stays selected.
        }
      }
    }
  }

  Future<Object> _signActive(
    PreparedDappRequest prepared,
    String address,
    AirGapDappSource? source,
    DateTime? requestedAt,
    Duration? requestWindow,
  ) async {
    final state = _ref.read(walletControllerProvider);
    if (state.publicKey != address || !state.isUnlocked) {
      throw StateError('Unlock the wallet again before signing.');
    }
    final request = prepared.request;
    final payloads = request.kind == DappRequestKind.message
        ? [request.message!]
        : [for (final t in request.transactions) t.message];
    final signatures = await _signPayloads(
      state,
      payloads,
      prepared,
      source,
      requestedAt,
      requestWindow,
    );

    final publicKey = Ed25519HDPublicKey.fromBase58(address);
    for (var i = 0; i < payloads.length; i++) {
      final valid = await verifySignature(
        message: payloads[i],
        signature: signatures[i],
        publicKey: publicKey,
      );
      if (!valid) {
        throw StateError('The wallet returned an invalid signature.');
      }
    }

    switch (request.kind) {
      case DappRequestKind.message:
        return DappSignResult.message(signatures.single);
      case DappRequestKind.transaction:
        final signed = request.transactions.single.withSignature(
          address,
          signatures.single,
        );
        return DappSignResult.transaction(signed, signatures.single);
      case DappRequestKind.allTransactions:
        return DappSignResult.allTransactions([
          for (var i = 0; i < request.transactions.length; i++)
            request.transactions[i].withSignature(address, signatures[i]),
        ]);
      case DappRequestKind.signAndSend:
        final transaction = request.transactions.single;
        final signed = transaction.withSignature(address, signatures.single);
        final parsed = RawTransaction.parse(signed);
        for (var i = 0; i < parsed.requiredSigners.length; i++) {
          if (parsed.signatureAt(i) == null) {
            throw StateError('Another party still has to sign.');
          }
        }
        final txSignature = await _ref
            .read(solanaWalletServiceProvider)
            .broadcastSignedTransaction(signed);
        return DappSignResult.sent(txSignature);
    }
  }

  Future<List<Uint8List>> _signPayloads(
    WalletControllerState state,
    List<Uint8List> payloads,
    PreparedDappRequest prepared,
    AirGapDappSource? source,
    DateTime? requestedAt,
    Duration? requestWindow,
  ) async {
    switch (state.custody) {
      case WalletCustody.localMnemonic:
        String? mnemonic;
        if (state.mnemonicTokenId != null) {
          mnemonic = _ref
              .read(mnemonicEphemeralStoreProvider)
              .retrieveTemporary(state.mnemonicTokenId!);
        } else {
          mnemonic = state.mnemonic;
        }
        if (mnemonic == null) {
          throw StateError('Unlock the wallet again before signing.');
        }
        final solana = _ref.read(solanaWalletServiceProvider);
        return [
          for (final payload in payloads)
            await solana.signBytes(
              mnemonic: mnemonic,
              bytes: payload,
              derivation: state.derivation,
            ),
        ];
      case WalletCustody.seedVault:
        final authToken = state.mwaAuthToken;
        final derivationPath = state.seedVaultDerivationPath;
        if (authToken == null ||
            authToken.isEmpty ||
            derivationPath == null ||
            derivationPath.isEmpty) {
          throw StateError('Connect Seed Vault again before signing.');
        }
        final result = await _ref
            .read(mobileWalletAdapterServiceProvider)
            .signSeedVaultMessages(
              authToken: authToken,
              derivationPath: derivationPath,
              messages: payloads,
              ownerAddress: state.publicKey,
              onAccountChanged: (newToken, newPath) => _ref
                  .read(walletControllerProvider.notifier)
                  .updateSeedVaultAccount(
                    publicKey: state.publicKey!,
                    oldToken: authToken,
                    newToken: newToken,
                    derivationPath: newPath,
                  ),
            );
        if (result.signatures.length != payloads.length) {
          throw StateError(
            'Seed Vault returned an unexpected signature count.',
          );
        }
        return [
          for (final s in result.signatures)
            Uint8List.fromList(base58decode(s)),
        ];
      case WalletCustody.airGap:
        final transactions = prepared.request.kind != DappRequestKind.message;
        final simulation = prepared.simulation;
        return _ref
            .read(airGapSigningServiceProvider)
            .signDappPayloads(
              ownerAddress: state.publicKey!,
              payloads: payloads,
              transactions: transactions,
              source: source ?? const AirGapDappSource(host: '?'),
              tokens: await _tokensFor(prepared),
              requestedAt: requestedAt,
              window: requestWindow,
              simulation: simulation == null || simulation.failed != null
                  ? null
                  : AirGapSimulation(
                      lamports: BigInt.from(simulation.lamportsChange),
                      tokens: [
                        for (final MapEntry(:key, :value)
                            in simulation.tokenChanges.entries)
                          AirGapBalanceChange(
                            mint: Uint8List.fromList(base58decode(key)),
                            amount: value,
                          ),
                      ],
                    ),
            );
      case WalletCustody.mobileWalletAdapter:
        throw UnsupportedError('This wallet cannot sign for websites yet.');
    }
  }

  /// Catalog tokens the transactions touch, with the attestations that let
  /// the signer show them as verified.
  Future<List<TokenInfo>> _tokensFor(PreparedDappRequest prepared) async {
    final mints = {
      for (final message in prepared.messages)
        for (final instruction in message.instructions)
          if (instruction.mint != null) instruction.mint!,
      ...?prepared.simulation?.tokenChanges.keys,
    };
    if (mints.isEmpty) {
      return const [];
    }
    try {
      final catalog = await _ref.read(backendApiClientProvider).getTokens();
      return [
        for (final item in catalog)
          if (mints.contains(item.mintAddress))
            TokenInfo(
              mintAddress: item.mintAddress,
              symbol: item.symbol,
              name: item.name,
              decimals: item.decimals,
              isNative: item.isNative,
              isVisible: item.isVisible,
              signerAttestation: item.signerAttestation,
            ),
      ];
    } on Object {
      // The signer then shows these tokens as unverified.
      return const [];
    }
  }
}

final dappSignerProvider = Provider<DappSigner>(DappSigner.new);
