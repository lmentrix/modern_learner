import 'package:modern_learner_production/features/explore/domain/entities/learning_subject.dart';

class CreateCourseArgs {
  const CreateCourseArgs({required this.subject, this.topic});

  final LearningSubject subject;
  final LearningTopic? topic;
}
