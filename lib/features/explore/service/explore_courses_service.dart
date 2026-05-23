import 'package:flutter/foundation.dart';

import 'package:modern_learner_production/core/models/progress_course_selection.dart';
import 'package:modern_learner_production/features/explore/service/user_courses_service.dart';
import 'package:modern_learner_production/features/progress/service/course_xp_service.dart';

/// Holds courses created from the Explore page and mirrors them to local
/// storage.
class ExploreCoursesService {
  ExploreCoursesService._();

  static final ExploreCoursesService instance = ExploreCoursesService._();

  final ValueNotifier<List<ProgressCourseSelection>> courses = ValueNotifier(
    const [],
  );

  UserCoursesService? _storage;

  void injectRemote(UserCoursesService service) => _storage = service;

  Future<void> loadCourses() async {
    courses.value = await _storage?.fetchCourses() ?? const [];
  }

  Future<void> addCourse(ProgressCourseSelection course) async {
    final current = courses.value;
    final duplicate = current.any((c) => _matches(c, course));
    if (duplicate) return;

    CourseXpService.instance.resetCourse(progressCourseXpKey(course));
    courses.value = [course, ...current];
    await _storage?.upsertCourse(course);
  }

  Future<void> updateCourse(ProgressCourseSelection course) async {
    final current = List<ProgressCourseSelection>.from(courses.value);
    final index = current.indexWhere((saved) => _matches(saved, course));

    if (index >= 0) {
      current[index] = course;
    } else {
      current.insert(0, course);
    }

    courses.value = current;
    await _storage?.upsertCourse(course);
  }

  Future<void> removeCourse(ProgressCourseSelection course) async {
    CourseXpService.instance.resetCourse(progressCourseXpKey(course));
    courses.value = courses.value
        .where((c) => c != course)
        .toList(growable: false);
    await _storage?.deleteCourse(course);
  }

  Future<List<ProgressCourseSelection>> removeAllCourses() async {
    final previous = List<ProgressCourseSelection>.from(courses.value);
    courses.value = const [];
    await _storage?.deleteAllCourses();
    return previous;
  }

  void markRoadmapGenerated(ProgressCourseSelection course) {
    courses.value = courses.value
        .map((c) {
          if (_matches(c, course)) {
            return c.copyWith(roadmapGenerated: true);
          }
          return c;
        })
        .toList(growable: false);
  }

  bool _matches(ProgressCourseSelection left, ProgressCourseSelection right) {
    return left.title == right.title &&
        left.topic == right.topic &&
        left.level == right.level &&
        left.nativeLanguage == right.nativeLanguage;
  }
}
