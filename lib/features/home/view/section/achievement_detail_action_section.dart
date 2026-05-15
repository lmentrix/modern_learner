import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/home/data/achievement_entity.dart';

class AchievementDetailActionSection extends StatelessWidget {
  const AchievementDetailActionSection({
    super.key,
    required this.achievement,
    required this.onTap,
  });

  final AchievementEntity achievement;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isLocked = achievement.isLocked;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isLocked
              ? AppColors.surfaceContainerHigh
              : AppColors.primary,
          foregroundColor: isLocked
              ? AppColors.onSurfaceVariant
              : const Color(0xFF1A1028),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isLocked
                ? BorderSide(
                    color: AppColors.outlineVariant.withValues(alpha: 0.2),
                  )
                : BorderSide.none,
          ),
          elevation: 0,
        ),
        child: Text(
          isLocked
              ? 'Start Learning!'
              : achievement.isMaxLevel
              ? 'Legendary! 💎'
              : 'Keep Going!',
          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
