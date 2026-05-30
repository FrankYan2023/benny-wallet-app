import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';

Future<void> showErrorAlertDialog(
  BuildContext context, {
  required String title,
  required String message,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(title),
      content: Text(message),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(context.l10n.commonOk),
        ),
      ],
    ),
  );
}
