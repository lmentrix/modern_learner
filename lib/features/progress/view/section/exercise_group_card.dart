import 'package:flutter/material.dart';
import 'package:modern_learner_production/features/progress/service/request/exercise_request.dart';
import 'package:modern_learner_production/features/progress/view/helpers/exercise_helpers.dart';
import 'package:modern_learner_production/features/progress/view/section/exercise_group_header.dart';
import 'package:modern_learner_production/features/progress/view/section/matching_board.dart';
import 'package:modern_learner_production/features/progress/view/section/question_block.dart';
import 'package:modern_learner_production/features/progress/view/widgets/exercise_panel.dart';

class ExerciseGroupCard extends StatelessWidget {
  const ExerciseGroupCard({
    super.key,
    required this.groupIndex,
    required this.group,
    required this.accentColor,
    required this.checked,
    required this.checkedQuestionKeys,
    required this.checkedMatchKeys,
    required this.selectedAnswers,
    required this.matchingAnswers,
    required this.activeMatchKey,
    required this.textControllers,
    required this.onAnswerSelected,
    required this.onMatchLeftSelected,
    required this.onMatchRightSelected,
    required this.onMatchCleared,
    required this.onQuestionChecked,
    required this.onMatchChecked,
  });

  final int groupIndex;
  final ChapterExerciseGroupModel group;
  final Color accentColor;
  final bool checked;
  final Set<String> checkedQuestionKeys;
  final Set<String> checkedMatchKeys;
  final Map<String, String> selectedAnswers;
  final Map<String, String> matchingAnswers;
  final String? activeMatchKey;
  final Map<String, TextEditingController> textControllers;
  final void Function(String key, String answer) onAnswerSelected;
  final ValueChanged<String> onMatchLeftSelected;
  final ValueChanged<String> onMatchRightSelected;
  final ValueChanged<String> onMatchCleared;
  final void Function(String key, {required bool isCorrect}) onQuestionChecked;
  final ValueChanged<String> onMatchChecked;

  @override
  Widget build(BuildContext context) {
    final color = typeColor(group.exerciseType, accentColor);
    return ExercisePanel(
      accentColor: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExerciseGroupHeader(group: group, accentColor: color),
          const SizedBox(height: 16),
          if (group.exerciseType == 'matching')
            MatchingBoard(
              groupIndex: groupIndex,
              pairs: group.pairs,
              accentColor: color,
              checked: checked,
              checkedMatchKeys: checkedMatchKeys,
              matchingAnswers: matchingAnswers,
              activeMatchKey: activeMatchKey,
              onLeftSelected: onMatchLeftSelected,
              onRightSelected: onMatchRightSelected,
              onMatchCleared: onMatchCleared,
              onMatchChecked: onMatchChecked,
            )
          else
            ...group.questions.map(
              (question) => QuestionBlock(
                groupIndex: groupIndex,
                group: group,
                question: question,
                accentColor: color,
                checked: checked,
                checkedQuestionKeys: checkedQuestionKeys,
                selectedAnswers: selectedAnswers,
                textControllers: textControllers,
                onAnswerSelected: onAnswerSelected,
                onQuestionChecked: onQuestionChecked,
              ),
            ),
        ],
      ),
    );
  }
}
