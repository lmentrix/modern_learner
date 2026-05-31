import 'dart:convert';

import 'package:modern_learner_production/features/progress/service/model/roadmap_model.dart';

class ChapterSubcontentGenerateRequestModel {
  const ChapterSubcontentGenerateRequestModel({
    this.roadmapId,
    this.roadmapCacheKey,
    required this.chapterNumber,
    this.model,
    this.roadmapJson,
    this.topic,
    this.language,
    this.level,
    this.nativeLanguage,
  });

  final String? roadmapId;
  final String? roadmapCacheKey;
  final int chapterNumber;
  final String? model;

  /// Sent inline so the server can reconstruct the roadmap if the in-memory
  /// store was cleared (e.g. after a restart).
  final Map<String, dynamic>? roadmapJson;
  final String? topic;
  final String? language;
  final String? level;
  final String? nativeLanguage;

  Map<String, dynamic> toJson({required String resolvedRoadmapId}) {
    final selectedModel = model;
    final selectedTopic = topic;
    final selectedLanguage = language;
    final selectedLevel = level;
    final selectedNativeLanguage = nativeLanguage;
    return {
      'roadmap_id': resolvedRoadmapId,
      'chapter_number': chapterNumber,
      if (selectedModel != null && selectedModel.trim().isNotEmpty)
        'model': selectedModel,
      if (roadmapJson != null) 'roadmap_json': roadmapJson,
      if (selectedTopic != null && selectedTopic.trim().isNotEmpty)
        'topic': selectedTopic,
      if (selectedLanguage != null && selectedLanguage.trim().isNotEmpty)
        'language': selectedLanguage,
      if (selectedLevel != null && selectedLevel.trim().isNotEmpty)
        'level': selectedLevel,
      if (selectedNativeLanguage != null &&
          selectedNativeLanguage.trim().isNotEmpty)
        'native_language': selectedNativeLanguage,
    };
  }

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
      statusCode: _readInt(json, const ['status_code', 'statusCode']) ?? 200,
      requestId: _readString(json, const ['request_id', 'requestId']),
      code: _readString(json, const ['code']) ?? '',
      message: _readString(json, const ['message']) ?? '',
      model: _readString(json, const ['model']) ?? '',
      courseType:
          _readString(json, const ['course_type', 'courseType']) ?? 'school',
      chapterSubcontent: ChapterSubcontentModel.fromJson(subcontentJson),
      usage: switch (_readMap(json, const ['usage'])) {
        final usageJson? => RoadmapUsageModel.fromJson(usageJson),
        null => null,
      },
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
    if (usage != null) 'usage': usage?.toJson(),
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

  /// Maps a backend ChapterContent object (from /ai/chapter-content/generate)
  /// to this model by flattening its sections into subcontent items.
  factory ChapterSubcontentModel.fromChapterContent(Map<String, dynamic> json) {
    final chapterNumber =
        _readInt(json, const ['chapterNumber', 'chapter_number']) ?? 0;
    final chapterTitle =
        _readString(json, const ['chapterTitle', 'chapter_title']) ?? '';
    final overview =
        _readString(json, const ['introduction', 'overview']) ?? '';
    final id = _readString(json, const ['id']);
    final learningObjectives = _readStringList(json, const [
      'learningObjectives',
      'learning_objectives',
    ]);
    final summary = _readString(json, const ['summary']) ?? '';
    final culturalNotes = _readStringList(json, const [
      'culturalNotes',
      'cultural_notes',
    ]);
    final tips = _readStringList(json, const ['tips']);

    final subcontents = <ChapterSubcontentItemModel>[];
    var idx = 1;

    // Vocabulary
    final vocab = _rawList(json, 'vocabulary');
    if (vocab.isNotEmpty) {
      final activities = vocab.map((v) {
        final word = v['word']?.toString() ?? '';
        final translation = v['translation']?.toString() ?? '';
        return '$word — $translation';
      }).toList();
      subcontents.add(
        ChapterSubcontentItemModel(
          subcontentNumber: idx++,
          title: 'Vocabulary Practice',
          subcontentType: 'vocabulary',
          summary: 'Learn and practise new vocabulary for this chapter.',
          objectives: learningObjectives,
          activities: activities,
          sourceLessons: const [],
          estimatedMinutes: 15,
          focusSkills: const ['vocabulary', 'pronunciation'],
        ),
      );
    }

    // Grammar
    final grammar = _rawList(json, 'grammar');
    if (grammar.isNotEmpty) {
      final activities = grammar
          .map((g) => g['name']?.toString() ?? '')
          .toList();
      subcontents.add(
        ChapterSubcontentItemModel(
          subcontentNumber: idx++,
          title: 'Grammar Study',
          subcontentType: 'grammar',
          summary: 'Master the grammar concepts introduced in this chapter.',
          objectives: learningObjectives,
          activities: activities,
          sourceLessons: const [],
          estimatedMinutes: 20,
          focusSkills: const ['grammar', 'structure'],
        ),
      );
    }

    // Conversation
    final conversation = _rawList(json, 'conversation');
    if (conversation.isNotEmpty) {
      final activities = conversation
          .map((c) => c['title']?.toString() ?? '')
          .toList();
      subcontents.add(
        ChapterSubcontentItemModel(
          subcontentNumber: idx++,
          title: 'Conversation Practice',
          subcontentType: 'conversation',
          summary: 'Build real-world speaking skills through guided dialogue.',
          objectives: learningObjectives,
          activities: activities,
          sourceLessons: const [],
          estimatedMinutes: 20,
          focusSkills: const ['speaking', 'listening'],
        ),
      );
    }

    // Reading
    final reading = _rawList(json, 'reading');
    if (reading.isNotEmpty) {
      final activities = reading
          .map((r) => r['title']?.toString() ?? '')
          .toList();
      subcontents.add(
        ChapterSubcontentItemModel(
          subcontentNumber: idx++,
          title: 'Reading Practice',
          subcontentType: 'reading',
          summary: 'Develop reading comprehension through authentic passages.',
          objectives: learningObjectives,
          activities: activities,
          sourceLessons: const [],
          estimatedMinutes: 15,
          focusSkills: const ['reading', 'comprehension'],
        ),
      );
    }

    // Listening
    final listening = _rawList(json, 'listening');
    if (listening.isNotEmpty) {
      final activities = listening
          .map((l) => l['title']?.toString() ?? '')
          .toList();
      subcontents.add(
        ChapterSubcontentItemModel(
          subcontentNumber: idx++,
          title: 'Listening Practice',
          subcontentType: 'listening',
          summary: 'Sharpen your ear with curated listening exercises.',
          objectives: learningObjectives,
          activities: activities,
          sourceLessons: const [],
          estimatedMinutes: 15,
          focusSkills: const ['listening', 'comprehension'],
        ),
      );
    }

    // Exercises (always present per schema)
    final exercises = _rawList(json, 'exercises');
    if (exercises.isNotEmpty) {
      final activities = exercises
          .map((e) => e['title']?.toString() ?? '')
          .toList();
      subcontents.add(
        ChapterSubcontentItemModel(
          subcontentNumber: idx++,
          title: 'Practice Exercises',
          subcontentType: 'exercise',
          summary: 'Reinforce learning with targeted practice questions.',
          objectives: learningObjectives,
          activities: activities,
          sourceLessons: const [],
          estimatedMinutes: 20,
          focusSkills: const ['recall', 'application'],
        ),
      );
    }

    // Chapter review / summary
    if (summary.isNotEmpty || culturalNotes.isNotEmpty || tips.isNotEmpty) {
      subcontents.add(
        ChapterSubcontentItemModel(
          subcontentNumber: idx,
          title: 'Chapter Review',
          subcontentType: 'review',
          summary: summary.isNotEmpty ? summary : 'Review and consolidate.',
          objectives: learningObjectives,
          activities: [
            ...culturalNotes.map((n) => '🌍 $n'),
            ...tips.map((t) => '💡 $t'),
          ],
          sourceLessons: const [],
          estimatedMinutes: 10,
          focusSkills: const ['review', 'retention'],
        ),
      );
    }

    return ChapterSubcontentModel(
      courseType: 'school',
      chapterNumber: chapterNumber,
      chapterTitle: chapterTitle,
      overview: overview,
      subcontents: subcontents,
      id: id,
    );
  }

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

/// Helper used by [ChapterSubcontentModel.fromChapterContent] to extract a
/// typed list from a single top-level key (backend uses camelCase).
List<Map<String, dynamic>> _rawList(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is List) {
    return value.whereType<Map>().map(Map<String, dynamic>.from).toList();
  }
  return const [];
}
