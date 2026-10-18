/// A "Sign in with Solana" text message, as Benny's backend sends for its
/// login challenge:
///
/// ```text
/// Benny Wallet wants you to sign in with your Solana account:
/// <address>
///
/// <statement>
///
/// URI: benny-wallet-auth
/// Version: 1
/// ...
/// Expiration Time: 2026-10-18T16:47:15.000Z
/// ```
///
/// Only the text is read; nothing here proves who sent it.
class SolanaSignInMessage {
  const SolanaSignInMessage({
    required this.domain,
    required this.address,
    this.statement,
    this.uri,
    this.expiresAt,
  });

  /// Who asks, as written on the first line ("Benny Wallet").
  final String domain;

  /// The account the message signs in.
  final String address;
  final String? statement;
  final String? uri;
  final DateTime? expiresAt;

  /// Name and audience Benny's backend writes into its login challenge.
  static const bennyDomain = 'Benny Wallet';
  static const bennyUri = 'benny-wallet-auth';

  static final _header = RegExp(
    r'^(.{1,80}) wants you to sign in with your Solana account:$',
  );
  static final _address = RegExp(r'^[1-9A-HJ-NP-Za-km-z]{32,44}$');

  /// The message read from [text], or null when it is not a sign-in
  /// message.
  static SolanaSignInMessage? parse(String text) {
    final lines = text.replaceAll('\r\n', '\n').split('\n');
    if (lines.length < 2) {
      return null;
    }
    final header = _header.firstMatch(lines[0]);
    final address = lines[1].trim();
    if (header == null || !_address.hasMatch(address)) {
      return null;
    }
    String? statement;
    String? uri;
    DateTime? expiresAt;
    for (final line in lines.skip(2)) {
      if (line.startsWith('URI: ')) {
        uri = line.substring(5).trim();
      } else if (line.startsWith('Expiration Time: ')) {
        expiresAt = DateTime.tryParse(line.substring(17).trim());
      } else if (statement == null &&
          line.trim().isNotEmpty &&
          !line.contains(': ') &&
          !line.startsWith('- ') &&
          line != 'Resources:') {
        statement = line.trim();
      }
    }
    return SolanaSignInMessage(
      domain: header.group(1)!.trim(),
      address: address,
      statement: statement,
      uri: uri,
      expiresAt: expiresAt,
    );
  }

  /// A login to Benny Wallet's own service.
  bool get isBenny => domain == bennyDomain && uri == bennyUri;

  bool isExpiredAt(DateTime now) =>
      expiresAt != null && expiresAt!.isBefore(now);
}
