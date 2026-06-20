import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/home/model/home_models.dart';
import 'package:modern_learner_production/home/model/upload_model.dart';
import 'package:modern_learner_production/home/service/upload_service.dart';
import 'package:modern_learner_production/home/widgets/note_card.dart';
import 'package:modern_learner_production/theme/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── Section shell (stateful so it owns the notes list) ───────────────────────

class EmptyNotesSection extends StatefulWidget {
  const EmptyNotesSection({super.key});

  @override
  State<EmptyNotesSection> createState() => _EmptyNotesSectionState();
}

class _EmptyNotesSectionState extends State<EmptyNotesSection> {
  late final UploadService _service;
  List<NoteItem> _notes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _service = UploadService(Supabase.instance.client);
    _fetchFiles();
  }

  Future<void> _fetchFiles() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final models = await _service.fetchFiles(userId);
      if (mounted) {
        setState(() {
          _notes = models.map(_toNoteItem).toList();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  static NoteItem _toNoteItem(UploadedFileModel m) => NoteItem(
        id: m.id,
        title: m.title,
        fileType: _mapFileType(m.fileType),
        fileSize: m.fileSize,
        subject: m.subject,
        uploadedAt: _formatDate(m.uploadedAt),
        cardColor: m.cardColor,
      );

  static NoteFileType _mapFileType(UploadFileType t) => switch (t) {
        UploadFileType.pdf => NoteFileType.pdf,
        UploadFileType.image => NoteFileType.image,
        UploadFileType.doc => NoteFileType.doc,
        UploadFileType.other => NoteFileType.other,
      };

  static String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(dt.year, dt.month, dt.day);
    if (d == today) return 'Today';
    if (d == today.subtract(const Duration(days: 1))) return 'Yesterday';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}';
  }

  void _delete(NoteItem note) {
    _service.deleteFile(note.id).ignore();
    setState(() => _notes.remove(note));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }
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
    setState(() => _deleting.add(note.id));

    // Burst animation finishes inside _Swipeable._confirmDismiss; by the time
    // onDelete() is called the card has already visually vanished. Collapse row.
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _buildRemovedCard(note, animation),
      duration: const Duration(milliseconds: 400),
    );
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) widget.onDelete(note);
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
          accentColor: Color(note.cardColor),
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
    required this.accentColor,
    required this.onDelete,
    required this.child,
  });

  final Animation<double> animation;
  final bool isDeleting;
  final bool isLast;
  final Color accentColor;
  final VoidCallback onDelete;
  final Widget child;

  @override
  State<_Swipeable> createState() => _SwipeableState();
}

class _SwipeableState extends State<_Swipeable> with TickerProviderStateMixin {
  // Single controller drives the full burst sequence (0 → 1, 750 ms).
  AnimationController? _burst;

  Animation<double>? _cardScale;
  Animation<double>? _cardFade;
  Animation<double>? _cardRotate;

  @override
  void initState() {
    super.initState();

    final burst = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    _burst = burst;

    // Brief swell then elastic implode
    _cardScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.07), weight: 10),
      TweenSequenceItem(
        tween: Tween(begin: 1.07, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInBack)),
        weight: 90,
      ),
    ]).animate(CurvedAnimation(
      parent: burst,
      curve: const Interval(0.15, 0.72),
    ));

    _cardFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: burst, curve: const Interval(0.30, 0.72)),
    );

    _cardRotate = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.06), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.06, end: -0.04), weight: 50),
    ]).animate(CurvedAnimation(
      parent: burst,
      curve: const Interval(0.15, 0.70, curve: Curves.easeInOut),
    ));
  }

  @override
  void dispose() {
    _burst?.dispose();
    super.dispose();
  }

  Future<bool> _confirmDismiss(DismissDirection _) async {
    final burst = _burst;
    if (burst == null) { widget.onDelete(); return false; }
    HapticFeedback.mediumImpact();
    await burst.animateTo(0.72);
    HapticFeedback.lightImpact();
    await burst.animateTo(1.0);
    widget.onDelete();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final burst = _burst;
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
            background: _DeleteRevealPanel(accentColor: widget.accentColor),
            child: burst == null
                ? widget.child
                : AnimatedBuilder(
              animation: burst,
              builder: (context, child) {
                final t = burst.value;
                return Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // Burst FX layer (ripples, particles, sparkles)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: _BurstPainter(
                            progress: t,
                            accentColor: widget.accentColor,
                          ),
                        ),
                      ),
                    ),
                    // Card — scale + rotate + fade
                    Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..rotateZ(t > 0.15 ? (_cardRotate?.value ?? 0) : 0)
                        ..scale(
                          t > 0.15 ? (_cardScale?.value ?? 1.0) : 1.0,
                          t > 0.15 ? (_cardScale?.value ?? 1.0) : 1.0,
                        ),
                      child: Opacity(
                        opacity: t > 0.30
                            ? (_cardFade?.value ?? 1.0).clamp(0.0, 1.0)
                            : 1.0,
                        child: child,
                      ),
                    ),
                  ],
                );
              },
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Sketch eraser background painter ─────────────────────────────────────────
// Draws a light-red fill with a rough hand-drawn border.

// ── Delete reveal panel ───────────────────────────────────────────────────────

class _DeleteRevealPanel extends StatelessWidget {
  const _DeleteRevealPanel({required this.accentColor});
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor.withValues(alpha: 0.10),
            accentColor.withValues(alpha: 0.32),
          ],
        ),
        borderRadius: EduRadius.borderXl,
        border: Border.all(
          color: accentColor.withValues(alpha: 0.38),
          width: 1.4,
        ),
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(right: EduSpacing.s5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_delete_rounded,
                  size: 26, color: accentColor.withValues(alpha: 0.85)),
              const SizedBox(height: 4),
              Text(
                'delete',
                style: GoogleFonts.caveat(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: accentColor.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── BurstPainter ─────────────────────────────────────────────────────────────
// Three layered FX driven by a single 0→1 progress value:
//   Ripple rings    0.00 – 0.45
//   Paper particles 0.00 – 0.55
//   Sparkle glints  0.50 – 0.85

class _BurstPainter extends CustomPainter {
  _BurstPainter({required this.progress, required this.accentColor});

  final double progress;
  final Color accentColor;

  static final List<_ParticleDef> _particles = _buildParticles();
  static final List<_SparkleDef>  _sparkles  = _buildSparkles();

  static List<_ParticleDef> _buildParticles() {
    final rng = math.Random(7);
    return List.generate(16, (i) {
      final angle = (i / 16) * math.pi * 2 + rng.nextDouble() * 0.4;
      return _ParticleDef(
        angle: angle,
        dist:  70.0 + rng.nextDouble() * 60,
        size:  4.0  + rng.nextDouble() * 6,
        rot:   rng.nextDouble() * math.pi * 2,
        delay: rng.nextDouble() * 0.18,
      );
    });
  }

  static List<_SparkleDef> _buildSparkles() {
    final rng = math.Random(13);
    return List.generate(6, (i) {
      final angle = (i / 6) * math.pi * 2 + rng.nextDouble() * 0.5;
      return _SparkleDef(
        angle: angle,
        dist:  55.0 + rng.nextDouble() * 45,
        size:  6.0  + rng.nextDouble() * 8,
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final cx = size.width  / 2;
    final cy = size.height / 2;
    final center = Offset(cx, cy);

    // ── Ripple rings (0 → 0.45) ─────────────────────────────────────────
    final rippleT = (progress / 0.45).clamp(0.0, 1.0);
    for (int r = 0; r < 3; r++) {
      final delay = r * 0.22;
      final t = ((rippleT - delay) / (1.0 - delay)).clamp(0.0, 1.0);
      if (t <= 0) continue;
      canvas.drawCircle(
        center,
        t * (size.width * 0.62),
        Paint()
          ..color = accentColor.withValues(alpha: (1 - t) * 0.52)
          ..strokeWidth = 2.5 - t * 1.8
          ..style = PaintingStyle.stroke,
      );
    }

    // ── Paper-bit particles (0 → 0.55) ──────────────────────────────────
    final particleT = (progress / 0.55).clamp(0.0, 1.0);
    for (final p in _particles) {
      final t = ((particleT - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (t <= 0) continue;
      final eased = Curves.easeOut.transform(t);
      // Arc: gravity pulls bits slightly downward
      final dx = math.cos(p.angle) * p.dist * eased;
      final dy = math.sin(p.angle) * p.dist * eased + 16 * eased * eased;
      final alpha = (1.0 - Curves.easeIn.transform(t)) * 0.9;
      final half = p.size / 2;

      canvas.save();
      canvas.translate(cx + dx, cy + dy);
      canvas.rotate(p.rot + t * math.pi * 1.8);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-half, -half * 0.55, p.size, p.size * 0.55),
          const Radius.circular(2),
        ),
        Paint()..color = accentColor.withValues(alpha: alpha),
      );
      canvas.restore();
    }

    // ── Sparkle glints (0.50 → 0.85) ────────────────────────────────────
    final sparkT = ((progress - 0.50) / 0.35).clamp(0.0, 1.0);
    if (sparkT > 0) {
      for (final s in _sparkles) {
        final eased = Curves.easeOut.transform(sparkT);
        final dx = math.cos(s.angle) * s.dist * eased;
        final dy = math.sin(s.angle) * s.dist * eased;
        // Flash in (0→0.5) then out (0.5→1)
        final alpha = sparkT < 0.5 ? sparkT * 2 : (1 - sparkT) * 2;
        final sz = s.size * (0.5 + 0.5 * (1 - sparkT));
        _drawStar(canvas, Offset(cx + dx, cy + dy), sz,
            accentColor.withValues(alpha: alpha * 0.92));
      }
    }
  }

  void _drawStar(Canvas canvas, Offset c, double size, Color color) {
    final h = size / 2;
    final thin = h * 0.22;
    final path = Path()
      ..moveTo(c.dx,        c.dy - h)
      ..lineTo(c.dx + thin, c.dy - thin)
      ..lineTo(c.dx + h,    c.dy)
      ..lineTo(c.dx + thin, c.dy + thin)
      ..lineTo(c.dx,        c.dy + h)
      ..lineTo(c.dx - thin, c.dy + thin)
      ..lineTo(c.dx - h,    c.dy)
      ..lineTo(c.dx - thin, c.dy - thin)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_BurstPainter old) =>
      old.progress != progress || old.accentColor != accentColor;
}

class _ParticleDef {
  const _ParticleDef({
    required this.angle, required this.dist,
    required this.size,  required this.rot, required this.delay,
  });
  final double angle, dist, size, rot, delay;
}

class _SparkleDef {
  const _SparkleDef({required this.angle, required this.dist, required this.size});
  final double angle, dist, size;
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

