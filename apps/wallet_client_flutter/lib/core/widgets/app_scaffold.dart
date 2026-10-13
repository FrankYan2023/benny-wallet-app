import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../l10n/l10n.dart';
import 'brand_logo.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.showBackButton = true,
    this.enableTitleNavigation = true,
    this.showTopBar = true,
    this.showBackgroundDecorations = true,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;
  final bool showBackButton;
  final bool enableTitleNavigation;
  final bool showTopBar;
  final bool showBackgroundDecorations;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final titleText = title == l10n.appTitle ? l10n.brandShortName : title;
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          _WarmBackground(showDecorations: showBackgroundDecorations),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    children: [
                      if (showTopBar) ...[
                        Row(
                          children: [
                            if (showBackButton)
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(22),
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.shadowColor.withValues(
                                        alpha: 0.05,
                                      ),
                                      blurRadius: 18,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  tooltip: l10n.commonBack,
                                  onPressed: () {
                                    if (context.canPop()) {
                                      context.pop();
                                      return;
                                    }
                                    context.go('/');
                                  },
                                  icon: const Icon(Icons.arrow_back_rounded),
                                ),
                              )
                            else
                              const BrandLogo(size: 44, radius: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: enableTitleNavigation
                                  ? InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      onTap: () => context.go('/'),
                                      child: Text(
                                        titleText,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.primary,
                                            ),
                                      ),
                                    )
                                  : Text(
                                      titleText,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.primary,
                                          ),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            actions == null || actions!.isEmpty
                                ? const SizedBox(width: 44, height: 44)
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      for (
                                        var index = 0;
                                        index < actions!.length;
                                        index++
                                      ) ...[
                                        if (index > 0) const SizedBox(width: 8),
                                        actions![index],
                                      ],
                                    ],
                                  ),
                          ],
                        ),
                        const SizedBox(height: 18),
                      ],
                      Expanded(
                        child: SizedBox(width: double.infinity, child: child),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WarmBackground extends StatelessWidget {
  const _WarmBackground({required this.showDecorations});

  final bool showDecorations;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.background, Color(0xFFF8F2EC), Color(0xFFF9F4EE)],
        ),
      ),
      child: Stack(
        children: [
          if (showDecorations)
            Positioned(
              top: -110,
              right: -70,
              child: _GlowBlob(
                size: 220,
                color: AppColors.secondary.withValues(alpha: 0.22),
              ),
            ),
          if (showDecorations)
            Positioned(
              bottom: -90,
              left: -40,
              child: _GlowBlob(
                size: 200,
                color: AppColors.tertiary.withValues(alpha: 0.22),
              ),
            ),
        ],
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: size * 0.26,
              spreadRadius: size * 0.02,
            ),
          ],
        ),
      ),
    );
  }
}
