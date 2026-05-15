import 'package:flutter/material.dart';

class ProgressStatItem {
  const ProgressStatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.detail,
    required this.toneColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final String detail;
  final Color toneColor;
}
