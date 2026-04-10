import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/progress/data/models/lesson_content_model.dart';

class FillBlankExercise extends StatelessWidget {
  const FillBlankExercise({
    super.key,
    required this.exerciseIdx,
    required this.items,
    required this.itemCorrect,
    required this.typeColor,
    required this.itemKey,
    required this.getController,
    required this.onCheck,
  });

  final int exerciseIdx;
  final List<ExerciseItemModel> items;
  final Map<String, bool?> itemCorrect;
  final Color typeColor;
  final String Function(int, int) itemKey;
  final TextEditingController Function(String key) getController;
  final Function(String key, String correctAnswer) onCheck;

  static List<TextSpan> _buildBlankSpans(String question, Color color) {
    final parts = question.split('__');
    if (parts.length <= 1) return [TextSpan(text: question)];
    final spans = <TextSpan>[];
    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isNotEmpty) spans.add(TextSpan(text: parts[i]));
      if (i < parts.length - 1) {
        spans.add(
          TextSpan(
            text: ' _____ ',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
              decorationColor: color,
            ),
          ),
        );
      }
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.asMap().entries.map((e) {
        final key = itemKey(exerciseIdx, e.key);
        final item = e.value;
        final controller = getController(key);
        final correctness = itemCorrect[key];
        final isCorrect = correctness == true;
        final isWrong = correctness == false;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question with highlighted blank
              RichText(
                text: TextSpan(
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.onSurface,
                    height: 1.5,
                  ),
                  children: _buildBlankSpans(item.question, typeColor),
                ),
              ),
              const SizedBox(height: 10),

              // Input row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      enabled: !isCorrect,
                      onSubmitted: (_) => onCheck(key, item.answer),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Type your answer…',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.onSurfaceVariant.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        filled: true,
                        fillColor: isCorrect
                            ? AppColors.tertiary.withValues(alpha: 0.08)
                            : isWrong
                            ? AppColors.error.withValues(alpha: 0.08)
                            : AppColors.surfaceContainer,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: isWrong
                                ? AppColors.error.withValues(alpha: 0.4)
                                : AppColors.outlineVariant.withValues(
                                    alpha: 0.3,
                                  ),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: typeColor.withValues(alpha: 0.5),
                          ),
                        ),
                        suffixIcon: isCorrect
                            ? const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.tertiary,
                                size: 18,
                              )
                            : isWrong
                            ? const Icon(
                                Icons.cancel_rounded,
                                color: AppColors.error,
                                size: 18,
                              )
                            : null,
                      ),
                    ),
                  ),
                  if (!isCorrect) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => onCheck(key, item.answer),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: typeColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Check',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              // Wrong feedback with correct answer
              if (isWrong) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lightbulb_outline_rounded,
                        size: 13,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Correct answer: ',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.error,
                        ),
                      ),
                      Text(
                        item.answer,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Correct feedback
              if (isCorrect) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 13,
                      color: AppColors.tertiary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Correct!',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.tertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }
}
