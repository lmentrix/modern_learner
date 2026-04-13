import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/explore/service/explore_subject.dart';
import 'package:modern_learner_production/features/explore/utils/explore_utils.dart';

class ExploreMetricsRow extends StatelessWidget {
  const ExploreMetricsRow({
    super.key,
    required this.filteredSubjects,
    required this.allSubjects,
  });

  final List<ExploreSubject> filteredSubjects;
  final List<ExploreSubject> allSubjects;

  @override
  Widget build(BuildContext context) {
    final totalWorks = filteredSubjects.fold<int>(
      0,
      (sum, s) => sum + s.workCount,
    );

    return Row(
      children: [
        Expanded(
          child: ExploreMetricCard(
            label: 'Visible',
            value: '${filteredSubjects.length}',
            hint: 'collections',
            accentColor: AppColors.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ExploreMetricCard(
            label: 'Papers',
            value: formatCount(totalWorks),
            hint: 'papers tracked',
            accentColor: AppColors.secondary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ExploreMetricCard(
            label: 'Source',
            value: 'OpenAlex',
            hint: '${allSubjects.length} feeds',
            accentColor: AppColors.tertiary,
          ),
        ),
      ],
    );
  }
}

class ExploreMetricCard extends StatelessWidget {
  const ExploreMetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.hint,
    required this.accentColor,
  });

  final String label;
  final String value;
  final String hint;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.9,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            hint,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
