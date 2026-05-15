import 'package:modern_learner_production/features/explore/domain/entities/learning_subject.dart';

abstract class LearningSubjectsState {
  const LearningSubjectsState();
}

class LearningSubjectsInitial extends LearningSubjectsState {
  const LearningSubjectsInitial();
}

class LearningSubjectsLoading extends LearningSubjectsState {
  const LearningSubjectsLoading();
}

class LearningSubjectsLoaded extends LearningSubjectsState {
  const LearningSubjectsLoaded({
    required this.allSubjects,
    required this.displayed,
    this.activeCategory,
  });

  final List<LearningSubject> allSubjects;
  final List<LearningSubject> displayed;
  final SubjectCategory? activeCategory;
}

class LearningSubjectsError extends LearningSubjectsState {
  const LearningSubjectsError(this.message);

  final String message;
}
