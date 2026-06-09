import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/l10n/app_text.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';

class ProfileAppearanceOption extends StatelessWidget {
  const ProfileAppearanceOption({
    super.key,
    required this.label,
    required this.emoji,
    required this.isSelected,
    required this.color,
    this.onTap,
  });

  final String label;
  final String emoji;
  final bool isSelected;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : AppColors.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? color.withValues(alpha: 0.45)
                : AppColors.outlineVariant.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: TextStyle(fontSize: 22)),
            SizedBox(height: 6),
            Text(
              context.tr(label),
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? color : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
