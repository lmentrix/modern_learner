import 'package:flutter/material.dart';
import 'package:modern_learner_production/theme/theme.dart';

class BackgroundBlobs extends StatelessWidget {
  const BackgroundBlobs({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top-right large purple orb
        Positioned(
          top: -80,
          right: -80,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  EduColors.primary.withValues(alpha: 0.20),
                  EduColors.primary.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
        // Mid-left accent green
        Positioned(
          top: 260,
          left: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  EduColors.accentGreen.withValues(alpha: 0.22),
                  EduColors.accentGreen.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
        // Bottom-right yellow
        Positioned(
          bottom: 120,
          right: -30,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  EduColors.accentYellow.withValues(alpha: 0.28),
                  EduColors.accentYellow.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
