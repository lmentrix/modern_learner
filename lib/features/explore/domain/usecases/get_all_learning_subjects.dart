import 'package:modern_learner_production/features/explore/domain/entities/learning_subject.dart';
import 'package:modern_learner_production/features/explore/domain/repositories/learning_subject_repository.dart';

class GetAllLearningSubjects {
  const GetAllLearningSubjects(this._repository);

  final LearningSubjectRepository _repository;

  Future<List<LearningSubject>> call() => _repository.getAllSubjects();
}
