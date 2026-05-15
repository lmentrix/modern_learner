import 'package:flutter/material.dart';

import 'package:modern_learner_production/features/profile/data/profile_page_data.dart';
import 'package:modern_learner_production/features/profile/view/widgets/stats_card.dart';

class ProfileStatsSection extends StatelessWidget {
  const ProfileStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < ProfilePageData.stats.length; index++) ...[
          if (index > 0) const SizedBox(width: 12),
          Expanded(
            child: StatsCard(
              icon: ProfilePageData.stats[index].icon,
              label: ProfilePageData.stats[index].label,
              value: ProfilePageData.stats[index].value,
              accentColor: ProfilePageData.stats[index].accentColor,
            ),
          ),
        ],
      ],
    );
  }
}
