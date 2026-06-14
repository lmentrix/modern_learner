import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:modern_learner_production/core/models/progress_course_selection.dart';
import 'package:modern_learner_production/features/course/model/course__service_model.dart';
import 'package:modern_learner_production/features/course/service/course_service.dart';
import 'package:modern_learner_production/features/explore/service/explore_courses_service.dart';
import 'package:modern_learner_production/features/progress/service/model/roadmap_model.dart';
import 'package:modern_learner_production/features/progress/service/request/progress_request.dart';
import 'package:modern_learner_production/features/progress/service/roadmap_mock_guard.dart';
import 'package:modern_learner_production/features/roadmap/service/roadmap_service.dart';

class RoadmapGenerationService {
  RoadmapGenerationService._();

  static final RoadmapGenerationService instance = RoadmapGenerationService._();

  final ValueNotifier<int> revision = ValueNotifier<int>(0);
  final Map<String, Future<RoadmapResponseModel>> _inFlight =
      <String, Future<RoadmapResponseModel>>{};

  bool isGenerating(ProgressCourseSelection course) =>
      _inFlight.containsKey(_courseKey(course));

  Future<RoadmapResponseModel> ensureRoadmap(
    ProgressCourseSelection course, {
    bool forceRegenerate = false,
  }) {
    final key = _courseKey(course);
    final existing = forceRegenerate ? null : _inFlight[key];
    if (existing != null) return existing;

    final future = _ensureRoadmap(course, forceRegenerate: forceRegenerate);
    _inFlight[key] = future;
    revision.value++;

    future.whenComplete(() {
      if (identical(_inFlight[key], future)) {
        _inFlight.remove(key);
        revision.value++;
      }
    }).ignore();

    return future;
  }

  Future<void> resumeMissingRoadmaps(
    Iterable<ProgressCourseSelection> courses,
  ) async {
    for (final course in courses) {
      if (_extractRoadmapResponse(course.roadmapJson) != null) continue;
      unawaited(_safeEnsureRoadmap(course));
    }
  }

  Future<void> _safeEnsureRoadmap(ProgressCourseSelection course) async {
    try {
      await ensureRoadmap(course);
    } catch (_) {}
  }

  Future<RoadmapResponseModel> _ensureRoadmap(
    ProgressCourseSelection course, {
    required bool forceRegenerate,
  }) async {
    final existingResponse = forceRegenerate
        ? null
        : _extractRoadmapResponse(course.roadmapJson);
    if (existingResponse != null &&
        !_isStaleRoadmapResponse(existingResponse)) {
      return existingResponse;
    }

    final courseId = course.courseId;
    if (!forceRegenerate && courseId != null) {
      final row = await RoadmapService.instance.fetchRoadmapByCourse(courseId);
      if (row != null) {
        final response = RoadmapResponseModel.fromJson(row.roadmapJson);
        await _persistGeneratedCourse(course, response);
        return response;
      }
    }

    final request = RoadmapGenerateRequestModel(
      roadmapMode: course.courseType == ProgressCourseType.voice
          ? 'voice'
          : 'school',
      topic: course.topic,
      language: course.roadmapLanguage,
      level: course.level,
      nativeLanguage: course.nativeLanguage,
    );

    final response = await fetchProgress(request, bypassCache: forceRegenerate);
    await _persistGeneratedCourse(course, response, request: request);
    return response;
  }

  Future<void> _persistGeneratedCourse(
    ProgressCourseSelection course,
    RoadmapResponseModel response, {
    RoadmapGenerateRequestModel? request,
  }) async {
    final rawRoadmapJson = response.rawJson ?? response.toJson();
    final updatedCourse = course.copyWith(
      roadmapJson: rawRoadmapJson,
      roadmapGenerated: true,
    );

    await ExploreCoursesService.instance.updateCourse(updatedCourse);

    final courseId = course.courseId;
    if (courseId == null) return;

    final effectiveRequest =
        request ??
        RoadmapGenerateRequestModel(
          roadmapMode: course.courseType == ProgressCourseType.voice
              ? 'voice'
              : 'school',
          topic: course.topic,
          language: course.roadmapLanguage,
          level: course.level,
          nativeLanguage: course.nativeLanguage,
        );

    try {
      // Save roadmap first so we have its Supabase UUID as a fallback roadmapId.
      final savedRoadmap = await RoadmapService.instance.saveRoadmap(
        response: response,
        request: effectiveRequest,
        courseId: courseId,
      );

      final roadmapId = response.roadmap.id ?? savedRoadmap.id;

      await Future.wait([
        CourseService.instance.updateCourse(
          courseId,
          UpdateUserCourseRequest(roadmapJson: rawRoadmapJson),
        ),
        if (roadmapId.trim().isNotEmpty)
          RoadmapService.instance.saveChapterMetadata(
            response: response,
            roadmapId: roadmapId,
            courseKey: _courseKey(course),
            courseId: courseId,
          ),
      ]);
    } catch (_) {}
  }
}

String _courseKey(ProgressCourseSelection course) =>
    progressCourseXpKey(course);

RoadmapResponseModel? _extractRoadmapResponse(Map<String, dynamic>? raw) {
  if (raw == null || raw.isEmpty) return null;
  if (isMockRoadmapPayload(raw)) return null;

  final hasLegacyEnvelope = raw['roadmap'] is Map;
  final hasDirectChapters = raw['chapters'] is List;
  if (!hasLegacyEnvelope && !hasDirectChapters) return null;

  try {
    return RoadmapResponseModel.fromJson(raw);
  } catch (_) {
    return null;
  }
}

bool _isStaleRoadmapResponse(RoadmapResponseModel response) {
  final code = response.code.toLowerCase();
  final model = response.model.toLowerCase();
  final message = response.message.toLowerCase();
  final summary = response.roadmap.summary.toLowerCase();
  final id = (response.roadmap.id ?? '').toLowerCase();
  return response.mocked ||
      code.contains('mock') ||
      code.contains('offline_fallback') ||
      model == 'offline-fallback' ||
      message.contains('mock roadmap') ||
      summary.contains('deterministic offline') ||
      id.startsWith('mock') ||
      id.contains('_mock');
}
