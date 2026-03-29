import '../repositories/progress_repository.dart';

class CompleteNode {
  final ProgressRepository repository;

  CompleteNode(this.repository);

  Future<void> call(String nodeId) => repository.completeNode(nodeId);
}
