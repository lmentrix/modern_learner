import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:modern_learner_production/core/models/user_progress.dart';
import 'package:modern_learner_production/features/achievement/data/achievemenet_data.dart';
import 'package:modern_learner_production/features/achievement/model/achievement_model.dart';
import 'package:modern_learner_production/features/progress/service/course_xp_service.dart';

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

  /// Stamps each catalogue entry with the list of courses that unlocked it.
  List<Achievement> _evaluate(
    List<Achievement> catalogue,
    UserProgress progress,
  ) {
    final courseData = Map.fromEntries(
      CourseXpService.instance.courseNotifiers.entries.map(
        (e) => MapEntry(e.key, e.value.value),
      ),
    );

    return catalogue.map((a) {
      final courses = _unlockedBy(a, progress, courseData);
      return a.copyWith(
        unlockedByCourses: courses,
        unlockedAt: courses.isNotEmpty && a.unlockedAt == null
            ? DateTime.now()
            : a.unlockedAt,
      );
    }).toList();
  }

  /// Returns the list of course keys (or ['global']) that meet [a]'s threshold.
  List<String> _unlockedBy(
    Achievement a,
    UserProgress progress,
    Map<String, CourseXpData> courseData,
  ) {
    switch (a.type) {
      case AchievementType.xp:
        return courseData.entries
            .where((e) => e.value.exerciseXp >= a.requirement)
            .map((e) => e.key)
            .toList();

      case AchievementType.chapter:
        return courseData.entries
            .where((e) => e.value.chaptersUnlocked >= a.requirement)
            .map((e) => e.key)
            .toList();

      case AchievementType.streak:
        return progress.streak >= a.requirement ? ['global'] : [];

      case AchievementType.level:
        return progress.level >= a.requirement ? ['global'] : [];

      case AchievementType.gems:
        return progress.gems >= a.requirement ? ['global'] : [];

      case AchievementType.lesson:
        return progress.completedLessons.length >= a.requirement
            ? ['global']
            : [];
    }
  }
}
