import 'package:modern_learner_production/progress/model/progress_models.dart';

final class XpAchievementCalculator {
  const XpAchievementCalculator();

  XpAchievementResult calculate({
    required int xp,
    required List<SkillNode> skillNodes,
    required List<Achievement> achievements,
    Set<String> previouslyUnlockedSkillIds = const {},
    Set<String> previouslyUnlockedAchievementIds = const {},
  }) {
    final safeXp = xp < 0 ? 0 : xp;
    final evaluatedNodes = _evaluateSkillNodes(safeXp, skillNodes);
    final evaluatedAchievements = achievements
        .map(
          (achievement) => _copyAchievement(
            achievement,
            unlocked: safeXp >= achievement.requiredXp,
          ),
        )
        .toList(growable: false);

    final unlockedSkillIds = evaluatedNodes
        .where((node) => node.state == NodeState.unlocked)
        .map((node) => node.id)
        .toSet();
    final unlockedAchievementIds = evaluatedAchievements
        .where((achievement) => achievement.unlocked)
        .map((achievement) => achievement.id)
        .toSet();

    final milestones = <XpMilestone>[
      for (final node in evaluatedNodes)
        if (node.state != NodeState.unlocked)
          XpMilestone(
            id: node.id,
            title: node.title,
            requiredXp: node.requiredXp,
            type: XpMilestoneType.skill,
          ),
      for (final achievement in evaluatedAchievements)
        if (!achievement.unlocked)
          XpMilestone(
            id: achievement.id,
            title: achievement.title,
            requiredXp: achievement.requiredXp,
            type: XpMilestoneType.achievement,
          ),
    ]..sort((a, b) => a.requiredXp.compareTo(b.requiredXp));

    return XpAchievementResult(
      xp: safeXp,
      skillNodes: evaluatedNodes,
      achievements: evaluatedAchievements,
      newlyUnlockedSkillIds: unlockedSkillIds
          .difference(previouslyUnlockedSkillIds)
          .toList(growable: false),
      newlyUnlockedAchievementIds: unlockedAchievementIds
          .difference(previouslyUnlockedAchievementIds)
          .toList(growable: false),
      nextMilestone: milestones.firstOrNull,
    );
  }

  List<SkillNode> _evaluateSkillNodes(int xp, List<SkillNode> source) {
    final nodes = source
        .map((node) => _copySkillNode(node, state: NodeState.locked))
        .toList(growable: false);
    final unlockedIds = <String>{};

    var changed = true;
    while (changed) {
      changed = false;
      for (var index = 0; index < nodes.length; index++) {
        final node = nodes[index];
        if (unlockedIds.contains(node.id)) continue;

        final xpMet = xp >= node.requiredXp;
        final prerequisitesMet = node.prerequisiteIds.every(
          unlockedIds.contains,
        );
        if (xpMet && prerequisitesMet) {
          nodes[index] = _copySkillNode(node, state: NodeState.unlocked);
          unlockedIds.add(node.id);
          changed = true;
        }
      }
    }

    for (var index = 0; index < nodes.length; index++) {
      final node = nodes[index];
      if (node.state == NodeState.unlocked) continue;

      final prerequisitesMet = node.prerequisiteIds.every(unlockedIds.contains);
      if (prerequisitesMet) {
        nodes[index] = _copySkillNode(node, state: NodeState.available);
      }
    }

    return nodes;
  }

  SkillNode _copySkillNode(SkillNode node, {required NodeState state}) {
    return SkillNode(
      id: node.id,
      title: node.title,
      description: node.description,
      icon: node.icon,
      tier: node.tier,
      state: state,
      xpReward: node.xpReward,
      prerequisiteIds: node.prerequisiteIds,
      requiredXp: node.requiredXp,
      requiredLevel: node.requiredLevel,
      requiredLessons: node.requiredLessons,
      requiredHours: node.requiredHours,
      requiredNotes: node.requiredNotes,
      requiredFiles: node.requiredFiles,
      requiredStreak: node.requiredStreak,
    );
  }

  Achievement _copyAchievement(
    Achievement achievement, {
    required bool unlocked,
  }) {
    return Achievement(
      id: achievement.id,
      title: achievement.title,
      description: achievement.description,
      icon: achievement.icon,
      unlocked: unlocked,
      unlockedDate: unlocked ? 'XP milestone' : '',
      rarityColor: achievement.rarityColor,
      requiredXp: achievement.requiredXp,
    );
  }
}

enum XpMilestoneType { skill, achievement }

final class XpMilestone {
  const XpMilestone({
    required this.id,
    required this.title,
    required this.requiredXp,
    required this.type,
  });

  final String id;
  final String title;
  final int requiredXp;
  final XpMilestoneType type;
}

final class XpAchievementResult {
  const XpAchievementResult({
    required this.xp,
    required this.skillNodes,
    required this.achievements,
    required this.newlyUnlockedSkillIds,
    required this.newlyUnlockedAchievementIds,
    required this.nextMilestone,
  });

  final int xp;
  final List<SkillNode> skillNodes;
  final List<Achievement> achievements;
  final List<String> newlyUnlockedSkillIds;
  final List<String> newlyUnlockedAchievementIds;
  final XpMilestone? nextMilestone;
}
