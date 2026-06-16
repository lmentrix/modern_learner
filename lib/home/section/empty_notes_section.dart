import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/home/data/home_data.dart';
import 'package:modern_learner_production/home/model/home_models.dart';
import 'package:modern_learner_production/home/widgets/note_card.dart';
import 'package:modern_learner_production/theme/theme.dart';

// ── Section shell (stateful so it owns the notes list) ───────────────────────

class EmptyNotesSection extends StatefulWidget {
  const EmptyNotesSection({super.key});

  @override
  State<EmptyNotesSection> createState() => _EmptyNotesSectionState();
}

class _EmptyNotesSectionState extends State<EmptyNotesSection> {
  final List<NoteItem> _notes = List.of(mockNotes);

  void _delete(NoteItem note) {
    setState(() => _notes.remove(note));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: EduSpacing.s6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──────────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'My notes',
                    style: GoogleFonts.caveat(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: EduColors.textPrimary,
                    ),
                  ),
                  CustomPaint(
                    painter: _ThinAccentLine(),
                    size: const Size(70, 5),
                  ),
                ],
              ),
              const Spacer(),
              if (_notes.isNotEmpty)
                _UploadChip(label: '+ Upload', onTap: () {}),
            ],
          ),

          const SizedBox(height: EduSpacing.s8),

          // ── Content — cross-fades between list and empty state ───────────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 380),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.06),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: _notes.isEmpty
                ? const Center(key: ValueKey('empty'), child: _UploadEmptyState())
                : _NotesList(
                    key: const ValueKey('list'),
                    notes: _notes,
                    onDelete: _delete,
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Animated notes list ───────────────────────────────────────────────────────

class _NotesList extends StatefulWidget {
  const _NotesList({super.key, required this.notes, required this.onDelete});
  final List<NoteItem> notes;
  final void Function(NoteItem) onDelete;

  @override
  State<_NotesList> createState() => _NotesListState();
}

class _NotesListState extends State<_NotesList> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();

  // Tracks which items are mid-deletion so we can show the shrink-away widget.
  final Set<String> _deleting = {};

  void _handleDelete(NoteItem note, int index) {
    HapticFeedback.mediumImpact();
    setState(() => _deleting.add(note.id));

    // Let the dismiss animation finish, then collapse the row.
    Future.delayed(const Duration(milliseconds: 260), () {
      if (!mounted) return;
      _listKey.currentState?.removeItem(
        index,
        (context, animation) => _buildRemovedCard(note, animation),
        duration: const Duration(milliseconds: 320),
      );
      // Notify parent after collapse starts so the parent list shrinks too.
      Future.delayed(const Duration(milliseconds: 160), () {
        if (mounted) widget.onDelete(note);
      });
    });
  }

  Widget _buildRemovedCard(NoteItem note, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
      axisAlignment: -1,
      child: FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
        child: Padding(
          padding: const EdgeInsets.only(bottom: EduSpacing.s3),
          child: NoteCard(note: note),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: _listKey,
      initialItemCount: widget.notes.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index, animation) {
        if (index >= widget.notes.length) return const SizedBox.shrink();
        final note = widget.notes[index];

        return _Swipeable(
          key: ValueKey(note.id),
          animation: animation,
          isDeleting: _deleting.contains(note.id),
          isLast: index == widget.notes.length - 1,
          onDelete: () => _handleDelete(note, index),
          child: NoteCard(note: note),
        );
      },
    );
  }
}

// ── Swipeable row wrapper ─────────────────────────────────────────────────────

class _Swipeable extends StatefulWidget {
  const _Swipeable({
    super.key,
    required this.animation,
    required this.isDeleting,
    required this.isLast,
    required this.onDelete,
    required this.child,
  });

  final Animation<double> animation;
  final bool isDeleting;
  final bool isLast;
  final VoidCallback onDelete;
  final Widget child;

  @override
  State<_Swipeable> createState() => _SwipeableState();
}

class _SwipeableState extends State<_Swipeable>
    with TickerProviderStateMixin {
  // Phase 1: scribble lines draw across the card (0 → 1).
  late final AnimationController _scribbleCtrl;
  // Phase 2: card crumples — scaleX squishes then scaleY collapses.
  late final AnimationController _crumpleCtrl;
  late final Animation<double> _crumpleX;
  late final Animation<double> _crumpleY;
  late final Animation<double> _crumpleRotate;

  double _scribbleProgress = 0;

  @override
  void initState() {
    super.initState();

    _scribbleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )..addListener(() {
        setState(() => _scribbleProgress = _scribbleCtrl.value);
      });

    _crumpleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    // ScaleX: 1 → 0  (squish horizontally like crumpling paper)
    _crumpleX = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _crumpleCtrl,
        curve: const Interval(0.0, 0.7, curve: Curves.easeInBack),
      ),
    );
    // ScaleY: 1 → 0  (flatten after horizontal squish)
    _crumpleY = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _crumpleCtrl,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );
    // Slight tilt while crumpling
    _crumpleRotate = Tween<double>(begin: 0.0, end: 0.08).animate(
      CurvedAnimation(
        parent: _crumpleCtrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _scribbleCtrl.dispose();
    _crumpleCtrl.dispose();
    super.dispose();
  }

  Future<bool> _confirmDismiss(DismissDirection _) async {
    HapticFeedback.mediumImpact();
    // Draw scribbles across the card.
    await _scribbleCtrl.forward();
    HapticFeedback.lightImpact();
    // Crumple the card.
    await _crumpleCtrl.forward();
    widget.onDelete();
    return false; // AnimatedList handles the row collapse
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: CurvedAnimation(parent: widget.animation, curve: Curves.easeOut),
      child: FadeTransition(
        opacity: CurvedAnimation(parent: widget.animation, curve: Curves.easeOut),
        child: Padding(
          padding: EdgeInsets.only(bottom: widget.isLast ? 0 : EduSpacing.s3),
          child: Dismissible(
            key: ValueKey('dismiss_${widget.key}'),
            direction: DismissDirection.endToStart,
            confirmDismiss: _confirmDismiss,
            // ── Sketch eraser panel ──────────────────────────────────────
            background: CustomPaint(
              painter: _SketchEraserPainter(),
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: EduSpacing.s5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(28, 28),
                        painter: _SketchTrashPainter(),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'erase',
                        style: GoogleFonts.caveat(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFDC2626),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // ── Card with scribble overlay + crumple transform ───────────
            child: AnimatedBuilder(
              animation: _crumpleCtrl,
              builder: (context, child) => Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..rotateZ(_crumpleRotate.value)
                  ..scale(_crumpleX.value, _crumpleY.value),
                child: child,
              ),
              child: CustomPaint(
                foregroundPainter: _ScribblePainter(
                  progress: _scribbleProgress,
                  color: const Color(0xFFDC2626),
                ),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Sketch eraser background painter ─────────────────────────────────────────
// Draws a light-red fill with a rough hand-drawn border.

class _SketchEraserPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = 20.0;

    // Soft fill
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(r)),
      Paint()..color = const Color(0xFFFEE2E2),
    );

    // Rough wobbly border — 4 sides drawn as slightly imperfect cubic curves
    final stroke = Paint()
      ..color = const Color(0xFFDC2626).withValues(alpha: 0.55)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(r + 2, 1)
      ..cubicTo(w * 0.35, -2, w * 0.65, 3, w - r - 1, 1)   // top
      ..cubicTo(w + 2, r, w - 2, h - r, w - 1, h - r - 1)  // right
      ..cubicTo(w - r, h + 2, r + 2, h - 3, 1, h - r - 1)  // bottom
      ..cubicTo(-2, h - r, 3, r, 1, r + 1)                  // left
      ..close();
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(_SketchEraserPainter _) => false;
}

// ── Sketch trash icon painter ─────────────────────────────────────────────────
// Hand-drawn trash can: rough rectangle body + lid + three lines inside.

class _SketchTrashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFFDC2626)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // Body (rough rectangle, slightly wobbly)
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.18, h * 0.32)
        ..cubicTo(w * 0.15, h * 0.55, w * 0.17, h * 0.80, w * 0.20, h * 0.92)
        ..cubicTo(w * 0.38, h * 0.96, w * 0.62, h * 0.95, w * 0.80, h * 0.92)
        ..cubicTo(w * 0.83, h * 0.78, w * 0.85, h * 0.52, w * 0.82, h * 0.32),
      p,
    );

    // Lid
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.10, h * 0.28)
        ..cubicTo(w * 0.35, h * 0.22, w * 0.65, h * 0.24, w * 0.90, h * 0.28),
      p,
    );

    // Handle on lid
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.38, h * 0.24)
        ..cubicTo(w * 0.40, h * 0.12, w * 0.60, h * 0.12, w * 0.62, h * 0.24),
      p,
    );

    // Three inner lines
    for (final t in [0.42, 0.55, 0.68]) {
      canvas.drawLine(
        Offset(w * 0.35, h * t),
        Offset(w * 0.33, h * (t + 0.22)),
        p,
      );
    }
  }

  @override
  bool shouldRepaint(_SketchTrashPainter _) => false;
}

// ── Scribble overlay painter ──────────────────────────────────────────────────
// Progressively draws 3 rough diagonal lines across the card as progress 0→1.

class _ScribblePainter extends CustomPainter {
  const _ScribblePainter({required this.progress, required this.color});
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    final paint = Paint()
      ..color = color.withValues(alpha: 0.75)
      ..strokeWidth = 2.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Three rough lines; each occupies 1/3 of the total progress.
    final lines = [
      _wobblyLine(
        Offset(size.width * 0.04, size.height * 0.20),
        Offset(size.width * 0.96, size.height * 0.78),
        cx1: size.width * 0.30, cy1: size.height * 0.10,
        cx2: size.width * 0.68, cy2: size.height * 0.88,
      ),
      _wobblyLine(
        Offset(size.width * 0.96, size.height * 0.22),
        Offset(size.width * 0.04, size.height * 0.80),
        cx1: size.width * 0.70, cy1: size.height * 0.08,
        cx2: size.width * 0.28, cy2: size.height * 0.90,
      ),
      _wobblyLine(
        Offset(size.width * 0.10, size.height * 0.50),
        Offset(size.width * 0.90, size.height * 0.52),
        cx1: size.width * 0.35, cy1: size.height * 0.38,
        cx2: size.width * 0.65, cy2: size.height * 0.64,
      ),
    ];

    const perLine = 1.0 / 3;
    for (int i = 0; i < lines.length; i++) {
      final start = i * perLine;
      if (progress <= start) break;
      final t = ((progress - start) / perLine).clamp(0.0, 1.0);
      for (final m in lines[i].computeMetrics()) {
        canvas.drawPath(m.extractPath(0, m.length * t), paint);
      }
    }
  }

  Path _wobblyLine(Offset p1, Offset p2,
      {required double cx1, required double cy1,
      required double cx2, required double cy2}) {
    return Path()
      ..moveTo(p1.dx, p1.dy)
      ..cubicTo(cx1, cy1, cx2, cy2, p2.dx, p2.dy);
  }

  @override
  bool shouldRepaint(_ScribblePainter old) => old.progress != progress;
}

// ── Empty / upload state ──────────────────────────────────────────────────────

class _UploadEmptyState extends StatefulWidget {
  const _UploadEmptyState();

  @override
  State<_UploadEmptyState> createState() => _UploadEmptyStateState();
}

class _UploadEmptyStateState extends State<_UploadEmptyState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _float;

  @override
  void initState() {
    super.initState();
    _float = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Column(
      children: [
        AnimatedBuilder(
          animation: CurvedAnimation(parent: _float, curve: Curves.easeInOut),
          builder: (context, child) => Transform.translate(
            offset: Offset(0, -6 + _float.value * 12),
            child: child,
          ),
          child: const _UploadIllustration(),
        ),
        const SizedBox(height: EduSpacing.s6),
        Text(
          'No notes yet',
          style: tt.titleMedium?.copyWith(color: EduColors.textPrimary),
        ),
        const SizedBox(height: EduSpacing.s1),
        Text(
          'Upload a PDF, image, or doc\nand we\'ll organise it for you.',
          style: tt.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: EduSpacing.s5),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: EduColors.primary,
            foregroundColor: EduColors.textInverse,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            shape: const StadiumBorder(),
          ),
          onPressed: () {},
          icon: const Icon(Icons.upload_rounded, size: 18),
          label: Text(
            'Upload a note',
            style: tt.titleSmall?.copyWith(color: EduColors.textInverse),
          ),
        ),
      ],
    );
  }
}

// ── Upload illustration (dashed drop-zone card with icon) ─────────────────────

class _UploadIllustration extends StatelessWidget {
  const _UploadIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Back tinted card
          Transform.rotate(
            angle: 0.15,
            child: _TintCard(color: EduColors.accentTeal),
          ),
          Transform.rotate(
            angle: -0.10,
            child: _TintCard(color: EduColors.primaryLight),
          ),
          // Front dashed upload card
          CustomPaint(
            size: const Size(100, 120),
            painter: _DashedCardPainter(),
            child: SizedBox(
              width: 100,
              height: 120,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: EduColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.upload_rounded,
                      color: EduColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Drop here',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: EduColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Sparkles
          Positioned(
            top: 8,
            right: 12,
            child: _Sparkle(size: 10, color: EduColors.primary),
          ),
          Positioned(
            bottom: 16,
            left: 8,
            child: _Sparkle(size: 7, color: EduColors.accentGreen),
          ),
          Positioned(
            top: 28,
            left: 18,
            child: _Sparkle(size: 6, color: EduColors.star),
          ),
        ],
      ),
    );
  }
}

class _TintCard extends StatelessWidget {
  const _TintCard({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 120,
      decoration: BoxDecoration(
        color: color,
        borderRadius: EduRadius.borderLg,
        boxShadow: EduColors.shadowCard,
      ),
    );
  }
}

class _DashedCardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rr = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(20),
    );
    canvas.drawRRect(
      rr,
      Paint()..color = EduColors.surface,
    );

    const dashW = 6.0;
    const gap = 4.0;
    final paint = Paint()
      ..color = EduColors.primary.withValues(alpha: 0.45)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path()..addRRect(rr);
    final metrics = path.computeMetrics();
    for (final m in metrics) {
      double d = 0;
      while (d < m.length) {
        canvas.drawPath(
          m.extractPath(d, d + dashW),
          paint,
        );
        d += dashW + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedCardPainter old) => false;
}

// ── Upload chip (shown in header when notes exist) ────────────────────────────

class _UploadChip extends StatelessWidget {
  const _UploadChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: EduColors.primaryLight,
          borderRadius: EduRadius.borderPill,
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: EduColors.primary,
          ),
        ),
      ),
    );
  }
}

// ── Sparkle widget ────────────────────────────────────────────────────────────

class _Sparkle extends StatelessWidget {
  const _Sparkle({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: Size(size, size),
        painter: _SparkPainter(color: color),
      );
}

class _SparkPainter extends CustomPainter {
  const _SparkPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withValues(alpha: 0.7);
    final cx = size.width / 2;
    final cy = size.height / 2;
    final path = Path()
      ..moveTo(cx, 0)
      ..lineTo(cx + size.width * 0.15, cy)
      ..lineTo(size.width, cy)
      ..lineTo(cx + size.width * 0.15, cy + size.height * 0.15)
      ..lineTo(cx, size.height)
      ..lineTo(cx - size.width * 0.15, cy + size.height * 0.15)
      ..lineTo(0, cy)
      ..lineTo(cx - size.width * 0.15, cy)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SparkPainter old) => old.color != color;
}

// ── Thin accent line (matching other sections) ────────────────────────────────

class _ThinAccentLine extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height * 0.6)
        ..quadraticBezierTo(
            size.width * 0.30, size.height * 0.1,
            size.width * 0.62, size.height * 0.7)
        ..lineTo(size.width * 0.90, size.height * 0.3),
      Paint()
        ..color = EduColors.primary.withValues(alpha: 0.40)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ThinAccentLine old) => false;
}

