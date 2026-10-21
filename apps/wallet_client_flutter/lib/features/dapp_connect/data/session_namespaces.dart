import 'package:reown_walletkit/reown_walletkit.dart';

import '../../../core/walletconnect/solana_wc_request.dart';

/// Why a connection request cannot be accepted.
enum ProposalProblem { otherChains, noSolana, unsupportedSolanaChain }

/// The Solana chains a dApp asks for, or the reason it cannot connect.
class ProposalChains {
  const ProposalChains._(this.chains, this.problem);

  final List<String> chains;
  final ProposalProblem? problem;

  bool get ok => problem == null;

  /// A dApp on this phone (Mobile Wallet Adapter) names one chain; only
  /// mainnet is served.
  static ProposalChains fromMwaChain(String? chain) =>
      chain == null || chain == 'solana:mainnet' || chain == 'mainnet-beta'
      ? const ProposalChains._([SolanaWc.mainnet], null)
      : const ProposalChains._([], ProposalProblem.unsupportedSolanaChain);

  /// Reads the dApp's required and optional namespaces. Keys are either a
  /// namespace ("solana", chains listed inside) or a chain ("solana:5eyk…").
  static ProposalChains read({
    required Map<String, RequiredNamespace> required,
    required Map<String, RequiredNamespace> optional,
  }) {
    List<String> chainsOf(String key, RequiredNamespace namespace) =>
        key.contains(':') ? [key] : (namespace.chains ?? const []);
    bool isSolana(String key) =>
        key == SolanaWc.namespace || key.startsWith('${SolanaWc.namespace}:');

    final requiredChains = <String>{};
    for (final MapEntry(:key, :value) in required.entries) {
      if (!isSolana(key)) {
        return const ProposalChains._([], ProposalProblem.otherChains);
      }
      requiredChains.addAll(chainsOf(key, value));
    }
    if (requiredChains.any((c) => !SolanaWc.isSupportedChain(c))) {
      return const ProposalChains._([], ProposalProblem.unsupportedSolanaChain);
    }
    final optionalChains = <String>{
      for (final MapEntry(:key, :value) in optional.entries)
        if (isSolana(key)) ...chainsOf(key, value),
    };
    final asked = {...requiredChains, ...optionalChains};
    if (required.isEmpty && !optional.keys.any(isSolana)) {
      return const ProposalChains._([], ProposalProblem.noSolana);
    }
    final chains = asked.where(SolanaWc.isSupportedChain).toList();
    if (chains.isEmpty) {
      // A Solana dApp that names only devnet/testnet, or no chain at all.
      return asked.isEmpty
          ? const ProposalChains._([SolanaWc.mainnet], null)
          : const ProposalChains._([], ProposalProblem.unsupportedSolanaChain);
    }
    return ProposalChains._(chains, null);
  }

  /// The namespaces Benny approves: [address] on each chain.
  Map<String, Namespace> namespacesFor(String address) => {
    SolanaWc.namespace: Namespace(
      chains: chains,
      accounts: SolanaWc.accountsFor(address, chains),
      methods: SolanaWc.methods,
      events: SolanaWc.events,
    ),
  };
}

/// The wallet address a session was approved for.
String? sessionAddress(SessionData session) {
  final accounts = session.namespaces[SolanaWc.namespace]?.accounts ?? const [];
  for (final account in accounts) {
    final parts = account.split(':');
    if (parts.length == 3) {
      return parts[2];
    }
  }
  return null;
}
