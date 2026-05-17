import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/providers.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../../auth/domain/wallet_controller_state.dart';
import '../../../auth/presentation/providers/wallet_controller.dart';
import '../../../portfolio/presentation/providers/portfolio_provider.dart';
import 'create_wallet_page.dart';
import 'import_mnemonic_page.dart';

class WelcomePage extends ConsumerWidget {
  const WelcomePage({super.key});

  static const routeName = 'welcome';
  static const routePath = '/';

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
  Widget build(BuildContext context, WidgetRef ref) {
    final walletState = ref.watch(walletControllerProvider);
    final seekerVaultAvailable =
        ref.watch(seekerVaultAvailableProvider).valueOrNull ?? false;

    return AppScaffold(
      title: '',
      showBackButton: false,
      enableTitleNavigation: false,
      showTopBar: false,
      child: ListView(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surface.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(34),
            ),
            child: Column(
              children: [
                const BrandLogo(size: 88, radius: 30),
                const SizedBox(height: 18),
                Text(
                  'Growing wealth\ntogether as a family',
                  style: Theme.of(context).textTheme.displaySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          if (walletState.status == WalletStatus.loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Row(
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
                    subtitle: 'Start a fresh default wallet',
                    onTap: () => _startFlow(
                      context,
                      ref,
                      routePath: CreateWalletPage.routePath,
                    ),
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
                    subtitle: seekerVaultAvailable
                        ? 'Phrase or Seeker Vault'
                        : 'Restore from recovery phrase',
                    onTap: () => _startFlow(
                      context,
                      ref,
                      routePath: ImportMnemonicPage.routePath,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
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
