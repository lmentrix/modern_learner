import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/home/domain/entities/achievement_entity.dart';
import 'package:modern_learner_production/features/home/service/achievement_evaluator.dart';
import 'package:modern_learner_production/features/progress/domain/entities/user_progress.dart';
import 'package:modern_learner_production/features/progress/domain/repositories/progress_repository.dart';

part 'achievement_event.dart';
part 'achievement_state.dart';

class AchievementBloc extends Bloc<AchievementEvent, AchievementState> {
  AchievementBloc({required ProgressRepository progressRepository})
      : _progressRepository = progressRepository,
        super(const AchievementState()) {
    on<AchievementLoadRequested>(_onLoadRequested);
    on<AchievementFilterChanged>(_onFilterChanged);
    on<AchievementProgressUpdated>(_onProgressUpdated);
    on<AchievementNewlyUnlockedAcknowledged>(_onAcknowledged);

    _progressSub = _progressRepository
        .getProgressStream()
        .listen((p) => add(AchievementProgressUpdated(p)));
  }

  final ProgressRepository _progressRepository;
  late final StreamSubscription<UserProgress> _progressSub;

  @override
  Future<void> close() {
    _progressSub.cancel();
    return super.close();
  }

  // ── Category order ────────────────────────────────────────────────────────

  static const List<String> categoryOrder = [
    'Streaks',
    'Experience',
    'Learning',
    'Special',
  ];

  // ── Achievement definitions (8 achievements × 5 levels) ──────────────────

  static const List<AchievementEntity> allAchievements = [
    // ── Streaks ──────────────────────────────────────────────────────────────
    AchievementEntity(
      id: 'streak_master',
      emoji: '🔥',
      title: 'Streak Guardian',
      description:
          'Maintain daily learning streaks without missing a single day. '
          'The longer you go, the higher your tier!',
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

    // ── Experience ───────────────────────────────────────────────────────────
    AchievementEntity(
      id: 'xp_collector',
      emoji: '⭐',
      title: 'XP Collector',
      description:
          'Accumulate XP by completing lessons, chapters, and challenges. '
          'More XP means a higher tier!',
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
          'Rise through the player levels by completing more and more content. '
          'Each new tier represents a new milestone!',
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

    // ── Learning ─────────────────────────────────────────────────────────────
    AchievementEntity(
      id: 'lesson_warrior',
      emoji: '📚',
      title: 'Lesson Warrior',
      description:
          'Complete lessons across all your courses. '
          'Every lesson brings you one step closer to the Diamond tier!',
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
          'Prove your dedication by completing multiple lessons in a single day. '
          'Your best single-day count determines your tier!',
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
          'Fully complete chapters across your learning roadmaps. '
          'Each tier represents mastery of more complete chapters!',
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

    // ── Special ──────────────────────────────────────────────────────────────
    AchievementEntity(
      id: 'night_owl',
      emoji: '🦉',
      title: 'Night Owl',
      description:
          'Study in the quiet hours between midnight and 5 AM. '
          'More midnight sessions = a higher tier!',
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
          'Progress through the game levels to unlock higher Pioneer tiers. '
          'The highest tier proves you\'ve been here from the start!',
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
  ];

  // ── Handlers ──────────────────────────────────────────────────────────────

  Future<void> _onLoadRequested(
    AchievementLoadRequested event,
    Emitter<AchievementState> emit,
  ) async {
    emit(state.copyWith(status: AchievementStatus.loading));
    final progress = await _progressRepository.getUserProgress();
    final list = _buildList(progress);
    emit(state.copyWith(
      status: AchievementStatus.loaded,
      achievements: list,
      filtered: _applyFilter(list, state.selectedFilter),
    ));
  }

  void _onFilterChanged(
    AchievementFilterChanged event,
    Emitter<AchievementState> emit,
  ) {
    emit(state.copyWith(
      selectedFilter: event.filter,
      filtered: _applyFilter(state.achievements, event.filter),
    ));
  }

  void _onProgressUpdated(
    AchievementProgressUpdated event,
    Emitter<AchievementState> emit,
  ) {
    // Track previous levels to detect level-ups.
    final previousLevels = {
      for (final a in state.achievements) a.id: a.currentLevel,
    };

    final newList = _buildList(event.progress);

    // Collect achievements that just gained a level.
    final levelUps = newList.where((a) {
      final prev = previousLevels[a.id] ?? 0;
      return a.currentLevel > prev;
    }).toList();

    emit(state.copyWith(
      status: AchievementStatus.loaded,
      achievements: newList,
      filtered: _applyFilter(newList, state.selectedFilter),
      newlyUnlocked: [...state.newlyUnlocked, ...levelUps],
    ));
  }

  void _onAcknowledged(
    AchievementNewlyUnlockedAcknowledged event,
    Emitter<AchievementState> emit,
  ) {
    emit(state.copyWith(newlyUnlocked: []));
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Rebuilds the full list with [currentLevel] and [currentProgress] set
  /// from [progress.achievementLevels] and the evaluator.
  List<AchievementEntity> _buildList(UserProgress progress) {
    return allAchievements.map((template) {
      final level = progress.achievementLevels[template.id] ?? 0;
      final rawProgress = AchievementEvaluator.progressFor(template.id, progress);
      return template.copyWith(
        currentLevel: level,
        currentProgress: rawProgress,
      );
    }).toList();
  }

  List<AchievementEntity> _applyFilter(
    List<AchievementEntity> list,
    String filter,
  ) {
    return switch (filter) {
      'unlocked' => list.where((a) => !a.isLocked).toList(),
      'locked' => list.where((a) => a.isLocked).toList(),
      _ => List<AchievementEntity>.from(list),
    };
  }
}
