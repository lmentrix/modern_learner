import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';

class ExerciseCompletionDialog extends StatelessWidget {
  const ExerciseCompletionDialog({
    super.key,
    required this.accentColor,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.onContinue,
  });

  final Color accentColor;
  final int totalQuestions;
  final int correctAnswers;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final percentage = totalQuestions <= 0
        ? 0.0
        : correctAnswers / totalQuestions;
    final isPerfect = percentage == 1.0;
    final isGood = percentage >= 0.7;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: isPerfect
                      ? [const Color(0xFFFFD700), const Color(0xFFFFA500)]
                      : isGood
                      ? [accentColor.withValues(alpha: 0.5), accentColor]
                      : [AppColors.outlineVariant, AppColors.onSurfaceVariant],
                ),
              ),
              child: Center(
                child: Text(
                  isPerfect
                      ? '🏆'
                      : isGood
                      ? '🎉'
                      : '💪',
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isPerfect
                  ? 'Perfect!'
                  : isGood
                  ? 'Great Job!'
                  : 'Keep Practicing!',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You got $correctAnswers out of $totalQuestions correct',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: onContinue,
                style: FilledButton.styleFrom(
                  backgroundColor: accentColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Continue',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
