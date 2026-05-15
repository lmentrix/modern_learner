import 'package:flutter/material.dart';

import 'package:modern_learner_production/features/progress/data/progress_page_data.dart';
import 'package:modern_learner_production/features/progress/view/widgets/progress_metric_tile.dart';
import 'package:modern_learner_production/features/progress/view/widgets/progress_section_heading.dart';

class ProgressStatsSection extends StatelessWidget {
  const ProgressStatsSection({super.key, required this.data});

  final ProgressPageData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProgressSectionHeading(
          eyebrow: 'SNAPSHOT',
          title: 'How the streak is holding',
          subtitle:
              'A quick read on momentum, completion, and how much depth this roadmap already has.',
        ),
        const SizedBox(height: 18),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.88,
          ),
          itemCount: data.statItems.length,
          itemBuilder: (context, index) {
            return ProgressMetricTile(item: data.statItems[index]);
          },
        ),
      ],
    );
  }
}
