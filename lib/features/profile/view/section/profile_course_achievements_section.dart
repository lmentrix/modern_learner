import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/di/injection.dart';
import 'package:modern_learner_production/core/models/progress_course_selection.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/home/data/achievement_entity.dart';
import 'package:modern_learner_production/features/home/data/home_achievement_data.dart';
import 'package:modern_learner_production/features/profile/view/bloc/profile_achievement_bloc.dart';
import 'package:modern_learner_production/features/progress/service/course_xp_service.dart';

class ProfileCourseAchievementsSection extends StatefulWidget {
  const ProfileCourseAchievementsSection({
    super.key,
    required this.course,
    required this.onAchievementTap,
  });

  final ProgressCourseSelection course;
  final ValueChanged<AchievementEntity> onAchievementTap;

  @override
  State<ProfileCourseAchievementsSection> createState() =>
      _ProfileCourseAchievementsSectionState();
}

class _ProfileCourseAchievementsSectionState
    extends State<ProfileCourseAchievementsSection> {
  late final ProfileAchievementBloc _bloc;
  late final String _courseKey;

  @override
  void initState() {
    super.initState();
    _courseKey = progressCourseXpKey(widget.course);
    _bloc = getIt<ProfileAchievementBloc>();
    _bloc.add(ProfileAchievementLoadRequested(courseId: _courseKey));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<CourseXpData>(
      valueListenable: CourseXpService.instance.notifierFor(_courseKey),
      builder: (context, xpData, _) {
        return BlocProvider.value(
          value: _bloc,
          child: BlocBuilder<ProfileAchievementBloc, AchievementState>(
            builder: (context, state) {
              final achievements = _achievementsForProgress(
                state.achievements,
                xpData,
              );
              final unlocked = achievements
                  .where((achievement) => !achievement.isLocked)
                  .toList(growable: false);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CourseAchievementHeader(
                    title: widget.course.title,
                    xp: xpData.exerciseXp,
                    completedCount: xpData.exercisesCompleted,
                    unlockedCount: unlocked.length,
                    totalCount: achievements.length,
                  ),
                  const SizedBox(height: 10),
                  if (state.status == AchievementStatus.initial ||
                      state.status == AchievementStatus.loading)
                    const _MiniAchievementShimmer()
                  else if (unlocked.isEmpty)
                    const _MiniAchievementEmptyState()
                  else
                    _MiniAchievementBadgeRow(
                      achievements: unlocked,
                      onTap: widget.onAchievementTap,
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  List<AchievementEntity> _achievementsForProgress(
    List<AchievementEntity> achievements,
    CourseXpData xpData,
  ) {
    return achievements
        .map((achievement) {
          final progress = switch (achievement.id) {
            final id when id.endsWith('_chapter_starter') =>
              (xpData.chaptersUnlocked - 1).clamp(0, 1000000),
            final id when id.endsWith('_exercise_champion') =>
              xpData.exercisesCompleted,
            final id when id.endsWith('_dedicated_learner') =>
              xpData.exercisesCompleted,
            _ => achievement.currentProgress,
          };

          return achievement.copyWith(
            currentProgress: progress,
            currentLevel: _levelFor(progress, achievement.levelThresholds),
          );
        })
        .toList(growable: false);
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

class _CourseAchievementHeader extends StatelessWidget {
  const _CourseAchievementHeader({
    required this.title,
    required this.xp,
    required this.completedCount,
    required this.unlockedCount,
    required this.totalCount,
  });

  final String title;
  final int xp;
  final int completedCount;
  final int unlockedCount;
  final int totalCount;

  static const List<int> _thresholds = [0, 500, 1200, 2200, 3500, 5000, 7000];

  int _levelForXp(int xp) {
    var level = 1;
    for (var index = 1; index < _thresholds.length; index++) {
      if (xp >= _thresholds[index]) {
        level = index + 1;
      } else {
        break;
      }
    }
    return level.clamp(1, _thresholds.length);
  }

  @override
  Widget build(BuildContext context) {
    final level = _levelForXp(xp);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 10),
            _MetricPill(label: '$xp XP', color: AppColors.primary),
          ],
        ),
        const SizedBox(height: 7),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _MetricPill(label: 'LVL $level', color: AppColors.secondary),
            _MetricPill(
              label: '$completedCount done',
              color: AppColors.tertiary,
            ),
            if (totalCount > 0)
              _MetricPill(
                label: '$unlockedCount/$totalCount badges',
                color: Colors.teal,
              ),
          ],
        ),
      ],
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.9, end: 1),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.13),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _MiniAchievementBadgeRow extends StatelessWidget {
  const _MiniAchievementBadgeRow({
    required this.achievements,
    required this.onTap,
  });

  final List<AchievementEntity> achievements;
  final ValueChanged<AchievementEntity> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 78,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: achievements.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final achievement = achievements[index];
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 260 + index * 60),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Opacity(
                opacity: value.clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(0, 10 * (1 - value)),
                  child: Transform.scale(
                    scale: 0.9 + (0.1 * value),
                    child: child,
                  ),
                ),
              );
            },
            child: _MiniAchievementBadge(
              achievement: achievement,
              onTap: () => onTap(achievement),
            ),
          );
        },
      ),
    );
  }
}

class _MiniAchievementBadge extends StatelessWidget {
  const _MiniAchievementBadge({required this.achievement, required this.onTap});

  final AchievementEntity achievement;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tierColor = AchievementEntity.tierColor(achievement.currentLevel);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 66,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          color: tierColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: tierColor.withValues(alpha: 0.32)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_iconFor(achievement), size: 22, color: tierColor),
            const SizedBox(height: 5),
            Text(
              AchievementEntity.tierRoman(achievement.currentLevel),
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: tierColor,
                height: 1,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              achievement.title,
              style: GoogleFonts.inter(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurfaceVariant,
                height: 1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(AchievementEntity achievement) {
    if (achievement.id.contains('chapter')) return Icons.menu_book_rounded;
    if (achievement.id.contains('exercise')) {
      return Icons.fitness_center_rounded;
    }
    if (achievement.id.contains('dedicated')) return Icons.school_rounded;
    return Icons.emoji_events_rounded;
  }
}

class _MiniAchievementShimmer extends StatelessWidget {
  const _MiniAchievementShimmer();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 78,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, _) => Container(
          width: 66,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh.withValues(alpha: 0.42),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class _MiniAchievementEmptyState extends StatelessWidget {
  const _MiniAchievementEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('馃弲', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Text(
            'No badges yet',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
