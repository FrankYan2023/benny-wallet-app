import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../app/theme/app_colors.dart';

import '../../../../core/airgap/airgap_protocol.dart';
import '../../../../core/airgap/ur.dart';
import '../../../../core/airgap/widgets/animated_ur_qr.dart';
import '../../../../core/airgap/widgets/scan_hint_animation.dart';
import '../../../../core/airgap/widgets/ur_scanner_view.dart';
import '../../../../l10n/l10n.dart';
import '../../../signer/presentation/widgets/signer_ui.dart';
import '../../domain/air_gap_wallet_meta.dart';
import '../widgets/countdown_border.dart';

/// What the sign page returns: the signature and the request it signs
/// (which differs from the first one if the code was refreshed).
typedef AirGapSignResult = ({
  AirGapSignature signature,
  AirGapSignRequest request,
});

/// Two steps: show the request for the signer to scan, then scan the
/// signature it shows. The code sits at the top, the who-scans-whom
/// animation under it, and the next-step button is pinned to the bottom. A transaction gets 90 seconds, shown as a shrinking
/// line around the screen; when it runs out, [refresh] supplies a fresh
/// request and the user starts again from step 1. Pops with the result, or
/// null if the user gives up.
class AirGapSignPage extends StatefulWidget {
  const AirGapSignPage({
    super.key,
    required this.request,
    required this.meta,
    this.startedAt,
    this.refresh,
    this.signIn = false,
  });

  final AirGapSignRequest request;
  final AirGapWalletMeta meta;

  /// When the transaction was built; the timer counts from here.
  final DateTime? startedAt;
  final Future<AirGapSignRequest> Function()? refresh;

  /// The request is Benny's login message; the page explains why it is
  /// needed before the user scans it.
  final bool signIn;

  /// How long a transaction is treated as valid.
  static const transactionWindow = Duration(seconds: 90);

  @override
  State<AirGapSignPage> createState() => _AirGapSignPageState();
}

class _AirGapSignPageState extends State<AirGapSignPage>
    with SingleTickerProviderStateMixin {
  late AirGapSignRequest _request = widget.request;
  late Ur _requestUr = _request.toUr();
  late DateTime _startedAt = widget.startedAt ?? DateTime.now();
  late final Ticker _ticker = createTicker((_) => _tick());
  bool _scanning = false;
  bool _refreshing = false;
  bool _refreshed = false;
  bool _refreshFailed = false;
  String? _error;
  int _scannerKey = 0;
  double _remaining = 1;
  bool _signerOutdated = false;

  bool get _isTransaction =>
      widget.request.signType == AirGapSignType.transaction;

  int get _secondsLeft =>
      (_remaining * AirGapSignPage.transactionWindow.inSeconds).ceil();

  @override
  void initState() {
    super.initState();
    if (_isTransaction) {
      _ticker.start();
    }
    unawaited(_checkSignerVersion());
  }

  void _tick() {
    final elapsed = DateTime.now().difference(_startedAt);
    final remaining =
        1 -
        elapsed.inMilliseconds /
            AirGapSignPage.transactionWindow.inMilliseconds;
    setState(() => _remaining = remaining.clamp(0.0, 1.0));
    if (remaining <= 0 && !_refreshing && !_refreshFailed) {
      unawaited(_refresh());
    }
  }

  Future<void> _refresh() async {
    final refresh = widget.refresh;
    if (refresh == null) {
      return;
    }
    setState(() {
      _refreshing = true;
      _refreshFailed = false;
    });
    final startedAt = DateTime.now();
    try {
      final request = await refresh();
      if (!mounted) {
        return;
      }
      setState(() {
        _request = request;
        _requestUr = request.toUr();
        _startedAt = startedAt;
        _remaining = 1;
        _scanning = false;
        _error = null;
        _refreshed = true;
        _refreshing = false;
        _scannerKey++;
      });
    } on Object {
      if (mounted) {
        setState(() {
          _refreshing = false;
          _refreshFailed = true;
        });
      }
    }
  }

  Future<void> _checkSignerVersion() async {
    final info = widget.meta.signerInfo;
    var outdated = info.protocolVersion < airGapProtocolVersion;
    if (!outdated && info.appVersion.isNotEmpty) {
      try {
        final ours = (await PackageInfo.fromPlatform()).version;
        outdated = isOlderVersion(info.appVersion, ours);
      } on Object {
        // Version unknown; no hint.
      }
    }
    if (outdated && mounted) {
      setState(() => _signerOutdated = true);
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onSignature(Ur ur) {
    final l10n = context.l10n;
    try {
      final signature = AirGapSignature.fromUr(ur);
      if (!sameBytes(signature.requestId, _request.requestId)) {
        setState(
          () => _error = _refreshed
              ? l10n.airGapSignOldRequest
              : l10n.airGapSignWrongRequest,
        );
        return;
      }
      Navigator.of(
        context,
      ).pop<AirGapSignResult>((signature: signature, request: _request));
    } on Object {
      setState(() => _error = l10n.airGapSignInvalidCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final device = widget.meta.deviceName.trim().isEmpty
        ? l10n.airGapSignerLabel
        : widget.meta.deviceName.trim();
    final step = _scanning ? 2 : 1;
    final page = Scaffold(
      backgroundColor: _isTransaction ? Colors.transparent : null,
      appBar: AppBar(
        backgroundColor: _isTransaction ? Colors.transparent : null,
        title: Text(
          widget.signIn ? l10n.airGapSignInTitle : l10n.airGapSignTitle,
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                children: [
                  if (_refreshing || _refreshFailed || _refreshed) ...[
                    _refreshFailed
                        ? SignerNotice(
                            text: l10n.airGapSignRefreshFailed,
                            icon: Icons.error_outline_rounded,
                            tone: SignerTone.danger,
                          )
                        : SignerNotice(
                            text: _refreshing
                                ? l10n.airGapSignRefreshing
                                : l10n.airGapSignRefreshed(device),
                            icon: Icons.autorenew_rounded,
                            tone: SignerTone.warm,
                          ),
                    if (_refreshFailed)
                      TextButton(
                        onPressed: () => unawaited(_refresh()),
                        child: Text(l10n.commonRetry),
                      ),
                    const SizedBox(height: 12),
                  ],
                  if (_signerOutdated) ...[
                    SignerNotice(
                      text: l10n.airGapSignerOutdated,
                      icon: Icons.system_update_rounded,
                      tone: SignerTone.info,
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (widget.signIn && !_scanning) ...[
                    _SignInExplainer(
                      // Older signers (and Keystone) show the message as
                      // plain English text.
                      signerShowsLogin: widget.meta.supports(
                        AirGapCapability.signIn,
                      ),
                      device: device,
                    ),
                    const SizedBox(height: 14),
                  ],
                  _StepPills(
                    current: step,
                    labels: [
                      l10n.airGapSignStepShort1,
                      l10n.airGapSignStepShort2,
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _scanning
                        ? l10n.airGapSignStep2Named(device)
                        : l10n.airGapSignStep1Named(device),
                    style: theme.textTheme.titleMedium,
                  ),
                  if (_isTransaction) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 16,
                          color: CountdownBorder.colorFor(_remaining),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _secondsLeft > 0
                                ? l10n.airGapSignTimeLeft(_secondsLeft)
                                : widget.refresh == null
                                ? l10n.airGapSignMayHaveExpired
                                : l10n.airGapSignRefreshing,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: _secondsLeft > 20
                                  ? AppColors.textSecondary
                                  : AppColors.danger,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 14),
                  if (!_scanning)
                    if (_refreshing ||
                        (_remaining <= 0 && widget.refresh != null))
                      const SizedBox(
                        height: 280,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else
                      Center(
                        child: AnimatedUrQr(
                          key: ObjectKey(_requestUr),
                          ur: _requestUr,
                        ),
                      )
                  else ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: UrScannerView(
                        key: ValueKey(_scannerKey),
                        acceptedTypes: const {AirGapUrType.signature},
                        onResult: _onSignature,
                        onWrongCode: () =>
                            setState(() => _error = l10n.airGapSignInvalidCode),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      SignerNotice(
                        text: _error!,
                        icon: Icons.error_outline_rounded,
                        tone: SignerTone.danger,
                      ),
                      TextButton(
                        onPressed: () => setState(() {
                          _error = null;
                          _scannerKey++;
                        }),
                        child: Text(l10n.commonRetry),
                      ),
                    ],
                  ],
                  const SizedBox(height: 18),
                  // Below the code: who scans whom. This phone on the left,
                  // the signer on the right; the code travels toward
                  // whoever scans.
                  ScanHintAnimation(
                    qrOnLeft: !_scanning,
                    leftLabel: l10n.airGapThisPhone,
                    rightLabel: device,
                    height: 96,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _scanning
                        ? l10n.airGapSignStep2BodyNamed(device)
                        : l10n.airGapSignStep1BodyNamed(device),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            // The next step always stays on screen.
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: _scanning
                  ? TextButton(
                      onPressed: () => setState(() {
                        _scanning = false;
                        _error = null;
                      }),
                      child: Text(l10n.airGapSignShowRequestAgain),
                    )
                  : PrimaryButton(
                      label: l10n.airGapSignScanSignatureNamed(device),
                      onPressed: () => setState(() => _scanning = true),
                    ),
            ),
          ],
        ),
      ),
    );
    if (!_isTransaction) {
      return page;
    }
    return CountdownBorder(remaining: _remaining, child: page);
  }
}

/// Why a login needs the signer: a short reason, what it does not do, and
/// what the signer will show.
class _SignInExplainer extends StatelessWidget {
  const _SignInExplainer({
    required this.signerShowsLogin,
    required this.device,
  });

  final bool signerShowsLogin;
  final String device;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return WalletCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.login_rounded, color: AppColors.primaryStrong),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.airGapSignInWhy,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(l10n.airGapSignInWhyBody, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 10),
          SignerNotice(
            text: l10n.airGapSignInSafe,
            icon: Icons.shield_rounded,
            tone: SignerTone.success,
          ),
          const SizedBox(height: 8),
          SignerNotice(
            text: signerShowsLogin
                ? l10n.airGapSignInSignerShows(device)
                : l10n.airGapSignInSignerShowsText(device),
            icon: Icons.visibility_rounded,
            tone: SignerTone.info,
          ),
        ],
      ),
    );
  }
}

class _StepPills extends StatelessWidget {
  const _StepPills({required this.current, required this.labels});

  final int current;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: i + 1 == current
                    ? AppColors.primaryBright
                    : i + 1 < current
                    ? const Color(0xFFD9F2E3)
                    : AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 11,
                    backgroundColor: Colors.white.withValues(alpha: 0.75),
                    child: i + 1 < current
                        ? const Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: AppColors.success,
                          )
                        : Text(
                            (i + 1).toString(),
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      labels[i],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: i + 1 == current
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
