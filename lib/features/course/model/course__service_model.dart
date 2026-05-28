class UserCourseModel {
  const UserCourseModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.topic,
    required this.roadmapLanguage,
    required this.level,
    required this.nativeLanguage,
    this.roadmapJson,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String title;
  final String topic;
  final String roadmapLanguage;
  final String level;
  final String nativeLanguage;
  final Map<String, dynamic>? roadmapJson;
  final DateTime createdAt;

  factory UserCourseModel.fromJson(Map<String, dynamic> json) {
    return UserCourseModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      topic: json['topic'] as String,
      roadmapLanguage: json['roadmap_language'] as String,
      level: json['level'] as String,
      nativeLanguage: json['native_language'] as String? ?? 'English',
      roadmapJson: json['roadmap_json'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toInsertJson() => {
    'user_id': userId,
    'title': title,
    'topic': topic,
    'roadmap_language': roadmapLanguage,
    'level': level,
    'native_language': nativeLanguage,
    if (roadmapJson != null) 'roadmap_json': roadmapJson,
  };

  Map<String, dynamic> toUpdateJson() => {
    'title': title,
    'topic': topic,
    'roadmap_language': roadmapLanguage,
    'level': level,
    'native_language': nativeLanguage,
    if (roadmapJson != null) 'roadmap_json': roadmapJson,
  };

  UserCourseModel copyWith({
    String? title,
    String? topic,
    String? roadmapLanguage,
    String? level,
    String? nativeLanguage,
    Map<String, dynamic>? roadmapJson,
  }) {
    return UserCourseModel(
      id: id,
      userId: userId,
      title: title ?? this.title,
      topic: topic ?? this.topic,
      roadmapLanguage: roadmapLanguage ?? this.roadmapLanguage,
      level: level ?? this.level,
      nativeLanguage: nativeLanguage ?? this.nativeLanguage,
      roadmapJson: roadmapJson ?? this.roadmapJson,
      createdAt: createdAt,
    );
  }
}

class CreateUserCourseRequest {
  const CreateUserCourseRequest({
    required this.userId,
    required this.title,
    required this.topic,
    required this.roadmapLanguage,
    required this.level,
    required this.nativeLanguage,
    this.roadmapJson,
  });

  final String userId;
  final String title;
  final String topic;
  final String roadmapLanguage;
  final String level;
  final String nativeLanguage;
  final Map<String, dynamic>? roadmapJson;

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'title': title,
    'topic': topic,
    'roadmap_language': roadmapLanguage,
    'level': level,
    'native_language': nativeLanguage,
    if (roadmapJson != null) 'roadmap_json': roadmapJson,
  };
}

class UpdateUserCourseRequest {
  const UpdateUserCourseRequest({
    this.title,
    this.topic,
    this.roadmapLanguage,
    this.level,
    this.nativeLanguage,
    this.roadmapJson,
  });

  final String? title;
  final String? topic;
  final String? roadmapLanguage;
  final String? level;
  final String? nativeLanguage;
  final Map<String, dynamic>? roadmapJson;

  Map<String, dynamic> toJson() => {
    if (title != null) 'title': title,
    if (topic != null) 'topic': topic,
    if (roadmapLanguage != null) 'roadmap_language': roadmapLanguage,
    if (level != null) 'level': level,
    if (nativeLanguage != null) 'native_language': nativeLanguage,
    if (roadmapJson != null) 'roadmap_json': roadmapJson,
  };

  bool get isEmpty =>
      title == null &&
      topic == null &&
      roadmapLanguage == null &&
      level == null &&
      nativeLanguage == null &&
      roadmapJson == null;
}
