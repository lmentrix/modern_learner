import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/progress/service/request/exercise_request.dart';
import 'package:modern_learner_production/features/progress/view/helpers/exercise_helpers.dart';
import 'package:modern_learner_production/features/progress/view/widgets/answer_option.dart';
import 'package:modern_learner_production/features/progress/view/widgets/exercise_result_note.dart';
import 'package:modern_learner_production/features/progress/view/widgets/exercise_small_note.dart';

class QuestionBlock extends StatelessWidget {
  const QuestionBlock({
    super.key,
    required this.groupIndex,
    required this.group,
    required this.question,
    required this.accentColor,
    required this.checked,
    required this.checkedQuestionKeys,
    required this.selectedAnswers,
    required this.textControllers,
    required this.onAnswerSelected,
    required this.onQuestionChecked,
  });

  final int groupIndex;
  final ChapterExerciseGroupModel group;
  final ChapterExerciseQuestionModel question;
  final Color accentColor;
  final bool checked;
  final Set<String> checkedQuestionKeys;
  final Map<String, String> selectedAnswers;
  final Map<String, TextEditingController> textControllers;
  final void Function(String key, String answer) onAnswerSelected;
  final ValueChanged<String> onQuestionChecked;

  @override
  Widget build(BuildContext context) {
    final key = questionKey(groupIndex, question.questionNumber);
    final selected = selectedAnswers[key];
    final controller = textControllers.putIfAbsent(
      key,
      TextEditingController.new,
    );
    final isFillBlank = group.exerciseType == 'fill_in_the_blank';
    final isChecked = checked || checkedQuestionKeys.contains(key);
    final isCorrect = matchesAnswer(
      isFillBlank ? controller.text : selected,
      question.answer,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.prompt,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
              height: 1.35,
            ),
          ),
          if ((question.clue ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            ExerciseSmallNote(
              icon: Icons.lightbulb_outline_rounded,
              text: question.clue!,
            ),
          ],
          const SizedBox(height: 12),
          if (isFillBlank)
            TextField(
              controller: controller,
              onChanged: (_) {
                onAnswerSelected(key, controller.text);
              },
              decoration: InputDecoration(
                hintText: 'Type your answer',
                filled: true,
                fillColor: AppColors.surfaceContainer,
                focusedBorder: exerciseInputBorder(accentColor),
                enabledBorder: exerciseInputBorder(AppColors.outlineVariant),
              ),
            )
          else
            Column(
              children: question.options
                  .map(
                    (option) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: AnswerOption(
                        label: option,
                        selected: selected == option,
                        checked: isChecked,
                        isCorrectAnswer: option == question.answer,
                        accentColor: accentColor,
                        onTap: () => onAnswerSelected(key, option),
                      ),
                    ),
                  )
                  .toList(),
            ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () => onQuestionChecked(key),
              icon: const Icon(Icons.fact_check_rounded, size: 16),
              label: const Text('Check'),
              style: OutlinedButton.styleFrom(
                foregroundColor: accentColor,
                side: BorderSide(color: accentColor.withValues(alpha: 0.35)),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
          if (isChecked && !isCorrect) ...[
            const SizedBox(height: 12),
            ExerciseResultNote(
              isCorrect: isCorrect,
              answer: question.answer,
              explanation: question.explanation,
            ),
          ],
        ],
      ),
    );
  }
}
