import 'package:modern_learner_production/core/supabase/supabase_service.dart';
import 'package:modern_learner_production/features/explore/data/datasources/learning_subject_local_datasource.dart';
import 'package:modern_learner_production/features/explore/data/models/learning_subject_model.dart';
import 'package:modern_learner_production/features/explore/domain/entities/learning_subject.dart';

class LearningSubjectSupabaseDatasource
    implements LearningSubjectLocalDatasource {
  LearningSubjectSupabaseDatasource({LearningSubjectLocalDatasource? fallback})
    : _fallback = fallback ?? LearningSubjectLocalDatasourceImpl();

  final LearningSubjectLocalDatasource _fallback;

  @override
  Future<List<LearningSubjectModel>> getAllSubjects() async {
    try {
      final rows = await supabase
          .from('learning_subjects')
          .select('*, learning_topics(*)')
          .order('sort_order')
          .order('sort_order', referencedTable: 'learning_topics');
      final subjects = rows
          .map((row) => LearningSubjectModel.fromJson(row))
          .toList(growable: false);
      return subjects.isEmpty ? _fallback.getAllSubjects() : subjects;
    } catch (_) {
      return _fallback.getAllSubjects();
    }
  }

  @override
  Future<List<LearningSubjectModel>> getByCategory(
    SubjectCategory category,
  ) async {
    final subjects = await getAllSubjects();
    return subjects
        .where((subject) => subject.categoryEnum == category)
        .toList();
  }

  @override
  Future<List<LearningSubjectModel>> search(String query) async {
    final q = query.toLowerCase().trim();
    final subjects = await getAllSubjects();
    if (q.isEmpty) return subjects;
    return subjects.where((subject) {
      if (subject.name.toLowerCase().contains(q)) return true;
      if (subject.description.toLowerCase().contains(q)) return true;
      if (subject.category.toLowerCase().contains(q)) return true;
      return subject.topics.any(
        (topic) =>
            topic.name.toLowerCase().contains(q) ||
            topic.description.toLowerCase().contains(q),
      );
    }).toList();
  }
}
