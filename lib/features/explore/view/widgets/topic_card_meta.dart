import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/explore/domain/entities/learning_subject.dart';
import 'package:modern_learner_production/features/explore/view/widgets/level_pill.dart';

class TopicCardMeta extends StatelessWidget {
  const TopicCardMeta({super.key, required this.topic, required this.accent});

  final LearningTopic topic;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        LevelPill(level: topic.difficulty, accent: accent),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(
              Icons.schedule_rounded,
              size: 12,
              color: AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: 3),
            Text(
              '${topic.estimatedMinutes}m',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
