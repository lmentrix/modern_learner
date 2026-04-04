import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:modern_learner_production/core/constants/api_constants.dart';
import 'package:modern_learner_production/features/progress/data/models/roadmap_model.dart';
import 'package:modern_learner_production/features/progress/domain/entities/roadmap.dart';

class RoadmapGenerationService {
  RoadmapGenerationService({required this.dio, required this.prefs});

  final Dio dio;
  final SharedPreferences prefs;

  static const _cachePrefix = 'roadmap_cache_';

  String _cacheKey(
    String topic,
    String language,
    String level,
    String nativeLanguage,
  ) => '$_cachePrefix${topic}_${language}_${level}_$nativeLanguage'
      .toLowerCase()
      .replaceAll(' ', '_');

  Future<Roadmap> generateRoadmap({
    required String topic,
    required String language,
    required String level,
    required String nativeLanguage,
  }) async {
    final key = _cacheKey(topic, language, level, nativeLanguage);
    final cached = prefs.getString(key);

    if (cached != null) {
      final json = jsonDecode(cached) as Map<String, dynamic>;
      return RoadmapModel.fromJson(json).toEntity();
    }

    final response = await dio.post<Map<String, dynamic>>(
      '${ApiConstants.baseUrl}${ApiConstants.roadmapGenerate}',
      data: {
        'topic': topic,
        'language': language,
        'level': level,
        'nativeLanguage': nativeLanguage,
      },
    );

    final body = response.data!;
    final roadmapJson = body['data'] as Map<String, dynamic>;

    await prefs.setString(key, jsonEncode(roadmapJson));

    return RoadmapModel.fromJson(roadmapJson).toEntity();
  }

  Future<void> clearCache({
    required String topic,
    required String language,
    required String level,
    required String nativeLanguage,
  }) async {
    final key = _cacheKey(topic, language, level, nativeLanguage);
    await prefs.remove(key);
  }
}
