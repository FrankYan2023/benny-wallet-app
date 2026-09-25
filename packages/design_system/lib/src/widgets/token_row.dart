import 'package:flutter/material.dart';

class TokenRow extends StatelessWidget {
  const TokenRow({
    super.key,
    required this.name,
    required this.value,
    required this.balanceLine,
    required this.change,
    required this.isPositiveChange,
    required this.symbol,
    this.secondaryValue,
    this.networkLabel,
    this.networkIconAsset,
    this.iconUrl,
    this.onTap,
  });

  final String name;
  final String value;
  final String balanceLine;
  final String change;
  final bool? isPositiveChange;
  final String symbol;
  final String? secondaryValue;
  final String? networkLabel;
  final String? networkIconAsset;
  final String? iconUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryText = theme.colorScheme.onSurface;
    final secondaryText = theme.colorScheme.onSurface.withValues(alpha: 0.58);
    final changeColor = isPositiveChange == null
        ? secondaryText
        : isPositiveChange!
        ? const Color(0xFF30A46C)
        : const Color(0xFFE2562A);
    final normalizedSecondaryValue = _normalizeDetailText(secondaryValue);
    final normalizedChange = _normalizeDetailText(change);
    final shouldRenderStandaloneChange =
        normalizedSecondaryValue == null && normalizedChange != null;

    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            _AvatarStack(
              symbol: symbol,
              iconUrl: iconUrl,
              networkIconAsset: networkIconAsset,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: primaryText,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (networkLabel != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      networkLabel!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: secondaryText,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 2),
                  Text(
                    balanceLine,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: secondaryText,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: primaryText,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (secondaryValue != null) ...[
                  const SizedBox(height: 2),
                  _SecondaryDetailLine(
                    secondaryValue: normalizedSecondaryValue,
                    change: normalizedChange,
                    secondaryTextColor: secondaryText,
                    changeColor: changeColor,
                  ),
                ] else if (shouldRenderStandaloneChange) ...[
                  const SizedBox(height: 2),
                  Text(
                    normalizedChange!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: changeColor,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String? _normalizeDetailText(String? value) {
  if (value == null) {
    return null;
  }

  final trimmed = value.trim();
  if (trimmed.isEmpty || trimmed == '--') {
    return null;
  }

  return trimmed;
}

class _SecondaryDetailLine extends StatelessWidget {
  const _SecondaryDetailLine({
    required this.secondaryValue,
    required this.change,
    required this.secondaryTextColor,
    required this.changeColor,
  });

  final String? secondaryValue;
  final String? change;
  final Color secondaryTextColor;
  final Color changeColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (secondaryValue == null && change == null) {
      return Text(
        '--',
        style: theme.textTheme.bodySmall?.copyWith(
          color: secondaryTextColor,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    if (secondaryValue == null) {
      return Text(
        '$change',
        style: theme.textTheme.bodySmall?.copyWith(
          color: changeColor,
          fontWeight: FontWeight.w700,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    if (change == null) {
      return Text(
        secondaryValue!,
        style: theme.textTheme.bodySmall?.copyWith(
          color: secondaryTextColor,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: secondaryValue,
            style: theme.textTheme.bodySmall?.copyWith(
              color: secondaryTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(
            text: '  $change',
            style: theme.textTheme.bodySmall?.copyWith(
              color: changeColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _AvatarStack extends StatelessWidget {
  const _AvatarStack({
    required this.symbol,
    this.iconUrl,
    this.networkIconAsset,
  });

  final String symbol;
  final String? iconUrl;
  final String? networkIconAsset;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 54,
      height: 54,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(
                  context,
                ).colorScheme.secondaryContainer.withValues(alpha: 0.7),
              ),
              child: _TokenAvatar(symbol: symbol, iconUrl: iconUrl),
            ),
          ),
          if (networkIconAsset != null)
            Positioned(
              right: -1,
              bottom: -1,
              child: Container(
                width: 24,
                height: 24,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.surface,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surface,
                    width: 1.5,
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(
                    networkIconAsset!,
                    fit: BoxFit.cover,
                    excludeFromSemantics: true,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TokenAvatar extends StatelessWidget {
  const _TokenAvatar({required this.symbol, this.iconUrl});

  final String symbol;
  final String? iconUrl;

  static const _iconUrls = {
    'SOL': 'https://assets.coingecko.com/coins/images/4128/large/solana.png',
    'USDC': 'https://assets.coingecko.com/coins/images/6319/large/usdc.png',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedIconUrl = iconUrl ?? _iconUrls[symbol];
    if (resolvedIconUrl == null) {
      return Center(
        child: Text(
          symbol.substring(0, 1),
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
      );
    }

    return ClipOval(
      child: Image.network(
        resolvedIconUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Center(
          child: Text(
            symbol.substring(0, 1),
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}
