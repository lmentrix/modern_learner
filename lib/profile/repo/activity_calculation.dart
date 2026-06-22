import 'package:modern_learner_production/profile/model/profile_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

typedef ActivityClock = DateTime Function();

final class ActivityCalculation {
  ActivityCalculation(this._client, {ActivityClock clock = DateTime.now})
    : _clock = clock;

  final SupabaseClient _client;
  final ActivityClock _clock;

  DateTime? _sessionStartedAt;
  Duration _unrecorded = Duration.zero;
  bool _sessionRecorded = false;

  bool get isTracking => _sessionStartedAt != null;

  void startTracking() {
    _sessionStartedAt ??= _clock();
  }

  Future<ActivitySummary> sync({
    required String userId,
    bool stopTracking = false,
  }) async {
    await _recordElapsed(stopTracking: stopTracking);
    return fetchSummary(userId);
  }

  Future<ActivitySummary> fetchSummary(String userId) async {
    final today = _dateOnly(_clock());
    final firstDate = today.subtract(const Duration(days: 69));
    final response = await _client
        .from('learning_activity_days')
        .select('activity_date, active_seconds')
        .eq('user_id', userId)
        .gte('activity_date', _dateKey(firstDate))
        .lte('activity_date', _dateKey(today))
        .order('activity_date');

    final records = (response as List<dynamic>)
        .map(
          (row) =>
              ActivityRecord.fromJson(Map<String, dynamic>.from(row as Map)),
        )
        .toList(growable: false);
    final summary = summarize(records: records, today: today);

    await _client.from('learning_activity').upsert({
      'user_id': userId,
      'best_week_days': summary.bestWeekDays,
      'this_week_days': summary.thisWeekDays,
      'total_active_days': summary.totalActiveDays,
      'activity_days': summary.activityDays
          .map(
            (day) => {
              'date': _dateKey(day.date),
              'intensity': day.intensity,
              'active_seconds': day.activeSeconds,
            },
          )
          .toList(growable: false),
      'weeks_tracked': summary.weeksTracked,
      'updated_at': _clock().toUtc().toIso8601String(),
    }, onConflict: 'user_id');

    return summary;
  }

  Future<void> _recordElapsed({required bool stopTracking}) async {
    final startedAt = _sessionStartedAt;
    if (startedAt == null) return;

    final now = _clock();
    final elapsed = now.difference(startedAt);
    if (!elapsed.isNegative) {
      _unrecorded += elapsed;
    }
    _sessionStartedAt = stopTracking ? null : now;

    final seconds = _unrecorded.inSeconds;
    if (seconds <= 0) return;

    await _client.rpc(
      'record_learning_activity',
      params: {
        'p_active_seconds': seconds.clamp(0, 3600),
        'p_activity_date': _dateKey(now),
        'p_new_session': !_sessionRecorded,
      },
    );

    _unrecorded -= Duration(seconds: seconds.clamp(0, 3600));
    _sessionRecorded = !stopTracking;
    if (stopTracking) {
      _sessionRecorded = false;
    }
  }

  static ActivitySummary summarize({
    required List<ActivityRecord> records,
    required DateTime today,
  }) {
    final normalizedToday = _dateOnly(today);
    final firstDate = normalizedToday.subtract(const Duration(days: 69));
    final secondsByDate = <DateTime, int>{
      for (final record in records)
        _dateOnly(record.date): record.activeSeconds,
    };
    final activityDays = List.generate(70, (index) {
      final date = firstDate.add(Duration(days: index));
      final seconds = secondsByDate[date] ?? 0;
      return ActivityDay(
        date: date,
        intensity: activityIntensity(seconds),
        activeSeconds: seconds,
      );
    }, growable: false);

    final activeDays = activityDays
        .where((day) => day.activeSeconds > 0)
        .toList(growable: false);
    final thisWeekStart = normalizedToday.subtract(
      Duration(days: normalizedToday.weekday - DateTime.monday),
    );
    final activeDaysByWeek = <DateTime, int>{};
    for (final day in activeDays) {
      final weekStart = day.date.subtract(
        Duration(days: day.date.weekday - DateTime.monday),
      );
      activeDaysByWeek.update(
        weekStart,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }

    final bestWeekDays = activeDaysByWeek.values.fold<int>(
      0,
      (best, count) => count > best ? count : best,
    );
    final earliestActiveDate = activeDays.isEmpty
        ? null
        : activeDays.first.date;
    final weeksTracked = earliestActiveDate == null
        ? 0
        : ((normalizedToday.difference(earliestActiveDate).inDays + 1) / 7)
              .ceil()
              .clamp(1, 10);

    return ActivitySummary(
      bestWeekDays: bestWeekDays,
      thisWeekDays: activeDaysByWeek[thisWeekStart] ?? 0,
      totalActiveDays: activeDays.length,
      activityDays: activityDays,
      weeksTracked: weeksTracked,
      todayActiveSeconds: secondsByDate[normalizedToday] ?? 0,
    );
  }

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

final class ActivityRecord {
  const ActivityRecord({required this.date, required this.activeSeconds});

  factory ActivityRecord.fromJson(Map<String, dynamic> json) => ActivityRecord(
    date: DateTime.parse(json['activity_date'] as String),
    activeSeconds: json['active_seconds'] as int? ?? 0,
  );

  final DateTime date;
  final int activeSeconds;
}

final class ActivitySummary {
  const ActivitySummary({
    required this.bestWeekDays,
    required this.thisWeekDays,
    required this.totalActiveDays,
    required this.activityDays,
    required this.weeksTracked,
    required this.todayActiveSeconds,
  });

  final int bestWeekDays;
  final int thisWeekDays;
  final int totalActiveDays;
  final List<ActivityDay> activityDays;
  final int weeksTracked;
  final int todayActiveSeconds;
}
