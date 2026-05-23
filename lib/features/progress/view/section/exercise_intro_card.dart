import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/progress/service/request/exercise_request.dart';
import 'package:modern_learner_production/features/progress/view/helpers/exercise_helpers.dart';
import 'package:modern_learner_production/features/progress/view/widgets/exercise_chip.dart';
import 'package:modern_learner_production/features/progress/view/widgets/exercise_label.dart';
import 'package:modern_learner_production/features/progress/view/widgets/exercise_panel.dart';

class ExerciseIntroCard extends StatelessWidget {
  const ExerciseIntroCard({
    super.key,
    required this.detail,
    required this.accentColor,
  });

  final ChapterExerciseDetailModel detail;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final chips = <String>[
      titleCase(detail.subcontentType),
      if (detail.isVoice) 'Voice lesson' else 'Practice set',
      if (detail.learningFocus.isNotEmpty)
        '${detail.learningFocus.length} focus areas',
    ];

    return ExercisePanel(
      accentColor: accentColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            detail.introduction,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
              height: 1.6,
            ),
          ),
          if (chips.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: chips
                  .map((chip) => ExerciseChip(chip, color: accentColor))
                  .toList(),
            ),
          ],
          if (detail.learningFocus.isNotEmpty) ...[
            const SizedBox(height: 18),
            const ExerciseLabel('Learning focus'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: detail.learningFocus.map(ExerciseChip.new).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
