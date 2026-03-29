import '../entities/skill_tree.dart';
import '../entities/user_progress.dart';

abstract class ProgressRepository {
  Future<SkillTree> getSkillTree();
  Future<UserProgress> getUserProgress();
  Future<void> startNode(String nodeId);
  Future<void> completeNode(String nodeId);
  Future<void> updateNodeProgress(String nodeId, double progress);
  Stream<UserProgress> getProgressStream();
}
