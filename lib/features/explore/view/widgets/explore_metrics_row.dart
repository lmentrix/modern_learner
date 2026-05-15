import 'package:flutter/material.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/explore/service/explore_subject.dart';
import 'package:modern_learner_production/features/explore/utils/explore_utils.dart';
import 'package:modern_learner_production/features/explore/view/widgets/explore_metric_card.dart';

class ExploreMetricsRow extends StatelessWidget {
  const ExploreMetricsRow({
    super.key,
    required this.filteredSubjects,
    required this.allSubjects,
  });

  final List<ExploreSubject> filteredSubjects;
  final List<ExploreSubject> allSubjects;

  @override
  Widget build(BuildContext context) {
    final totalWorks = filteredSubjects.fold<int>(
      0,
      (sum, s) => sum + s.workCount,
    );

    return Row(
      children: [
        Expanded(
          child: ExploreMetricCard(
            label: 'Visible',
            value: '${filteredSubjects.length}',
            hint: 'collections',
            accentColor: AppColors.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ExploreMetricCard(
            label: 'Papers',
            value: formatCount(totalWorks),
            hint: 'papers tracked',
            accentColor: AppColors.secondary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ExploreMetricCard(
            label: 'Source',
            value: 'OpenAlex',
            hint: '${allSubjects.length} feeds',
            accentColor: AppColors.tertiary,
          ),
        ),
      ],
    );
  }
}
