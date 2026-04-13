import 'package:modern_learner_production/features/explore/data/datasources/learning_subject_local_datasource.dart';
import 'package:modern_learner_production/features/explore/domain/entities/learning_subject.dart';
import 'package:modern_learner_production/features/explore/domain/repositories/learning_subject_repository.dart';

class LearningSubjectRepositoryImpl implements LearningSubjectRepository {
  const LearningSubjectRepositoryImpl(this._datasource);

  final LearningSubjectLocalDatasource _datasource;

  @override
  Future<List<LearningSubject>> getAllSubjects() =>
      _datasource.getAllSubjects();

  @override
  Future<List<LearningSubject>> getByCategory(SubjectCategory category) =>
      _datasource.getByCategory(category);

  @override
  Future<List<LearningSubject>> search(String query) =>
      _datasource.search(query);
}
