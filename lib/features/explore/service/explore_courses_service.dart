import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:modern_learner_production/core/models/progress_course_selection.dart';
import 'package:modern_learner_production/features/course/model/course__service_model.dart';
import 'package:modern_learner_production/features/course/service/course_service.dart';
import 'package:modern_learner_production/features/explore/data/models/progress_course_model.dart';
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
    // Seed from local first for instant display, then replace with Supabase.
    courses.value = await _storage?.fetchCourses() ?? const [];
    try {
      final remoteModels = await CourseService.instance.fetchCourses();
      final remote = remoteModels.map(_toEntity).toList();
      if (remote.isNotEmpty) {
        courses.value = remote;
        // Sync course IDs into CourseXpService so XP sync carries the FK.
        for (final c in remote) {
          if (c.courseId != null) {
            CourseXpService.instance.setCourseId(
              progressCourseXpKey(c),
              c.courseId!,
            );
          }
        }
        // Persist the authoritative list locally for offline use.
        if (_storage != null) {
          for (final c in remote) {
            await _storage!.upsertCourse(c);
          }
        }
      }
    } catch (_) {}
  }

  Future<void> addCourse(ProgressCourseSelection course) async {
    final current = courses.value;
    final duplicate = current.any((c) => _matches(c, course));
    if (duplicate) return;

    CourseXpService.instance.resetCourse(progressCourseXpKey(course));

    ProgressCourseSelection saved = course;
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        final request = CreateUserCourseRequest(
          userId: userId,
          title: course.title,
          topic: course.topic,
          roadmapLanguage: course.roadmapLanguage,
          level: course.level,
          nativeLanguage: course.nativeLanguage,
          roadmapJson: course.roadmapJson,
        );
        final courseId = await CourseService.instance.upsertCourse(request);
        saved = course.copyWith(courseId: courseId);
        CourseXpService.instance.setCourseId(progressCourseXpKey(saved), courseId);
      }
    } catch (_) {}

    courses.value = [saved, ...current];
    await _storage?.upsertCourse(saved);
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
    CourseXpService.instance.removeCourse(progressCourseXpKey(course));
    courses.value = courses.value
        .where((c) => c != course)
        .toList(growable: false);
    await _storage?.deleteCourse(course);
    // Deleting from user_courses cascades to profile_course_xp,
    // user_achievement_progress, and achievements automatically.
    if (course.courseId != null) {
      try {
        await CourseService.instance.deleteCourse(course.courseId!);
      } catch (_) {}
    }
  }

  Future<List<ProgressCourseSelection>> removeAllCourses() async {
    final previous = List<ProgressCourseSelection>.from(courses.value);
    for (final c in previous) {
      CourseXpService.instance.removeCourse(progressCourseXpKey(c));
    }
    courses.value = const [];
    await _storage?.deleteAllCourses();
    final courseIds = previous
        .map((c) => c.courseId)
        .whereType<String>()
        .toList();
    if (courseIds.isNotEmpty) {
      try {
        await CourseService.instance.deleteCourses(courseIds);
      } catch (_) {}
    }
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

  static ProgressCourseSelection _toEntity(UserCourseModel m) =>
      ProgressCourseModel.fromRow({
        'id': m.id,
        'title': m.title,
        'topic': m.topic,
        'roadmap_language': m.roadmapLanguage,
        'level': m.level,
        'native_language': m.nativeLanguage,
        'roadmap_json': m.roadmapJson,
      }).toEntity();
}
