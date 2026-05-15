import 'package:flutter/material.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/home/view/widgets/home_lesson_quick_access_card.dart';

/// Lesson quick access cards for voice and school lessons.
class HomeLessonQuickAccess extends StatelessWidget {
  const HomeLessonQuickAccess({
    super.key,
    required this.onVoiceLessonTap,
    required this.onSchoolLessonTap,
  });

  final VoidCallback onVoiceLessonTap;
  final VoidCallback onSchoolLessonTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: HomeLessonQuickAccessCard(
              title: 'Voice Lesson',
              subtitle: 'Practice pronunciation',
              emoji: '🎤',
              color: AppColors.primary,
              onTap: onVoiceLessonTap,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: HomeLessonQuickAccessCard(
              title: 'School Lesson',
              subtitle: 'Learn academics',
              emoji: '📚',
              color: AppColors.secondary,
              onTap: onSchoolLessonTap,
            ),
          ),
        ],
      ),
    );
  }
}
