import 'package:equatable/equatable.dart';

enum AchievementType { streak, xp, level, lesson, chapter, gems }

enum AchievementRarity { common, rare, epic, legendary }

enum AchievementScope { account, course }

class Achievement extends Equatable {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.type,
    required this.rarity,
    required this.requirement,
    required this.xpReward,
    this.unlockedAt,
    this.unlockedByCourses = const [],
  });

  final String id;
  final String title;
  final String description;
  final String emoji;
  final AchievementType type;
  final AchievementRarity rarity;
  final int requirement;
  final int xpReward;
  final DateTime? unlockedAt;
  final List<String> unlockedByCourses;

  bool get isUnlocked => unlockedByCourses.isNotEmpty || unlockedAt != null;

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? emoji,
    AchievementType? type,
    AchievementRarity? rarity,
    int? requirement,
    int? xpReward,
    DateTime? unlockedAt,
    List<String>? unlockedByCourses,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      type: type ?? this.type,
      rarity: rarity ?? this.rarity,
      requirement: requirement ?? this.requirement,
      xpReward: xpReward ?? this.xpReward,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      unlockedByCourses: unlockedByCourses ?? this.unlockedByCourses,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    emoji,
    type,
    rarity,
    requirement,
    xpReward,
    unlockedAt,
    unlockedByCourses,
  ];
}

class AchievementDefinitionModel {
  const AchievementDefinitionModel({
    required this.key,
    required this.title,
    required this.description,
    required this.emoji,
    required this.type,
    required this.rarity,
    required this.scope,
    required this.requirementValue,
    required this.xpReward,
    this.sortOrder = 0,
    this.isActive = true,
    this.metadata = const {},
    this.createdAt,
    this.updatedAt,
  });

  factory AchievementDefinitionModel.fromJson(Map<String, dynamic> json) {
    return AchievementDefinitionModel(
      key: json['key'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      emoji: json['emoji'] as String? ?? '',
      type: _enumFromName(AchievementType.values, json['type']),
      rarity: _enumFromName(AchievementRarity.values, json['rarity']),
      scope: _enumFromName(AchievementScope.values, json['scope']),
      requirementValue: _intFromJson(json['requirement_value']),
      xpReward: _intFromJson(json['xp_reward']),
      sortOrder: _intFromJson(json['sort_order']),
      isActive: json['is_active'] as bool? ?? true,
      metadata: _mapFromJson(json['metadata']),
      createdAt: _dateTimeFromJson(json['created_at']),
      updatedAt: _dateTimeFromJson(json['updated_at']),
    );
  }

  factory AchievementDefinitionModel.fromAchievement({
    required Achievement achievement,
    AchievementScope? scope,
    int sortOrder = 0,
  }) {
    return AchievementDefinitionModel(
      key: achievement.id,
      title: achievement.title,
      description: achievement.description,
      emoji: achievement.emoji,
      type: achievement.type,
      rarity: achievement.rarity,
      scope: scope ?? _scopeForType(achievement.type),
      requirementValue: achievement.requirement,
      xpReward: achievement.xpReward,
      sortOrder: sortOrder,
      metadata: {
        if (achievement.unlockedAt != null)
          'unlocked_at': achievement.unlockedAt!.toUtc().toIso8601String(),
      },
    );
  }

  final String key;
  final String title;
  final String description;
  final String emoji;
  final AchievementType type;
  final AchievementRarity rarity;
  final AchievementScope scope;
  final int requirementValue;
  final int xpReward;
  final int sortOrder;
  final bool isActive;
  final Map<String, dynamic> metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Achievement toAchievement({
    DateTime? unlockedAt,
    List<String> unlockedByCourses = const [],
  }) {
    return Achievement(
      id: key,
      title: title,
      description: description,
      emoji: emoji,
      type: type,
      rarity: rarity,
      requirement: requirementValue,
      xpReward: xpReward,
      unlockedAt: unlockedAt,
      unlockedByCourses: unlockedByCourses,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'title': title,
      'description': description,
      'emoji': emoji,
      'type': type.name,
      'rarity': rarity.name,
      'scope': scope.name,
      'requirement_value': requirementValue,
      'xp_reward': xpReward,
      'sort_order': sortOrder,
      'is_active': isActive,
      'metadata': metadata,
    };
  }
}

class UserAchievementProgressModel {
  const UserAchievementProgressModel({
    this.id,
    required this.userId,
    required this.achievementKey,
    this.courseKey = 'global',
    this.progressValue = 0,
    this.unlockedAt,
    this.seenAt,
    this.metadata = const {},
    this.createdAt,
    this.updatedAt,
  });

  factory UserAchievementProgressModel.fromJson(Map<String, dynamic> json) {
    return UserAchievementProgressModel(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      achievementKey: json['achievement_key'] as String,
      courseKey: json['course_key'] as String? ?? 'global',
      progressValue: _intFromJson(json['progress_value']),
      unlockedAt: _dateTimeFromJson(json['unlocked_at']),
      seenAt: _dateTimeFromJson(json['seen_at']),
      metadata: _mapFromJson(json['metadata']),
      createdAt: _dateTimeFromJson(json['created_at']),
      updatedAt: _dateTimeFromJson(json['updated_at']),
    );
  }

  final String? id;
  final String userId;
  final String achievementKey;
  final String courseKey;
  final int progressValue;
  final DateTime? unlockedAt;
  final DateTime? seenAt;
  final Map<String, dynamic> metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isUnlocked => unlockedAt != null;

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'achievement_key': achievementKey,
      'course_key': courseKey,
      'progress_value': progressValue,
      'unlocked_at': unlockedAt?.toUtc().toIso8601String(),
      'seen_at': seenAt?.toUtc().toIso8601String(),
      'metadata': metadata,
    };
  }
}

class ProfileCourseXpModel {
  const ProfileCourseXpModel({
    required this.userId,
    required this.courseKey,
    this.courseId,
    this.courseTitle,
    this.courseTopic,
    this.exerciseXp = 0,
    this.exercisesCompleted = 0,
    this.chaptersUnlocked = 1,
    this.metadata = const {},
    this.createdAt,
    this.updatedAt,
  });

  factory ProfileCourseXpModel.fromJson(Map<String, dynamic> json) {
    final courseRow = json['user_courses'];
    final course = courseRow is Map<String, dynamic> ? courseRow : null;
    return ProfileCourseXpModel(
      userId: json['user_id'] as String,
      courseKey: json['course_key'] as String,
      courseId: json['course_id'] as String?,
      courseTitle: course?['title'] as String?,
      courseTopic: course?['topic'] as String?,
      exerciseXp: _intFromJson(json['exercise_xp']),
      exercisesCompleted: _intFromJson(json['exercises_completed']),
      chaptersUnlocked: _intFromJson(json['chapters_unlocked']),
      metadata: _mapFromJson(json['metadata']),
      createdAt: _dateTimeFromJson(json['created_at']),
      updatedAt: _dateTimeFromJson(json['updated_at']),
    );
  }

  final String userId;
  final String courseKey;
  /// UUID FK to `user_courses.id`. Null for rows created before this field existed.
  final String? courseId;
  /// Human-readable title from the joined `user_courses` row.
  final String? courseTitle;
  final String? courseTopic;
  final int exerciseXp;
  final int exercisesCompleted;
  final int chaptersUnlocked;
  final Map<String, dynamic> metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'course_key': courseKey,
      if (courseId != null) 'course_id': courseId,
      'exercise_xp': exerciseXp,
      'exercises_completed': exercisesCompleted,
      'chapters_unlocked': chaptersUnlocked,
      'metadata': metadata,
    };
  }

  ProfileCourseXpModel copyWith({
    String? userId,
    String? courseKey,
    String? courseId,
    String? courseTitle,
    String? courseTopic,
    int? exerciseXp,
    int? exercisesCompleted,
    int? chaptersUnlocked,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfileCourseXpModel(
      userId: userId ?? this.userId,
      courseKey: courseKey ?? this.courseKey,
      courseId: courseId ?? this.courseId,
      courseTitle: courseTitle ?? this.courseTitle,
      courseTopic: courseTopic ?? this.courseTopic,
      exerciseXp: exerciseXp ?? this.exerciseXp,
      exercisesCompleted: exercisesCompleted ?? this.exercisesCompleted,
      chaptersUnlocked: chaptersUnlocked ?? this.chaptersUnlocked,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

AchievementScope _scopeForType(AchievementType type) {
  return switch (type) {
    AchievementType.xp || AchievementType.chapter => AchievementScope.course,
    AchievementType.streak ||
    AchievementType.level ||
    AchievementType.lesson ||
    AchievementType.gems => AchievementScope.account,
  };
}

T _enumFromName<T extends Enum>(List<T> values, dynamic value) {
  return values.firstWhere((item) => item.name == value);
}

int _intFromJson(dynamic value) {
  return (value as num?)?.toInt() ?? 0;
}

Map<String, dynamic> _mapFromJson(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const {};
}

DateTime? _dateTimeFromJson(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.parse(value as String);
}
