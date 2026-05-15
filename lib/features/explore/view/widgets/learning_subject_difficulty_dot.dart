import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/features/explore/domain/entities/learning_subject.dart';

class LearningSubjectDifficultyDot extends StatelessWidget {
  const LearningSubjectDifficultyDot({
    super.key,
    required this.level,
    required this.accent,
  });

  final DifficultyLevel level;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        level.label,
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: accent,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
