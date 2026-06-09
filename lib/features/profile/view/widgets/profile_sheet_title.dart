import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/l10n/app_text.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';

class ProfileSheetTitle extends StatelessWidget {
  const ProfileSheetTitle({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
  });

  final String title;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(width: 12),
        Text(
          context.tr(title),
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}
