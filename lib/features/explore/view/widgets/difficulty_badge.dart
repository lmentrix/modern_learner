import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/features/explore/domain/entities/learning_subject.dart';

/// Large badge used in the hero area — accent-coloured outline pill.
class DifficultyBadge extends StatelessWidget {
  const DifficultyBadge({super.key, required this.level, required this.accent});

  final DifficultyLevel level;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.32)),
      ),
      child: Text(
        level.label.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: accent,
        ),
      ),
    );
  }
}
