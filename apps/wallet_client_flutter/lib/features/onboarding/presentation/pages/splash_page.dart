import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../../auth/domain/wallet_controller_state.dart';
import '../../../auth/presentation/pages/unlock_page.dart';
import '../../../auth/presentation/providers/wallet_controller.dart';
import '../../../portfolio/presentation/pages/portfolio_page.dart';

import 'welcome_page.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  static const routeName = 'splash';
  static const routePath = '/splash';

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;
  bool _redirected = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _scale = Tween<double>(
      begin: 0.92,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletControllerProvider);
    final targetPath = _targetPath(walletState);
    if (!_redirected && targetPath != null) {
      _redirected = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _goAfterSplash(targetPath);
      });
    }

    return Scaffold(
      body: Stack(
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.background,
                  Color(0xFFF8F2EC),
                  Color(0xFFF9F4EE),
                ],
              ),
            ),
            child: SizedBox.expand(),
          ),
          Positioned(
            top: -78,
            right: -62,
            child: _GlowBlob(
              size: 188,
              color: AppColors.secondary.withValues(alpha: 0.24),
            ),
          ),
          Positioned(
            bottom: -82,
            left: -46,
            child: _GlowBlob(
              size: 176,
              color: AppColors.tertiary.withValues(alpha: 0.18),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _opacity,
              child: ScaleTransition(
                scale: _scale,
                child: Container(
                  width: 214,
                  height: 214,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFFBD7B6),
                  ),
                  child: const Center(child: BrandLogo(size: 138)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _goAfterSplash(String targetPath) async {
    if (targetPath == WelcomePage.routePath) {
      await _controller.forward();
      await Future<void>.delayed(const Duration(milliseconds: 80));
    }

    if (mounted) {
      context.go(targetPath);
    }
  }

  String? _targetPath(WalletControllerState walletState) {
    if (walletState.status == WalletStatus.loading) {
      return null;
    }
    if (walletState.hasWallet && !walletState.loggedOut) {
      return walletState.isUnlocked
          ? PortfolioPage.routePath
          : UnlockPage.routePath;
    }
    return WelcomePage.routePath;
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
