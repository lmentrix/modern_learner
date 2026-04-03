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
