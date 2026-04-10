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

  static const _idPrefix = 'roadmap_json_';

  /// Returns the raw roadmap JSON (i.e. the `data` object from Step 1)
  /// previously cached under the roadmap's [id].
  Map<String, dynamic>? getCachedRoadmapJsonById(String roadmapId) {
    final raw = prefs.getString('$_idPrefix$roadmapId');
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> cacheRoadmapJson(
    Map<String, dynamic> roadmapJson, {
    required String topic,
    required String language,
    required String level,
    required String nativeLanguage,
  }) async {
    final key = _cacheKey(topic, language, level, nativeLanguage);
    await prefs.setString(key, jsonEncode(roadmapJson));

    final roadmapId = roadmapJson['id'] as String?;
    if (roadmapId != null && roadmapId.isNotEmpty) {
      await prefs.setString('$_idPrefix$roadmapId', jsonEncode(roadmapJson));
    }
  }

  Future<Map<String, dynamic>> generateRoadmapJson({
    required String topic,
    required String language,
    required String level,
    required String nativeLanguage,
  }) async {
    final key = _cacheKey(topic, language, level, nativeLanguage);
    final cached = prefs.getString(key);

    if (cached != null) {
      final json = jsonDecode(cached) as Map<String, dynamic>;
      // Ensure secondary ID-based cache is populated.
      final roadmapId = json['id'] as String;
      if (prefs.getString('$_idPrefix$roadmapId') == null) {
        await prefs.setString('$_idPrefix$roadmapId', jsonEncode(json));
      }
      return json;
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
    await cacheRoadmapJson(
      roadmapJson,
      topic: topic,
      language: language,
      level: level,
      nativeLanguage: nativeLanguage,
    );
    return roadmapJson;
  }

  Future<Map<String, dynamic>> generateLessonRoadmapJson({
    required String lessonType,
    required String topic,
    required String contentType,
    required String level,
    required String nativeLanguage,
  }) async {
    final key = _cacheKey(topic, contentType, level, nativeLanguage);
    final cached = prefs.getString(key);

    if (cached != null) {
      final json = jsonDecode(cached) as Map<String, dynamic>;
      final roadmapId = json['id'] as String;
      if (prefs.getString('$_idPrefix$roadmapId') == null) {
        await prefs.setString('$_idPrefix$roadmapId', jsonEncode(json));
      }
      return json;
    }

    final response = await dio.post<Map<String, dynamic>>(
      '${ApiConstants.baseUrl}${ApiConstants.lessonRoadmapGenerate}',
      data: {
        'lessonType': lessonType == 'school' ? 'school' : 'voice',
        'topic': topic,
        if (lessonType == 'school')
          'subject': contentType
        else
          'language': contentType,
        'level': level,
        'nativeLanguage': nativeLanguage,
      },
    );

    final body = response.data!;
    final roadmapJson = body['data'] as Map<String, dynamic>;
    await cacheRoadmapJson(
      roadmapJson,
      topic: topic,
      language: contentType,
      level: level,
      nativeLanguage: nativeLanguage,
    );
    return roadmapJson;
  }

  Future<Roadmap> generateRoadmap({
    required String topic,
    required String language,
    required String level,
    required String nativeLanguage,
  }) async {
    final roadmapJson = await generateRoadmapJson(
      topic: topic,
      language: language,
      level: level,
      nativeLanguage: nativeLanguage,
    );
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
    // Also clear all secondary ID-keyed entries.
    final idKeys = prefs
        .getKeys()
        .where((k) => k.startsWith(_idPrefix))
        .toList();
    for (final k in idKeys) {
      await prefs.remove(k);
    }
  }
}
