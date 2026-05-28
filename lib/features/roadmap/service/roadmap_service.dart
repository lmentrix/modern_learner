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
        .limit(1);

    if (rows.isEmpty) return null;
    return RoadmapDbModel.fromJson(rows.first);
  }

  /// Fetches all roadmap rows for the current user.
  Future<List<RoadmapDbModel>> fetchRoadmapsForUser({String? userId}) async {
    final resolvedUserId =
        userId ?? _client.auth.currentUser?.id ?? (throw _noUserError());

    final rows = await _client
        .from(_roadmapsTable)
        .select()
        .eq('user_id', resolvedUserId)
        .order('created_at', ascending: false);

    return rows.map((r) => RoadmapDbModel.fromJson(r)).toList();
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

  /// Fetches all chapter progress rows for a given [courseId].
  Future<List<RoadmapChapterProgressDbModel>> fetchChapterProgressByCourse(
    String courseId,
  ) async {
    final rows = await _client
        .from(_chapterProgressTable)
        .select()
        .eq('course_id', courseId)
        .order('chapter_number');

    return rows.map((r) => RoadmapChapterProgressDbModel.fromJson(r)).toList();
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
        .limit(1);

    if (rows.isEmpty) return null;
    return RoadmapChapterProgressDbModel.fromJson(rows.first);
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
}

StateError _noUserError() =>
    StateError('No authenticated user. Cannot write to database.');
