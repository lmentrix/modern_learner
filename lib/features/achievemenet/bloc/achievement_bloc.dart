import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modern_learner_production/features/achievemenet/data/achievement_summary.dart';
import 'package:modern_learner_production/features/achievemenet/model/achievement_model.dart';
import 'package:modern_learner_production/features/achievemenet/service/achievement_service.dart';

part 'achievement_event.dart';
part 'achievement_state.dart';

class AchievementBloc extends Bloc<AchievementEvent, AchievementState> {
  AchievementBloc(this._service) : super(const AchievementState()) {
    on<AchievementsLoadRequested>(_onLoadRequested);
    on<AchievementSignalRecorded>(_onSignalRecorded);
    on<AchievementCategoryChanged>(_onCategoryChanged);
    on<AchievementUnlockedSeen>(_onUnlockedSeen);
  }

  final AchievementService _service;

  Future<void> _onLoadRequested(
    AchievementsLoadRequested event,
    Emitter<AchievementState> emit,
  ) async {
    emit(state.copyWith(status: AchievementStatus.loading));
    try {
      final achievements = await _service.fetchAchievements();
      emit(
        state.copyWith(
          status: AchievementStatus.success,
          achievements: achievements,
          recentlyUnlocked: const [],
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AchievementStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onSignalRecorded(
    AchievementSignalRecorded event,
    Emitter<AchievementState> emit,
  ) async {
    try {
      final changed = await _service.recordSignal(event.signal);
      if (changed.isEmpty) return;

      final latest = await _service.fetchAchievements();
      final unlocked = changed
          .where((achievement) => achievement.progress.isUnseen)
          .toList(growable: false);

      emit(
        state.copyWith(
          status: AchievementStatus.success,
          achievements: latest,
          recentlyUnlocked: unlocked,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AchievementStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void _onCategoryChanged(
    AchievementCategoryChanged event,
    Emitter<AchievementState> emit,
  ) {
    emit(
      state.copyWith(
        selectedCategory: event.category,
        clearSelectedCategory: event.category == null,
      ),
    );
  }

  Future<void> _onUnlockedSeen(
    AchievementUnlockedSeen event,
    Emitter<AchievementState> emit,
  ) async {
    final ids = event.achievementIds.toSet();
    await _service.markSeen(ids);
    final seenAt = DateTime.now().toUtc();
    emit(
      state.copyWith(
        achievements: state.achievements
            .map((achievement) {
              if (!ids.contains(achievement.definition.id)) return achievement;
              return UserAchievement(
                definition: achievement.definition,
                progress: achievement.progress.copyWith(seenAt: seenAt),
              );
            })
            .toList(growable: false),
        recentlyUnlocked: const [],
      ),
    );
  }
}
