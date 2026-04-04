import 'package:modern_learner_production/features/progress/domain/entities/roadmap.dart';
import 'package:modern_learner_production/features/progress/domain/repositories/progress_repository.dart';

class RegenerateRoadmap {
  RegenerateRoadmap(this._repository);
  final ProgressRepository _repository;

  Future<Roadmap> call() => _repository.regenerateRoadmap();
}
