part of 'achievement_bloc.dart';

@immutable
sealed class AchievementState {}

final class AchievementInitial extends AchievementState {}

final class AchievementLoading extends AchievementState {}

final class AchievementLoaded extends AchievementState {
  AchievementLoaded({
    required this.all,
    required this.displayed,
    this.newlyUnlocked = const [],
    this.activeFilter,
  });

  /// Full catalogue with unlock status applied.
  final List<Achievement> all;

  /// Subset shown in the UI (filtered by type).
  final List<Achievement> displayed;

  /// Achievements unlocked during the latest [CheckAchievements] event.
  final List<Achievement> newlyUnlocked;

  final AchievementType? activeFilter;

  int get unlockedCount => all.where((a) => a.isUnlocked).length;
  int get totalCount => all.length;

  AchievementLoaded copyWith({
    List<Achievement>? all,
    List<Achievement>? displayed,
    List<Achievement>? newlyUnlocked,
    AchievementType? activeFilter,
    bool clearFilter = false,
  }) {
    return AchievementLoaded(
      all: all ?? this.all,
      displayed: displayed ?? this.displayed,
      newlyUnlocked: newlyUnlocked ?? this.newlyUnlocked,
      activeFilter: clearFilter ? null : (activeFilter ?? this.activeFilter),
    );
  }
}

final class AchievementError extends AchievementState {
  AchievementError(this.message);
  final String message;
}
