import 'package:flutter/material.dart';
import 'package:modern_learner_production/home/data/home_data.dart';
import 'package:modern_learner_production/home/widgets/stat_card.dart';
import 'package:modern_learner_production/theme/theme.dart';

class QuickStatsSection extends StatelessWidget {
  const QuickStatsSection({super.key, required this.animate});

  final bool animate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EduSpacing.pagePadding,
          child: Text('Quick stats', style: Theme.of(context).textTheme.headlineSmall),
        ),
        const SizedBox(height: EduSpacing.s4),
        Padding(
          padding: EduSpacing.pagePadding,
          child: Row(
            children: mockStats.map((stat) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: stat == mockStats.last ? 0 : EduSpacing.s3,
                  ),
                  child: StatCard(stat: stat, animate: animate),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
