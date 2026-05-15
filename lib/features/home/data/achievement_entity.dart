import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class AchievementEntity extends Equatable {
  const AchievementEntity({
    required this.id,
    required this.emoji,
    required this.title,
    required this.description,
    required this.color,
    required this.category,
    required this.levelThresholds,
    required this.levelRequirements,
    this.currentLevel = 0,
    this.currentProgress = 0,
  });

  final String id;
  final String emoji;
  final String title;
  final String description;
  final Color color;
  final String category;
  final List<int> levelThresholds;
  final List<String> levelRequirements;
  final int currentLevel;
  final int currentProgress;

  bool get isLocked => currentLevel == 0;

  bool get isMaxLevel => currentLevel >= 5;

  String get subtitle =>
      levelRequirements[currentLevel > 0 ? currentLevel - 1 : 0];

  double get progressToNextLevel {
    if (currentLevel >= 5) return 1.0;
    final previousThreshold = currentLevel > 0
        ? levelThresholds[currentLevel - 1]
        : 0;
    final nextThreshold = levelThresholds[currentLevel];
    if (nextThreshold <= previousThreshold) return 1.0;
    return ((currentProgress - previousThreshold) /
            (nextThreshold - previousThreshold))
        .clamp(0.0, 1.0);
  }

  static const _levelNames = [
    '',
    'Bronze',
    'Silver',
    'Gold',
    'Platinum',
    'Diamond',
  ];

  static const _levelRomans = ['', 'I', 'II', 'III', 'IV', 'V'];

  static const _levelColors = [
    Colors.transparent,
    Color(0xFFCD7F32),
    Color(0xFFB0BEC5),
    Color(0xFFFFD700),
    Color(0xFF90CAF9),
    Color(0xFF00B4D8),
  ];

  static String tierName(int level) => _levelNames[level.clamp(0, 5)];

  static String tierRoman(int level) => _levelRomans[level.clamp(0, 5)];

  static Color tierColor(int level) => _levelColors[level.clamp(0, 5)];

  String get currentLevelName => tierName(currentLevel);

  String get currentLevelRoman => tierRoman(currentLevel);

  Color get currentLevelColor =>
      currentLevel > 0 ? tierColor(currentLevel) : color.withValues(alpha: 0.5);

  AchievementEntity copyWith({int? currentLevel, int? currentProgress}) {
    return AchievementEntity(
      id: id,
      emoji: emoji,
      title: title,
      description: description,
      color: color,
      category: category,
      levelThresholds: levelThresholds,
      levelRequirements: levelRequirements,
      currentLevel: currentLevel ?? this.currentLevel,
      currentProgress: currentProgress ?? this.currentProgress,
    );
  }

  @override
  List<Object?> get props => [
    id,
    emoji,
    title,
    description,
    color,
    category,
    levelThresholds,
    levelRequirements,
    currentLevel,
    currentProgress,
  ];
}
