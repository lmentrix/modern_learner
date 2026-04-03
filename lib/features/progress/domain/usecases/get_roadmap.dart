import 'package:modern_learner_production/features/progress/domain/entities/roadmap.dart';
import 'package:modern_learner_production/features/progress/domain/repositories/progress_repository.dart';

class GetRoadmap {

  GetRoadmap(this.repository);
  final ProgressRepository repository;

  Future<Roadmap> call() => repository.getRoadmap();
}
