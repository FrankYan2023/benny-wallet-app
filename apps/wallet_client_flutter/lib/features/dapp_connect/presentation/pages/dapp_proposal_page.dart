import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/walletconnect/dapp_review.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../l10n/l10n.dart';
import '../../../auth/presentation/providers/wallet_controller.dart';
import '../../data/dapp_activity_store.dart';
import '../../data/dapp_blocklist.dart';
import '../../data/dapp_connect_service.dart';
import '../../data/dapp_signer.dart';
import '../../data/session_namespaces.dart';
import '../widgets/dapp_ui.dart';

/// Asks whether a dApp may connect, and with which wallet. Pops true when
/// the session was approved.
class DappProposalPage extends ConsumerStatefulWidget {
  const DappProposalPage({super.key, required this.proposal});

  static const routeName = 'dappProposal';
  static const routePath = '/dapps/proposal';

  final DappProposal proposal;

  @override
  ConsumerState<DappProposalPage> createState() => _DappProposalPageState();
}

class _DappProposalPageState extends ConsumerState<DappProposalPage> {
  String? _selected;
  bool _busy = false;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    final state = ref.read(walletControllerProvider);
    // Benny's browser connects the wallet selected in the app, nothing else.
    final eligible = state.wallets.where(
      (w) =>
          canConnectDapps(w.custody) &&
          (_responder.channel != DappChannel.browser ||
              w.publicKey == state.publicKey),
    );
    _selected =
        eligible
            .where((w) => w.publicKey == state.publicKey)
            .firstOrNull
            ?.publicKey ??
        eligible.firstOrNull?.publicKey;
  }

  /// WalletConnect's check, overridden by Benny Wallet's blocklist.
  SiteCheck get _site =>
      ref.read(dappBlocklistProvider).current.blocksHost(_host)
      ? SiteCheck.scam
      : widget.proposal.site;

  bool get _blocked => _site == SiteCheck.scam || !widget.proposal.chains.ok;

  DappResponder get _responder =>
      widget.proposal.via ?? ref.read(dappConnectServiceProvider);

  Future<void> _record(DappActivityEvent event, {String? address}) async {
    final proposal = widget.proposal;
    final host =
        DappReviewer.hostOf(proposal.origin) ??
        DappReviewer.hostOf(proposal.peer.url) ??
        proposal.peer.url;
    try {
      await ref
          .read(dappActivityStoreProvider)
          .add(
            DappActivity(
              at: DateTime.now(),
              host: host,
              siteName: _siteName,
              icon: proposal.peer.icons
                  .where((i) => i.startsWith('https://'))
                  .firstOrNull,
              event: event,
              wallet: address == null ? null : Formatters.address(address),
              viaPhone: _responder.channel == DappChannel.phoneApp,
              inBrowser: _responder.channel == DappChannel.browser,
            ),
          );
    } on Object {
      // The log is a convenience.
    }
  }

  Future<void> _reject() async {
    if (_answered) {
      return;
    }
    _answered = true;
    await _record(DappActivityEvent.connectRejected);
    try {
      await _responder.reject(
        widget.proposal,
        unsupported: !widget.proposal.chains.ok,
      );
    } on Object {
      // The proposal expired; nothing to answer.
    }
    if (mounted) {
      context.pop(false);
    }
  }

  Future<void> _approve() async {
    final address = _selected;
    if (address == null || _busy) {
      return;
    }
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      await _responder.approve(widget.proposal, address);
      _answered = true;
      await _record(DappActivityEvent.connected, address: address);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.dappConnected(_siteName))),
      );
      if (mounted) {
        context.pop(true);
      }
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(l10n.dappPairFailed)));
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  String? get _host =>
      DappReviewer.hostOf(widget.proposal.origin) ??
      DappReviewer.hostOf(widget.proposal.peer.url);

  String get _siteName {
    final name = widget.proposal.peer.name.trim();
    return name.isNotEmpty ? name : (_host ?? '?');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final walletState = ref.watch(walletControllerProvider);
    final wallets = walletState.wallets
        .where(
          (w) =>
              canConnectDapps(w.custody) &&
              (_responder.channel != DappChannel.browser ||
                  w.publicKey == walletState.publicKey),
        )
        .toList();
    final problem = switch (widget.proposal.chains.problem) {
      ProposalProblem.otherChains ||
      ProposalProblem.noSolana => l10n.dappProposalOnlySolana,
      ProposalProblem.unsupportedSolanaChain =>
        l10n.dappProposalUnsupportedChain,
      null => null,
    };
    final siteWarning = switch (_site) {
      SiteCheck.scam => DappWarningKind.siteScam,
      SiteCheck.mismatch => DappWarningKind.siteMismatch,
      _ => null,
    };

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _reject();
        }
      },
      child: AppScaffold(
        title: l10n.dappProposalTitle,
        showBackButton: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  const SizedBox(height: 8),
                  DappHeader(
                    peer: widget.proposal.peer,
                    host: _host,
                    site: _site,
                    subtitle: l10n.dappProposalWants(_siteName),
                  ),
                  const SizedBox(height: 20),
                  if (siteWarning != null) ...[
                    _Notice(
                      text: dappWarningText(l10n, siteWarning),
                      color: DappTrust.danger.color,
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (problem != null)
                    _Notice(text: problem, color: DappTrust.caution.color)
                  else if (wallets.isEmpty)
                    _Notice(
                      text: l10n.dappProposalNoEligibleWallet,
                      color: DappTrust.caution.color,
                    )
                  else ...[
                    DappCard(
                      title: l10n.dappProposalCanDo,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Bullet(l10n.dappProposalSeeAddress),
                          _Bullet(l10n.dappProposalRequestSign),
                          const SizedBox(height: 8),
                          Text(
                            l10n.dappProposalNoAutoFunds,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    DappCard(
                      title: l10n.dappProposalWallet,
                      child: RadioGroup<String>(
                        groupValue: _selected,
                        onChanged: (value) {
                          if (!_busy) {
                            setState(() => _selected = value);
                          }
                        },
                        child: Column(
                          children: [
                            for (final wallet in wallets)
                              RadioListTile<String>(
                                contentPadding: EdgeInsets.zero,
                                value: wallet.publicKey,
                                title: Text(wallet.name),
                                subtitle: Text(
                                  Formatters.address(wallet.publicKey),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _busy ? null : _reject,
                    child: Text(l10n.dappReject),
                  ),
                ),
                if (!_blocked && wallets.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _busy || _selected == null ? null : _approve,
                      child: Text(
                        _busy ? l10n.dappConnecting : l10n.dappConnect,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 18,
            color: AppColors.success,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
