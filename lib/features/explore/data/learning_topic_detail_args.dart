import 'package:modern_learner_production/features/explore/domain/entities/learning_subject.dart';

class LearningTopicDetailArgs {
  const LearningTopicDetailArgs({required this.subject, required this.topic});

  final LearningSubject subject;
  final LearningTopic topic;
}
