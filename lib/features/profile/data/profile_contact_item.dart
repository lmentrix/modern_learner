import 'package:flutter/material.dart';

class ProfileContactItem {
  const ProfileContactItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
}
