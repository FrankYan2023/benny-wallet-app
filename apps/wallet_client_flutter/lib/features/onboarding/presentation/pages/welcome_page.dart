import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/providers.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../../auth/domain/wallet_controller_state.dart';
import '../../../auth/presentation/providers/wallet_controller.dart';
import '../../../portfolio/presentation/providers/portfolio_provider.dart';
import 'create_wallet_page.dart';
import 'import_mnemonic_page.dart';

class WelcomePage extends ConsumerStatefulWidget {
  const WelcomePage({super.key});

  static const routeName = 'welcome';
  static const routePath = '/';

  @override
  ConsumerState<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends ConsumerState<WelcomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _introController;
  bool _introStarted = false;

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4300),
    );
  }

  @override
  void dispose() {
    _introController.dispose();
    super.dispose();
  }

  void _syncIntro({
    required bool isLoading,
    required bool shouldAnimate,
    required bool disableAnimations,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || isLoading) {
        return;
      }

      if (disableAnimations || !shouldAnimate) {
        _introStarted = false;
        _introController.value = 1;
        return;
      }

      if (!_introStarted) {
        _introStarted = true;
        _introController.forward(from: 0);
      }
    });
  }

  Future<bool> _confirmReplace(BuildContext context) async {
    final firstConfirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Replace current wallet'),
        content: const Text('Continuing will delete the current wallet.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (firstConfirmed != true || !context.mounted) {
      return false;
    }

    final secondConfirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm again'),
        content: const Text(
          'After deletion you may lose access to the phrase. Save it first.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Back'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    return secondConfirmed == true;
  }

  Future<void> _startFlow(
    BuildContext context,
    WidgetRef ref, {
    required String routePath,
  }) async {
    final walletState = ref.read(walletControllerProvider);
    if (walletState.hasWallet && !walletState.loggedOut) {
      final confirmed = await _confirmReplace(context);
      if (!confirmed || !context.mounted) {
        return;
      }
      final activePublicKey = walletState.publicKey;
      if (activePublicKey != null) {
        ref.invalidate(portfolioProvider(activePublicKey));
      }
      await ref.read(walletControllerProvider.notifier).clearWallet();
      ref.read(portfolioCacheProvider.notifier).state = const {};
      if (!context.mounted) {
        return;
      }
    }

    context.push(routePath);
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletControllerProvider);
    final seekerVaultAvailable =
        ref.watch(seekerVaultAvailableProvider).valueOrNull ?? false;
    final isLoading = walletState.status == WalletStatus.loading;
    final shouldAnimateIntro = !isLoading && !walletState.hasWallet;

    _syncIntro(
      isLoading: isLoading,
      shouldAnimate: shouldAnimateIntro,
      disableAnimations: MediaQuery.of(context).disableAnimations,
    );

    return AppScaffold(
      title: '',
      showBackButton: false,
      enableTitleNavigation: false,
      showTopBar: false,
      child: ListView(
        children: [
          _WalletRevealHero(animation: _introController),
          const SizedBox(height: 18),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            _AnimatedActionRow(
              animation: _introController,
              newWalletSubtitle: 'Start a fresh default wallet',
              importWalletSubtitle: seekerVaultAvailable
                  ? 'Phrase or Seeker Vault'
                  : 'Restore from recovery phrase',
              onNewWallet: () => _startFlow(
                context,
                ref,
                routePath: CreateWalletPage.routePath,
              ),
              onImportWallet: () => _startFlow(
                context,
                ref,
                routePath: ImportMnemonicPage.routePath,
              ),
            ),
        ],
      ),
    );
  }
}

class _WalletRevealHero extends StatelessWidget {
  const _WalletRevealHero({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final heroHeight = (screenHeight * 0.5).clamp(330.0, 430.0);

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final value = animation.value;
        final preludeOpacity =
            1 - _interval(value, 0.28, 0.48, Curves.easeOutCubic);
        final copyProgress = _interval(value, 0.46, 0.78, Curves.easeOutCubic);
        final coreProgress = _interval(value, 0.0, 0.58, Curves.easeOutCubic);
        final portalProgress = _interval(value, 0.0, 1.0, Curves.easeOutCubic);
        final coreStartY = heroHeight * 0.78;
        final coreEndY = heroHeight * 0.34;
        final coreCenterY = _lerpDouble(coreStartY, coreEndY, coreProgress);
        final coreScale = _lerpDouble(2.62, 1, coreProgress);

        return Semantics(
          label: 'Meet your new Benny Wallet.',
          child: Container(
            height: heroHeight,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(34),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFF9F3),
                  Color(0xFFFFF2ED),
                  Color(0xFFFFFAF5),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withValues(alpha: 0.08),
                  blurRadius: 38,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -40,
                  bottom: -64,
                  left: -40,
                  child: Transform.scale(
                    scale: 0.48 + 0.52 * portalProgress,
                    child: Opacity(
                      opacity: 0.78 + 0.18 * portalProgress,
                      child: const _RevealPortal(),
                    ),
                  ),
                ),
                _RevealToken(
                  label: 'SOL',
                  index: 0,
                  coreStartY: coreStartY,
                  coreEndY: coreEndY,
                  finalOffset: const Offset(-142, -46),
                  colors: const [Color(0xFF171A2F), Color(0xFF2FD188)],
                  size: 42,
                  progress: value,
                ),
                _RevealToken(
                  label: 'USDC',
                  index: 1,
                  coreStartY: coreStartY,
                  coreEndY: coreEndY,
                  finalOffset: const Offset(-88, -70),
                  colors: const [Color(0xFF2775CA), Color(0xFF8BD4FF)],
                  size: 46,
                  progress: value,
                ),
                _RevealToken(
                  label: 'NFT',
                  index: 2,
                  coreStartY: coreStartY,
                  coreEndY: coreEndY,
                  finalOffset: const Offset(-22, -86),
                  colors: const [
                    Color(0xFFF04F7A),
                    Color(0xFFFFB443),
                    Color(0xFF6036C9),
                  ],
                  size: 54,
                  progress: value,
                ),
                _RevealToken(
                  label: 'B',
                  index: 3,
                  coreStartY: coreStartY,
                  coreEndY: coreEndY,
                  finalOffset: const Offset(74, -82),
                  colors: const [AppColors.primary, AppColors.primaryBright],
                  size: 40,
                  progress: value,
                ),
                _RevealToken(
                  label: r'$',
                  index: 4,
                  coreStartY: coreStartY,
                  coreEndY: coreEndY,
                  finalOffset: const Offset(142, -46),
                  colors: const [AppColors.success, Color(0xFFB7F7CE)],
                  foregroundColor: Color(0xFF0D4E2D),
                  size: 44,
                  progress: value,
                ),
                _RevealToken(
                  label: '*',
                  index: 5,
                  coreStartY: coreStartY,
                  coreEndY: coreEndY,
                  finalOffset: const Offset(-130, 18),
                  colors: const [AppColors.tertiary, AppColors.primaryBright],
                  foregroundColor: AppColors.primaryStrong,
                  size: 30,
                  progress: value,
                ),
                _RevealToken(
                  label: 'KEY',
                  index: 6,
                  coreStartY: coreStartY,
                  coreEndY: coreEndY,
                  finalOffset: const Offset(-78, 18),
                  colors: const [Color(0xFFFFF2B7), Color(0xFFC28E26)],
                  foregroundColor: AppColors.tertiaryStrong,
                  size: 34,
                  progress: value,
                ),
                _RevealToken(
                  label: 'BTC',
                  index: 7,
                  coreStartY: coreStartY,
                  coreEndY: coreEndY,
                  finalOffset: const Offset(82, 14),
                  colors: const [Color(0xFFF7931A), Color(0xFF4A2D00)],
                  size: 36,
                  progress: value,
                ),
                _RevealToken(
                  label: 'SOL',
                  index: 8,
                  coreStartY: coreStartY,
                  coreEndY: coreEndY,
                  finalOffset: const Offset(132, 16),
                  colors: const [Color(0xFF14F195), Color(0xFF9945FF)],
                  size: 32,
                  progress: value,
                ),
                Positioned(
                  top: heroHeight * 0.42,
                  right: 26,
                  left: 26,
                  child: Opacity(
                    opacity: preludeOpacity,
                    child: Text(
                      'A new wallet is here.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.tertiaryStrong.withValues(alpha: 0.74),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: coreCenterY - 38,
                  left: 0,
                  right: 0,
                  child: Transform.scale(
                    scale: coreScale,
                    child: const Center(child: _RevealCore()),
                  ),
                ),
                Positioned(
                  top: heroHeight * 0.52,
                  right: 24,
                  left: 24,
                  child: Opacity(
                    opacity: copyProgress,
                    child: Transform.translate(
                      offset: Offset(0, 12 * (1 - copyProgress)),
                      child: Column(
                        children: [
                          Text(
                            'CREATE WALLET',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: AppColors.tertiaryStrong.withValues(
                                    alpha: 0.74,
                                  ),
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Meet your new Benny Wallet.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(color: AppColors.primaryStrong),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Start fresh or restore your recovery phrase.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppColors.textSecondary.withValues(
                                    alpha: 0.86,
                                  ),
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RevealPortal extends StatelessWidget {
  const _RevealPortal();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.96),
            Colors.white.withValues(alpha: 0.58),
            Colors.transparent,
          ],
          stops: const [0, 0.48, 0.74],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3152FF).withValues(alpha: 0.2),
            blurRadius: 28,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Align(
        alignment: const Alignment(0, 0.46),
        child: Container(
          width: 224,
          height: 26,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                const Color(0xFF4AD8FF).withValues(alpha: 0.72),
                const Color(0xFF3152FF).withValues(alpha: 0.82),
                const Color(0xFF12D4A1).withValues(alpha: 0.66),
                Colors.transparent,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3152FF).withValues(alpha: 0.32),
                blurRadius: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RevealCore extends StatelessWidget {
  const _RevealCore();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.9),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.14),
            blurRadius: 32,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.58),
            blurRadius: 0,
            spreadRadius: 12,
          ),
        ],
      ),
      child: const BrandLogo(size: 52, radius: 26),
    );
  }
}

class _RevealToken extends StatelessWidget {
  const _RevealToken({
    required this.label,
    required this.index,
    required this.coreStartY,
    required this.coreEndY,
    required this.finalOffset,
    required this.colors,
    required this.size,
    required this.progress,
    this.foregroundColor = const Color(0xFFFFF8EC),
  });

  final String label;
  final int index;
  final double coreStartY;
  final double coreEndY;
  final Offset finalOffset;
  final List<Color> colors;
  final double size;
  final double progress;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    final start = 0.2 + index * 0.025;
    final rise = _interval(progress, start, start + 0.48, Curves.easeOutCubic);
    final opacity = _interval(
      progress,
      start + 0.04,
      start + 0.2,
      Curves.easeOut,
    );
    final drift = _interval(progress, 0.84, 1, Curves.easeInOut);
    final direction = index.isEven ? 1.0 : -1.0;
    final releaseProgress = _interval(start, 0.0, 0.58, Curves.easeOutCubic);
    final releaseY = _lerpDouble(coreStartY, coreEndY, releaseProgress);
    final x = finalOffset.dx * rise + direction * 3 * drift;
    final y =
        _lerpDouble(releaseY - coreEndY, finalOffset.dy, rise) - 4 * drift;
    final scale = 0.22 + 0.78 * rise;

    return Positioned(
      left: 0,
      right: 0,
      top: coreEndY - size / 2,
      child: IgnorePointer(
        child: Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(x, y),
            child: Transform.scale(
              scale: scale,
              child: Center(
                child: Container(
                  width: size,
                  height: size,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: colors,
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.9),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.textPrimary.withValues(alpha: 0.14),
                        blurRadius: 24,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: foregroundColor,
                      fontSize: label.length > 1 ? 8 : 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedActionRow extends StatelessWidget {
  const _AnimatedActionRow({
    required this.animation,
    required this.newWalletSubtitle,
    required this.importWalletSubtitle,
    required this.onNewWallet,
    required this.onImportWallet,
  });

  final Animation<double> animation;
  final String newWalletSubtitle;
  final String importWalletSubtitle;
  final VoidCallback onNewWallet;
  final VoidCallback onImportWallet;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final progress = _interval(
          animation.value,
          0.76,
          1,
          Curves.easeOutCubic,
        );

        return IgnorePointer(
          ignoring: progress < 0.96,
          child: Opacity(
            opacity: progress,
            child: Transform.translate(
              offset: Offset(0, 18 * (1 - progress)),
              child: Row(
                children: [
                  Expanded(
                    child: _WarmActionCard(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.secondaryContainer,
                      foregroundColor: Theme.of(
                        context,
                      ).colorScheme.onSecondaryContainer,
                      icon: Icons.auto_awesome_rounded,
                      title: 'New wallet',
                      subtitle: newWalletSubtitle,
                      onTap: onNewWallet,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _WarmActionCard(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.tertiaryContainer,
                      foregroundColor: Theme.of(
                        context,
                      ).colorScheme.onTertiaryContainer,
                      icon: Icons.download_rounded,
                      title: 'Import wallet',
                      subtitle: importWalletSubtitle,
                      onTap: onImportWallet,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

double _interval(double value, double start, double end, Curve curve) {
  final normalized = ((value - start) / (end - start)).clamp(0.0, 1.0);
  return curve.transform(normalized);
}

double _lerpDouble(double start, double end, double progress) {
  return start + (end - start) * progress;
}

class _WarmActionCard extends StatelessWidget {
  const _WarmActionCard({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(32),
      onTap: onTap,
      child: Container(
        height: 174,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.46),
                borderRadius: BorderRadius.circular(23),
              ),
              child: Icon(icon, color: foregroundColor, size: 22),
            ),
            const Spacer(),
            Text(
              title,
              style: theme.textTheme.displaySmall?.copyWith(
                color: foregroundColor,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: foregroundColor.withValues(alpha: 0.72),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
