import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({super.key, required this.text, required this.typeColor});
  final String text;
  final Color typeColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            typeColor.withValues(alpha: 0.1),
            AppColors.surfaceContainerHigh,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: typeColor.withValues(alpha: 0.2)),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 13,
          color: AppColors.onSurface,
          height: 1.65,
        ),
      ),
    );
  }
}
