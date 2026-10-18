import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/l10n.dart';
import '../../data/offline_status.dart';

/// Live checklist of the radios that must be off. Reports [onReadyChanged]
/// true once every required check passes (detected, or ticked by hand where
/// the platform cannot detect it).
class OfflineChecklist extends StatefulWidget {
  const OfflineChecklist({
    super.key,
    required this.service,
    required this.onReadyChanged,
  });

  final OfflineStatusService service;
  final ValueChanged<bool> onReadyChanged;

  @override
  State<OfflineChecklist> createState() => _OfflineChecklistState();
}

class _OfflineChecklistState extends State<OfflineChecklist>
    with WidgetsBindingObserver {
  OfflineStatus? _status;
  final Set<OfflineCheck> _confirmedByHand = {};
  Timer? _timer;
  bool? _lastReady;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_refresh());
    _timer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => unawaited(_refresh()),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_refresh());
    }
  }

  Future<void> _refresh() async {
    final status = await widget.service.read();
    if (!mounted) {
      return;
    }
    setState(() => _status = status);
    _report();
  }

  bool get _ready {
    final status = _status;
    if (status == null || !status.isOffline) {
      return false;
    }
    return OfflineCheck.values
        .where(
          (check) =>
              !status.detected.contains(check) &&
              !status.recommendedOnly.contains(check),
        )
        .every(_confirmedByHand.contains);
  }

  void _report() {
    final ready = _ready;
    if (ready != _lastReady) {
      _lastReady = ready;
      widget.onReadyChanged(ready);
    }
  }

  String _label(BuildContext context, OfflineCheck check) {
    final l10n = context.l10n;
    return switch (check) {
      OfflineCheck.airplaneMode => l10n.signerCheckAirplane,
      OfflineCheck.wifiOff => l10n.signerCheckWifi,
      OfflineCheck.bluetoothOff => l10n.signerCheckBluetooth,
      OfflineCheck.nfcOff => l10n.signerCheckNfc,
      OfflineCheck.noNetwork => l10n.signerCheckNoNetwork,
      OfflineCheck.usbDebuggingOff => l10n.signerCheckUsbDebugging,
      OfflineCheck.simRemoved => l10n.signerCheckSim,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = _status;
    if (status == null) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final check in OfflineCheck.values)
          if (status.detected.contains(check))
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                status.isPassed(check)
                    ? Icons.check_circle_rounded
                    : status.recommendedOnly.contains(check)
                    ? Icons.info_outline_rounded
                    : Icons.cancel_rounded,
                color: status.isPassed(check)
                    ? AppColors.success
                    : status.recommendedOnly.contains(check)
                    ? theme.colorScheme.outline
                    : theme.colorScheme.error,
              ),
              title: Text(_label(context, check)),
            )
          else
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: _confirmedByHand.contains(check),
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _confirmedByHand.add(check);
                  } else {
                    _confirmedByHand.remove(check);
                  }
                });
                _report();
              },
              title: Text(_label(context, check)),
              subtitle: Text(context.l10n.signerCheckManualHint),
            ),
        const SizedBox(height: 8),
        if (status.detected.length > 1)
          OutlinedButton.icon(
            onPressed: widget.service.openAirplaneSettings,
            icon: const Icon(Icons.airplanemode_active_rounded),
            label: Text(context.l10n.signerOpenSettings),
          ),
      ],
    );
  }
}
