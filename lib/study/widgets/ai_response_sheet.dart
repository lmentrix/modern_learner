import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/study/model/study_models.dart';
import 'package:modern_learner_production/theme/theme.dart';

class AiResponseSheet extends StatefulWidget {
  const AiResponseSheet({
    super.key,
    required this.action,
    required this.selectedText,
  });

  final AiAction action;
  final String selectedText;

  @override
  State<AiResponseSheet> createState() => _AiResponseSheetState();
}

class _AiResponseSheetState extends State<AiResponseSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _typeCtrl;
  late final Animation<int>      _charCount;

  String get _fullResponse => _responseFor(widget.action);

  @override
  void initState() {
    super.initState();
    _typeCtrl = AnimationController(
      vsync: this,
      duration: Duration(
          milliseconds: (_fullResponse.length * 16).clamp(700, 2800)),
    )..forward();
    _charCount = IntTween(begin: 0, end: _fullResponse.length)
        .animate(CurvedAnimation(parent: _typeCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _typeCtrl.dispose();
    super.dispose();
  }

  String _responseFor(AiAction action) {
    switch (action) {
      case AiAction.explain:
        return 'The selected passage explains a foundational concept in the topic. '
            'In simpler terms: the idea is that systems learn by adjusting internal parameters '
            'based on feedback from their output. Think of it like learning to ride a bike — '
            'each fall teaches your body a small correction until balance becomes automatic. '
            'The key insight is that no one programs the corrections explicitly; they emerge from the process itself.';
      case AiAction.imagine:
        return '🎨 Generating a visual representation...\n\n'
            'Imagine a glowing web of nodes arranged in columns. '
            'Light pulses travel left to right, growing brighter or dimmer at each node. '
            'Where pulses are strong they activate the next layer; where weak they fade. '
            'The final column lights up with the answer — shaped entirely by how the pulses flowed.';
      case AiAction.takeNote:
        return '📝 Note saved!\n\n'
            '"${widget.selectedText.length > 80 ? '${widget.selectedText.substring(0, 80)}...' : widget.selectedText}"\n\n'
            'Added to your notes with a highlight. You can review it in the Notes section.';
    }
  }

  IconData get _icon {
    switch (widget.action) {
      case AiAction.explain:  return Icons.auto_awesome_rounded;
      case AiAction.imagine:  return Icons.image_outlined;
      case AiAction.takeNote: return Icons.edit_note_rounded;
    }
  }

  String get _title {
    switch (widget.action) {
      case AiAction.explain:  return 'AI Explanation';
      case AiAction.imagine:  return 'Visual Concept';
      case AiAction.takeNote: return 'Note Saved';
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(
          EduSpacing.s6, EduSpacing.s4, EduSpacing.s6, EduSpacing.s8),
      decoration: const BoxDecoration(
        color: Color(0xFFFEFCF5),  // paper cream
        borderRadius: BorderRadius.vertical(top: EduRadius.xl),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sketch drag handle
          Center(
            child: CustomPaint(
              painter: _WobblyHandlePainter(),
              size: const Size(44, 6),
            ),
          ),
          const SizedBox(height: EduSpacing.s5),

          // Header row
          Row(
            children: [
              // Sketch icon badge
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: EduColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: EduColors.primary.withValues(alpha: 0.38),
                    width: 1.4,
                  ),
                ),
                child: Icon(_icon, color: EduColors.primary, size: 19),
              ),
              const SizedBox(width: EduSpacing.s3),
              Text(
                _title,
                style: GoogleFonts.caveat(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: EduSpacing.s4),

          // Selected text quote — sketch card style
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F0EB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF1A1A2E).withValues(alpha: 0.18),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 3, height: 36,
                  decoration: BoxDecoration(
                    color: EduColors.primary.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.selectedText.length > 60
                        ? '"${widget.selectedText.substring(0, 60)}…"'
                        : '"${widget.selectedText}"',
                    style: GoogleFonts.caveat(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: EduColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: EduSpacing.s5),

          // Typewriter response text
          AnimatedBuilder(
            animation: _charCount,
            builder: (context, _) {
              final visible = _fullResponse.substring(0, _charCount.value);
              return Text(visible, style: tt.bodyLarge);
            },
          ),
          const SizedBox(height: EduSpacing.s6),

          // Action buttons — sketch style
          Row(
            children: [
              Expanded(
                child: _SketchOutlineButton(
                  label: 'Dismiss',
                  icon:  Icons.close_rounded,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: EduSpacing.s3),
              Expanded(
                child: _SketchFilledButton(
                  label: 'Save',
                  icon:  Icons.bookmark_add_outlined,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Sketch buttons ────────────────────────────────────────────────────────────

class _SketchOutlineButton extends StatelessWidget {
  const _SketchOutlineButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: const Color(0xFFFEFCF5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.35),
            width: 1.4,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: EduColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.caveat(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: EduColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SketchFilledButton extends StatelessWidget {
  const _SketchFilledButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: EduColors.primary,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: EduColors.primary.withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(1, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.caveat(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Wobbly drag handle ────────────────────────────────────────────────────────

class _WobblyHandlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height * 0.5)
        ..quadraticBezierTo(
            size.width * 0.35, size.height * 0.1,
            size.width * 0.65, size.height * 0.8)
        ..lineTo(size.width, size.height * 0.4),
      Paint()
        ..color = const Color(0xFF1A1A2E).withValues(alpha: 0.22)
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_WobblyHandlePainter old) => false;
}
