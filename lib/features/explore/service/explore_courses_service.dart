import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:modern_learner_production/core/models/progress_course_selection.dart';
import 'package:modern_learner_production/features/cache/generation_cache.dart';
import 'package:modern_learner_production/features/course/model/course__service_model.dart';
import 'package:modern_learner_production/features/course/service/course_service.dart';
import 'package:modern_learner_production/features/explore/data/models/progress_course_model.dart';
import 'package:modern_learner_production/features/explore/service/user_courses_service.dart';
import 'package:modern_learner_production/features/progress/service/cache/roadmap_id_cache.dart';
import 'package:modern_learner_production/features/progress/service/course_xp_service.dart';
import 'package:modern_learner_production/features/progress/service/progress_preload_service.dart';
import 'package:modern_learner_production/features/progress/service/roadmap_mock_guard.dart';
import 'package:modern_learner_production/features/roadmap/service/roadmap_service.dart';

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
    await CourseXpService.instance.ensureInitializedForCurrentUser();
    // Seed from local first for instant display, then replace with Supabase.
    courses.value = (await _storage?.fetchCourses() ?? const [])
        .map(_stripMockRoadmap)
        .toList(growable: false);
    try {
      final remoteModels = await CourseService.instance.fetchCourses();
      final remote = remoteModels
          .map(_toEntity)
          .map(_stripMockRoadmap)
          .toList();
      if (remote.isNotEmpty) {
        courses.value = remote;
        // Sync course IDs into CourseXpService so XP sync carries the FK.
        for (final c in remote) {
          final courseId = c.courseId;
          if (courseId != null) {
            CourseXpService.instance.setCourseId(
              progressCourseXpKey(c),
              courseId,
            );
          }
        }
        await CourseXpService.instance.restoreFromSupabase();
        // Persist the authoritative list locally for offline use.
        final storage = _storage;
        if (storage != null) {
          for (final c in remote) {
            await storage.upsertCourse(c);
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
        CourseXpService.instance.setCourseId(
          progressCourseXpKey(saved),
          courseId,
        );

        // Trigger FCM push notification via Supabase webhook.
        await _sendCourseCreatedNotification(userId: userId, course: saved);
      }
    } catch (_) {}

    saved = _stripMockRoadmap(saved);
    courses.value = [saved, ...current];
    await _storage?.upsertCourse(saved);
  }

  Future<void> updateCourse(ProgressCourseSelection course) async {
    course = _stripMockRoadmap(course);
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
    final courseKey = progressCourseXpKey(course);
    CourseXpService.instance.removeCourse(courseKey);
    ProgressPreloadService.instance.evictCourse(courseKey);
    courses.value = courses.value
        .where((c) => c != course)
        .toList(growable: false);
    await _storage?.deleteCourse(course);

    // Deleting from user_courses cascades to profile_course_xp,
    // user_achievement_progress, achievements, generated_chapter_exercises,
    // roadmap_chapter_progress, and roadmaps automatically.
    final courseId = course.courseId;
    if (courseId != null) {
      // Clear local cache before the DB row is gone so we can still query it.
      await _clearLocalCacheForCourse(course, courseId);
      try {
        await CourseService.instance.deleteCourse(courseId);
      } catch (_) {}
    }
  }

  Future<List<ProgressCourseSelection>> removeAllCourses() async {
    final previous = List<ProgressCourseSelection>.from(courses.value);
    for (final c in previous) {
      final courseKey = progressCourseXpKey(c);
      CourseXpService.instance.removeCourse(courseKey);
      ProgressPreloadService.instance.evictCourse(courseKey);
    }
    courses.value = const [];
    await _storage?.deleteAllCourses();

    final courseIds = previous
        .map((c) => c.courseId)
        .whereType<String>()
        .toList();
    if (courseIds.isNotEmpty) {
      // Clear local cache for every course before DB rows are deleted.
      for (final c in previous) {
        final id = c.courseId;
        if (id != null) {
          await _clearLocalCacheForCourse(c, id);
        }
      }
      try {
        await CourseService.instance.deleteCourses(courseIds);
      } catch (_) {}
    }
    return previous;
  }

  /// Purges all local [GenerationCache] entries that belong to [course].
  /// Fetches the exercise and chapter-number keys from the DB first so we can
  /// target only the entries that were actually cached for this course.
  Future<void> _clearLocalCacheForCourse(
    ProgressCourseSelection course,
    String courseId,
  ) async {
    try {
      final roadmapCacheKey = RoadmapIdCache.buildRoadmapCacheKey(
        roadmapMode: course.courseType == ProgressCourseType.voice
            ? 'voice'
            : 'school',
        topic: course.topic,
        language: course.roadmapLanguage,
        level: course.level,
        nativeLanguage: course.nativeLanguage,
      );

      final results = await Future.wait([
        RoadmapService.instance.fetchExerciseKeysForCourse(courseId),
        RoadmapService.instance.fetchChapterNumbersForCourse(courseId),
      ]);

      final exerciseKeys =
          results[0]
              as List<({String chapterSubcontentId, int subcontentNumber})>;
      final chapterNumbers = results[1] as List<int>;

      await const GenerationCache().clearCourseEntries(
        roadmapCacheKey: roadmapCacheKey,
        chapterNumbers: chapterNumbers,
        exerciseKeys: exerciseKeys,
      );

      await const RoadmapIdCache().clearRoadmapId(cacheKey: roadmapCacheKey);
    } catch (_) {
      // Cache cleanup must never break the deletion flow.
    }
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

  Future<void> _sendCourseCreatedNotification({
    required String userId,
    required ProgressCourseSelection course,
  }) async {
    try {
      final typeLabel = course.courseType == ProgressCourseType.voice
          ? 'Voice Lesson'
          : 'School Lesson';
      await Supabase.instance.client.from('notifications').insert({
        'user_id': userId,
        'title': 'New $typeLabel Created! ${course.courseType.badgeEmoji}',
        'body':
            '${course.title} (${course.level}) is ready. Start learning now!',
      });
    } catch (_) {
      // Notification failure must never break course creation.
    }
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

  static ProgressCourseSelection _stripMockRoadmap(
    ProgressCourseSelection course,
  ) {
    if (!isMockRoadmapPayload(course.roadmapJson)) return course;
    return course.copyWith(clearRoadmapJson: true);
  }
}
