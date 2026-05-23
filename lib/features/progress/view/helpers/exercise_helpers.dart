import 'package:flutter/material.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';

OutlineInputBorder exerciseInputBorder(Color color) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(color: color.withValues(alpha: 0.45)),
  );
}

String questionKey(int groupIndex, int questionNumber) {
  return '$groupIndex:$questionNumber';
}

String matchingKey(int groupIndex, int pairNumber) {
  return 'match:$groupIndex:$pairNumber';
}

bool matchesAnswer(String? input, String expected) {
  final actual = input?.trim().toLowerCase();
  final normalizedExpected = expected.trim().toLowerCase();
  return actual != null &&
      actual.isNotEmpty &&
      (actual == normalizedExpected || actual.contains(normalizedExpected));
}

IconData groupIcon(String type) {
  switch (type) {
    case 'multiple_choice':
      return Icons.checklist_rounded;
    case 'fill_in_the_blank':
      return Icons.edit_note_rounded;
    case 'matching':
      return Icons.hub_rounded;
    default:
      return Icons.quiz_rounded;
  }
}

Color typeColor(String type, Color fallback) {
  switch (type) {
    case 'multiple_choice':
      return AppColors.primary;
    case 'fill_in_the_blank':
      return AppColors.secondary;
    case 'matching':
      return AppColors.tertiary;
    default:
      return fallback;
  }
}

String titleCase(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return 'Untitled';
  return trimmed
      .split('_')
      .expand((part) => part.split(' '))
      .where((part) => part.trim().isNotEmpty)
      .map((part) {
        final normalized = part.trim();
        return '${normalized[0].toUpperCase()}${normalized.substring(1).toLowerCase()}';
      })
      .join(' ');
}
