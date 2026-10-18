import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/airgap/token_registry.dart';

/// A token's icon on the offline signer. Icons ship inside the app
/// (assets/signer_token_icons, see tool/signer_icons) because the signer
/// never goes online. Only verified tokens get one: a scam token could copy
/// any logo, so unverified tokens always show a grey question mark.
class SignerTokenIcon extends StatelessWidget {
  const SignerTokenIcon({super.key, required this.token, this.size = 28});

  final ResolvedToken token;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (!token.isVerified) {
      return _circle(
        color: AppColors.textSecondary.withValues(alpha: 0.18),
        child: Icon(
          Icons.question_mark_rounded,
          size: size * 0.6,
          color: AppColors.textSecondary,
        ),
      );
    }
    final symbol = token.token?.symbol ?? '?';
    final letter = _circle(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Text(
        symbol.isEmpty ? '?' : symbol.characters.first.toUpperCase(),
        style: TextStyle(
          fontSize: size * 0.45,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
    );
    return ClipOval(
      child: Image.asset(
        'assets/signer_token_icons/${token.mint}.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => letter,
      ),
    );
  }

  Widget _circle({required Color color, required Widget child}) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    child: child,
  );
}
