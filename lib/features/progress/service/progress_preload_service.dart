import 'package:modern_learner_production/features/course/model/course__service_model.dart';
import 'package:modern_learner_production/features/course/service/course_service.dart';
import 'package:modern_learner_production/features/explore/data/models/progress_course_model.dart';
import 'package:modern_learner_production/features/explore/service/explore_courses_service.dart';
import 'package:modern_learner_production/features/progress/service/course_xp_service.dart';
import 'package:modern_learner_production/features/progress/service/model/chapter_subcontent_model.dart';
import 'package:modern_learner_production/features/roadmap/service/roadmap_service.dart';
import 'package:modern_learner_production/core/models/progress_course_selection.dart';

/// Pre-loads roadmap and chapter subcontent from the local DB into a shared
/// in-memory cache so the progress page can render without a skeleton on first
/// visit after app startup.
class ProgressPreloadService {
  ProgressPreloadService._();
  static final ProgressPreloadService instance = ProgressPreloadService._();

  // courseKey → (chapterCacheKey → response)
  final Map<String, Map<String, ChapterSubcontentResponseModel>>
  _subcontentByCourse = {};

  final Set<String> _loadedCourseKeys = {};

  bool isCourseLoaded(String courseKey) =>
      _loadedCourseKeys.contains(courseKey);

  /// Returns the preloaded chapter subcontent map for [courseKey], or null if
  /// the preload has not completed for that course yet.
  Map<String, ChapterSubcontentResponseModel>? subcontentFor(
    String courseKey,
  ) => _subcontentByCourse[courseKey];

  /// Removes all cached data for [courseKey]. Call when a course is deleted.
  void evictCourse(String courseKey) {
    _subcontentByCourse.remove(courseKey);
    _loadedCourseKeys.remove(courseKey);
  }

  /// Fetches courses from the remote DB, updates [ExploreCoursesService], then
  /// reads chapter subcontent rows for each course into the shared cache.
  /// Safe to call fire-and-forget — all errors are silently absorbed.
  Future<void> preload() async {
    try {
      final models = await CourseService.instance.fetchCourses();
      if (models.isEmpty) return;

      final courses = models.map(_toEntity).toList();

      // Update ExploreCoursesService so the home page and progress page both
      // see the course list immediately without waiting for their own fetches.
      ExploreCoursesService.instance.courses.value = courses;
      for (final c in courses) {
        final courseId = c.courseId;
        if (courseId != null) {
          CourseXpService.instance.setCourseId(
            progressCourseXpKey(c),
            courseId,
          );
        }
      }

      // Load chapter subcontent for each course from the DB.
      for (final course in courses) {
        await _preloadCourse(course);
      }
    } catch (_) {}
  }

  Future<void> _preloadCourse(ProgressCourseSelection course) async {
    final courseId = course.courseId;
    if (courseId == null) return;

    final courseKey = progressCourseXpKey(course);
    try {
      final chapterRows = await RoadmapService.instance
          .fetchChapterProgressByCourse(courseId);

      final subcontentMap = <String, ChapterSubcontentResponseModel>{};
      for (final row in chapterRows) {
        final subcontentJson = row.chapterSubcontentJson;
        if (subcontentJson == null) continue;
        final cacheKey = '$courseKey::ch${row.chapterNumber}';
        try {
          final subcontent = ChapterSubcontentModel.fromJson(subcontentJson);
          subcontentMap[cacheKey] = ChapterSubcontentResponseModel(
            statusCode: 200,
            code: 'ok',
            message: '',
            model: '',
            courseType: subcontent.courseType,
            chapterSubcontent: subcontent,
          );
        } catch (_) {}
      }

      _subcontentByCourse[courseKey] = subcontentMap;
      _loadedCourseKeys.add(courseKey);
    } catch (_) {}
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
