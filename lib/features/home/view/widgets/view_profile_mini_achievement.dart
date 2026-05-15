import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';

class ViewProfileMiniAchievement extends StatelessWidget {
  const ViewProfileMiniAchievement({
    super.key,
    required this.emoji,
    required this.title,
    required this.color,
    this.isLocked = false,
  });

  final String emoji;
  final String title;
  final Color color;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isLocked
            ? AppColors.surfaceContainerHighest
            : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isLocked
              ? AppColors.outlineVariant.withValues(alpha: 0.15)
              : color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(isLocked ? '🔒' : emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isLocked
                  ? AppColors.onSurfaceVariant
                  : AppColors.onSurface,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
