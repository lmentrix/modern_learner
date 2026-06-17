import 'package:modern_learner_production/global_bloc/model/user_stats_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserStatsService {
  UserStatsService(this._client);

  final SupabaseClient _client;

  Future<UserStatsModel> fetchStats(String userId) async {
    final now = DateTime.now();
    final since = now.subtract(const Duration(days: 70));

    // Profile is fetched separately so a missing table / RLS error never
    // prevents user_progress and activity data from loading.
    final profileFuture = _safeProfileFetch(userId);

    final results = await Future.wait([
      _client
          .from('user_progress')
          .select(
            'total_xp, xp_goal, level, streak, completed_lessons, '
            'hours_studied, notes_count, voice_notes_count, uploaded_notes_count',
          )
          .eq('user_id', userId)
          .maybeSingle(),
      _client
          .from('learning_activity_days')
          .select('activity_date, active_seconds')
          .eq('user_id', userId)
          .gte('activity_date', since.toIso8601String().substring(0, 10))
          .order('activity_date'),
    ]);

    final progress = (results[0] as Map<String, dynamic>?) ?? {};
    final activityRows = (results[1] as List<dynamic>).cast<Map<String, dynamic>>();
    final profile = await profileFuture;

    return UserStatsModel.fromSupabase(
      progress: progress,
      activityRows: activityRows,
      profile: profile,
    );
  }

  Future<Map<String, dynamic>> _safeProfileFetch(String userId) async {
    try {
      final result = await _client
          .from('profiles')
          .select('name, email, created_at')
          .eq('id', userId)
          .maybeSingle();
      return result ?? {};
    } catch (_) {
      return {};
    }
  }

  /// Inserts today's row with zero active time if it doesn't already exist.
  /// Called on every login so today appears in the activity grid.
  /// Silently no-ops on error (e.g. during local dev before migration is applied).
  Future<void> ensureTodayActivity(String userId) async {
    try {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      await _client.from('learning_activity_days').upsert(
        {
          'user_id': userId,
          'activity_date': today,
          'active_seconds': 0,
          'sessions_count': 0,
        },
        onConflict: 'user_id,activity_date',
        ignoreDuplicates: true,
      );
    } catch (_) {}
  }

  Future<void> updateProgress(
    String userId, {
    int? xp,
    int? xpGoal,
    int? level,
    int? streak,
    int? hoursStudied,
    int? notesCount,
    int? voiceNotesCount,
    int? uploadedNotesCount,
  }) async {
    final data = <String, dynamic>{};
    if (xp != null) data['total_xp'] = xp;
    if (xpGoal != null) data['xp_goal'] = xpGoal;
    if (level != null) data['level'] = level;
    if (streak != null) data['streak'] = streak;
    if (hoursStudied != null) data['hours_studied'] = hoursStudied;
    if (notesCount != null) data['notes_count'] = notesCount;
    if (voiceNotesCount != null) data['voice_notes_count'] = voiceNotesCount;
    if (uploadedNotesCount != null) data['uploaded_notes_count'] = uploadedNotesCount;

    if (data.isEmpty) return;
    data['last_updated'] = DateTime.now().toIso8601String();

    await _client.from('user_progress').upsert({'user_id': userId, ...data});
  }

  Future<void> recordActivityDay(String userId, {int activeSeconds = 0}) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await _client.from('learning_activity_days').upsert({
      'user_id': userId,
      'activity_date': today,
      'active_seconds': activeSeconds,
      'sessions_count': 1,
    }, onConflict: 'user_id,activity_date');
  }
}
