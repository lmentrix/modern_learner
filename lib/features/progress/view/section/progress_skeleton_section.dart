import 'package:flutter/material.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/progress/data/progress_page_constants.dart';

class ProgressSkeletonSection extends StatefulWidget {
  const ProgressSkeletonSection({super.key});

  @override
  State<ProgressSkeletonSection> createState() =>
      _ProgressSkeletonSectionState();
}

class _ProgressSkeletonSectionState extends State<ProgressSkeletonSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _shimmer = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmer,
      builder: (context, _) {
        return CustomScrollView(
          physics: const NeverScrollableScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(
              child: SizedBox(height: ProgressPageConstants.sectionSpacing),
            ),
            SliverPadding(
              padding: ProgressPageConstants.pagePadding,
              sliver: SliverToBoxAdapter(
                child: _SkeletonHeader(shimmerValue: _shimmer.value),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: ProgressPageConstants.sectionSpacing),
            ),
            SliverPadding(
              padding: ProgressPageConstants.pagePadding,
              sliver: SliverToBoxAdapter(
                child: _SkeletonJourney(shimmerValue: _shimmer.value),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Header skeleton ──────────────────────────────────────────────────────────

class _SkeletonHeader extends StatelessWidget {
  const _SkeletonHeader({required this.shimmerValue});
  final double shimmerValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SkeletonSectionHeading(shimmerValue: shimmerValue),
        const SizedBox(height: 18),
        _SkeletonXpBar(shimmerValue: shimmerValue),
      ],
    );
  }
}

class _SkeletonXpBar extends StatelessWidget {
  const _SkeletonXpBar({required this.shimmerValue});
  final double shimmerValue;

  @override
  Widget build(BuildContext context) {
    return _ShimmerBox(
      shimmerValue: shimmerValue,
      width: double.infinity,
      height: 80,
      borderRadius: 16,
    );
  }
}

// ── Journey skeleton ─────────────────────────────────────────────────────────

class _SkeletonJourney extends StatelessWidget {
  const _SkeletonJourney({required this.shimmerValue});
  final double shimmerValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SkeletonSectionHeading(shimmerValue: shimmerValue),
        const SizedBox(height: 18),
        for (int i = 0; i < 5; i++) ...[
          _SkeletonChapterTile(shimmerValue: shimmerValue, isLast: i == 4),
        ],
      ],
    );
  }
}

class _SkeletonChapterTile extends StatelessWidget {
  const _SkeletonChapterTile({
    required this.shimmerValue,
    required this.isLast,
  });

  final double shimmerValue;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline column
          SizedBox(
            width: 40,
            child: Column(
              children: [
                _ShimmerBox(
                  shimmerValue: shimmerValue,
                  width: 40,
                  height: 40,
                  borderRadius: 12,
                ),
                if (!isLast)
                  Expanded(
                    child: Center(
                      child: _ShimmerBox(
                        shimmerValue: shimmerValue,
                        width: 2,
                        height: double.infinity,
                        borderRadius: 2,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  _ShimmerBox(
                    shimmerValue: shimmerValue,
                    width: 60,
                    height: 11,
                    borderRadius: 6,
                  ),
                  const SizedBox(height: 8),
                  _ShimmerBox(
                    shimmerValue: shimmerValue,
                    width: double.infinity,
                    height: 16,
                    borderRadius: 6,
                  ),
                  const SizedBox(height: 6),
                  _ShimmerBox(
                    shimmerValue: shimmerValue,
                    width: 140,
                    height: 12,
                    borderRadius: 6,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared heading skeleton ───────────────────────────────────────────────────

class _SkeletonSectionHeading extends StatelessWidget {
  const _SkeletonSectionHeading({required this.shimmerValue});
  final double shimmerValue;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Accent bar
        _ShimmerBox(
          shimmerValue: shimmerValue,
          width: 3,
          height: 56,
          borderRadius: 999,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Eyebrow pill
              _ShimmerBox(
                shimmerValue: shimmerValue,
                width: 72,
                height: 22,
                borderRadius: 999,
              ),
              const SizedBox(height: 10),
              // Title
              _ShimmerBox(
                shimmerValue: shimmerValue,
                width: 220,
                height: 20,
                borderRadius: 6,
              ),
              const SizedBox(height: 8),
              // Subtitle line 1
              _ShimmerBox(
                shimmerValue: shimmerValue,
                width: double.infinity,
                height: 13,
                borderRadius: 5,
              ),
              const SizedBox(height: 5),
              // Subtitle line 2
              _ShimmerBox(
                shimmerValue: shimmerValue,
                width: 180,
                height: 13,
                borderRadius: 5,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Shimmer box primitive ─────────────────────────────────────────────────────

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    required this.shimmerValue,
    required this.width,
    required this.height,
    required this.borderRadius,
  });

  final double shimmerValue;
  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    const base = AppColors.surfaceContainerHigh;
    const highlight = AppColors.surfaceContainerHighest;

    final color = Color.lerp(base, highlight, shimmerValue)!;

    return Container(
      width: width == double.infinity ? null : width,
      height: height == double.infinity ? null : height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
