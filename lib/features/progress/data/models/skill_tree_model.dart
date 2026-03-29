import 'package:json_annotation/json_annotation.dart';

part 'skill_tree_model.g.dart';

@JsonSerializable()
class SkillTreeModel {
  final String id;
  final String name;
  final String description;
  final List<Map<String, dynamic>> nodes;
  final List<Map<String, dynamic>> paths;

  SkillTreeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.nodes,
    required this.paths,
  });

  factory SkillTreeModel.fromJson(Map<String, dynamic> json) =>
      _$SkillTreeModelFromJson(json);

  Map<String, dynamic> toJson() => _$SkillTreeModelToJson(json);
}

@JsonSerializable()
class SkillPathModel {
  final String fromNodeId;
  final String toNodeId;
  final bool isUnlocked;

  SkillPathModel({
    required this.fromNodeId,
    required this.toNodeId,
    required this.isUnlocked,
  });

  factory SkillPathModel.fromJson(Map<String, dynamic> json) =>
      _$SkillPathModelFromJson(json);

  Map<String, dynamic> toJson() => _$SkillPathModelToJson(json);
}
