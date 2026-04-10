import 'package:modern_learner_production/features/progress/domain/entities/progress_course_selection.dart';
import 'package:modern_learner_production/features/progress/domain/entities/roadmap.dart';
import 'package:modern_learner_production/features/progress/domain/repositories/progress_repository.dart';

class RegenerateRoadmap {
  RegenerateRoadmap(this._repository);
  final ProgressRepository _repository;

  Future<Roadmap> call({ProgressCourseSelection? courseSelection}) =>
      _repository.regenerateRoadmap(courseSelection: courseSelection);
}
