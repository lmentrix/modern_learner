import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/profile/view/widgets/stats_card.dart';
import 'package:modern_learner_production/features/progress/bloc/xp_bloc.dart';
import 'package:modern_learner_production/features/progress/data/progress_module_step.dart';

class ProgressStatsRow extends StatelessWidget {
  const ProgressStatsRow({
    super.key,
    required this.moduleSteps,
    required this.accentColor,
  });

  final List<ProgressModuleStep> moduleSteps;
  final Color accentColor;

  static const _xpPerChapter = 200;

  String _formatXp(int xp) {
    if (xp >= 1000) return '${(xp / 1000).toStringAsFixed(1)}K';
    return '$xp';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<XpBloc, XpState>(
      builder: (context, xpState) {
        final chapterXp = moduleSteps.fold<int>(
          0,
          (s, st) => s + (st.progress * _xpPerChapter).round(),
        );
        final totalXp = chapterXp + xpState.totalXp;
        final completedChapters = moduleSteps
            .where((s) => !s.isLocked && s.progress >= 1.0)
            .length;
        final totalChapters = moduleSteps.length;

        return Row(
          children: [
            Expanded(
              child: StatsCard(
                icon: Icons.bolt_rounded,
                label: 'Course XP',
                value: _formatXp(totalXp),
                accentColor: accentColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatsCard(
                icon: Icons.layers_rounded,
                label: 'Chapters',
                value: '$completedChapters/$totalChapters',
                accentColor: AppColors.secondary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatsCard(
                icon: Icons.fitness_center_rounded,
                label: 'Exercises',
                value: '${xpState.exercisesCompleted}',
                accentColor: const Color(0xFFFF9F43),
              ),
            ),
          ],
        );
      },
    );
  }
}
