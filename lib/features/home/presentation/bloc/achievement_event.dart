part of 'achievement_bloc.dart';

sealed class AchievementEvent extends Equatable {
  const AchievementEvent();

  @override
  List<Object?> get props => [];
}

final class AchievementLoadRequested extends AchievementEvent {
  const AchievementLoadRequested();
}

final class AchievementFilterChanged extends AchievementEvent {
  const AchievementFilterChanged(this.filter);

  final String filter;

  @override
  List<Object?> get props => [filter];
}

/// Fired internally when the progress stream emits a new [UserProgress].
final class AchievementProgressUpdated extends AchievementEvent {
  const AchievementProgressUpdated(this.progress);

  final UserProgress progress;

  @override
  List<Object?> get props => [progress];
}

/// Fired after the UI has displayed the newly unlocked achievements toast.
final class AchievementNewlyUnlockedAcknowledged extends AchievementEvent {
  const AchievementNewlyUnlockedAcknowledged();
}

/// Internal: clear all achievements on sign-out.
class _AchievementSignedOut extends AchievementEvent {
  const _AchievementSignedOut();
}
