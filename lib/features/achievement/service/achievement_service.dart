import 'package:modern_learner_production/core/supabase/supabase_service.dart';
import 'package:modern_learner_production/features/achievement/model/achievement_model.dart';

class AchievementService {
  AchievementService();

  static const String _definitionsTable = 'achievement_definitions';
  static const String _progressTable = 'user_achievement_progress';
  static const String _courseXpTable = 'profile_course_xp';

  String? get currentUserId => supabase.auth.currentUser?.id;

  Future<List<AchievementDefinitionModel>> getDefinitions() async {
    final data = await supabase
        .from(_definitionsTable)
        .select()
        .eq('is_active', true)
        .order('sort_order')
        .order('key');

    return data.map(AchievementDefinitionModel.fromJson).toList();
  }

  Future<List<UserAchievementProgressModel>> getUserProgress({
    String? userId,
  }) async {
    final resolvedUserId = _resolveUserId(userId);
    final data = await supabase
        .from(_progressTable)
        .select()
        .eq('user_id', resolvedUserId);

    return data.map(UserAchievementProgressModel.fromJson).toList();
  }

  Future<List<UserAchievementProgressModel>> getCourseProgress({
    String? userId,
    required String courseKey,
  }) async {
    final resolvedUserId = _resolveUserId(userId);
    final data = await supabase
        .from(_progressTable)
        .select()
        .eq('user_id', resolvedUserId)
        .eq('course_key', courseKey);

    return data.map(UserAchievementProgressModel.fromJson).toList();
  }

  Future<List<UserAchievementProgressModel>> getUnlockedProgress({
    String? userId,
  }) async {
    final resolvedUserId = _resolveUserId(userId);
    final data = await supabase
        .from(_progressTable)
        .select()
        .eq('user_id', resolvedUserId)
        .not('unlocked_at', 'is', null)
        .order('unlocked_at', ascending: false);

    return data.map(UserAchievementProgressModel.fromJson).toList();
  }

  Future<UserAchievementProgressModel> upsertProgress(
    UserAchievementProgressModel progress,
  ) async {
    final data = await supabase
        .from(_progressTable)
        .upsert(
          progress.toJson(),
          onConflict: 'user_id,achievement_key,course_key',
        )
        .select()
        .single();

    return UserAchievementProgressModel.fromJson(data);
  }

  Future<UserAchievementProgressModel> updateProgress({
    String? userId,
    required String achievementKey,
    String courseKey = 'global',
    required int progressValue,
    DateTime? unlockedAt,
  }) async {
    final resolvedUserId = _resolveUserId(userId);
    final updates = <String, dynamic>{'progress_value': progressValue};
    if (unlockedAt != null) {
      updates['unlocked_at'] = unlockedAt.toUtc().toIso8601String();
    }

    final data = await supabase
        .from(_progressTable)
        .update(updates)
        .eq('user_id', resolvedUserId)
        .eq('achievement_key', achievementKey)
        .eq('course_key', courseKey)
        .select()
        .single();

    return UserAchievementProgressModel.fromJson(data);
  }

  Future<void> markSeen({
    String? userId,
    required String achievementKey,
    String courseKey = 'global',
    DateTime? seenAt,
  }) async {
    final resolvedUserId = _resolveUserId(userId);
    await supabase
        .from(_progressTable)
        .update({
          'seen_at': (seenAt ?? DateTime.now()).toUtc().toIso8601String(),
        })
        .eq('user_id', resolvedUserId)
        .eq('achievement_key', achievementKey)
        .eq('course_key', courseKey);
  }

  Future<void> deleteProgress({
    String? userId,
    required String achievementKey,
    String courseKey = 'global',
  }) async {
    final resolvedUserId = _resolveUserId(userId);
    await supabase
        .from(_progressTable)
        .delete()
        .eq('user_id', resolvedUserId)
        .eq('achievement_key', achievementKey)
        .eq('course_key', courseKey);
  }


  Future<List<ProfileCourseXpModel>> getCourseXp({String? userId}) async {
    final resolvedUserId = _resolveUserId(userId);
    final data = await supabase
        .from(_courseXpTable)
        .select('*, user_courses(title, topic)')
        .eq('user_id', resolvedUserId)
        .order('exercise_xp', ascending: false)
        .order('course_key');

    return data.map(ProfileCourseXpModel.fromJson).toList();
  }

  Future<ProfileCourseXpModel?> getCourseXpByKey({
    String? userId,
    required String courseKey,
  }) async {
    final resolvedUserId = _resolveUserId(userId);
    final data = await supabase
        .from(_courseXpTable)
        .select()
        .eq('user_id', resolvedUserId)
        .eq('course_key', courseKey)
        .maybeSingle();

    if (data == null) return null;
    return ProfileCourseXpModel.fromJson(data);
  }

  Future<ProfileCourseXpModel> upsertCourseXp(
    ProfileCourseXpModel courseXp,
  ) async {
    final data = await supabase
        .from(_courseXpTable)
        .upsert(courseXp.toJson(), onConflict: 'user_id,course_key')
        .select()
        .single();

    return ProfileCourseXpModel.fromJson(data);
  }

  Future<void> syncProfileSnapshot({
    String? userId,
    required List<AchievementDefinitionModel> definitions,
    required List<ProfileCourseXpModel> courseXp,
  }) async {
    final resolvedUserId = _resolveUserId(userId);
    final existingProgress = await getUserProgress(userId: resolvedUserId);
    final existingByKey = {
      for (final progress in existingProgress)
        '${progress.achievementKey}:${progress.courseKey}': progress,
    };

    for (final data in courseXp) {
      await upsertCourseXp(data.copyWith(userId: resolvedUserId));
    }

    for (final definition in definitions) {
      switch (definition.scope) {
        case AchievementScope.account:
          final progress = _accountProgressValue(definition, courseXp);
          await _upsertProgressSnapshot(
            userId: resolvedUserId,
            definition: definition,
            courseKey: 'global',
            progressValue: progress,
            existing: existingByKey['${definition.key}:global'],
          );
        case AchievementScope.course:
          for (final data in courseXp) {
            final progress = _courseProgressValue(definition, data);
            await _upsertProgressSnapshot(
              userId: resolvedUserId,
              definition: definition,
              courseKey: data.courseKey,
              progressValue: progress,
              existing: existingByKey['${definition.key}:${data.courseKey}'],
            );
          }
      }
    }
  }

  Stream<List<UserAchievementProgressModel>> watchProgress({String? userId}) {
    final resolvedUserId = _resolveUserId(userId);
    return supabase.from(_progressTable).stream(primaryKey: ['id']).map((rows) {
      return rows
          .where((row) => row['user_id'] == resolvedUserId)
          .map(UserAchievementProgressModel.fromJson)
          .toList();
    });
  }

  Stream<List<ProfileCourseXpModel>> watchCourseXp({String? userId}) {
    final resolvedUserId = _resolveUserId(userId);
    // Streams don't support joins, so we fetch plain rows and sort client-side.
    return supabase
        .from(_courseXpTable)
        .stream(primaryKey: ['user_id', 'course_key'])
        .map((rows) {
          final courseXp = rows
              .where((row) => row['user_id'] == resolvedUserId)
              .map(ProfileCourseXpModel.fromJson)
              .toList();
          courseXp.sort((a, b) => b.exerciseXp.compareTo(a.exerciseXp));
          return courseXp;
        });
  }

  String _resolveUserId(String? userId) {
    final resolvedUserId = userId ?? currentUserId;
    if (resolvedUserId == null) {
      throw Exception('User is not authenticated');
    }
    return resolvedUserId;
  }

  Future<void> _upsertProgressSnapshot({
    required String userId,
    required AchievementDefinitionModel definition,
    required String courseKey,
    required int progressValue,
    UserAchievementProgressModel? existing,
  }) async {
    final isUnlocked = progressValue >= definition.requirementValue;
    final unlockedAt = isUnlocked
        ? (existing?.unlockedAt ?? DateTime.now())
        : existing?.unlockedAt;

    await upsertProgress(
      UserAchievementProgressModel(
        id: existing?.id,
        userId: userId,
        achievementKey: definition.key,
        courseKey: courseKey,
        progressValue: progressValue,
        unlockedAt: unlockedAt,
        seenAt: existing?.seenAt,
        metadata: existing?.metadata ?? const {},
      ),
    );
  }

  int _accountProgressValue(
    AchievementDefinitionModel definition,
    List<ProfileCourseXpModel> courseXp,
  ) {
    return switch (definition.type) {
      AchievementType.xp => courseXp.fold(
        0,
        (sum, data) => sum + data.exerciseXp,
      ),
      AchievementType.chapter => courseXp.fold(
        0,
        (max, data) =>
            data.chaptersUnlocked > max ? data.chaptersUnlocked : max,
      ),
      AchievementType.lesson => courseXp.fold(
        0,
        (sum, data) => sum + data.exercisesCompleted,
      ),
      AchievementType.streak ||
      AchievementType.level ||
      AchievementType.gems => existingUnsupportedProgress,
    };
  }

  int _courseProgressValue(
    AchievementDefinitionModel definition,
    ProfileCourseXpModel courseXp,
  ) {
    return switch (definition.type) {
      AchievementType.xp => courseXp.exerciseXp,
      AchievementType.chapter => courseXp.chaptersUnlocked,
      AchievementType.lesson => courseXp.exercisesCompleted,
      AchievementType.streak ||
      AchievementType.level ||
      AchievementType.gems => existingUnsupportedProgress,
    };
  }

  static const int existingUnsupportedProgress = 0;
}
