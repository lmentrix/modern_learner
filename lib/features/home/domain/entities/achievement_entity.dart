import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class AchievementEntity extends Equatable {
  const AchievementEntity({
    required this.id,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.color,
    this.isLocked = false,
  });

  final String id;
  final String emoji;
  final String title;
  final String subtitle;
  final String description;
  final Color color;
  final bool isLocked;

  @override
  List<Object?> get props => [id, emoji, title, subtitle, description, color, isLocked];
}
