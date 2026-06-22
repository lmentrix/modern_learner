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
    required this.achievements,
    required this.totalNodes,
    required this.unlockedCount,
    required this.totalTiers,
    required this.currentXp,
    this.nextMilestone,
    this.newlyUnlockedId,
    this.newlyUnlockedSkillIds = const [],
    this.newlyUnlockedAchievementIds = const [],
  });

  final List<SkillNode> nodes;
  final List<Achievement> achievements;
  final int totalNodes;
  final int unlockedCount;
  final int totalTiers;
  final int currentXp;
  final XpMilestone? nextMilestone;
  final String? newlyUnlockedId;
  final List<String> newlyUnlockedSkillIds;
  final List<String> newlyUnlockedAchievementIds;

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

  Set<String> get unlockedNodeIds => nodes
      .where((n) => n.state == NodeState.unlocked)
      .map((n) => n.id)
      .toSet();

  Set<String> get unlockedAchievementIds => achievements
      .where((achievement) => achievement.unlocked)
      .map((achievement) => achievement.id)
      .toSet();
}

final class SkillTreeError extends SkillTreeState {
  const SkillTreeError(this.message);
  final String message;
}
