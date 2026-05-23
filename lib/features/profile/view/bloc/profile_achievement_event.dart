part of 'profile_achievement_bloc.dart';

sealed class ProfileAchievementEvent extends Equatable {
  const ProfileAchievementEvent();
}

/// Load achievements for [courseId]. Pass null for the global set.
final class ProfileAchievementLoadRequested extends ProfileAchievementEvent {
  const ProfileAchievementLoadRequested({this.courseId});

  final String? courseId;

  @override
  List<Object?> get props => [courseId];
}

/// Apply a display filter (e.g. 'all', 'unlocked', 'Streaks').
final class ProfileAchievementFilterChanged extends ProfileAchievementEvent {
  const ProfileAchievementFilterChanged(this.filter);

  final String filter;

  @override
  List<Object?> get props => [filter];
}

/// Sync live XP from XpBloc so the xp_collector achievement reflects real progress.
final class ProfileAchievementXpUpdated extends ProfileAchievementEvent {
  const ProfileAchievementXpUpdated(this.totalXp);

  final int totalXp;

  @override
  List<Object?> get props => [totalXp];
}
