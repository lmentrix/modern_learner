import 'package:flutter/material.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/progress/data/progress_page_data.dart';
import 'package:modern_learner_production/features/progress/view/widgets/progress_section_heading.dart';
import 'package:modern_learner_production/features/progress/view/widgets/progress_xp_bar.dart';

class ProgressHeaderSection extends StatelessWidget {
  const ProgressHeaderSection({super.key, required this.data});

  final ProgressPageData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProgressSectionHeading(
          eyebrow: 'XP',
          title: 'Your learning rank',
          subtitle:
              'Every lesson mastered, streak held, and hour invested converts into XP and pushes your rank forward.',
          accentColor: AppColors.secondary,
        ),
        const SizedBox(height: 18),
        ProgressXpBar(
          snapshot: data.snapshot,
          courseTitle: data.course.title,
          moduleSteps: data.moduleSteps,
        ),
      ],
    );
  }
}
