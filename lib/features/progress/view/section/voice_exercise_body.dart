import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/progress/service/request/exercise_request.dart';
import 'package:modern_learner_production/features/progress/view/widgets/exercise_label.dart';
import 'package:modern_learner_production/features/progress/view/widgets/exercise_panel.dart';
import 'package:modern_learner_production/features/progress/view/widgets/exercise_small_note.dart';
import 'package:modern_learner_production/features/progress/view/widgets/vocabulary_row.dart';
import 'package:modern_learner_production/features/progress/view/widgets/voice_step_row.dart';

class VoiceExerciseBody extends StatelessWidget {
  const VoiceExerciseBody({
    super.key,
    required this.detail,
    required this.accentColor,
  });

  final ChapterExerciseDetailModel detail;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ExercisePanel(
          accentColor: accentColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ExerciseLabel('Speaking practice'),
              const SizedBox(height: 12),
              if ((detail.speakingFocus ?? '').trim().isNotEmpty)
                Text(
                  detail.speakingFocus!,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                    height: 1.55,
                  ),
                ),
              const SizedBox(height: 14),
              ...detail.practiceSteps.map(
                (step) => VoiceStepRow(step: step, accentColor: accentColor),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ExercisePanel(
          accentColor: AppColors.secondary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ExerciseLabel('Vocabulary'),
              const SizedBox(height: 12),
              ...detail.vocabularyItems.map(VocabularyRow.new),
            ],
          ),
        ),
        if ((detail.performanceTask ?? '').trim().isNotEmpty) ...[
          const SizedBox(height: 16),
          ExercisePanel(
            accentColor: AppColors.tertiary,
            child: ExerciseSmallNote(
              icon: Icons.record_voice_over_rounded,
              text: detail.performanceTask!,
            ),
          ),
        ],
      ],
    );
  }
}
