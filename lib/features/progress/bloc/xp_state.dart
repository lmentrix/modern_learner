part of 'xp_bloc.dart';

final class XpState extends Equatable {
  const XpState({this.totalXp = 0, this.exercisesCompleted = 0});

  final int totalXp;
  final int exercisesCompleted;

  XpState copyWith({int? totalXp, int? exercisesCompleted}) {
    return XpState(
      totalXp: totalXp ?? this.totalXp,
      exercisesCompleted: exercisesCompleted ?? this.exercisesCompleted,
    );
  }

  @override
  List<Object?> get props => [totalXp, exercisesCompleted];
}
