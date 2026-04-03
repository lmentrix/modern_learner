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

  static const List<AchievementEntity> allAchievements = [
    AchievementEntity(
      id: 'week_streak',
      emoji: '🔥',
      title: 'Week Streak',
      subtitle: '7 day streak',
      color: Color(0xFFFF9500),
      description: 'Maintain a 7-day learning streak without missing a day.',
    ),
    AchievementEntity(
      id: 'xp_master',
      emoji: '⭐',
      title: 'XP Master',
      subtitle: '2000 XP earned',
      color: AppColors.tertiaryContainer,
      description: 'Earn 2000 XP points through lessons and exercises.',
    ),
    AchievementEntity(
      id: 'bookworm',
      emoji: '📚',
      title: 'Bookworm',
      subtitle: '25 lessons done',
      color: AppColors.primary,
      description: 'Complete 25 lessons across all courses.',
    ),
    AchievementEntity(
      id: 'perfectionist',
      emoji: '🎯',
      title: 'Perfectionist',
      subtitle: '100% accuracy',
      color: AppColors.secondary,
      description: 'Complete a lesson with 100% accuracy on the first try.',
    ),
    AchievementEntity(
      id: 'quick_learner',
      emoji: '🌟',
      title: 'Quick Learner',
      subtitle: '5 lessons in a day',
      color: Color(0xFF00DC82),
      description: 'Complete 5 lessons in a single day.',
    ),
    AchievementEntity(
      id: 'dedicated',
      emoji: '💪',
      title: 'Dedicated',
      subtitle: '30 day streak',
      color: Color(0xFFFF6B9D),
      description: 'Maintain a 30-day learning streak. True dedication!',
    ),
    AchievementEntity(
      id: 'champion',
      emoji: '🏆',
      title: 'Champion',
      subtitle: 'Top 10 leaderboard',
      color: Color(0xFFFFD700),
      description: 'Reach the top 10 on the weekly leaderboard.',
      isLocked: true,
    ),
    AchievementEntity(
      id: 'scholar',
      emoji: '🎓',
      title: 'Scholar',
      subtitle: 'Complete all courses',
      color: AppColors.primary,
      description: 'Finish all available courses and become a true scholar.',
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
