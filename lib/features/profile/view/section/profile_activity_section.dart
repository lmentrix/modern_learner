import 'package:flutter/material.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/core/theme/app_text_styles.dart';
import 'package:modern_learner_production/features/profile/data/learning_activity_summary.dart';
import 'package:modern_learner_production/features/profile/service/learning_activity_service.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_activity_chart.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_section_label.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_skeletons.dart';

class ProfileActivitySection extends StatefulWidget {
  const ProfileActivitySection({super.key});

  @override
  State<ProfileActivitySection> createState() => _ProfileActivitySectionState();
}

class _ProfileActivitySectionState extends State<ProfileActivitySection> {
  Future<LearningActivitySummary>? _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<LearningActivitySummary> _load() async {
    await LearningActivityService.instance.flushPending();
    return LearningActivityService.instance.fetchCurrentWeek();
  }

  void _refresh() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProfileSectionLabel(text: 'THIS WEEK'),
        const SizedBox(height: 14),
        FutureBuilder<LearningActivitySummary>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const _ActivitySkeletonInline();
            }
            if (snapshot.hasError) {
              return _errorCard();
            }
            return ProfileActivityChart.fromSummary(
              summary: snapshot.data!,
              onRefresh: _refresh,
              isLoading: snapshot.connectionState == ConnectionState.waiting,
            );
          },
        ),
      ],
    );
  }

  Widget _errorCard() {
    return Container(
      height: 80,
      alignment: Alignment.center,
      child: Text(
        'Could not load activity',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}

// Renders only the chart card skeleton (label already shown by parent Column).
class _ActivitySkeletonInline extends StatelessWidget {
  const _ActivitySkeletonInline();

  @override
  Widget build(BuildContext context) {
    // Reuse the full skeleton but clip just the card portion (skip its label).
    return const ProfileActivitySkeleton(hideLabel: true);
  }
}
