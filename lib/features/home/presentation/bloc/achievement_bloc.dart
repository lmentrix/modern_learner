import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/home/domain/entities/achievement_entity.dart';

part 'achievement_event.dart';
part 'achievement_state.dart';

class AchievementBloc extends Bloc<AchievementEvent, AchievementState> {
  AchievementBloc() : super(const AchievementState()) {
    on<AchievementLoadRequested>(_onLoadRequested);
    on<AchievementFilterChanged>(_onFilterChanged);
  }

  static const List<String> categoryOrder = [
    'Streaks',
    'Experience',
    'Learning',
    'Social',
    'Special',
  ];

  static const List<AchievementEntity> allAchievements = [
    // ── Streaks ──────────────────────────────────────────────────────────────
    AchievementEntity(
      id: 'week_streak',
      emoji: '🔥',
      title: 'Week Streak',
      subtitle: '7 day streak',
      color: Color(0xFFFF9500),
      category: 'Streaks',
      description: 'Maintain a 7-day learning streak without missing a day.',
    ),
    AchievementEntity(
      id: 'fortnight_streak',
      emoji: '⚡',
      title: 'Fortnight',
      subtitle: '14 day streak',
      color: Color(0xFFFF9500),
      category: 'Streaks',
      description: 'Keep your learning streak alive for 14 consecutive days.',
    ),
    AchievementEntity(
      id: 'month_streak',
      emoji: '💪',
      title: 'Dedicated',
      subtitle: '30 day streak',
      color: Color(0xFFFF6B9D),
      category: 'Streaks',
      description: 'Maintain a 30-day learning streak. True dedication!',
    ),
    AchievementEntity(
      id: 'century_streak',
      emoji: '🌋',
      title: 'Unstoppable',
      subtitle: '100 day streak',
      color: Color(0xFFFF4500),
      category: 'Streaks',
      description: 'Reach a 100-day streak. Truly unstoppable!',
      isLocked: true,
    ),
    AchievementEntity(
      id: 'year_streak',
      emoji: '♾️',
      title: 'Eternal Flame',
      subtitle: '365 day streak',
      color: Color(0xFFFF2D55),
      category: 'Streaks',
      description: 'A full year of daily learning. Legendary dedication!',
      isLocked: true,
    ),

    // ── Experience ───────────────────────────────────────────────────────────
    AchievementEntity(
      id: 'first_xp',
      emoji: '✨',
      title: 'First Steps',
      subtitle: '100 XP earned',
      color: AppColors.tertiaryContainer,
      category: 'Experience',
      description: 'Earn your first 100 XP points. Every journey starts here!',
    ),
    AchievementEntity(
      id: 'xp_hunter',
      emoji: '⭐',
      title: 'XP Hunter',
      subtitle: '500 XP earned',
      color: AppColors.tertiaryContainer,
      category: 'Experience',
      description: 'Accumulate 500 XP through lessons and exercises.',
    ),
    AchievementEntity(
      id: 'xp_master',
      emoji: '🌟',
      title: 'XP Master',
      subtitle: '2000 XP earned',
      color: AppColors.tertiaryContainer,
      category: 'Experience',
      description: 'Earn 2000 XP points through lessons and exercises.',
    ),
    AchievementEntity(
      id: 'xp_legend',
      emoji: '💎',
      title: 'XP Legend',
      subtitle: '10,000 XP earned',
      color: Color(0xFF00B4D8),
      category: 'Experience',
      description: 'Reach 10,000 XP. You\'re a true legend!',
      isLocked: true,
    ),
    AchievementEntity(
      id: 'xp_champion',
      emoji: '👑',
      title: 'XP Champion',
      subtitle: '50,000 XP earned',
      color: Color(0xFFFFD700),
      category: 'Experience',
      description: 'Earn 50,000 XP. The absolute pinnacle of achievement!',
      isLocked: true,
    ),

    // ── Learning ─────────────────────────────────────────────────────────────
    AchievementEntity(
      id: 'first_lesson',
      emoji: '📖',
      title: 'First Lesson',
      subtitle: 'Complete 1 lesson',
      color: AppColors.primary,
      category: 'Learning',
      description:
          'Complete your very first lesson. Every journey begins with a single step!',
    ),
    AchievementEntity(
      id: 'quick_learner',
      emoji: '🎯',
      title: 'Quick Learner',
      subtitle: '5 lessons in a day',
      color: Color(0xFF00DC82),
      category: 'Learning',
      description: 'Complete 5 lessons in a single day.',
    ),
    AchievementEntity(
      id: 'perfectionist',
      emoji: '💯',
      title: 'Perfectionist',
      subtitle: '100% accuracy',
      color: AppColors.secondary,
      category: 'Learning',
      description: 'Complete a lesson with 100% accuracy on the first try.',
    ),
    AchievementEntity(
      id: 'bookworm',
      emoji: '📚',
      title: 'Bookworm',
      subtitle: '25 lessons done',
      color: AppColors.primary,
      category: 'Learning',
      description: 'Complete 25 lessons across all courses.',
    ),
    AchievementEntity(
      id: 'no_mistakes',
      emoji: '🏅',
      title: 'Flawless',
      subtitle: '5 perfect lessons',
      color: Color(0xFF00DC82),
      category: 'Learning',
      description: 'Complete 5 lessons in a row without a single mistake.',
      isLocked: true,
    ),
    AchievementEntity(
      id: 'century_learner',
      emoji: '🏫',
      title: 'Century Learner',
      subtitle: '100 lessons done',
      color: AppColors.primaryDim,
      category: 'Learning',
      description: 'Complete 100 lessons. An impressive milestone!',
      isLocked: true,
    ),
    AchievementEntity(
      id: 'scholar',
      emoji: '🎓',
      title: 'Scholar',
      subtitle: 'Complete all courses',
      color: AppColors.primary,
      category: 'Learning',
      description: 'Finish all available courses and become a true scholar.',
      isLocked: true,
    ),

    // ── Social ───────────────────────────────────────────────────────────────
    AchievementEntity(
      id: 'top_10',
      emoji: '🏆',
      title: 'Champion',
      subtitle: 'Top 10 leaderboard',
      color: Color(0xFFFFD700),
      category: 'Social',
      description: 'Reach the top 10 on the weekly leaderboard.',
      isLocked: true,
    ),
    AchievementEntity(
      id: 'top_3',
      emoji: '🥇',
      title: 'Podium',
      subtitle: 'Top 3 leaderboard',
      color: Color(0xFFFFD700),
      category: 'Social',
      description: 'Reach the top 3 on the weekly leaderboard.',
      isLocked: true,
    ),
    AchievementEntity(
      id: 'number_one',
      emoji: '🌍',
      title: 'World #1',
      subtitle: 'Rank #1 globally',
      color: Color(0xFFFFD700),
      category: 'Social',
      description: 'Claim the #1 spot on the global leaderboard.',
      isLocked: true,
    ),
    AchievementEntity(
      id: 'referral',
      emoji: '🤝',
      title: 'Team Player',
      subtitle: 'Invite 3 friends',
      color: Color(0xFF4FC3F7),
      category: 'Social',
      description: 'Invite 3 friends to join Modern Learner.',
      isLocked: true,
    ),

    // ── Special ──────────────────────────────────────────────────────────────
    AchievementEntity(
      id: 'early_adopter',
      emoji: '🚀',
      title: 'Early Adopter',
      subtitle: 'Joined early access',
      color: Color(0xFF7E51FF),
      category: 'Special',
      description:
          'You joined during the early access period. Thanks for being here from the start!',
    ),
    AchievementEntity(
      id: 'night_owl',
      emoji: '🦉',
      title: 'Night Owl',
      subtitle: 'Study after midnight',
      color: Color(0xFF6C63FF),
      category: 'Special',
      description:
          'Complete a lesson after midnight. The night is your classroom!',
      isLocked: true,
    ),
    AchievementEntity(
      id: 'speed_demon',
      emoji: '💨',
      title: 'Speed Demon',
      subtitle: 'Fastest completion',
      color: Color(0xFF00DC82),
      category: 'Special',
      description:
          'Complete a lesson faster than the average time. Lightning speed!',
      isLocked: true,
    ),
    AchievementEntity(
      id: 'comeback_kid',
      emoji: '🦅',
      title: 'Comeback Kid',
      subtitle: 'Return after 7 days',
      color: Color(0xFFFF9500),
      category: 'Special',
      description:
          'Return to learning after a 7-day break. Comebacks are always welcome!',
      isLocked: true,
    ),
  ];

  void _onLoadRequested(
    AchievementLoadRequested event,
    Emitter<AchievementState> emit,
  ) {
    emit(state.copyWith(
      status: AchievementStatus.loaded,
      achievements: allAchievements,
      filtered: allAchievements,
    ));
  }

  void _onFilterChanged(
    AchievementFilterChanged event,
    Emitter<AchievementState> emit,
  ) {
    final filtered = switch (event.filter) {
      'unlocked' => state.achievements.where((a) => !a.isLocked).toList(),
      'locked' => state.achievements.where((a) => a.isLocked).toList(),
      _ => List<AchievementEntity>.from(state.achievements),
    };
    emit(state.copyWith(selectedFilter: event.filter, filtered: filtered));
  }
}
