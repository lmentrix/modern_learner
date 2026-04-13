import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/features/explore/domain/entities/learning_subject.dart';

/// Large badge used in the hero area — accent-coloured outline pill.
class DifficultyBadge extends StatelessWidget {
  const DifficultyBadge({
    super.key,
    required this.level,
    required this.accent,
  });

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

/// Small colour-coded pill used inside topic cards.
class LevelPill extends StatelessWidget {
  const LevelPill({super.key, required this.level, required this.accent});

  final DifficultyLevel level;
  final Color accent;

  Color get _color {
    switch (level) {
      case DifficultyLevel.beginner:
        return const Color(0xFF66BB6A);
      case DifficultyLevel.intermediate:
        return const Color(0xFFFFA726);
      case DifficultyLevel.advanced:
        return const Color(0xFFEF5350);
      case DifficultyLevel.allLevels:
        return accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        level.label,
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: c,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
