import 'package:flutter/material.dart';
import 'package:modern_learner_production/features/progress/service/request/exercise_request.dart';
import 'package:modern_learner_production/features/progress/view/helpers/exercise_helpers.dart';
import 'package:modern_learner_production/features/progress/view/widgets/match_choice_chip.dart';
import 'package:modern_learner_production/features/progress/view/widgets/match_prompt_card.dart';
import 'package:modern_learner_production/features/progress/view/widgets/exercise_label.dart';

class MatchingBoard extends StatelessWidget {
  const MatchingBoard({
    super.key,
    required this.groupIndex,
    required this.pairs,
    required this.accentColor,
    required this.checked,
    required this.matchingAnswers,
    required this.activeMatchKey,
    required this.onLeftSelected,
    required this.onRightSelected,
    required this.onMatchCleared,
  });

  final int groupIndex;
  final List<ChapterExerciseMatchingPairModel> pairs;
  final Color accentColor;
  final bool checked;
  final Map<String, String> matchingAnswers;
  final String? activeMatchKey;
  final ValueChanged<String> onLeftSelected;
  final ValueChanged<String> onRightSelected;
  final ValueChanged<String> onMatchCleared;

  @override
  Widget build(BuildContext context) {
    final rightItems = pairs.map((pair) => pair.rightItem).toList()
      ..sort((a, b) => b.length.compareTo(a.length));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ExerciseLabel('Tap a prompt, then choose its match'),
        const SizedBox(height: 10),
        ...pairs.map((pair) {
          final key = matchingKey(groupIndex, pair.pairNumber);
          final selectedAnswer = matchingAnswers[key];
          final isActive = activeMatchKey == key;
          final isCorrect = selectedAnswer == pair.rightItem;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: MatchPromptCard(
              label: pair.leftItem,
              selectedAnswer: selectedAnswer,
              checked: checked,
              isActive: isActive,
              isCorrect: isCorrect,
              accentColor: accentColor,
              onTap: () => onLeftSelected(key),
              onClear: selectedAnswer == null ? null : () => onMatchCleared(key),
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
