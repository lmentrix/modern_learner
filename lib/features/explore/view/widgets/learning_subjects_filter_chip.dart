import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';

class LearningSubjectsFilterChip extends StatelessWidget {
  const LearningSubjectsFilterChip({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 160),
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          gradient: isActive ? AppColors.primaryGradient : null,
          color: isActive
              ? null
              : AppColors.surfaceContainerHighest.withValues(alpha: 0.52),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isActive
                ? Colors.transparent
                : AppColors.outlineVariant.withValues(alpha: 0.18),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isActive ? Color(0xFF1A1028) : AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
