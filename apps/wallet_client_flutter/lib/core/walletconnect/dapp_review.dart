import 'dart:convert';
import 'dart:typed_data';

import '../airgap/sign_in_message.dart';
import '../airgap/solana_message_parser.dart';

/// The colour of a dApp request: green signs with a tap, yellow with a long
/// hold, red only after the user reads the risk and ticks that they accept
/// it. [blocked] requests cannot be signed at all.
enum DappTrust { safe, caution, danger, blocked }

/// What WalletConnect's Verify service says about the site.
enum SiteCheck { verified, unknown, mismatch, scam }

enum DappWarningKind {
  siteScam,
  siteMismatch,
  siteUnknown,
  messageUnreadable,
  messageIsTransaction,
  signInOtherSite,
  signInOtherAccount,
  signInExpired,
  tokenApprove,
  setAuthority,
  assignAccount,
  closeAccount,
  advanceNonce,
  unknownProgram,
  blockedProgram,
  unresolvedAccounts,
  simulationFailed,
  simulationUnavailable,
  highSlippage,
}

class DappWarning {
  const DappWarning(this.kind, this.trust);

  final DappWarningKind kind;
  final DappTrust trust;

  @override
  bool operator ==(Object other) =>
      other is DappWarning && other.kind == kind && other.trust == trust;

  @override
  int get hashCode => Object.hash(kind, trust);
}

/// Balance changes a simulation of the transactions predicts for the
/// signing account. [failed] holds the program error when it would fail.
class SimulationOutcome {
  const SimulationOutcome({
    this.failed,
    this.lamportsChange = 0,
    this.tokenChanges = const {},
  });

  final String? failed;

  /// Native SOL, signed: negative is paid out (fees included).
  final int lamportsChange;

  /// Raw token amounts by mint, signed.
  final Map<String, BigInt> tokenChanges;
}

class DappReview {
  const DappReview(this.trust, this.warnings);

  final DappTrust trust;

  /// Every finding, the worst first.
  final List<DappWarning> warnings;

  bool get canSign => trust != DappTrust.blocked;
}

/// Programs whose instructions are expected from mainstream dApps: their
/// presence alone does not turn a request yellow.
abstract final class KnownDappPrograms {
  static const ids = {
    SolanaPrograms.system,
    SolanaPrograms.token,
    SolanaPrograms.token2022,
    SolanaPrograms.associatedToken,
    SolanaPrograms.computeBudget,
    SolanaPrograms.memo,
    SolanaPrograms.memoV1,
    SolanaPrograms.jupiterV6,
    SolanaPrograms.pumpFun,
    SolanaPrograms.pumpAmm,
    SolanaPrograms.pumpPortal,
    // Raydium AMM v4, CLMM, CPMM
    '675kPX9MHTjS2zt1qfr1NYHuzeLXfQM9H24wFSUt1Mp8',
    'CAMMCzo5YL8w4VFF8KVHrK22GGUsp5VTaW7grrKgrWqK',
    'CPMMoo8L3F4NbTegBCKVNunggL7H1ZpdTHKxQB5qKP1C',
    // Orca Whirlpools
    'whirLbMiicVdio4qvUfM5KAg6Ct8VwpYzGff3uctyCc',
    // Meteora DLMM
    'LBUZKhRxPF3XUpBCjp4YzTKgLccjZhTSDM9YuVaPwxo',
    // Phoenix
    'PhoeNiXZ8ByJGLkxNfZRnkUfjvmuYqLR89jjFHGqdXY',
    // Drift
    'dRiftyHA39MWEi3m9aunc5MzRF1JYuBsbn6VPcn33UH',
    // Metaplex Token Metadata
    'metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s',
    // Lighthouse (wallet-side assertions some dApps add)
    'L2TExMFKdjpN9kozasaurPirfHy9P8sbXoAN1qA3S95',
  };

  /// Core programs the parser fully understands: an instruction of theirs
  /// it cannot decode is suspicious, not merely unfamiliar.
  static const decoded = {
    SolanaPrograms.system,
    SolanaPrograms.token,
    SolanaPrograms.token2022,
  };
}

abstract final class DappReviewer {
  static DappWarning? _site(SiteCheck site) => switch (site) {
    SiteCheck.scam => const DappWarning(
      DappWarningKind.siteScam,
      DappTrust.blocked,
    ),
    SiteCheck.mismatch => const DappWarning(
      DappWarningKind.siteMismatch,
      DappTrust.danger,
    ),
    SiteCheck.unknown => const DappWarning(
      DappWarningKind.siteUnknown,
      DappTrust.caution,
    ),
    SiteCheck.verified => null,
  };

  /// The text of [bytes] when they are printable UTF-8, else null.
  static String? readableText(Uint8List bytes) {
    final String text;
    try {
      text = utf8.decode(bytes);
    } on FormatException {
      return null;
    }
    final control = RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]');
    return control.hasMatch(text) ? null : text;
  }

  /// Reviews a message signature. [siteHost] is the host the request came
  /// from (Verify's origin), compared with a sign-in message's domain.
  static DappReview message({
    required Uint8List bytes,
    required String address,
    required SiteCheck site,
    required String? siteHost,
    DateTime? now,
  }) {
    final warnings = <DappWarning>[?_site(site)];
    final text = readableText(bytes);
    if (SolanaMessageParser.looksLikeTransaction(bytes)) {
      warnings.add(
        const DappWarning(
          DappWarningKind.messageIsTransaction,
          DappTrust.blocked,
        ),
      );
    } else if (text == null) {
      warnings.add(
        const DappWarning(DappWarningKind.messageUnreadable, DappTrust.danger),
      );
    } else {
      final signIn = SolanaSignInMessage.parse(text);
      if (signIn != null) {
        if (signIn.address != address) {
          warnings.add(
            const DappWarning(
              DappWarningKind.signInOtherAccount,
              DappTrust.danger,
            ),
          );
        }
        if (siteHost == null || !_sameSite(signIn.domain, siteHost)) {
          warnings.add(
            const DappWarning(
              DappWarningKind.signInOtherSite,
              DappTrust.danger,
            ),
          );
        }
        if (signIn.isExpiredAt(now ?? DateTime.now())) {
          warnings.add(
            const DappWarning(DappWarningKind.signInExpired, DappTrust.caution),
          );
        }
      }
    }
    return _review(warnings);
  }

  /// Reviews transactions [address] is asked to sign. [simulation] is null
  /// when it could not be run.
  static DappReview transactions({
    required List<ParsedSolanaMessage> messages,
    required String address,
    required SiteCheck site,
    required SimulationOutcome? simulation,
    Set<String> blockedPrograms = const {},
  }) {
    final warnings = <DappWarning>[?_site(site)];
    for (final message in messages) {
      if (message.hasUnresolvedAccounts) {
        warnings.add(
          const DappWarning(
            DappWarningKind.unresolvedAccounts,
            DappTrust.caution,
          ),
        );
      }
      for (final instruction in message.instructions) {
        // On Benny Wallet's blocklist: never signed.
        if (blockedPrograms.contains(instruction.programId)) {
          warnings.add(
            const DappWarning(
              DappWarningKind.blockedProgram,
              DappTrust.blocked,
            ),
          );
        }
        final warning = _instruction(instruction, address);
        if (warning != null) {
          warnings.add(warning);
        }
      }
    }
    if (simulation == null) {
      warnings.add(
        const DappWarning(
          DappWarningKind.simulationUnavailable,
          DappTrust.caution,
        ),
      );
    } else if (simulation.failed != null) {
      warnings.add(
        const DappWarning(DappWarningKind.simulationFailed, DappTrust.danger),
      );
    }
    return _review(warnings);
  }

  static DappWarning? _instruction(ParsedInstruction i, String address) {
    switch (i.kind) {
      case ParsedInstructionKind.tokenApprove:
        return const DappWarning(
          DappWarningKind.tokenApprove,
          DappTrust.danger,
        );
      case ParsedInstructionKind.setAuthority:
        return const DappWarning(
          DappWarningKind.setAuthority,
          DappTrust.danger,
        );
      case ParsedInstructionKind.assignAccount:
        return const DappWarning(
          DappWarningKind.assignAccount,
          DappTrust.danger,
        );
      case ParsedInstructionKind.closeTokenAccount:
        // Closing an empty account to reclaim rent is routine; the
        // simulation shows whether tokens go with it.
        return const DappWarning(
          DappWarningKind.closeAccount,
          DappTrust.caution,
        );
      case ParsedInstructionKind.advanceNonce:
        // A durable nonce keeps a signature valid indefinitely.
        return const DappWarning(
          DappWarningKind.advanceNonce,
          DappTrust.caution,
        );
      case ParsedInstructionKind.swap:
        return i.risk == InstructionRisk.danger
            ? const DappWarning(DappWarningKind.highSlippage, DappTrust.danger)
            : null;
      case ParsedInstructionKind.unknown:
        if (KnownDappPrograms.decoded.contains(i.programId)) {
          return const DappWarning(
            DappWarningKind.unknownProgram,
            DappTrust.danger,
          );
        }
        return KnownDappPrograms.ids.contains(i.programId)
            ? null
            : const DappWarning(
                DappWarningKind.unknownProgram,
                DappTrust.caution,
              );
      default:
        return null;
    }
  }

  static DappReview _review(List<DappWarning> warnings) {
    final unique = warnings.toSet().toList()
      ..sort((a, b) => b.trust.index.compareTo(a.trust.index));
    final trust = unique.isEmpty ? DappTrust.safe : unique.first.trust;
    return DappReview(trust, unique);
  }

  /// A sign-in domain ("app.example.com" or "https://app.example.com") on
  /// the host the request came from.
  static bool _sameSite(String domain, String host) {
    final cleaned = domain
        .toLowerCase()
        .replaceFirst(RegExp(r'^https?://'), '')
        .split('/')
        .first;
    return cleaned == host.toLowerCase();
  }

  /// The host of a site URL, or null when [url] has none.
  static String? hostOf(String? url) {
    if (url == null || url.isEmpty) {
      return null;
    }
    final host = Uri.tryParse(url)?.host ?? '';
    return host.isEmpty ? null : host.toLowerCase();
  }
}
