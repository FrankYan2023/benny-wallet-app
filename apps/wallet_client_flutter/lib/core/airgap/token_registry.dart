import 'package:solana/base58.dart';

import 'airgap_protocol.dart';
import 'builtin_token_list.dart';
import 'token_attestation.dart';

class SignerToken {
  const SignerToken({
    required this.mint,
    required this.symbol,
    required this.name,
    required this.decimals,
  });

  final String mint;
  final String symbol;
  final String name;
  final int decimals;
}

enum TokenTrust {
  /// In the token list shipped with this signer, or signed with the Benny
  /// token key.
  verified,

  /// Named by the online wallet without a valid signature. The name is
  /// shown, marked as unchecked.
  walletProvided,

  /// Not known; only the mint address can be shown.
  unverified,
}

class ResolvedToken {
  const ResolvedToken({required this.mint, required this.trust, this.token});

  final String mint;
  final TokenTrust trust;
  final SignerToken? token;

  int? get decimals => token?.decimals;

  bool get isVerified => trust == TokenTrust.verified;
}

/// Token names the offline signer trusts: the built-in list and tokens
/// signed with the pinned Benny token key. Other names from the online
/// phone are shown only as unchecked. See the design doc, "代币识别与更新".
class TokenRegistry {
  TokenRegistry({List<SignerToken> tokens = builtinTokens, int? version})
    : version = version ?? builtinTokenListVersion,
      _byMint = {for (final token in tokens) token.mint: token},
      _provided = const {};

  TokenRegistry._(this.version, this._byMint, this._provided);

  final int version;
  final Map<String, SignerToken> _byMint;
  final Map<String, SignerToken> _provided;

  /// This registry plus the tokens a request names in [hints]. Only mints in
  /// [mints] (the transaction's accounts) are taken. A hint signed with the
  /// Benny token key counts as verified; any other only adds an unchecked
  /// name. Built-in names always win.
  Future<TokenRegistry> withHints(
    List<AirGapTokenHint> hints, {
    required Set<String> mints,
    List<String> keys = TokenAttestation.trustedKeys,
  }) async {
    if (hints.isEmpty) {
      return this;
    }
    final verified = Map.of(_byMint);
    final provided = Map.of(_provided);
    for (final hint in hints) {
      final mint = base58encode(hint.mint);
      if (!mints.contains(mint) || verified.containsKey(mint)) {
        continue;
      }
      // No real token has more; such amounts would render as ~0.
      if (hint.decimals < 0 || hint.decimals > maxDecimals) {
        continue;
      }
      final token = SignerToken(
        mint: mint,
        symbol: hint.symbol,
        name: hint.name,
        decimals: hint.decimals,
      );
      final attestation = hint.attestation;
      final signed =
          attestation != null &&
          await TokenAttestation.verify(
            mint: mint,
            symbol: hint.symbol,
            name: hint.name,
            decimals: hint.decimals,
            signature: attestation,
            keys: keys,
          );
      if (signed) {
        verified[mint] = token;
        provided.remove(mint);
      } else {
        provided[mint] = token;
      }
    }
    return TokenRegistry._(version, verified, provided);
  }

  static const wrappedSolMint = 'So11111111111111111111111111111111111111112';

  /// Hints with more decimals are ignored.
  static const maxDecimals = 18;

  /// This registry with [mints] no longer vouched for: their names are kept
  /// but shown as unchecked. Used for mints whose address in a transaction
  /// is only the wallet's word (read from a lookup table).
  TokenRegistry withUnchecked(Set<String> mints) {
    if (mints.isEmpty) {
      return this;
    }
    final verified = Map.of(_byMint);
    final provided = Map.of(_provided);
    for (final mint in mints) {
      final token = verified.remove(mint);
      if (token != null) {
        provided[mint] = token;
      }
    }
    return TokenRegistry._(version, verified, provided);
  }

  ResolvedToken resolve(String mint) {
    final token = _byMint[mint];
    if (token != null) {
      return ResolvedToken(
        mint: mint,
        trust: TokenTrust.verified,
        token: token,
      );
    }
    final provided = _provided[mint];
    return ResolvedToken(
      mint: mint,
      trust: provided == null
          ? TokenTrust.unverified
          : TokenTrust.walletProvided,
      token: provided,
    );
  }
}
