import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/theme/app_colors.dart';

class AchievementBadge extends StatelessWidget {
  const AchievementBadge({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    this.isLocked = false,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isLocked
            ? AppColors.surfaceContainerHighest
            : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLocked
              ? AppColors.outlineVariant.withValues(alpha: 0.2)
              : color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isLocked
                  ? AppColors.surfaceContainerHigh
                  : color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                emoji,
                style: TextStyle(
                  fontSize: 26,
                  color: isLocked ? AppColors.onSurfaceVariant : null,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isLocked ? AppColors.onSurfaceVariant : AppColors.onSurface,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 9,
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
