import 'package:flutter/material.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_activity_chart.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_section_label.dart';

class ProfileActivitySection extends StatelessWidget {
  const ProfileActivitySection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSectionLabel(text: 'THIS WEEK'),
        SizedBox(height: 14),
        ProfileActivityChart(),
      ],
    );
  }
}
