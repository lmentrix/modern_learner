import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/skill_node.dart';
import '../../domain/entities/skill_tree.dart';

class SkillTreeCanvas extends StatelessWidget {
  final SkillTree skillTree;
  final String? selectedNodeId;
  final Function(String nodeId) onNodeTap;
  final Function(String nodeId) onNodeLongPress;

  const SkillTreeCanvas({
    super.key,
    required this.skillTree,
    required this.selectedNodeId,
    required this.onNodeTap,
    required this.onNodeLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SkillTreePathPainter(
        nodes: skillTree.nodes,
        paths: skillTree.paths,
        selectedNodeId: selectedNodeId,
      ),
      size: Size.infinite,
      child: Stack(
        children: skillTree.nodes.map((node) {
          return Positioned.fill(
            child: Align(
              alignment: Alignment(
                (node.positionX / 50) - 1, // Convert 0-100 to -1 to 1
                1 - (node.positionY / 50), // Convert 0-100 to 1 to -1 (inverted)
              ),
              child: GestureDetector(
                onTap: () => onNodeTap(node.id),
                onLongPress: () => onNodeLongPress(node.id),
                child: SkillTreeNode(node: node),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class SkillTreePathPainter extends CustomPainter {
  final List<SkillNode> nodes;
  final List<SkillPath> paths;
  final String? selectedNodeId;

  SkillTreePathPainter({
    required this.nodes,
    required this.paths,
    this.selectedNodeId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final nodeMap = {for (final node in nodes) node.id: node};

    for (final path in paths) {
      final fromNode = nodeMap[path.fromNodeId];
      final toNode = nodeMap[path.toNodeId];
      if (fromNode == null || toNode == null) continue;

      final fromX = (fromNode.positionX / 100) * size.width;
      final fromY = size.height - (fromNode.positionY / 100) * size.height;
      final toX = (toNode.positionX / 100) * size.width;
      final toY = size.height - (toNode.positionY / 100) * size.height;

      final paint = Paint()
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;

      if (path.isUnlocked) {
        final gradient = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.3),
            AppColors.primaryDim.withValues(alpha: 0.6),
          ],
        ).createShader(Rect.fromPoints(Offset(fromX, fromY), Offset(toX, toY)));

        paint.shader = gradient;
        paint.style = PaintingStyle.stroke;

        // Draw glow
        paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawLine(Offset(fromX, fromY), Offset(toX, toY), paint);
        paint.maskFilter = null;

        // Draw solid line
        paint.shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDim],
        ).createShader(Rect.fromPoints(Offset(fromX, fromY), Offset(toX, toY)));
        canvas.drawLine(Offset(fromX, fromY), Offset(toX, toY), paint);

        // Animated particles for unlocked paths
        _drawParticles(canvas, size, fromX, fromY, toX, toY);
      } else {
        paint.color = AppColors.outlineVariant.withValues(alpha: 0.3);
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 2;
        canvas.drawLine(Offset(fromX, fromY), Offset(toX, toY), paint);
      }
    }
  }

  void _drawParticles(Canvas canvas, Size size, double x1, double y1, double x2, double y2) {
    final random = math.Random();
    final particlePaint = Paint()
      ..color = AppColors.tertiary.withValues(alpha: 0.8)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // Draw a few static particles along the path
    for (int i = 0; i < 3; i++) {
      final t = (i + 1) / 4;
      final px = x1 + (x2 - x1) * t;
      final py = y1 + (y2 - y1) * t;

      canvas.drawCircle(
        Offset(px, py),
        3 + random.nextDouble() * 2,
        particlePaint,
      );
    }
  }

  @override
  bool shouldRepaint(SkillTreePathPainter oldDelegate) {
    return oldDelegate.selectedNodeId != selectedNodeId;
  }
}

class SkillTreeNode extends StatefulWidget {
  final SkillNode node;

  const SkillTreeNode({super.key, required this.node});

  @override
  State<SkillTreeNode> createState() => _SkillTreeNodeState();
}

class _SkillTreeNodeState extends State<SkillTreeNode>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    if (widget.node.status == SkillNodeStatus.available ||
        widget.node.status == SkillNodeStatus.inProgress) {
      _controller.repeat();
    }

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final node = widget.node;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: child,
          ),
        );
      },
      child: _buildNode(node),
    );
  }

  Widget _buildNode(SkillNode node) {
    switch (node.status) {
      case SkillNodeStatus.locked:
        return _buildLockedNode(node);
      case SkillNodeStatus.available:
        return _buildAvailableNode(node, isPulsing: true);
      case SkillNodeStatus.inProgress:
        return _buildInProgressNode(node);
      case SkillNodeStatus.completed:
        return _buildCompletedNode(node);
    }
  }

  Widget _buildLockedNode(SkillNode node) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surfaceContainer,
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        Icons.lock_rounded,
        color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
        size: 28,
      ),
    );
  }

  Widget _buildAvailableNode(SkillNode node, {bool isPulsing = false}) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDim.withValues(alpha: 0.5),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 40,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Inner ring
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
          ),
          Text(
            node.emoji,
            style: const TextStyle(fontSize: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildInProgressNode(SkillNode node) {
    return SizedBox(
      width: 76,
      height: 76,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Progress ring
          CircularProgressIndicator(
            value: 0.3,
            strokeWidth: 4,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.tertiary),
          ),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.surfaceContainerHighest,
                  AppColors.primaryDim.withValues(alpha: 0.3),
                ],
              ),
              border: Border.all(
                color: AppColors.tertiary.withValues(alpha: 0.5),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.tertiary.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              node.emoji,
              style: const TextStyle(fontSize: 30),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedNode(SkillNode node) {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.tertiaryContainer.withValues(alpha: 0.3),
            AppColors.tertiary.withValues(alpha: 0.5),
          ],
        ),
        border: Border.all(
          color: AppColors.tertiary,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.tertiary.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            node.emoji,
            style: const TextStyle(fontSize: 32),
          ),
          Positioned(
            top: 2,
            right: 2,
            child: Icon(
              Icons.check_circle_rounded,
              color: AppColors.tertiary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
