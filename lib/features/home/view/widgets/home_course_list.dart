import 'package:flutter/material.dart';
import 'package:modern_learner_production/core/models/progress_course_selection.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/explore/service/explore_courses_service.dart';
import 'package:modern_learner_production/features/home/view/widgets/lesson_card.dart';

/// Course list widget that displays continue learning courses.
class HomeCourseList extends StatelessWidget {
  const HomeCourseList({
    super.key,
    required this.onCourseTap,
    required this.onCourseLongPress,
  });

  final Function(ProgressCourseSelection course) onCourseTap;
  final Function(ProgressCourseSelection course) onCourseLongPress;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<ProgressCourseSelection>>(
      valueListenable: ExploreCoursesService.instance.courses,
      builder: (context, courses, _) {
        if (courses.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: courses
                .map(
                  (course) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onLongPress: () => onCourseLongPress(course),
                      child: LessonCard(
                        emoji: '🎓',
                        title: course.topic,
                        chapter: course.title,
                        duration: course.level,
                        progress: 0.0,
                        accentColor: AppColors.primary,
                        isNew: !course.roadmapGenerated,
                        lessonType: course.roadmapGenerated
                            ? (course.title == 'Languages'
                                  ? 'language'
                                  : 'school')
                            : null,
                        onTap: () => onCourseTap(course),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}
