import '../airgap/solana_message_parser.dart';

/// What a dApp transaction does, as far as its programs tell.
enum DappActionKind { swap, transfer, stake, lend, perps, nft, other }

/// A program Benny can name, and the kind of action it stands for (null for
/// plumbing such as the token or compute budget programs).
typedef DappProgram = ({String name, DappActionKind? kind});

abstract final class DappPrograms {
  static const Map<String, DappProgram> known = {
    // Plumbing: present in almost every transaction.
    SolanaPrograms.system: (name: 'System Program', kind: null),
    SolanaPrograms.token: (name: 'Token Program', kind: null),
    SolanaPrograms.token2022: (name: 'Token-2022', kind: null),
    SolanaPrograms.associatedToken: (
      name: 'Associated Token Account',
      kind: null,
    ),
    SolanaPrograms.computeBudget: (name: 'Compute Budget', kind: null),
    SolanaPrograms.memo: (name: 'Memo', kind: null),
    SolanaPrograms.memoV1: (name: 'Memo (v1)', kind: null),
    'L2TExMFKdjpN9kozasaurPirfHy9P8sbXoAN1qA3S95': (
      name: 'Lighthouse (safety checks)',
      kind: null,
    ),
    // Swaps.
    SolanaPrograms.jupiterV6: (name: 'Jupiter', kind: DappActionKind.swap),
    '61DFfeTKM7trxYcPQCM78bJ794ddZprZpAwAnLiwTpYH': (
      name: 'Jupiter Order Engine',
      kind: DappActionKind.swap,
    ),
    'jupoNjAxXgZ4rjzxzPMP4oxduvQsQtZzyknqvzYNrNu': (
      name: 'Jupiter Limit Order',
      kind: DappActionKind.swap,
    ),
    'DCA265Vj8a9CEuX1eb1LWRnDT7uK6q1xMipnNyatn23M': (
      name: 'Jupiter DCA',
      kind: DappActionKind.swap,
    ),
    '675kPX9MHTjS2zt1qfr1NYHuzeLXfQM9H24wFSUt1Mp8': (
      name: 'Raydium AMM',
      kind: DappActionKind.swap,
    ),
    'CAMMCzo5YL8w4VFF8KVHrK22GGUsp5VTaW7grrKgrWqK': (
      name: 'Raydium CLMM',
      kind: DappActionKind.swap,
    ),
    'CPMMoo8L3F4NbTegBCKVNunggL7H1ZpdTHKxQB5qKP1C': (
      name: 'Raydium CPMM',
      kind: DappActionKind.swap,
    ),
    'whirLbMiicVdio4qvUfM5KAg6Ct8VwpYzGff3uctyCc': (
      name: 'Orca Whirlpools',
      kind: DappActionKind.swap,
    ),
    'LBUZKhRxPF3XUpBCjp4YzTKgLccjZhTSDM9YuVaPwxo': (
      name: 'Meteora DLMM',
      kind: DappActionKind.swap,
    ),
    'Eo7WjKq67rjJQSZxS6z3YkapzY3eMj6Xy8X5EQVn5UaB': (
      name: 'Meteora Pools',
      kind: DappActionKind.swap,
    ),
    'PhoeNiXZ8ByJGLkxNfZRnkUfjvmuYqLR89jjFHGqdXY': (
      name: 'Phoenix',
      kind: DappActionKind.swap,
    ),
    SolanaPrograms.pumpFun: (name: 'pump.fun', kind: DappActionKind.swap),
    SolanaPrograms.pumpAmm: (name: 'PumpSwap', kind: DappActionKind.swap),
    SolanaPrograms.pumpPortal: (name: 'PumpPortal', kind: DappActionKind.swap),
    // Perpetuals.
    'dRiftyHA39MWEi3m9aunc5MzRF1JYuBsbn6VPcn33UH': (
      name: 'Drift',
      kind: DappActionKind.perps,
    ),
    // Staking.
    'Stake11111111111111111111111111111111111111': (
      name: 'Stake Program',
      kind: DappActionKind.stake,
    ),
    'MarBmsSgKXdrN1egZf5sqe1TMai9K1rChYNDJgjq7aD': (
      name: 'Marinade',
      kind: DappActionKind.stake,
    ),
    'SPoo1Ku8WFXoNDMHPsrGSTSG1Y47rzgn41SLUNakuHy': (
      name: 'Stake Pool (Jito and others)',
      kind: DappActionKind.stake,
    ),
    // Lending.
    'KLend2g3cP87fffoy8q1mQqGKjrxjC8boSyAYavgmjD': (
      name: 'Kamino Lend',
      kind: DappActionKind.lend,
    ),
    // NFTs.
    'metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s': (
      name: 'Metaplex',
      kind: DappActionKind.nft,
    ),
    'M2mx93ekt1fmXSVkTrUL9xVFHkmME8HTUi5Cyc5aF7K': (
      name: 'Magic Eden',
      kind: DappActionKind.nft,
    ),
    'TSWAPaqyCSx2KABk68Shruf4rp7CxcNi8hAsbdwmHbN': (
      name: 'Tensor',
      kind: DappActionKind.nft,
    ),
  };

  static String? nameOf(String programId) => known[programId]?.name;
}

/// The action a set of transactions performs: the kind, the protocol that
/// decides it (null for a plain transfer or an unknown action), and the
/// programs Benny cannot name.
typedef DappAction = ({
  DappActionKind kind,
  String? protocol,
  List<String> unknownPrograms,
});

abstract final class DappActions {
  /// Order in which a kind wins when several appear (a swap that also
  /// stakes is shown as a swap).
  static const _priority = [
    DappActionKind.swap,
    DappActionKind.perps,
    DappActionKind.lend,
    DappActionKind.stake,
    DappActionKind.nft,
  ];

  static DappAction classify(List<ParsedSolanaMessage> messages) {
    final programs = <String>[
      for (final m in messages)
        for (final i in m.instructions) i.programId,
    ];
    final unknown = {
      for (final p in programs)
        if (!DappPrograms.known.containsKey(p)) p,
    }.toList();
    for (final kind in _priority) {
      for (final p in programs) {
        final known = DappPrograms.known[p];
        if (known?.kind == kind) {
          return (kind: kind, protocol: known!.name, unknownPrograms: unknown);
        }
      }
    }
    final transfers = messages.any(
      (m) => m.instructions.any(
        (i) =>
            i.kind == ParsedInstructionKind.solTransfer ||
            i.kind == ParsedInstructionKind.tokenTransfer,
      ),
    );
    if (transfers && unknown.isEmpty) {
      return (
        kind: DappActionKind.transfer,
        protocol: null,
        unknownPrograms: unknown,
      );
    }
    return (
      kind: DappActionKind.other,
      protocol: null,
      unknownPrograms: unknown,
    );
  }
}
