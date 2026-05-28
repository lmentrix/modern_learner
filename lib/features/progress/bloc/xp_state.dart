part of 'xp_bloc.dart';

final class XpState extends Equatable {
  const XpState({
    this.totalXp = 0,
    this.exercisesCompleted = 0,
    this.chaptersUnlocked = 1,
  });

  final int totalXp;
  final int exercisesCompleted;
  final int chaptersUnlocked;

  XpState copyWith({
    int? totalXp,
    int? exercisesCompleted,
    int? chaptersUnlocked,
  }) {
    return XpState(
      totalXp: totalXp ?? this.totalXp,
      exercisesCompleted: exercisesCompleted ?? this.exercisesCompleted,
      chaptersUnlocked: chaptersUnlocked ?? this.chaptersUnlocked,
    );
  }

  @override
  List<Object?> get props => [totalXp, exercisesCompleted, chaptersUnlocked];
}
