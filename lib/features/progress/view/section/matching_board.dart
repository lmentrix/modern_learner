import 'package:flutter/material.dart';
import 'package:modern_learner_production/core/l10n/app_text.dart';
import 'package:modern_learner_production/features/progress/service/request/exercise_request.dart';
import 'package:modern_learner_production/features/progress/view/helpers/exercise_helpers.dart';
import 'package:modern_learner_production/features/progress/view/widgets/match_choice_chip.dart';
import 'package:modern_learner_production/features/progress/view/widgets/match_prompt_card.dart';
import 'package:modern_learner_production/features/progress/view/widgets/exercise_label.dart';
import 'package:modern_learner_production/features/progress/view/widgets/exercise_result_note.dart';

class MatchingBoard extends StatelessWidget {
  const MatchingBoard({
    super.key,
    required this.groupIndex,
    required this.pairs,
    required this.accentColor,
    required this.checked,
    required this.checkedMatchKeys,
    required this.matchingAnswers,
    required this.activeMatchKey,
    required this.onLeftSelected,
    required this.onRightSelected,
    required this.onMatchCleared,
    required this.onMatchChecked,
  });

  final int groupIndex;
  final List<ChapterExerciseMatchingPairModel> pairs;
  final Color accentColor;
  final bool checked;
  final Set<String> checkedMatchKeys;
  final Map<String, String> matchingAnswers;
  final String? activeMatchKey;
  final ValueChanged<String> onLeftSelected;
  final ValueChanged<String> onRightSelected;
  final ValueChanged<String> onMatchCleared;
  final ValueChanged<String> onMatchChecked;

  @override
  Widget build(BuildContext context) {
    final rightItems = pairs.map((pair) => pair.rightItem).toList()
      ..sort((a, b) => b.length.compareTo(a.length));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExerciseLabel(context.tr('Tap a prompt, then choose its match')),
        const SizedBox(height: 10),
        ...pairs.map((pair) {
          final key = matchingKey(groupIndex, pair.pairNumber);
          final selectedAnswer = matchingAnswers[key];
          final isActive = activeMatchKey == key;
          final isCorrect = selectedAnswer == pair.rightItem;
          final isChecked = checked || checkedMatchKeys.contains(key);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                MatchPromptCard(
                  label: pair.leftItem,
                  selectedAnswer: selectedAnswer,
                  checked: isChecked,
                  isActive: isActive,
                  isCorrect: isCorrect,
                  accentColor: accentColor,
                  onTap: () => onLeftSelected(key),
                  onClear: selectedAnswer == null
                      ? null
                      : () => onMatchCleared(key),
                ),
                const SizedBox(height: 6),
                OutlinedButton.icon(
                  onPressed: () => onMatchChecked(key),
                  icon: const Icon(Icons.fact_check_rounded, size: 16),
                  label: Text(context.tr('Check')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: accentColor,
                    side: BorderSide(
                      color: accentColor.withValues(alpha: 0.35),
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                if (isChecked && !isCorrect) ...[
                  const SizedBox(height: 8),
                  ExerciseResultNote(
                    isCorrect: false,
                    answer: pair.rightItem,
                    explanation: context.tr(
                      'Match this prompt with the shown answer.',
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: rightItems.map((answer) {
            final isUsed = matchingAnswers.containsValue(answer);
            return MatchChoiceChip(
              label: answer,
              disabled: isUsed && activeMatchKey == null,
              accentColor: accentColor,
              onTap: () => onRightSelected(answer),
            );
          }).toList(),
        ),
      ],
    );
  }
}
