import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/models/progress_course_selection.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/home/data/achievement_entity.dart';
import 'package:modern_learner_production/features/home/data/home_achievement_data.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_achievement_badge.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_achievement_empty_state.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_achievement_shimmer.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_section_label.dart';
import 'package:modern_learner_production/features/progress/service/course_xp_service.dart';

class ProfileAchievementsSection extends StatelessWidget {
  const ProfileAchievementsSection({
    super.key,
    required this.achievementState,
    required this.courses,
    required this.onViewAllTap,
    required this.onAchievementTap,
  });

  final AchievementState achievementState;
  final List<ProgressCourseSelection> courses;
  final VoidCallback onViewAllTap;
  final ValueChanged<AchievementEntity> onAchievementTap;

  @override
  Widget build(BuildContext context) {
    final achievements = _courseAchievements();
    final unlockedCount = achievements
        .where((achievement) => !achievement.isLocked)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const ProfileSectionLabel(text: 'ACHIEVEMENTS'),
            if (achievements.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$unlockedCount/${achievements.length}',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
            const Spacer(),
            GestureDetector(
              onTap: onViewAllTap,
              child: Text(
                'View all',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (achievementState.status == AchievementStatus.initial ||
            achievementState.status == AchievementStatus.loading)
          const ProfileAchievementShimmer()
        else if (achievements.isEmpty)
          const ProfileAchievementEmptyState()
        else
          SizedBox(
            height: 148,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: achievements.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final achievement = achievements[index];
                return GestureDetector(
                  onTap: () => onAchievementTap(achievement),
                  child: ProfileAchievementBadge(achievement: achievement),
                );
              },
            ),
          ),
      ],
    );
  }

  List<AchievementEntity> _courseAchievements() {
    return [
      for (final course in courses)
        ..._templatesForCourse(course).map((achievement) {
          final progress = _progressFor(course, achievement.id);
          return achievement.copyWith(
            currentProgress: progress,
            currentLevel: _levelFor(progress, achievement.levelThresholds),
          );
        }),
    ];
  }

  List<AchievementEntity> _templatesForCourse(ProgressCourseSelection course) {
    final courseKey = progressCourseXpKey(course);
    final shortTitle = course.title.trim().isEmpty ? 'Course' : course.title;

    return [
      AchievementEntity(
        id: '$courseKey::chapter_starter',
        emoji: 'C',
        title: '$shortTitle Chapters',
        description: 'Complete chapters in $shortTitle to climb the tiers.',
        color: const Color(0xFF0F766E),
        category: 'Learning',
        levelThresholds: const [1, 3, 5, 10, 20],
        levelRequirements: const [
          '1 chapter',
          '3 chapters',
          '5 chapters',
          '10 chapters',
          '20 chapters',
        ],
      ),
      AchievementEntity(
        id: '$courseKey::exercise_champion',
        emoji: 'E',
        title: '$shortTitle Exercises',
        description: 'Finish exercises in $shortTitle to prove your mastery.',
        color: const Color(0xFF7E51FF),
        category: 'Learning',
        levelThresholds: const [1, 5, 15, 30, 60],
        levelRequirements: const [
          '1 exercise',
          '5 exercises',
          '15 exercises',
          '30 exercises',
          '60 exercises',
        ],
      ),
      AchievementEntity(
        id: '$courseKey::dedicated_learner',
        emoji: 'D',
        title: '$shortTitle Dedication',
        description: 'Keep returning to $shortTitle to build consistency.',
        color: const Color(0xFF26C6DA),
        category: 'Dedication',
        levelThresholds: const [1, 3, 7, 14, 30],
        levelRequirements: const [
          '1 session',
          '3 sessions',
          '7 sessions',
          '14 sessions',
          '30 sessions',
        ],
      ),
    ];
  }

  int _progressFor(ProgressCourseSelection course, String achievementId) {
    final data = CourseXpService.instance.dataFor(progressCourseXpKey(course));
    if (achievementId.endsWith('::chapter_starter')) {
      return (data.chaptersUnlocked - 1).clamp(0, 1000000);
    }
    if (achievementId.endsWith('::exercise_champion')) {
      return data.exercisesCompleted;
    }
    if (achievementId.endsWith('::dedicated_learner')) {
      return data.exercisesCompleted;
    }
    return 0;
  }

  int _levelFor(int progress, List<int> thresholds) {
    var level = 0;
    for (var index = 0; index < thresholds.length; index++) {
      if (progress >= thresholds[index]) {
        level = index + 1;
      }
    }
    return level.clamp(0, thresholds.length);
  }
}
