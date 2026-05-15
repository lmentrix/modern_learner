import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';

class HomeSectionLabel extends StatelessWidget {
  const HomeSectionLabel({
    super.key,
    required this.text,
    this.fontWeight = FontWeight.w700,
    this.letterSpacing = 1.8,
  });

  final String text;
  final FontWeight fontWeight;
  final double letterSpacing;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: fontWeight,
        color: AppColors.onSurfaceVariant,
        letterSpacing: letterSpacing,
      ),
    );
  }
}
