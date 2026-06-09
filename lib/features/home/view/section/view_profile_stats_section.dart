import 'package:flutter/material.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/home/view/widgets/view_profile_stat_box.dart';

class ViewProfileStatsSection extends StatelessWidget {
  const ViewProfileStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: ViewProfileStatBox(
            icon: Icons.local_fire_department_rounded,
            value: '14',
            label: 'Day Streak',
            color: Color(0xFFFF9500),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ViewProfileStatBox(
            icon: Icons.star_rounded,
            value: '2.4K',
            label: 'Total XP',
            color: AppColors.tertiaryContainer,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ViewProfileStatBox(
            icon: Icons.check_circle_rounded,
            value: '47',
            label: 'Done',
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
