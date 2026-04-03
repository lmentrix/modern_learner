import 'package:modern_learner_production/features/progress/domain/entities/user_progress.dart';

class UserProgressModel {

  UserProgressModel({
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

  factory UserProgressModel.fromJson(Map<String, dynamic> json) {
    return UserProgressModel(
      totalXp: json['totalXp'] as int,
      level: json['level'] as int,
      gems: json['gems'] as int,
      streak: json['streak'] as int,
      completedLessons: Map<String, String>.from(json['completedLessons'] ?? {}),
      lessonProgress: Map<String, double>.from(json['lessonProgress'] ?? {}),
      completedChapters: Map<String, String>.from(json['completedChapters'] ?? {}),
      unlockedAchievements: (json['unlockedAchievements'] as List<dynamic>?)?.cast<String>() ?? [],
      currentRoadmapId: json['currentRoadmapId'] as String?,
    );
  }
  final int totalXp;
  final int level;
  final int gems;
  final int streak;
  final Map<String, String> completedLessons;
  final Map<String, double> lessonProgress;
  final Map<String, String> completedChapters;
  final List<String> unlockedAchievements;
  final String? currentRoadmapId;

  Map<String, dynamic> toJson() {
    return {
      'totalXp': totalXp,
      'level': level,
      'gems': gems,
      'streak': streak,
      'completedLessons': completedLessons,
      'lessonProgress': lessonProgress,
      'completedChapters': completedChapters,
      'unlockedAchievements': unlockedAchievements,
      'currentRoadmapId': currentRoadmapId,
    };
  }

  UserProgress toEntity() {
    return UserProgress(
      totalXp: totalXp,
      level: level,
      gems: gems,
      streak: streak,
      completedLessons: completedLessons.map((k, v) => MapEntry(k, DateTime.parse(v))),
      lessonProgress: lessonProgress,
      completedChapters: completedChapters.map((k, v) => MapEntry(k, DateTime.parse(v))),
      unlockedAchievements: unlockedAchievements,
      currentRoadmapId: currentRoadmapId,
    );
  }

  static UserProgressModel fromEntity(UserProgress progress) {
    return UserProgressModel(
      totalXp: progress.totalXp,
      level: progress.level,
      gems: progress.gems,
      streak: progress.streak,
      completedLessons: progress.completedLessons.map((k, v) => MapEntry(k, v.toIso8601String())),
      lessonProgress: progress.lessonProgress,
      completedChapters: progress.completedChapters.map((k, v) => MapEntry(k, v.toIso8601String())),
      unlockedAchievements: progress.unlockedAchievements,
      currentRoadmapId: progress.currentRoadmapId,
    );
  }
}
