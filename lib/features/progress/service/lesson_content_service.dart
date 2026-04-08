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

  String _cacheKey(String lessonId) => '$_cachePrefix$lessonId';

  Future<LessonContentModel> generateContent({
    required String lessonId,
    required String topic,
    required String language,
    required String level,
    required String chapterTitle,
    required String lessonTitle,
    required String lessonType,
    required String lessonDescription,
    required String nativeLanguage,
    required String chapterId,
  }) async {
    final key = _cacheKey(lessonId);
    final cached = prefs.getString(key);

    if (cached != null) {
      return LessonContentModel.fromJson(
        jsonDecode(cached) as Map<String, dynamic>,
      );
    }

    final response = await dio.post<Map<String, dynamic>>(
      '${ApiConstants.baseUrl}${ApiConstants.lessonContentGenerate}',
      data: {
        'topic': topic,
        'language': language,
        'level': level,
        'chapterTitle': chapterTitle,
        'lessonTitle': lessonTitle,
        'lessonType': lessonType,
        'lessonDescription': lessonDescription,
        'nativeLanguage': nativeLanguage,
        'chapterId': chapterId,
      },
    );

    final contentJson = (response.data!['data']) as Map<String, dynamic>;
    final model = LessonContentModel.fromJson(contentJson);
    await prefs.setString(key, jsonEncode(contentJson));

    return model;
  }
}
