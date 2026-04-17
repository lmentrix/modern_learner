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
    required this.achievementLevels,
    this.currentRoadmapId,
  });
  final int totalXp;
  final int level;
  final int gems;
  final int streak;
  final Map<String, DateTime> completedLessons; // lessonId -> completionDate
  final Map<String, double> lessonProgress; // lessonId -> 0.0 to 1.0
  final Map<String, DateTime> completedChapters; // chapterId -> completionDate
  /// Maps achievement ID → highest earned level (1–5). Absent key = level 0.
  final Map<String, int> achievementLevels;
  final String? currentRoadmapId;

  UserProgress copyWith({
    int? totalXp,
    int? level,
    int? gems,
    int? streak,
    Map<String, DateTime>? completedLessons,
    Map<String, double>? lessonProgress,
    Map<String, DateTime>? completedChapters,
    Map<String, int>? achievementLevels,
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
      achievementLevels: achievementLevels ?? Map.from(this.achievementLevels),
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
        achievementLevels,
        currentRoadmapId,
      ];
}
