import 'package:equatable/equatable.dart';

import 'skill_node.dart';

class SkillTree extends Equatable {
  final String id;
  final String name;
  final String description;
  final List<SkillNode> nodes;
  final List<SkillPath> paths;

  const SkillTree({
    required this.id,
    required this.name,
    required this.description,
    required this.nodes,
    required this.paths,
  });

  @override
  List<Object?> get props => [id, name, description, nodes, paths];
}

class SkillPath extends Equatable {
  final String fromNodeId;
  final String toNodeId;
  final bool isUnlocked;

  const SkillPath({
    required this.fromNodeId,
    required this.toNodeId,
    required this.isUnlocked,
  });

  @override
  List<Object?> get props => [fromNodeId, toNodeId, isUnlocked];
}
