import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/progress/service/request/exercise_request.dart';
import 'package:modern_learner_production/features/progress/view/widgets/exercise_chip.dart';
import 'package:modern_learner_production/features/progress/view/widgets/exercise_small_note.dart';

class VoiceStepRow extends StatelessWidget {
  const VoiceStepRow({
    super.key,
    required this.step,
    required this.accentColor,
    required this.checked,
    required this.onChecked,
  });

  final VoicePracticeStepModel step;
  final Color accentColor;
  final bool checked;
  final VoidCallback onChecked;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExerciseChip('Step ${step.stepNumber}', color: accentColor),
          const SizedBox(height: 10),
          Text(
            step.prompt,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          ExerciseSmallNote(
            icon: Icons.tips_and_updates_rounded,
            text: step.coachingTip,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: onChecked,
              icon: const Icon(Icons.fact_check_rounded, size: 16),
              label: const Text('Check'),
              style: OutlinedButton.styleFrom(
                foregroundColor: accentColor,
                side: BorderSide(color: accentColor.withValues(alpha: 0.35)),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
          if (checked) ...[
            const SizedBox(height: 8),
            ExerciseSmallNote(
              icon: Icons.check_circle_outline_rounded,
              text: 'Target response: ${step.prompt}',
            ),
          ],
        ],
      ),
    );
  }
}
