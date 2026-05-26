import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:modern_learner_production/core/models/user_progress.dart';
import 'package:modern_learner_production/features/achievement/data/achievemenet_data.dart';
import 'package:modern_learner_production/features/achievement/model/achievement_model.dart';

part 'achievement_event.dart';
part 'achievement_state.dart';

class AchievementBloc extends Bloc<AchievementEvent, AchievementState> {
  AchievementBloc() : super(AchievementInitial()) {
    on<LoadAchievements>(_onLoad);
    on<CheckAchievements>(_onCheck);
    on<FilterAchievements>(_onFilter);
  }

  void _onLoad(LoadAchievements event, Emitter<AchievementState> emit) {
    emit(AchievementLoading());
    try {
      final evaluated = _evaluate(AchievementCatalogue.all, event.progress);
      emit(AchievementLoaded(all: evaluated, displayed: evaluated));
    } catch (e) {
      emit(AchievementError('Failed to load achievements: $e'));
    }
  }

  void _onCheck(CheckAchievements event, Emitter<AchievementState> emit) {
    final current = state;
    if (current is! AchievementLoaded) return;

    final previously = {
      for (final a in current.all.where((a) => a.isUnlocked)) a.id,
    };

    final updated = _evaluate(AchievementCatalogue.all, event.progress);

    final newlyUnlocked = updated
        .where((a) => a.isUnlocked && !previously.contains(a.id))
        .toList();

    final displayed = current.activeFilter == null
        ? updated
        : updated.where((a) => a.type == current.activeFilter).toList();

    emit(
      current.copyWith(
        all: updated,
        displayed: displayed,
        newlyUnlocked: newlyUnlocked,
      ),
    );
  }

  void _onFilter(FilterAchievements event, Emitter<AchievementState> emit) {
    final current = state;
    if (current is! AchievementLoaded) return;

    final displayed = event.type == null
        ? current.all
        : current.all.where((a) => a.type == event.type).toList();

    emit(
      current.copyWith(
        displayed: displayed,
        activeFilter: event.type,
        clearFilter: event.type == null,
        newlyUnlocked: [],
      ),
    );
  }

  /// Stamps each catalogue entry with its current unlock status.
  List<Achievement> _evaluate(
    List<Achievement> catalogue,
    UserProgress progress,
  ) {
    return catalogue.map((a) {
      final met = _isMet(a, progress);
      return a.copyWith(
        isUnlocked: met,
        unlockedAt: met && a.unlockedAt == null ? DateTime.now() : a.unlockedAt,
      );
    }).toList();
  }

  bool _isMet(Achievement achievement, UserProgress progress) {
    return switch (achievement.type) {
      AchievementType.streak => progress.streak >= achievement.requirement,
      AchievementType.xp => progress.totalXp >= achievement.requirement,
      AchievementType.level => progress.level >= achievement.requirement,
      AchievementType.lesson =>
        progress.completedLessons.length >= achievement.requirement,
      AchievementType.chapter =>
        progress.completedChapters.length >= achievement.requirement,
      AchievementType.gems => progress.gems >= achievement.requirement,
    };
  }
}
