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

  /// Base accent colour used for unlocked display.
  final Color color;
  final String category;

  /// Raw thresholds for levels I–V (ascending).
  final List<int> levelThresholds;

  /// Human-readable requirement for each level ("7-day streak", "500 XP", …).
  final List<String> levelRequirements;

  /// 0 = not yet earned, 1–5 = highest earned level.
  final int currentLevel;

  /// Current raw progress value used to compute fraction toward next level.
  final int currentProgress;

  // ── Convenience getters ───���────────────────────────────────────────────────

  /// Backward-compatible: true when no level has been earned.
  bool get isLocked => currentLevel == 0;

  bool get isMaxLevel => currentLevel >= 5;

  /// Short subtitle shown on cards — the current level requirement,
  /// or the first requirement when nothing is earned yet.
  String get subtitle => levelRequirements[currentLevel > 0 ? currentLevel - 1 : 0];

  /// Progress fraction [0.0, 1.0] toward the next level.
  double get progressToNextLevel {
    if (currentLevel >= 5) return 1.0;
    final prev = currentLevel > 0 ? levelThresholds[currentLevel - 1] : 0;
    final next = levelThresholds[currentLevel];
    if (next <= prev) return 1.0;
    return ((currentProgress - prev) / (next - prev)).clamp(0.0, 1.0);
  }

  // ── Static level metadata ──────────────────────────────────────────────────

  static const _levelNames = [
    '',
    'Bronze',
    'Silver',
    'Gold',
    'Platinum',
    'Diamond',
  ];

  static const _levelRomanals = ['', 'I', 'II', 'III', 'IV', 'V'];

  static const _levelColors = [
    Colors.transparent,
    Color(0xFFCD7F32), // Bronze
    Color(0xFFB0BEC5), // Silver
    Color(0xFFFFD700), // Gold
    Color(0xFF90CAF9), // Platinum
    Color(0xFF00B4D8), // Diamond
  ];

  /// Name of a given tier (1–5).
  static String tierName(int level) =>
      _levelNames[level.clamp(0, 5)];

  /// Roman numeral for a given tier (1–5).
  static String tierRoman(int level) =>
      _levelRomanals[level.clamp(0, 5)];

  /// Accent colour for a given tier.
  static Color tierColor(int level) =>
      _levelColors[level.clamp(0, 5)];

  String get currentLevelName => tierName(currentLevel);
  String get currentLevelRoman => tierRoman(currentLevel);
  Color get currentLevelColor =>
      currentLevel > 0 ? tierColor(currentLevel) : color.withValues(alpha: 0.5);

  // ── copyWith ───────────────────────────────────────────────────────────────

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
