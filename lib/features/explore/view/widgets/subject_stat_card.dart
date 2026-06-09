import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';

class SubjectStatCard extends StatelessWidget {
  const SubjectStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final valueSize = w < 380
        ? 15.0
        : w >= 600
        ? 20.0
        : 18.0;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: valueSize,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}
