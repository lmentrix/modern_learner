import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/features/explore/domain/entities/learning_subject.dart';
import 'package:modern_learner_production/features/explore/view/widgets/create_course_preview_row.dart';

class CreateCoursePreviewSection extends StatelessWidget {
  const CreateCoursePreviewSection({
    super.key,
    required this.subject,
    required this.topic,
    required this.accent,
    required this.isTopic,
  });

  final LearningSubject subject;
  final LearningTopic? topic;
  final Color accent;
  final bool isTopic;

  @override
  Widget build(BuildContext context) {
    final mins = topic?.estimatedMinutes ?? 30;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'COURSE SUMMARY',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              color: accent,
            ),
          ),
          const SizedBox(height: 14),
          CreateCoursePreviewRow(
            icon: Icons.auto_stories_rounded,
            label: 'Subject',
            value: subject.name,
            accent: accent,
          ),
          const SizedBox(height: 10),
          CreateCoursePreviewRow(
            icon: Icons.topic_rounded,
            label: isTopic ? 'Topic' : 'Starting topic',
            value:
                topic?.name ??
                (subject.topics.isNotEmpty
                    ? subject.topics.first.name
                    : subject.name),
            accent: accent,
          ),
          const SizedBox(height: 10),
          CreateCoursePreviewRow(
            icon: Icons.schedule_rounded,
            label: 'Estimated time',
            value: '$mins min per session',
            accent: accent,
          ),
          const SizedBox(height: 10),
          CreateCoursePreviewRow(
            icon: Icons.psychology_rounded,
            label: 'Roadmap',
            value: 'AI-generated · adaptive',
            accent: accent,
          ),
        ],
      ),
    );
  }
}
