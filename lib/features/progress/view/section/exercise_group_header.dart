import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/progress/service/request/exercise_request.dart';
import 'package:modern_learner_production/features/progress/view/helpers/exercise_helpers.dart';
import 'package:modern_learner_production/features/progress/view/widgets/exercise_icon_box.dart';

class ExerciseGroupHeader extends StatelessWidget {
  const ExerciseGroupHeader({
    super.key,
    required this.group,
    required this.accentColor,
  });

  final ChapterExerciseGroupModel group;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExerciseIconBox(
          icon: groupIcon(group.exerciseType),
          color: accentColor,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                group.title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
              ),
              SizedBox(height: 5),
              Text(
                group.instructions,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
