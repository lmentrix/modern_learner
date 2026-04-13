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
}
