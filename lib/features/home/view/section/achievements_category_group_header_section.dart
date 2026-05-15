import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/home/data/home_achievement_data.dart';

class AchievementsCategoryGroupHeaderSection extends StatelessWidget {
  const AchievementsCategoryGroupHeaderSection({
    super.key,
    required this.category,
    required this.count,
    required this.unlocked,
  });

  final String category;
  final int count;
  final int unlocked;

  @override
  Widget build(BuildContext context) {
    final meta = achievementCategoryMeta[category];
    final accent = meta?.$2 ?? AppColors.primary;
    final emoji = meta?.$1 ?? '🏅';

    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 15)),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          category.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppColors.onSurfaceVariant,
            letterSpacing: 1.6,
          ),
        ),
        const Spacer(),
        Text(
          '$unlocked/$count',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: unlocked == count ? accent : AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 6),
        if (unlocked == count)
          Icon(Icons.check_circle_rounded, color: accent, size: 16)
        else
          Icon(
            Icons.radio_button_unchecked_rounded,
            color: AppColors.outlineVariant.withValues(alpha: 0.5),
            size: 16,
          ),
      ],
    );
  }
}
