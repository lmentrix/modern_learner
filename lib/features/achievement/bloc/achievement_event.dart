part of 'achievement_bloc.dart';

@immutable
sealed class AchievementEvent {}

/// Load all achievements and evaluate which are already unlocked.
final class LoadAchievements extends AchievementEvent {
  LoadAchievements(this.progress);
  final UserProgress progress;
}

/// Re-evaluate achievements whenever user progress changes.
final class CheckAchievements extends AchievementEvent {
  CheckAchievements(this.progress);
  final UserProgress progress;
}

/// Filter the displayed list by type; null shows all.
final class FilterAchievements extends AchievementEvent {
  FilterAchievements(this.type);
  final AchievementType? type;
}
