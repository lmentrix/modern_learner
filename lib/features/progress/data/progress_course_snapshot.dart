import 'package:flutter/material.dart';

class ProgressCourseSnapshot {
  const ProgressCourseSnapshot({
    required this.completion,
    required this.streakDays,
    required this.weeklyMinutes,
    required this.weeklyGoalMinutes,
    required this.totalHours,
    required this.masteredLessons,
    required this.totalLessons,
    required this.currentFocus,
    required this.momentumLabel,
    required this.accentColor,
  });

  final double completion;
  final int streakDays;
  final int weeklyMinutes;
  final int weeklyGoalMinutes;
  final int totalHours;
  final int masteredLessons;
  final int totalLessons;
  final String currentFocus;
  final String momentumLabel;
  final Color accentColor;
}
