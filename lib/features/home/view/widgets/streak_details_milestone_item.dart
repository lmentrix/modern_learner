import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';

class StreakDetailsMilestoneItem extends StatelessWidget {
  const StreakDetailsMilestoneItem({
    super.key,
    required this.days,
    required this.label,
    required this.achieved,
    this.isCurrent = false,
  });

  final int days;
  final String label;
  final bool achieved;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: achieved
                  ? AppColors.primary
                  : AppColors.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              achieved ? Icons.check : Icons.lock_outline,
              size: 16,
              color: achieved ? Colors.white : AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: achieved ? FontWeight.w600 : FontWeight.w500,
                    color: achieved
                        ? AppColors.onSurface
                        : AppColors.onSurfaceVariant,
                  ),
                ),
                Text(
                  '$days days',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (isCurrent)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Current',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
