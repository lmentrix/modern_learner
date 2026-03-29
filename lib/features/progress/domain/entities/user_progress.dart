import 'package:equatable/equatable.dart';

class UserProgress extends Equatable {
  final int totalXp;
  final int level;
  final int gems;
  final int streak;
  final Map<String, DateTime> completedNodes; // nodeId -> completionDate
  final Map<String, double> nodeProgress; // nodeId -> 0.0 to 1.0
  final List<String> unlockedAchievements;

  const UserProgress({
    required this.totalXp,
    required this.level,
    required this.gems,
    required this.streak,
    required this.completedNodes,
    required this.nodeProgress,
    required this.unlockedAchievements,
  });

  UserProgress copyWith({
    int? totalXp,
    int? level,
    int? gems,
    int? streak,
    Map<String, DateTime>? completedNodes,
    Map<String, double>? nodeProgress,
    List<String>? unlockedAchievements,
  }) {
    return UserProgress(
      totalXp: totalXp ?? this.totalXp,
      level: level ?? this.level,
      gems: gems ?? this.gems,
      streak: streak ?? this.streak,
      completedNodes: completedNodes ?? Map.from(this.completedNodes),
      nodeProgress: nodeProgress ?? Map.from(this.nodeProgress),
      unlockedAchievements: unlockedAchievements ?? [...this.unlockedAchievements],
    );
  }

  @override
  List<Object?> get props => [
        totalXp,
        level,
        gems,
        streak,
        completedNodes,
        nodeProgress,
        unlockedAchievements,
      ];
}
