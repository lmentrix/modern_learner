import '../../domain/entities/skill_node.dart';

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

  factory SkillNodeModel.fromJson(Map<String, dynamic> json) {
    return SkillNodeModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      emoji: json['emoji'] as String,
      type: json['type'] as String,
      status: json['status'] as String,
      positionX: json['positionX'] as int,
      positionY: json['positionY'] as int,
      prerequisites: (json['prerequisites'] as List<dynamic>?)?.cast<String>() ?? [],
      xpReward: json['xpReward'] as int,
      durationSeconds: json['durationSeconds'] as int?,
      rewards: (json['rewards'] as List<dynamic>?)
              ?.map((r) => SkillNodeRewardModel.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'emoji': emoji,
      'type': type,
      'status': status,
      'positionX': positionX,
      'positionY': positionY,
      'prerequisites': prerequisites,
      'xpReward': xpReward,
      'durationSeconds': durationSeconds,
      'rewards': rewards.map((r) => r.toJson()).toList(),
    };
  }

  SkillNode toEntity() {
    return SkillNode(
      id: id,
      title: title,
      description: description,
      emoji: emoji,
      type: SkillNodeType.values.firstWhere((t) => t.name == type),
      status: SkillNodeStatus.values.firstWhere((s) => s.name == status),
      positionX: positionX,
      positionY: positionY,
      prerequisites: prerequisites,
      xpReward: xpReward,
      duration: durationSeconds != null ? Duration(seconds: durationSeconds!) : null,
      rewards: rewards.map((r) => r.toEntity()).toList(),
    );
  }

  static SkillNodeModel fromEntity(SkillNode node) {
    return SkillNodeModel(
      id: node.id,
      title: node.title,
      description: node.description,
      emoji: node.emoji,
      type: node.type.name,
      status: node.status.name,
      positionX: node.positionX,
      positionY: node.positionY,
      prerequisites: node.prerequisites,
      xpReward: node.xpReward,
      durationSeconds: node.duration?.inSeconds,
      rewards: node.rewards.map((r) => SkillNodeRewardModel.fromEntity(r)).toList(),
    );
  }
}

class SkillNodeRewardModel {
  final String name;
  final String icon;
  final int quantity;

  SkillNodeRewardModel({
    required this.name,
    required this.icon,
    required this.quantity,
  });

  factory SkillNodeRewardModel.fromJson(Map<String, dynamic> json) {
    return SkillNodeRewardModel(
      name: json['name'] as String,
      icon: json['icon'] as String,
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'icon': icon,
      'quantity': quantity,
    };
  }

  SkillNodeReward toEntity() {
    return SkillNodeReward(
      name: name,
      icon: icon,
      quantity: quantity,
    );
  }

  static SkillNodeRewardModel fromEntity(SkillNodeReward reward) {
    return SkillNodeRewardModel(
      name: reward.name,
      icon: reward.icon,
      quantity: reward.quantity,
    );
  }
}
