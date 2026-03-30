import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/skill_node.dart';
import '../../domain/entities/skill_tree.dart';

class LessonPathWidget extends StatelessWidget {
  final SkillTree skillTree;
  final String? selectedNodeId;
  final Function(String nodeId) onNodeTap;

  const LessonPathWidget({
    super.key,
    required this.skillTree,
    required this.selectedNodeId,
    required this.onNodeTap,
  });

  List<SkillNode> get _sortedNodes {
    final nodes = [...skillTree.nodes];
    nodes.sort((a, b) => b.positionY.compareTo(a.positionY));
    return nodes;
  }

  @override
  Widget build(BuildContext context) {
    final nodes = _sortedNodes;

    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: 80),
      itemCount: nodes.length,
      itemBuilder: (context, index) {
        final node = nodes[index];
        final showChapterBanner = index % 4 == 0;
        // Alternate node positions: right offset on even, left on odd
        final xOffset = index % 2 == 0 ? 0.38 : -0.38;

        return Column(
          children: [
            if (showChapterBanner)
              _ChapterBanner(
                chapter: (index ~/ 4) + 1,
                title: _chapterTitle(index ~/ 4),
              ),
            _PathNodeRow(
              node: node,
              xOffset: xOffset,
              showTopLine: index > 0,
              showBottomLine: index < nodes.length - 1,
              onTap: () => onNodeTap(node.id),
            ),
          ],
        );
      },
    );
  }

  String _chapterTitle(int index) {
    const titles = [
      'Foundations',
      'Building Skills',
      'Going Deeper',
      'Mastery',
      'Expert Territory',
    ];
    return index < titles.length ? titles[index] : 'Advanced';
  }
}

class _ChapterBanner extends StatelessWidget {
  final int chapter;
  final String title;

  const _ChapterBanner({required this.chapter, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
            ),
            child: Center(
              child: Text(
                '$chapter',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chapter $chapter',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PathNodeRow extends StatelessWidget {
  final SkillNode node;
  final double xOffset;
  final bool showTopLine;
  final bool showBottomLine;
  final VoidCallback onTap;

  const _PathNodeRow({
    required this.node,
    required this.xOffset,
    required this.showTopLine,
    required this.showBottomLine,
    required this.onTap,
  });

  Color get _lineColor {
    if (node.status == SkillNodeStatus.locked) {
      return AppColors.outlineVariant.withValues(alpha: 0.2);
    }
    if (node.status == SkillNodeStatus.completed) {
      return AppColors.tertiary.withValues(alpha: 0.3);
    }
    return AppColors.primary.withValues(alpha: 0.35);
  }

  bool get _isActive =>
      node.status == SkillNodeStatus.available ||
      node.status == SkillNodeStatus.inProgress;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final centerX = screenWidth / 2;
    // Give a bit more height to active nodes for the label
    final rowHeight = _isActive ? 118.0 : 104.0;

    return SizedBox(
      height: rowHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Top line segment
          if (showTopLine)
            Positioned(
              top: 0,
              left: centerX - 1,
              width: 2,
              height: rowHeight / 2,
              child: Container(color: _lineColor),
            ),
          // Bottom line segment
          if (showBottomLine)
            Positioned(
              top: rowHeight / 2,
              left: centerX - 1,
              width: 2,
              height: rowHeight / 2,
              child: Container(color: _lineColor),
            ),
          // Node circle
          Align(
            alignment: Alignment(xOffset, _isActive ? -0.2 : 0),
            child: GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: _PathNodeCircle(node: node),
            ),
          ),
          // Start / Continue label beneath active node
          if (_isActive)
            Align(
              alignment: Alignment(xOffset, 0.82),
              child: _ActionLabel(status: node.status),
            ),
        ],
      ),
    );
  }
}

class _ActionLabel extends StatelessWidget {
  final SkillNodeStatus status;

  const _ActionLabel({required this.status});

  @override
  Widget build(BuildContext context) {
    final isContinue = status == SkillNodeStatus.inProgress;
    final label = isContinue ? 'Continue' : 'Start';
    final color = isContinue ? AppColors.tertiary : AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _PathNodeCircle extends StatefulWidget {
  final SkillNode node;

  const _PathNodeCircle({required this.node});

  @override
  State<_PathNodeCircle> createState() => _PathNodeCircleState();
}

class _PathNodeCircleState extends State<_PathNodeCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1100),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.node.status == SkillNodeStatus.available ||
        widget.node.status == SkillNodeStatus.inProgress) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (_, child) => Transform.scale(scale: _scaleAnim.value, child: child),
      child: _buildNode(),
    );
  }

  Widget _buildNode() {
    return switch (widget.node.status) {
      SkillNodeStatus.locked => _lockedNode(),
      SkillNodeStatus.available => _availableNode(),
      SkillNodeStatus.inProgress => _inProgressNode(),
      SkillNodeStatus.completed => _completedNode(),
    };
  }

  Widget _lockedNode() {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surfaceContainerHigh,
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Icon(
        Icons.lock_rounded,
        color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
        size: 22,
      ),
    );
  }

  Widget _availableNode() {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDim.withValues(alpha: 0.45),
            blurRadius: 18,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Text(
          widget.node.emoji,
          style: const TextStyle(fontSize: 30),
        ),
      ),
    );
  }

  Widget _inProgressNode() {
    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: 0.4,
            strokeWidth: 3,
            backgroundColor: AppColors.surfaceContainerHighest,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.tertiary),
          ),
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceContainerHighest,
              border: Border.all(
                color: AppColors.tertiary.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                widget.node.emoji,
                style: const TextStyle(fontSize: 26),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _completedNode() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.tertiary.withValues(alpha: 0.1),
            border: Border.all(
              color: AppColors.tertiary.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              widget.node.emoji,
              style: const TextStyle(fontSize: 26),
            ),
          ),
        ),
        Positioned(
          top: -2,
          right: -2,
          child: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.tertiary,
            ),
            child: const Icon(Icons.check_rounded, color: Colors.black, size: 13),
          ),
        ),
      ],
    );
  }
}
