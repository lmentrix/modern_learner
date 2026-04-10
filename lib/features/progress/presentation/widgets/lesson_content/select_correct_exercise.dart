import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/progress/data/models/lesson_content_model.dart';

class SelectCorrectExercise extends StatelessWidget {
  const SelectCorrectExercise({
    super.key,
    required this.exerciseIdx,
    required this.items,
    required this.itemAnswers,
    required this.itemCorrect,
    required this.typeColor,
    required this.itemKey,
    required this.onSelect,
  });

  final int exerciseIdx;
  final List<ExerciseItemModel> items;
  final Map<String, String?> itemAnswers;
  final Map<String, bool?> itemCorrect;
  final Color typeColor;
  final String Function(int, int) itemKey;
  final Function(String key, String answer, String correctAnswer) onSelect;

  static List<String> _parseOptions(String question) =>
      question.split(' | ').map((s) => s.trim()).toList();

  static String _optionKey(String option) {
    final m = RegExp(r'^([A-Z]):').firstMatch(option.trim());
    return m?.group(1) ?? option.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.asMap().entries.map((e) {
        final key = itemKey(exerciseIdx, e.key);
        final item = e.value;
        final options = _parseOptions(item.question);
        final selectedKey = itemAnswers[key];
        final correctness = itemCorrect[key];
        final isAnswered = correctness != null;

        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: options.map((option) {
              final optKey = _optionKey(option);
              final isSelected = selectedKey == optKey;
              final isThisCorrect = optKey == item.answer.trim();
              final isThisWrong = isSelected && correctness == false;
              final showCorrect = isAnswered && isThisCorrect;

              Color? bgColor;
              Color? borderColor;
              Color textColor = AppColors.onSurface;
              Widget? trailingIcon;

              if (showCorrect) {
                bgColor = AppColors.tertiary.withValues(alpha: 0.1);
                borderColor = AppColors.tertiary.withValues(alpha: 0.4);
                textColor = AppColors.tertiary;
                trailingIcon = const Icon(
                  Icons.check_circle_rounded,
                  size: 16,
                  color: AppColors.tertiary,
                );
              } else if (isThisWrong) {
                bgColor = AppColors.error.withValues(alpha: 0.08);
                borderColor = AppColors.error.withValues(alpha: 0.35);
                textColor = AppColors.error;
                trailingIcon = const Icon(
                  Icons.cancel_rounded,
                  size: 16,
                  color: AppColors.error,
                );
              } else if (isSelected) {
                bgColor = typeColor.withValues(alpha: 0.1);
                borderColor = typeColor.withValues(alpha: 0.35);
                textColor = typeColor;
              } else {
                bgColor = AppColors.surfaceContainer;
                borderColor = AppColors.outlineVariant.withValues(alpha: 0.3);
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: isAnswered && correctness == true
                      ? null
                      : () => onSelect(key, optKey, item.answer.trim()),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        // Option key badge
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: showCorrect
                                ? AppColors.tertiary.withValues(alpha: 0.2)
                                : isThisWrong
                                ? AppColors.error.withValues(alpha: 0.15)
                                : typeColor.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              optKey,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: showCorrect
                                    ? AppColors.tertiary
                                    : isThisWrong
                                    ? AppColors.error
                                    : typeColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            option.replaceFirst(RegExp(r'^[A-Z]:\s*'), ''),
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: textColor,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              height: 1.4,
                            ),
                          ),
                        ),
                        if (trailingIcon != null) ...[
                          const SizedBox(width: 8),
                          trailingIcon,
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}
