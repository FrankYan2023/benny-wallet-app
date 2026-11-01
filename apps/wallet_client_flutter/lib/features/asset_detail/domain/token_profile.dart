/// A further page about a coin (a launchpad, an explorer).
typedef TokenLink = ({String label, String url});

/// A coin's description and links (from CoinGecko, through the backend;
/// Benny Coin's are Benny's own).
class TokenProfile {
  const TokenProfile({
    required this.categories,
    required this.sources,
    this.description,
    this.website,
    this.twitter,
    this.whitepaper,
    this.github,
    this.genesisDate,
    this.links = const [],
  });

  final String? description;
  final String? website;
  final String? twitter;
  final String? whitepaper;
  final String? github;
  final List<String> categories;

  /// Launch date, when the coin has one on record.
  final DateTime? genesisDate;
  final List<String> sources;
  final List<TokenLink> links;

  static TokenProfile fromJson(Map<String, dynamic> json) {
    List<String> strings(String key) => [
      for (final value in json[key] as List<dynamic>? ?? const [])
        if (value is String && value.trim().isNotEmpty) value,
    ];
    String? text(String key) {
      final value = (json[key] as String?)?.trim();
      return value == null || value.isEmpty ? null : value;
    }

    return TokenProfile(
      description: text('description'),
      website: text('website'),
      twitter: text('twitter'),
      whitepaper: text('whitepaper'),
      github: text('github'),
      categories: strings('categories'),
      genesisDate: DateTime.tryParse(json['genesisDate'] as String? ?? ''),
      sources: strings('sources'),
      links: [
        for (final link in json['links'] as List<dynamic>? ?? const [])
          if (link is Map &&
              link['label'] is String &&
              link['url'] is String &&
              (link['url'] as String).startsWith('https://'))
            (label: link['label'] as String, url: link['url'] as String),
      ],
    );
  }
}
