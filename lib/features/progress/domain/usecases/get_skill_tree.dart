import '../entities/skill_tree.dart';
import '../repositories/progress_repository.dart';

class GetSkillTree {
  final ProgressRepository repository;

  GetSkillTree(this.repository);

  Future<SkillTree> call() => repository.getSkillTree();
}
