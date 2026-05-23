import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:modern_learner_production/features/home/data/home_achievement_data.dart';
import 'package:modern_learner_production/features/profile/data/achievement_repository.dart';

part 'profile_achievement_event.dart';

/// Manages loading and filtering of achievements for the profile screen.
/// Emits [AchievementState] (shared model from home feature).
class ProfileAchievementBloc
    extends Bloc<ProfileAchievementEvent, AchievementState> {
  ProfileAchievementBloc(this._repository) : super(const AchievementState()) {
    on<ProfileAchievementLoadRequested>(_onLoadRequested);
    on<ProfileAchievementFilterChanged>(_onFilterChanged);
    on<ProfileAchievementXpUpdated>(_onXpUpdated);
  }

  final AchievementRepository _repository;

  Future<void> _onLoadRequested(
    ProfileAchievementLoadRequested event,
    Emitter<AchievementState> emit,
  ) async {
    emit(state.copyWith(status: AchievementStatus.loading));
    try {
      final achievements =
          await _repository.getAchievements(courseId: event.courseId);
      emit(
        state.copyWith(
          status: AchievementStatus.loaded,
          achievements: achievements,
          filtered: filterAchievements(achievements, state.selectedFilter),
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: AchievementStatus.error));
    }
  }

  void _onFilterChanged(
    ProfileAchievementFilterChanged event,
    Emitter<AchievementState> emit,
  ) {
    emit(
      state.copyWith(
        selectedFilter: event.filter,
        filtered: filterAchievements(state.achievements, event.filter),
      ),
    );
  }

  void _onXpUpdated(
    ProfileAchievementXpUpdated event,
    Emitter<AchievementState> emit,
  ) {
    if (state.status != AchievementStatus.loaded) return;

    final updated = state.achievements.map((a) {
      if (a.id != 'xp_collector') return a;
      return a.copyWith(
        currentProgress: event.totalXp,
        currentLevel: _levelFor(event.totalXp, a.levelThresholds),
      );
    }).toList();

    emit(state.copyWith(
      achievements: updated,
      filtered: filterAchievements(updated, state.selectedFilter),
    ));
  }

  static int _levelFor(int value, List<int> thresholds) {
    var level = 0;
    for (var i = 0; i < thresholds.length; i++) {
      if (value >= thresholds[i]) level = i + 1;
    }
    return level;
  }
}
