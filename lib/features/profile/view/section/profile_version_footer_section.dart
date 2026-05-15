import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/profile/data/profile_page_constants.dart';

class ProfileVersionFooterSection extends StatelessWidget {
  const ProfileVersionFooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      ProfilePageConstants.versionLabel,
      style: GoogleFonts.inter(
        fontSize: 11,
        color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
      ),
    );
  }
}
