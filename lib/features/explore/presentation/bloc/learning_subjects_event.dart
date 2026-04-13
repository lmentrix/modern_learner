import 'package:modern_learner_production/features/explore/domain/entities/learning_subject.dart';

abstract class LearningSubjectsEvent {
  const LearningSubjectsEvent();
}

class LoadLearningSubjects extends LearningSubjectsEvent {
  const LoadLearningSubjects();
}

class FilterByCategory extends LearningSubjectsEvent {
  const FilterByCategory(this.category);

  /// null means "All"
  final SubjectCategory? category;
}

class SearchSubjectsEvent extends LearningSubjectsEvent {
  const SearchSubjectsEvent(this.query);

  final String query;
}
