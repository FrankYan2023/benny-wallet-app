import 'package:flutter/material.dart';

import '../chains/chain_models.dart';
import '../chains/solana_adapter.dart';

/// Local network artwork shared by selectors, labels and transaction history.
class NetworkIcon extends StatelessWidget {
  const NetworkIcon({super.key, this.iconAsset, this.size = 22, this.color});
  final String? iconAsset;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) => iconAsset == null
      ? Icon(Icons.public_rounded, size: size, color: color)
      : ClipOval(
          child: Image.asset(
            iconAsset!,
            width: size,
            height: size,
            fit: BoxFit.cover,
            excludeFromSemantics: true,
            errorBuilder: (_, _, _) =>
                Icon(Icons.public_rounded, size: size, color: color),
          ),
        );
}

class NetworkBadge extends StatelessWidget {
  const NetworkBadge({
    super.key,
    required this.name,
    this.iconAsset,
    this.compact = true,
    this.style,
    this.alignment = MainAxisAlignment.start,
  });
  NetworkBadge.fromConfig(
    ChainConfig config, {
    super.key,
    this.compact = true,
    this.style,
    this.alignment = MainAxisAlignment.start,
  }) : name = config.displayName,
       iconAsset = config.iconAsset;

  /// Legacy portfolio/history endpoints are explicitly Solana-only.
  NetworkBadge.solana({
    super.key,
    this.compact = true,
    this.style,
    this.alignment = MainAxisAlignment.start,
  }) : name = SolanaAdapter.chainConfig.displayName,
       iconAsset = SolanaAdapter.chainConfig.iconAsset;

  final String name;
  final String? iconAsset;
  final bool compact;
  final TextStyle? style;
  final MainAxisAlignment alignment;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: alignment,
    children: [
      NetworkIcon(iconAsset: iconAsset, size: compact ? 16 : 24),
      SizedBox(width: compact ? 6 : 10),
      Flexible(
        child: Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style:
              style ??
              (compact
                  ? Theme.of(context).textTheme.bodySmall
                  : Theme.of(context).textTheme.titleMedium),
        ),
      ),
    ],
  );
}
