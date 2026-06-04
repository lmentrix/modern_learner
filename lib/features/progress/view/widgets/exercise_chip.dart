import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/core/l10n/app_text.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';

class ExerciseChip extends StatelessWidget {
  const ExerciseChip(this.label, {super.key, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c != null
            ? c.withValues(alpha: 0.12)
            : AppColors.secondary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: c != null ? Border.all(color: c.withValues(alpha: 0.22)) : null,
      ),
      child: Text(
        context.tr(label),
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: c ?? AppColors.onSurface,
        ),
      ),
    );
  }
}
