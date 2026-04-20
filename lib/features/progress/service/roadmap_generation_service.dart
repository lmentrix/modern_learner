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

    late final Map<String, dynamic> roadmapJson;
    try {
      roadmapJson = await _fetchVoiceRoadmap(
        topic: topic,
        language: language,
        level: level,
        nativeLanguage: nativeLanguage,
      );
    } catch (_) {
      final response = await dio.post<Map<String, dynamic>>(
        '${ApiConstants.baseUrl}${ApiConstants.roadmapGenerate}',
        data: {
          'topic': topic,
          'language': language,
          'level': level,
          'nativeLanguage': nativeLanguage,
        },
      );
      roadmapJson = _unwrapPayload(response.data);
    }

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

    try {
      final roadmapJson = lessonType == 'school'
          ? await _fetchLegacyLessonRoadmap(
              topic: topic,
              contentType: contentType,
              level: level,
              nativeLanguage: nativeLanguage,
            )
          : await _fetchVoiceRoadmap(
              topic: topic,
              language: contentType,
              level: level,
              nativeLanguage: nativeLanguage,
            );
      await cacheRoadmapJson(
        roadmapJson,
        topic: topic,
        language: contentType,
        level: level,
        nativeLanguage: nativeLanguage,
      );
      return roadmapJson;
    } catch (_) {
      // API unavailable — return a minimal stub so lesson creation still succeeds.
      return _minimalLessonRoadmap(
        lessonType: lessonType,
        topic: topic,
        contentType: contentType,
        level: level,
      );
    }
  }

  /// Builds a minimal roadmap JSON used as a fallback when the AI API is unreachable.
  Map<String, dynamic> _minimalLessonRoadmap({
    required String lessonType,
    required String topic,
    required String contentType,
    required String level,
  }) {
    return {
      'id': 'offline_${DateTime.now().millisecondsSinceEpoch}',
      'title': '$contentType – $topic',
      'description': 'Generated offline. Reload to fetch AI content.',
      'targetLanguage': contentType,
      'level': level,
      'totalXp': 0,
      'estimatedHours': 0,
      'chapters': [],
    };
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

  Future<Map<String, dynamic>> _fetchVoiceRoadmap({
    required String topic,
    required String language,
    required String level,
    required String nativeLanguage,
  }) async {
    final response = await dio.post<Map<String, dynamic>>(
      '${ApiConstants.baseUrl}${ApiConstants.voiceCourseRoadmapGenerate}',
      data: {
        'language': language,
        'topic': topic,
        'level': level,
        'nativeLanguage': nativeLanguage,
      },
    );

    return _normalizeVoiceRoadmap(
      _unwrapPayload(response.data),
      topic: topic,
      language: language,
      level: level,
      nativeLanguage: nativeLanguage,
    );
  }

  Future<Map<String, dynamic>> _fetchLegacyLessonRoadmap({
    required String topic,
    required String contentType,
    required String level,
    required String nativeLanguage,
  }) async {
    final response = await dio.post<Map<String, dynamic>>(
      '${ApiConstants.baseUrl}${ApiConstants.lessonRoadmapGenerate}',
      data: {
        'lessonType': 'school',
        'topic': topic,
        'subject': contentType,
        'level': level,
        'nativeLanguage': nativeLanguage,
      },
    );

    return _unwrapPayload(response.data);
  }

  Map<String, dynamic> _unwrapPayload(Map<String, dynamic>? raw) {
    if (raw == null) return <String, dynamic>{};
    final nested = raw['data'];
    if (nested is Map<String, dynamic>) return nested;
    return raw;
  }

  Map<String, dynamic> _normalizeVoiceRoadmap(
    Map<String, dynamic> json, {
    required String topic,
    required String language,
    required String level,
    required String nativeLanguage,
  }) {
    final chapters = (json['chapters'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map((chapter) => _normalizeVoiceChapter(chapter))
        .toList();

    return {
      'id': json['id'] as String? ?? 'voice_${DateTime.now().millisecondsSinceEpoch}',
      'title': json['title'] as String? ?? '$language Voice Roadmap',
      'description':
          json['description'] as String? ??
          'AI-generated voice-focused learning roadmap.',
      'topic': json['topic'] as String? ?? topic,
      'targetLanguage': json['targetLanguage'] as String? ?? language,
      'nativeLanguage': json['nativeLanguage'] as String? ?? nativeLanguage,
      'level': json['level'] as String? ?? level,
      'totalXp': _asInt(json['totalXp']),
      'estimatedHours': _asInt(json['estimatedHours']),
      'ai_generated':
          json['aiGenerated'] as bool? ?? json['ai_generated'] as bool? ?? true,
      if (json['voiceProfile'] != null || json['voice_profile'] != null)
        'voice_profile':
            (json['voiceProfile'] as Map<String, dynamic>?) ??
            (json['voice_profile'] as Map<String, dynamic>?),
      'chapters': chapters,
    };
  }

  Map<String, dynamic> _normalizeVoiceChapter(Map<String, dynamic> json) {
    final lessons = (json['lessons'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map((lesson) => _normalizeVoiceLesson(lesson))
        .toList();

    return {
      'id': json['id'] as String? ?? '',
      'chapterNumber': _asInt(json['chapterNumber']),
      'title': json['title'] as String? ?? '',
      'description': json['description'] as String? ?? '',
      'icon': json['icon'] as String? ?? '🎤',
      'type': json['type'] as String? ?? 'lesson',
      'xpReward': _asInt(json['xpReward']),
      'gemReward': _asInt(json['gemReward']),
      'prerequisites': (json['prerequisites'] as List<dynamic>? ?? [])
          .map((value) => value as String)
          .toList(),
      'skills': (json['focusSkills'] as List<dynamic>? ??
              json['skills'] as List<dynamic>? ??
              [])
          .map((value) => value as String)
          .toList(),
      'pronunciation_focus':
          json['pronunciationFocus'] as String? ??
          json['pronunciation_focus'] as String? ??
          '',
      'audio_cues': (json['audioCues'] as List<dynamic>? ??
              json['audio_cues'] as List<dynamic>? ??
              [])
          .map((value) => value as String)
          .toList(),
      if (json['speech'] != null) 'speech': json['speech'],
      'lessons': lessons,
    };
  }

  Map<String, dynamic> _normalizeVoiceLesson(Map<String, dynamic> json) {
    final originalType = json['type'] as String? ?? 'voice_exercise';

    return {
      'id': json['id'] as String? ?? '',
      'title': json['title'] as String? ?? '',
      'type': _mapVoiceLessonType(originalType),
      'voice_type':
          json['voiceType'] as String? ??
          json['voice_type'] as String? ??
          originalType,
      'description': json['description'] as String? ?? '',
      'xpReward': _asInt(json['xpReward']),
      'duration_minutes':
          _asNullableInt(json['durationMinutes']) ??
          _asNullableInt(json['duration_minutes']),
      'audio_cues': (json['audioCues'] as List<dynamic>? ??
              json['audio_cues'] as List<dynamic>? ??
              [])
          .map((value) => value as String)
          .toList(),
      if (json['speech'] != null) 'speech': json['speech'],
      'status': json['status'] as String? ?? 'locked',
    };
  }

  String _mapVoiceLessonType(String type) {
    switch (type) {
      case 'pronunciation':
      case 'voice_exercise':
      case 'quiz':
        return 'exercise';
      case 'dialogue':
        return 'conversation';
      case 'reading':
        return 'reading';
      case 'vocabulary':
        return 'vocabulary';
      default:
        return 'exercise';
    }
  }

  int _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.round();
    return 0;
  }

  int? _asNullableInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.round();
    return null;
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
