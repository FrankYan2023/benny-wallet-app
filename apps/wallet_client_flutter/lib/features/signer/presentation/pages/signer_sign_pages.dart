import 'package:design_system/design_system.dart';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:solana/base58.dart';
import 'package:solana/solana.dart' show Ed25519HDPublicKey;

import '../../../../app/theme/app_colors.dart';
import '../../../../core/airgap/airgap_protocol.dart';
import '../../../../core/airgap/sign_in_message.dart';
import '../../../../core/airgap/signer_engine.dart';
import '../../../../core/airgap/solana_message_parser.dart';
import '../../../../core/airgap/token_registry.dart';
import '../../../../core/airgap/ur.dart';
import '../../../../core/airgap/widgets/animated_ur_qr.dart';
import '../../../../core/airgap/widgets/scan_hint_animation.dart';
import '../../../../core/airgap/widgets/ur_scanner_view.dart';
import '../../../../core/utils/formatters.dart';
import '../../../airgap/presentation/widgets/countdown_border.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../l10n/l10n.dart';
import '../signer_controller.dart';
import '../widgets/hold_to_confirm_button.dart';
import '../widgets/signer_ui.dart';
import '../widgets/token_icon.dart';
import 'signer_home_page.dart' show shortAddress;

class SignerScanPage extends StatefulWidget {
  const SignerScanPage({super.key, required this.controller});

  final SignerController controller;

  @override
  State<SignerScanPage> createState() => _SignerScanPageState();
}

class _SignerScanPageState extends State<SignerScanPage> {
  String? _error;
  int _scannerKey = 0;

  Future<void> _onResult(Ur ur) async {
    final l10n = context.l10n;
    final engine = widget.controller.engine;
    if (engine == null) {
      return;
    }
    try {
      final request = AirGapSignRequest.fromUr(ur);
      final review = engine.review(request);
      // Names the wallet sent along, for tokens this transaction touches.
      final tx = review.transaction;
      final summary = request.swapSummary;
      final tokens = await widget.controller.tokens.withHints(
        request.tokenHints,
        mints: {
          ...?tx?.accountKeys,
          // Mints may sit in accounts the signer could not read; the names
          // are still checked against their signatures.
          if (summary != null && (tx?.hasUnresolvedAccounts ?? false)) ...[
            base58encode(summary.inputMint),
            base58encode(summary.outputMint),
          ],
        },
      );
      final recipient = await verifiedRecipient(request, tx);
      final ownAccounts = await findOwnAccounts(tx, review.signerAddress);
      if (!mounted) {
        return;
      }
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => SignerReviewPage(
            controller: widget.controller,
            review: review,
            tokens: tokens,
            ownAccounts: ownAccounts,
            recipient: recipient,
          ),
        ),
      );
    } on SignerRejection catch (error) {
      setState(
        () => _error = switch (error.reason) {
          SignerRejectReason.unknownAccount => l10n.signerRejectUnknownAccount,
          SignerRejectReason.notASigner => l10n.signerRejectNotASigner,
          SignerRejectReason.unreadableTransaction =>
            l10n.signerRejectUnreadable,
          SignerRejectReason.messageIsTransaction =>
            l10n.signerRejectMessageIsTransaction,
        },
      );
    } on Object {
      setState(() => _error = l10n.signerRejectInvalidCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SignerScaffold(
      title: l10n.signerScanToSign,
      children: [
        if (_error == null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: UrScannerView(
              key: ValueKey(_scannerKey),
              acceptedTypes: const {AirGapUrType.signRequest},
              onResult: _onResult,
              onWrongCode: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.signerScanWrongCode)),
                );
              },
            ),
          ),
          const SizedBox(height: 18),
          ScanHintAnimation(
            qrOnLeft: false,
            leftLabel: widget.controller.info?.deviceName ?? '',
            rightLabel: l10n.signerWalletPhoneLabel,
            height: 96,
          ),
          const SizedBox(height: 10),
          Text(
            l10n.signerScanBody,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ] else ...[
          SignerHero(
            icon: Icons.block_rounded,
            tone: SignerTone.danger,
            title: l10n.signerScanRefusedTitle,
            subtitle: _error,
          ),
          const SizedBox(height: 22),
          PrimaryButton(
            label: l10n.signerScanAgain,
            onPressed: () => setState(() {
              _error = null;
              _scannerKey++;
            }),
          ),
        ],
      ],
    );
  }
}

class SignerReviewPage extends StatefulWidget {
  const SignerReviewPage({
    super.key,
    required this.controller,
    required this.review,
    required this.tokens,
    required this.ownAccounts,
    this.recipient,
  });

  final SignerController controller;
  final SignerReview review;

  /// The signer's token list plus the names sent with this request.
  final TokenRegistry tokens;

  /// This signer's token accounts among the transaction's own keys; see
  /// [findOwnAccounts].
  final SignerOwnAccounts ownAccounts;

  /// Who a send pays, checked against the transaction.
  final SignerRecipient? recipient;

  @override
  State<SignerReviewPage> createState() => _SignerReviewPageState();
}

/// One reason the screen is not green, with the colour it calls for.
typedef _Warning = ({String text, TxTrust level, IconData icon});

class _SignerReviewPageState extends State<SignerReviewPage> {
  bool _signing = false;
  String? _error;

  SignerReview get _review => widget.review;
  ParsedSolanaMessage? get _tx => _review.transaction;
  String get _signer => _review.signerAddress;
  List<ParsedInstruction> get _instructions =>
      _tx?.instructions ?? const <ParsedInstruction>[];

  /// The token list, minus mints whose address here is only the wallet's
  /// word (read from a lookup table and not tied to the signer's own
  /// token account).
  late final TokenRegistry _tokens = widget.tokens.withUnchecked(
    uncheckedMints(_tx, _signer, widget.ownAccounts, widget.tokens),
  );

  /// The wallet's swap quote. It belongs only to a swap instruction of a
  /// known swap program, and only if both its tokens are used by the
  /// transaction (or may be, in accounts the signer could not read).
  late final AirGapSwapSummary? _swapSummary = () {
    final summary = _review.request.swapSummary;
    final tx = _tx;
    if (summary == null || tx == null || _firstSwap < 0) {
      return null;
    }
    // Some routes move native SOL, so wrapped SOL need not be an account.
    bool present(Uint8List mint) {
      final address = base58encode(mint);
      return address == TokenRegistry.wrappedSolMint ||
          tx.referencedAccounts.contains(address);
    }

    final found = present(summary.inputMint) && present(summary.outputMint);
    return found || tx.hasUnresolvedAccounts ? summary : null;
  }();

  late final int _firstSwap = _instructions.indexWhere(
    (i) => i.kind == ParsedInstructionKind.swap,
  );

  /// The step the swap quote belongs to.
  int? get _swapStep =>
      _swapSummary == null || _firstSwap < 0 ? null : _firstSwap;

  late final TxHeadline? _headline = TxHeadline.of(
    _review,
    // Guesses come from the full list; trust below uses [_tokens].
    widget.tokens,
    summary: _swapSummary,
    swapStep: _swapStep,
  );

  /// The address is this signer or one of its token accounts, and was
  /// written in the transaction itself (not read from a table).
  bool _isOwn(ParsedInstruction i, String? address, AccountField field) =>
      address != null &&
      !i.fromTable.contains(field) &&
      (address == _signer || widget.ownAccounts.isOwnTokenAccount(address));

  /// Steps that move SOL or tokens to someone other than this signer.
  late final List<int> _outflows = [
    for (final (index, i) in _instructions.indexed)
      if (switch (i.kind) {
        ParsedInstructionKind.solTransfer ||
        ParsedInstructionKind.tokenTransfer ||
        ParsedInstructionKind.closeTokenAccount => !_isOwn(
          i,
          i.to,
          AccountField.to,
        ),
        // The new account is never one of the signer's.
        ParsedInstructionKind.createAccount => true,
        _ => false,
      })
        index,
  ];

  /// Outflows besides the headline's own send.
  late final Set<int> _extraOutflows = {
    for (final index in _outflows)
      if (index != _headline?.sendIndex) index,
  };

  /// Swap steps whose output does not provably land with this signer.
  late final Set<int> _badSwapOutputs = {
    for (final (index, i) in _instructions.indexed)
      if (i.kind == ParsedInstructionKind.swap &&
          i.swap != null &&
          !swapPaysSigner(i, _signer, widget.ownAccounts))
        index,
  };

  bool get _hasUnverifiedToken {
    final step = _swapStep;
    return [
      for (final (index, i) in _instructions.indexed)
        hasUnverifiedToken(
          i,
          _tokens,
          summary: index == step ? _swapSummary : null,
        ),
    ].any((unverified) => unverified);
  }

  /// Every reason for yellow or red, most specific first.
  late final List<_Warning> _warnings = () {
    final l10n = context.l10n;
    final tx = _tx;
    if (tx == null) {
      return <_Warning>[];
    }
    final headline = _headline;
    const danger = TxTrust.danger;
    const caution = TxTrust.caution;
    final out = <_Warning>[];
    void add(String text, TxTrust level, [IconData? icon]) =>
        out.add((text: text, level: level, icon: icon ?? Icons.gpp_maybe));

    final unreadHeadline =
        headline != null &&
        (headline.payMint == '?' ||
            headline.getMint == '?' ||
            headline.to == '?');
    if (tx.hasUnresolvedAccounts) {
      add(
        l10n.signerUnresolvedAccounts,
        headline == null || unreadHeadline ? danger : caution,
      );
    }
    final tableSend = _instructions.any(
      (i) =>
          (i.kind == ParsedInstructionKind.solTransfer ||
              i.kind == ParsedInstructionKind.tokenTransfer) &&
          i.addressFromTable,
    );
    if (tableSend) {
      add(l10n.signerAddressFromWallet, danger);
    }
    if (_badSwapOutputs.isNotEmpty) {
      add(l10n.signerSwapOutputUnchecked, danger);
    }
    final slippage = _instructions.any(
      (i) => (i.swap?.slippageBps ?? 0) >= 10000,
    );
    if (slippage) {
      add(l10n.signerSlippageAll, danger);
    }
    if (_extraOutflows.isNotEmpty) {
      add(l10n.signerExtraOutflow, danger);
    }
    // A website's request: what the wallet said about the site, and each
    // program the signer cannot read, named so the user knows what it is.
    if (_source case final source?) {
      if (source.check == AirGapSiteCheck.scam) {
        add(l10n.signerDappSiteScam, danger, Icons.gpp_bad_rounded);
      } else if (source.check == AirGapSiteCheck.mismatch) {
        add(l10n.signerDappSiteMismatch, danger, Icons.gpp_bad_rounded);
      }
      final unread = {
        for (final i in _instructions)
          if (i.kind == ParsedInstructionKind.unknown &&
              i.risk == InstructionRisk.danger)
            i.programId,
      };
      for (final program in unread) {
        add(
          l10n.signerDappUnknownStep(shortAddress(program)),
          danger,
          Icons.help_outline_rounded,
        );
      }
    }
    // Any other step the signer flags as dangerous.
    if (!out.any((w) => w.level == danger) &&
        _instructions.any((i) => i.risk == InstructionRisk.danger)) {
      add(l10n.signerDangerBanner, danger);
    }
    if (tx.priorityFeeLamports > highPriorityFeeLamports) {
      add(
        l10n.signerHighFee(formatBaseUnits(tx.estimatedFeeLamports, 9)),
        caution,
        Icons.local_gas_station_rounded,
      );
    }
    if (_instructions.any(
      (i) => i.kind == ParsedInstructionKind.advanceNonce,
    )) {
      add(l10n.signerDurableNonce, caution, Icons.all_inclusive_rounded);
    }
    if (headline != null && headline.fromWallet) {
      add(l10n.signerSwapFromWallet, caution, Icons.info_outline_rounded);
    } else if (_instructions.any(
      (i) => i.kind == ParsedInstructionKind.swap && i.swap == null,
    )) {
      // A swap route whose amounts the signer cannot read.
      add(l10n.signerActionSwapDetail, caution, Icons.info_outline_rounded);
    }
    return out;
  }();

  TxTrust? get _tokenTrust => _headline?.tokenTrust(_tokens);

  /// The website the request came from, as the wallet reports it.
  AirGapDappSource? get _source => _review.request.dappSource;

  SolanaSignInMessage? get _signIn => _review.signIn;

  /// A login message: Benny's own, for this account and still valid, is
  /// green; another site's or an expired one is yellow; one for another
  /// account is red.
  late final _Warning? _signInVerdict = () {
    final signIn = _signIn;
    if (_tx != null || signIn == null) {
      return null;
    }
    final l10n = context.l10n;
    if (signIn.address != _signer) {
      return (
        text: l10n.signerSignInOtherAccount,
        level: TxTrust.danger,
        icon: Icons.gpp_bad_rounded,
      );
    }
    if (!signIn.isBenny) {
      return (
        text: l10n.signerSignInOtherSite(cleanDisplayText(signIn.domain)),
        level: TxTrust.caution,
        icon: Icons.public_rounded,
      );
    }
    if (signIn.isExpiredAt(DateTime.now())) {
      return (
        text: l10n.signerSignInExpired,
        level: TxTrust.caution,
        icon: Icons.timer_off_rounded,
      );
    }
    return (
      text: l10n.signerSignInBenny,
      level: TxTrust.safe,
      icon: Icons.verified_rounded,
    );
  }();

  /// Green, yellow or red for the whole screen. Swap: both tokens verified
  /// is green, one is yellow, neither is red. Send: an unverified token is
  /// red. Other risky steps make it red; unread accounts, a never-expiring
  /// signature, a very high fee or wallet-given swap terms make green
  /// yellow.
  late final TxTrust? _trust = () {
    if (_signInVerdict case final verdict?) {
      return verdict.level;
    }
    TxTrust? trust = _tokenTrust;
    for (final warning in _warnings) {
      if (trust == null || warning.level.index > trust.index) {
        trust = warning.level;
      }
    }
    return trust;
  }();

  /// The warning the headline leads with, when the colour comes from it
  /// rather than from the tokens.
  _Warning? get _leadWarning {
    final trust = _trust;
    if (_headline == null || trust == null || trust == _tokenTrust) {
      return null;
    }
    return _warnings.where((w) => w.level == trust).firstOrNull;
  }

  bool get _needsLongHold =>
      _hasUnverifiedToken ||
      (_trust != null && _trust != TxTrust.safe) ||
      _review.risk == InstructionRisk.danger;

  Future<void> _sign() async {
    final l10n = context.l10n;
    final engine = widget.controller.engine;
    if (_signing || engine == null) {
      return;
    }
    setState(() {
      _signing = true;
      _error = null;
    });
    final status = await widget.controller.refreshOfflineStatus();
    if (status.hasNetwork) {
      // The controller locks itself; this page goes away with it.
      return;
    }
    try {
      final signature = await engine.sign(
        _review,
        info: widget.controller.signerInfo,
      );
      if (!mounted) {
        return;
      }
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => SignerSignaturePage(
            signature: signature,
            deviceName: widget.controller.info?.deviceName ?? '',
          ),
        ),
      );
    } on Object {
      if (mounted) {
        setState(() {
          _signing = false;
          _error = l10n.signerSignFailed;
        });
      }
    }
  }

  /// Steps listed under the headline: all but fee settings and the one
  /// the headline already shows.
  List<(int, ParsedInstruction)> _otherSteps(ParsedSolanaMessage tx) => [
    for (final (index, i) in tx.instructions.indexed)
      if (i.kind != ParsedInstructionKind.computeUnitLimit &&
          i.kind != ParsedInstructionKind.computeUnitPrice &&
          index != _headline?.step)
        (index, i),
  ];

  int get _accountNumber => _review.account.path.indexes[2] + 1;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final tx = _tx;
    final lead = _leadWarning;
    final notices = <Widget>[
      if (_review.request.protocolVersion > airGapProtocolVersion)
        SignerNotice(
          icon: Icons.system_update_rounded,
          text: l10n.signerNewerWalletNotice,
        ),
      for (final warning in _warnings)
        if (warning != lead &&
            // Shown with the amounts already.
            warning.text != l10n.signerSwapFromWallet &&
            // Said by the swap step itself.
            warning.text != l10n.signerActionSwapDetail &&
            // Shown in the recipient box already.
            !(warning.text == l10n.signerAddressFromWallet &&
                _headline?.addressFromWallet == true))
          SignerNotice(
            icon: warning.icon,
            text: warning.text,
            tone: warning.level == TxTrust.danger
                ? SignerTone.danger
                : SignerTone.warm,
          ),
    ];
    final headline = _headline;
    final trust = _trust;
    final source = _source;
    final simulation = tx == null ? null : _review.request.simulation;
    final page = SignerScaffold(
      title: _signInVerdict == null
          ? l10n.signerReviewTitle
          : l10n.signerSignInTitle,
      transparent: trust != null,
      children: [
        if (source != null) ...[_DappSourceCard(source: source), signerGap],
        if (headline != null) ...[
          _HeadlineCard(
            headline: headline,
            tokens: _tokens,
            trust: trust ?? TxTrust.safe,
            // The recipient box already says the address is unchecked.
            verdict: headline.addressFromWallet
                ? l10n.signerDangerBanner
                : lead?.text,
            signerAddress: _signer,
            usdPrices: _review.request.usdPrices,
            recipient: widget.recipient,
          ),
          signerGap,
        ],
        for (final notice in notices) ...[notice, signerGap],
        if (simulation != null) ...[
          _SimulationCard(simulation: simulation, tokens: _tokens),
          signerGap,
        ],
        if (tx != null && _otherSteps(tx).isNotEmpty) ...[
          SignerSection(
            label: headline == null
                ? l10n.signerReviewActions
                : l10n.signerReviewOtherSteps,
            child: Column(
              children: [
                for (final (index, instruction) in _otherSteps(tx))
                  _InstructionTile(
                    instruction: instruction,
                    tokens: _tokens,
                    inputGuess: instruction.swap == null
                        ? null
                        : swapInputGuess(instruction, widget.tokens),
                    summary: index == _swapStep ? _swapSummary : null,
                    signerAddress: _signer,
                    recipient: widget.recipient,
                    warn:
                        _extraOutflows.contains(index) ||
                        _badSwapOutputs.contains(index),
                  ),
              ],
            ),
          ),
          signerGap,
        ],
        if (_signInVerdict case final verdict?) ...[
          _SignInCard(verdict: verdict, rawText: _review.messageText ?? ''),
          signerGap,
        ] else if (tx == null) ...[
          SignerSection(
            label: l10n.signerReviewMessage,
            child: SelectableText(
              _review.messageText ??
                  l10n.signerBinaryMessage(_review.request.signData.length),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          signerGap,
        ],
        // Who signs and what it costs: one small card.
        WalletCard(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            children: [
              _DetailRow(
                label: l10n.signerReviewAccount,
                value:
                    '${l10n.signerAccountName(_accountNumber)} · '
                    '${shortAddress(_signer)}',
              ),
              if (tx != null)
                _DetailRow(
                  label: l10n.signerReviewFee,
                  value: '≈ ${formatBaseUnits(tx.estimatedFeeLamports, 9)} SOL',
                  warn: tx.priorityFeeLamports > highPriorityFeeLamports,
                ),
              if (tx != null && tx.feePayer != _signer)
                _DetailRow(
                  label: l10n.signerReviewFeePayer,
                  value: shortAddress(tx.feePayer),
                ),
            ],
          ),
        ),
      ],
      bottom: _SignBar(
        hint: _needsLongHold ? l10n.signerHoldLongHint : null,
        error: _error,
        danger: _needsLongHold,
        signing: _signing,
        onSign: _sign,
        onReject: () => Navigator.of(context).pop(),
      ),
    );
    if (trust == null) {
      return page;
    }
    return CountdownBorder(remaining: 1, color: trust.color, child: page);
  }
}

/// Where a website's request came from. The wallet passed this on; the
/// signer cannot check it, but it tells the user the request did not
/// start in their own wallet.
class _DappSourceCard extends StatelessWidget {
  const _DappSourceCard({required this.source});

  final AirGapDappSource source;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final check = switch (source.check) {
      AirGapSiteCheck.verified => l10n.signerDappSiteVerified,
      AirGapSiteCheck.unknown => l10n.signerDappSiteUnverified,
      AirGapSiteCheck.mismatch => l10n.signerDappSiteMismatch,
      AirGapSiteCheck.scam => l10n.signerDappSiteScam,
    };
    final tone = switch (source.check) {
      AirGapSiteCheck.verified => SignerTone.info,
      AirGapSiteCheck.unknown => SignerTone.warm,
      AirGapSiteCheck.mismatch || AirGapSiteCheck.scam => SignerTone.danger,
    };
    return SignerNotice(
      icon: Icons.language_rounded,
      tone: tone,
      text: [
        l10n.signerDappSource(source.host),
        check,
        l10n.signerDappSourceHint,
      ].join('\n'),
    );
  }
}

/// The wallet's simulated balance changes for a website's transaction,
/// shown as its estimate: the signer cannot run the chain to check them.
class _SimulationCard extends StatelessWidget {
  const _SimulationCard({required this.simulation, required this.tokens});

  final AirGapSimulation simulation;
  final TokenRegistry tokens;

  static String _signed(BigInt amount, int decimals) {
    final text = formatBaseUnits(amount.abs(), decimals);
    return amount.isNegative ? '-$text' : '+$text';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final rows = <(String, String, bool)>[
      if (simulation.lamports != BigInt.zero)
        (
          'SOL',
          _signed(simulation.lamports, 9),
          simulation.lamports.isNegative,
        ),
      for (final change in simulation.tokens)
        if (change.amount != BigInt.zero)
          () {
            final mint = base58encode(change.mint);
            final resolved = tokens.resolve(mint);
            // A name only the wallet vouches for is marked with "?".
            final token = resolved.token;
            final symbol = token == null
                ? shortAddress(mint)
                : resolved.isVerified
                ? token.symbol
                : '${token.symbol}?';
            final decimals = resolved.decimals ?? 0;
            return (
              symbol,
              _signed(change.amount, decimals),
              change.amount.isNegative,
            );
          }(),
    ];
    return SignerSection(
      label: l10n.signerDappSimulation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (symbol, amount, out) in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Expanded(child: Text(symbol)),
                  Text(
                    amount,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: out ? AppColors.danger : AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          if (rows.isEmpty) Text(l10n.signerDappSimulationNone),
          const SizedBox(height: 6),
          Text(
            l10n.signerDappSimulationNote,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// A priority fee above this (0.01 SOL) is called out.
final highPriorityFeeLamports = BigInt.from(10000000);

class _InstructionTile extends StatelessWidget {
  const _InstructionTile({
    required this.instruction,
    required this.tokens,
    required this.signerAddress,
    this.inputGuess,
    this.summary,
    this.recipient,
    this.warn = false,
  });

  final ParsedInstruction instruction;
  final TokenRegistry tokens;
  final String signerAddress;
  final String? inputGuess;
  final AirGapSwapSummary? summary;
  final SignerRecipient? recipient;

  /// Flagged by the page (e.g. moves funds to someone else).
  final bool warn;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final (title, details) = _describe(l10n);
    final danger = instruction.risk == InstructionRisk.danger;
    final unverified = hasUnverifiedToken(
      instruction,
      tokens,
      summary: summary,
    );
    final warn = this.warn || danger || unverified;
    final color = warn ? theme.colorScheme.error : AppColors.textPrimary;
    final tone = warn ? SignerTone.danger : SignerTone.warm;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!warn && _createsAccountFor != null)
            _NewAccountIcon(token: _createsAccountFor!)
          else
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: tone.colors(theme).background,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                warn ? Icons.warning_amber_rounded : _icon,
                size: 18,
                color: tone.colors(theme).foreground,
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                for (final line in details)
                  SelectableText(line, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// The token whose account this step opens, if it is a known one.
  ResolvedToken? get _createsAccountFor {
    final mint = instruction.mint;
    if (instruction.kind != ParsedInstructionKind.createTokenAccount ||
        mint == null) {
      return null;
    }
    final token = tokens.resolve(mint);
    return token.token == null ? null : token;
  }

  IconData get _icon => switch (instruction.kind) {
    ParsedInstructionKind.solTransfer ||
    ParsedInstructionKind.tokenTransfer => Icons.north_east_rounded,
    ParsedInstructionKind.swap => Icons.swap_horiz_rounded,
    ParsedInstructionKind.memo => Icons.notes_rounded,
    ParsedInstructionKind.createTokenAccount ||
    ParsedInstructionKind.createAccount => Icons.add_circle_outline_rounded,
    ParsedInstructionKind.closeTokenAccount => Icons.recycling_rounded,
    _ => Icons.bolt_rounded,
  };

  (String, List<String>) _describe(AppLocalizations l10n) {
    final i = instruction;
    // "this account" only for the signer written in the transaction.
    String who(String? address, AccountField field) => address == null
        ? '?'
        : address == signerAddress && !i.fromTable.contains(field)
        ? l10n.signerThisAccount
        : address;
    final fromWallet = [if (i.addressFromTable) l10n.signerAddressFromWallet];
    switch (i.kind) {
      case ParsedInstructionKind.solTransfer:
        return (
          l10n.signerActionSendSol(formatBaseUnits(i.amount!, 9)),
          [l10n.signerActionTo(who(i.to, AccountField.to)), ...fromWallet],
        );
      case ParsedInstructionKind.tokenTransfer:
        final mint = i.mint;
        final resolved = mint == null ? null : tokens.resolve(mint);
        final decimals = i.decimals ?? resolved?.decimals;
        final amount = i.amount == null
            ? '?'
            : decimals == null
            ? i.amount.toString()
            : formatBaseUnits(i.amount!, decimals);
        final to = l10n.signerActionToTokenAccount(who(i.to, AccountField.to));
        if (resolved != null && resolved.isVerified) {
          final token = resolved.token!;
          return (
            l10n.signerActionSendToken(amount, token.symbol),
            [l10n.signerTokenVerified(token.name), to, ...fromWallet],
          );
        }
        if (resolved?.trust == TokenTrust.walletProvided) {
          final token = resolved!.token!;
          return (
            l10n.signerActionSendToken(
              amount,
              l10n.signerTokenUnchecked(token.symbol),
            ),
            [
              l10n.signerTokenWalletProvided(token.symbol),
              l10n.signerActionMint(mint!),
              to,
              ...fromWallet,
            ],
          );
        }
        return (
          l10n.signerActionSendUnverified(amount),
          [if (mint != null) l10n.signerActionMint(mint), to, ...fromWallet],
        );
      case ParsedInstructionKind.createTokenAccount:
        final token = i.mint == null ? null : tokens.resolve(i.mint!).token;
        final forOther =
            i.owner != null &&
            (i.owner != signerAddress ||
                i.fromTable.contains(AccountField.owner));
        final isAssociated = i.programId == SolanaPrograms.associatedToken;
        final name = recipient?.name ?? '';
        return (
          token == null
              ? l10n.signerActionCreateTokenAccount
              : forOther
              ? l10n.signerActionCreateTokenAccountForRecipient(token.symbol)
              : l10n.signerActionCreateTokenAccountFor(token.symbol),
          [
            if (isAssociated)
              i.idempotent
                  ? l10n.signerCreateAccountSkipIfOpen
                  : l10n.signerCreateAccountNotOpen,
            if (forOther)
              l10n.signerActionOwner(
                i.owner == recipient?.address && name.isNotEmpty
                    ? '${l10n.signerWalletNote(name)} · ${i.owner}'
                    : who(i.owner, AccountField.owner),
              ),
          ],
        );
      case ParsedInstructionKind.closeTokenAccount:
        return (
          l10n.signerActionCloseTokenAccount,
          [
            if (i.to != null)
              l10n.signerActionCloseTo(who(i.to, AccountField.to)),
            ...fromWallet,
          ],
        );
      case ParsedInstructionKind.memo:
        return (l10n.signerActionMemo, [i.text ?? '']);
      case ParsedInstructionKind.swap:
        return _describeSwap(l10n);
      case ParsedInstructionKind.tokenApprove:
        return (l10n.signerActionApprove, [l10n.signerActionDangerDetail]);
      case ParsedInstructionKind.setAuthority:
        return (l10n.signerActionSetAuthority, [l10n.signerActionDangerDetail]);
      case ParsedInstructionKind.assignAccount:
        return (l10n.signerActionAssign, [l10n.signerActionDangerDetail]);
      case ParsedInstructionKind.createAccount:
        final owner = i.newAccountOwner;
        final standard =
            owner == SolanaPrograms.system ||
            owner == SolanaPrograms.token ||
            owner == SolanaPrograms.token2022;
        return (
          l10n.signerActionCreateAccount,
          [
            if (i.amount != null) '${formatBaseUnits(i.amount!, 9)} SOL',
            if (i.to != null) l10n.signerActionTo(who(i.to, AccountField.to)),
            if (!standard) ...[
              l10n.signerActionOwnerProgram(owner ?? '?'),
              l10n.signerActionDangerDetail,
            ],
          ],
        );
      case ParsedInstructionKind.advanceNonce:
        return (l10n.signerActionAdvanceNonce, [l10n.signerDurableNonce]);
      case ParsedInstructionKind.syncNative:
        return (l10n.signerActionSyncNative, const []);
      case ParsedInstructionKind.computeUnitLimit:
      case ParsedInstructionKind.computeUnitPrice:
        return (l10n.signerReviewFee, const []);
      case ParsedInstructionKind.unknown:
        return (
          l10n.signerActionUnknown,
          [l10n.signerActionProgram(shortAddress(i.programId))],
        );
    }
  }

  (String, List<String>) _describeSwap(AppLocalizations l10n) {
    final swap = instruction.swap;
    final quote = summary;
    final quoteIn = quote == null ? null : base58encode(quote.inputMint);
    final quoteOut = quote == null ? null : base58encode(quote.outputMint);
    final output = swap?.outputMint ?? quoteOut;
    final input = swap?.inputMint ?? quoteIn ?? inputGuess;
    if (input == null && output == null) {
      return (l10n.signerActionSwap, [l10n.signerActionSwapDetail]);
    }

    String symbol(String? mint) {
      if (mint == null) {
        return '?';
      }
      final resolved = tokens.resolve(mint);
      return switch (resolved.trust) {
        TokenTrust.verified => resolved.token!.symbol,
        TokenTrust.walletProvided => l10n.signerTokenUnchecked(
          resolved.token!.symbol,
        ),
        TokenTrust.unverified => l10n.signerSwapUnverifiedToken,
      };
    }

    String amount(BigInt? raw, String? mint) {
      if (raw == null) {
        return symbol(mint);
      }
      final decimals = mint == null ? null : tokens.resolve(mint).decimals;
      final value = decimals == null
          ? raw.toString()
          : formatBaseUnits(raw, decimals);
      // The title already says when a name is unverified.
      final name = mint == null ? null : tokens.resolve(mint).token?.symbol;
      return '$value ${name ?? symbol(mint)}';
    }

    // The amounts the transaction itself fixes; the wallet's quote only
    // when the route could not be read.
    final decoded =
        swap != null && (swap.inputAmount != null || swap.outputAmount != null);
    return (
      l10n.signerActionSwapPair(symbol(input), symbol(output)),
      [
        if (decoded) ...[
          if (swap.inputAmount != null)
            swap.inputIsMaximum
                ? l10n.signerSwapPayAtMost(amount(swap.inputAmount, input))
                : l10n.signerSwapPay(amount(swap.inputAmount, input)),
          if (swap.outputAmount != null)
            swap.outputIsMinimum
                ? l10n.signerSwapReceiveAtLeast(
                    amount(swap.outputAmount, output),
                  )
                : l10n.signerSwapReceive(amount(swap.outputAmount, output)),
        ] else if (quote != null) ...[
          l10n.signerSwapWalletQuote(
            amount(quote.inputAmount, quoteIn),
            amount(quote.outputAmount, quoteOut),
          ),
          l10n.signerSwapFromWallet,
        ],
        for (final mint in {input, output}.nonNulls)
          tokenStatusLine(l10n, tokens, mint),
      ],
    );
  }
}

class SignerSignaturePage extends StatelessWidget {
  const SignerSignaturePage({
    super.key,
    required this.signature,
    this.deviceName = '',
  });

  final AirGapSignature signature;
  final String deviceName;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SignerScaffold(
      title: l10n.signerSignatureTitle,
      bottom: PrimaryButton(
        label: l10n.commonDone,
        onPressed: () => Navigator.of(context).pop(),
      ),
      children: [
        WalletCard(
          child: Center(child: AnimatedUrQr(ur: signature.toUr())),
        ),
        const SizedBox(height: 18),
        ScanHintAnimation(
          qrOnLeft: true,
          leftLabel: deviceName,
          rightLabel: l10n.signerWalletPhoneLabel,
          height: 96,
        ),
        const SizedBox(height: 10),
        Text(
          l10n.signerSignatureBody,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

/// True when [i] moves a token the signer cannot vouch for: unknown, or
/// named only by the wallet. [summary] is the wallet's swap quote.
bool hasUnverifiedToken(
  ParsedInstruction i,
  TokenRegistry tokens, {
  AirGapSwapSummary? summary,
}) {
  bool unknown(String? mint) =>
      mint != null && !tokens.resolve(mint).isVerified;
  final quoteUnknown =
      summary != null &&
      (unknown(base58encode(summary.inputMint)) ||
          unknown(base58encode(summary.outputMint)));
  switch (i.kind) {
    case ParsedInstructionKind.tokenTransfer:
      return i.mint == null || unknown(i.mint);
    case ParsedInstructionKind.swap:
      final swap = i.swap;
      return quoteUnknown ||
          (swap != null &&
              (unknown(swap.inputMint) || unknown(swap.outputMint)));
    default:
      return quoteUnknown;
  }
}

/// Some Jupiter routes do not name the input mint; take the known token
/// among the route's accounts that is not the output (SOL first).
String? swapInputGuess(ParsedInstruction i, TokenRegistry tokens) {
  final output = i.swap?.outputMint;
  final known = [
    for (final account in i.accounts)
      if (account != output && tokens.resolve(account).isVerified) account,
  ];
  if (known.contains(TokenRegistry.wrappedSolMint)) {
    return TokenRegistry.wrappedSolMint;
  }
  return known.firstOrNull;
}

/// This signer's associated token accounts among a transaction's static
/// keys (the ones its signature covers).
class SignerOwnAccounts {
  const SignerOwnAccounts([this.tokenAccountMints = const {}]);

  /// Static account → the mint it is this signer's token account for.
  final Map<String, String> tokenAccountMints;

  bool isOwnTokenAccount(String address) =>
      tokenAccountMints.containsKey(address);

  /// [account] is this signer's associated token account for [mint]. An
  /// associated token account address is derived from its mint, so it can
  /// only ever hold that mint.
  bool binds(String? account, String? mint) =>
      account != null && mint != null && tokenAccountMints[account] == mint;
}

/// Finds which of [tx]'s static keys are [signer]'s associated token
/// accounts (Token and Token-2022), for every mint the transaction names.
/// Runs before the review page opens: the address derivation is async.
Future<SignerOwnAccounts> findOwnAccounts(
  ParsedSolanaMessage? tx,
  String signer,
) async {
  if (tx == null) {
    return const SignerOwnAccounts();
  }
  final static = tx.staticAccountKeys.toSet();
  final owner = base58decode(signer);
  final ataProgram = Ed25519HDPublicKey.fromBase58(
    SolanaPrograms.associatedToken,
  );
  final found = <String, String>{};
  for (final mint in {...tx.accountKeys}) {
    for (final program in [SolanaPrograms.token, SolanaPrograms.token2022]) {
      try {
        final account = await Ed25519HDPublicKey.findProgramAddress(
          seeds: [owner, base58decode(program), base58decode(mint)],
          programId: ataProgram,
        );
        final address = account.toBase58();
        if (static.contains(address)) {
          found[address] = mint;
        }
      } on Object {
        // Not a valid seed; cannot be a mint.
      }
    }
  }
  return SignerOwnAccounts(found);
}

/// Mints whose address in [tx] is only the wallet's word: read from a
/// lookup table (or guessed for a route that does not name it) and not
/// tied to [signer]'s own token account of that mint.
Set<String> uncheckedMints(
  ParsedSolanaMessage? tx,
  String signer,
  SignerOwnAccounts own,
  TokenRegistry tokens,
) {
  final out = <String>{};
  for (final i in tx?.instructions ?? const <ParsedInstruction>[]) {
    // A mint from a table is tied down only by the signer's own token
    // account of that mint, written in the transaction (e.g. opening it).
    final mint = i.mint;
    if (mint != null &&
        i.fromTable.contains(AccountField.mint) &&
        !(!i.fromTable.contains(AccountField.to) && own.binds(i.to, mint)) &&
        !(!i.fromTable.contains(AccountField.from) &&
            own.binds(i.from, mint))) {
      out.add(mint);
    }
    final swap = i.swap;
    if (i.kind != ParsedInstructionKind.swap || swap == null) {
      continue;
    }
    bool bound(String? account, String mint, AccountField accountField) =>
        !i.fromTable.contains(accountField) && own.binds(account, mint);
    void side(
      String? mint,
      String? account,
      AccountField mintField,
      AccountField accountField,
    ) {
      if (mint == null) {
        return;
      }
      final written =
          !i.fromTable.contains(mintField) &&
          !i.fromTable.contains(accountField);
      if (!written && !bound(account, mint, accountField)) {
        out.add(mint);
      }
    }

    side(
      swap.inputMint,
      swap.inputAccount,
      AccountField.swapInputMint,
      AccountField.swapInputAccount,
    );
    if (!swap.outputIsNative) {
      side(
        swap.outputMint,
        swap.outputAccount,
        AccountField.swapOutputMint,
        AccountField.swapOutputAccount,
      );
    }
    // A guessed input counts only if it is the token of the account paid
    // from.
    final guess = swap.inputMint == null ? swapInputGuess(i, tokens) : null;
    if (guess != null &&
        !bound(swap.inputAccount, guess, AccountField.swapInputAccount)) {
      out.add(guess);
    }
  }
  return out;
}

/// The swap [i] pays its output to [signer]: into the signer's own token
/// account of the output mint, or as native SOL to the signer itself, by
/// an account written in the transaction (not read from a table).
bool swapPaysSigner(ParsedInstruction i, String signer, SignerOwnAccounts own) {
  final swap = i.swap;
  if (swap == null || i.fromTable.contains(AccountField.swapOutputAccount)) {
    return false;
  }
  if (swap.outputIsNative) {
    return swap.outputAccount == signer;
  }
  return own.binds(swap.outputAccount, swap.outputMint);
}

/// "BYC (Benny Coin) · Verified by Benny Wallet", or why it is not.
String tokenStatusLine(
  AppLocalizations l10n,
  TokenRegistry tokens,
  String mint,
) {
  final resolved = tokens.resolve(mint);
  final token = resolved.token;
  return switch (resolved.trust) {
    TokenTrust.verified => l10n.signerTokenVerified(
      token!.name.isEmpty || token.name == token.symbol
          ? token.symbol
          : '${token.symbol} (${token.name})',
    ),
    TokenTrust.walletProvided =>
      '${l10n.signerTokenWalletProvided(token!.symbol)}\n'
          '${l10n.signerActionMint(mint)}',
    TokenTrust.unverified =>
      '${l10n.signerTokenNotVerified}\n${l10n.signerActionMint(mint)}',
  };
}

enum TxTrust {
  safe,
  caution,
  danger;

  Color get color => switch (this) {
    TxTrust.safe => CountdownBorder.colorFor(1),
    TxTrust.caution => CountdownBorder.colorFor(0.5),
    TxTrust.danger => CountdownBorder.colorFor(0),
  };
}

enum TxKind { swap, send }

/// What a transaction mainly does, in one line: a swap of one token for
/// another, or a send. Amounts come from the transaction when the signer
/// can read them, else from the wallet's quote ([fromWallet]).
class TxHeadline {
  const TxHeadline({
    required this.kind,
    this.payMint,
    this.payAmount,
    this.payDecimals,
    this.payIsMaximum = false,
    this.getMint,
    this.getAmount,
    this.getIsMinimum = false,
    this.fromWallet = false,
    this.addressFromWallet = false,
    this.to,
    this.step,
    this.sendIndex,
  });

  /// The instruction this headline describes; not listed again below it.
  final int? step;

  final TxKind kind;
  final String? payMint;
  final BigInt? payAmount;
  final int? payDecimals;
  final bool payIsMaximum;
  final String? getMint;
  final BigInt? getAmount;
  final bool getIsMinimum;

  /// An amount or a token comes from the wallet's quote, not the
  /// transaction.
  final bool fromWallet;

  /// A send whose destination, token or owner was read from a lookup
  /// table: the signer cannot check it.
  final bool addressFromWallet;

  /// The instruction a send headline describes, even when several sends
  /// keep it listed.
  final int? sendIndex;

  /// Who a send goes to.
  final String? to;

  static TxHeadline? of(
    SignerReview review,
    TokenRegistry tokens, {
    AirGapSwapSummary? summary,
    int? swapStep,
  }) {
    final instructions = review.transaction?.instructions;
    if (instructions == null) {
      return null;
    }
    final quoteIn = summary == null ? null : base58encode(summary.inputMint);
    final quoteOut = summary == null ? null : base58encode(summary.outputMint);
    final swapIndex = instructions.indexWhere(
      (i) => i.kind == ParsedInstructionKind.swap && i.swap != null,
    );
    if (swapIndex >= 0) {
      final i = instructions[swapIndex];
      final swap = i.swap!;
      final readAmounts = swap.inputAmount != null || swap.outputAmount != null;
      final mintFromQuote =
          (swap.inputMint == null && quoteIn != null) ||
          (swap.outputMint == null && quoteOut != null);
      return TxHeadline(
        kind: TxKind.swap,
        payMint: swap.inputMint ?? quoteIn ?? swapInputGuess(i, tokens),
        payAmount: readAmounts ? swap.inputAmount : summary?.inputAmount,
        payIsMaximum: readAmounts && swap.inputIsMaximum,
        getMint: swap.outputMint ?? quoteOut,
        getAmount: readAmounts ? swap.outputAmount : summary?.outputAmount,
        getIsMinimum: readAmounts && swap.outputIsMinimum,
        fromWallet: (!readAmounts && summary != null) || mintFromQuote,
        step: swapIndex,
      );
    }
    if (summary != null && swapStep != null) {
      return TxHeadline(
        kind: TxKind.swap,
        payMint: quoteIn,
        payAmount: summary.inputAmount,
        getMint: quoteOut,
        getAmount: summary.outputAmount,
        fromWallet: true,
        step: swapStep,
      );
    }
    final sends = [
      for (final (index, i) in instructions.indexed)
        if (i.kind == ParsedInstructionKind.solTransfer ||
            i.kind == ParsedInstructionKind.tokenTransfer)
          (index, i),
    ];
    if (sends.isEmpty) {
      return null;
    }
    final (sendIndex, send) = sends.first;
    final isSol = send.kind == ParsedInstructionKind.solTransfer;
    return TxHeadline(
      kind: TxKind.send,
      payMint: isSol ? TokenRegistry.wrappedSolMint : send.mint,
      payAmount: send.amount,
      payDecimals: isSol ? 9 : send.decimals,
      to: send.to,
      addressFromWallet: send.addressFromTable,
      // Several sends stay listed, so none is hidden behind the first.
      step: sends.length == 1 ? sendIndex : null,
      sendIndex: sendIndex,
    );
  }

  /// The colour the screen calls for: [tokenTrust], at most yellow when
  /// the wallet supplied amounts or tokens, red for a send to an address
  /// the signer cannot check.
  TxTrust trust(TokenRegistry tokens) {
    final trust = tokenTrust(tokens);
    if (addressFromWallet) {
      return TxTrust.danger;
    }
    if (fromWallet && trust == TxTrust.safe) {
      return TxTrust.caution;
    }
    return trust;
  }

  /// The colour the tokens alone call for.
  TxTrust tokenTrust(TokenRegistry tokens) {
    bool verified(String? mint) =>
        mint != null && tokens.resolve(mint).isVerified;
    switch (kind) {
      case TxKind.send:
        return verified(payMint) ? TxTrust.safe : TxTrust.danger;
      case TxKind.swap:
        final pay = verified(payMint);
        final get = verified(getMint);
        return pay && get
            ? TxTrust.safe
            : pay || get
            ? TxTrust.caution
            : TxTrust.danger;
    }
  }
}

class _HeadlineCard extends StatelessWidget {
  const _HeadlineCard({
    required this.headline,
    required this.tokens,
    required this.trust,
    required this.signerAddress,
    required this.usdPrices,
    this.verdict,
    this.recipient,
  });

  final TxHeadline headline;
  final TokenRegistry tokens;
  final TxTrust trust;

  /// Why the screen is not green, when the tokens are not the reason.
  final String? verdict;
  final String signerAddress;

  /// The wallet's USD price per whole token, by mint.
  final Map<String, double> usdPrices;

  /// The send's recipient, if the wallet named it and the transaction pays it.
  final SignerRecipient? recipient;

  int? _decimals(String? mint, int? given) =>
      given ?? (mint == null ? null : tokens.resolve(mint).decimals);

  String? _usd(BigInt? raw, String? mint, int? decimals) {
    final price = mint == null ? null : usdPrices[mint];
    if (raw == null || price == null || decimals == null) {
      return null;
    }
    return '≈ ${Formatters.usdPrice(raw.toDouble() / pow(10, decimals) * price)}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final h = headline;
    final payDecimals = _decimals(h.payMint, h.payDecimals);
    final getDecimals = _decimals(h.getMint, null);
    final payUsd = _usd(h.payAmount, h.payMint, payDecimals);
    final getUsd = _usd(h.getAmount, h.getMint, getDecimals);
    final small = theme.textTheme.bodySmall;
    final verdict =
        this.verdict ??
        switch ((h.kind, trust)) {
          (_, TxTrust.safe) => l10n.signerTrustSafe,
          (TxKind.swap, TxTrust.caution) => l10n.signerTrustCaution,
          (TxKind.swap, TxTrust.danger) => l10n.signerTrustDangerSwap,
          (TxKind.send, _) => l10n.signerTrustDangerSend,
        };
    return SignerSection(
      label: h.kind == TxKind.swap ? l10n.signerKindSwap : l10n.signerKindSend,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: trust.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(
                  trust == TxTrust.safe
                      ? Icons.verified_rounded
                      : Icons.warning_amber_rounded,
                  color: trust.color,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    verdict,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (h.kind == TxKind.swap) ...[
            Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  children: [
                    _AmountPanel(
                      label: h.payIsMaximum
                          ? l10n.signerPayAtMost
                          : l10n.signerPay,
                      token: h.payMint == null
                          ? null
                          : tokens.resolve(h.payMint!),
                      amount: h.payAmount,
                      decimals: payDecimals,
                      usd: payUsd,
                    ),
                    const SizedBox(height: 6),
                    _AmountPanel(
                      label: h.getIsMinimum
                          ? l10n.signerGetAtLeast
                          : h.fromWallet
                          ? l10n.signerGetAbout
                          : l10n.signerGet,
                      token: h.getMint == null
                          ? null
                          : tokens.resolve(h.getMint!),
                      amount: h.getAmount,
                      decimals: getDecimals,
                      usd: getUsd,
                    ),
                  ],
                ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 4),
                    boxShadow: const [
                      BoxShadow(color: AppColors.shadow, blurRadius: 8),
                    ],
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: trust.color.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_downward_rounded,
                      size: 22,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            if (h.fromWallet && this.verdict != l10n.signerSwapFromWallet) ...[
              const SizedBox(height: 6),
              Text(l10n.signerSwapFromWallet, style: small),
            ],
          ] else ...[
            _AmountPanel(
              token: h.payMint == null ? null : tokens.resolve(h.payMint!),
              amount: h.payAmount,
              decimals: payDecimals,
              usd: payUsd,
            ),
            const SizedBox(height: 14),
            _RecipientBox(
              address: recipient?.address ?? h.to,
              name: recipient?.name ?? '',
              isTokenAccount:
                  recipient == null &&
                  h.payMint != TokenRegistry.wrappedSolMint,
              signerAddress: signerAddress,
              fromWallet: h.addressFromWallet,
            ),
          ],
          const SizedBox(height: 10),
          for (final mint in {h.payMint, h.getMint}.nonNulls)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(tokenStatusLine(l10n, tokens, mint), style: small),
            ),
          if (payUsd != null || getUsd != null)
            Text(l10n.signerUsdFromWallet, style: small),
        ],
      ),
    );
  }
}

/// A login request in plain words: what it is for and that it moves
/// nothing, with the original text folded away.
class _SignInCard extends StatefulWidget {
  const _SignInCard({required this.verdict, required this.rawText});

  final _Warning verdict;
  final String rawText;

  @override
  State<_SignInCard> createState() => _SignInCardState();
}

class _SignInCardState extends State<_SignInCard> {
  bool _showText = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final verdict = widget.verdict;
    final color = verdict.level.color;
    return SignerSection(
      label: l10n.signerKindSignIn,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(verdict.icon, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    verdict.text,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          for (final (icon, text) in [
            (Icons.how_to_reg_rounded, l10n.signerSignInWhat),
            (Icons.money_off_rounded, l10n.signerSignInNoFunds),
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 20, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(text, style: theme.textTheme.bodyMedium),
                  ),
                ],
              ),
            ),
          TextButton.icon(
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            onPressed: () => setState(() => _showText = !_showText),
            icon: Icon(
              _showText ? Icons.expand_less_rounded : Icons.expand_more_rounded,
            ),
            label: Text(l10n.signerSignInShowText),
          ),
          if (_showText)
            SelectableText(
              widget.rawText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}

/// A label on the left and its value on the right, on one line.
class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.warn = false,
  });

  final String label;
  final String value;
  final bool warn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: warn ? theme.colorScheme.error : AppColors.textPrimary,
                fontWeight: warn ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The sign button, pinned to the bottom so it is always in reach, with
/// reject beside it and any hold hint or error right above.
class _SignBar extends StatelessWidget {
  const _SignBar({
    required this.hint,
    required this.error,
    required this.danger,
    required this.signing,
    required this.onSign,
    required this.onReject,
  });

  final String? hint;
  final String? error;
  final bool danger;
  final bool signing;
  final VoidCallback onSign;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final message = error ?? hint;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (message != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: error != null || danger
                      ? theme.colorScheme.error
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          Row(
            children: [
              SizedBox(
                height: 56,
                child: OutlinedButton(
                  onPressed: signing ? null : onReject,
                  style: OutlinedButton.styleFrom(
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                  ),
                  child: Text(l10n.signerReject),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: HoldToConfirmButton(
                  label: l10n.signerHoldToSign,
                  danger: danger,
                  holdDuration: Duration(seconds: danger ? 3 : 1),
                  onConfirmed: signing ? null : onSign,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A token's icon with a small plus: a new account for that token.
class _NewAccountIcon extends StatelessWidget {
  const _NewAccountIcon({required this.token});

  final ResolvedToken token;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SignerTokenIcon(token: token, size: 34),
          Positioned(
            right: -3,
            bottom: -3,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 2),
              ),
              child: const Icon(
                Icons.add_rounded,
                size: 12,
                color: AppColors.surface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One side of a send or swap: the token on the left, the amount and its
/// USD value on the right.
class _AmountPanel extends StatelessWidget {
  const _AmountPanel({
    required this.token,
    required this.amount,
    required this.decimals,
    this.label,
    this.usd,
  });

  final String? label;
  final ResolvedToken? token;
  final BigInt? amount;
  final int? decimals;
  final String? usd;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final token = this.token;
    final named = token?.token;
    // A name only the wallet vouches for always carries the marker.
    final symbol = named == null
        ? l10n.signerSwapUnverifiedToken
        : token!.isVerified
        ? named.symbol
        : l10n.signerTokenUnchecked(named.symbol);
    final amount = this.amount;
    final value = amount == null
        ? '?'
        : decimals == null
        ? amount.toString()
        : formatBaseUnits(amount, decimals!);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Text(
              label!,
              style: theme.textTheme.titleSmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(5, 5, 14, 5),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: const [
                    BoxShadow(color: AppColors.shadow, blurRadius: 6),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (token != null)
                      SignerTokenIcon(token: token, size: 30)
                    else
                      const SizedBox(width: 30, height: 30),
                    const SizedBox(width: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 130),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 260),
                          child: Text(
                            symbol,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        value,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (usd != null)
                      Text(
                        usd!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Who a send goes to: the full address, tagged "this account" for the
/// signer itself, or with the wallet's note for it (clearly marked as the
/// wallet's).
class _RecipientBox extends StatelessWidget {
  const _RecipientBox({
    required this.address,
    required this.name,
    required this.isTokenAccount,
    required this.signerAddress,
    this.fromWallet = false,
  });

  final String? address;
  final String name;

  /// Only the recipient's token account is known, not their wallet.
  final bool isTokenAccount;
  final String signerAddress;

  /// The address was read from a lookup table: the wallet's word only.
  final bool fromWallet;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isSigner = address == signerAddress && !fromWallet;
    final label = theme.textTheme.labelLarge;
    Widget tag(Widget child, {required bool own}) => Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: own
              ? AppColors.tertiary.withValues(alpha: 0.55)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(own ? 999 : 8),
          border: own ? null : Border.all(color: AppColors.textSecondary),
        ),
        child: child,
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              isTokenAccount
                  ? l10n.signerRecipientTokenAccount
                  : l10n.signerRecipient,
              style: theme.textTheme.titleSmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            if (isSigner)
              tag(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_user_rounded,
                      size: 14,
                      color: AppColors.tertiaryStrong,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        l10n.signerThisAccount,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: label?.copyWith(
                          color: AppColors.tertiaryStrong,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                own: true,
              )
            else if (name.isNotEmpty)
              tag(
                Text(
                  l10n.signerWalletNote(name),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: label?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                own: false,
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: fromWallet
                  ? theme.colorScheme.error
                  : AppColors.surfaceContainer,
            ),
          ),
          child: SelectableText(
            address ?? '?',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
        ),
        if (fromWallet) ...[
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.gpp_maybe_rounded,
                size: 18,
                color: theme.colorScheme.error,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l10n.signerAddressFromWallet,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// A send's recipient: the wallet's account the transaction really pays.
class SignerRecipient {
  const SignerRecipient({required this.address, this.name = ''});

  final String address;
  final String name;
}

/// The recipient the wallet named, if the transaction's first send really
/// pays it (directly for SOL, through its token account for tokens), by
/// addresses written in the transaction itself.
Future<SignerRecipient?> verifiedRecipient(
  AirGapSignRequest request,
  ParsedSolanaMessage? tx,
) async {
  final named = request.recipient;
  if (named == null || tx == null) {
    return null;
  }
  final send = tx.instructions
      .where(
        (i) =>
            i.kind == ParsedInstructionKind.solTransfer ||
            i.kind == ParsedInstructionKind.tokenTransfer,
      )
      .firstOrNull;
  final to = send?.to;
  // A destination, token or owner read from a lookup table is only the
  // wallet's word, so it cannot confirm whom the send pays.
  if (send == null || to == null || send.addressFromTable) {
    return null;
  }
  final owner = base58encode(named.address);
  final recipient = SignerRecipient(address: owner, name: named.name);
  if (send.kind == ParsedInstructionKind.solTransfer) {
    return to == owner ? recipient : null;
  }
  final mint = send.mint;
  if (mint == null) {
    return null;
  }
  try {
    final account = await Ed25519HDPublicKey.findProgramAddress(
      seeds: [named.address, base58decode(send.programId), base58decode(mint)],
      programId: Ed25519HDPublicKey.fromBase58(SolanaPrograms.associatedToken),
    );
    return account.toBase58() == to ? recipient : null;
  } on Object {
    return null;
  }
}
