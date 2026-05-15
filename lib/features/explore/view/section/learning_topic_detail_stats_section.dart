import 'package:flutter/material.dart';

import 'package:modern_learner_production/features/explore/domain/entities/learning_subject.dart';
import 'package:modern_learner_production/features/explore/view/widgets/learning_topic_detail_stat_chip.dart';

class LearningTopicDetailStatsSection extends StatelessWidget {
  const LearningTopicDetailStatsSection({
    super.key,
    required this.topic,
    required this.accent,
  });

  final LearningTopic topic;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        LearningTopicDetailStatChip(
          icon: Icons.schedule_rounded,
          label: '${topic.estimatedMinutes} min',
          accent: accent,
        ),
        const SizedBox(width: 10),
        LearningTopicDetailStatChip(
          icon: Icons.signal_cellular_alt_rounded,
          label: topic.difficulty.label,
          accent: accent,
        ),
        const SizedBox(width: 10),
        LearningTopicDetailStatChip(
          icon: Icons.auto_stories_rounded,
          label: 'AI-generated roadmap',
          accent: accent,
        ),
      ],
    );
  }
}
