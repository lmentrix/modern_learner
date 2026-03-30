import '../../domain/entities/user_progress.dart';

class UserProgressModel {
  final int totalXp;
  final int level;
  final int gems;
  final int streak;
  final Map<String, String> completedNodes;
  final Map<String, double> nodeProgress;
  final List<String> unlockedAchievements;

  UserProgressModel({
    required this.totalXp,
    required this.level,
    required this.gems,
    required this.streak,
    required this.completedNodes,
    required this.nodeProgress,
    required this.unlockedAchievements,
  });

  factory UserProgressModel.fromJson(Map<String, dynamic> json) {
    return UserProgressModel(
      totalXp: json['totalXp'] as int,
      level: json['level'] as int,
      gems: json['gems'] as int,
      streak: json['streak'] as int,
      completedNodes: Map<String, String>.from(json['completedNodes'] ?? {}),
      nodeProgress: Map<String, double>.from(json['nodeProgress'] ?? {}),
      unlockedAchievements: (json['unlockedAchievements'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalXp': totalXp,
      'level': level,
      'gems': gems,
      'streak': streak,
      'completedNodes': completedNodes,
      'nodeProgress': nodeProgress,
      'unlockedAchievements': unlockedAchievements,
    };
  }

  UserProgress toEntity() {
    return UserProgress(
      totalXp: totalXp,
      level: level,
      gems: gems,
      streak: streak,
      completedNodes: completedNodes.map((k, v) => MapEntry(k, DateTime.parse(v))),
      nodeProgress: nodeProgress,
      unlockedAchievements: unlockedAchievements,
    );
  }

  static UserProgressModel fromEntity(UserProgress progress) {
    return UserProgressModel(
      totalXp: progress.totalXp,
      level: progress.level,
      gems: progress.gems,
      streak: progress.streak,
      completedNodes: progress.completedNodes.map((k, v) => MapEntry(k, v.toIso8601String())),
      nodeProgress: progress.nodeProgress,
      unlockedAchievements: progress.unlockedAchievements,
    );
  }
}
