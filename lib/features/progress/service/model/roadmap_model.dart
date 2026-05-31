import 'dart:convert';

class RoadmapGenerateRequestModel {
  const RoadmapGenerateRequestModel({
    this.roadmapMode = 'school',
    required this.topic,
    required this.language,
    required this.level,
    this.nativeLanguage = 'English',
    this.model,
    this.temperature = 0.2,
    this.maxTokens = 16000,
    this.topP = 1,
  });

  factory RoadmapGenerateRequestModel.fromJson(Map<String, dynamic> json) {
    return RoadmapGenerateRequestModel(
      roadmapMode:
          _readString(json, const ['roadmap_mode', 'roadmapMode']) ?? 'school',
      topic: _readString(json, const ['topic']) ?? '',
      language: _readString(json, const ['language']) ?? '',
      level: _readString(json, const ['level']) ?? '',
      nativeLanguage:
          _readString(json, const ['native_language', 'nativeLanguage']) ??
          'English',
      model: _readString(json, const ['model']),
      temperature: _readNum(json, const ['temperature'])?.toDouble() ?? 0.2,
      maxTokens: _readInt(json, const ['max_tokens', 'maxTokens']) ?? 16000,
      topP: _readNum(json, const ['top_p', 'topP'])?.toDouble() ?? 1,
    );
  }

  final String roadmapMode;
  final String topic;
  final String language;
  final String level;
  final String nativeLanguage;
  final String? model;
  final double temperature;
  final int maxTokens;
  final double topP;

  Map<String, dynamic> toJson() {
    final selectedModel = model;
    return {
      'roadmap_mode': roadmapMode,
      'topic': topic,
      'language': language,
      'level': level,
      'native_language': nativeLanguage,
      if (selectedModel != null && selectedModel.trim().isNotEmpty)
        'model': selectedModel,
      'temperature': temperature,
      'max_tokens': maxTokens,
      'top_p': topP,
    };
  }

  String toRawJson() => jsonEncode(toJson());
}

class RoadmapResponseModel {
  const RoadmapResponseModel({
    required this.statusCode,
    this.requestId,
    required this.code,
    required this.message,
    required this.model,
    required this.roadmapMode,
    required this.mocked,
    required this.roadmap,
    this.usage,
    this.rawContent,
    this.prompt,
    this.rawJson,
  });

  factory RoadmapResponseModel.fromJson(Map<String, dynamic> json) {
    // FastAPI /openrouter/roadmaps/generate returns an envelope:
    // {status_code, roadmap: {...}, ...}
    // The inner roadmap can be nested under 'roadmap'.
    // Direct format (chapters at top level) is also accepted as a fallback.
    Map<String, dynamic>? roadmapJson = _readMap(json, const ['roadmap']);

    if (roadmapJson == null) {
      // Fallback: the whole response is the roadmap (e.g. stored rawJson).
      if (json['chapters'] is List) {
        roadmapJson = json;
      } else {
        throw const FormatException('Missing roadmap payload.');
      }
    }

    return RoadmapResponseModel(
      statusCode: _readInt(json, const ['status_code', 'statusCode']) ?? 200,
      requestId: _readString(json, const ['request_id', 'requestId']),
      code: _readString(json, const ['code']) ?? '',
      message: _readString(json, const ['message']) ?? '',
      model: _readString(json, const ['model']) ?? '',
      roadmapMode:
          _readString(json, const ['roadmap_mode', 'roadmapMode']) ?? 'school',
      mocked: json['mocked'] as bool? ?? false,
      roadmap: RoadmapModel.fromJson(roadmapJson),
      usage: switch (_readMap(json, const ['usage'])) {
        final usageJson? => RoadmapUsageModel.fromJson(usageJson),
        null => null,
      },
      rawContent: _readString(json, const ['raw_content', 'rawContent']),
      prompt: _readString(json, const ['prompt']),
      rawJson: json,
    );
  }

  factory RoadmapResponseModel.fromRawJson(String source) =>
      RoadmapResponseModel.fromJson(
        Map<String, dynamic>.from(jsonDecode(source) as Map),
      );

  final int statusCode;
  final String? requestId;
  final String code;
  final String message;
  final String model;
  final String roadmapMode;
  final bool mocked;
  final RoadmapModel roadmap;
  final RoadmapUsageModel? usage;
  final String? rawContent;
  final String? prompt;

  /// The original JSON from the backend — stored so it can be forwarded verbatim
  /// to the /ai/chapter-content/generate endpoint as the `roadmap` field.
  final Map<String, dynamic>? rawJson;

  Map<String, dynamic> toJson() => {
    'status_code': statusCode,
    if (requestId != null) 'request_id': requestId,
    'code': code,
    'message': message,
    'model': model,
    'roadmapMode': roadmapMode,
    'mocked': mocked,
    'roadmap': roadmap.toJson(),
    if (usage != null) 'usage': usage?.toJson(),
    if (rawContent != null) 'raw_content': rawContent,
    if (prompt != null) 'prompt': prompt,
  };

  String toRawJson() => jsonEncode(toJson());
}

class RoadmapModel {
  const RoadmapModel({
    required this.title,
    required this.summary,
    required this.targetLanguage,
    required this.level,
    required this.estimatedHours,
    required this.objectives,
    required this.chapters,
    this.courseType,
    this.id,
    this.topic,
    this.nativeLanguage,
  });

  factory RoadmapModel.fromJson(Map<String, dynamic> json) {
    return RoadmapModel(
      title: _readString(json, const ['title']) ?? '',
      summary: _readString(json, const ['summary', 'description']) ?? '',
      targetLanguage:
          _readString(json, const ['target_language', 'targetLanguage']) ?? '',
      level: _readString(json, const ['level']) ?? '',
      estimatedHours:
          _readInt(json, const ['estimated_hours', 'estimatedHours']) ?? 0,
      objectives: _readStringList(json, const ['objectives']),
      chapters: _readList(json, const ['chapters'])
          .map(
            (chapter) => RoadmapChapterModel.fromJson(
              Map<String, dynamic>.from(chapter),
            ),
          )
          .toList(),
      courseType: _readString(json, const ['course_type', 'courseType']),
      id: _readString(json, const ['id']),
      topic: _readString(json, const ['topic']),
      nativeLanguage: _readString(json, const [
        'native_language',
        'nativeLanguage',
      ]),
    );
  }

  factory RoadmapModel.fromRawJson(String source) => RoadmapModel.fromJson(
    Map<String, dynamic>.from(jsonDecode(source) as Map),
  );

  final String title;
  final String summary;
  final String targetLanguage;
  final String level;
  final int estimatedHours;
  final List<String> objectives;
  final List<RoadmapChapterModel> chapters;
  final String? courseType;
  final String? id;
  final String? topic;
  final String? nativeLanguage;

  Map<String, dynamic> toJson() => {
    'title': title,
    'summary': summary,
    'target_language': targetLanguage,
    'level': level,
    'estimated_hours': estimatedHours,
    'objectives': objectives,
    'chapters': chapters.map((chapter) => chapter.toJson()).toList(),
    if (courseType != null) 'course_type': courseType,
    if (id != null) 'id': id,
    if (topic != null) 'topic': topic,
    if (nativeLanguage != null) 'native_language': nativeLanguage,
  };

  String toRawJson() => jsonEncode(toJson());
}

class RoadmapChapterModel {
  const RoadmapChapterModel({
    required this.chapterNumber,
    required this.title,
    required this.description,
    required this.skills,
    required this.lessons,
  });

  factory RoadmapChapterModel.fromJson(Map<String, dynamic> json) {
    return RoadmapChapterModel(
      chapterNumber:
          _readInt(json, const ['chapter_number', 'chapterNumber']) ?? 0,
      title: _readString(json, const ['title']) ?? '',
      description: _readString(json, const ['description']) ?? '',
      skills: _readStringList(json, const ['skills']),
      lessons: _readList(json, const ['lessons'])
          .asMap()
          .entries
          .map(
            (e) => RoadmapLessonModel.fromJson(
              Map<String, dynamic>.from(e.value),
              indexFallback: e.key,
            ),
          )
          .toList(),
    );
  }

  final int chapterNumber;
  final String title;
  final String description;
  final List<String> skills;
  final List<RoadmapLessonModel> lessons;

  Map<String, dynamic> toJson() => {
    'chapter_number': chapterNumber,
    'title': title,
    'description': description,
    'skills': skills,
    'lessons': lessons.map((lesson) => lesson.toJson()).toList(),
  };
}

class RoadmapLessonModel {
  const RoadmapLessonModel({
    required this.lessonNumber,
    required this.title,
    required this.type,
    required this.description,
    required this.objectives,
  });

  factory RoadmapLessonModel.fromJson(
    Map<String, dynamic> json, {
    int indexFallback = 0,
  }) {
    return RoadmapLessonModel(
      lessonNumber:
          _readInt(json, const ['lesson_number', 'lessonNumber']) ??
          (indexFallback + 1),
      title: _readString(json, const ['title']) ?? '',
      type: _readString(json, const ['type']) ?? '',
      description: _readString(json, const ['description']) ?? '',
      objectives: _readStringList(json, const ['objectives']),
    );
  }

  final int lessonNumber;
  final String title;
  final String type;
  final String description;
  final List<String> objectives;

  Map<String, dynamic> toJson() => {
    'lesson_number': lessonNumber,
    'title': title,
    'type': type,
    'description': description,
    'objectives': objectives,
  };
}

class RoadmapUsageModel {
  const RoadmapUsageModel({
    this.inputTokens,
    this.outputTokens,
    this.totalTokens,
  });

  factory RoadmapUsageModel.fromJson(Map<String, dynamic> json) {
    return RoadmapUsageModel(
      inputTokens: _readInt(json, const ['input_tokens', 'inputTokens']),
      outputTokens: _readInt(json, const ['output_tokens', 'outputTokens']),
      totalTokens: _readInt(json, const ['total_tokens', 'totalTokens']),
    );
  }

  final int? inputTokens;
  final int? outputTokens;
  final int? totalTokens;

  Map<String, dynamic> toJson() => {
    'input_tokens': inputTokens,
    'output_tokens': outputTokens,
    'total_tokens': totalTokens,
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

num? _readNum(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is num) return value;
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
