import 'package:flutter/foundation.dart';
import 'package:modern_learner_production/features/progress/domain/entities/progress_course_selection.dart';

/// Holds courses created from the Explore page so the Home page can display them.
class ExploreCoursesService {
  ExploreCoursesService._();
  static final ExploreCoursesService instance = ExploreCoursesService._();

  final ValueNotifier<List<ProgressCourseSelection>> courses =
      ValueNotifier(const []);

  void addCourse(ProgressCourseSelection course) {
    final current = courses.value;
    final alreadyExists = current.any(
      (c) => c.title == course.title && c.topic == course.topic,
    );
    if (!alreadyExists) {
      courses.value = [course, ...current];
    }
  }

  void removeCourse(ProgressCourseSelection course) {
    courses.value =
        courses.value.where((c) => c != course).toList(growable: false);
  }
}
