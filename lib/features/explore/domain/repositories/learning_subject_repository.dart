import 'package:modern_learner_production/features/explore/domain/entities/learning_subject.dart';

abstract class LearningSubjectRepository {
  Future<List<LearningSubject>> getAllSubjects();
  Future<List<LearningSubject>> getByCategory(SubjectCategory category);
  Future<List<LearningSubject>> search(String query);
}
