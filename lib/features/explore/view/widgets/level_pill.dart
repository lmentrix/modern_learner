import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/features/explore/domain/entities/learning_subject.dart';

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
    final color = _color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        level.label,
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
