import 'package:flutter/material.dart';

/// Place in bounded horizontal space: the popup matches its trigger exactly.
class WalletDropdown<T> extends StatelessWidget {
  const WalletDropdown({
    super.key,
    required this.child,
    required this.itemBuilder,
    required this.onSelected,
    this.tooltip,
    this.enabled = true,
    this.menuPadding = const EdgeInsets.all(8),
  });

  final Widget child;
  final PopupMenuItemBuilder<T> itemBuilder;
  final PopupMenuItemSelected<T> onSelected;
  final String? tooltip;
  final bool enabled;
  final EdgeInsetsGeometry menuPadding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) => PopupMenuButton<T>(
        tooltip: tooltip,
        enabled: enabled,
        position: PopupMenuPosition.under,
        offset: const Offset(0, 8),
        constraints: BoxConstraints.tightFor(width: constraints.maxWidth),
        menuPadding: menuPadding,
        color: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: .65),
          ),
        ),
        onSelected: onSelected,
        itemBuilder: itemBuilder,
        child: SizedBox(width: double.infinity, child: child),
      ),
    );
  }
}
