import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';

class ExploreHeader extends StatelessWidget {
  const ExploreHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final hPad = w < 380 ? 16.0 : w >= 600 ? 28.0 : 20.0;
    final titleSize = w < 360 ? 24.0 : w < 380 ? 28.0 : w >= 600 ? 38.0 : 32.0;
    final bodySize = w < 360 ? 12.0 : w >= 600 ? 15.0 : 14.0;

    return Container(
      padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0E1020), AppColors.surface],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.tertiary.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.tertiary.withValues(alpha: 0.28),
              ),
            ),
            child: Text(
              'LIVE FROM OPENALEX',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: AppColors.tertiary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Browse research collections',
            style: GoogleFonts.spaceGrotesk(
              fontSize: titleSize,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Live subject feeds from OpenAlex with search and category filtering for language, school, and research learning.',
            style: GoogleFonts.inter(
              fontSize: bodySize,
              height: 1.6,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
