import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';

class ProfileOnOffChip extends StatelessWidget {
  const ProfileOnOffChip({super.key, required this.isOn});

  final bool isOn;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isOn
            ? AppColors.tertiary.withValues(alpha: 0.12)
            : AppColors.outlineVariant.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isOn ? 'On' : 'Off',
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isOn ? AppColors.tertiary : AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}
