import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:modern_learner_production/core/constants/api_constants.dart';
import 'package:modern_learner_production/features/progress/data/models/lesson_content_model.dart';

class LessonContentService {
  LessonContentService({required this.dio, required this.prefs});

  final Dio dio;
  final SharedPreferences prefs;

  static const _cachePrefix = 'lesson_content_';

  String _cacheKey(
    String roadmapId,
    int chapterNumber,
    int lessonNumber,
    String lessonId,
  ) => '$_cachePrefix${roadmapId}_${chapterNumber}_${lessonNumber}_$lessonId';

  Future<void> clearAllCaches() async {
    final keys = prefs
        .getKeys()
        .where((k) => k.startsWith(_cachePrefix))
        .toList();
    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  /// Step 3 — POST /ai/lesson-content/generate
  ///
  /// [roadmap] is the full `data` object from Step 1.
  /// [chapterContent] is the full `data` object from Step 2.
  /// [lessonNumber] is 1-based index within the chapter's lessons list.
  Future<LessonContentModel> generateContent({
    required String lessonId,
    required Map<String, dynamic> roadmap,
    required Map<String, dynamic> chapterContent,
    required int lessonNumber,
  }) async {
    final roadmapId = roadmap['id'] as String? ?? 'unknown_roadmap';
    final chapterNumber = chapterContent['chapterNumber'] as int? ?? 0;
    final key = _cacheKey(roadmapId, chapterNumber, lessonNumber, lessonId);
    final cached = prefs.getString(key);

    if (cached != null) {
      return LessonContentModel.fromJson(
        jsonDecode(cached) as Map<String, dynamic>,
      );
    }

    const maxRetries = 3;
    Object? lastError;

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final response = await dio.post<Map<String, dynamic>>(
          '${ApiConstants.baseUrl}${ApiConstants.lessonContentGenerate}',
          data: {
            'roadmap': roadmap,
            'chapterContent': chapterContent,
            'lessonNumber': lessonNumber,
          },
        );

        final contentJson = response.data!['data'] as Map<String, dynamic>;
        final model = LessonContentModel.fromJson(contentJson);
        await prefs.setString(key, jsonEncode(contentJson));
        return model;
      } catch (e) {
        lastError = e;
        if (attempt < maxRetries) {
          await Future.delayed(Duration(seconds: attempt));
        }
      }
    }

    throw Exception(_buildErrorMessage(lastError));
  }

  String _buildErrorMessage(Object? error) {
    if (error is DioException) {
      final endpoint = error.requestOptions.uri.toString();
      switch (error.type) {
        case DioExceptionType.connectionError:
        case DioExceptionType.connectionTimeout:
          return 'Unable to reach AI content service at $endpoint. '
              'Check that the backend server is running and BASE_URL is reachable '
              '(Android emulator uses 10.0.2.2 instead of localhost).';
        case DioExceptionType.receiveTimeout:
          return 'AI content generation timed out while waiting for server response. '
              'Please retry.';
        case DioExceptionType.badResponse:
          final code = error.response?.statusCode;
          return 'AI content service returned HTTP ${code ?? 'unknown'}.';
        default:
          final msg = error.message ?? 'Unknown network error.';
          return 'Failed to generate lesson content: $msg';
      }
    }

    return error?.toString() ?? 'Failed to generate lesson content.';
  }
}
