import 'package:json_annotation/json_annotation.dart';

part 'user_progress_model.g.dart';

@JsonSerializable()
class UserProgressModel {
  final int totalXp;
  final int level;
  final int gems;
  final int streak;
  final Map<String, String> completedNodes;
  final Map<String, double> nodeProgress;
  final List<String> unlockedAchievements;

  UserProgressModel({
    required this.totalXp,
    required this.level,
    required this.gems,
    required this.streak,
    required this.completedNodes,
    required this.nodeProgress,
    required this.unlockedAchievements,
  });

  factory UserProgressModel.fromJson(Map<String, dynamic> json) =>
      _$UserProgressModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserProgressModelToJson(json);
}
