import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/explore/domain/entities/learning_subject.dart';

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

  int get _beginnerCount =>
      subject.topics.where((t) => t.difficulty == DifficultyLevel.beginner).length;

  int get _advancedCount =>
      subject.topics.where((t) => t.difficulty == DifficultyLevel.advanced).length;

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
              const SizedBox(width: 10),
              Expanded(
                child: SubjectStatCard(
                  label: 'EST. TIME',
                  value: '${_totalMinutes ~/ 60}h ${_totalMinutes % 60}m',
                  accent: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
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
        const SizedBox(width: 10),
        Expanded(
          child: SubjectStatCard(
            label: 'EST. TIME',
            value: '${_totalMinutes ~/ 60}h ${_totalMinutes % 60}m',
            accent: AppColors.secondary,
          ),
        ),
        const SizedBox(width: 10),
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

class SubjectStatCard extends StatelessWidget {
  const SubjectStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final valueSize = w < 380 ? 15.0 : w >= 600 ? 20.0 : 18.0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: valueSize,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}
