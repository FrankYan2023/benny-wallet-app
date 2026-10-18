import 'package:flutter/material.dart';

/// Numbered recovery words, two columns so 24 words fit on one screen.
class RecoveryWordsGrid extends StatelessWidget {
  const RecoveryWordsGrid({super.key, required this.words});

  final List<String> words;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: words.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 4,
      ),
      itemBuilder: (context, index) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerLeft,
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '${index + 1}. ',
                style: TextStyle(color: theme.colorScheme.outline),
              ),
              TextSpan(
                text: words[index],
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          style: theme.textTheme.titleMedium,
        ),
      ),
    );
  }
}
