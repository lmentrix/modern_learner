import 'package:flutter/material.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';

class HomeCourseListSkeleton extends StatefulWidget {
  const HomeCourseListSkeleton({super.key, this.itemCount = 2});

  final int itemCount;

  @override
  State<HomeCourseListSkeleton> createState() => _HomeCourseListSkeletonState();
}

class _HomeCourseListSkeletonState extends State<HomeCourseListSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _shimmer = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedBuilder(
        animation: _shimmer,
        builder: (context, _) {
          final shimmerColor =
              Color.lerp(
                AppColors.surfaceContainerLow,
                AppColors.surfaceContainerHighest,
                _shimmer.value,
              ) ??
              AppColors.surfaceContainerLow;
          final highlightColor =
              Color.lerp(
                AppColors.surfaceContainer,
                AppColors.surfaceBright,
                _shimmer.value,
              ) ??
              AppColors.surfaceContainer;

          return Column(
            children: List.generate(
              widget.itemCount,
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _SkeletonCard(
                  baseColor: shimmerColor,
                  highlightColor: highlightColor,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.baseColor, required this.highlightColor});

  final Color baseColor;
  final Color highlightColor;

  Widget _box({double? width, double? height, double radius = 8}) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: baseColor,
      borderRadius: BorderRadius.circular(radius),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          // Emoji icon placeholder
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: highlightColor,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row
                Row(
                  children: [
                    Expanded(child: _box(height: 14, radius: 6)),
                    const SizedBox(width: 40),
                    _box(width: 48, height: 20, radius: 10),
                  ],
                ),
                const SizedBox(height: 8),
                // Subtitle
                _box(width: 120, height: 11, radius: 5),
                const SizedBox(height: 14),
                // Progress bar
                _box(height: 5, radius: 100),
                const SizedBox(height: 5),
                Align(
                  alignment: Alignment.centerRight,
                  child: _box(width: 32, height: 11, radius: 5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _box(width: 14, height: 14, radius: 4),
        ],
      ),
    );
  }
}
