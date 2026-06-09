import 'package:flutter/material.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/profile/data/profile_page_constants.dart';

/// Full-page shimmer skeleton shown while an exercise is being generated.
/// Mirrors the real exercise page layout (header → intro card → question
/// groups → action card) so the transition feels seamless.
class ExerciseSkeletonSection extends StatefulWidget {
  const ExerciseSkeletonSection({
    super.key,
    required this.accentColor,
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

  final Color accentColor;

  /// The subcontent title — shown as real text so the user knows what's loading.
  final String title;

  /// The chapter title — shown as real text in the header eyebrow row.
  final String subtitle;

  final VoidCallback onBack;

  @override
  State<ExerciseSkeletonSection> createState() =>
      _ExerciseSkeletonSectionState();
}

class _ExerciseSkeletonSectionState extends State<ExerciseSkeletonSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _shimmer = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: AnimatedBuilder(
        animation: _shimmer,
        builder: (context, _) {
          final sv = _shimmer.value;
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Header ──────────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: _SkeletonHeader(
                  shimmerValue: sv,
                  accentColor: widget.accentColor,
                  title: widget.title,
                  subtitle: widget.subtitle,
                  onBack: widget.onBack,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // ── Intro card ───────────────────────────────────────────────────
              SliverPadding(
                padding: ProfilePageConstants.pagePadding,
                sliver: SliverToBoxAdapter(
                  child: _SkeletonPanel(
                    shimmerValue: sv,
                    accentColor: widget.accentColor,
                    child: _SkeletonIntroBody(
                      shimmerValue: sv,
                      accentColor: widget.accentColor,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: ProfilePageConstants.sectionSpacing),
              ),

              // ── Question group 1 ─────────────────────────────────────────────
              SliverPadding(
                padding: ProfilePageConstants.pagePadding,
                sliver: SliverToBoxAdapter(
                  child: _SkeletonPanel(
                    shimmerValue: sv,
                    accentColor: widget.accentColor,
                    child: _SkeletonQuestionGroup(
                      shimmerValue: sv,
                      accentColor: widget.accentColor,
                      questionCount: 3,
                      questionType: _QuestionSkeletonType.multipleChoice,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: ProfilePageConstants.sectionSpacing),
              ),

              // ── Question group 2 ─────────────────────────────────────────────
              SliverPadding(
                padding: ProfilePageConstants.pagePadding,
                sliver: SliverToBoxAdapter(
                  child: _SkeletonPanel(
                    shimmerValue: sv,
                    accentColor: widget.accentColor,
                    child: _SkeletonQuestionGroup(
                      shimmerValue: sv,
                      accentColor: widget.accentColor,
                      questionCount: 2,
                      questionType: _QuestionSkeletonType.fillBlank,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: ProfilePageConstants.sectionSpacing),
              ),

              // ── Question group 3 (matching) ──────────────────────────────────
              SliverPadding(
                padding: ProfilePageConstants.pagePadding,
                sliver: SliverToBoxAdapter(
                  child: _SkeletonPanel(
                    shimmerValue: sv,
                    accentColor: widget.accentColor,
                    child: _SkeletonQuestionGroup(
                      shimmerValue: sv,
                      accentColor: widget.accentColor,
                      questionCount: 3,
                      questionType: _QuestionSkeletonType.matching,
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 18)),

              // ── Action card ──────────────────────────────────────────────────
              SliverPadding(
                padding: ProfilePageConstants.pagePadding,
                sliver: SliverToBoxAdapter(
                  child: _SkeletonPanel(
                    shimmerValue: sv,
                    accentColor: widget.accentColor,
                    child: _SkeletonActionRow(
                      shimmerValue: sv,
                      accentColor: widget.accentColor,
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
    );
  }
}

// ── Header skeleton ───────────────────────────────────────────────────────────

class _SkeletonHeader extends StatelessWidget {
  const _SkeletonHeader({
    required this.shimmerValue,
    required this.accentColor,
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

  final double shimmerValue;
  final Color accentColor;
  final String title;
  final String subtitle;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      decoration: BoxDecoration(gradient: ProfilePageConstants.headerGradient),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back + pill row
          Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded),
                color: Colors.white,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.10),
                ),
              ),
              const Spacer(),
              // Pill badge shimmer
              _ShimmerBox(
                shimmerValue: shimmerValue,
                width: 80,
                height: 28,
                borderRadius: 999,
                baseColor: accentColor.withValues(alpha: 0.18),
                highlightColor: accentColor.withValues(alpha: 0.32),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Eyebrow — shimmer line
          _ShimmerBox(
            shimmerValue: shimmerValue,
            width: 130,
            height: 11,
            borderRadius: 5,
            baseColor: Colors.white.withValues(alpha: 0.12),
            highlightColor: Colors.white.withValues(alpha: 0.22),
          ),
          const SizedBox(height: 12),
          // Title — real text so the user knows what's loading
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.08,
              fontFamily: 'SpaceGrotesk',
            ),
          ),
          const SizedBox(height: 10),
          // Subtitle — real text
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.70),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Panel wrapper (mirrors ExercisePanel) ─────────────────────────────────────

class _SkeletonPanel extends StatelessWidget {
  const _SkeletonPanel({
    required this.shimmerValue,
    required this.accentColor,
    required this.child,
  });

  final double shimmerValue;
  final Color accentColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accentColor.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ── Intro card body ───────────────────────────────────────────────────────────

class _SkeletonIntroBody extends StatelessWidget {
  const _SkeletonIntroBody({
    required this.shimmerValue,
    required this.accentColor,
  });

  final double shimmerValue;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Introduction text lines
        _ShimmerBox(
          shimmerValue: shimmerValue,
          width: double.infinity,
          height: 13,
          borderRadius: 5,
        ),
        const SizedBox(height: 7),
        _ShimmerBox(
          shimmerValue: shimmerValue,
          width: double.infinity,
          height: 13,
          borderRadius: 5,
        ),
        const SizedBox(height: 7),
        _ShimmerBox(
          shimmerValue: shimmerValue,
          width: 220,
          height: 13,
          borderRadius: 5,
        ),
        const SizedBox(height: 18),
        // Chip row
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _ShimmerBox(
              shimmerValue: shimmerValue,
              width: 74,
              height: 26,
              borderRadius: 999,
            ),
            _ShimmerBox(
              shimmerValue: shimmerValue,
              width: 94,
              height: 26,
              borderRadius: 999,
            ),
            _ShimmerBox(
              shimmerValue: shimmerValue,
              width: 108,
              height: 26,
              borderRadius: 999,
            ),
          ],
        ),
        const SizedBox(height: 18),
        // Learning focus label
        _ShimmerBox(
          shimmerValue: shimmerValue,
          width: 110,
          height: 11,
          borderRadius: 5,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _ShimmerBox(
              shimmerValue: shimmerValue,
              width: 88,
              height: 26,
              borderRadius: 999,
            ),
            _ShimmerBox(
              shimmerValue: shimmerValue,
              width: 112,
              height: 26,
              borderRadius: 999,
            ),
          ],
        ),
      ],
    );
  }
}

// ── Question group body ───────────────────────────────────────────────────────

enum _QuestionSkeletonType { multipleChoice, fillBlank, matching }

class _SkeletonQuestionGroup extends StatelessWidget {
  const _SkeletonQuestionGroup({
    required this.shimmerValue,
    required this.accentColor,
    required this.questionCount,
    required this.questionType,
  });

  final double shimmerValue;
  final Color accentColor;
  final int questionCount;
  final _QuestionSkeletonType questionType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Group header — type badge + title + instructions
        Row(
          children: [
            _ShimmerBox(
              shimmerValue: shimmerValue,
              width: 72,
              height: 22,
              borderRadius: 999,
            ),
            const SizedBox(width: 10),
            _ShimmerBox(
              shimmerValue: shimmerValue,
              width: 44,
              height: 22,
              borderRadius: 999,
            ),
          ],
        ),
        const SizedBox(height: 10),
        _ShimmerBox(
          shimmerValue: shimmerValue,
          width: double.infinity,
          height: 16,
          borderRadius: 6,
        ),
        const SizedBox(height: 6),
        _ShimmerBox(
          shimmerValue: shimmerValue,
          width: 200,
          height: 13,
          borderRadius: 5,
        ),
        const SizedBox(height: 20),
        // Question items
        for (int i = 0; i < questionCount; i++) ...[
          if (i > 0) const SizedBox(height: 14),
          _buildQuestion(i),
        ],
      ],
    );
  }

  Widget _buildQuestion(int index) {
    return switch (questionType) {
      _QuestionSkeletonType.multipleChoice => _SkeletonMultipleChoice(
        shimmerValue: shimmerValue,
        accentColor: accentColor,
        index: index,
      ),
      _QuestionSkeletonType.fillBlank => _SkeletonFillBlank(
        shimmerValue: shimmerValue,
        accentColor: accentColor,
      ),
      _QuestionSkeletonType.matching => _SkeletonMatchingRow(
        shimmerValue: shimmerValue,
        accentColor: accentColor,
      ),
    };
  }
}

// ── Multiple-choice question skeleton ─────────────────────────────────────────

class _SkeletonMultipleChoice extends StatelessWidget {
  const _SkeletonMultipleChoice({
    required this.shimmerValue,
    required this.accentColor,
    required this.index,
  });

  final double shimmerValue;
  final Color accentColor;
  final int index;

  @override
  Widget build(BuildContext context) {
    // Vary the prompt width slightly so the skeleton doesn't look copy-pasted.
    final promptWidth = index.isEven ? double.infinity : 260.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Prompt
        _ShimmerBox(
          shimmerValue: shimmerValue,
          width: promptWidth,
          height: 14,
          borderRadius: 5,
        ),
        const SizedBox(height: 12),
        // 4 answer options
        for (int i = 0; i < 4; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _SkeletonAnswerOption(
            shimmerValue: shimmerValue,
            accentColor: accentColor,
            index: i,
          ),
        ],
      ],
    );
  }
}

class _SkeletonAnswerOption extends StatelessWidget {
  const _SkeletonAnswerOption({
    required this.shimmerValue,
    required this.accentColor,
    required this.index,
  });

  final double shimmerValue;
  final Color accentColor;
  final int index;

  @override
  Widget build(BuildContext context) {
    final labelWidths = [140.0, 100.0, 160.0, 120.0];
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          // Radio circle placeholder
          _ShimmerBox(
            shimmerValue: shimmerValue,
            width: 18,
            height: 18,
            borderRadius: 999,
          ),
          const SizedBox(width: 12),
          _ShimmerBox(
            shimmerValue: shimmerValue,
            width: labelWidths[index % labelWidths.length],
            height: 13,
            borderRadius: 5,
          ),
        ],
      ),
    );
  }
}

// ── Fill-in-the-blank skeleton ────────────────────────────────────────────────

class _SkeletonFillBlank extends StatelessWidget {
  const _SkeletonFillBlank({
    required this.shimmerValue,
    required this.accentColor,
  });

  final double shimmerValue;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ShimmerBox(
          shimmerValue: shimmerValue,
          width: double.infinity,
          height: 14,
          borderRadius: 5,
        ),
        SizedBox(height: 10),
        // Text field placeholder
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accentColor.withValues(alpha: 0.18)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Align(
            alignment: Alignment.centerLeft,
            child: _ShimmerBox(
              shimmerValue: shimmerValue,
              width: 100,
              height: 13,
              borderRadius: 5,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Matching row skeleton ─────────────────────────────────────────────────────

class _SkeletonMatchingRow extends StatelessWidget {
  const _SkeletonMatchingRow({
    required this.shimmerValue,
    required this.accentColor,
  });

  final double shimmerValue;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left item
        Expanded(
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accentColor.withValues(alpha: 0.18)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              child: _ShimmerBox(
                shimmerValue: shimmerValue,
                width: double.infinity,
                height: 13,
                borderRadius: 5,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: _ShimmerBox(
            shimmerValue: shimmerValue,
            width: 18,
            height: 18,
            borderRadius: 999,
          ),
        ),
        // Right item
        Expanded(
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.20),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              child: _ShimmerBox(
                shimmerValue: shimmerValue,
                width: double.infinity,
                height: 13,
                borderRadius: 5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Action card body ──────────────────────────────────────────────────────────

class _SkeletonActionRow extends StatelessWidget {
  const _SkeletonActionRow({
    required this.shimmerValue,
    required this.accentColor,
  });

  final double shimmerValue;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;
        final textLine = _ShimmerBox(
          shimmerValue: shimmerValue,
          width: compact ? constraints.maxWidth : double.infinity,
          height: 18,
          borderRadius: 6,
        );
        final button = _ShimmerBox(
          shimmerValue: shimmerValue,
          width: compact ? constraints.maxWidth : 100,
          height: 44,
          borderRadius: 999,
          baseColor: accentColor.withValues(alpha: 0.22),
          highlightColor: accentColor.withValues(alpha: 0.38),
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [textLine, const SizedBox(height: 12), button],
          );
        }

        return Row(
          children: [
            Expanded(child: textLine),
            const SizedBox(width: 16),
            button,
          ],
        );
      },
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
    this.baseColor,
    this.highlightColor,
  });

  final double shimmerValue;
  final double width;
  final double height;
  final double borderRadius;
  final Color? baseColor;
  final Color? highlightColor;

  @override
  Widget build(BuildContext context) {
    final base = baseColor ?? AppColors.surfaceContainerHigh;
    final highlight = highlightColor ?? AppColors.surfaceContainerHighest;
    final color = Color.lerp(base, highlight, shimmerValue) ?? base;

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
