import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/l10n.dart';

class SendInputCard extends StatelessWidget {
  const SendInputCard({super.key, required this.child, this.trailing});

  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        children: [
          Expanded(child: child),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}

class SendAmountCard extends StatelessWidget {
  const SendAmountCard({
    super.key,
    required this.symbol,
    required this.amountController,
    required this.onChanged,
    required this.onMax,
    this.enabled = true,
  });

  final String symbol;
  final TextEditingController amountController;
  final VoidCallback onChanged;
  final VoidCallback onMax;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: amountController,
              enabled: enabled,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (_) {
                onChanged();
              },
              decoration: InputDecoration(
                hintText: context.l10n.sendAmountHint,
                border: InputBorder.none,
                filled: false,
              ),
            ),
          ),
          Text(symbol, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(width: 10),
          TextButton(
            onPressed: enabled ? onMax : null,
            child: Text(context.l10n.commonMax),
          ),
        ],
      ),
    );
  }
}

class SendTokenAvatar extends StatelessWidget {
  const SendTokenAvatar({super.key, required this.symbol, this.iconUrl});

  final String symbol;
  final String? iconUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.7),
      ),
      child: iconUrl == null
          ? Center(
              child: Text(
                symbol.substring(0, 1),
                style: theme.textTheme.displayMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(8),
              child: ClipOval(
                child: Image.network(
                  iconUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Text(
                      symbol.substring(0, 1),
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

class SendBottomActionRow extends StatelessWidget {
  const SendBottomActionRow({
    super.key,
    required this.leadingLabel,
    required this.trailingLabel,
    required this.onLeading,
    required this.onTrailing,
  });

  final String leadingLabel;
  final String trailingLabel;
  final VoidCallback? onLeading;
  final VoidCallback? onTrailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.tonal(
            onPressed: onLeading,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(58),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
            ),
            child: Text(leadingLabel),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: FilledButton(
            onPressed: onTrailing,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(58),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
            ),
            child: Text(trailingLabel),
          ),
        ),
      ],
    );
  }
}

class SendReviewContent extends StatelessWidget {
  const SendReviewContent({
    super.key,
    required this.amountText,
    this.fiatText,
    required this.rows,
  });

  final String amountText;
  final String? fiatText;
  final List<SendInfoRowData> rows;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 12),
        Center(
          child: Icon(
            Icons.send_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: 52,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          amountText,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.displayLarge?.copyWith(fontSize: 40),
        ),
        if (fiatText != null) ...[
          const SizedBox(height: 6),
          Text(
            fiatText!,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.displaySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
        const SizedBox(height: 24),
        _InfoPanel(rows: rows),
      ],
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.rows});

  final List<SendInfoRowData> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          for (var index = 0; index < rows.length; index++) ...[
            _InfoRow(data: rows[index]),
            if (index != rows.length - 1)
              Divider(
                height: 1,
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
          ],
        ],
      ),
    );
  }
}

class SendInfoRowData {
  const SendInfoRowData(
    this.label,
    this.value, {
    this.isAddress = false,
    this.valueWidget,
    this.maxLines = 1,
  });

  final String label;
  final String value;
  final Widget? valueWidget;
  final bool isAddress;
  final int? maxLines;
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.data});

  final SendInfoRowData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              data.label,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child:
                data.valueWidget ??
                Text(
                  data.value,
                  textAlign: TextAlign.end,
                  maxLines: data.maxLines,
                  overflow: data.maxLines == 1
                      ? TextOverflow.ellipsis
                      : TextOverflow.clip,
                  softWrap: data.maxLines != 1,
                  style:
                      (data.isAddress
                              ? theme.textTheme.titleMedium
                              : theme.textTheme.titleLarge)
                          ?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: data.isAddress ? 0.2 : null,
                          ),
                ),
          ),
        ],
      ),
    );
  }
}
