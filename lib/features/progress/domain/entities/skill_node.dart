import 'package:equatable/equatable.dart';

enum SkillNodeStatus {
  locked,
  available,
  inProgress,
  completed,
}

enum SkillNodeType {
  core,
  bonus,
  challenge,
  boss,
}

class SkillNode extends Equatable {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final SkillNodeType type;
  final SkillNodeStatus status;
  final int positionX; // Percentage 0-100
  final int positionY; // Percentage 0-100 (from bottom)
  final List<String> prerequisites; // Node IDs that must be completed
  final int xpReward;
  final Duration? duration;
  final List<SkillNodeReward> rewards;

  const SkillNode({
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
    this.duration,
    required this.rewards,
  });

  SkillNode copyWith({
    SkillNodeStatus? status,
    List<SkillNodeReward>? rewards,
  }) {
    return SkillNode(
      id: id,
      title: title,
      description: description,
      emoji: emoji,
      type: type,
      status: status ?? this.status,
      positionX: positionX,
      positionY: positionY,
      prerequisites: prerequisites,
      xpReward: xpReward,
      duration: duration,
      rewards: rewards ?? this.rewards,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        emoji,
        type,
        status,
        positionX,
        positionY,
        prerequisites,
        xpReward,
        duration,
        rewards,
      ];
}

class SkillNodeReward extends Equatable {
  final String name;
  final String icon;
  final int quantity;

  const SkillNodeReward({
    required this.name,
    required this.icon,
    required this.quantity,
  });

  @override
  List<Object?> get props => [name, icon, quantity];
}
