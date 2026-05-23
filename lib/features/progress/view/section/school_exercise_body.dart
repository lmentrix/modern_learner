import 'package:flutter/material.dart';
import 'package:modern_learner_production/features/progress/service/request/exercise_request.dart';
import 'package:modern_learner_production/features/progress/view/section/exercise_group_card.dart';

class SchoolExerciseBody extends StatelessWidget {
  const SchoolExerciseBody({
    super.key,
    required this.detail,
    required this.accentColor,
    required this.checked,
    required this.selectedAnswers,
    required this.matchingAnswers,
    required this.activeMatchKey,
    required this.textControllers,
    required this.onAnswerSelected,
    required this.onMatchLeftSelected,
    required this.onMatchRightSelected,
    required this.onMatchCleared,
  });

  final ChapterExerciseDetailModel detail;
  final Color accentColor;
  final bool checked;
  final Map<String, String> selectedAnswers;
  final Map<String, String> matchingAnswers;
  final String? activeMatchKey;
  final Map<String, TextEditingController> textControllers;
  final void Function(String key, String answer) onAnswerSelected;
  final ValueChanged<String> onMatchLeftSelected;
  final ValueChanged<String> onMatchRightSelected;
  final ValueChanged<String> onMatchCleared;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (
          var groupIndex = 0;
          groupIndex < detail.exerciseGroups.length;
          groupIndex++
        )
          Padding(
            padding: EdgeInsets.only(
              bottom: groupIndex < detail.exerciseGroups.length - 1 ? 16 : 0,
            ),
            child: ExerciseGroupCard(
              groupIndex: groupIndex,
              group: detail.exerciseGroups[groupIndex],
              accentColor: accentColor,
              checked: checked,
              selectedAnswers: selectedAnswers,
              matchingAnswers: matchingAnswers,
              activeMatchKey: activeMatchKey,
              textControllers: textControllers,
              onAnswerSelected: onAnswerSelected,
              onMatchLeftSelected: onMatchLeftSelected,
              onMatchRightSelected: onMatchRightSelected,
              onMatchCleared: onMatchCleared,
            ),
          ),
      ],
    );
  }
}
