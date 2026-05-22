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
}
