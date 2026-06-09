import 'package:flutter/material.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/explore/domain/entities/learning_subject.dart';
import 'package:modern_learner_production/features/explore/view/widgets/subject_stat_card.dart';

class SubjectStatsRow extends StatelessWidget {
  const SubjectStatsRow({
    super.key,
    required this.subject,
    required this.accent,
  });

  final LearningSubject subject;
  final Color accent;

  int get _totalMinutes =>
      subject.topics.fold(0, (sum, t) => sum + t.estimatedMinutes);

  int get _beginnerCount => subject.topics
      .where((t) => t.difficulty == DifficultyLevel.beginner)
      .length;

  int get _advancedCount => subject.topics
      .where((t) => t.difficulty == DifficultyLevel.advanced)
      .length;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;

    // On very small screens, stack as 2×2 grid instead of 1×4 row
    if (w < 360) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: SubjectStatCard(
                  label: 'TOPICS',
                  value: '${subject.topicCount}',
                  accent: accent,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: SubjectStatCard(
                  label: 'EST. TIME',
                  value: '${_totalMinutes ~/ 60}h ${_totalMinutes % 60}m',
                  accent: AppColors.secondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SubjectStatCard(
                  label: 'BEGINNER',
                  value: '$_beginnerCount',
                  accent: AppColors.tertiary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SubjectStatCard(
                  label: 'ADVANCED',
                  value: '$_advancedCount',
                  accent: const Color(0xFFFF8A65),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: SubjectStatCard(
            label: 'TOPICS',
            value: '${subject.topicCount}',
            accent: accent,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: SubjectStatCard(
            label: 'EST. TIME',
            value: '${_totalMinutes ~/ 60}h ${_totalMinutes % 60}m',
            accent: AppColors.secondary,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: SubjectStatCard(
            label: 'BEGINNER',
            value: '$_beginnerCount',
            accent: AppColors.tertiary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SubjectStatCard(
            label: 'ADVANCED',
            value: '$_advancedCount',
            accent: const Color(0xFFFF8A65),
          ),
        ),
      ],
    );
  }
}
