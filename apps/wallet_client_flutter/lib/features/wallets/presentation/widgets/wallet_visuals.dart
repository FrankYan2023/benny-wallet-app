import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../l10n/l10n.dart';
import '../../../auth/domain/wallet_controller_state.dart';

/// Warm palette shared with the settings tiles so wallet UI matches the app.
abstract final class WalletPalette {
  static const tile = Color(0xFFF7F1E7);
  static const tileSelected = Color(0xFFF8E8B8);
  static const ink = Color(0xFF2D2A23);
  static const muted = Color(0xFF8A7D6A);
  static const accent = Color(0xFFA46708);
  static const accentDeep = Color(0xFF8A5B09);
  static const danger = Color(0xFFCC6A4A);

  static const _avatarColors = [
    Color(0xFFA46708),
    Color(0xFF4096C9),
    Color(0xFF4E7A52),
    Color(0xFF6C63FF),
    Color(0xFFCC6A4A),
    Color(0xFF235E7A),
  ];

  /// Stable per-wallet color so a wallet is recognizable at a glance.
  static Color avatarColor(String publicKey) {
    var hash = 0;
    for (final unit in publicKey.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return _avatarColors[hash % _avatarColors.length];
  }
}

String walletDisplayName(WalletSummary wallet) {
  final name = wallet.name.trim();
  return name.isEmpty ? Formatters.compactAddress(wallet.publicKey) : name;
}

String walletShortAddress(String publicKey) =>
    Formatters.compactAddress(publicKey, visibleChars: 4);

/// Wallet initial with the Solana chain subscript, the same
/// badge token icons carry.
class WalletAvatar extends StatelessWidget {
  const WalletAvatar({
    super.key,
    required this.wallet,
    this.size = 40,
    this.ringColor = WalletPalette.tile,
  });

  final WalletSummary wallet;
  final double size;

  /// Background behind the avatar, so the badge ring blends in.
  final Color ringColor;

  @override
  Widget build(BuildContext context) {
    final color = WalletPalette.avatarColor(wallet.publicKey);
    final name = walletDisplayName(wallet);
    final initial = name.isEmpty ? '?' : name.characters.first.toUpperCase();

    return ChainBadged(
      size: size,
      ringColor: ringColor,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.16),
          shape: BoxShape.circle,
        ),
        child: Text(
          initial,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w900,
            fontSize: size * 0.42,
            height: 1,
          ),
        ),
      ),
    );
  }
}

/// Row subtitle: chain mark and short address. The wallet type sits next to
/// the name (see [WalletTypeTag]).
class WalletTypeLabel extends StatelessWidget {
  const WalletTypeLabel({super.key, required this.wallet});

  final WalletSummary wallet;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: WalletPalette.muted,
      fontSize: 13,
      fontWeight: FontWeight.w600,
    );
    return Row(
      children: [
        const SolanaChainMark(size: 13),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            walletShortAddress(wallet.publicKey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ),
      ],
    );
  }
}

/// Small pill after the wallet name: "Standard", an "S" mark for Seeker
/// (Seed Vault) wallets, or a shield for offline-signer wallets.
class WalletTypeTag extends StatelessWidget {
  const WalletTypeTag({super.key, required this.wallet});

  final WalletSummary wallet;

  static const _seedColor = Color(0xFF235E7A);
  static const _signerColor = Color(0xFF854F00);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final signer = wallet.custody == WalletCustody.airGap;
    final seeker = wallet.isExternal && !signer;
    final color = signer
        ? _signerColor
        : seeker
        ? _seedColor
        : WalletPalette.muted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // External wallets show just a mark; the name says enough.
          if (signer)
            Semantics(
              label: l10n.walletAddAirGap,
              child: Icon(Icons.security_rounded, size: 13, color: color),
            )
          else if (seeker)
            Semantics(
              label: l10n.walletTypeSeedVault,
              child: SeekerMark(size: 13, color: color),
            )
          else
            Text(
              l10n.walletTypeStandard,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 11,
                height: 1.2,
              ),
            ),
        ],
      ),
    );
  }
}

/// Seeker / Seed Vault mark: a bold "S", kept apart from the signer shield.
class SeekerMark extends StatelessWidget {
  const SeekerMark({super.key, this.size = 18, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final ink = color ?? IconTheme.of(context).color ?? Colors.black;
    return SizedBox.square(
      dimension: size,
      child: Center(
        child: Text(
          'S',
          style: TextStyle(
            color: ink,
            fontSize: size * 0.92,
            height: 1,
            fontWeight: FontWeight.w900,
            fontFamily: 'Sora',
          ),
        ),
      ),
    );
  }
}

class WalletBadge extends StatelessWidget {
  const WalletBadge({super.key, required this.label, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final badgeColor = color ?? WalletPalette.accentDeep;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: badgeColor,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

/// Drag-handle sheet container used by the settings pickers.
class WalletSheetFrame extends StatelessWidget {
  const WalletSheetFrame({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxHeight = MediaQuery.sizeOf(context).height * 0.82;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        top: false,
        child: ListView(
          shrinkWrap: true,
          children: [
            Align(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.displaySmall,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// Rounded cream row matching `_SettingsActionTile`.
class WalletActionRow extends StatelessWidget {
  const WalletActionRow({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    this.titleTag,
    this.trailing,
    this.onTap,
    this.selected = false,
  });

  final Widget leading;
  final String title;

  /// Shown right after the title, e.g. [WalletTypeTag].
  final Widget? titleTag;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = onTap != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? WalletPalette.tileSelected
                : WalletPalette.tile.withValues(alpha: enabled ? 1 : 0.55),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: enabled
                                  ? WalletPalette.ink
                                  : WalletPalette.muted,
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                            ),
                          ),
                        ),
                        if (titleTag != null) ...[
                          const SizedBox(width: 6),
                          titleTag!,
                        ],
                      ],
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      subtitle!,
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            ],
          ),
        ),
      ),
    );
  }
}

class WalletIconCircle extends StatelessWidget {
  const WalletIconCircle({super.key, this.icon, this.color, this.child})
    : assert(icon != null || child != null);

  final IconData? icon;
  final Color? color;

  /// Drawn instead of [icon], e.g. a [SeekerMark].
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? WalletPalette.accent;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: iconColor.withValues(alpha: 0.18)),
      ),
      child: IconTheme(
        data: IconThemeData(color: iconColor, size: 21),
        child: child ?? Icon(icon),
      ),
    );
  }
}
