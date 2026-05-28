import 'dart:convert';

/// Row model for the `roadmaps` table.
class RoadmapDbModel {
  const RoadmapDbModel({
    required this.id,
    required this.userId,
    required this.roadmapMode,
    required this.topic,
    required this.roadmapLanguage,
    required this.level,
    required this.nativeLanguage,
    this.model,
    this.requestId,
    this.statusCode,
    required this.mocked,
    required this.roadmapJson,
    this.usage,
    this.rawContent,
    this.prompt,
    this.code,
    this.message,
    this.temperature,
    this.maxTokens,
    this.topP,
    this.courseId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RoadmapDbModel.fromJson(Map<String, dynamic> json) {
    return RoadmapDbModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      roadmapMode: json['roadmap_mode'] as String? ?? 'school',
      topic: json['topic'] as String,
      roadmapLanguage: json['roadmap_language'] as String,
      level: json['level'] as String,
      nativeLanguage: json['native_language'] as String? ?? 'English',
      model: json['model'] as String?,
      requestId: json['request_id'] as String?,
      statusCode: json['status_code'] as int?,
      mocked: json['mocked'] as bool? ?? false,
      roadmapJson: json['roadmap_json'] is Map
          ? Map<String, dynamic>.from(json['roadmap_json'] as Map)
          : jsonDecode(json['roadmap_json'] as String) as Map<String, dynamic>,
      usage: json['usage'] is Map
          ? Map<String, dynamic>.from(json['usage'] as Map)
          : null,
      rawContent: json['raw_content'] as String?,
      prompt: json['prompt'] as String?,
      code: json['code'] as String?,
      message: json['message'] as String?,
      temperature: (json['temperature'] as num?)?.toDouble(),
      maxTokens: json['max_tokens'] as int?,
      topP: (json['top_p'] as num?)?.toDouble(),
      courseId: json['course_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  final String id;
  final String userId;
  final String roadmapMode;
  final String topic;
  final String roadmapLanguage;
  final String level;
  final String nativeLanguage;
  final String? model;
  final String? requestId;
  final int? statusCode;
  final bool mocked;
  final Map<String, dynamic> roadmapJson;
  final Map<String, dynamic>? usage;
  final String? rawContent;
  final String? prompt;
  final String? code;
  final String? message;
  final double? temperature;
  final int? maxTokens;
  final double? topP;
  final String? courseId;
  final DateTime createdAt;
  final DateTime updatedAt;
}

/// Insert/upsert payload for the `roadmaps` table.
class UpsertRoadmapRequest {
  const UpsertRoadmapRequest({
    required this.userId,
    required this.roadmapMode,
    required this.topic,
    required this.roadmapLanguage,
    required this.level,
    required this.nativeLanguage,
    this.model,
    this.requestId,
    this.statusCode,
    required this.mocked,
    required this.roadmapJson,
    this.usage,
    this.rawContent,
    this.prompt,
    this.code,
    this.message,
    this.temperature,
    this.maxTokens,
    this.topP,
    this.courseId,
  });

  final String userId;
  final String roadmapMode;
  final String topic;
  final String roadmapLanguage;
  final String level;
  final String nativeLanguage;
  final String? model;
  final String? requestId;
  final int? statusCode;
  final bool mocked;
  final Map<String, dynamic> roadmapJson;
  final Map<String, dynamic>? usage;
  final String? rawContent;
  final String? prompt;
  final String? code;
  final String? message;
  final double? temperature;
  final int? maxTokens;
  final double? topP;
  final String? courseId;

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'roadmap_mode': roadmapMode,
    'topic': topic,
    'roadmap_language': roadmapLanguage,
    'level': level,
    'native_language': nativeLanguage,
    if (model != null) 'model': model,
    if (requestId != null) 'request_id': requestId,
    if (statusCode != null) 'status_code': statusCode,
    'mocked': mocked,
    'roadmap_json': roadmapJson,
    if (usage != null) 'usage': usage,
    if (rawContent != null) 'raw_content': rawContent,
    if (prompt != null) 'prompt': prompt,
    if (code != null) 'code': code,
    if (message != null) 'message': message,
    if (temperature != null) 'temperature': temperature,
    if (maxTokens != null) 'max_tokens': maxTokens,
    if (topP != null) 'top_p': topP,
    if (courseId != null) 'course_id': courseId,
  };
}

/// Row model for the `roadmap_chapter_progress` table.
class RoadmapChapterProgressDbModel {
  const RoadmapChapterProgressDbModel({
    required this.id,
    required this.userId,
    required this.roadmapId,
    required this.courseKey,
    required this.chapterNumber,
    required this.chapterTitle,
    required this.overview,
    required this.isCompleted,
    this.completedAt,
    this.chapterSubcontentJson,
    this.subcontentApiId,
    this.courseId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RoadmapChapterProgressDbModel.fromJson(Map<String, dynamic> json) {
    return RoadmapChapterProgressDbModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      roadmapId: json['roadmap_id'] as String,
      courseKey: json['course_key'] as String,
      chapterNumber: json['chapter_number'] as int,
      chapterTitle: json['chapter_title'] as String? ?? '',
      overview: json['overview'] as String? ?? '',
      isCompleted: json['is_completed'] as bool? ?? false,
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
      chapterSubcontentJson: json['chapter_subcontent_json'] is Map
          ? Map<String, dynamic>.from(json['chapter_subcontent_json'] as Map)
          : null,
      subcontentApiId: json['subcontent_api_id'] as String?,
      courseId: json['course_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  final String id;
  final String userId;
  final String roadmapId;
  final String courseKey;
  final int chapterNumber;
  final String chapterTitle;
  final String overview;
  final bool isCompleted;
  final DateTime? completedAt;
  final Map<String, dynamic>? chapterSubcontentJson;
  final String? subcontentApiId;
  final String? courseId;
  final DateTime createdAt;
  final DateTime updatedAt;
}

/// Insert/upsert payload for the `roadmap_chapter_progress` table.
class UpsertChapterProgressRequest {
  const UpsertChapterProgressRequest({
    required this.userId,
    required this.roadmapId,
    required this.courseKey,
    required this.chapterNumber,
    required this.chapterTitle,
    required this.overview,
    this.chapterSubcontentJson,
    this.subcontentApiId,
    this.courseId,
    this.isCompleted = false,
    this.completedAt,
  });

  final String userId;
  final String roadmapId;
  final String courseKey;
  final int chapterNumber;
  final String chapterTitle;
  final String overview;
  final Map<String, dynamic>? chapterSubcontentJson;
  final String? subcontentApiId;
  final String? courseId;
  final bool isCompleted;
  final DateTime? completedAt;

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'roadmap_id': roadmapId,
    'course_key': courseKey,
    'chapter_number': chapterNumber,
    'chapter_title': chapterTitle,
    'overview': overview,
    if (chapterSubcontentJson != null)
      'chapter_subcontent_json': chapterSubcontentJson,
    if (subcontentApiId != null) 'subcontent_api_id': subcontentApiId,
    if (courseId != null) 'course_id': courseId,
    'is_completed': isCompleted,
    if (completedAt != null) 'completed_at': completedAt!.toIso8601String(),
  };
}
