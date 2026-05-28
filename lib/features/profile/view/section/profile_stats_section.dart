import 'package:flutter/material.dart';
import 'package:modern_learner_production/core/supabase/supabase_service.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_skeletons.dart';
import 'package:modern_learner_production/features/profile/view/widgets/stats_card.dart';

class _StatsData {
  const _StatsData({
    required this.streak,
    required this.totalXp,
    required this.exercisesCompleted,
  });
  final int streak;
  final int totalXp;
  final int exercisesCompleted;
}

class ProfileStatsSection extends StatefulWidget {
  const ProfileStatsSection({super.key});

  @override
  State<ProfileStatsSection> createState() => _ProfileStatsSectionState();
}

class _ProfileStatsSectionState extends State<ProfileStatsSection> {
  Future<_StatsData>? _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_StatsData> _load() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return const _StatsData(streak: 0, totalXp: 0, exercisesCompleted: 0);

    final results = await Future.wait([
      // Course XP: sum exercise_xp and exercises_completed from profile_course_xp
      supabase
          .from('profile_course_xp')
          .select('exercise_xp, exercises_completed')
          .eq('user_id', userId),
      // Streak: count consecutive days with activity ending today
      supabase
          .from('learning_activity_days')
          .select('activity_date')
          .eq('user_id', userId)
          .gt('active_seconds', 0)
          .order('activity_date', ascending: false)
          .limit(365),
    ]);

    final xpRows = results[0] as List<dynamic>;
    int totalXp = 0;
    int exercisesCompleted = 0;
    for (final row in xpRows) {
      totalXp += (row['exercise_xp'] as num?)?.toInt() ?? 0;
      exercisesCompleted += (row['exercises_completed'] as num?)?.toInt() ?? 0;
    }

    final activityDates = (results[1] as List<dynamic>)
        .map((r) => r['activity_date'] as String)
        .toList();

    final streak = _computeStreak(activityDates);

    return _StatsData(
      streak: streak,
      totalXp: totalXp,
      exercisesCompleted: exercisesCompleted,
    );
  }

  int _computeStreak(List<String> sortedDatesDesc) {
    if (sortedDatesDesc.isEmpty) return 0;
    final today = DateTime.now();
    final todayKey = _dateKey(today);
    final yesterdayKey = _dateKey(today.subtract(const Duration(days: 1)));

    // Streak is valid only if user was active today or yesterday.
    if (sortedDatesDesc.first != todayKey &&
        sortedDatesDesc.first != yesterdayKey) {
      return 0;
    }

    var streak = 0;
    DateTime cursor = sortedDatesDesc.first == todayKey ? today : today.subtract(const Duration(days: 1));

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

  String _formatXp(int xp) {
    if (xp >= 1000) return '${(xp / 1000).toStringAsFixed(1)}K';
    return '$xp';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_StatsData>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData && !snapshot.hasError) {
          return const ProfileStatsSkeleton();
        }

        final data = snapshot.data;
        final streak = data?.streak ?? 0;
        final xp = data?.totalXp ?? 0;
        final completed = data?.exercisesCompleted ?? 0;

        return Row(
          children: [
            Expanded(
              child: StatsCard(
                icon: Icons.local_fire_department_rounded,
                label: 'Day Streak',
                value: '$streak',
                accentColor: const Color(0xFFFF9500),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatsCard(
                icon: Icons.star_rounded,
                label: 'Total XP',
                value: _formatXp(xp),
                accentColor: AppColors.tertiaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatsCard(
                icon: Icons.check_circle_rounded,
                label: 'Completed',
                value: '$completed',
                accentColor: AppColors.primary,
              ),
            ),
          ],
        );
      },
    );
  }
}
