import 'package:flutter/material.dart';

import 'package:modern_learner_production/features/progress/data/progress_page_data.dart';
import 'package:modern_learner_production/features/progress/view/widgets/progress_module_tile.dart';
import 'package:modern_learner_production/features/progress/view/widgets/progress_section_heading.dart';

class ProgressJourneySection extends StatelessWidget {
  const ProgressJourneySection({super.key, required this.data});

  final ProgressPageData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProgressSectionHeading(
          eyebrow: 'ROADMAP',
          title: 'Where the next lift happens',
          subtitle:
              'Each chapter is sequenced to feel directional: what is done, what is active, and what unlocks next.',
        ),
        const SizedBox(height: 18),
        Column(
          children: data.moduleSteps
              .map(
                (step) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ProgressModuleTile(step: step),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
