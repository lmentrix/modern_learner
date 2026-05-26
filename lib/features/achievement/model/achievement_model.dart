import 'package:equatable/equatable.dart';

enum AchievementType { streak, xp, level, lesson, chapter, gems }

enum AchievementRarity { common, rare, epic, legendary }

class Achievement extends Equatable {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.type,
    required this.rarity,
    required this.requirement,
    required this.xpReward,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  final String id;
  final String title;
  final String description;
  final String emoji;
  final AchievementType type;
  final AchievementRarity rarity;

  /// The threshold value that must be reached to unlock this achievement.
  final int requirement;
  final int xpReward;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  Achievement copyWith({
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      emoji: emoji,
      type: type,
      rarity: rarity,
      requirement: requirement,
      xpReward: xpReward,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        emoji,
        type,
        rarity,
        requirement,
        xpReward,
        isUnlocked,
        unlockedAt,
      ];
}


