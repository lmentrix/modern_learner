import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';

class ExerciseAnswerOption extends StatelessWidget {
  const ExerciseAnswerOption({
    super.key,
    required this.option,
    required this.isSelected,
    required this.isCorrect,
    required this.isWrong,
    required this.onTap,
    required this.accentColor,
  });

  final String option;
  final bool isSelected;
  final bool isCorrect;
  final bool isWrong;
  final VoidCallback onTap;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    Color backgroundColor;
    Color textColor;

    if (isCorrect) {
      borderColor = Colors.green;
      backgroundColor = Colors.green.withValues(alpha: 0.1);
      textColor = Colors.green.shade700;
    } else if (isWrong) {
      borderColor = Colors.red;
      backgroundColor = Colors.red.withValues(alpha: 0.1);
      textColor = Colors.red.shade700;
    } else if (isSelected) {
      borderColor = accentColor;
      backgroundColor = accentColor.withValues(alpha: 0.15);
      textColor = accentColor;
    } else {
      borderColor = AppColors.outlineVariant.withValues(alpha: 0.3);
      backgroundColor = AppColors.surfaceContainerHighest;
      textColor = AppColors.onSurface;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                option,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            if (isCorrect)
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 22,
              ),
            if (isWrong)
              const Icon(Icons.error_rounded, color: Colors.red, size: 22),
          ],
        ),
      ),
    );
  }
}
