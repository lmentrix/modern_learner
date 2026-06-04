import 'package:flutter/material.dart';
import 'package:modern_learner_production/core/supabase/supabase_service.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/profile/service/streak_service.dart';
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
    if (userId == null) {
      return const _StatsData(streak: 0, totalXp: 0, exercisesCompleted: 0);
    }

    final xpFuture = supabase
        .from('profile_course_xp')
        .select('exercise_xp, exercises_completed, user_courses!inner(id)')
        .eq('user_id', userId);
    final streakFuture = StreakService.instance.fetchAndUpdate();

    final xpRows = await xpFuture;
    final streak = await streakFuture;

    int totalXp = 0;
    int exercisesCompleted = 0;
    for (final row in xpRows) {
      totalXp += (row['exercise_xp'] as num?)?.toInt() ?? 0;
      exercisesCompleted += (row['exercises_completed'] as num?)?.toInt() ?? 0;
    }

    return _StatsData(
      streak: streak,
      totalXp: totalXp,
      exercisesCompleted: exercisesCompleted,
    );
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
