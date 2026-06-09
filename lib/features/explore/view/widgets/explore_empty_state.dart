import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/l10n/app_text.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';

class ExploreEmptyState extends StatelessWidget {
  const ExploreEmptyState({
    super.key,
    required this.hasSearchQuery,
    required this.onClearFilters,
  });

  final bool hasSearchQuery;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          const Text('🔎', style: TextStyle(fontSize: 32)),
          SizedBox(height: 14),
          Text(
            hasSearchQuery
                ? context.tr('No matching collections')
                : context.tr('No collections available'),
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr(
              'Try another category or clear the current search to see more research fields.',
            ),
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 1.5,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onClearFilters,
            child: Text(context.tr('Clear filters')),
          ),
        ],
      ),
    );
  }
}
