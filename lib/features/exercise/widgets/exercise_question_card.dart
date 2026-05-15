import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';

import '../models/exercise.dart';

class ExerciseQuestionCard extends StatelessWidget {
  const ExerciseQuestionCard({
    super.key,
    required this.exercise,
    required this.accentColor,
    required this.emoji,
  });

  final Exercise exercise;
  final Color accentColor;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _exerciseTypeLabel(exercise.type),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            exercise.question,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
              height: 1.4,
            ),
          ),
          if (exercise.content != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                exercise.content!,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: AppColors.onSurface,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _exerciseTypeLabel(ExerciseType type) {
    return switch (type) {
      ExerciseType.multipleChoice => 'MULTIPLE CHOICE',
      ExerciseType.fillBlank => 'FILL IN THE BLANK',
      ExerciseType.speaking => 'SPEAKING EXERCISE',
      ExerciseType.matching => 'MATCHING',
      ExerciseType.trueFalse => 'TRUE OR FALSE',
      ExerciseType.writing => 'WRITING EXERCISE',
    };
  }
}
