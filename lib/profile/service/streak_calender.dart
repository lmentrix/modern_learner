import 'package:modern_learner_production/profile/model/streak_calendar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

typedef StreakCalendarClock = DateTime Function();

final class StreakCalenderService {
  StreakCalenderService(
    this._client, {
    StreakCalendarClock clock = DateTime.now,
  }) : _clock = clock;

  final SupabaseClient _client;
  final StreakCalendarClock _clock;

  Future<StreakCalendarMonth> loadMonth({
    required String userId,
    DateTime? month,
    bool recordToday = true,
  }) async {
    final today = _dateOnly(_clock());
    final visibleMonth = _monthOnly(month ?? today);
    final firstOfMonth = visibleMonth;
    final lastOfMonth = DateTime(visibleMonth.year, visibleMonth.month + 1, 0);
    final gridStart = firstOfMonth.subtract(
      Duration(days: firstOfMonth.weekday - DateTime.monday),
    );
    final gridEnd = lastOfMonth.add(
      Duration(days: DateTime.sunday - lastOfMonth.weekday),
    );
    final historyStart = gridStart.subtract(const Duration(days: 365));

    final todayWasActive = await _isDateActive(userId: userId, date: today);
    if (recordToday) {
      await _client.rpc(
        'record_learning_activity',
        params: {
          'p_active_seconds': 1,
          'p_activity_date': _dateKey(today),
          'p_new_session': !todayWasActive,
        },
      );
    }

    final response = await _client
        .from('learning_activity_days')
        .select('activity_date, active_seconds, sessions_count')
        .eq('user_id', userId)
        .gte('activity_date', _dateKey(historyStart))
        .lte('activity_date', _dateKey(gridEnd))
        .order('activity_date');

    final records = <DateTime, _CalendarRecord>{
      for (final row in response as List<dynamic>)
        _dateOnly(
          DateTime.parse(
            Map<String, dynamic>.from(row as Map)['activity_date'] as String,
          ),
        ): _CalendarRecord.fromJson(
          Map<String, dynamic>.from(row),
        ),
    };
    final activeDates = records.entries
        .where((entry) => entry.value.activeSeconds > 0)
        .map((entry) => entry.key)
        .toSet();
    final streakDates = _currentStreakDates(
      activeDates: activeDates,
      today: today,
    );
    await _client.from('user_progress').upsert({
      'user_id': userId,
      'streak': streakDates.length,
      'last_updated': _clock().toUtc().toIso8601String(),
    }, onConflict: 'user_id');

    final days = <StreakCalendarDay>[];
    for (
      var date = gridStart;
      !date.isAfter(gridEnd);
      date = date.add(const Duration(days: 1))
    ) {
      final record = records[_dateOnly(date)];
      days.add(
        StreakCalendarDay(
          date: date,
          activeSeconds: record?.activeSeconds ?? 0,
          sessionsCount: record?.sessionsCount ?? 0,
          isInMonth:
              date.year == visibleMonth.year &&
              date.month == visibleMonth.month,
          isToday: _isSameDate(date, today),
          isStreakDay: streakDates.contains(_dateOnly(date)),
        ),
      );
    }

    final monthDays = days.where((day) => day.isInMonth);
    return StreakCalendarMonth(
      visibleMonth: visibleMonth,
      days: days,
      currentStreak: streakDates.length,
      longestStreak: _longestStreak(activeDates),
      activeDaysThisMonth: monthDays.where((day) => day.isActive).length,
      totalActiveSecondsThisMonth: monthDays.fold<int>(
        0,
        (total, day) => total + day.activeSeconds,
      ),
      igniteToday:
          recordToday && !todayWasActive && streakDates.contains(today),
    );
  }

  Future<bool> _isDateActive({
    required String userId,
    required DateTime date,
  }) async {
    final response = await _client
        .from('learning_activity_days')
        .select('active_seconds')
        .eq('user_id', userId)
        .eq('activity_date', _dateKey(date))
        .maybeSingle();
    if (response == null) return false;
    return (response['active_seconds'] as int? ?? 0) > 0;
  }

  static Set<DateTime> _currentStreakDates({
    required Set<DateTime> activeDates,
    required DateTime today,
  }) {
    final streakDates = <DateTime>{};
    var cursor = _dateOnly(today);
    while (activeDates.contains(cursor)) {
      streakDates.add(cursor);
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streakDates;
  }

  static int _longestStreak(Set<DateTime> activeDates) {
    if (activeDates.isEmpty) return 0;
    final sorted = activeDates.toList()..sort();
    var longest = 1;
    var current = 1;
    for (var index = 1; index < sorted.length; index++) {
      final previous = sorted[index - 1];
      final date = sorted[index];
      if (date.difference(previous).inDays == 1) {
        current++;
      } else {
        current = 1;
      }
      if (current > longest) longest = current;
    }
    return longest;
  }

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static DateTime _monthOnly(DateTime date) => DateTime(date.year, date.month);

  static bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

final class _CalendarRecord {
  const _CalendarRecord({
    required this.activeSeconds,
    required this.sessionsCount,
  });

  factory _CalendarRecord.fromJson(Map<String, dynamic> json) =>
      _CalendarRecord(
        activeSeconds: json['active_seconds'] as int? ?? 0,
        sessionsCount: json['sessions_count'] as int? ?? 0,
      );

  final int activeSeconds;
  final int sessionsCount;
}
