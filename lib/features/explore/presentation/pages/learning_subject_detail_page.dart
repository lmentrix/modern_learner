import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/explore/domain/entities/learning_subject.dart';
import 'package:modern_learner_production/features/explore/presentation/widgets/subject_description_card.dart';
import 'package:modern_learner_production/features/explore/presentation/widgets/subject_detail_hero.dart';
import 'package:modern_learner_production/features/explore/presentation/widgets/subject_stats_row.dart';
import 'package:modern_learner_production/features/explore/presentation/widgets/topic_card.dart';

class LearningSubjectDetailPage extends StatelessWidget {
  const LearningSubjectDetailPage({super.key, required this.subject});

  final LearningSubject subject;

  @override
  Widget build(BuildContext context) {
    final accent = subject.accentColor;

    return Material(
      color: AppColors.surface,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: SubjectDetailHero(subject: subject)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SubjectStatsRow(subject: subject, accent: accent),
                  const SizedBox(height: 20),
                  SubjectDescriptionCard(subject: subject, accent: accent),
                  const SizedBox(height: 28),
                  Text(
                    'TOPICS IN THIS SUBJECT',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.6,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${subject.topicCount} curated learning topics',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 60),
            sliver: SliverList.separated(
              itemCount: subject.topics.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) =>
                  TopicCard(topic: subject.topics[index], accent: accent),
            ),
          ),
        ],
      ),
    );
  }
}
