import 'dart:convert';

import 'package:modern_learner_production/features/progress/service/model/roadmap_model.dart';

class ChapterSubcontentGenerateRequestModel {
  const ChapterSubcontentGenerateRequestModel({
    this.roadmapId,
    this.roadmapCacheKey,
    required this.chapterNumber,
    this.model,
  });

  factory ChapterSubcontentGenerateRequestModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ChapterSubcontentGenerateRequestModel(
      roadmapId: _readString(json, const ['roadmap_id', 'roadmapId']),
      roadmapCacheKey: _readString(json, const [
        'roadmap_cache_key',
        'roadmapCacheKey',
      ]),
      chapterNumber:
          _readInt(json, const ['chapter_number', 'chapterNumber']) ?? 1,
      model: _readString(json, const ['model']),
    );
  }

  final String? roadmapId;
  final String? roadmapCacheKey;
  final int chapterNumber;
  final String? model;

  Map<String, dynamic> toJson({required String resolvedRoadmapId}) => {
    'roadmap_id': resolvedRoadmapId,
    'chapter_number': chapterNumber,
    if (model != null && model!.trim().isNotEmpty) 'model': model,
  };

  String toRawJson({required String resolvedRoadmapId}) =>
      jsonEncode(toJson(resolvedRoadmapId: resolvedRoadmapId));
}

class ChapterSubcontentResponseModel {
  const ChapterSubcontentResponseModel({
    required this.statusCode,
    this.requestId,
    required this.code,
    required this.message,
    required this.model,
    required this.courseType,
    required this.chapterSubcontent,
    this.usage,
    this.rawContent,
    this.prompt,
  });

  factory ChapterSubcontentResponseModel.fromJson(Map<String, dynamic> json) {
    final subcontentJson = _readMap(json, const [
      'chapter_subcontent',
      'chapterSubcontent',
    ]);
    if (subcontentJson == null) {
      throw const FormatException('Missing chapter subcontent payload.');
    }

    return ChapterSubcontentResponseModel(
      statusCode: _readInt(json, const ['status_code', 'statusCode']) ?? 0,
      requestId: _readString(json, const ['request_id', 'requestId']),
      code: _readString(json, const ['code']) ?? '',
      message: _readString(json, const ['message']) ?? '',
      model: _readString(json, const ['model']) ?? '',
      courseType:
          _readString(json, const ['course_type', 'courseType']) ?? 'school',
      chapterSubcontent: ChapterSubcontentModel.fromJson(subcontentJson),
      usage: _readMap(json, const ['usage']) == null
          ? null
          : RoadmapUsageModel.fromJson(_readMap(json, const ['usage'])!),
      rawContent: _readString(json, const ['raw_content', 'rawContent']),
      prompt: _readString(json, const ['prompt']),
    );
  }

  factory ChapterSubcontentResponseModel.fromRawJson(String source) =>
      ChapterSubcontentResponseModel.fromJson(
        Map<String, dynamic>.from(jsonDecode(source) as Map),
      );

  final int statusCode;
  final String? requestId;
  final String code;
  final String message;
  final String model;
  final String courseType;
  final ChapterSubcontentModel chapterSubcontent;
  final RoadmapUsageModel? usage;
  final String? rawContent;
  final String? prompt;

  Map<String, dynamic> toJson() => {
    'status_code': statusCode,
    if (requestId != null) 'request_id': requestId,
    'code': code,
    'message': message,
    'model': model,
    'course_type': courseType,
    'chapter_subcontent': chapterSubcontent.toJson(),
    if (usage != null) 'usage': usage!.toJson(),
    if (rawContent != null) 'raw_content': rawContent,
    if (prompt != null) 'prompt': prompt,
  };

  String toRawJson() => jsonEncode(toJson());
}

class ChapterSubcontentModel {
  const ChapterSubcontentModel({
    required this.courseType,
    required this.chapterNumber,
    required this.chapterTitle,
    required this.overview,
    required this.subcontents,
    this.id,
    this.roadmapId,
    this.topic,
    this.targetLanguage,
    this.level,
  });

  factory ChapterSubcontentModel.fromJson(Map<String, dynamic> json) {
    return ChapterSubcontentModel(
      courseType:
          _readString(json, const ['course_type', 'courseType']) ?? 'school',
      chapterNumber:
          _readInt(json, const ['chapter_number', 'chapterNumber']) ?? 0,
      chapterTitle:
          _readString(json, const ['chapter_title', 'chapterTitle']) ?? '',
      overview: _readString(json, const ['overview']) ?? '',
      subcontents: _readList(json, const ['subcontents'])
          .map(
            (item) => ChapterSubcontentItemModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
      id: _readString(json, const ['id']),
      roadmapId: _readString(json, const ['roadmap_id', 'roadmapId']),
      topic: _readString(json, const ['topic']),
      targetLanguage: _readString(json, const [
        'target_language',
        'targetLanguage',
      ]),
      level: _readString(json, const ['level']),
    );
  }

  factory ChapterSubcontentModel.fromRawJson(String source) =>
      ChapterSubcontentModel.fromJson(
        Map<String, dynamic>.from(jsonDecode(source) as Map),
      );

  final String courseType;
  final int chapterNumber;
  final String chapterTitle;
  final String overview;
  final List<ChapterSubcontentItemModel> subcontents;
  final String? id;
  final String? roadmapId;
  final String? topic;
  final String? targetLanguage;
  final String? level;

  Map<String, dynamic> toJson() => {
    'course_type': courseType,
    'chapter_number': chapterNumber,
    'chapter_title': chapterTitle,
    'overview': overview,
    'subcontents': subcontents.map((item) => item.toJson()).toList(),
    if (id != null) 'id': id,
    if (roadmapId != null) 'roadmap_id': roadmapId,
    if (topic != null) 'topic': topic,
    if (targetLanguage != null) 'target_language': targetLanguage,
    if (level != null) 'level': level,
  };

  String toRawJson() => jsonEncode(toJson());
}

class ChapterSubcontentItemModel {
  const ChapterSubcontentItemModel({
    required this.subcontentNumber,
    required this.title,
    required this.subcontentType,
    required this.summary,
    required this.objectives,
    required this.activities,
    required this.sourceLessons,
    required this.estimatedMinutes,
    required this.focusSkills,
    this.teachingNote,
    this.speakingFocus,
    this.audioCues = const [],
  });

  factory ChapterSubcontentItemModel.fromJson(Map<String, dynamic> json) {
    return ChapterSubcontentItemModel(
      subcontentNumber:
          _readInt(json, const ['subcontent_number', 'subcontentNumber']) ?? 0,
      title: _readString(json, const ['title']) ?? '',
      subcontentType:
          _readString(json, const ['subcontent_type', 'subcontentType']) ?? '',
      summary: _readString(json, const ['summary']) ?? '',
      objectives: _readStringList(json, const ['objectives']),
      activities: _readStringList(json, const ['activities']),
      sourceLessons: _readStringList(json, const [
        'source_lessons',
        'sourceLessons',
      ]),
      estimatedMinutes:
          _readInt(json, const ['estimated_minutes', 'estimatedMinutes']) ?? 0,
      focusSkills: _readStringList(json, const ['focus_skills', 'focusSkills']),
      teachingNote: _readString(json, const ['teaching_note', 'teachingNote']),
      speakingFocus: _readString(json, const [
        'speaking_focus',
        'speakingFocus',
      ]),
      audioCues: _readStringList(json, const ['audio_cues', 'audioCues']),
    );
  }

  final int subcontentNumber;
  final String title;
  final String subcontentType;
  final String summary;
  final List<String> objectives;
  final List<String> activities;
  final List<String> sourceLessons;
  final int estimatedMinutes;
  final List<String> focusSkills;
  final String? teachingNote;
  final String? speakingFocus;
  final List<String> audioCues;

  Map<String, dynamic> toJson() => {
    'subcontent_number': subcontentNumber,
    'title': title,
    'subcontent_type': subcontentType,
    'summary': summary,
    'objectives': objectives,
    'activities': activities,
    'source_lessons': sourceLessons,
    'estimated_minutes': estimatedMinutes,
    'focus_skills': focusSkills,
    if (teachingNote != null) 'teaching_note': teachingNote,
    if (speakingFocus != null) 'speaking_focus': speakingFocus,
    if (audioCues.isNotEmpty) 'audio_cues': audioCues,
  };
}

String? _readString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String) return value;
    if (value != null) return value.toString();
  }

  return null;
}

int? _readInt(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
  }

  return null;
}

Map<String, dynamic>? _readMap(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
  }

  return null;
}

List<Map<String, dynamic>> _readList(
  Map<String, dynamic> json,
  List<String> keys,
) {
  for (final key in keys) {
    final value = json[key];
    if (value is List) {
      return value.whereType<Map>().map(Map<String, dynamic>.from).toList();
    }
  }

  return const [];
}

List<String> _readStringList(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
  }

  return const [];
}
