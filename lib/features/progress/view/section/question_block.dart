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

  /// Called when this question's "Check" is tapped.
  /// Passes the question key and whether the answer was correct.
  final void Function(String key, {required bool isCorrect}) onQuestionChecked;

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
    final currentAnswer = isFillBlank ? controller.text : selected;
    final isCorrect = matchesAnswer(currentAnswer, question.answer);
    final hasAnswer = isFillBlank
        ? controller.text.trim().isNotEmpty
        : selected != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isChecked
            ? (isCorrect ? AppColors.tertiary : AppColors.error).withValues(
                alpha: 0.04,
              )
            : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isChecked
              ? (isCorrect ? AppColors.tertiary : AppColors.error).withValues(
                  alpha: 0.18,
                )
              : AppColors.outlineVariant.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question number + prompt row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 22,
                height: 22,
                margin: const EdgeInsets.only(top: 1, right: 8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${question.questionNumber}',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: accentColor,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  question.prompt,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          if ((question.clue ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            ExerciseSmallNote(
              icon: Icons.lightbulb_outline_rounded,
              text: question.clue ?? '',
            ),
          ],
          const SizedBox(height: 12),
          if (isFillBlank)
            TextField(
              controller: controller,
              onChanged: (_) => onAnswerSelected(key, controller.text),
              decoration: InputDecoration(
                hintText: 'Type your answer…',
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
          const SizedBox(height: 6),
          // Check / checked state row
          if (!isChecked)
            Align(
              alignment: Alignment.centerRight,
              child: _CheckButton(
                enabled: hasAnswer,
                accentColor: accentColor,
                onTap: () => onQuestionChecked(key, isCorrect: isCorrect),
              ),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  size: 15,
                  color: isCorrect ? AppColors.tertiary : AppColors.error,
                ),
                const SizedBox(width: 5),
                Text(
                  isCorrect ? 'Correct' : 'Checked',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isCorrect ? AppColors.tertiary : AppColors.error,
                  ),
                ),
              ],
            ),
          // Animated result note
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            child: isChecked
                ? Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: ExerciseResultNote(
                      isCorrect: isCorrect,
                      answer: question.answer,
                      explanation: question.explanation,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ── Animated check button ─────────────────────────────────────────────────────

class _CheckButton extends StatefulWidget {
  const _CheckButton({
    required this.enabled,
    required this.accentColor,
    required this.onTap,
  });

  final bool enabled;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  State<_CheckButton> createState() => _CheckButtonState();
}

class _CheckButtonState extends State<_CheckButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    if (widget.enabled) _pulseCtrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_CheckButton old) {
    super.didUpdateWidget(old);
    if (widget.enabled && !_pulseCtrl.isAnimating) {
      _pulseCtrl.repeat(reverse: true);
    } else if (!widget.enabled && _pulseCtrl.isAnimating) {
      _pulseCtrl.stop();
      _pulseCtrl.value = 0;
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (context, child) {
        final glow = widget.enabled ? _pulseCtrl.value * 0.22 : 0.0;
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            boxShadow: widget.enabled
                ? [
                    BoxShadow(
                      color: widget.accentColor.withValues(alpha: glow),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: child,
        );
      },
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: widget.enabled ? 1.0 : 0.45,
        child: OutlinedButton.icon(
          onPressed: widget.enabled ? widget.onTap : null,
          icon: const Icon(Icons.fact_check_rounded, size: 15),
          label: const Text('Check'),
          style: OutlinedButton.styleFrom(
            foregroundColor: widget.accentColor,
            side: BorderSide(color: widget.accentColor.withValues(alpha: 0.45)),
            visualDensity: VisualDensity.compact,
          ),
        ),
      ),
    );
  }
}
