import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';

class AllLessonsEmptyStateSection extends StatelessWidget {
  const AllLessonsEmptyStateSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No lessons yet. Start creating!',
        style: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}
