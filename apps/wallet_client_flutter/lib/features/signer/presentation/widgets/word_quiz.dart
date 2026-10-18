import 'dart:math';

// The BIP39 English list is only exported from the package's src folder.
// ignore: implementation_imports
import 'package:bip39/src/wordlists/english.dart' as bip39_words;
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/l10n.dart';
import 'signer_ui.dart';

/// How many words are checked: 8 of 24, 4 of 12.
int quizQuestionCount(int wordCount) => wordCount >= 24 ? 8 : 4;

class _Question {
  const _Question(this.index, this.options);

  final int index;
  final List<String> options;
}

/// Backup check: for several random positions the user picks the right word
/// out of four. A wrong pick starts over with new positions, so guessing by
/// elimination does not work. The four options for a position stay the same
/// for the life of the quiz, so seeing a position again with fresh decoys
/// cannot narrow it down either.
class WordQuiz extends StatefulWidget {
  const WordQuiz({
    super.key,
    required this.words,
    required this.onPassed,
    this.maxWrongAnswers,
    this.onFailed,
    this.random,
  });

  final List<String> words;
  final VoidCallback onPassed;

  /// When set, the quiz ends after this many wrong picks in total and calls
  /// [onFailed]; the options are no longer shown.
  final int? maxWrongAnswers;
  final VoidCallback? onFailed;

  /// For tests; a secure random source by default.
  final Random? random;

  @override
  State<WordQuiz> createState() => WordQuizState();
}

@visibleForTesting
class WordQuizState extends State<WordQuiz> {
  late final Random _random = widget.random ?? Random.secure();
  late List<_Question> _questions;
  final Map<int, List<String>> _optionsByIndex = {};
  int _current = 0;
  int _wrongCount = 0;
  bool _wrong = false;
  bool _failed = false;
  String? _flash;

  @visibleForTesting
  List<int> get questionIndexes => [for (final q in _questions) q.index];

  @visibleForTesting
  List<String> get currentOptions => _questions[_current].options;

  @override
  void initState() {
    super.initState();
    _questions = _build();
  }

  List<_Question> _build() {
    final words = widget.words;
    final count = quizQuestionCount(words.length);
    final indexes = <int>{};
    while (indexes.length < count) {
      indexes.add(_random.nextInt(words.length));
    }
    final inPhrase = words.toSet();
    return [
      for (final index in indexes.toList()..sort())
        _Question(index, _options(index, words[index], inPhrase)),
    ];
  }

  List<String> _options(int index, String answer, Set<String> inPhrase) {
    final fixed = _optionsByIndex.putIfAbsent(index, () {
      final options = <String>{answer};
      while (options.length < 4) {
        final word =
            bip39_words.WORDLIST[_random.nextInt(bip39_words.WORDLIST.length)];
        if (!inPhrase.contains(word)) {
          options.add(word);
        }
      }
      return options.toList();
    });
    return List.of(fixed)..shuffle(_random);
  }

  void _pick(String word) {
    if (_failed) {
      return;
    }
    final question = _questions[_current];
    if (word != widget.words[question.index]) {
      _wrongCount++;
      final limit = widget.maxWrongAnswers;
      if (limit != null && _wrongCount >= limit) {
        setState(() {
          _failed = true;
          _flash = null;
        });
        widget.onFailed?.call();
        return;
      }
      setState(() {
        _wrong = true;
        _flash = null;
        _current = 0;
        _questions = _build();
      });
      return;
    }
    if (_current == _questions.length - 1) {
      widget.onPassed();
      return;
    }
    setState(() {
      _wrong = false;
      _flash = word;
      _current++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    if (_failed) {
      return SignerNotice(
        text: l10n.signerQuizWrong,
        icon: Icons.lock_outline_rounded,
        tone: SignerTone.danger,
      );
    }
    final question = _questions[_current];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            for (var i = 0; i < _questions.length; i++)
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: i < _current
                        ? AppColors.success
                        : i == _current
                        ? AppColors.primaryBright
                        : AppColors.surfaceContainerHigh,
                  ),
                ),
              ),
          ],
        ),
        signerGap,
        if (_wrong) ...[
          SignerNotice(
            text: l10n.signerQuizWrong,
            icon: Icons.refresh_rounded,
            tone: SignerTone.danger,
          ),
          signerGap,
        ],
        WalletCard(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
          child: Column(
            children: [
              Text(
                l10n.signerQuizProgress(_current + 1, _questions.length),
                style: theme.textTheme.labelMedium,
              ),
              const SizedBox(height: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: Text(
                  l10n.signerQuizQuestion(question.index + 1),
                  key: ValueKey(question.index),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displaySmall,
                ),
              ),
              const SizedBox(height: 18),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.6,
                children: [
                  for (final option in question.options)
                    _OptionButton(
                      key: ValueKey('${question.index}-$option'),
                      label: option,
                      onTap: () => _pick(option),
                    ),
                ],
              ),
              if (_flash != null) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.success,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.signerQuizCorrect,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _OptionButton extends StatelessWidget {
  const _OptionButton({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Center(
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
