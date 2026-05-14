import 'package:flutter/material.dart';

class ResponsiveActionGroup extends StatelessWidget {
  const ResponsiveActionGroup({
    super.key,
    required this.children,
    this.breakpoint = 520,
    this.spacing = 12,
    this.compactWidthFactor = 0.75,
  });

  final List<Widget> children;
  final double breakpoint;
  final double spacing;
  final double compactWidthFactor;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < breakpoint;
        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (var index = 0; index < children.length; index++) ...[
                FractionallySizedBox(
                  widthFactor: compactWidthFactor,
                  child: SizedBox(
                    width: double.infinity,
                    child: children[index],
                  ),
                ),
                if (index != children.length - 1) SizedBox(height: spacing),
              ],
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var index = 0; index < children.length; index++) ...[
              Expanded(child: children[index]),
              if (index != children.length - 1) SizedBox(width: spacing),
            ],
          ],
        );
      },
    );
  }
}
