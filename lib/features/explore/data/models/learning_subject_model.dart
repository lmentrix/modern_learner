import 'package:modern_learner_production/features/explore/domain/entities/learning_subject.dart';

class LearningTopicModel extends LearningTopic {
  const LearningTopicModel({
    required super.id,
    required super.name,
    required super.description,
    required super.emoji,
    required super.difficulty,
    required super.estimatedMinutes,
  });

  factory LearningTopicModel.fromJson(Map<String, dynamic> json) {
    return LearningTopicModel(
      id: _asString(json['id']),
      name: _asString(json['name']),
      description: _asString(json['description']),
      emoji: _asString(json['emoji'], fallback: 'Book'),
      difficulty: _difficultyFromKey(_asString(json['difficulty'])),
      estimatedMinutes: _asInt(json['estimated_minutes'], fallback: 45),
    );
  }
}

class LearningSubjectModel extends LearningSubject {
  const LearningSubjectModel({
    required super.id,
    required super.name,
    required super.category,
    required super.categoryEnum,
    required super.description,
    required super.emoji,
    required super.accentColorValue,
    required super.topics,
    required super.difficulty,
  });

  factory LearningSubjectModel.fromJson(Map<String, dynamic> json) {
    final category = _asString(json['category']);
    final categoryKey = _asString(json['category_key'], fallback: category);
    final rawTopics = json['learning_topics'];
    final topics = rawTopics is List
        ? rawTopics
              .whereType<Map<String, dynamic>>()
              .map(LearningTopicModel.fromJson)
              .toList(growable: false)
        : const <LearningTopicModel>[];

    return LearningSubjectModel(
      id: _asString(json['id']),
      name: _asString(json['name']),
      category: category,
      categoryEnum: _categoryFromKey(categoryKey),
      description: _asString(json['description']),
      emoji: _asString(json['emoji'], fallback: 'Book'),
      accentColorValue: _asInt(
        json['accent_color_value'],
        fallback: 0xFF7C6FCD,
      ),
      topics: topics,
      difficulty: _difficultyFromKey(_asString(json['difficulty'])),
    );
  }
}

String _asString(Object? value, {String fallback = ''}) {
  if (value == null) return fallback;
  final text = value.toString().trim();
  return text.isEmpty ? fallback : text;
}

int _asInt(Object? value, {required int fallback}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

SubjectCategory _categoryFromKey(String key) {
  final normalized = key.toLowerCase().replaceAll(RegExp(r'[\s_-]+'), '');
  return switch (normalized) {
    'stem' => SubjectCategory.stem,
    'humanities' => SubjectCategory.humanities,
    'arts' => SubjectCategory.arts,
    'socialsciences' => SubjectCategory.socialSciences,
    'languages' => SubjectCategory.languages,
    'professional' => SubjectCategory.professional,
    _ => SubjectCategory.stem,
  };
}

DifficultyLevel _difficultyFromKey(String key) {
  final normalized = key.toLowerCase().replaceAll(RegExp(r'[\s_-]+'), '');
  return switch (normalized) {
    'beginner' => DifficultyLevel.beginner,
    'intermediate' => DifficultyLevel.intermediate,
    'advanced' => DifficultyLevel.advanced,
    'alllevels' => DifficultyLevel.allLevels,
    _ => DifficultyLevel.allLevels,
  };
}
