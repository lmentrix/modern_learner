import 'package:equatable/equatable.dart';

class UserProgress extends Equatable {
  const UserProgress({
    required this.totalXp,
    required this.level,
    required this.gems,
    required this.streak,
    required this.completedLessons,
    required this.lessonProgress,
    required this.completedChapters,
    this.currentRoadmapId,
  });

  const UserProgress.empty()
    : totalXp = 0,
      level = 1,
      gems = 0,
      streak = 0,
      completedLessons = const {},
      lessonProgress = const {},
      completedChapters = const {},
      currentRoadmapId = null;

  final int totalXp;
  final int level;
  final int gems;
  final int streak;
  final Map<String, DateTime> completedLessons;
  final Map<String, double> lessonProgress;
  final Map<String, DateTime> completedChapters;
  final String? currentRoadmapId;

  UserProgress copyWith({
    int? totalXp,
    int? level,
    int? gems,
    int? streak,
    Map<String, DateTime>? completedLessons,
    Map<String, double>? lessonProgress,
    Map<String, DateTime>? completedChapters,
    String? currentRoadmapId,
  }) {
    return UserProgress(
      totalXp: totalXp ?? this.totalXp,
      level: level ?? this.level,
      gems: gems ?? this.gems,
      streak: streak ?? this.streak,
      completedLessons: completedLessons ?? Map.from(this.completedLessons),
      lessonProgress: lessonProgress ?? Map.from(this.lessonProgress),
      completedChapters: completedChapters ?? Map.from(this.completedChapters),
      currentRoadmapId: currentRoadmapId ?? this.currentRoadmapId,
    );
  }

  @override
  List<Object?> get props => [
    totalXp,
    level,
    gems,
    streak,
    completedLessons,
    lessonProgress,
    completedChapters,
    currentRoadmapId,
  ];
}
