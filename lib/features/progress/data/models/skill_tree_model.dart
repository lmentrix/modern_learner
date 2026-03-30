import '../../domain/entities/skill_tree.dart';
import 'skill_node_model.dart';

class SkillTreeModel {
  final String id;
  final String name;
  final String description;
  final List<SkillNodeModel> nodes;
  final List<SkillPathModel> paths;

  SkillTreeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.nodes,
    required this.paths,
  });

  factory SkillTreeModel.fromJson(Map<String, dynamic> json) {
    return SkillTreeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      nodes: (json['nodes'] as List<dynamic>)
          .map((n) => SkillNodeModel.fromJson(n as Map<String, dynamic>))
          .toList(),
      paths: (json['paths'] as List<dynamic>)
          .map((p) => SkillPathModel.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'nodes': nodes.map((n) => n.toJson()).toList(),
      'paths': paths.map((p) => p.toJson()).toList(),
    };
  }

  SkillTree toEntity() {
    return SkillTree(
      id: id,
      name: name,
      description: description,
      nodes: nodes.map((n) => n.toEntity()).toList(),
      paths: paths.map((p) => p.toEntity()).toList(),
    );
  }

  static SkillTreeModel fromEntity(SkillTree tree) {
    return SkillTreeModel(
      id: tree.id,
      name: tree.name,
      description: tree.description,
      nodes: tree.nodes.map((n) => SkillNodeModel.fromEntity(n)).toList(),
      paths: tree.paths.map((p) => SkillPathModel.fromEntity(p)).toList(),
    );
  }
}

class SkillPathModel {
  final String fromNodeId;
  final String toNodeId;
  final bool isUnlocked;

  SkillPathModel({
    required this.fromNodeId,
    required this.toNodeId,
    required this.isUnlocked,
  });

  factory SkillPathModel.fromJson(Map<String, dynamic> json) {
    return SkillPathModel(
      fromNodeId: json['fromNodeId'] as String,
      toNodeId: json['toNodeId'] as String,
      isUnlocked: json['isUnlocked'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fromNodeId': fromNodeId,
      'toNodeId': toNodeId,
      'isUnlocked': isUnlocked,
    };
  }

  SkillPath toEntity() {
    return SkillPath(
      fromNodeId: fromNodeId,
      toNodeId: toNodeId,
      isUnlocked: isUnlocked,
    );
  }

  static SkillPathModel fromEntity(SkillPath path) {
    return SkillPathModel(
      fromNodeId: path.fromNodeId,
      toNodeId: path.toNodeId,
      isUnlocked: path.isUnlocked,
    );
  }
}
