import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/providers.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../l10n/l10n.dart';
import '../../../auth/domain/wallet_controller_state.dart';
import '../../../auth/presentation/providers/wallet_controller.dart';
import '../../../portfolio/presentation/providers/portfolio_provider.dart';
import '../../../settings/domain/app_settings.dart';
import '../../../settings/presentation/providers/app_settings_controller.dart';
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
    final l10n = context.l10n;
    final firstConfirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.welcomeReplaceWalletTitle),
        content: Text(l10n.welcomeReplaceWalletMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.commonContinue),
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
        title: Text(l10n.welcomeConfirmAgainTitle),
        content: Text(l10n.welcomeConfirmAgainMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.commonBack),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.commonConfirm),
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
    final l10n = context.l10n;
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
              newWalletSubtitle: l10n.welcomeNewWalletSubtitle,
              importWalletSubtitle: seekerVaultAvailable
                  ? l10n.welcomeImportWalletSubtitleSeeker
                  : l10n.welcomeImportWalletSubtitlePhrase,
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
          if (!isLoading) ...[
            const SizedBox(height: 14),
            _WelcomeLanguagePrompt(animation: _introController),
          ],
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
        final logoRingCenterY = coreEndY - 10;
        final coreCenterY = _lerpDouble(
          coreStartY,
          logoRingCenterY,
          coreProgress,
        );
        final coreScale = _lerpDouble(2.62, 1, coreProgress);
        final copyTop = coreEndY + 120;

        return Semantics(
          label: context.l10n.welcomeHeroSemantics,
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
                _RevealLogo(
                  assetPath: _MarketLogoAssets.usdc,
                  semanticLabel: 'USDC',
                  index: 0,
                  coreStartY: coreStartY,
                  coreEndY: coreEndY,
                  finalOffset: const Offset(-138, -58),
                  size: 42,
                  progress: value,
                ),
                _RevealLogo(
                  assetPath: _MarketLogoAssets.jup,
                  semanticLabel: 'JUP',
                  index: 1,
                  coreStartY: coreStartY,
                  coreEndY: coreEndY,
                  finalOffset: const Offset(-72, -86),
                  size: 46,
                  progress: value,
                ),
                _RevealLogo(
                  assetPath: _MarketLogoAssets.sol,
                  semanticLabel: 'SOL',
                  index: 2,
                  coreStartY: coreStartY,
                  coreEndY: coreEndY,
                  finalOffset: const Offset(0, -96),
                  size: 54,
                  progress: value,
                ),
                _RevealLogo(
                  assetPath: _MarketLogoAssets.byc,
                  semanticLabel: 'BYC',
                  index: 3,
                  coreStartY: coreStartY,
                  coreEndY: coreEndY,
                  finalOffset: const Offset(72, -86),
                  size: 46,
                  progress: value,
                ),
                _RevealLogo(
                  assetPath: _MarketLogoAssets.pump,
                  semanticLabel: 'pump.fun',
                  index: 4,
                  coreStartY: coreStartY,
                  coreEndY: coreEndY,
                  finalOffset: const Offset(138, -58),
                  size: 42,
                  progress: value,
                ),
                _RevealLogo(
                  assetPath: _MarketLogoAssets.nvda,
                  semanticLabel: 'NVDAx',
                  index: 5,
                  coreStartY: coreStartY,
                  coreEndY: coreEndY,
                  finalOffset: const Offset(-138, 34),
                  size: 38,
                  progress: value,
                  shape: _RevealLogoShape.roundedSquare,
                ),
                _RevealLogo(
                  assetPath: _MarketLogoAssets.aapl,
                  semanticLabel: 'AAPLx',
                  index: 6,
                  coreStartY: coreStartY,
                  coreEndY: coreEndY,
                  finalOffset: const Offset(-76, 64),
                  size: 38,
                  progress: value,
                  shape: _RevealLogoShape.roundedSquare,
                ),
                _RevealLogo(
                  assetPath: _MarketLogoAssets.tsla,
                  semanticLabel: 'TSLAx',
                  index: 7,
                  coreStartY: coreStartY,
                  coreEndY: coreEndY,
                  finalOffset: const Offset(0, 76),
                  size: 38,
                  progress: value,
                  shape: _RevealLogoShape.roundedSquare,
                ),
                _RevealLogo(
                  assetPath: _MarketLogoAssets.spy,
                  semanticLabel: 'SPYx',
                  index: 8,
                  coreStartY: coreStartY,
                  coreEndY: coreEndY,
                  finalOffset: const Offset(76, 64),
                  size: 38,
                  progress: value,
                  shape: _RevealLogoShape.roundedSquare,
                ),
                _RevealLogo(
                  assetPath: _MarketLogoAssets.qqq,
                  semanticLabel: 'QQQx',
                  index: 9,
                  coreStartY: coreStartY,
                  coreEndY: coreEndY,
                  finalOffset: const Offset(138, 34),
                  size: 38,
                  progress: value,
                  shape: _RevealLogoShape.roundedSquare,
                ),
                Positioned(
                  top: heroHeight * 0.42,
                  right: 26,
                  left: 26,
                  child: Opacity(
                    opacity: preludeOpacity,
                    child: Text(
                      context.l10n.welcomeHeroPrelude,
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
                  top: copyTop,
                  right: 24,
                  left: 24,
                  child: Opacity(
                    opacity: copyProgress,
                    child: Transform.translate(
                      offset: Offset(0, 12 * (1 - copyProgress)),
                      child: Column(
                        children: [
                          Text(
                            context.l10n.welcomeHeroTitle,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(color: AppColors.primaryStrong),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            context.l10n.welcomeHeroSubtitle,
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

abstract final class _MarketLogoAssets {
  static const sol = 'assets/market_logos/sol.png';
  static const usdc = 'assets/market_logos/usdc.png';
  static const jup = 'assets/market_logos/jup.png';
  static const byc = 'assets/market_logos/byc.png';
  static const pump = 'assets/brand/pump_mark.svg';
  static const nvda = 'assets/market_logos/xstock_nvda.png';
  static const aapl = 'assets/market_logos/xstock_aapl.png';
  static const tsla = 'assets/market_logos/xstock_tsla.png';
  static const spy = 'assets/market_logos/xstock_spy.png';
  static const qqq = 'assets/market_logos/xstock_qqq.png';
}

enum _RevealLogoShape { circle, roundedSquare }

class _RevealLogo extends StatelessWidget {
  const _RevealLogo({
    required this.assetPath,
    required this.semanticLabel,
    required this.index,
    required this.coreStartY,
    required this.coreEndY,
    required this.finalOffset,
    required this.size,
    required this.progress,
    this.shape = _RevealLogoShape.circle,
  });

  final String assetPath;
  final String semanticLabel;
  final int index;
  final double coreStartY;
  final double coreEndY;
  final Offset finalOffset;
  final double size;
  final double progress;
  final _RevealLogoShape shape;

  @override
  Widget build(BuildContext context) {
    final isSvg = assetPath.endsWith('.svg');
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
                    shape: shape == _RevealLogoShape.circle
                        ? BoxShape.circle
                        : BoxShape.rectangle,
                    color: Colors.white.withValues(alpha: 0.96),
                    borderRadius: shape == _RevealLogoShape.roundedSquare
                        ? BorderRadius.circular(size * 0.28)
                        : null,
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
                  child: Padding(
                    padding: EdgeInsets.all(
                      isSvg
                          ? size * 0.1
                          : shape == _RevealLogoShape.circle
                          ? size * 0.02
                          : 0,
                    ),
                    child: ClipRRect(
                      borderRadius: shape == _RevealLogoShape.circle
                          ? BorderRadius.circular(size / 2)
                          : BorderRadius.circular(size * 0.22),
                      child: isSvg
                          ? SvgPicture.asset(
                              assetPath,
                              semanticsLabel: semanticLabel,
                              fit: BoxFit.contain,
                              width: size,
                              height: size,
                            )
                          : Image.asset(
                              assetPath,
                              semanticLabel: semanticLabel,
                              fit: BoxFit.cover,
                              width: size,
                              height: size,
                            ),
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
                      title: context.l10n.welcomeNewWallet,
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
                      title: context.l10n.welcomeImportWallet,
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

class _WelcomeLanguagePrompt extends ConsumerWidget {
  const _WelcomeLanguagePrompt({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final selectedOption = ref
        .watch(appSettingsControllerProvider)
        .languageOption;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final progress = _interval(
          animation.value,
          0.82,
          1,
          Curves.easeOutCubic,
        );

        return IgnorePointer(
          ignoring: progress < 0.96,
          child: Opacity(
            opacity: progress,
            child: Transform.translate(
              offset: Offset(0, 12 * (1 - progress)),
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () =>
                    _showWelcomeLanguagePicker(context, ref, selectedOption),
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.fromLTRB(16, 8, 14, 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.82),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE7F4F6),
                          borderRadius: BorderRadius.circular(21),
                        ),
                        child: const Icon(
                          Icons.language_rounded,
                          color: Color(0xFF235E7A),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _languageLabel(l10n, selectedOption),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppColors.primaryStrong,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.expand_more_rounded, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

Future<void> _showWelcomeLanguagePicker(
  BuildContext context,
  WidgetRef ref,
  AppLanguageOption selectedOption,
) {
  final l10n = context.l10n;
  final theme = Theme.of(context);
  final notifier = ref.read(appSettingsControllerProvider.notifier);

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: false,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      final maxHeight = MediaQuery.sizeOf(sheetContext).height * 0.78;

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Container(
            constraints: BoxConstraints(maxHeight: maxHeight),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(28),
            ),
            child: ListView(
              shrinkWrap: true,
              children: [
                Container(
                  width: 42,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                Text(
                  l10n.settingsLanguageSheetTitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displaySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.settingsLanguageSheetSubtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                for (final option in AppLanguageOption.values) ...[
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    tileColor: option == selectedOption
                        ? const Color(0xFFF8E8B8)
                        : theme.colorScheme.surfaceContainerHigh.withValues(
                            alpha: 0.28,
                          ),
                    title: Text(_languageLabel(l10n, option)),
                    subtitle: option == AppLanguageOption.system
                        ? Text(l10n.settingsLanguageSystemDescription)
                        : null,
                    trailing: option == selectedOption
                        ? const Icon(Icons.check_rounded)
                        : null,
                    onTap: () async {
                      await notifier.setLanguageOption(option);
                      if (!sheetContext.mounted) {
                        return;
                      }
                      Navigator.of(sheetContext).pop();
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ),
      );
    },
  );
}

String _languageLabel(AppLocalizations l10n, AppLanguageOption option) {
  return option.nativeLabel ?? l10n.languageSystem;
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
