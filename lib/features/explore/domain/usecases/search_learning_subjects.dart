import 'package:modern_learner_production/features/explore/domain/entities/learning_subject.dart';
import 'package:modern_learner_production/features/explore/domain/repositories/learning_subject_repository.dart';

class SearchLearningSubjects {
  const SearchLearningSubjects(this._repository);

  final LearningSubjectRepository _repository;

  Future<List<LearningSubject>> call(String query) =>
      _repository.search(query);
}
