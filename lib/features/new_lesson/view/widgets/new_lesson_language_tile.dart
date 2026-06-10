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

  IconData _languageIcon(String label) {
    return switch (label) {
      'English' => Icons.language_rounded,
      'Spanish' => Icons.forum_rounded,
      'French' => Icons.travel_explore_rounded,
      'German' => Icons.account_tree_rounded,
      'Japanese' => Icons.graphic_eq_rounded,
      'Mandarin' => Icons.record_voice_over_rounded,
      'Italian' => Icons.music_note_rounded,
      'Portuguese' => Icons.waves_rounded,
      _ => Icons.mic_rounded,
    };
  }

  Color _languageColor(String label) {
    return switch (label) {
      'English' => AppColors.primary,
      'Spanish' => const Color(0xFFFF9F43),
      'French' => AppColors.secondary,
      'German' => const Color(0xFF26C6DA),
      'Japanese' => const Color(0xFFFF6E84),
      'Mandarin' => AppColors.tertiary,
      'Italian' => const Color(0xFF5FD068),
      'Portuguese' => const Color(0xFF00BCD4),
      _ => AppColors.primary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final accent = _languageColor(option.label);

    return NewLessonSelectableChip(
      isSelected: isSelected,
      accentColor: accent,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accent.withValues(alpha: 0.20),
                    accent.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: accent.withValues(alpha: 0.18)),
              ),
              child: Icon(_languageIcon(option.label), color: accent, size: 21),
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
                      color: isSelected ? accent : AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 3),
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
                  ? accent
                  : AppColors.onSurfaceVariant.withValues(alpha: 0.6),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
