import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/l10n/app_text.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/new_lesson/data/new_lesson_option_item.dart';
import 'package:modern_learner_production/features/new_lesson/view/widgets/new_lesson_selectable_chip.dart';

class NewLessonLanguageTile extends StatelessWidget {
  const NewLessonLanguageTile({
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
      accentColor: AppColors.primary,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(option.emoji, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    context.tr(option.label),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.onSurface,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    context.tr(option.detail),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: isSelected
                  ? AppColors.primary
                  : AppColors.onSurfaceVariant.withValues(alpha: 0.6),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
