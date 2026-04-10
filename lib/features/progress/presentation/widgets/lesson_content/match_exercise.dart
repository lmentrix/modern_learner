import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/progress/data/models/lesson_content_model.dart';

class MatchExercise extends StatelessWidget {
  const MatchExercise({
    super.key,
    required this.exerciseIdx,
    required this.items,
    required this.shuffledAnswers,
    required this.itemAnswers,
    required this.itemCorrect,
    required this.typeColor,
    required this.itemKey,
    required this.onSelect,
  });

  final int exerciseIdx;
  final List<ExerciseItemModel> items;
  final List<String> shuffledAnswers;
  final Map<String, String?> itemAnswers;
  final Map<String, bool?> itemCorrect;
  final Color typeColor;
  final String Function(int, int) itemKey;
  final Function(String key, String answer, String correctAnswer) onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.asMap().entries.map((e) {
        final key = itemKey(exerciseIdx, e.key);
        final item = e.value;
        final isCorrect = itemCorrect[key] == true;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question term
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.question,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                    if (isCorrect) ...[
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 15,
                        color: AppColors.tertiary,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Answer chips (hidden once correct)
              if (!isCorrect)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: shuffledAnswers.map((answer) {
                    final selected = itemAnswers[key] == answer;
                    final isWrong = selected && itemCorrect[key] == false;
                    return GestureDetector(
                      onTap: () => onSelect(key, answer, item.answer),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: isWrong
                              ? AppColors.error.withValues(alpha: 0.1)
                              : selected
                              ? typeColor.withValues(alpha: 0.15)
                              : AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isWrong
                                ? AppColors.error.withValues(alpha: 0.4)
                                : selected
                                ? typeColor.withValues(alpha: 0.4)
                                : AppColors.outlineVariant.withValues(
                                    alpha: 0.3,
                                  ),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isWrong) ...[
                              const Icon(
                                Icons.close_rounded,
                                size: 12,
                                color: AppColors.error,
                              ),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              answer,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: isWrong
                                    ? AppColors.error
                                    : selected
                                    ? typeColor
                                    : AppColors.onSurface,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                )
              else
                // Locked correct answer
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.tertiary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.tertiary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_rounded,
                        size: 13,
                        color: AppColors.tertiary,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        item.answer,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.tertiary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
