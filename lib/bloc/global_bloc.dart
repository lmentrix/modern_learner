import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:modern_learner_production/profile/model/profile_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'global_event.dart';
part 'global_state.dart';

class GlobalBloc extends Bloc<GlobalEvent, GlobalState> {
  GlobalBloc() : super(GlobalInitial()) {
    on<FetchGlobalStats>(_onFetch);
    on<RefreshGlobalStats>(_onRefresh);
  }

  String? _userId;

  Future<void> _onFetch(FetchGlobalStats event, Emitter<GlobalState> emit) async {
    _userId = event.userId;
    emit(GlobalLoading());
    await _load(emit);
  }

  Future<void> _onRefresh(RefreshGlobalStats event, Emitter<GlobalState> emit) async {
    if (_userId == null) return;
    await _load(emit);
  }

  Future<void> _load(Emitter<GlobalState> emit) async {
    try {
      final client = Supabase.instance.client;
      final now = DateTime.now();
      final since = now.subtract(const Duration(days: 70));

      final progress = await client
          .from('user_progress')
          .select(
            'total_xp, xp_goal, level, streak, completed_lessons, '
            'hours_studied, notes_count',
          )
          .eq('user_id', _userId!)
          .maybeSingle();
      final activityRows = await client
          .from('learning_activity_days')
          .select('activity_date, active_seconds')
          .eq('user_id', _userId!)
          .gte('activity_date', since.toIso8601String().substring(0, 10))
          .order('activity_date');
      final profile = await _safeProfile(client, _userId!);

      final progressData = progress ?? {};
      final rows =
          (activityRows as List<dynamic>).cast<Map<String, dynamic>>();

      final days = _buildActivityDays(rows);
      final weekStats = _computeWeekStats(days);

      emit(GlobalLoaded(
        streak: (progressData['streak'] as int?) ?? 0,
        xp: (progressData['total_xp'] as int?) ?? 0,
        level: (progressData['level'] as int?) ?? 0,
        xpGoal: (progressData['xp_goal'] as int?) ?? 5000,
        hoursStudied: (progressData['hours_studied'] as int?) ?? 0,
        lessonsCompleted:
            (progressData['completed_lessons'] as Map<String, dynamic>? ?? {}).length,
        notesCount: (progressData['notes_count'] as int?) ?? 0,
        weeksTracked: 10,
        bestWeekDays: weekStats.bestWeekDays,
        thisWeekDays: weekStats.thisWeekDays,
        totalActiveDays: weekStats.totalActiveDays,
        displayName: profile['name'] ?? '',
        avatarInitials: _initials(profile['name'] ?? ''),
        joinedDate: _formatJoinDate(profile['created_at']),
        activityDays: days,
      ));
    } catch (e) {
      emit(GlobalError(e.toString()));
    }
  }

  Future<Map<String, String>> _safeProfile(SupabaseClient client, String userId) async {
    try {
      final result = await client
          .from('profiles')
          .select('name, email, created_at')
          .eq('id', userId)
          .maybeSingle();

      if (result != null && (result['email'] as String?)?.isNotEmpty == true) {
        return {
          'name': result['name'] ?? '',
          'email': result['email'] ?? '',
          'created_at': result['created_at']?.toString() ?? '',
        };
      }

      final authUser = client.auth.currentUser;
      if (authUser == null) return <String, String>{};

      final name = (authUser.userMetadata?['name'] as String?) ?? '';
      final email = authUser.email ?? '';
      await client.from('profiles').upsert({
        'id': userId,
        'name': name,
        'email': email,
      }, onConflict: 'id');
      return {
        'name': name,
        'email': email,
        'created_at': authUser.createdAt,
      };
    } catch (_) {
      final authUser = client.auth.currentUser;
      return authUser != null
          ? {
              'name': (authUser.userMetadata?['name'] as String?) ?? '',
              'email': authUser.email ?? '',
              'created_at': authUser.createdAt,
            }
          : <String, String>{};
    }
  }

  List<ActivityDay> _buildActivityDays(List<Map<String, dynamic>> rows) {
    final Map<DateTime, int> activityMap = {};
    for (final row in rows) {
      final date = DateTime.parse(row['activity_date'] as String);
      final seconds = (row['active_seconds'] as int?) ?? 0;
      final intensity = seconds <= 0
          ? 0
          : seconds <= 600
              ? 1
              : seconds <= 1800
                  ? 2
                  : 3;
      activityMap[DateTime(date.year, date.month, date.day)] = intensity;
    }

    final now = DateTime.now();
    final days = <ActivityDay>[];
    for (var i = 69; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key = DateTime(date.year, date.month, date.day);
      days.add(ActivityDay(date: key, intensity: activityMap[key] ?? 0));
    }
    return days;
  }

  _WeekStats _computeWeekStats(List<ActivityDay> days) {
    int totalActiveDays = 0;
    int bestWeekDays = 0;
    int thisWeekDays = 0;

    final now = DateTime.now();
    final startOfThisWeek = now.subtract(Duration(days: now.weekday - 1));

    final Map<int, int> weekActiveDays = {};
    for (final day in days) {
      if (day.intensity > 0) {
        totalActiveDays++;
        final weekIndex =
            day.date.difference(days.first.date).inDays ~/ 7;
        weekActiveDays[weekIndex] = (weekActiveDays[weekIndex] ?? 0) + 1;

        final isThisWeek = !day.date.isBefore(
          DateTime(
            startOfThisWeek.year,
            startOfThisWeek.month,
            startOfThisWeek.day,
          ),
        );
        if (isThisWeek) thisWeekDays++;
      }
    }
    bestWeekDays = weekActiveDays.values.fold(0, (a, b) => a > b ? a : b);

    return _WeekStats(
      bestWeekDays: bestWeekDays,
      thisWeekDays: thisWeekDays,
      totalActiveDays: totalActiveDays,
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.length >= 2
        ? name.substring(0, 2).toUpperCase()
        : name.toUpperCase();
  }

  String _formatJoinDate(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return '';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.year}';
  }
}

class _WeekStats {
  const _WeekStats({
    required this.bestWeekDays,
    required this.thisWeekDays,
    required this.totalActiveDays,
  });
  final int bestWeekDays;
  final int thisWeekDays;
  final int totalActiveDays;
}
