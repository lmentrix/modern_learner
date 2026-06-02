import 'package:flutter/foundation.dart';
import 'package:modern_learner_production/core/supabase/supabase_service.dart';

class StreakService {
  StreakService._();

  static final StreakService instance = StreakService._();

  final ValueNotifier<int> currentStreak = ValueNotifier<int>(0);

  bool _loaded = false;

  Future<int> fetchAndUpdate() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      currentStreak.value = 0;
      return 0;
    }

    final rows = await supabase
        .from('learning_activity_days')
        .select('activity_date')
        .eq('user_id', userId)
        .gt('active_seconds', 0)
        .order('activity_date', ascending: false)
        .limit(365);

    final dates = (rows as List<dynamic>)
        .map((r) => r['activity_date'] as String)
        .toList();

    final streak = _computeStreak(dates);
    currentStreak.value = streak;
    _loaded = true;
    return streak;
  }

  bool get isLoaded => _loaded;

  static int _computeStreak(List<String> sortedDatesDesc) {
    if (sortedDatesDesc.isEmpty) return 0;
    final today = DateTime.now();
    final todayKey = _dateKey(today);
    final yesterdayKey = _dateKey(today.subtract(const Duration(days: 1)));

    if (sortedDatesDesc.first != todayKey &&
        sortedDatesDesc.first != yesterdayKey) {
      return 0;
    }

    var streak = 0;
    DateTime cursor = sortedDatesDesc.first == todayKey
        ? today
        : today.subtract(const Duration(days: 1));

    for (final dateStr in sortedDatesDesc) {
      if (dateStr == _dateKey(cursor)) {
        streak++;
        cursor = cursor.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  static String _dateKey(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }
}
