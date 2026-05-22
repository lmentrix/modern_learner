import 'package:flutter/material.dart';

import 'package:modern_learner_production/core/models/progress_course_selection.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/progress/view/widgets/progress_achievement_card.dart';
import 'package:modern_learner_production/features/progress/view/widgets/progress_section_heading.dart';

class ProgressAchievementSection extends StatefulWidget {
  const ProgressAchievementSection({
    super.key,
    required this.courses,
  });

  final List<ProgressCourseSelection> courses;

  @override
  State<ProgressAchievementSection> createState() =>
      _ProgressAchievementSectionState();
}

class _ProgressAchievementSectionState
    extends State<ProgressAchievementSection> {
  String? _selectedCourseKey;

  String _courseKey(ProgressCourseSelection c) =>
      '${c.title}::${c.topic}::${c.level}';

  @override
  Widget build(BuildContext context) {
    final courses = widget.courses;

    if (courses.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProgressSectionHeading(
          eyebrow: 'ACHIEVEMENTS',
          title: 'Progress across courses',
          subtitle:
              'A quick snapshot of where each course stands — tap a card to see the full breakdown.',
          accentColor: AppColors.primary,
        ),
        const SizedBox(height: 18),
        Column(
          children: [
            for (int i = 0; i < courses.length; i++)
              Padding(
                padding: EdgeInsets.only(bottom: i < courses.length - 1 ? 12 : 0),
                child: ProgressAchievementCard(
                  course: courses[i],
                  isSelected: _selectedCourseKey == _courseKey(courses[i]),
                  onTap: () {
                    final key = _courseKey(courses[i]);
                    setState(() {
                      _selectedCourseKey =
                          _selectedCourseKey == key ? null : key;
                    });
                  },
                ),
              ),
          ],
        ),
      ],
    );
  }
}
