import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:modern_learner_production/progress/data/progress_data.dart';
import 'package:modern_learner_production/progress/model/progress_models.dart';

part 'skill_tree_event.dart';
part 'skill_tree_state.dart';

class SkillTreeBloc extends Bloc<SkillTreeEvent, SkillTreeState> {
  SkillTreeBloc() : super(const SkillTreeInitial()) {
    on<FetchSkillTree>(_onFetch);
    on<RefreshSkillTree>(_onRefresh);
    on<UnlockSkill>(_onUnlock);
    on<StartSkill>(_onStart);
    on<ToggleSkillLock>(_onToggle);
  }

  void _onFetch(FetchSkillTree event, Emitter<SkillTreeState> emit) async {
    emit(const SkillTreeLoading());
    try {
      final nodes = _loadSkillTree();
      final totalNodes = nodes.length;
      final unlockedCount = nodes
          .where((n) => n.state == NodeState.unlocked)
          .length;
      final tiers = nodes.map((n) => n.tier).toSet().length;

      emit(
        SkillTreeLoaded(
          nodes: nodes,
          totalNodes: totalNodes,
          unlockedCount: unlockedCount,
          totalTiers: tiers,
        ),
      );
    } catch (e) {
      emit(SkillTreeError(e.toString()));
    }
  }

  void _onRefresh(RefreshSkillTree event, Emitter<SkillTreeState> emit) async {
    emit(const SkillTreeLoading());
    try {
      final nodes = _loadSkillTree();
      final totalNodes = nodes.length;
      final unlockedCount = nodes
          .where((n) => n.state == NodeState.unlocked)
          .length;
      final tiers = nodes.map((n) => n.tier).toSet().length;

      emit(
        SkillTreeLoaded(
          nodes: nodes,
          totalNodes: totalNodes,
          unlockedCount: unlockedCount,
          totalTiers: tiers,
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
        return SkillNode(
          id: node.id,
          title: node.title,
          description: node.description,
          icon: node.icon,
          tier: node.tier,
          state: NodeState.unlocked,
          xpReward: node.xpReward,
          prerequisiteIds: node.prerequisiteIds,
        );
      }
      return node;
    }).toList();

    _propagateAvailability(updated);

    emit(
      SkillTreeLoaded(
        nodes: updated,
        totalNodes: current.totalNodes,
        unlockedCount: updated
            .where((n) => n.state == NodeState.unlocked)
            .length,
        totalTiers: current.totalTiers,
        newlyUnlockedId: event.nodeId,
      ),
    );
  }

  void _onStart(StartSkill event, Emitter<SkillTreeState> emit) {
    if (state is! SkillTreeLoaded) return;
    final current = state as SkillTreeLoaded;

    final updated = current.nodes.map((node) {
      if (node.id == event.nodeId) {
        return SkillNode(
          id: node.id,
          title: node.title,
          description: node.description,
          icon: node.icon,
          tier: node.tier,
          state: NodeState.inProgress,
          xpReward: node.xpReward,
          prerequisiteIds: node.prerequisiteIds,
        );
      }
      return node;
    }).toList();

    emit(
      SkillTreeLoaded(
        nodes: updated,
        totalNodes: current.totalNodes,
        unlockedCount: updated
            .where((n) => n.state == NodeState.unlocked)
            .length,
        totalTiers: current.totalTiers,
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
        return SkillNode(
          id: node.id,
          title: node.title,
          description: node.description,
          icon: node.icon,
          tier: node.tier,
          state: allPrereqsMet ? NodeState.unlocked : NodeState.available,
          xpReward: node.xpReward,
          prerequisiteIds: node.prerequisiteIds,
        );
      } else {
        return SkillNode(
          id: node.id,
          title: node.title,
          description: node.description,
          icon: node.icon,
          tier: node.tier,
          state: NodeState.locked,
          xpReward: node.xpReward,
          prerequisiteIds: node.prerequisiteIds,
        );
      }
    }).toList();

    _propagateAvailability(updated);
    _propagateLocks(updated);

    emit(
      SkillTreeLoaded(
        nodes: updated,
        totalNodes: current.totalNodes,
        unlockedCount: updated
            .where((n) => n.state == NodeState.unlocked)
            .length,
        totalTiers: current.totalTiers,
        newlyUnlockedId: isCurrentlyLocked ? event.nodeId : null,
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
        nodes[i] = SkillNode(
          id: node.id,
          title: node.title,
          description: node.description,
          icon: node.icon,
          tier: node.tier,
          state: NodeState.available,
          xpReward: node.xpReward,
          prerequisiteIds: node.prerequisiteIds,
        );
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
        nodes[i] = SkillNode(
          id: node.id,
          title: node.title,
          description: node.description,
          icon: node.icon,
          tier: node.tier,
          state: NodeState.locked,
          xpReward: node.xpReward,
          prerequisiteIds: node.prerequisiteIds,
        );
      }
    }
  }

  List<SkillNode> _loadSkillTree() {
    return skillTree.map((node) {
      return SkillNode(
        id: node.id,
        title: node.title,
        description: node.description,
        icon: node.icon,
        tier: node.tier,
        state: node.state,
        xpReward: node.xpReward,
        prerequisiteIds: node.prerequisiteIds,
      );
    }).toList();
  }
}
