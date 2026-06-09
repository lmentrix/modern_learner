import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/l10n/app_text.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';

class HomeProfileQuickStat extends StatelessWidget {
  const HomeProfileQuickStat({
    super.key,
    required this.emoji,
    required this.label,
    required this.value,
    required this.subtitle,
  });

  final String emoji;
  final String label;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(emoji, style: TextStyle(fontSize: 20)),
          SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
          ),
          SizedBox(height: 2),
          Text(
            context.tr(label),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          Text(
            context.tr(subtitle),
            style: GoogleFonts.inter(
              fontSize: 9,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
