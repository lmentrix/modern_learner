import 'package:modern_learner_production/features/progress/domain/entities/progress_course_selection.dart';
import 'package:modern_learner_production/features/progress/domain/entities/roadmap.dart';
import 'package:modern_learner_production/features/progress/domain/repositories/progress_repository.dart';

class GetRoadmap {
  GetRoadmap(this.repository);
  final ProgressRepository repository;

  Future<Roadmap> call({ProgressCourseSelection? courseSelection}) =>
      repository.getRoadmap(courseSelection: courseSelection);
}
