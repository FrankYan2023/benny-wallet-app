import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/brand_logo.dart';

/// Building blocks that give signer mode the same warm, rounded look as the
/// wallet (cream background, soft cards, round icon bubbles, the Benny face).

/// Big rounded header card, like the wallet's import and welcome heroes.
class SignerHero extends StatelessWidget {
  const SignerHero({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.showLogo = false,
    this.tone = SignerTone.info,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;

  /// Shows the Benny face instead of [icon].
  final bool showLogo;
  final SignerTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = tone.colors(theme);
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: colors.background,
      ),
      child: Column(
        children: [
          if (showLogo)
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.55),
                shape: BoxShape.circle,
              ),
              child: const BrandLogo(size: 76),
            )
          else if (icon != null)
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, size: 32, color: colors.foreground),
            ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.displaySmall?.copyWith(
              color: colors.foreground,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colors.foreground.withValues(alpha: 0.78),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

enum SignerTone {
  info,
  warm,
  brand,
  success,
  danger;

  ({Color background, Color foreground}) colors(ThemeData theme) {
    final scheme = theme.colorScheme;
    return switch (this) {
      SignerTone.info => (
        background: scheme.secondaryContainer,
        foreground: scheme.onSecondaryContainer,
      ),
      SignerTone.warm => (
        background: scheme.tertiaryContainer,
        foreground: scheme.onTertiaryContainer,
      ),
      SignerTone.brand => (
        background: AppColors.backgroundAccent,
        foreground: AppColors.primaryStrong,
      ),
      SignerTone.success => (
        background: const Color(0xFFD9F2E3),
        foreground: const Color(0xFF1D5E3A),
      ),
      SignerTone.danger => (
        background: const Color(0xFFFFE1D8),
        foreground: AppColors.danger,
      ),
    };
  }
}

/// A tappable row card with a round icon bubble.
class SignerTile extends StatelessWidget {
  const SignerTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.tone = SignerTone.warm,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final SignerTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = tone.colors(theme);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: WalletCard(
          padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: colors.foreground, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(subtitle!, style: theme.textTheme.bodyMedium),
                    ],
                  ],
                ),
              ),
              if (trailing != null)
                trailing!
              else if (onTap != null)
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Rounded message strip for warnings and hints.
class SignerNotice extends StatelessWidget {
  const SignerNotice({
    super.key,
    required this.text,
    this.icon = Icons.info_outline_rounded,
    this.tone = SignerTone.info,
  });

  final String text;
  final IconData icon;
  final SignerTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = tone.colors(Theme.of(context));
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 16, 12),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colors.foreground, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: colors.foreground,
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// White card with a small label above its content.
class SignerSection extends StatelessWidget {
  const SignerSection({super.key, required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return WalletCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: theme.textTheme.labelMedium),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

/// Standard signer screen: wallet app bar, cream background, padded list.
class SignerScaffold extends StatelessWidget {
  const SignerScaffold({
    super.key,
    required this.children,
    this.title,
    this.leading,
    this.actions,
    this.bottom,
    this.transparent = false,
  });

  final String? title;

  /// Lets a background drawn behind the page (e.g. a pulsing colour) show.
  final bool transparent;
  final Widget? leading;
  final List<Widget>? actions;
  final List<Widget> children;

  /// Pinned under the scrolling content, so the next step stays on screen.
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final list = ListView(
      padding: EdgeInsets.fromLTRB(20, 4, 20, bottom == null ? 32 : 12),
      children: children,
    );
    return Scaffold(
      backgroundColor: transparent ? Colors.transparent : null,
      appBar: AppBar(
        backgroundColor: transparent ? Colors.transparent : null,
        title: title == null ? null : Text(title!),
        leading: leading,
        actions: actions,
      ),
      body: SafeArea(
        child: bottom == null
            ? list
            : Column(
                children: [
                  Expanded(child: list),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                    child: bottom,
                  ),
                ],
              ),
      ),
    );
  }
}

/// Vertical gaps between stacked cards.
const signerGap = SizedBox(height: 14);
