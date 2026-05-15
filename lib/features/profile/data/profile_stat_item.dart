import 'package:flutter/material.dart';

class ProfileStatItem {
  const ProfileStatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.accentColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accentColor;
}
