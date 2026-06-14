import 'dart:convert';

import 'package:modern_learner_production/features/progress/service/model/chapter_subcontent_model.dart';
import 'package:modern_learner_production/features/progress/service/model/roadmap_model.dart'
    as api;
import 'package:modern_learner_production/features/roadmap/model/roadmap_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RoadmapService {
  RoadmapService._();
  static final RoadmapService instance = RoadmapService._();

  SupabaseClient get _client => Supabase.instance.client;

  static const _roadmapsTable = 'roadmaps';
  static const _chapterProgressTable = 'roadmap_chapter_progress';
  static const _chapterExercisesTable = 'generated_chapter_exercises';
  static const _chapterExerciseProgressTable = 'chapter_exercise_progress';

  // ---------------------------------------------------------------------------
  // Roadmaps
  // ---------------------------------------------------------------------------

  /// Saves a generated roadmap response to the `roadmaps` table.
  ///
  /// If a row already exists for (user_id, course_id), it is updated;
  /// otherwise a new row is inserted. Returns the saved [RoadmapDbModel].
  Future<RoadmapDbModel> saveRoadmap({
    required api.RoadmapResponseModel response,
    required api.RoadmapGenerateRequestModel request,
    required String courseId,
    String? userId,
  }) async {
    final resolvedUserId =
        userId ?? _client.auth.currentUser?.id ?? (throw _noUserError());

    final existing = await _client
        .from(_roadmapsTable)
        .select('id')
        .eq('user_id', resolvedUserId)
        .eq('course_id', courseId)
        .limit(1);

    final payload = UpsertRoadmapRequest(
      userId: resolvedUserId,
      roadmapMode: request.roadmapMode,
      topic: request.topic,
      roadmapLanguage: request.language,
      level: request.level,
      nativeLanguage: request.nativeLanguage,
      model: response.model.isNotEmpty ? response.model : null,
      requestId: response.requestId,
      statusCode: response.statusCode,
      mocked: response.mocked,
      roadmapJson: response.roadmap.toJson(),
      generatedRoadmapJson: response.rawJson ?? response.toJson(),
      usage: response.usage?.toJson(),
      rawContent: response.rawContent,
      prompt: response.prompt,
      code: response.code,
      message: response.message,
      temperature: request.temperature,
      maxTokens: request.maxTokens,
      topP: request.topP,
      courseId: courseId,
    ).toJson();
    payload.addAll(_freshCacheWindow());

    List<Map<String, dynamic>> rows;

    if (existing.isNotEmpty) {
      final id = existing.first['id'] as String;
      rows = await _client
          .from(_roadmapsTable)
          .update({...payload, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', id)
          .select();
    } else {
      rows = await _client.from(_roadmapsTable).insert(payload).select();
    }

    return RoadmapDbModel.fromJson(rows.first);
  }

  /// Fetches the roadmap row for a given [courseId].
  Future<RoadmapDbModel?> fetchRoadmapByCourse(String courseId) async {
    final rows = await _client
        .from(_roadmapsTable)
        .select()
        .eq('course_id', courseId)
        .eq('mocked', false)
        .gte('expires_at', DateTime.now().toUtc().toIso8601String())
        .limit(1);

    if (rows.isEmpty) return null;
    final row = RoadmapDbModel.fromJson(rows.first);
    return row.isExpired || _isStaleRoadmapJson(row.roadmapJson) ? null : row;
  }

  /// Fetches all roadmap rows for the current user.
  Future<List<RoadmapDbModel>> fetchRoadmapsForUser({String? userId}) async {
    final resolvedUserId =
        userId ?? _client.auth.currentUser?.id ?? (throw _noUserError());

    final rows = await _client
        .from(_roadmapsTable)
        .select()
        .eq('user_id', resolvedUserId)
        .eq('mocked', false)
        .order('created_at', ascending: false);

    return rows
        .map((r) => RoadmapDbModel.fromJson(r))
        .where((row) => !_isStaleRoadmapJson(row.roadmapJson))
        .toList();
  }

  // ---------------------------------------------------------------------------
  // Chapter progress
  // ---------------------------------------------------------------------------

  /// Saves generated chapter subcontent to `roadmap_chapter_progress`.
  ///
  /// Looks up an existing row by (user_id, roadmap_id, chapter_number) and
  /// updates it; inserts a new row if none exists.
  Future<RoadmapChapterProgressDbModel> saveChapterProgress({
    required ChapterSubcontentResponseModel response,
    required String roadmapId,
    required String courseKey,
    required String courseId,
    String? userId,
  }) async {
    final resolvedUserId =
        userId ?? _client.auth.currentUser?.id ?? (throw _noUserError());

    final subcontent = response.chapterSubcontent;

    final existing = await _client
        .from(_chapterProgressTable)
        .select('id')
        .eq('user_id', resolvedUserId)
        .eq('roadmap_id', roadmapId)
        .eq('chapter_number', subcontent.chapterNumber)
        .limit(1);

    final payload = UpsertChapterProgressRequest(
      userId: resolvedUserId,
      roadmapId: roadmapId,
      courseKey: courseKey,
      chapterNumber: subcontent.chapterNumber,
      chapterTitle: subcontent.chapterTitle,
      overview: subcontent.overview,
      chapterSubcontentJson: subcontent.toJson(),
      subcontentApiId: subcontent.id,
      courseId: courseId,
    ).toJson();
    payload.addAll(_freshCacheWindow());

    List<Map<String, dynamic>> rows;

    if (existing.isNotEmpty) {
      final id = existing.first['id'] as String;
      rows = await _client
          .from(_chapterProgressTable)
          .update({...payload, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', id)
          .select();
    } else {
      rows = await _client.from(_chapterProgressTable).insert(payload).select();
    }

    return RoadmapChapterProgressDbModel.fromJson(rows.first);
  }

  /// Saves one metadata-only row per chapter (no subcontent) to
  /// `roadmap_chapter_progress`, using upsert so existing rows are preserved.
  /// Called right after a roadmap is persisted so the DB reflects the full
  /// chapter list immediately — before any subcontent is generated.
  Future<void> saveChapterMetadata({
    required api.RoadmapResponseModel response,
    required String roadmapId,
    required String courseKey,
    required String courseId,
    String? userId,
  }) async {
    final resolvedUserId =
        userId ?? _client.auth.currentUser?.id ?? (throw _noUserError());

    final chapters = response.roadmap.chapters;
    if (chapters.isEmpty) return;

    final cacheWindow = _freshCacheWindow();
    final rows = chapters
        .where((ch) => ch.chapterNumber > 0)
        .map(
          (ch) => {
            ...UpsertChapterProgressRequest(
              userId: resolvedUserId,
              roadmapId: roadmapId,
              courseKey: courseKey,
              chapterNumber: ch.chapterNumber,
              chapterTitle: ch.title,
              overview: ch.description,
              courseId: courseId,
            ).toJson(),
            ...cacheWindow,
          },
        )
        .toList();

    if (rows.isEmpty) return;

    await _client
        .from(_chapterProgressTable)
        .upsert(rows, onConflict: 'user_id,roadmap_id,chapter_number')
        .select();
  }

  /// Fetches all chapter progress rows for a given [courseId].
  Future<List<RoadmapChapterProgressDbModel>> fetchChapterProgressByCourse(
    String courseId,
  ) async {
    final rows = await _client
        .from(_chapterProgressTable)
        .select()
        .eq('course_id', courseId)
        .gte('expires_at', DateTime.now().toUtc().toIso8601String())
        .order('chapter_number');

    return rows
        .map((r) => RoadmapChapterProgressDbModel.fromJson(r))
        .where((row) => !row.isExpired)
        .toList();
  }

  /// Fetches a single chapter progress row by roadmap + chapter number.
  Future<RoadmapChapterProgressDbModel?> fetchChapterProgress({
    required String roadmapId,
    required int chapterNumber,
    String? userId,
  }) async {
    final resolvedUserId =
        userId ?? _client.auth.currentUser?.id ?? (throw _noUserError());

    final rows = await _client
        .from(_chapterProgressTable)
        .select()
        .eq('user_id', resolvedUserId)
        .eq('roadmap_id', roadmapId)
        .eq('chapter_number', chapterNumber)
        .gte('expires_at', DateTime.now().toUtc().toIso8601String())
        .limit(1);

    if (rows.isEmpty) return null;
    final row = RoadmapChapterProgressDbModel.fromJson(rows.first);
    return row.isExpired ? null : row;
  }

  /// Marks a chapter as completed.
  Future<RoadmapChapterProgressDbModel?> markChapterCompleted({
    required String roadmapId,
    required int chapterNumber,
    String? userId,
  }) async {
    final resolvedUserId =
        userId ?? _client.auth.currentUser?.id ?? (throw _noUserError());

    final now = DateTime.now();
    final rows = await _client
        .from(_chapterProgressTable)
        .update({
          'is_completed': true,
          'completed_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        })
        .eq('user_id', resolvedUserId)
        .eq('roadmap_id', roadmapId)
        .eq('chapter_number', chapterNumber)
        .select();

    if (rows.isEmpty) return null;
    return RoadmapChapterProgressDbModel.fromJson(rows.first);
  }

  Future<Map<String, dynamic>?> fetchChapterExerciseJson({
    required String chapterSubcontentId,
    required int subcontentNumber,
    String? userId,
  }) async {
    final resolvedUserId =
        userId ?? _client.auth.currentUser?.id ?? (throw _noUserError());

    final rows = await _client
        .from(_chapterExercisesTable)
        .select('exercise_json, expires_at')
        .eq('user_id', resolvedUserId)
        .eq('chapter_subcontent_id', chapterSubcontentId)
        .eq('subcontent_number', subcontentNumber)
        .gte('expires_at', DateTime.now().toUtc().toIso8601String())
        .limit(1);

    if (rows.isEmpty) return null;
    final row = rows.first;
    final expiresAt = DateTime.tryParse(row['expires_at'] as String? ?? '');
    if (expiresAt != null && !expiresAt.isAfter(DateTime.now().toUtc())) {
      return null;
    }
    final payload = row['exercise_json'];
    if (payload is Map<String, dynamic>) return payload;
    if (payload is Map) return Map<String, dynamic>.from(payload);
    if (payload is String) {
      return Map<String, dynamic>.from(jsonDecode(payload) as Map);
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> fetchChapterExercisesByCourse(
    String courseId, {
    String? userId,
  }) async {
    final resolvedUserId =
        userId ?? _client.auth.currentUser?.id ?? (throw _noUserError());

    final rows = await _client
        .from(_chapterExercisesTable)
        .select(
          'chapter_subcontent_id, subcontent_number, exercise_json, expires_at',
        )
        .eq('user_id', resolvedUserId)
        .eq('course_id', courseId)
        .gte('expires_at', DateTime.now().toUtc().toIso8601String());

    return rows.map((row) => Map<String, dynamic>.from(row)).toList();
  }

  /// Returns all (chapter_subcontent_id, subcontent_number) pairs for a course
  /// regardless of expiry — used to identify local cache entries to purge.
  Future<List<({String chapterSubcontentId, int subcontentNumber})>>
  fetchExerciseKeysForCourse(String courseId, {String? userId}) async {
    final resolvedUserId =
        userId ?? _client.auth.currentUser?.id ?? (throw _noUserError());

    final rows = await _client
        .from(_chapterExercisesTable)
        .select('chapter_subcontent_id, subcontent_number')
        .eq('user_id', resolvedUserId)
        .eq('course_id', courseId);

    return rows
        .map((r) {
          final id = r['chapter_subcontent_id'] as String? ?? '';
          final n = (r['subcontent_number'] as num?)?.toInt() ?? 0;
          return (chapterSubcontentId: id, subcontentNumber: n);
        })
        .where((k) => k.chapterSubcontentId.trim().isNotEmpty)
        .toList();
  }

  /// Returns all chapter numbers stored for a course regardless of expiry —
  /// used to identify local subcontent cache entries to purge.
  Future<List<int>> fetchChapterNumbersForCourse(
    String courseId, {
    String? userId,
  }) async {
    final resolvedUserId =
        userId ?? _client.auth.currentUser?.id ?? (throw _noUserError());

    final rows = await _client
        .from(_chapterProgressTable)
        .select('chapter_number')
        .eq('course_id', courseId);

    return rows
        .map((r) => (r['chapter_number'] as num?)?.toInt() ?? 0)
        .where((n) => n > 0)
        .toList();
  }

  /// Deletes all AI-generated content rows for [courseId] from Supabase
  /// so the next progress-page load is forced to generate fresh content.
  ///
  /// Called before navigating to progress for a brand-new lesson so stale
  /// Supabase rows from a previous generation of the same course are not
  /// served by [_loadFromDb].
  Future<void> resetCourseGeneratedContent(String courseId) async {
    try {
      await Future.wait([
        _client.from(_roadmapsTable).delete().eq('course_id', courseId),
        _client.from(_chapterProgressTable).delete().eq('course_id', courseId),
        _client.from(_chapterExercisesTable).delete().eq('course_id', courseId),
        _client
            .from(_chapterExerciseProgressTable)
            .delete()
            .eq('course_id', courseId),
      ]);
    } catch (_) {}
  }

  Future<void> saveChapterExerciseJson({
    required String rawJson,
    required String courseKey,
    required String chapterSubcontentId,
    required int chapterNumber,
    required int subcontentNumber,
    String? courseId,
    String? userId,
  }) async {
    final resolvedUserId =
        userId ?? _client.auth.currentUser?.id ?? (throw _noUserError());
    final decoded = Map<String, dynamic>.from(jsonDecode(rawJson) as Map);
    final payload = {
      'user_id': resolvedUserId,
      'course_key': courseKey,
      'chapter_subcontent_id': chapterSubcontentId,
      'chapter_number': chapterNumber,
      'subcontent_number': subcontentNumber,
      'exercise_json': decoded,
      ..._freshCacheWindow(),
    };
    if (courseId != null) {
      payload['course_id'] = courseId;
    }

    await _client
        .from(_chapterExercisesTable)
        .upsert(
          payload,
          onConflict: 'user_id,chapter_subcontent_id,subcontent_number',
        )
        .select()
        .limit(1);
  }

  Future<Map<String, dynamic>?> fetchChapterExerciseProgress({
    required String chapterSubcontentId,
    required int subcontentNumber,
    String? userId,
  }) async {
    final resolvedUserId =
        userId ?? _client.auth.currentUser?.id ?? (throw _noUserError());

    final rows = await _client
        .from(_chapterExerciseProgressTable)
        .select('progress_json')
        .eq('user_id', resolvedUserId)
        .eq('chapter_subcontent_id', chapterSubcontentId)
        .eq('subcontent_number', subcontentNumber)
        .limit(1);

    if (rows.isEmpty) return null;
    final payload = rows.first['progress_json'];
    if (payload is Map<String, dynamic>) return payload;
    if (payload is Map) return Map<String, dynamic>.from(payload);
    return null;
  }

  Future<void> saveChapterExerciseProgress({
    required Map<String, dynamic> progressJson,
    required String courseKey,
    required String chapterSubcontentId,
    required int chapterNumber,
    required int subcontentNumber,
    String? courseId,
    DateTime? completedAt,
    String? userId,
  }) async {
    final resolvedUserId =
        userId ?? _client.auth.currentUser?.id ?? (throw _noUserError());
    final payload = {
      'user_id': resolvedUserId,
      'course_key': courseKey,
      'chapter_subcontent_id': chapterSubcontentId,
      'chapter_number': chapterNumber,
      'subcontent_number': subcontentNumber,
      'progress_json': progressJson,
    };
    if (courseId != null) {
      payload['course_id'] = courseId;
    }
    if (completedAt != null) {
      payload['completed_at'] = completedAt.toUtc().toIso8601String();
    }

    await _client
        .from(_chapterExerciseProgressTable)
        .upsert(
          payload,
          onConflict: 'user_id,chapter_subcontent_id,subcontent_number',
        )
        .select()
        .limit(1);
  }
}

StateError _noUserError() =>
    StateError('No authenticated user. Cannot write to database.');

Map<String, String> _freshCacheWindow() {
  final now = DateTime.now().toUtc();
  return {
    'generated_at': now.toIso8601String(),
    'expires_at': now.add(const Duration(days: 7)).toIso8601String(),
  };
}

bool _isStaleRoadmapJson(Map<String, dynamic> json) {
  final code = (json['code'] ?? '').toString().toLowerCase();
  final model = (json['model'] ?? '').toString().toLowerCase();
  final message = (json['message'] ?? '').toString().toLowerCase();
  final summary = _readRoadmapSummary(json).toLowerCase();
  return json['mocked'] == true ||
      code.contains('mock') ||
      code.contains('offline_fallback') ||
      model == 'offline-fallback' ||
      message.contains('mock roadmap') ||
      summary.contains('deterministic offline');
}

String _readRoadmapSummary(Map<String, dynamic> json) {
  final roadmap = json['roadmap'];
  if (roadmap is Map) {
    return (roadmap['summary'] ?? '').toString();
  }
  return (json['summary'] ?? '').toString();
}
