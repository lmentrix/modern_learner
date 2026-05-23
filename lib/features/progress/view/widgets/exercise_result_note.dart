import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';

class ExerciseResultNote extends StatelessWidget {
  const ExerciseResultNote({
    super.key,
    required this.isCorrect,
    required this.answer,
    required this.explanation,
  });

  final bool isCorrect;
  final String answer;
  final String explanation;

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? AppColors.tertiary : AppColors.error;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Text(
        '${isCorrect ? 'Correct' : 'Answer: $answer'}\n$explanation',
        style: GoogleFonts.inter(
          fontSize: 12,
          color: AppColors.onSurfaceVariant,
          height: 1.45,
        ),
      ),
    );
  }
}
