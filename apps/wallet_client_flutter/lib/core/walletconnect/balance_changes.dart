import 'dart:typed_data';

import 'package:solana/base58.dart';

import '../airgap/solana_message_parser.dart';
import 'dapp_review.dart';

/// One account's state before or after a simulated transaction.
class AccountSnapshot {
  const AccountSnapshot({
    required this.lamports,
    required this.programOwner,
    required this.data,
  });

  final int lamports;

  /// The program that owns the account.
  final String programOwner;
  final Uint8List data;
}

abstract final class BalanceChanges {
  /// Token account layout (SPL Token and Token-2022 share it): mint 0..32,
  /// owner 32..64, amount 64..72 (u64 little endian).
  static (String mint, String owner, BigInt amount)? _tokenAccount(
    AccountSnapshot? account,
  ) {
    if (account == null ||
        (account.programOwner != SolanaPrograms.token &&
            account.programOwner != SolanaPrograms.token2022) ||
        account.data.length < 72) {
      return null;
    }
    final data = account.data;
    var amount = BigInt.zero;
    for (var i = 7; i >= 0; i--) {
      amount = (amount << 8) | BigInt.from(data[64 + i]);
    }
    return (
      base58encode(data.sublist(0, 32)),
      base58encode(data.sublist(32, 64)),
      amount,
    );
  }

  /// What [owner] gains or loses between [before] and [after], keyed by
  /// address. A missing entry is an account that does not exist.
  static SimulationOutcome compute({
    required String owner,
    required Map<String, AccountSnapshot?> before,
    required Map<String, AccountSnapshot?> after,
  }) {
    final lamports =
        (after[owner]?.lamports ?? 0) - (before[owner]?.lamports ?? 0);
    final tokens = <String, BigInt>{};
    for (final address in {...before.keys, ...after.keys}) {
      if (address == owner) {
        continue;
      }
      final pre = _tokenAccount(before[address]);
      final post = _tokenAccount(after[address]);
      // A token account counts while the owner holds it on either side, so
      // tokens moved out by a change of owner still show as lost.
      final mint = post?.$1 ?? pre?.$1;
      if (mint == null) {
        continue;
      }
      final preAmount = pre != null && pre.$2 == owner ? pre.$3 : BigInt.zero;
      final postAmount = post != null && post.$2 == owner
          ? post.$3
          : BigInt.zero;
      final change = postAmount - preAmount;
      if (change != BigInt.zero) {
        tokens[mint] = (tokens[mint] ?? BigInt.zero) + change;
      }
    }
    tokens.removeWhere((_, change) => change == BigInt.zero);
    return SimulationOutcome(lamportsChange: lamports, tokenChanges: tokens);
  }

  /// Sums the outcomes of transactions simulated one by one.
  static SimulationOutcome combine(List<SimulationOutcome> outcomes) {
    var lamports = 0;
    final tokens = <String, BigInt>{};
    for (final outcome in outcomes) {
      if (outcome.failed != null) {
        return outcome;
      }
      lamports += outcome.lamportsChange;
      outcome.tokenChanges.forEach((mint, change) {
        tokens[mint] = (tokens[mint] ?? BigInt.zero) + change;
      });
    }
    tokens.removeWhere((_, change) => change == BigInt.zero);
    return SimulationOutcome(lamportsChange: lamports, tokenChanges: tokens);
  }
}
