import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/security/secure_screen.dart';
import '../../../../core/widgets/app_scaffold.dart';
import 'import_wallet_selection_page.dart';

class ImportWalletLoadingFlowData {
  const ImportWalletLoadingFlowData({required this.mnemonic});

  final String mnemonic;
}

class ImportWalletLoadingPage extends StatefulWidget {
  const ImportWalletLoadingPage({super.key, required this.mnemonic});

  static const routeName = 'importWalletLoading';
  static const routePath = '/import/loading';

  final String mnemonic;

  @override
  State<ImportWalletLoadingPage> createState() =>
      _ImportWalletLoadingPageState();
}

class _ImportWalletLoadingPageState extends State<ImportWalletLoadingPage> {
  bool _redirected = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openSelectionPage();
    });
  }

  Future<void> _openSelectionPage() async {
    if (_redirected || !mounted) {
      return;
    }
    _redirected = true;
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (!mounted) {
      return;
    }
    context.replace(
      ImportWalletSelectionPage.routePath,
      extra: ImportWalletSelectionFlowData(mnemonic: widget.mnemonic),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SecureScreen(
      child: AppScaffold(
        title: 'Import Wallet',
        child: Center(
          child: WalletCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 18),
                  Text(
                    'Importing wallet...',
                    style: theme.textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Preparing your Solana wallet list.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
