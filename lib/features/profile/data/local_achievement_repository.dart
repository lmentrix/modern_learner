import 'package:flutter/material.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/home/data/achievement_entity.dart';
import 'package:modern_learner_production/features/profile/data/achievement_repository.dart';

class LocalAchievementRepository implements AchievementRepository {
  const LocalAchievementRepository();

  @override
  Future<List<AchievementEntity>> getAchievements({String? courseId}) async {
    final progress = await getProgress(courseId: courseId);
    final templates = _templatesFor(courseId);
    return templates.map((t) {
      final p = progress[t.id] ?? 0;
      return t.copyWith(
        currentLevel: _levelFor(p, t.levelThresholds),
        currentProgress: p,
      );
    }).toList(growable: false);
  }

  @override
  Future<Map<String, int>> getProgress({String? courseId}) async {
    if (courseId != null && _courseProgress.containsKey(courseId)) {
      return Map.unmodifiable(_courseProgress[courseId]!);
    }
    return Map.unmodifiable(_globalProgress);
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  List<AchievementEntity> _templatesFor(String? courseId) {
    if (courseId != null && _courseTemplates.containsKey(courseId)) {
      return _courseTemplates[courseId]!;
    }
    return _globalTemplates;
  }

  static int _levelFor(int value, List<int> thresholds) {
    var level = 0;
    for (var i = 0; i < thresholds.length; i++) {
      if (value >= thresholds[i]) level = i + 1;
    }
    return level;
  }
}

// ---------------------------------------------------------------------------
// Global (cross-course) achievement data
// ---------------------------------------------------------------------------

const _globalProgress = <String, int>{
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

const _globalTemplates = <AchievementEntity>[
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
    levelRequirements: ['100 XP', '500 XP', '2,000 XP', '10,000 XP', '50,000 XP'],
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
    levelRequirements: ['Level 2', 'Level 5', 'Level 10', 'Level 20', 'Level 50'],
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
        'Prove your dedication by completing multiple lessons in a single day.',
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
    description: 'Fully complete chapters across your learning roadmaps.',
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
    description: 'Study in the quiet hours between midnight and 5 AM.',
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
    description: 'Progress through the game levels to unlock higher Pioneer tiers.',
    color: Color(0xFF7E51FF),
    category: 'Special',
    levelThresholds: [1, 2, 5, 10, 20],
    levelRequirements: ['Level 1', 'Level 2', 'Level 5', 'Level 10', 'Level 20'],
  ),
  AchievementEntity(
    id: 'gem_hoarder',
    emoji: '💎',
    title: 'Gem Hoarder',
    description: 'Collect gems by completing lessons and chapters.',
    color: Color(0xFF4FC3F7),
    category: 'Mastery',
    levelThresholds: [10, 50, 200, 750, 2000],
    levelRequirements: ['10 gems', '50 gems', '200 gems', '750 gems', '2,000 gems'],
  ),
  AchievementEntity(
    id: 'early_bird',
    emoji: '🌅',
    title: 'Early Bird',
    description: 'Complete lessons between 5 AM and 9 AM.',
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
    description: 'Show up for learning on as many different days as possible.',
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
    description: 'Maximise your learning output in any rolling 7-day window.',
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

// ---------------------------------------------------------------------------
// Per-course achievement templates & progress
// Extend this map to add achievements specific to a course.
// ---------------------------------------------------------------------------

// Example: course-specific achievements for 'flutter_basics'
const _courseTemplates = <String, List<AchievementEntity>>{
  'flutter_basics': [
    AchievementEntity(
      id: 'flutter_basics_widget_builder',
      emoji: '🧱',
      title: 'Widget Builder',
      description: 'Complete widget-focused lessons in Flutter Basics.',
      color: Color(0xFF54C5F8),
      category: 'Learning',
      levelThresholds: [1, 5, 10, 20, 40],
      levelRequirements: [
        '1 widget lesson',
        '5 widget lessons',
        '10 widget lessons',
        '20 widget lessons',
        '40 widget lessons',
      ],
    ),
    AchievementEntity(
      id: 'flutter_basics_state_master',
      emoji: '⚡',
      title: 'State Master',
      description: 'Master state management lessons in Flutter Basics.',
      color: Color(0xFF7E51FF),
      category: 'Mastery',
      levelThresholds: [1, 3, 6, 12, 20],
      levelRequirements: [
        '1 state lesson',
        '3 state lessons',
        '6 state lessons',
        '12 state lessons',
        '20 state lessons',
      ],
    ),
  ],
};

const _courseProgress = <String, Map<String, int>>{
  'flutter_basics': {
    'flutter_basics_widget_builder': 6,
    'flutter_basics_state_master': 3,
  },
};
