import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solana/base58.dart';
import 'package:reown_walletkit/reown_walletkit.dart' show Errors;

import '../../../../app/di/providers.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/airgap/airgap_protocol.dart';
import '../../../../core/airgap/sign_in_message.dart';
import '../../../../core/airgap/solana_message_parser.dart';
import '../../../../core/airgap/token_registry.dart';
import '../../../../core/security/secure_screen.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/walletconnect/dapp_actions.dart';
import '../../../../core/walletconnect/dapp_review.dart';
import '../../../../core/walletconnect/raw_transaction.dart';
import '../../../../core/walletconnect/solana_wc_request.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/pin_prompt_dialog.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../l10n/l10n.dart';
import '../../../airgap/presentation/air_gap_signing.dart';
import '../../../airgap/presentation/pages/air_gap_sign_page.dart';
import '../../../auth/domain/wallet_controller_state.dart';
import '../../../auth/presentation/providers/wallet_controller.dart';
import '../../../portfolio/presentation/providers/portfolio_provider.dart';
import '../../../signer/presentation/widgets/hold_to_confirm_button.dart';
import '../../data/dapp_activity_store.dart';
import '../../data/dapp_connect_service.dart';
import '../../data/dapp_signer.dart';
import '../widgets/dapp_ui.dart';

/// Reviews and signs one dApp request. Every way out answers the dApp:
/// the result when signed, a rejection otherwise.
class DappRequestPage extends ConsumerStatefulWidget {
  const DappRequestPage({super.key, required this.request});

  static const routeName = 'dappRequest';
  static const routePath = '/dapps/request';

  final DappRequest request;

  @override
  ConsumerState<DappRequestPage> createState() => _DappRequestPageState();
}

enum _Phase { loading, review, signing, done, failed }

class _DappRequestPageState extends ConsumerState<DappRequestPage> {
  _Phase _phase = _Phase.loading;
  PreparedDappRequest? _prepared;
  String? _message;
  bool _acceptedRisk = false;
  bool _answered = false;

  DappRequest get _request => widget.request;

  @override
  void initState() {
    super.initState();
    unawaited(_prepare());
  }

  Future<void> _prepare() async {
    final wallets = ref.read(walletControllerProvider).wallets;
    final wallet = wallets
        .where((w) => w.publicKey == _request.address)
        .firstOrNull;
    if (wallet == null || !canConnectDapps(wallet.custody)) {
      await _refuse(error: Errors.UNSUPPORTED_ACCOUNTS);
      _finish(_Phase.failed, context.l10n.dappRequestInvalid);
      return;
    }
    try {
      final prepared = await ref
          .read(dappSignerProvider)
          .prepare(
            method: _request.method,
            params: _request.params,
            address: _request.address,
            site: _request.site,
            siteHost: _request.siteHost,
          );
      if (!mounted) {
        return;
      }
      setState(() {
        _prepared = prepared;
        _phase = _Phase.review;
      });
    } on Object {
      // Params or transaction bytes the parser could not read.
      await _refuse(error: Errors.MALFORMED_REQUEST_PARAMS);
      if (mounted) {
        _finish(_Phase.failed, context.l10n.dappRequestInvalid);
      }
    }
  }

  DappResponder get _responder =>
      _request.via ?? ref.read(dappConnectServiceProvider);

  Future<void> _refuse({String error = Errors.USER_REJECTED_SIGN}) async {
    if (_answered) {
      return;
    }
    _answered = true;
    try {
      await _responder.refuse(_request, error: error);
    } on Object {
      // The request expired or the session is gone.
    }
  }

  Future<void> _reject() async {
    // Recorded before answering: a dApp on this phone closes Benny as soon
    // as it has the answer.
    if (!_answered) {
      await _record(DappActivityEvent.rejected);
    }
    await _refuse();
    if (mounted) {
      context.pop(false);
    }
  }

  void _finish(_Phase phase, String message) {
    if (!mounted) {
      return;
    }
    setState(() {
      _phase = phase;
      _message = message;
    });
    Future<void>.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) {
        context.pop(phase == _Phase.done);
      }
    });
  }

  /// Biometrics when the user turned them on, else the PIN. Seed Vault
  /// asks for its own confirmation.
  Future<bool> _authenticate(WalletCustody custody) async {
    // Seed Vault and the offline signer ask for their own confirmation.
    if (custody == WalletCustody.seedVault || custody == WalletCustody.airGap) {
      return true;
    }
    final l10n = context.l10n;
    final state = ref.read(walletControllerProvider);
    if (state.biometricEnabled) {
      final ok = await ref
          .read(biometricAuthServiceProvider)
          .authenticateForUnlock(localizedReason: l10n.dappAuthReason);
      if (ok) {
        return true;
      }
    }
    if (!mounted) {
      return false;
    }
    final pin = await showDialog<String>(
      context: context,
      builder: (_) => PinPromptDialog(title: l10n.dappPinTitle),
    );
    if (pin == null) {
      return false;
    }
    try {
      await ref.read(walletControllerProvider.notifier).verifyPin(pin);
      return true;
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.unlockIncorrectPin)));
      }
      return false;
    }
  }

  Future<void> _sign() async {
    final prepared = _prepared;
    if (prepared == null || !prepared.review.canSign) {
      return;
    }
    final custody = ref
        .read(walletControllerProvider)
        .wallets
        .firstWhere((w) => w.publicKey == _request.address)
        .custody;
    // In Benny's own browser the wallet is already open and unlocked, and
    // the hold is the confirmation: no PIN on top.
    final inBrowser = _responder.channel == DappChannel.browser;
    if (!inBrowser && !await _authenticate(custody) || !mounted) {
      return;
    }
    final l10n = context.l10n;
    setState(() => _phase = _Phase.signing);
    final Object result;
    try {
      result = await ref
          .read(dappSignerProvider)
          .sign(
            prepared: prepared,
            address: _request.address,
            source: AirGapDappSource(
              host: _request.siteHost ?? '?',
              name: _request.peer.name.trim(),
              check: switch (_request.site) {
                SiteCheck.verified => AirGapSiteCheck.verified,
                SiteCheck.unknown => AirGapSiteCheck.unknown,
                SiteCheck.mismatch => AirGapSiteCheck.mismatch,
                SiteCheck.scam => AirGapSiteCheck.scam,
              },
            ),
            requestedAt: _request.receivedAt,
            requestWindow: _responder.channel == DappChannel.phoneApp
                ? AirGapSignPage.phoneAppRequestWindow
                : null,
          );
    } on AirGapSigningCancelled {
      // Closed the QR page: back to the review, nothing answered yet.
      if (mounted) {
        setState(() => _phase = _Phase.review);
      }
      return;
    } on Object catch (error) {
      await _record(DappActivityEvent.failed);
      await _refuse(error: Errors.USER_REJECTED_SIGN);
      _finish(_Phase.failed, l10n.dappRequestFailed(_short(error)));
      return;
    }
    final sent = prepared.request.kind == DappRequestKind.signAndSend;
    _answered = true;
    try {
      await _responder.respond(_request, result);
    } on Object catch (error) {
      // A sent transaction is on chain even if the website stopped
      // waiting; anything else never reached the website.
      if (!sent) {
        await _record(DappActivityEvent.failed);
        _finish(_Phase.failed, l10n.dappRequestFailed(_short(error)));
        return;
      }
    }
    await _record(
      sent ? DappActivityEvent.sent : DappActivityEvent.signed,
      result: result,
    );
    _finish(_Phase.done, sent ? l10n.dappRequestSent : l10n.dappRequestDone);
  }

  /// Adds this request to the website activity log on this phone.
  Future<void> _record(DappActivityEvent event, {Object? result}) async {
    final prepared = _prepared;
    final host = _request.siteHost ?? _request.peer.url;
    String? action;
    String? protocol;
    String? pay;
    String? receive;
    var programs = const <String>[];
    if (prepared != null) {
      programs = {
        for (final m in prepared.messages)
          for (final i in m.instructions)
            if (i.programId != SolanaPrograms.computeBudget)
              DappPrograms.nameOf(i.programId) ??
                  Formatters.address(i.programId),
      }.toList();
      if (prepared.request.kind == DappRequestKind.message) {
        action = 'message';
      } else {
        final classified = DappActions.classify(prepared.messages);
        action = classified.kind.name;
        protocol = classified.protocol;
        final outcome = prepared.simulation;
        if (outcome != null && outcome.failed == null) {
          final rows = _balanceRows(ref, outcome);
          String? join(Iterable<(String, double, bool)> items) => items.isEmpty
              ? null
              : items
                    .map((r) => '${Formatters.amount(r.$2.abs())} ${r.$1}')
                    .join(' + ');
          pay = join(rows.where((r) => r.$2 < 0));
          receive = join(rows.where((r) => r.$2 > 0));
        }
      }
    }
    final entry = DappActivity(
      at: DateTime.now(),
      host: host,
      siteName: _request.peer.name.trim().isEmpty
          ? host
          : _request.peer.name.trim(),
      icon: _request.peer.icons
          .where((i) => i.startsWith('https://'))
          .firstOrNull,
      event: event,
      action: action,
      protocol: protocol,
      pay: pay,
      receive: receive,
      signature: action == 'message' ? null : _transactionId(result),
      wallet: Formatters.address(_request.address),
      programs: programs,
      viaPhone: _responder.channel == DappChannel.phoneApp,
      inBrowser: _responder.channel == DappChannel.browser,
    );
    try {
      await ref.read(dappActivityStoreProvider).add(entry);
    } on Object {
      // The log is a convenience; signing goes on without it.
    }
  }

  /// The transaction id of a signed or sent result, when it is final: the
  /// first signature, which the fee payer adds.
  static String? _transactionId(Object? result) {
    if (result is! Map) {
      return null;
    }
    final encoded = switch (result) {
      {'transaction': final String t} => t,
      {'transactions': final List list} when list.isNotEmpty =>
        list.first as String?,
      _ => null,
    };
    if (encoded == null) {
      // Sent: the result carries the transaction id itself.
      final signature = result['signature'];
      return result.length == 1 && signature is String ? signature : null;
    }
    try {
      final first = RawTransaction.parse(
        DappSignRequest.decodeTransaction(encoded),
      ).signatureAt(0);
      return first == null ? null : base58encode(first);
    } on Object {
      return null;
    }
  }

  static String _short(Object error) {
    final text = error.toString().replaceFirst(
      RegExp(r'^(Bad state|Exception|StateError): '),
      '',
    );
    return text.length > 140 ? '${text.substring(0, 140)}…' : text;
  }

  String _title(AppLocalizations l10n) {
    final prepared = _prepared;
    if (prepared == null) {
      return l10n.dappRequestTitle;
    }
    final request = prepared.request;
    switch (request.kind) {
      case DappRequestKind.message:
        final text = DappReviewer.readableText(request.message!);
        final signIn = text == null ? null : SolanaSignInMessage.parse(text);
        return signIn != null
            ? l10n.dappRequestSignIn(signIn.domain)
            : l10n.dappRequestSignMessage;
      case DappRequestKind.allTransactions when request.transactions.length > 1:
        return l10n.dappRequestTransactions(request.transactions.length);
      default:
        return l10n.dappRequestTransaction;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final prepared = _prepared;
    final wallet = ref
        .watch(walletControllerProvider)
        .wallets
        .where((w) => w.publicKey == _request.address)
        .firstOrNull;

    return SecureScreen(
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop &&
              (_phase == _Phase.review || _phase == _Phase.loading)) {
            _reject();
          }
        },
        child: AppScaffold(
          title: l10n.dappRequestTitle,
          showBackButton: false,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    const SizedBox(height: 4),
                    DappHeader(
                      peer: _request.peer,
                      host: _request.siteHost,
                      site: _request.site,
                      subtitle: _title(l10n),
                    ),
                    const SizedBox(height: 16),
                    if (_phase == _Phase.loading) ...[
                      const SizedBox(height: 24),
                      const Center(child: CircularProgressIndicator()),
                      const SizedBox(height: 12),
                      Center(child: Text(l10n.dappRequestLoading)),
                    ] else if (_message != null)
                      _ResultBanner(
                        text: _message!,
                        success: _phase == _Phase.done,
                      )
                    else if (prepared != null) ...[
                      DappTrustPanel(review: prepared.review),
                      const SizedBox(height: 12),
                      if (wallet != null)
                        DappCard(
                          title: l10n.dappRequestSigningWallet,
                          child: Text(
                            '${wallet.name}  ·  '
                            '${Formatters.address(wallet.publicKey)}',
                          ),
                        ),
                      const SizedBox(height: 12),
                      ..._details(l10n, prepared),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _actions(l10n, prepared),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _details(AppLocalizations l10n, PreparedDappRequest prepared) {
    final request = prepared.request;
    if (request.kind == DappRequestKind.message) {
      final text = DappReviewer.readableText(request.message!);
      return [
        DappCard(
          title: l10n.dappRequestMessage,
          child: SelectableText(
            text ?? '0x${_hex(request.message!)}',
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
          ),
        ),
      ];
    }
    final fee = prepared.messages.fold<BigInt>(
      BigInt.zero,
      (sum, m) => sum + m.estimatedFeeLamports,
    );
    final feeText = '≈ ${_sol(fee.toDouble(), digits: 6)} SOL';
    final programs = <String>{
      for (final m in prepared.messages)
        for (final i in m.instructions)
          if (i.programId != SolanaPrograms.computeBudget) i.programId,
    };
    return [
      // A swap built by the site expires within about a minute; two QR
      // round trips with a cold wallet often take longer.
      if (_coldWallet &&
          DappActions.classify(prepared.messages).kind ==
              DappActionKind.swap) ...[
        DappCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.timer_outlined, color: DappTrust.caution.color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.dappColdSwapNotice,
                  style: TextStyle(
                    color: DappTrust.caution.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
      _ActionSummary(
        messages: prepared.messages,
        simulation: prepared.simulation,
      ),
      const SizedBox(height: 12),
      DappCard(
        title: l10n.dappRequestBalanceChanges,
        child: _BalanceChanges(
          simulation: prepared.simulation,
          emptyText: l10n.dappRequestNoBalanceChange,
          unavailableText: l10n.dappWarnSimulationUnavailable,
        ),
      ),
      const SizedBox(height: 12),
      DappCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(l10n.dappRequestNetworkFee)),
                Text(feeText),
              ],
            ),
            if (request.kind == DappRequestKind.signAndSend) ...[
              const SizedBox(height: 6),
              Text(
                l10n.dappRequestSendNote,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ],
        ),
      ),
      const SizedBox(height: 12),
      DappCard(
        title: l10n.dappRequestPrograms,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final program in programs)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DappPrograms.nameOf(program) ?? l10n.dappActionOther,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: DappPrograms.nameOf(program) == null
                            ? DappTrust.caution.color
                            : null,
                      ),
                    ),
                    SelectableText(
                      program,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ];
  }

  bool get _coldWallet =>
      ref
          .read(walletControllerProvider)
          .wallets
          .where((w) => w.publicKey == _request.address)
          .firstOrNull
          ?.custody ==
      WalletCustody.airGap;

  Widget _actions(AppLocalizations l10n, PreparedDappRequest? prepared) {
    final busy = _phase != _Phase.review;
    final reject = OutlinedButton(
      onPressed: busy && _phase != _Phase.loading ? null : _reject,
      child: Text(l10n.dappReject),
    );
    if (prepared == null || _message != null) {
      return _message != null
          ? const SizedBox.shrink()
          : SizedBox(width: double.infinity, child: reject);
    }
    final trust = prepared.review.trust;
    if (trust == DappTrust.blocked) {
      return Column(
        children: [
          Text(
            l10n.dappRequestBlocked,
            textAlign: TextAlign.center,
            style: TextStyle(color: trust.color, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          SizedBox(width: double.infinity, child: reject),
        ],
      );
    }
    final Widget confirm;
    if (_phase == _Phase.signing) {
      confirm = const FilledButton(
        onPressed: null,
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    } else if (_coldWallet ||
        (trust == DappTrust.safe &&
            _responder.channel != DappChannel.browser)) {
      // A cold wallet is confirmed on the signer (with its own hold), and a
      // phone app's request runs out quickly: one tap shows the QR code.
      confirm = FilledButton(
        onPressed: busy || (trust == DappTrust.danger && !_acceptedRisk)
            ? null
            : _sign,
        child: Text(l10n.dappRequestSign),
      );
    } else {
      confirm = HoldToConfirmButton(
        label: l10n.dappRequestHoldToSign,
        danger: trust == DappTrust.danger,
        holdDuration: Duration(
          milliseconds: trust == DappTrust.danger ? 2000 : 1000,
        ),
        onConfirmed: busy || (trust == DappTrust.danger && !_acceptedRisk)
            ? null
            : _sign,
      );
    }
    return Column(
      children: [
        if (trust == DappTrust.danger)
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: _acceptedRisk,
            onChanged: busy
                ? null
                : (value) => setState(() => _acceptedRisk = value ?? false),
            title: Text(l10n.dappRequestAcceptRisk),
          ),
        Row(
          children: [
            Expanded(child: reject),
            const SizedBox(width: 12),
            Expanded(flex: 2, child: confirm),
          ],
        ),
      ],
    );
  }

  static String _hex(List<int> bytes) =>
      bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

  static String _sol(double lamports, {int digits = 4}) =>
      Formatters.amount(lamports / 1e9, maxDecimals: digits);
}

class _ResultBanner extends StatelessWidget {
  const _ResultBanner({required this.text, required this.success});

  final String text;
  final bool success;

  @override
  Widget build(BuildContext context) {
    final color = success ? DappTrust.safe.color : DappTrust.danger.color;
    return Column(
      children: [
        const SizedBox(height: 24),
        Icon(
          success ? Icons.check_circle_rounded : Icons.error_rounded,
          size: 56,
          color: color,
        ),
        const SizedBox(height: 12),
        Text(
          text,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}

/// Predicted SOL and token changes, gains in green and losses in red.
class _BalanceChanges extends ConsumerWidget {
  const _BalanceChanges({
    required this.simulation,
    required this.emptyText,
    required this.unavailableText,
  });

  final SimulationOutcome? simulation;
  final String emptyText;
  final String unavailableText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outcome = simulation;
    if (outcome == null || outcome.failed != null) {
      return Text(
        outcome?.failed != null
            ? context.l10n.dappWarnSimulationFailed
            : unavailableText,
        style: const TextStyle(color: AppColors.textSecondary),
      );
    }
    final rows = _balanceRows(ref, outcome);
    if (rows.isEmpty) {
      return Text(
        emptyText,
        style: const TextStyle(color: AppColors.textSecondary),
      );
    }
    return Column(
      children: [
        for (final (symbol, amount, _) in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    symbol,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  '${amount > 0 ? '+' : '−'}'
                  '${Formatters.amount(amount.abs())}',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: amount > 0
                        ? DappTrust.safe.color
                        : DappTrust.danger.color,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Balance changes for the user, as (symbol, amount, symbol known) rows.
List<(String, double, bool)> _balanceRows(
  WidgetRef ref,
  SimulationOutcome outcome,
) {
  final holdings =
      ref.watch(activePortfolioProvider).valueOrNull?.assets ?? const [];
  final registry = TokenRegistry();
  final rows = <(String, double, bool)>[];
  // Fees alone are not worth a line; anything above 0.0001 SOL is.
  if (outcome.lamportsChange.abs() > 100000) {
    rows.add(('SOL', outcome.lamportsChange / 1e9, true));
  }
  outcome.tokenChanges.forEach((mint, raw) {
    final held = holdings.where((h) => h.token.mintAddress == mint);
    final known = held.isNotEmpty
        ? (held.first.token.symbol, held.first.token.decimals)
        : switch (registry.resolve(mint).token) {
            final SignerToken t => (t.symbol, t.decimals),
            null => null,
          };
    if (known == null) {
      rows.add((Formatters.address(mint), raw.toDouble(), false));
    } else {
      rows.add((known.$1, raw.toDouble() / pow(10, known.$2), true));
    }
  });
  return rows;
}

/// The headline of a transaction review: what it does, through which
/// protocol, and what the user pays and receives.
class _ActionSummary extends ConsumerWidget {
  const _ActionSummary({required this.messages, required this.simulation});

  final List<ParsedSolanaMessage> messages;
  final SimulationOutcome? simulation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final action = DappActions.classify(messages);
    final (label, icon) = switch (action.kind) {
      DappActionKind.swap => (l10n.dappActionSwap, Icons.swap_horiz_rounded),
      DappActionKind.transfer => (
        l10n.dappActionTransfer,
        Icons.arrow_outward_rounded,
      ),
      DappActionKind.stake => (l10n.dappActionStake, Icons.savings_rounded),
      DappActionKind.lend => (
        l10n.dappActionLend,
        Icons.account_balance_rounded,
      ),
      DappActionKind.perps => (
        l10n.dappActionPerps,
        Icons.candlestick_chart_rounded,
      ),
      DappActionKind.nft => (l10n.dappActionNft, Icons.image_rounded),
      DappActionKind.other => (
        l10n.dappActionOther,
        Icons.help_outline_rounded,
      ),
    };
    final outcome = simulation;
    final rows = outcome == null || outcome.failed != null
        ? const <(String, double, bool)>[]
        : _balanceRows(ref, outcome);
    final paid = rows.where((r) => r.$2 < 0).toList();
    final received = rows.where((r) => r.$2 > 0).toList();
    String list(List<(String, double, bool)> items) => items
        .map((r) => '${Formatters.amount(r.$2.abs())} ${r.$1}')
        .join(' + ');
    final unknown =
        action.unknownPrograms.isNotEmpty ||
        action.kind == DappActionKind.other;

    return DappCard(
      title: l10n.dappActionTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: label,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      if (action.protocol != null)
                        TextSpan(
                          text: '  ·  ${l10n.dappActionVia(action.protocol!)}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ],
          ),
          if (paid.isNotEmpty) ...[
            const SizedBox(height: 10),
            _SummaryLine(
              label: l10n.dappActionPay,
              value: list(paid),
              color: DappTrust.danger.color,
            ),
          ],
          if (received.isNotEmpty) ...[
            const SizedBox(height: 6),
            _SummaryLine(
              label: l10n.dappActionReceive,
              value: list(received),
              color: DappTrust.safe.color,
            ),
          ],
          if (unknown) ...[
            const SizedBox(height: 10),
            Text(
              l10n.dappActionUnknownHint,
              style: TextStyle(color: DappTrust.caution.color),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 88,
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w800, color: color),
          ),
        ),
      ],
    );
  }
}
