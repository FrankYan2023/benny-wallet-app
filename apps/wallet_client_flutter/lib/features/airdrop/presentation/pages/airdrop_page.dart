import 'dart:async';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/di/providers.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/config/app_features.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../asset_detail/domain/asset_detail_view_data.dart';
import '../../../auth/presentation/providers/wallet_controller.dart';
import '../../domain/airdrop_view_data.dart';
import '../providers/airdrop_provider.dart';

const _bycMintAddress = 'AGk1gQfsSRZ8sfS16LUYuBm69iMfHTbCksLUZWJNpump';
const _bycPumpFunUrl =
    'https://pump.fun/coin/AGk1gQfsSRZ8sfS16LUYuBm69iMfHTbCksLUZWJNpump';
const _bycDisplayName = 'Benny Coin';
const _bycDisplaySymbol = 'BYC';
const _bycLogoUrl =
    'https://ipfs.io/ipfs/bafybeicro7545d5hqnanmezlb7mrozml5yfe4xscrpc4cwiqmmun6ohxau';

final bycAirdropDetailProvider = FutureProvider<AssetDetailViewData>((ref) async {
  return ref.read(assetDetailRepositoryProvider).loadTokenDetail(_bycMintAddress);
});

class AirdropPage extends ConsumerStatefulWidget {
  const AirdropPage({super.key});

  static const routeName = 'airdrop';
  static const routePath = '/airdrop';

  @override
  ConsumerState<AirdropPage> createState() => _AirdropPageState();
}

class _AirdropPageState extends ConsumerState<AirdropPage> {
  bool _joining = false;
  bool _checkingIn = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final walletState = ref.watch(walletControllerProvider);
    final profileAsync = ref.watch(activeAirdropProfileProvider);
    final coinDetailAsync = ref.watch(bycAirdropDetailProvider);

    return AppScaffold(
      title: 'BYC Airdrop',
      child: ListView(
        children: [
          _BycDetailCard(
            detailAsync: coinDetailAsync,
            theme: theme,
            showBuyButton:
                !walletState.childModeEnabled && AppFeatures.canOpenSwap,
          ),
          const SizedBox(height: 16),
          _AirdropHeroCard(
            ownerAddress: walletState.publicKey ?? '',
            profileAsync: profileAsync,
          ),
          const SizedBox(height: 16),
          profileAsync.when(
            data: (profile) {
              return Column(
                children: [
                  if (!profile.joined)
                    _JoinAirdropCard(
                      ownerAddress: walletState.publicKey ?? '',
                      isJoining: _joining,
                      onJoinPressed: _joining ? null : _handleJoinAirdrop,
                    )
                  else
                    _CheckInCard(
                      profile: profile,
                      isSubmitting: _checkingIn,
                      onCheckInPressed: profile.canCheckInToday && !_checkingIn
                          ? () => _handleCheckIn(profile)
                          : null,
                    ),
                  const SizedBox(height: 16),
                  _RewardsRuleCard(profile: profile),
                ],
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => WalletCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BYC airdrop temporarily unavailable',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _formatError(error),
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 18),
                  PrimaryButton(
                    label: 'Retry',
                    onPressed: () => ref.invalidate(activeAirdropProfileProvider),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Future<void> _handleJoinAirdrop() async {
    final ownerAddress = ref.read(walletControllerProvider).publicKey;
    if (ownerAddress == null || ownerAddress.isEmpty) {
      _showSnackBar('Unlock your wallet before joining the BYC airdrop.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Join the BYC airdrop?'),
        content: Text(
          'We will use your current Benny wallet address:\n\n${Formatters.compactAddress(ownerAddress, visibleChars: 6)}\n\nThis address will be sent to the Benny backend to register your airdrop profile.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Join'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _joining = true;
    });

    try {
      await ref
          .read(airdropRepositoryProvider)
          .joinAirdrop(ownerAddress: ownerAddress);
      ref.invalidate(activeAirdropProfileProvider);
      if (!mounted) {
        return;
      }
      _showSnackBar('You are in. Your BYC reward profile is ready.');
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showSnackBar(_formatError(error));
    } finally {
      if (mounted) {
        setState(() {
          _joining = false;
        });
      }
    }
  }

  Future<void> _handleCheckIn(AirdropProfileViewData profile) async {
    if (!profile.joined) {
      _showSnackBar('Join the BYC airdrop before checking in.');
      return;
    }

    final ownerAddress = ref.read(walletControllerProvider).publicKey;
    if (ownerAddress == null || ownerAddress.isEmpty) {
      _showSnackBar('Unlock your wallet before checking in.');
      return;
    }

    setState(() {
      _checkingIn = true;
    });

    try {
      final result = await ref
          .read(airdropRepositoryProvider)
          .checkIn(ownerAddress: ownerAddress);
      ref.invalidate(activeAirdropProfileProvider);
      if (!mounted) {
        return;
      }

      await showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) => _CheckInCelebrationDialog(
          awardedPoints: result.awardedPoints,
          rewardType: result.rewardType,
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showSnackBar(_formatError(error));
    } finally {
      if (mounted) {
        setState(() {
          _checkingIn = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _AirdropHeroCard extends StatelessWidget {
  const _AirdropHeroCard({
    required this.ownerAddress,
    required this.profileAsync,
  });

  final String ownerAddress;
  final AsyncValue<AirdropProfileViewData> profileAsync;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = profileAsync.valueOrNull;

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFB06E00),
            Color(0xFFD48B13),
            Color(0xFFF0C562),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.20),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'BYC Airdrop',
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  profile?.joined == true ? 'Joined' : 'Not joined',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _HeroMetric(
                  label: 'BYC points',
                  value: '${profile?.bycPoints ?? 0}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HeroMetric(
                  label: 'Streak',
                  value: '${profile?.streakDays ?? 0} days',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ownerAddress.isEmpty
                        ? 'Wallet unavailable'
                        : Formatters.compactAddress(ownerAddress, visibleChars: 6),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _JoinAirdropCard extends StatelessWidget {
  const _JoinAirdropCard({
    required this.ownerAddress,
    required this.isJoining,
    required this.onJoinPressed,
  });

  final String ownerAddress;
  final bool isJoining;
  final VoidCallback? onJoinPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WalletCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Join the airdrop',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Confirm with your active Benny wallet and create your BYC reward profile.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F1E7),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.verified_user_rounded,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    ownerAddress.isEmpty
                        ? 'Wallet unavailable'
                        : Formatters.compactAddress(ownerAddress, visibleChars: 6),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: isJoining ? 'Joining...' : 'Join With This Wallet',
            onPressed: onJoinPressed,
          ),
        ],
      ),
    );
  }
}

class _CheckInCard extends StatelessWidget {
  const _CheckInCard({
    required this.profile,
    required this.isSubmitting,
    required this.onCheckInPressed,
  });

  final AirdropProfileViewData profile;
  final bool isSubmitting;
  final VoidCallback? onCheckInPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonLabel = profile.canCheckInToday
        ? 'Check in now'
        : 'Checked in today';
    final helperText = profile.canCheckInToday
        ? 'Next reward: +${profile.nextCheckInRewardPoints} BYC'
        : 'Come back tomorrow to claim more BYC.';

    return WalletCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            helperText,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: isSubmitting ? 'Checking in...' : buttonLabel,
            onPressed: onCheckInPressed,
          ),
          if (profile.lastCheckInDate != null) ...[
            const SizedBox(height: 12),
            Text(
              'Last claimed ${Formatters.date(profile.lastCheckInDate)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RewardsRuleCard extends StatelessWidget {
  const _RewardsRuleCard({required this.profile});

  final AirdropProfileViewData profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WalletCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reward rules',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          const _RuleRow(
            title: 'First check-in',
            reward: '+500 BYC',
            color: Color(0xFFFFF1CC),
          ),
          const SizedBox(height: 10),
          const _RuleRow(
            title: 'Next day reward',
            reward: '+100 BYC',
            color: Color(0xFFF3F1FF),
          ),
          const SizedBox(height: 10),
          _RuleRow(
            title: 'Every ${profile.streakBonusEveryDays}-day streak',
            reward: '+500 BYC',
            color: const Color(0xFFE8F8EF),
          ),
        ],
      ),
    );
  }
}

class _RuleRow extends StatelessWidget {
  const _RuleRow({
    required this.title,
    required this.reward,
    required this.color,
  });

  final String title;
  final String reward;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            reward,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _BycDetailCard extends StatelessWidget {
  const _BycDetailCard({
    required this.detailAsync,
    required this.theme,
    required this.showBuyButton,
  });

  final AsyncValue<AssetDetailViewData> detailAsync;
  final ThemeData theme;
  final bool showBuyButton;

  @override
  Widget build(BuildContext context) {
    final detail = detailAsync.valueOrNull;
    final logoUrl = (detail?.logoUrl?.trim().isNotEmpty ?? false)
        ? detail!.logoUrl!.trim()
        : _bycLogoUrl;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.72),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surface.withValues(alpha: 0.98),
            theme.colorScheme.surface.withValues(alpha: 0.98),
            AppColors.backgroundAccent.withValues(alpha: 0.62),
          ],
          stops: const [0.0, 0.58, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.035),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _BycLogo(
                logoUrl: logoUrl,
                symbol: _bycDisplaySymbol,
              ),
              const SizedBox(width: 22),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _bycDisplayName,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: AppColors.primaryStrong,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (showBuyButton) ...[
                      const SizedBox(height: 12),
                      _PumpFunButton(onPressed: () => _openPumpFun(context)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openPumpFun(BuildContext context) async {
    final uri = Uri.parse(_bycPumpFunUrl);
    final didOpenApp = await _tryLaunchPumpFun(
      uri,
      LaunchMode.externalNonBrowserApplication,
    );
    if (!context.mounted || didOpenApp) {
      return;
    }

    final didOpenBrowser = await _tryLaunchPumpFun(
      uri,
      LaunchMode.externalApplication,
    );
    if (!context.mounted || didOpenBrowser) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unable to open Pump.fun right now.')),
    );
  }

  Future<bool> _tryLaunchPumpFun(Uri uri, LaunchMode mode) async {
    try {
      return await launchUrl(uri, mode: mode);
    } catch (_) {
      return false;
    }
  }
}

class _PumpFunButton extends StatelessWidget {
  const _PumpFunButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 50,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(999),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFC88400), Color(0xFFA96600)],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/brand/pump_mark.svg',
                      width: 30,
                      height: 30,
                      excludeFromSemantics: true,
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        'View on Pump.fun',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BycLogo extends StatelessWidget {
  const _BycLogo({
    required this.logoUrl,
    required this.symbol,
  });

  final String? logoUrl;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      color: Colors.transparent,
      alignment: Alignment.center,
      child: Text(
        symbol.substring(0, 1),
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );

    return Container(
      width: 118,
      height: 118,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: const Color(0xFFE7C39A),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: (logoUrl != null && logoUrl!.isNotEmpty)
              ? CachedNetworkImage(
                  imageUrl: logoUrl!,
                  fit: BoxFit.cover,
                  fadeInDuration: Duration.zero,
                  placeholder: (_, __) => fallback,
                  errorWidget: (_, __, ___) => fallback,
                )
              : fallback,
        ),
      ),
    );
  }
}

class _CheckInCelebrationDialog extends StatefulWidget {
  const _CheckInCelebrationDialog({
    required this.awardedPoints,
    required this.rewardType,
  });

  final int awardedPoints;
  final String rewardType;

  @override
  State<_CheckInCelebrationDialog> createState() =>
      _CheckInCelebrationDialogState();
}

class _CheckInCelebrationDialogState extends State<_CheckInCelebrationDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _dismissTimer = Timer(const Duration(milliseconds: 1750), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final pulse = Curves.easeOutBack.transform(_controller.value);
          return Transform.scale(
            scale: 0.94 + (pulse * 0.08),
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFF3D4),
                    Color(0xFFFFD97D),
                    Color(0xFFFFC247),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.18),
                    blurRadius: 28,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  for (final burst in _bursts)
                    _CelebrationBurst(
                      progress: _controller.value,
                      angle: burst.$1,
                      distance: burst.$2,
                    ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 94,
                        height: 94,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.34),
                        ),
                        child: const Icon(
                          Icons.celebration_rounded,
                          size: 44,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        _headlineForRewardType(widget.rewardType),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: AppColors.primaryStrong,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '+${widget.awardedPoints} BYC',
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Your Benny points balance has been updated.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CelebrationBurst extends StatelessWidget {
  const _CelebrationBurst({
    required this.progress,
    required this.angle,
    required this.distance,
  });

  final double progress;
  final double angle;
  final double distance;

  @override
  Widget build(BuildContext context) {
    final curved = Curves.easeOut.transform(progress);
    final dx = math.cos(angle) * distance * curved;
    final dy = math.sin(angle) * distance * curved;

    return Transform.translate(
      offset: Offset(dx, dy),
      child: Opacity(
        opacity: 1 - curved,
        child: Transform.scale(
          scale: 0.6 + ((1 - curved) * 0.8),
          child: Icon(
            progress > 0.5 ? Icons.auto_awesome_rounded : Icons.star_rounded,
            color: progress > 0.5 ? const Color(0xFFFF8A00) : const Color(0xFFFFC44C),
            size: 20,
          ),
        ),
      ),
    );
  }
}

const _bursts = <(double, double)>[
  (0.0, 90),
  (0.75, 84),
  (1.4, 88),
  (2.2, 84),
  (2.9, 92),
  (3.7, 86),
  (4.4, 88),
  (5.15, 84),
];

String _headlineForRewardType(String rewardType) {
  switch (rewardType) {
    case 'first_check_in':
      return 'First check-in unlocked';
    case 'streak_bonus':
      return 'Streak bonus landed';
    case 'already_checked_in':
      return 'Already claimed today';
    default:
      return 'Reward claimed';
  }
}

String _formatError(Object error) {
  final raw = error.toString();
  if (raw.startsWith('Exception: ')) {
    return raw.substring('Exception: '.length);
  }

  return raw;
}
