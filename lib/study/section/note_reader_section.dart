import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/study/model/study_models.dart';
import 'package:modern_learner_production/study/widgets/ai_action_bar.dart';
import 'package:modern_learner_production/study/widgets/ai_response_sheet.dart';
import 'package:modern_learner_production/theme/theme.dart';

class NoteReaderSection extends StatefulWidget {
  const NoteReaderSection({
    super.key,
    required this.note,
    required this.onClose,
  });

  final StudyNote note;
  final VoidCallback onClose;

  @override
  State<NoteReaderSection> createState() => _NoteReaderSectionState();
}

class _NoteReaderSectionState extends State<NoteReaderSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enterCtrl;
  late final Animation<Offset>   _enterSlide;
  late final Animation<double>   _enterFade;

  String _selectedText = '';
  bool   _showAiBar    = false;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    )..forward();
    _enterSlide = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
        .animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut));
    _enterFade = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    super.dispose();
  }

  void _onTextSelected(String text) {
    final t = text.trim();
    setState(() {
      _selectedText = t;
      _showAiBar    = t.isNotEmpty;
    });
  }

  void _onAiAction(AiAction action) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: AiResponseSheet(action: action, selectedText: _selectedText),
      ),
    ).then((_) => setState(() { _showAiBar = false; _selectedText = ''; }));
  }

  @override
  Widget build(BuildContext context) {
    final tagBg = Color(widget.note.tagColor);

    return FadeTransition(
      opacity: _enterFade,
      child: SlideTransition(
        position: _enterSlide,
        child: Scaffold(
          backgroundColor: const Color(0xFFFAF9F6),
          body: SafeArea(
            child: Column(
              children: [
                // ── Sketch top bar ─────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    EduSpacing.s4, EduSpacing.s3, EduSpacing.s4, 0,
                  ),
                  child: Row(
                    children: [
                      _SketchBackButton(onTap: widget.onClose),
                      const Spacer(),
                      _SketchSubjectTag(
                        subject: widget.note.subject,
                        color:   tagBg,
                      ),
                      const SizedBox(width: EduSpacing.s3),
                      _SketchMenuButton(),
                    ],
                  ),
                ),
                const SizedBox(height: EduSpacing.s5),

                // ── Scrollable paper content ───────────────────────────
                Expanded(
                  child: SelectionArea(
                    onSelectionChanged: (s) => _onTextSelected(s?.plainText ?? ''),
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          padding: EduSpacing.pagePadding,
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              // Meta row
                              Row(
                                children: [
                                  Icon(Icons.schedule_outlined,
                                      size: 13,
                                      color: EduColors.textSecondary.withValues(alpha: 0.70)),
                                  const SizedBox(width: 3),
                                  Text(
                                    '${widget.note.readMinutes} min read',
                                    style: GoogleFonts.caveat(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: EduColors.textSecondary),
                                  ),
                                  const SizedBox(width: EduSpacing.s4),
                                  Icon(Icons.calendar_today_outlined,
                                      size: 13,
                                      color: EduColors.textSecondary.withValues(alpha: 0.70)),
                                  const SizedBox(width: 3),
                                  Text(
                                    widget.note.createdAt,
                                    style: GoogleFonts.caveat(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: EduColors.textSecondary),
                                  ),
                                ],
                              ),
                              const SizedBox(height: EduSpacing.s4),

                              // Title
                              Text(
                                widget.note.title,
                                style: GoogleFonts.caveat(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1A1A2E),
                                  height: 1.15,
                                ),
                              ),

                              // Sketch underline beneath title
                              Padding(
                                padding: const EdgeInsets.only(top: 4, bottom: EduSpacing.s5),
                                child: CustomPaint(
                                  painter: _TitleUnderlinePainter(
                                      color: Color(widget.note.tagColor)),
                                  size: const Size(double.infinity, 8),
                                ),
                              ),

                              // AI hint callout (sketch style)
                              _SketchHintCallout(),
                              const SizedBox(height: EduSpacing.s6),

                              // Body
                              ..._buildBody(widget.note.body),

                              const SizedBox(height: 120),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── AI action bar ──────────────────────────────────────
                AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  child: _showAiBar
                      ? Padding(
                          padding: const EdgeInsets.only(
                              bottom: EduSpacing.s4, top: EduSpacing.s2),
                          child: AiActionBar(
                            selectedText: _selectedText,
                            onAction:     _onAiAction,
                            visible:      _showAiBar,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildBody(String body) {
    final lines   = body.split('\n');
    final widgets = <Widget>[];

    for (final line in lines) {
      if (line.startsWith('## ')) {
        // Section heading in Caveat
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: EduSpacing.s5, bottom: EduSpacing.s2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                line.substring(3),
                style: GoogleFonts.caveat(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 2),
              CustomPaint(
                painter: _SectionHeadingUnderline(),
                size: const Size(double.infinity, 4),
              ),
            ],
          ),
        ));
      } else if (line.startsWith('- **')) {
        final inner = line.substring(2);
        final parts = inner.split('**');
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: EduSpacing.s2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 8, right: 8),
                child: _InkBullet(filled: true),
              ),
              Expanded(
                child: Text.rich(TextSpan(children: [
                  if (parts.isNotEmpty)
                    TextSpan(
                      text: parts[0],
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700),
                    ),
                  if (parts.length > 1)
                    TextSpan(
                      text: parts[1],
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                ])),
              ),
            ],
          ),
        ));
      } else if (line.startsWith('- ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: EduSpacing.s2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 10, right: 8),
                child: _InkBullet(filled: false),
              ),
              Expanded(
                child: Text(
                  line.substring(2),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),
        ));
      } else if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: EduSpacing.s2));
      } else {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: EduSpacing.s3),
          child: Text(line, style: Theme.of(context).textTheme.bodyLarge),
        ));
      }
    }
    return widgets;
  }
}

// ── Sketch top-bar components ────────────────────────────────────────────────

class _SketchBackButton extends StatelessWidget {
  const _SketchBackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _SketchCircleBtnPainter(),
        child: const SizedBox(
          width: 40, height: 40,
          child: Icon(Icons.arrow_back_rounded,
              color: Color(0xFF1A1A2E), size: 20),
        ),
      ),
    );
  }
}

class _SketchMenuButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SketchCircleBtnPainter(),
      child: const SizedBox(
        width: 40, height: 40,
        child: Icon(Icons.more_vert_rounded,
            color: Color(0xFF1A1A2E), size: 20),
      ),
    );
  }
}

class _SketchCircleBtnPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    canvas.drawCircle(Offset(cx, cy), 19,
        Paint()..color = const Color(0xFFFEFCF5));
    canvas.drawCircle(Offset(cx, cy), 19,
        Paint()
          ..color = const Color(0xFF1A1A2E).withValues(alpha: 0.55)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke);
    canvas.drawCircle(Offset(cx + 0.8, cy + 1.0), 17,
        Paint()
          ..color = const Color(0xFF1A1A2E).withValues(alpha: 0.10)
          ..strokeWidth = 0.9
          ..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(_SketchCircleBtnPainter old) => false;
}

class _SketchSubjectTag extends StatelessWidget {
  const _SketchSubjectTag({required this.subject, required this.color});

  final String subject;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: color.withValues(alpha: 0.55), width: 1.3),
      ),
      child: Text(
        subject,
        style: GoogleFonts.caveat(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1A1A2E),
        ),
      ),
    );
  }
}

// ── Body helpers ─────────────────────────────────────────────────────────────

class _InkBullet extends StatelessWidget {
  const _InkBullet({required this.filled});

  final bool filled;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(8, 8),
      painter: _InkDotPainter(filled: filled),
    );
  }
}

class _InkDotPainter extends CustomPainter {
  const _InkDotPainter({required this.filled});

  final bool filled;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = filled
          ? EduColors.primary
          : const Color(0xFF1A1A2E).withValues(alpha: 0.45);
    if (filled) {
      canvas.drawCircle(Offset(size.width / 2, size.height / 2), 3.8, paint);
    } else {
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2), 3.0,
        paint..style = PaintingStyle.stroke ..strokeWidth = 1.4,
      );
    }
  }

  @override
  bool shouldRepaint(_InkDotPainter old) => old.filled != filled;
}

// ── AI hint callout (sketch style) ───────────────────────────────────────────

class _SketchHintCallout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: EduColors.primaryLight.withValues(alpha: 0.50),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: EduColors.primary.withValues(alpha: 0.28),
          width: 1.3,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.tips_and_updates_outlined,
              size: 16, color: EduColors.primary.withValues(alpha: 0.80)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Select any text to get an AI explanation, visualise it, or save a note.',
              style: GoogleFonts.caveat(
                fontSize: 15,
                color: EduColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Painters ─────────────────────────────────────────────────────────────────

class _TitleUnderlinePainter extends CustomPainter {
  const _TitleUnderlinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height * 0.6)
        ..quadraticBezierTo(
            size.width * 0.25, size.height * 0.1,
            size.width * 0.55, size.height * 0.8)
        ..quadraticBezierTo(
            size.width * 0.75, size.height * 1.2,
            size.width,        size.height * 0.5),
      Paint()
        ..color = color.withValues(alpha: 0.55)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_TitleUnderlinePainter old) => old.color != color;
}

class _SectionHeadingUnderline extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(0, 2)
        ..quadraticBezierTo(size.width * 0.3, 0, size.width * 0.6, 3)
        ..lineTo(size.width * 0.85, 1.5),
      Paint()
        ..color = EduColors.primary.withValues(alpha: 0.35)
        ..strokeWidth = 1.4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_SectionHeadingUnderline old) => false;
}
