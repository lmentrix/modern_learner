import 'package:flutter/material.dart';

class ExerciseIconBox extends StatelessWidget {
  const ExerciseIconBox({
    super.key,
    required this.icon,
    required this.color,
    this.showSpinner = false,
  });

  final IconData icon;
  final Color color;
  final bool showSpinner;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: showSpinner
          ? Padding(
              padding: const EdgeInsets.all(11),
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            )
          : Icon(icon, color: color, size: 22),
    );
  }
}
