import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/l10n/app_text.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/new_lesson/data/new_lesson_option_item.dart';
import 'package:modern_learner_production/features/new_lesson/view/widgets/new_lesson_selectable_chip.dart';

class NewLessonDifficultyTile extends StatelessWidget {
  const NewLessonDifficultyTile({
    super.key,
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final NewLessonOptionItem option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return NewLessonSelectableChip(
      isSelected: isSelected,
      accentColor: AppColors.tertiary,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(option.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 16),
            Text(
              context.tr(option.label),
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isSelected ? AppColors.tertiary : AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              context.tr(option.detail),
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
