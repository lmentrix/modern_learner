import 'package:modern_learner_production/features/explore/domain/entities/learning_subject.dart';
import 'package:modern_learner_production/features/explore/domain/repositories/learning_subject_repository.dart';

class GetSubjectsByCategory {
  const GetSubjectsByCategory(this._repository);

  final LearningSubjectRepository _repository;

  Future<List<LearningSubject>> call(SubjectCategory category) =>
      _repository.getByCategory(category);
}
