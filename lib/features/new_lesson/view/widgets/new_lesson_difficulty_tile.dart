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

  IconData _difficultyIcon(String label) {
    return switch (label) {
      'Intermediate' => Icons.local_fire_department_rounded,
      'Advanced' => Icons.rocket_launch_rounded,
      _ => Icons.spa_rounded,
    };
  }

  Color _difficultyColor(String label) {
    return switch (label) {
      'Intermediate' => const Color(0xFFFF9F43),
      'Advanced' => AppColors.secondary,
      _ => AppColors.tertiary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final accent = _difficultyColor(option.label);

    return NewLessonSelectableChip(
      isSelected: isSelected,
      accentColor: accent,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: accent.withValues(alpha: 0.18)),
                  ),
                  child: Icon(_difficultyIcon(option.label), color: accent),
                ),
                const Spacer(),
                Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: isSelected
                      ? accent
                      : AppColors.onSurfaceVariant.withValues(alpha: 0.55),
                  size: 19,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              context.tr(option.label),
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isSelected ? accent : AppColors.onSurface,
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
