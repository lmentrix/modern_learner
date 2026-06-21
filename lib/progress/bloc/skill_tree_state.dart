part of 'skill_tree_bloc.dart';

@immutable
sealed class SkillTreeState {
  const SkillTreeState();
}

final class SkillTreeInitial extends SkillTreeState {
  const SkillTreeInitial();
}

final class SkillTreeLoading extends SkillTreeState {
  const SkillTreeLoading();
}

final class SkillTreeLoaded extends SkillTreeState {
  const SkillTreeLoaded({
    required this.nodes,
    required this.totalNodes,
    required this.unlockedCount,
    required this.totalTiers,
    this.newlyUnlockedId,
  });

  final List<SkillNode> nodes;
  final int totalNodes;
  final int unlockedCount;
  final int totalTiers;
  final String? newlyUnlockedId;

  List<SkillNode> get beginnerNodes =>
      nodes.where((n) => n.tier == SkillTier.beginner).toList();

  List<SkillNode> get intermediateNodes =>
      nodes.where((n) => n.tier == SkillTier.intermediate).toList();

  List<SkillNode> get advancedNodes =>
      nodes.where((n) => n.tier == SkillTier.advanced).toList();

  List<SkillNode> get masterNodes =>
      nodes.where((n) => n.tier == SkillTier.master).toList();

  bool get areAllPrerequisitesMet {
    for (final node in nodes) {
      if (node.state == NodeState.locked) continue;
      for (final prereqId in node.prerequisiteIds) {
        final prereq = nodes.firstWhere((n) => n.id == prereqId);
        if (prereq.state != NodeState.unlocked) return false;
      }
    }
    return true;
  }

  Set<String> get unlockedNodeIds =>
      nodes.where((n) => n.state == NodeState.unlocked).map((n) => n.id).toSet();
}

final class SkillTreeError extends SkillTreeState {
  const SkillTreeError(this.message);
  final String message;
}
