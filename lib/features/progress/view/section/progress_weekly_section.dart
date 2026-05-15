import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/progress/data/progress_page_constants.dart';
import 'package:modern_learner_production/features/progress/data/progress_page_data.dart';
import 'package:modern_learner_production/features/progress/view/widgets/progress_section_heading.dart';
import 'package:modern_learner_production/features/progress/view/widgets/progress_week_bar.dart';

class ProgressWeeklySection extends StatelessWidget {
  const ProgressWeeklySection({super.key, required this.data});

  final ProgressPageData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProgressSectionHeading(
          eyebrow: 'RHYTHM',
          title: 'A week that actually looks alive',
          subtitle:
              'Daily minutes stay uneven on purpose. The goal is a sustainable cadence, not seven identical sessions.',
        ),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(
              ProgressPageConstants.cardRadius,
            ),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.16),
            ),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: data.weekDays
                    .map(
                      (day) => Expanded(
                        child: Center(
                          child: ProgressWeekBar(
                            day: day,
                            accentColor: data.snapshot.accentColor,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  '${data.snapshot.weeklyMinutes} minutes logged this week. '
                  'Your strongest days cluster around the middle of the week, which is a good sign that the routine is sticking.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
