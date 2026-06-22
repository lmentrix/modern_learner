import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/progress/model/progress_models.dart';
import 'package:modern_learner_production/progress/repo/xp_achievement_calculator.dart';
import 'package:modern_learner_production/progress/widget/skill_node_widget.dart';
import 'package:modern_learner_production/theme/theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Node layout constants
// ─────────────────────────────────────────────────────────────────────────────

/// x-position as a fraction of the canvas width, y as a tier row index.
const _kLayout = {
  'b1': (0.17, 0),
  'b2': (0.50, 0),
  'b3': (0.83, 0),
  'i1': (0.17, 1),
  'i2': (0.50, 1),
  'i3': (0.83, 1),
  'a1': (0.33, 2),
  'a2': (0.67, 2),
  'm1': (0.50, 3),
};

/// Deterministic tilt for each node (radians).
const _kTilt = {
  'b1': 0.032,
  'b2': -0.018,
  'b3': 0.025,
  'i1': -0.028,
  'i2': 0.014,
  'i3': -0.022,
  'a1': 0.019,
  'a2': -0.030,
  'm1': 0.010,
};

const _kCardW = 92.0;
const _kCardH = 108.0;

// Each tier owns a complete vertical lane: banner, breathing room, node card,
// and bottom clearance. Keeping these areas separate prevents banners from
// painting over nodes or escaping into the following Achievements section.
const _kTierLaneH = 166.0;
const _kBannerTop = 10.0;
const _kNodeTop = 42.0;
const _kCanvasBottomPadding = 18.0;
const _kCanvasH = 4 * _kTierLaneH + _kCanvasBottomPadding;

// ─────────────────────────────────────────────────────────────────────────────
// Section
// ─────────────────────────────────────────────────────────────────────────────

class SkillTreeSection extends StatefulWidget {
  const SkillTreeSection({
    super.key,
    required this.animate,
    required this.nodes,
    required this.unlockedCount,
    required this.totalNodes,
    required this.currentXp,
    required this.nextMilestone,
  });

  final bool animate;
  final List<SkillNode> nodes;
  final int unlockedCount;
  final int totalNodes;
  final int currentXp;
  final XpMilestone? nextMilestone;

  @override
  State<SkillTreeSection> createState() => _SkillTreeSectionState();
}

class _SkillTreeSectionState extends State<SkillTreeSection>
    with TickerProviderStateMixin {
  late final List<AnimationController> _ctrls;
  late final List<Animation<double>> _fades;
  late final List<Animation<double>> _scales;

  // One controller per node, ordered by row then column
  static final _orderedIds = [
    'b1',
    'b2',
    'b3',
    'i1',
    'i2',
    'i3',
    'a1',
    'a2',
    'm1',
  ];

  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(
      _orderedIds.length,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 480),
      ),
    );
    _fades = _ctrls
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut))
        .toList();
    _scales = _ctrls
        .map(
          (c) => Tween<double>(
            begin: 0.78,
            end: 1.0,
          ).animate(CurvedAnimation(parent: c, curve: Curves.elasticOut)),
        )
        .toList();
    if (widget.animate) _stagger();
  }

  void _stagger() {
    for (var i = 0; i < _orderedIds.length; i++) {
      Future.delayed(Duration(milliseconds: 80 * i + 200), () {
        if (mounted) _ctrls[i].forward();
      });
    }
  }

  @override
  void didUpdateWidget(SkillTreeSection old) {
    super.didUpdateWidget(old);
    if (!old.animate && widget.animate) _stagger();
  }

  @override
  void dispose() {
    for (final c in _ctrls) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Hand-stamp header ──────────────────────────────────────────────
        Padding(
          padding: EduSpacing.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CustomPaint(
                    painter: _StampTextPainter(),
                    size: const Size(120, 36),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: EduColors.primaryLight,
                      borderRadius: EduRadius.borderPill,
                      border: Border.all(
                        color: EduColors.primary.withValues(alpha: 0.30),
                      ),
                    ),
                    child: Text(
                      '${widget.unlockedCount}/${widget.totalNodes} unlocked',
                      style: tt.labelMedium?.copyWith(
                        color: EduColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Subtitle annotation
              Text(
                'Collect skills by completing challenges',
                style: GoogleFonts.caveat(
                  fontSize: 16,
                  color: EduColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: EduSpacing.s3),
              _XpReactionCard(
                currentXp: widget.currentXp,
                nextMilestone: widget.nextMilestone,
              ),
            ],
          ),
        ),

        const SizedBox(height: EduSpacing.s4),

        // ── Tree canvas ────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: EduSpacing.s6),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final positions = _buildPositions(w);

              return Container(
                width: w,
                height: _kCanvasH,
                decoration: BoxDecoration(
                  borderRadius: EduRadius.borderLg,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF475569).withValues(alpha: 0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: EduRadius.borderLg,
                  child: Stack(
                    clipBehavior: Clip.hardEdge,
                    children: [
                      // Paper texture
                      Positioned.fill(
                        child: CustomPaint(painter: _PaperTexturePainter()),
                      ),

                      // Soft tier lanes improve scanability without competing
                      // with the node cards.
                      ..._buildTierBackgrounds(w),

                      // Connection lines (below nodes)
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _ConnectionsPainter(
                            nodes: widget.nodes,
                            positions: positions,
                            cardW: _kCardW,
                            cardH: _kCardH,
                          ),
                        ),
                      ),

                      // Tier dividers (subtle dashed lines)
                      Positioned.fill(
                        child: CustomPaint(painter: _TierDividersPainter()),
                      ),

                      // Tier label badges
                      ..._buildTierLabels(),

                      // Skill nodes
                      ..._buildNodes(positions),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: EduSpacing.s6),

        // ── Hand-drawn legend ──────────────────────────────────────────────
        Padding(padding: EduSpacing.pagePadding, child: _SketchLegend()),

        const SizedBox(height: EduSpacing.s6),
      ],
    );
  }

  // ── Layout helpers ─────────────────────────────────────────────────────────

  Map<String, Offset> _buildPositions(double canvasW) {
    final positions = <String, Offset>{};
    for (final entry in _kLayout.entries) {
      final (xFrac, row) = entry.value;
      final cx = xFrac * canvasW;
      final cy = row * _kTierLaneH + _kNodeTop + _kCardH / 2;
      positions[entry.key] = Offset(cx, cy);
    }
    return positions;
  }

  List<Widget> _buildTierBackgrounds(double canvasW) {
    const tierColors = [
      Color(0xFF059669),
      Color(0xFF7C3AED),
      Color(0xFFD97706),
      Color(0xFFEA580C),
    ];

    return [
      for (var row = 0; row < tierColors.length; row++)
        Positioned(
          top: row * _kTierLaneH,
          left: 0,
          width: canvasW,
          height: _kTierLaneH,
          child: ColoredBox(
            color: tierColors[row].withValues(alpha: row.isEven ? 0.025 : 0.04),
          ),
        ),
    ];
  }

  List<Widget> _buildTierLabels() {
    const tierRows = [
      (0, 'BEGINNER', 'Foundation', Color(0xFF059669)),
      (1, 'INTERMEDIATE', 'Momentum', Color(0xFF7C3AED)),
      (2, 'ADVANCED', 'Mastery', Color(0xFFD97706)),
      (3, 'MASTER', 'Capstone', Color(0xFFEA580C)),
    ];

    return [
      for (final (row, label, caption, color) in tierRows)
        Positioned(
          top: row * _kTierLaneH + _kBannerTop,
          left: 12,
          right: 12,
          child: Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.30),
                      blurRadius: 5,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 7),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: EduRadius.borderPill,
                  border: Border.all(color: color.withValues(alpha: 0.30)),
                ),
                child: Text(
                  label,
                  style: GoogleFonts.caveat(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  caption,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.caveat(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: EduColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
    ];
  }

  List<Widget> _buildNodes(Map<String, Offset> positions) {
    return [
      for (var i = 0; i < _orderedIds.length; i++)
        Builder(
          builder: (context) {
            final id = _orderedIds[i];
            final node = widget.nodes.firstWhere((n) => n.id == id);
            final center = positions[id]!;
            final tilt = _kTilt[id] ?? 0.0;

            // Guard: stale hot-reload State may have fewer _fades entries.
            final safeIdx = i < _fades.length ? i : null;
            final nodeWidget = SkillNodeWidget(
              node: node,
              animate: widget.animate,
              tilt: tilt,
              index: i,
            );

            return Positioned(
              left: center.dx - _kCardW / 2,
              top: center.dy - _kCardH / 2,
              width: _kCardW,
              height: _kCardH,
              child: safeIdx != null
                  ? FadeTransition(
                      opacity: _fades[safeIdx],
                      child: ScaleTransition(
                        scale: _scales[safeIdx],
                        child: nodeWidget,
                      ),
                    )
                  : nodeWidget,
            );
          },
        ),
    ];
  }
}

class _XpReactionCard extends StatelessWidget {
  const _XpReactionCard({required this.currentXp, required this.nextMilestone});

  final int currentXp;
  final XpMilestone? nextMilestone;

  @override
  Widget build(BuildContext context) {
    final milestone = nextMilestone;
    final targetXp = milestone?.requiredXp ?? currentXp;
    final remaining = math.max(0, targetXp - currentXp);
    final progress = targetXp == 0
        ? 1.0
        : (currentXp / targetXp).clamp(0.0, 1.0);
    final typeLabel = milestone?.type == XpMilestoneType.achievement
        ? 'achievement'
        : 'skill';

    return Container(
      padding: const EdgeInsets.all(EduSpacing.s3),
      decoration: BoxDecoration(
        color: EduColors.primaryLight.withValues(alpha: 0.45),
        borderRadius: EduRadius.borderMd,
        border: Border.all(color: EduColors.primary.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                size: 17,
                color: EduColors.primary,
              ),
              const SizedBox(width: EduSpacing.s2),
              Expanded(
                child: Text(
                  milestone == null
                      ? 'All XP milestones unlocked'
                      : 'Next $typeLabel: ${milestone.title}',
                  style: GoogleFonts.caveat(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: EduColors.textPrimary,
                  ),
                ),
              ),
              Text(
                '$currentXp XP',
                style: GoogleFonts.caveat(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: EduColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: EduSpacing.s2),
          ClipRRect(
            borderRadius: EduRadius.borderPill,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: EduColors.surface,
              color: EduColors.primary,
            ),
          ),
          const SizedBox(height: EduSpacing.s1),
          Text(
            milestone == null ? 'Journey complete' : '$remaining XP to unlock',
            style: GoogleFonts.caveat(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: EduColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CustomPainter — connections
// ─────────────────────────────────────────────────────────────────────────────

class _ConnectionsPainter extends CustomPainter {
  const _ConnectionsPainter({
    required this.nodes,
    required this.positions,
    required this.cardW,
    required this.cardH,
  });

  final List<SkillNode> nodes;
  final Map<String, Offset> positions;
  final double cardW;
  final double cardH;

  static int _tierIndex(SkillTier t) {
    switch (t) {
      case SkillTier.beginner:
        return 0;
      case SkillTier.intermediate:
        return 1;
      case SkillTier.advanced:
        return 2;
      case SkillTier.master:
        return 3;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final nodeByIdTier = {for (final n in nodes) n.id: n.tier};

    for (final node in nodes) {
      final childCenter = positions[node.id];
      if (childCenter == null) continue;

      final childTierIdx = _tierIndex(node.tier);

      for (final prereqId in node.prerequisiteIds) {
        final parentCenter = positions[prereqId];
        if (parentCenter == null) continue;

        final parentTier = nodeByIdTier[prereqId];
        final sameTier =
            parentTier != null && _tierIndex(parentTier) == childTierIdx;

        if (sameTier) {
          // Horizontal connection: from right-center of parent to left-center of child
          final fromRight = parentCenter.dx < childCenter.dx;
          final from = Offset(
            fromRight
                ? parentCenter.dx + cardW / 2 - 4
                : parentCenter.dx - cardW / 2 + 4,
            parentCenter.dy,
          );
          final to = Offset(
            fromRight
                ? childCenter.dx - cardW / 2 + 4
                : childCenter.dx + cardW / 2 - 4,
            childCenter.dy,
          );
          _drawHorizontalConnection(canvas, from, to, node.state, prereqId);
        } else {
          final from = Offset(parentCenter.dx, parentCenter.dy + cardH / 2 - 4);
          final to = Offset(childCenter.dx, childCenter.dy - cardH / 2 + 4);
          _drawConnection(canvas, from, to, node.state, prereqId);
        }
      }
    }
  }

  void _drawHorizontalConnection(
    Canvas canvas,
    Offset from,
    Offset to,
    NodeState state,
    String prereqId,
  ) {
    final active = state == NodeState.unlocked || state == NodeState.inProgress;
    final locked = state == NodeState.locked;

    final color = locked
        ? const Color(0xFFCBD5E1)
        : active
        ? _activeColor(prereqId)
        : EduColors.primary.withValues(alpha: 0.28);

    final paint = Paint()
      ..color = color
      ..strokeWidth = active ? 2.0 : (locked ? 1.2 : 1.5)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (locked) {
      _drawDashed(canvas, from, to, paint);
      return;
    }

    // Gentle arc curving slightly downward for visual separation
    final midX = (from.dx + to.dx) / 2;
    const sag = 10.0; // how much the arc dips below the node center
    final path = Path()
      ..moveTo(from.dx, from.dy)
      ..cubicTo(midX, from.dy + sag, midX, to.dy + sag, to.dx, to.dy);

    canvas.drawPath(path, paint);

    // Arrow at end
    _drawArrow(canvas, Offset(midX, to.dy + sag), to, paint..strokeWidth = 1.5);

    // Ink dot at start
    canvas.drawCircle(from, 2.8, Paint()..color = color);
  }

  void _drawConnection(
    Canvas canvas,
    Offset from,
    Offset to,
    NodeState state,
    String prereqId,
  ) {
    final active = state == NodeState.unlocked || state == NodeState.inProgress;
    final locked = state == NodeState.locked;

    final color = locked
        ? const Color(0xFFCBD5E1)
        : active
        ? _activeColor(prereqId)
        : EduColors.primary.withValues(alpha: 0.28);

    final paint = Paint()
      ..color = color
      ..strokeWidth = active ? 2.2 : (locked ? 1.2 : 1.6)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (locked) {
      _drawDashed(canvas, from, to, paint);
      return;
    }

    // Bezier curve — control points pushed toward the midpoint vertically
    final midY = (from.dy + to.dy) / 2;
    final cp1 = Offset(from.dx, midY);
    final cp2 = Offset(to.dx, midY);

    final path = Path()
      ..moveTo(from.dx, from.dy)
      ..cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, to.dx, to.dy);

    canvas.drawPath(path, paint);

    // Arrowhead at the end
    if (!locked) _drawArrow(canvas, cp2, to, paint..strokeWidth = 1.6);

    // Ink dot at the start
    canvas.drawCircle(from, 2.8, Paint()..color = color);
  }

  Color _activeColor(String prereqId) {
    // Look up the tier of the PARENT node
    final parent = nodes.where((n) => n.id == prereqId).firstOrNull;
    if (parent == null) return EduColors.primary;
    return tierInk(parent.tier).withValues(alpha: 0.55);
  }

  void _drawArrow(Canvas canvas, Offset cp2, Offset to, Paint paint) {
    final dx = to.dx - cp2.dx;
    final dy = to.dy - cp2.dy;
    final len = math.sqrt(dx * dx + dy * dy);
    if (len < 1) return;
    final angle = math.atan2(dy, dx);
    const arrowLen = 7.5;
    const spread = 0.42;

    canvas.drawLine(
      to,
      Offset(
        to.dx - arrowLen * math.cos(angle - spread),
        to.dy - arrowLen * math.sin(angle - spread),
      ),
      paint,
    );
    canvas.drawLine(
      to,
      Offset(
        to.dx - arrowLen * math.cos(angle + spread),
        to.dy - arrowLen * math.sin(angle + spread),
      ),
      paint,
    );
  }

  void _drawDashed(Canvas canvas, Offset from, Offset to, Paint paint) {
    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;
    final dist = math.sqrt(dx * dx + dy * dy);
    const dash = 5.0;
    const gap = 4.0;
    var d = 0.0;
    var on = true;
    while (d < dist) {
      final seg = on ? dash : gap;
      final next = math.min(d + seg, dist);
      if (on) {
        canvas.drawLine(
          Offset(from.dx + dx * d / dist, from.dy + dy * d / dist),
          Offset(from.dx + dx * next / dist, from.dy + dy * next / dist),
          paint,
        );
      }
      d += seg;
      on = !on;
    }
  }

  @override
  bool shouldRepaint(_ConnectionsPainter old) => false;
}

class _TierDividersPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const tiers = [
      (Color(0xFF059669), 'BEGINNER', 0),
      (Color(0xFF7C3AED), 'INTERMEDIATE', 1),
      (Color(0xFFD97706), 'ADVANCED', 2),
      (Color(0xFFEA580C), 'MASTER', 3),
    ];

    for (final (color, _, row) in tiers) {
      final y = row * _kTierLaneH + 35;
      final line = Paint()
        ..color = color.withValues(alpha: 0.12)
        ..strokeWidth = 0.8
        ..style = PaintingStyle.stroke;
      const dashW = 5.0;
      const gap = 4.0;
      var x = 40.0;
      while (x < size.width - 16) {
        canvas.drawLine(Offset(x, y), Offset(x + dashW, y), line);
        x += dashW + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_TierDividersPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// CustomPainter — paper texture background
// ─────────────────────────────────────────────────────────────────────────────

class _PaperTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Warm cream fill
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFFEFCF5),
    );

    // Subtle horizontal lines (like notebook paper)
    final line = Paint()
      ..color = const Color(0xFF94A3B8).withValues(alpha: 0.07)
      ..strokeWidth = 0.5;
    const lineH = 18.0;
    for (double y = lineH; y < size.height; y += lineH) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
    }

    // Faint border
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0.5, 0.5, size.width - 1, size.height - 1),
        const Radius.circular(16),
      ),
      Paint()
        ..color = const Color(0xFF94A3B8).withValues(alpha: 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(_PaperTexturePainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// CustomPainter — hand-stamp "SKILL TREE" title text
// ─────────────────────────────────────────────────────────────────────────────

class _StampTextPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const ink = Color(0xFF1A1A2E);

    // Title text
    final tp = TextPainter(
      text: TextSpan(
        text: 'Skill Tree',
        style: GoogleFonts.caveat(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: ink,
          letterSpacing: 0.8,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset.zero);

    // Hand-drawn underline (two overlapping strokes)
    final ul = Paint()
      ..color = const Color(0xFF7C3AED).withValues(alpha: 0.75)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    const y = 31.0;
    const w = 88.0;
    // Main underline with slight wobble
    canvas.drawPath(
      Path()
        ..moveTo(0, y)
        ..quadraticBezierTo(w * 0.35, y + 1.8, w * 0.70, y - 0.8)
        ..lineTo(w, y + 0.5),
      ul,
    );
    // Shadow underline
    canvas.drawPath(
      Path()
        ..moveTo(1.5, y + 2.2)
        ..quadraticBezierTo(w * 0.40, y + 3.5, w * 0.75, y + 1.5)
        ..lineTo(w, y + 2.5),
      ul
        ..color = const Color(0xFF7C3AED).withValues(alpha: 0.22)
        ..strokeWidth = 1.4,
    );

    // Small star decoration
    _drawStar(
      canvas,
      const Offset(96, 12),
      5.5,
      const Color(0xFFF59E0B).withValues(alpha: 0.80),
    );
  }

  void _drawStar(Canvas canvas, Offset center, double r, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final inner = r * 0.42;
    final path = Path();
    for (var i = 0; i < 5; i++) {
      final outerAngle = -math.pi / 2 + i * 2 * math.pi / 5;
      final innerAngle = outerAngle + math.pi / 5;
      final px = center.dx + r * math.cos(outerAngle);
      final py = center.dy + r * math.sin(outerAngle);
      final ix = center.dx + inner * math.cos(innerAngle);
      final iy = center.dy + inner * math.sin(innerAngle);
      i == 0 ? path.moveTo(px, py) : path.lineTo(px, py);
      path.lineTo(ix, iy);
    }
    path.close();
    canvas.drawPath(
      path,
      paint
        ..style = PaintingStyle.fill
        ..color = color.withValues(alpha: 0.25),
    );
    canvas.drawPath(
      path,
      paint
        ..style = PaintingStyle.stroke
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_StampTextPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Legend
// ─────────────────────────────────────────────────────────────────────────────

class _SketchLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const items = [
      ('Unlocked', Color(0xFF059669), Icons.check_rounded),
      ('In Progress', Color(0xFF7C3AED), Icons.play_arrow_rounded),
      ('Available', Color(0xFF6B7280), Icons.radio_button_unchecked_rounded),
      ('Locked', Color(0xFFB0BAC8), Icons.lock_rounded),
    ];

    return Wrap(
      spacing: 14,
      runSpacing: 6,
      children: [
        for (final (label, color, icon) in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.18),
                  border: Border.all(
                    color: color.withValues(alpha: 0.55),
                    width: 1.3,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(icon, size: 9, color: color),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.caveat(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: EduColors.textSecondary,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
