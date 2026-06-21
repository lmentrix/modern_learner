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

final class EvaluateRequirements extends SkillTreeEvent {
  const EvaluateRequirements(this.xp, this.level, this.lessons, this.hours,
      this.notes, this.files, this.streak);
  final int xp;
  final int level;
  final int lessons;
  final int hours;
  final int notes;
  final int files;
  final int streak;
}
