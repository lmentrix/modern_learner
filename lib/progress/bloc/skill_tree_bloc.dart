import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:modern_learner_production/progress/data/progress_data.dart';
import 'package:modern_learner_production/progress/model/progress_models.dart';
import 'package:modern_learner_production/progress/repo/xp_achievement_calculator.dart';

part 'skill_tree_event.dart';
part 'skill_tree_state.dart';

class SkillTreeBloc extends Bloc<SkillTreeEvent, SkillTreeState> {
  SkillTreeBloc({
    XpAchievementCalculator calculator = const XpAchievementCalculator(),
  }) : _calculator = calculator,
       super(const SkillTreeInitial()) {
    on<FetchSkillTree>(_onFetch);
    on<RefreshSkillTree>(_onRefresh);
    on<UnlockSkill>(_onUnlock);
    on<StartSkill>(_onStart);
    on<ToggleSkillLock>(_onToggle);
    on<EvaluateXpProgress>(_onEvaluateXpProgress);
  }

  final XpAchievementCalculator _calculator;

  void _onFetch(FetchSkillTree event, Emitter<SkillTreeState> emit) async {
    emit(const SkillTreeLoading());
    try {
      final nodes = _loadSkillTree();
      final result = _calculator.calculate(
        xp: 0,
        skillNodes: nodes,
        achievements: achievements,
      );

      emit(
        SkillTreeLoaded(
          nodes: result.skillNodes,
          achievements: result.achievements,
          totalNodes: nodes.length,
          unlockedCount: 0,
          totalTiers: nodes.map((n) => n.tier).toSet().length,
          currentXp: result.xp,
          nextMilestone: result.nextMilestone,
        ),
      );
    } catch (e) {
      emit(SkillTreeError(e.toString()));
    }
  }

  void _onRefresh(RefreshSkillTree event, Emitter<SkillTreeState> emit) async {
    final xp = switch (state) {
      SkillTreeLoaded loaded => loaded.currentXp,
      _ => 0,
    };
    emit(const SkillTreeLoading());
    try {
      final nodes = _loadSkillTree();
      final result = _calculator.calculate(
        xp: xp,
        skillNodes: nodes,
        achievements: achievements,
      );

      emit(
        SkillTreeLoaded(
          nodes: result.skillNodes,
          achievements: result.achievements,
          totalNodes: nodes.length,
          unlockedCount: 0,
          totalTiers: nodes.map((n) => n.tier).toSet().length,
          currentXp: result.xp,
          nextMilestone: result.nextMilestone,
        ),
      );
    } catch (e) {
      emit(SkillTreeError(e.toString()));
    }
  }

  void _onUnlock(UnlockSkill event, Emitter<SkillTreeState> emit) {
    if (state is! SkillTreeLoaded) return;
    final current = state as SkillTreeLoaded;

    final updated = current.nodes.map((node) {
      if (node.id == event.nodeId) {
        return _copyNode(node, state: NodeState.unlocked);
      }
      return node;
    }).toList();

    _propagateAvailability(updated);

    emit(
      SkillTreeLoaded(
        nodes: updated,
        achievements: current.achievements,
        totalNodes: current.totalNodes,
        unlockedCount: updated
            .where((n) => n.state == NodeState.unlocked)
            .length,
        totalTiers: current.totalTiers,
        currentXp: current.currentXp,
        nextMilestone: current.nextMilestone,
        newlyUnlockedId: event.nodeId,
      ),
    );
  }

  void _onStart(StartSkill event, Emitter<SkillTreeState> emit) {
    if (state is! SkillTreeLoaded) return;
    final current = state as SkillTreeLoaded;

    final updated = current.nodes.map((node) {
      if (node.id == event.nodeId) {
        return _copyNode(node, state: NodeState.inProgress);
      }
      return node;
    }).toList();

    emit(
      SkillTreeLoaded(
        nodes: updated,
        achievements: current.achievements,
        totalNodes: current.totalNodes,
        unlockedCount: updated
            .where((n) => n.state == NodeState.unlocked)
            .length,
        totalTiers: current.totalTiers,
        currentXp: current.currentXp,
        nextMilestone: current.nextMilestone,
      ),
    );
  }

  void _onToggle(ToggleSkillLock event, Emitter<SkillTreeState> emit) {
    if (state is! SkillTreeLoaded) return;
    final current = state as SkillTreeLoaded;

    final targetNode = current.nodes.firstWhere((n) => n.id == event.nodeId);
    final isCurrentlyLocked = targetNode.state == NodeState.locked;

    final updated = current.nodes.map((node) {
      if (node.id != event.nodeId) return node;

      if (isCurrentlyLocked) {
        final allPrereqsMet = node.prerequisiteIds.every(
          (id) => current.unlockedNodeIds.contains(id),
        );
        return _copyNode(
          node,
          state: allPrereqsMet ? NodeState.unlocked : NodeState.available,
        );
      } else {
        return _copyNode(node, state: NodeState.locked);
      }
    }).toList();

    _propagateAvailability(updated);
    _propagateLocks(updated);

    emit(
      SkillTreeLoaded(
        nodes: updated,
        achievements: current.achievements,
        totalNodes: current.totalNodes,
        unlockedCount: updated
            .where((n) => n.state == NodeState.unlocked)
            .length,
        totalTiers: current.totalTiers,
        currentXp: current.currentXp,
        nextMilestone: current.nextMilestone,
        newlyUnlockedId: isCurrentlyLocked ? event.nodeId : null,
      ),
    );
  }

  void _onEvaluateXpProgress(
    EvaluateXpProgress event,
    Emitter<SkillTreeState> emit,
  ) {
    if (state is! SkillTreeLoaded) return;
    final current = state as SkillTreeLoaded;
    final result = _calculator.calculate(
      xp: event.xp,
      skillNodes: _loadSkillTree(),
      achievements: achievements,
      previouslyUnlockedSkillIds: current.unlockedNodeIds,
      previouslyUnlockedAchievementIds: current.unlockedAchievementIds,
    );

    emit(
      SkillTreeLoaded(
        nodes: result.skillNodes,
        achievements: result.achievements,
        totalNodes: current.totalNodes,
        unlockedCount: result.skillNodes
            .where((n) => n.state == NodeState.unlocked)
            .length,
        totalTiers: current.totalTiers,
        currentXp: result.xp,
        nextMilestone: result.nextMilestone,
        newlyUnlockedSkillIds: result.newlyUnlockedSkillIds,
        newlyUnlockedAchievementIds: result.newlyUnlockedAchievementIds,
      ),
    );
  }

  void _propagateAvailability(List<SkillNode> nodes) {
    final unlockedIds = nodes
        .where((n) => n.state == NodeState.unlocked)
        .map((n) => n.id)
        .toSet();

    for (var i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      if (node.state != NodeState.locked) continue;

      final allPrereqsMet = node.prerequisiteIds.every(
        (id) => unlockedIds.contains(id),
      );

      if (allPrereqsMet) {
        nodes[i] = _copyNode(node, state: NodeState.available);
      }
    }
  }

  void _propagateLocks(List<SkillNode> nodes) {
    final unlockedIds = nodes
        .where((n) => n.state == NodeState.unlocked)
        .map((n) => n.id)
        .toSet();

    for (var i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      if (node.state == NodeState.locked) continue;
      if (node.prerequisiteIds.isEmpty) continue;

      final anyPrereqLocked = node.prerequisiteIds.any(
        (id) => !unlockedIds.contains(id),
      );

      if (anyPrereqLocked) {
        nodes[i] = _copyNode(node, state: NodeState.locked);
      }
    }
  }

  List<SkillNode> _loadSkillTree() {
    return skillTree.map((node) => _copyNode(node)).toList();
  }

  SkillNode _copyNode(SkillNode node, {NodeState? state}) {
    return SkillNode(
      id: node.id,
      title: node.title,
      description: node.description,
      icon: node.icon,
      tier: node.tier,
      state: state ?? node.state,
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
}
