part of 'skill_tree_bloc.dart';

@immutable
sealed class SkillTreeEvent {
  const SkillTreeEvent();
}

final class FetchSkillTree extends SkillTreeEvent {
  const FetchSkillTree();
}

final class RefreshSkillTree extends SkillTreeEvent {
  const RefreshSkillTree();
}

final class UnlockSkill extends SkillTreeEvent {
  const UnlockSkill(this.nodeId);
  final String nodeId;
}

final class StartSkill extends SkillTreeEvent {
  const StartSkill(this.nodeId);
  final String nodeId;
}

final class ToggleSkillLock extends SkillTreeEvent {
  const ToggleSkillLock(this.nodeId);
  final String nodeId;
}

final class EvaluateXpProgress extends SkillTreeEvent {
  const EvaluateXpProgress(this.xp);

  final int xp;
}
