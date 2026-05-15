import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/home/data/achievement_entity.dart';

const achievementCategoryOrder = [
  'Streaks',
  'Experience',
  'Learning',
  'Mastery',
  'Dedication',
  'Special',
];

const achievementCategoryMeta = {
  'All': ('🏅', AppColors.primary),
  'Streaks': ('🔥', Color(0xFFFF9500)),
  'Experience': ('⭐', Color(0xFFFFD700)),
  'Learning': ('📚', AppColors.primary),
  'Mastery': ('💎', Color(0xFF4FC3F7)),
  'Dedication': ('📅', Color(0xFF26C6DA)),
  'Special': ('🚀', Color(0xFF7E51FF)),
};

enum AchievementStatus { initial, loading, loaded, error }

class AchievementState extends Equatable {
  const AchievementState({
    this.status = AchievementStatus.initial,
    this.achievements = const [],
    this.filtered = const [],
    this.selectedFilter = 'all',
    this.newlyUnlocked = const [],
  });

  final AchievementStatus status;
  final List<AchievementEntity> achievements;
  final List<AchievementEntity> filtered;
  final String selectedFilter;
  final List<AchievementEntity> newlyUnlocked;

  int get unlockedCount =>
      achievements.where((achievement) => !achievement.isLocked).length;

  Map<String, List<AchievementEntity>> get groupedFiltered {
    final groups = {
      for (final category in achievementCategoryOrder)
        category: <AchievementEntity>[],
    };
    for (final achievement in filtered) {
      groups[achievement.category]?.add(achievement);
    }
    return groups;
  }

  AchievementState copyWith({
    AchievementStatus? status,
    List<AchievementEntity>? achievements,
    List<AchievementEntity>? filtered,
    String? selectedFilter,
    List<AchievementEntity>? newlyUnlocked,
  }) {
    return AchievementState(
      status: status ?? this.status,
      achievements: achievements ?? this.achievements,
      filtered: filtered ?? this.filtered,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      newlyUnlocked: newlyUnlocked ?? this.newlyUnlocked,
    );
  }

  @override
  List<Object?> get props => [
    status,
    achievements,
    filtered,
    selectedFilter,
    newlyUnlocked,
  ];
}

AchievementState buildAchievementState({String selectedFilter = 'all'}) {
  final achievements = _achievementTemplates
      .map(_hydrateAchievement)
      .toList(growable: false);
  return AchievementState(
    status: AchievementStatus.loaded,
    achievements: achievements,
    filtered: filterAchievements(achievements, selectedFilter),
    selectedFilter: selectedFilter,
  );
}

AchievementState updateAchievementFilter(
  AchievementState state,
  String filter,
) {
  return state.copyWith(
    selectedFilter: filter,
    filtered: filterAchievements(state.achievements, filter),
  );
}

List<AchievementEntity> filterAchievements(
  List<AchievementEntity> achievements,
  String filter,
) {
  if (filter == 'all') {
    return List<AchievementEntity>.from(achievements);
  }
  if (filter == 'unlocked') {
    return achievements.where((achievement) => !achievement.isLocked).toList();
  }
  if (filter == 'locked') {
    return achievements.where((achievement) => achievement.isLocked).toList();
  }
  if (achievementCategoryOrder.contains(filter)) {
    return achievements
        .where((achievement) => achievement.category == filter)
        .toList();
  }
  return List<AchievementEntity>.from(achievements);
}

AchievementEntity _hydrateAchievement(AchievementEntity template) {
  final progress = _achievementProgress[template.id] ?? 0;
  return template.copyWith(
    currentLevel: _levelFor(progress, template.levelThresholds),
    currentProgress: progress,
  );
}

int _levelFor(int value, List<int> thresholds) {
  var level = 0;
  for (var index = 0; index < thresholds.length; index++) {
    if (value >= thresholds[index]) {
      level = index + 1;
    }
  }
  return level;
}

const _achievementProgress = <String, int>{
  'streak_master': 18,
  'xp_collector': 2400,
  'level_legend': 8,
  'lesson_warrior': 16,
  'daily_champion': 4,
  'chapter_ace': 5,
  'night_owl': 2,
  'pioneer': 8,
  'gem_hoarder': 180,
  'early_bird': 0,
  'study_days': 22,
  'weekly_warrior': 9,
};

const _achievementTemplates = <AchievementEntity>[
  AchievementEntity(
    id: 'streak_master',
    emoji: '🔥',
    title: 'Streak Guardian',
    description:
        'Maintain daily learning streaks without missing a single day. The longer you go, the higher your tier!',
    color: Color(0xFFFF9500),
    category: 'Streaks',
    levelThresholds: [3, 7, 14, 30, 100],
    levelRequirements: [
      '3-day streak',
      '7-day streak',
      '14-day streak',
      '30-day streak',
      '100-day streak',
    ],
  ),
  AchievementEntity(
    id: 'xp_collector',
    emoji: '⭐',
    title: 'XP Collector',
    description:
        'Accumulate XP by completing lessons, chapters, and challenges. More XP means a higher tier!',
    color: Color(0xFFFFC107),
    category: 'Experience',
    levelThresholds: [100, 500, 2000, 10000, 50000],
    levelRequirements: [
      '100 XP',
      '500 XP',
      '2,000 XP',
      '10,000 XP',
      '50,000 XP',
    ],
  ),
  AchievementEntity(
    id: 'level_legend',
    emoji: '🌟',
    title: 'Level Legend',
    description:
        'Rise through the player levels by completing more and more content. Each new tier represents a new milestone!',
    color: AppColors.tertiary,
    category: 'Experience',
    levelThresholds: [2, 5, 10, 20, 50],
    levelRequirements: [
      'Level 2',
      'Level 5',
      'Level 10',
      'Level 20',
      'Level 50',
    ],
  ),
  AchievementEntity(
    id: 'lesson_warrior',
    emoji: '📚',
    title: 'Lesson Warrior',
    description:
        'Complete lessons across all your courses. Every lesson brings you one step closer to the Diamond tier!',
    color: AppColors.primary,
    category: 'Learning',
    levelThresholds: [1, 10, 25, 50, 100],
    levelRequirements: [
      '1 lesson',
      '10 lessons',
      '25 lessons',
      '50 lessons',
      '100 lessons',
    ],
  ),
  AchievementEntity(
    id: 'daily_champion',
    emoji: '🎯',
    title: 'Daily Champion',
    description:
        'Prove your dedication by completing multiple lessons in a single day. Your best single-day count determines your tier!',
    color: Color(0xFF00DC82),
    category: 'Learning',
    levelThresholds: [2, 3, 5, 7, 10],
    levelRequirements: [
      '2 lessons/day',
      '3 lessons/day',
      '5 lessons/day',
      '7 lessons/day',
      '10 lessons/day',
    ],
  ),
  AchievementEntity(
    id: 'chapter_ace',
    emoji: '🏆',
    title: 'Chapter Ace',
    description:
        'Fully complete chapters across your learning roadmaps. Each tier represents mastery of more complete chapters!',
    color: Color(0xFFFFD700),
    category: 'Learning',
    levelThresholds: [1, 3, 7, 15, 30],
    levelRequirements: [
      '1 chapter',
      '3 chapters',
      '7 chapters',
      '15 chapters',
      '30 chapters',
    ],
  ),
  AchievementEntity(
    id: 'night_owl',
    emoji: '🦉',
    title: 'Night Owl',
    description:
        'Study in the quiet hours between midnight and 5 AM. More midnight sessions means a higher tier!',
    color: Color(0xFF6C63FF),
    category: 'Special',
    levelThresholds: [1, 3, 7, 15, 30],
    levelRequirements: [
      '1 midnight session',
      '3 midnight sessions',
      '7 midnight sessions',
      '15 midnight sessions',
      '30 midnight sessions',
    ],
  ),
  AchievementEntity(
    id: 'pioneer',
    emoji: '🚀',
    title: 'Pioneer',
    description:
        'Progress through the game levels to unlock higher Pioneer tiers. The highest tier proves you have been here from the start!',
    color: Color(0xFF7E51FF),
    category: 'Special',
    levelThresholds: [1, 2, 5, 10, 20],
    levelRequirements: [
      'Level 1',
      'Level 2',
      'Level 5',
      'Level 10',
      'Level 20',
    ],
  ),
  AchievementEntity(
    id: 'gem_hoarder',
    emoji: '💎',
    title: 'Gem Hoarder',
    description:
        'Collect gems by completing lessons and chapters. Stack up your treasure to reach the Diamond tier!',
    color: Color(0xFF4FC3F7),
    category: 'Mastery',
    levelThresholds: [10, 50, 200, 750, 2000],
    levelRequirements: [
      '10 gems',
      '50 gems',
      '200 gems',
      '750 gems',
      '2,000 gems',
    ],
  ),
  AchievementEntity(
    id: 'early_bird',
    emoji: '🌅',
    title: 'Early Bird',
    description:
        'Complete lessons between 5 AM and 9 AM. Rise with the sun and prove your morning dedication!',
    color: Color(0xFFFFB347),
    category: 'Mastery',
    levelThresholds: [1, 3, 7, 14, 30],
    levelRequirements: [
      '1 early session',
      '3 early sessions',
      '7 early sessions',
      '14 early sessions',
      '30 early sessions',
    ],
  ),
  AchievementEntity(
    id: 'study_days',
    emoji: '📅',
    title: 'Consistent Scholar',
    description:
        'Show up for learning on as many different days as possible. Consistency beats intensity and builds a real habit!',
    color: Color(0xFF26C6DA),
    category: 'Dedication',
    levelThresholds: [3, 7, 14, 30, 100],
    levelRequirements: [
      '3 study days',
      '7 study days',
      '14 study days',
      '30 study days',
      '100 study days',
    ],
  ),
  AchievementEntity(
    id: 'weekly_warrior',
    emoji: '🗓️',
    title: 'Weekly Warrior',
    description:
        'Maximise your learning output in any rolling 7-day window. Push your weekly best to claim the Diamond tier!',
    color: Color(0xFFEC407A),
    category: 'Dedication',
    levelThresholds: [5, 7, 10, 15, 20],
    levelRequirements: [
      '5 lessons in a week',
      '7 lessons in a week',
      '10 lessons in a week',
      '15 lessons in a week',
      '20 lessons in a week',
    ],
  ),
];
