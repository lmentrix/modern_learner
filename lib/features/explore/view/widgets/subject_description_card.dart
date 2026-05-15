import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/explore/domain/entities/learning_subject.dart';

class SubjectDescriptionCard extends StatelessWidget {
  const SubjectDescriptionCard({
    super.key,
    required this.subject,
    required this.accent,
  });

  final LearningSubject subject;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.14),
            AppColors.surfaceContainerLow,
          ],
        ),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ABOUT THIS SUBJECT',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.3,
              color: accent,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subject.description,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.65,
              color: AppColors.onSurface.withValues(alpha: 0.88),
            ),
          ),
        ],
      ),
    );
  }
}
