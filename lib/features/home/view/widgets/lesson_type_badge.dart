import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';

class LessonTypeBadge extends StatelessWidget {
  const LessonTypeBadge({super.key, required this.lessonType});

  final String lessonType;

  @override
  Widget build(BuildContext context) {
    final isLanguage = lessonType == 'language';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: (isLanguage ? AppColors.primary : AppColors.secondary)
            .withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: (isLanguage ? AppColors.primary : AppColors.secondary)
              .withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Text(
        isLanguage ? '🎤 Voice' : '📚 School',
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: isLanguage ? AppColors.primary : AppColors.secondary,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
