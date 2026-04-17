import 'package:modern_learner_production/features/progress/domain/entities/user_progress.dart';

/// Data-transfer object for [UserProgress].
///
/// [fromJson] / [toJson]  – camelCase keys (local SharedPreferences cache).
/// [fromRow]  / [toRow]   – snake_case keys (Supabase `user_progress` table).
class UserProgressModel {
  const UserProgressModel({
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

  // ── JSON (camelCase) ───────────────────────────────────────────────────────

  factory UserProgressModel.fromJson(Map<String, dynamic> json) =>
      UserProgressModel(
        totalXp: (json['totalXp'] as num?)?.toInt() ?? 0,
        level: (json['level'] as num?)?.toInt() ?? 1,
        gems: (json['gems'] as num?)?.toInt() ?? 0,
        streak: (json['streak'] as num?)?.toInt() ?? 0,
        completedLessons:
            Map<String, String>.from(json['completedLessons'] ?? {}),
        lessonProgress: (json['lessonProgress'] as Map<String, dynamic>? ?? {})
            .map((k, v) => MapEntry(k, (v as num).toDouble())),
        completedChapters:
            Map<String, String>.from(json['completedChapters'] ?? {}),
        achievementLevels:
            (json['achievementLevels'] as Map<String, dynamic>? ?? {})
                .map((k, v) => MapEntry(k, (v as num).toInt())),
        currentRoadmapId: json['currentRoadmapId'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'totalXp': totalXp,
        'level': level,
        'gems': gems,
        'streak': streak,
        'completedLessons': completedLessons,
        'lessonProgress': lessonProgress,
        'completedChapters': completedChapters,
        'achievementLevels': achievementLevels,
        'currentRoadmapId': currentRoadmapId,
      };

  // ── Supabase row (snake_case) ──────────────────────────────────────────────

  factory UserProgressModel.fromRow(Map<String, dynamic> row) =>
      UserProgressModel(
        totalXp: (row['total_xp'] as num?)?.toInt() ?? 0,
        level: (row['level'] as num?)?.toInt() ?? 1,
        gems: (row['gems'] as num?)?.toInt() ?? 0,
        streak: (row['streak'] as num?)?.toInt() ?? 0,
        completedLessons:
            (row['completed_lessons'] as Map<String, dynamic>? ?? {})
                .map((k, v) => MapEntry(k, v as String)),
        lessonProgress:
            (row['lesson_progress'] as Map<String, dynamic>? ?? {})
                .map((k, v) => MapEntry(k, (v as num).toDouble())),
        completedChapters:
            (row['completed_chapters'] as Map<String, dynamic>? ?? {})
                .map((k, v) => MapEntry(k, v as String)),
        achievementLevels:
            (row['achievement_levels'] as Map<String, dynamic>? ?? {})
                .map((k, v) => MapEntry(k, (v as num).toInt())),
        currentRoadmapId: row['current_roadmap_id'] as String?,
      );

  Map<String, dynamic> toRow(String userId) => {
        'user_id': userId,
        'total_xp': totalXp,
        'level': level,
        'gems': gems,
        'streak': streak,
        'current_roadmap_id': currentRoadmapId,
        'completed_lessons': completedLessons,
        'lesson_progress': lessonProgress,
        'completed_chapters': completedChapters,
        'achievement_levels': achievementLevels,
      };

  // ── Entity conversion ──────────────────────────────────────────────────────

  UserProgress toEntity() => UserProgress(
        totalXp: totalXp,
        level: level,
        gems: gems,
        streak: streak,
        completedLessons: completedLessons
            .map((k, v) => MapEntry(k, DateTime.parse(v))),
        lessonProgress: lessonProgress,
        completedChapters: completedChapters
            .map((k, v) => MapEntry(k, DateTime.parse(v))),
        achievementLevels: achievementLevels,
        currentRoadmapId: currentRoadmapId,
      );

  static UserProgressModel fromEntity(UserProgress p) => UserProgressModel(
        totalXp: p.totalXp,
        level: p.level,
        gems: p.gems,
        streak: p.streak,
        completedLessons: p.completedLessons
            .map((k, v) => MapEntry(k, v.toIso8601String())),
        lessonProgress: p.lessonProgress,
        completedChapters: p.completedChapters
            .map((k, v) => MapEntry(k, v.toIso8601String())),
        achievementLevels: p.achievementLevels,
        currentRoadmapId: p.currentRoadmapId,
      );

  // ── Fields ─────────────────────────────────────────────────────────────────

  final int totalXp;
  final int level;
  final int gems;
  final int streak;
  /// ISO-8601 strings keyed by progress-key.
  final Map<String, String> completedLessons;
  final Map<String, double> lessonProgress;
  /// ISO-8601 strings keyed by chapter-id.
  final Map<String, String> completedChapters;
  /// Achievement ID → highest earned level (1–5).
  final Map<String, int> achievementLevels;
  final String? currentRoadmapId;
}
