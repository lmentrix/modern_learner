import 'package:modern_learner_production/features/home/data/achievement_entity.dart';

abstract class AchievementRepository {
  /// Returns achievements optionally scoped to a [courseId].
  /// Pass null to fetch the global cross-course achievement set.
  Future<List<AchievementEntity>> getAchievements({String? courseId});

  /// Returns the raw progress map for a given [courseId] (or global).
  Future<Map<String, int>> getProgress({String? courseId});
}
