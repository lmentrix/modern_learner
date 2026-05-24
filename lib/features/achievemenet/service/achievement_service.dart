import 'package:modern_learner_production/core/supabase/supabase_service.dart';
import 'package:modern_learner_production/features/achievemenet/data/achievement_catalog.dart';
import 'package:modern_learner_production/features/achievemenet/model/achievement_model.dart';

const _table = 'user_achievements';

class AchievementService {
  const AchievementService();

  Future<List<UserAchievement>> fetchAchievements() async {
    final progressById = await _fetchProgressById();
    return AchievementCatalog.all
        .map((definition) {
          return UserAchievement(
            definition: definition,
            progress:
                progressById[definition.id] ??
                AchievementProgress(achievementId: definition.id),
          );
        })
        .toList(growable: false);
  }

  Future<List<UserAchievement>> recordSignal(AchievementSignal signal) async {
    final userId = _currentUserId;
    if (userId == null) return const [];

    final progressById = await _fetchProgressById();
    final changed = <UserAchievement>[];
    final now = DateTime.now().toUtc();

    for (final definition in AchievementCatalog.matchingMetric(signal.metric)) {
      final current =
          progressById[definition.id] ??
          AchievementProgress(achievementId: definition.id);
      final nextValue = signal.absoluteValue == null
          ? current.progressValue + signal.incrementBy
          : signal.absoluteValue!.clamp(current.progressValue, 1 << 31);
      final didUnlock =
          current.unlockedAt == null && nextValue >= definition.target;
      final next = current.copyWith(
        progressValue: nextValue,
        unlockedAt: didUnlock ? now : current.unlockedAt,
        metadata: {
          ...current.metadata,
          ...signal.metadata,
          'last_metric': signal.metric.name,
        },
      );

      await supabase
          .from(_table)
          .upsert(
            next.toUpsertMap(userId),
            onConflict: 'user_id,achievement_id',
          );

      if (didUnlock || next.progressValue != current.progressValue) {
        changed.add(UserAchievement(definition: definition, progress: next));
      }
    }

    return changed;
  }

  Future<List<UserAchievement>> recordSignals(
    Iterable<AchievementSignal> signals,
  ) async {
    final changedById = <String, UserAchievement>{};
    for (final signal in signals) {
      final changed = await recordSignal(signal);
      for (final achievement in changed) {
        changedById[achievement.definition.id] = achievement;
      }
    }
    return changedById.values.toList(growable: false);
  }

  Future<List<UserAchievement>> recordProgressPageCompletion({
    required int xpEarned,
    required int completedChapterNumber,
    required int totalChapters,
    bool isVoiceLesson = false,
  }) {
    final courseProgressPercent = totalChapters <= 0
        ? 0
        : ((completedChapterNumber / totalChapters) * 100).round();

    return recordSignals([
      const AchievementSignal(metric: AchievementMetric.activitiesCompleted),
      const AchievementSignal(
        metric: AchievementMetric.learningActivitiesCompleted,
      ),
      const AchievementSignal(metric: AchievementMetric.exercisesCompleted),
      const AchievementSignal(metric: AchievementMetric.lessonsCompleted),
      AchievementSignal(
        metric: AchievementMetric.xpEarned,
        incrementBy: xpEarned,
      ),
      AchievementSignal(
        metric: AchievementMetric.courseProgressPercent,
        absoluteValue: courseProgressPercent,
        metadata: {
          'completed_chapter_number': completedChapterNumber,
          'total_chapters': totalChapters,
        },
      ),
      const AchievementSignal(
        metric: AchievementMetric.coursesWithProgress,
        absoluteValue: 1,
      ),
      if (isVoiceLesson)
        const AchievementSignal(
          metric: AchievementMetric.voiceLessonsCompleted,
        ),
    ]);
  }

  Future<void> markSeen(Iterable<String> achievementIds) async {
    final ids = achievementIds.toSet();
    final userId = _currentUserId;
    if (userId == null || ids.isEmpty) return;

    await supabase
        .from(_table)
        .update({'seen_at': DateTime.now().toUtc().toIso8601String()})
        .eq('user_id', userId)
        .inFilter('achievement_id', ids.toList(growable: false));
  }

  Future<Map<String, AchievementProgress>> _fetchProgressById() async {
    final userId = _currentUserId;
    if (userId == null) return const {};

    final List<dynamic> rows;
    try {
      rows = await supabase
          .from(_table)
          .select(
            'achievement_id, progress_value, unlocked_at, seen_at, metadata',
          )
          .eq('user_id', userId);
    } catch (_) {
      return const {};
    }

    return {
      for (final row in rows)
        row['achievement_id'] as String: AchievementProgress.fromMap(
          Map<String, dynamic>.from(row as Map),
        ),
    };
  }

  String? get _currentUserId => supabase.auth.currentUser?.id;
}
