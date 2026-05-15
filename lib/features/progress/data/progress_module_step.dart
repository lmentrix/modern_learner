import 'package:flutter/material.dart';

class ProgressModuleStep {
  const ProgressModuleStep({
    required this.id,
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.detail,
    required this.progress,
    required this.durationLabel,
    required this.lessonCountLabel,
    required this.toneColor,
    required this.isCurrent,
    required this.isLocked,
  });

  final String id;
  final String icon;
  final String eyebrow;
  final String title;
  final String detail;
  final double progress;
  final String durationLabel;
  final String lessonCountLabel;
  final Color toneColor;
  final bool isCurrent;
  final bool isLocked;
}
