part of 'global_bloc.dart';

@immutable
sealed class GlobalState {
  const GlobalState();
}

final class GlobalInitial extends GlobalState {}

final class GlobalLoading extends GlobalState {}

final class Activity {
  const Activity({required this.date, required this.intensity});
  final DateTime date;
  final int intensity;

  //TODO: implement all activities
}

final class GlobalLoaded extends GlobalState {
  const GlobalLoaded({
    required this.displayName,
    this.xp,
    this.level,
    this.streak,
    this.lessons,
    this.hours,
    this.notes,
    this.files,
    this.xpGoal,
    this.activity,
    this.joinDate,
  });

  final String displayName;
  final int? xp;
  final int? level;
  final int? streak;
  final int? lessons;
  final int? hours;
  final int? notes;
  final int? files;
  final int? xpGoal;
  final String? joinDate;
  final Activity? activity;
}

final class GlobalError extends GlobalState {
  const GlobalError(this.message);
  final String message;
}
