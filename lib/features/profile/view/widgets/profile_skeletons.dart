import 'package:flutter/material.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';

// ── Shared shimmer engine ─────────────────────────────────────────────────────

class _Shimmer extends StatefulWidget {
  const _Shimmer({required this.child});
  final Widget child;

  @override
  State<_Shimmer> createState() => _ShimmerState();

  static _ShimmerState? of(BuildContext context) =>
      context.findAncestorStateOfType<_ShimmerState>();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _animation = Tween<double>(
      begin: -1.5,
      end: 2.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Animation<double> get shimmerAnimation => _animation;

  @override
  Widget build(BuildContext context) => widget.child;
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  final double? width;
  final double height;
  final double borderRadius;

  static const _base = Color(0xFF1E2235);
  static const _highlight = Color(0xFF2A3050);

  @override
  Widget build(BuildContext context) {
    final shimmerState = _Shimmer.of(context);
    if (shimmerState == null) {
      return _plain();
    }
    return AnimatedBuilder(
      animation: shimmerState.shimmerAnimation,
      builder: (context, _) {
        final t = shimmerState.shimmerAnimation.value;
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [
                (t - 0.5).clamp(0.0, 1.0),
                t.clamp(0.0, 1.0),
                (t + 0.5).clamp(0.0, 1.0),
              ],
              colors: const [_base, _highlight, _base],
            ),
          ),
        );
      },
    );
  }

  Widget _plain() => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: _base,
      borderRadius: BorderRadius.circular(borderRadius),
    ),
  );
}

// ── Stats skeleton (3 cards) ──────────────────────────────────────────────────

class ProfileStatsSkeleton extends StatelessWidget {
  const ProfileStatsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return _Shimmer(
      child: Row(
        children: List.generate(3, (i) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: i == 0 ? 0 : 12),
              child: _StatCardSkeleton(),
            ),
          );
        }),
      ),
    );
  }
}

class _StatCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          const _SkeletonBox(width: 40, height: 40, borderRadius: 12),
          const SizedBox(height: 10),
          const _SkeletonBox(width: 44, height: 18, borderRadius: 6),
          const SizedBox(height: 6),
          const _SkeletonBox(width: 56, height: 10, borderRadius: 4),
        ],
      ),
    );
  }
}

// ── Achievement skeleton ──────────────────────────────────────────────────────

class ProfileAchievementSkeleton extends StatelessWidget {
  const ProfileAchievementSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return _Shimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section label
          const _SkeletonBox(width: 110, height: 11, borderRadius: 4),
          const SizedBox(height: 14),
          // Progress bar card
          _progressBarSkeleton(),
          const SizedBox(height: 16),
          // Badge row
          _badgeRowSkeleton(),
          const SizedBox(height: 20),
          // Course XP label
          const _SkeletonBox(width: 80, height: 11, borderRadius: 4),
          const SizedBox(height: 14),
          // Two course XP cards
          _courseXpCardSkeleton(),
          const SizedBox(height: 12),
          _courseXpCardSkeleton(),
        ],
      ),
    );
  }

  Widget _progressBarSkeleton() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _SkeletonBox(width: 100, height: 13, borderRadius: 4),
              _SkeletonBox(width: 36, height: 13, borderRadius: 4),
            ],
          ),
          const SizedBox(height: 12),
          _SkeletonBox(width: double.infinity, height: 8, borderRadius: 8),
        ],
      ),
    );
  }

  Widget _badgeRowSkeleton() {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: NeverScrollableScrollPhysics(),
        itemCount: 6,
        separatorBuilder: (_, _) => SizedBox(width: 10),
        itemBuilder: (_, __) => Container(
          width: 64,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.outlineVariant, width: 1),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SkeletonBox(width: 28, height: 28, borderRadius: 6),
              SizedBox(height: 6),
              _SkeletonBox(width: 10, height: 10, borderRadius: 5),
            ],
          ),
        ),
      ),
    );
  }

  Widget _courseXpCardSkeleton() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.20),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _SkeletonBox(width: 48, height: 24, borderRadius: 999),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _SkeletonBox(width: 80, height: 14, borderRadius: 4),
                    SizedBox(height: 5),
                    _SkeletonBox(width: 60, height: 10, borderRadius: 4),
                  ],
                ),
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _SkeletonBox(width: 48, height: 22, borderRadius: 4),
                  SizedBox(height: 4),
                  _SkeletonBox(width: 56, height: 10, borderRadius: 4),
                ],
              ),
              const SizedBox(width: 6),
              const _SkeletonBox(width: 20, height: 20, borderRadius: 4),
            ],
          ),
          const SizedBox(height: 14),
          _SkeletonBox(width: double.infinity, height: 8, borderRadius: 999),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _SkeletonBox(width: 70, height: 10, borderRadius: 4),
              _SkeletonBox(width: 80, height: 10, borderRadius: 4),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Activity skeleton ─────────────────────────────────────────────────────────

class ProfileActivitySkeleton extends StatelessWidget {
  const ProfileActivitySkeleton({super.key, this.hideLabel = false});

  final bool hideLabel;
  static const _maxBarH = 72.0;

  @override
  Widget build(BuildContext context) {
    return _Shimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!hideLabel) ...[
            _SkeletonBox(width: 80, height: 11, borderRadius: 4),
            SizedBox(height: 14),
          ],
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          _SkeletonBox(width: 120, height: 14, borderRadius: 4),
                          SizedBox(height: 5),
                          _SkeletonBox(width: 56, height: 10, borderRadius: 4),
                        ],
                      ),
                    ),
                    const _SkeletonBox(width: 32, height: 32, borderRadius: 8),
                    const SizedBox(width: 8),
                    const _SkeletonBox(
                      width: 60,
                      height: 28,
                      borderRadius: 999,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Bar chart
                SizedBox(
                  height: _maxBarH + 52,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(7, (i) {
                      final heights = [
                        0.55,
                        0.80,
                        0.40,
                        0.65,
                        0.90,
                        0.30,
                        0.60,
                      ];
                      return Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const _SkeletonBox(
                              width: 20,
                              height: 9,
                              borderRadius: 3,
                            ),
                            const SizedBox(height: 3),
                            _SkeletonBox(
                              width: 22,
                              height: (_maxBarH * heights[i]).clamp(
                                4,
                                _maxBarH,
                              ),
                              borderRadius: 6,
                            ),
                            const SizedBox(height: 8),
                            const _SkeletonBox(
                              width: 22,
                              height: 22,
                              borderRadius: 11,
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 20),
                // Footer stats
                Row(
                  children: List.generate(3, (i) {
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: i == 0 ? 0 : 8),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              _SkeletonBox(
                                width: 40,
                                height: 14,
                                borderRadius: 4,
                              ),
                              SizedBox(height: 4),
                              _SkeletonBox(
                                width: 56,
                                height: 10,
                                borderRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
