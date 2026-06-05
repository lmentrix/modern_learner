import 'package:flutter/material.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/core/utils/responsive.dart';
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
    final hPad = Responsive.hPad(context);
    final gap = Responsive.isTabletOrDesktop(context) ? 16.0 : 12.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Responsive.maxContentWidth),
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
              SizedBox(width: gap),
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
        ),
      ),
    );
  }
}
