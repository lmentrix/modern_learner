import '../entities/roadmap.dart';
import '../repositories/progress_repository.dart';

class GetRoadmap {
  final ProgressRepository repository;

  GetRoadmap(this.repository);

  Future<Roadmap> call() => repository.getRoadmap();
}
