import 'package:supabase_flutter/supabase_flutter.dart';

typedef StreakClock = DateTime Function();

final class StreakCalculation {
  StreakCalculation(this._client, {StreakClock clock = DateTime.now})
    : _clock = clock;

  final SupabaseClient _client;
  final StreakClock _clock;

  DateTime? _recordedOnlineDay;

  Future<int> syncOnlineDayAndFetchStreak({required String userId}) async {
    final today = dateOnly(_clock());
    if (_recordedOnlineDay != today) {
      await _client.rpc(
        'record_learning_activity',
        params: {
          'p_active_seconds': 1,
          'p_activity_date': dateKey(today),
          'p_new_session': false,
        },
      );
      _recordedOnlineDay = today;
    }

    final streak = await fetchCurrentStreak(userId: userId, today: today);
    await _client.from('user_progress').upsert({
      'user_id': userId,
      'streak': streak,
      'last_updated': _clock().toUtc().toIso8601String(),
    }, onConflict: 'user_id');

    return streak;
  }

  Future<int> fetchCurrentStreak({
    required String userId,
    DateTime? today,
  }) async {
    final normalizedToday = dateOnly(today ?? _clock());
    final response = await _client
        .from('learning_activity_days')
        .select('activity_date')
        .eq('user_id', userId)
        .gt('active_seconds', 0)
        .lte('activity_date', dateKey(normalizedToday))
        .order('activity_date', ascending: false);

    final activeDates = (response as List<dynamic>).map((row) {
      final json = Map<String, dynamic>.from(row as Map);
      return DateTime.parse(json['activity_date'] as String);
    });

    return calculateCurrentStreak(
      activeDates: activeDates,
      today: normalizedToday,
    );
  }

  static int calculateCurrentStreak({
    required Iterable<DateTime> activeDates,
    required DateTime today,
  }) {
    final activeDateKeys = {
      for (final date in activeDates) dateKey(dateOnly(date)),
    };

    var streak = 0;
    var cursor = dateOnly(today);
    while (activeDateKeys.contains(dateKey(cursor))) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  static DateTime dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static String dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
