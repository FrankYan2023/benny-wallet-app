import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/config/app_features.dart';
import '../features/auth/presentation/providers/wallet_controller.dart';
import '../features/auth/presentation/pages/pin_setup_page.dart';
import '../features/auth/presentation/pages/unlock_page.dart';
import '../features/asset_detail/presentation/pages/asset_detail_page.dart';
import '../features/airdrop/presentation/pages/airdrop_page.dart';
import '../features/onboarding/presentation/pages/create_wallet_page.dart';
import '../features/onboarding/presentation/pages/import_wallet_loading_page.dart';
import '../features/onboarding/presentation/pages/import_mnemonic_page.dart';
import '../features/onboarding/presentation/pages/import_wallet_selection_page.dart';
import '../features/onboarding/presentation/pages/splash_page.dart';
import '../features/onboarding/presentation/pages/welcome_page.dart';
import '../features/notifications/domain/notification_message.dart';
import '../features/notifications/presentation/pages/notifications_page.dart';
import '../features/portfolio/presentation/pages/portfolio_page.dart';
import '../features/portfolio/presentation/pages/child_wallet_monitor_page.dart';
import '../features/portfolio/presentation/pages/child_wallets_page.dart';
import '../features/receive/presentation/pages/receive_page.dart';
import '../features/send/domain/send_draft_data.dart';
import '../features/send/presentation/pages/send_page.dart';
import '../features/send/presentation/pages/scan_address_page.dart';
import '../features/send/presentation/pages/send_compose_page.dart';
import '../features/send/presentation/pages/send_confirm_page.dart';
import '../features/send/presentation/pages/send_execute_page.dart';
import '../features/send/presentation/pages/send_history_page.dart';
import '../features/send/domain/send_result_data.dart';
import '../features/send/presentation/pages/send_result_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../features/settings/presentation/pages/contact_feedback_page.dart';
import '../features/settings/presentation/pages/rent_reclaim_page.dart';
import '../features/swap/domain/swap_review_data.dart';
import '../features/swap/presentation/pages/swap_execute_page.dart';
import '../features/swap/presentation/pages/swap_page.dart';
import '../features/swap/presentation/pages/swap_review_page.dart';

class AppRouter {
  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: SplashPage.routePath,
    routes: [
      GoRoute(
        path: SplashPage.routePath,
        name: SplashPage.routeName,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: WelcomePage.routePath,
        name: WelcomePage.routeName,
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          transitionDuration: const Duration(milliseconds: 360),
          reverseTransitionDuration: const Duration(milliseconds: 220),
          child: _RouteAccessGuard(
            currentLocation: state.matchedLocation,
            blockWhenWalletExists: true,
            child: const WelcomePage(),
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );
            return FadeTransition(opacity: curved, child: child);
          },
        ),
      ),
      GoRoute(
        path: ImportMnemonicPage.routePath,
        name: ImportMnemonicPage.routeName,
        builder: (context, state) => _RouteAccessGuard(
          currentLocation: state.matchedLocation,
          blockWhenWalletExists: true,
          child: const ImportMnemonicPage(),
        ),
      ),
      GoRoute(
        path: ImportWalletLoadingPage.routePath,
        name: ImportWalletLoadingPage.routeName,
        builder: (context, state) {
          final extra = state.extra;
          final flow = extra is ImportWalletLoadingFlowData
              ? extra
              : ImportWalletLoadingFlowData(mnemonic: extra as String);

          return _RouteAccessGuard(
            currentLocation: state.matchedLocation,
            blockWhenWalletExists: true,
            child: ImportWalletLoadingPage(mnemonic: flow.mnemonic),
          );
        },
      ),
      GoRoute(
        path: CreateWalletPage.routePath,
        name: CreateWalletPage.routeName,
        builder: (context, state) => _RouteAccessGuard(
          currentLocation: state.matchedLocation,
          blockWhenWalletExists: true,
          child: const CreateWalletPage(),
        ),
      ),
      GoRoute(
        path: ImportWalletSelectionPage.routePath,
        name: ImportWalletSelectionPage.routeName,
        builder: (context, state) {
          final extra = state.extra;
          final flow = extra is ImportWalletSelectionFlowData
              ? extra
              : ImportWalletSelectionFlowData(mnemonic: extra as String);

          return _RouteAccessGuard(
            currentLocation: state.matchedLocation,
            blockWhenWalletExists: true,
            child: ImportWalletSelectionPage(mnemonic: flow.mnemonic),
          );
        },
      ),
      GoRoute(
        path: PinSetupPage.routePath,
        name: PinSetupPage.routeName,
        builder: (context, state) {
          final extra = state.extra;
          final child = extra is PinSetupFlowData
              ? PinSetupPage(
                  mnemonic: extra.mnemonic,
                  returnHomeOnSuccess: extra.returnHomeOnSuccess,
                  derivation: extra.derivation,
                  publicKey: extra.publicKey,
                  mobileWalletAuthToken: extra.mobileWalletAuthToken,
                  seedVaultAuthToken: extra.seedVaultAuthToken,
                  seedVaultDerivationPath: extra.seedVaultDerivationPath,
                  walletLabel: extra.walletLabel,
                )
              : PinSetupPage(mnemonic: extra as String);

          return _RouteAccessGuard(
            currentLocation: state.matchedLocation,
            blockWhenWalletExists: true,
            child: child,
          );
        },
      ),
      GoRoute(
        path: UnlockPage.routePath,
        name: UnlockPage.routeName,
        builder: (context, state) => const UnlockPage(),
      ),
      GoRoute(
        path: PortfolioPage.routePath,
        name: PortfolioPage.routeName,
        builder: (context, state) => const PortfolioPage(),
      ),
      GoRoute(
        path: NotificationsPage.routePath,
        name: NotificationsPage.routeName,
        builder: (context, state) => _RouteAccessGuard(
          currentLocation: state.matchedLocation,
          child: const NotificationsPage(),
        ),
      ),
      GoRoute(
        path: ReceivedHistoryPage.routePath,
        name: ReceivedHistoryPage.routeName,
        builder: (context, state) => _RouteAccessGuard(
          currentLocation: state.matchedLocation,
          child: const ReceivedHistoryPage(),
        ),
      ),
      GoRoute(
        path: ReceivedNotificationDetailPage.routePath,
        name: ReceivedNotificationDetailPage.routeName,
        builder: (context, state) {
          final message = state.extra as NotificationMessage?;
          if (message == null) {
            return const _FeatureUnavailablePage(
              title: 'Message unavailable',
              message: 'Open a received message from the message list first.',
            );
          }
          return _RouteAccessGuard(
            currentLocation: state.matchedLocation,
            child: ReceivedNotificationDetailPage(message: message),
          );
        },
      ),
      GoRoute(
        path: AirdropPage.routePath,
        name: AirdropPage.routeName,
        builder: (context, state) {
          if (!AppFeatures.canOpenAirdrop) {
            return const _FeatureUnavailablePage(
              title: 'Feature unavailable',
              message: 'This feature is not available in this build.',
            );
          }
          return _RouteAccessGuard(
            currentLocation: state.matchedLocation,
            allowInChildMode: true,
            child: const AirdropPage(),
          );
        },
      ),
      GoRoute(
        path: ReceivePage.routePath,
        name: ReceivePage.routeName,
        builder: (context, state) => _RouteAccessGuard(
          currentLocation: state.matchedLocation,
          child: const ReceivePage(),
        ),
      ),
      GoRoute(
        path: SendPage.routePath,
        name: SendPage.routeName,
        builder: (context, state) => _RouteAccessGuard(
          currentLocation: state.matchedLocation,
          allowInChildMode: false,
          child: SendPage(
            recipientAddress: state.uri.queryParameters['recipient'],
          ),
        ),
      ),
      GoRoute(
        path: SendHistoryPage.routePath,
        name: SendHistoryPage.routeName,
        builder: (context, state) => _RouteAccessGuard(
          currentLocation: state.matchedLocation,
          allowInChildMode: false,
          child: const SendHistoryPage(),
        ),
      ),
      GoRoute(
        path: SendHistoryDetailPage.routePath,
        name: SendHistoryDetailPage.routeName,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! SendHistoryDetailData) {
            return const _FeatureUnavailablePage(
              title: 'Send details unavailable',
              message: 'Open a transaction from send history first.',
            );
          }
          return _RouteAccessGuard(
            currentLocation: state.matchedLocation,
            allowInChildMode: false,
            child: SendHistoryDetailPage(data: extra),
          );
        },
      ),
      GoRoute(
        path: SwapPage.routePath,
        name: SwapPage.routeName,
        builder: (context, state) {
          if (!AppFeatures.canOpenSwap) {
            return const _FeatureUnavailablePage(
              title: 'Feature unavailable',
              message: 'This feature is not available in this build.',
            );
          }
          return _RouteAccessGuard(
            currentLocation: state.matchedLocation,
            allowInChildMode: false,
            child: const SwapPage(),
          );
        },
      ),
      GoRoute(
        path: XStocksSwapPage.routePath,
        name: XStocksSwapPage.routeName,
        builder: (context, state) {
          if (!AppFeatures.canOpenXStocks) {
            return const _FeatureUnavailablePage(
              title: 'Feature unavailable',
              message: 'This feature is not available in this build.',
            );
          }
          return _RouteAccessGuard(
            currentLocation: state.matchedLocation,
            allowInChildMode: false,
            child: const XStocksSwapPage(),
          );
        },
      ),
      GoRoute(
        path: SwapReviewPage.routePath,
        name: SwapReviewPage.routeName,
        builder: (context, state) {
          if (!AppFeatures.canOpenSwap) {
            return const _FeatureUnavailablePage(
              title: 'Feature unavailable',
              message: 'This feature is not available in this build.',
            );
          }
          return _RouteAccessGuard(
            currentLocation: state.matchedLocation,
            allowInChildMode: false,
            child: SwapReviewPage(review: state.extra as SwapReviewData),
          );
        },
      ),
      GoRoute(
        path: SwapExecutePage.routePath,
        name: SwapExecutePage.routeName,
        builder: (context, state) {
          if (!AppFeatures.canOpenSwap) {
            return const _FeatureUnavailablePage(
              title: 'Feature unavailable',
              message: 'This feature is not available in this build.',
            );
          }
          return _RouteAccessGuard(
            currentLocation: state.matchedLocation,
            allowInChildMode: true,
            child: SwapExecutePage(review: state.extra as SwapReviewData),
          );
        },
      ),
      GoRoute(
        path: SendComposePage.routePath,
        name: SendComposePage.routeName,
        builder: (context, state) => _RouteAccessGuard(
          currentLocation: state.matchedLocation,
          allowInChildMode: false,
          child: SendComposePage(
            mintAddress: state.pathParameters['mint']!,
            recipientAddress: state.uri.queryParameters['recipient'],
          ),
        ),
      ),
      GoRoute(
        path: ScanAddressPage.routePath,
        name: ScanAddressPage.routeName,
        builder: (context, state) => _RouteAccessGuard(
          currentLocation: state.matchedLocation,
          allowInChildMode: false,
          child: const ScanAddressPage(),
        ),
      ),
      GoRoute(
        path: SendConfirmPage.routePath,
        name: SendConfirmPage.routeName,
        builder: (context, state) => _RouteAccessGuard(
          currentLocation: state.matchedLocation,
          allowInChildMode: false,
          child: SendConfirmPage(draft: state.extra as SendDraftData),
        ),
      ),
      GoRoute(
        path: SendExecutePage.routePath,
        name: SendExecutePage.routeName,
        builder: (context, state) => _RouteAccessGuard(
          currentLocation: state.matchedLocation,
          allowInChildMode: false,
          child: SendExecutePage(draft: state.extra as SendDraftData),
        ),
      ),
      GoRoute(
        path: SendResultPage.routePath,
        name: SendResultPage.routeName,
        builder: (context, state) => _RouteAccessGuard(
          currentLocation: state.matchedLocation,
          allowInChildMode: false,
          child: SendResultPage(result: state.extra as SendResultData),
        ),
      ),
      GoRoute(
        path: AssetDetailPage.routePath,
        name: AssetDetailPage.routeName,
        builder: (context, state) => _RouteAccessGuard(
          currentLocation: state.matchedLocation,
          child: AssetDetailPage(mintAddress: state.pathParameters['mint']!),
        ),
      ),
      GoRoute(
        path: SettingsPage.routePath,
        name: SettingsPage.routeName,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: RentReclaimPage.routePath,
        name: RentReclaimPage.routeName,
        builder: (context, state) => _RouteAccessGuard(
          currentLocation: state.matchedLocation,
          allowInChildMode: false,
          child: const RentReclaimPage(),
        ),
      ),
      GoRoute(
        path: ContactFeedbackPage.routePath,
        name: ContactFeedbackPage.routeName,
        builder: (context, state) => const ContactFeedbackPage(),
      ),
      GoRoute(
        path: ChildWalletsPage.routePath,
        name: ChildWalletsPage.routeName,
        builder: (context, state) => _RouteAccessGuard(
          currentLocation: state.matchedLocation,
          allowInChildMode: false,
          child: const ChildWalletsPage(),
        ),
      ),
      GoRoute(
        path: ChildWalletMonitorPage.routePath,
        name: ChildWalletMonitorPage.routeName,
        builder: (context, state) {
          final childId = state.extra as String?;
          if (childId == null) {
            return const Scaffold(
              body: Center(child: Text('Invalid child wallet ID')),
            );
          }
          return _RouteAccessGuard(
            currentLocation: state.matchedLocation,
            allowInChildMode: false,
            child: ChildWalletMonitorPage(childId: childId),
          );
        },
      ),
    ],
    errorBuilder: (context, state) {
      return Scaffold(
        body: Center(child: Text('Route not found: ${state.uri}')),
      );
    },
  );
}

class _RouteAccessGuard extends ConsumerWidget {
  const _RouteAccessGuard({
    required this.currentLocation,
    required this.child,
    this.allowInChildMode = true,
    this.blockWhenWalletExists = false,
  });

  final String currentLocation;
  final Widget child;
  final bool allowInChildMode;
  final bool blockWhenWalletExists;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletState = ref.watch(walletControllerProvider);

    String? redirectPath;
    if (blockWhenWalletExists &&
        walletState.hasWallet &&
        !walletState.loggedOut) {
      redirectPath = walletState.isUnlocked
          ? PortfolioPage.routePath
          : UnlockPage.routePath;
    } else if (!allowInChildMode &&
        walletState.isUnlocked &&
        walletState.childModeEnabled) {
      redirectPath = PortfolioPage.routePath;
    }

    if (redirectPath != null && redirectPath != currentLocation) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.go(redirectPath!);
        }
      });

      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return child;
  }
}

class _FeatureUnavailablePage extends StatelessWidget {
  const _FeatureUnavailablePage({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(message, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
