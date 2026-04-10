import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:modern_learner_production/core/constants/api_constants.dart';

class ChapterContentService {
  ChapterContentService({required this.dio, required this.prefs});

  final Dio dio;
  final SharedPreferences prefs;

  static const _cachePrefix = 'chapter_content_';

  String _cacheKey(String roadmapId, int chapterNumber) =>
      '$_cachePrefix${roadmapId}_$chapterNumber';

  Future<void> clearAllCaches() async {
    final keys = prefs.getKeys().where((k) => k.startsWith(_cachePrefix)).toList();
    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  /// Step 2 — POST /ai/chapter-content/generate
  ///
  /// [roadmap] is the full `data` object from Step 1.
  /// Returns the raw `data` object from the Step 2 response.
  Future<Map<String, dynamic>> generateChapterContent({
    required Map<String, dynamic> roadmap,
    required int chapterNumber,
  }) async {
    final roadmapId = roadmap['id'] as String;
    final key = _cacheKey(roadmapId, chapterNumber);
    final cached = prefs.getString(key);

    if (cached != null) {
      return jsonDecode(cached) as Map<String, dynamic>;
    }

    const maxRetries = 3;
    Object? lastError;

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final response = await dio.post<Map<String, dynamic>>(
          '${ApiConstants.baseUrl}${ApiConstants.chapterContentGenerate}',
          data: {
            'roadmap': roadmap,
            'chapterNumber': chapterNumber,
          },
        );

        final contentJson = response.data!['data'] as Map<String, dynamic>;
        await prefs.setString(key, jsonEncode(contentJson));
        return contentJson;
      } catch (e) {
        lastError = e;
        if (attempt < maxRetries) {
          await Future.delayed(Duration(seconds: attempt));
        }
      }
    }

    throw lastError!;
  }
}
