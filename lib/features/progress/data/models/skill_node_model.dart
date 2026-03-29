import 'package:json_annotation/json_annotation.dart';

part 'skill_node_model.g.dart';

@JsonSerializable()
class SkillNodeModel {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final String type;
  final String status;
  final int positionX;
  final int positionY;
  final List<String> prerequisites;
  final int xpReward;
  final int? durationSeconds;
  final List<SkillNodeRewardModel> rewards;

  SkillNodeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.type,
    required this.status,
    required this.positionX,
    required this.positionY,
    required this.prerequisites,
    required this.xpReward,
    this.durationSeconds,
    required this.rewards,
  });

  factory SkillNodeModel.fromJson(Map<String, dynamic> json) =>
      _$SkillNodeModelFromJson(json);

  Map<String, dynamic> toJson() => _$SkillNodeModelToJson(json);
}

@JsonSerializable()
class SkillNodeRewardModel {
  final String name;
  final String icon;
  final int quantity;

  SkillNodeRewardModel({
    required this.name,
    required this.icon,
    required this.quantity,
  });

  factory SkillNodeRewardModel.fromJson(Map<String, dynamic> json) =>
      _$SkillNodeRewardModelFromJson(json);

  Map<String, dynamic> toJson() => _$SkillNodeRewardModelToJson(json);
}
