import 'package:equatable/equatable.dart';

class UserProgress extends Equatable {
  final int totalXp;
  final int level;
  final int gems;
  final int streak;
  final Map<String, DateTime> completedLessons; // lessonId -> completionDate
  final Map<String, double> lessonProgress; // lessonId -> 0.0 to 1.0
  final Map<String, DateTime> completedChapters; // chapterId -> completionDate
  final List<String> unlockedAchievements;
  final String? currentRoadmapId;

  const UserProgress({
    required this.totalXp,
    required this.level,
    required this.gems,
    required this.streak,
    required this.completedLessons,
    required this.lessonProgress,
    required this.completedChapters,
    required this.unlockedAchievements,
    this.currentRoadmapId,
  });

  UserProgress copyWith({
    int? totalXp,
    int? level,
    int? gems,
    int? streak,
    Map<String, DateTime>? completedLessons,
    Map<String, double>? lessonProgress,
    Map<String, DateTime>? completedChapters,
    List<String>? unlockedAchievements,
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
      unlockedAchievements: unlockedAchievements ?? [...this.unlockedAchievements],
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
        unlockedAchievements,
        currentRoadmapId,
      ];
}
