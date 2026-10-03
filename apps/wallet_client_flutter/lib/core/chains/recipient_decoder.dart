import '../utils/validators.dart';
import 'chain_models.dart';

/// A scanned recipient never changes the network selected by the user.
String? decodeRecipient(
  String rawValue,
  ChainConfig config,
  bool Function(String) validateAddress,
) {
  final trimmed = rawValue.trim();
  if (config.family == ChainFamily.evm) {
    if (validateAddress(trimmed)) return trimmed;
    // Only a plain recipient URI is supported; ERC-20 transfer URIs name the
    // contract first and must not be mistaken for the recipient.
    final match = RegExp(
      r'^ethereum:(0x[0-9a-fA-F]{40})(?:@([0-9]+))?(?:\?.*)?$',
      caseSensitive: false,
    ).firstMatch(trimmed);
    if (match == null) return null;
    final network = match.group(2);
    if (network != null && int.tryParse(network) != config.chainId) return null;
    final address = match.group(1)!;
    return validateAddress(address) ? address : null;
  }
  // Retain the existing Solana QR extraction behavior.
  if (Validators.isValidPublicAddress(trimmed)) return trimmed;
  final uri = Uri.tryParse(trimmed);
  if (uri != null) {
    for (final candidate in <String>{
      if (uri.host.isNotEmpty) uri.host,
      if (uri.path.isNotEmpty) uri.path.replaceFirst('/', ''),
    }) {
      if (Validators.isValidPublicAddress(candidate)) return candidate;
    }
  }
  final fallback = RegExp(
    r'[1-9A-HJ-NP-Za-km-z]{32,44}',
  ).firstMatch(trimmed)?.group(0);
  return fallback != null && Validators.isValidPublicAddress(fallback)
      ? fallback
      : null;
}
