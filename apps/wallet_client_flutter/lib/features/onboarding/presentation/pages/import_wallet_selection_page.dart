import 'dart:async';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/providers.dart';
import '../../../../core/security/secure_screen.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../l10n/l10n.dart';
import '../../../auth/domain/wallet_derivation.dart';
import '../../../auth/presentation/pages/pin_setup_page.dart';

class ImportWalletSelectionFlowData {
  const ImportWalletSelectionFlowData({required this.mnemonic});

  final String mnemonic;
}

class ImportWalletSelectionPage extends ConsumerStatefulWidget {
  const ImportWalletSelectionPage({super.key, required this.mnemonic});

  static const routeName = 'importWalletSelection';
  static const routePath = '/import/select-wallet';

  final String mnemonic;

  @override
  ConsumerState<ImportWalletSelectionPage> createState() =>
      _ImportWalletSelectionPageState();
}

class _ImportWalletSelectionPageState
    extends ConsumerState<ImportWalletSelectionPage> {
  bool _loading = true;
  bool _submitting = false;
  String? _errorMessage;
  List<_ImportWalletOption> _options = const [];
  _ImportWalletOption? _selectedOption;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _loadOptions();
    });
  }

  Future<void> _loadOptions() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
      _options = const [];
      _selectedOption = null;
    });

    await Future<void>.delayed(const Duration(milliseconds: 80));
    if (!mounted) {
      return;
    }

    try {
      final solana = ref.read(solanaWalletServiceProvider);
      final backendApiClient = ref.read(backendApiClientProvider);
      final discoveryStopwatch = Stopwatch()..start();
      final candidates = await solana.discoverImportCandidates(widget.mnemonic);
      discoveryStopwatch.stop();
      debugPrint(
        'Import candidates (${discoveryStopwatch.elapsedMilliseconds}ms): ${candidates.map((candidate) => '${candidate.derivation.hdPath} -> ${candidate.address}').join(' | ')}',
      );
      if (candidates.isEmpty) {
        if (!mounted) {
          return;
        }
        setState(() => _loading = false);
        return;
      }

      final scanStopwatch = Stopwatch()..start();
      final items = await backendApiClient.scanImportWalletAddresses(
        candidates
            .map((candidate) => candidate.address)
            .toList(growable: false),
        fallbackAddresses: candidates
            .where(
              (candidate) =>
                  (candidate.derivation.accountIndex == 0 &&
                      candidate.derivation.changeIndex == 0) ||
                  (candidate.derivation.accountIndex == null &&
                      candidate.derivation.changeIndex == null),
            )
            .map((candidate) => candidate.address)
            .toList(growable: false),
      );
      scanStopwatch.stop();
      debugPrint(
        'Import scan results (${scanStopwatch.elapsedMilliseconds}ms): ${items.map((item) => '${item.address} active=${item.assetCount > 0}').join(' | ')}',
      );

      if (!mounted) {
        return;
      }

      final options =
          items
              .map((item) {
                final candidate = candidates.firstWhere(
                  (entry) => entry.address == item.address,
                );
                return _ImportWalletOption(
                  address: item.address,
                  assetCount: item.assetCount,
                  derivation: candidate.derivation,
                );
              })
              .toList(growable: true)
            ..sort(_compareOptions);

      if (options.isEmpty) {
        final fallbackCandidate = candidates.firstWhere(
          (candidate) =>
              candidate.derivation.accountIndex == 0 &&
              candidate.derivation.changeIndex == 0,
          orElse: () => candidates.first,
        );
        options.add(
          _ImportWalletOption(
            address: fallbackCandidate.address,
            assetCount: 0,
            derivation: fallbackCandidate.derivation,
          ),
        );
      }

      setState(() {
        _loading = false;
        _options = options;
        _selectedOption = options.first;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _errorMessage = error.toString();
      });
    }
  }

  int _compareOptions(_ImportWalletOption left, _ImportWalletOption right) {
    final byRank = _derivationRank(
      left.derivation,
    ).compareTo(_derivationRank(right.derivation));
    if (byRank != 0) {
      return byRank;
    }

    return left.derivation.hdPath.compareTo(right.derivation.hdPath);
  }

  int _derivationRank(WalletDerivation derivation) {
    if (derivation.accountIndex == 0 && derivation.changeIndex == 0) {
      return 0;
    }
    if (derivation.accountIndex == null && derivation.changeIndex == null) {
      return 1;
    }
    return 2;
  }

  void _continue() {
    final selectedOption = _selectedOption;
    if (selectedOption == null || _submitting) {
      return;
    }

    setState(() => _submitting = true);
    context.push(
      PinSetupPage.routePath,
      extra: PinSetupFlowData(
        mnemonic: widget.mnemonic,
        derivation: selectedOption.derivation,
        publicKey: selectedOption.address,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return SecureScreen(
      child: AppScaffold(
        title: l10n.importWalletTitle,
        child: Column(
          children: [
            WalletCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.commonNetwork,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      color: theme.colorScheme.secondaryContainer,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.hub_rounded,
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.importSolanaMainnet,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onSecondaryContainer,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                l10n.importSelectSolanaAccount,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSecondaryContainer
                                      .withValues(alpha: 0.78),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildBody(theme)),
            const SizedBox(height: 16),
            PrimaryButton(
              label: l10n.commonContinue,
              onPressed: _selectedOption == null || _submitting
                  ? null
                  : _continue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_loading) {
      return WalletCard(
        child: SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                context.l10n.importLoadingSolanaAccounts,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                context.l10n.importCheckingActiveSolanaAccounts,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return WalletCard(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.l10n.importUnableScanRecoveryPhrase,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              _errorMessage!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _loadOptions,
              child: Text(context.l10n.commonRetry),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: _options.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final option = _options[index];
        final isSelected = option.address == _selectedOption?.address;

        return InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () {
            setState(() => _selectedOption = option);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.secondaryContainer.withValues(alpha: 0.88)
                  : theme.colorScheme.surface.withValues(alpha: 0.98),
              borderRadius: BorderRadius.circular(30),
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
                  children: [
                    Expanded(
                      child: Text(
                        option.derivation.importLabel,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() => _selectedOption = option);
                      },
                      icon: Icon(
                        isSelected
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                      ),
                    ),
                  ],
                ),
                Text(
                  Formatters.compactAddress(option.address, visibleChars: 6),
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  option.hasAssets
                      ? context.l10n.importActiveAccount
                      : context.l10n.importDefaultMainWallet,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  option.derivation.hdPath,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
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

class _ImportWalletOption {
  const _ImportWalletOption({
    required this.address,
    required this.assetCount,
    required this.derivation,
  });

  final String address;
  final int assetCount;
  final WalletDerivation derivation;

  bool get hasAssets => assetCount > 0;
}
