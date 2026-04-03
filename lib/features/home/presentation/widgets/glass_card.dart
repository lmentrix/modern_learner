import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 24,
    this.opacity = 0.60,
    this.blur = 16,
    this.glowTop = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double opacity;
  final double blur;
  final bool glowTop;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: glowTop
                ? Border(
                    top: BorderSide(
                      color: AppColors.outlineVariant.withValues(alpha: 0.20),
                      width: 0.5,
                    ),
                    left: BorderSide(
                      color: AppColors.outlineVariant.withValues(alpha: 0.20),
                      width: 0.5,
                    ),
                  )
                : null,
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
