import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';

class AllLessonsHeaderSection extends StatelessWidget {
  const AllLessonsHeaderSection({
    super.key,
    required this.title,
    required this.onBackTap,
  });

  final String title;
  final VoidCallback onBackTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBackTap,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                size: 20,
                color: AppColors.onSurface,
              ),
            ),
          ),
          SizedBox(width: 16),
          Text(
            title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
