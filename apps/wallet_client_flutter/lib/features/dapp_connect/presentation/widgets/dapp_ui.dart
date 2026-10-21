import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:reown_walletkit/reown_walletkit.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/walletconnect/dapp_review.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../l10n/l10n.dart';
import '../../../airgap/presentation/widgets/countdown_border.dart';

extension DappTrustColor on DappTrust {
  /// The signer's green / yellow / red, so both review pages read alike.
  Color get color => switch (this) {
    DappTrust.safe => CountdownBorder.colorFor(1),
    DappTrust.caution => CountdownBorder.colorFor(0.5),
    DappTrust.danger || DappTrust.blocked => CountdownBorder.colorFor(0),
  };

  String label(AppLocalizations l10n) => switch (this) {
    DappTrust.safe => l10n.dappTrustSafe,
    DappTrust.caution => l10n.dappTrustCaution,
    DappTrust.danger => l10n.dappTrustDanger,
    DappTrust.blocked => l10n.dappTrustBlocked,
  };

  IconData get icon => switch (this) {
    DappTrust.safe => Icons.verified_user_rounded,
    DappTrust.caution => Icons.info_rounded,
    DappTrust.danger => Icons.warning_rounded,
    DappTrust.blocked => Icons.block_rounded,
  };
}

String dappWarningText(AppLocalizations l10n, DappWarningKind kind) =>
    switch (kind) {
      DappWarningKind.siteScam => l10n.dappWarnSiteScam,
      DappWarningKind.siteMismatch => l10n.dappWarnSiteMismatch,
      DappWarningKind.siteUnknown => l10n.dappWarnSiteUnknown,
      DappWarningKind.messageUnreadable => l10n.dappWarnMessageUnreadable,
      DappWarningKind.messageIsTransaction => l10n.dappWarnMessageIsTransaction,
      DappWarningKind.signInOtherSite => l10n.dappWarnSignInOtherSite,
      DappWarningKind.signInOtherAccount => l10n.dappWarnSignInOtherAccount,
      DappWarningKind.signInExpired => l10n.dappWarnSignInExpired,
      DappWarningKind.tokenApprove => l10n.dappWarnTokenApprove,
      DappWarningKind.setAuthority => l10n.dappWarnSetAuthority,
      DappWarningKind.assignAccount => l10n.dappWarnAssignAccount,
      DappWarningKind.closeAccount => l10n.dappWarnCloseAccount,
      DappWarningKind.advanceNonce => l10n.dappWarnAdvanceNonce,
      DappWarningKind.unknownProgram => l10n.dappWarnUnknownProgram,
      DappWarningKind.blockedProgram => l10n.dappWarnBlockedProgram,
      DappWarningKind.unresolvedAccounts => l10n.dappWarnUnresolvedAccounts,
      DappWarningKind.simulationFailed => l10n.dappWarnSimulationFailed,
      DappWarningKind.simulationUnavailable =>
        l10n.dappWarnSimulationUnavailable,
      DappWarningKind.highSlippage => l10n.dappWarnHighSlippage,
    };

/// The dApp's icon, name and host, with the Verify result as a badge.
class DappHeader extends StatelessWidget {
  const DappHeader({
    super.key,
    required this.peer,
    required this.host,
    required this.site,
    this.subtitle,
  });

  final PairingMetadata peer;
  final String? host;
  final SiteCheck site;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = peer.name.trim().isEmpty ? (host ?? '?') : peer.name.trim();
    return Column(
      children: [
        DappIcon(peer: peer, size: 64),
        const SizedBox(height: 12),
        Text(
          name,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        if (host != null) ...[
          const SizedBox(height: 4),
          Text(
            host!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: 8),
        SiteCheckBadge(site: site),
        if (subtitle != null) ...[
          const SizedBox(height: 14),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
        ],
      ],
    );
  }
}

class DappIcon extends StatelessWidget {
  const DappIcon({super.key, required this.peer, this.size = 40});

  final PairingMetadata peer;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = peer.icons.where((i) => i.startsWith('https://')).firstOrNull;
    final fallback = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(size / 4),
      ),
      child: Icon(
        Icons.language_rounded,
        size: size / 2,
        color: AppColors.textSecondary,
      ),
    );
    if (url == null) {
      return fallback;
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 4),
      child: CachedNetworkImage(
        imageUrl: url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorWidget: (_, _, _) => fallback,
        placeholder: (_, _) => fallback,
      ),
    );
  }
}

class SiteCheckBadge extends StatelessWidget {
  const SiteCheckBadge({super.key, required this.site});

  final SiteCheck site;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (label, trust) = switch (site) {
      SiteCheck.verified => (l10n.dappSiteVerified, DappTrust.safe),
      SiteCheck.unknown => (l10n.dappSiteUnknown, DappTrust.caution),
      SiteCheck.mismatch => (l10n.dappSiteMismatch, DappTrust.danger),
      SiteCheck.scam => (l10n.dappSiteScam, DappTrust.blocked),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: trust.color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(trust.icon, size: 14, color: trust.color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: trust.color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// The trust colour and the reasons behind it.
class DappTrustPanel extends StatelessWidget {
  const DappTrustPanel({super.key, required this.review});

  final DappReview review;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final color = review.trust.color;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(review.trust.icon, color: color),
              const SizedBox(width: 8),
              Text(
                review.trust.label(l10n),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          for (final warning in review.warnings) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Icon(
                    Icons.circle,
                    size: 6,
                    color: warning.trust.color,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    dappWarningText(l10n, warning.kind),
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class DappCard extends StatelessWidget {
  const DappCard({super.key, required this.child, this.title});

  final Widget child;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
          ],
          child,
        ],
      ),
    );
  }
}
