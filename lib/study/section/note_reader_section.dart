import 'package:flutter/material.dart';
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
  // Entrance slide
  late final AnimationController _enterCtrl;
  late final Animation<Offset> _enterSlide;
  late final Animation<double> _enterFade;

  String _selectedText = '';
  bool _showAiBar = false;

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
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      setState(() { _showAiBar = false; _selectedText = ''; });
      return;
    }
    setState(() { _selectedText = trimmed; _showAiBar = true; });
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
    final tt = Theme.of(context).textTheme;
    final tagBg = Color(widget.note.tagColor);

    return FadeTransition(
      opacity: _enterFade,
      child: SlideTransition(
        position: _enterSlide,
        child: Scaffold(
          backgroundColor: EduColors.bg,
          body: SafeArea(
            child: Column(
              children: [
                // ── Top bar ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    EduSpacing.s4, EduSpacing.s3, EduSpacing.s4, 0,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: widget.onClose,
                        child: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: EduColors.surface,
                            shape: BoxShape.circle,
                            boxShadow: EduColors.shadowCard,
                          ),
                          child: const Icon(Icons.arrow_back_rounded,
                              color: EduColors.textPrimary, size: 20),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: tagBg,
                          borderRadius: EduRadius.borderPill,
                        ),
                        child: Text(widget.note.subject, style: tt.labelLarge),
                      ),
                      const SizedBox(width: EduSpacing.s3),
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: EduColors.surface,
                          shape: BoxShape.circle,
                          boxShadow: EduColors.shadowCard,
                        ),
                        child: const Icon(Icons.more_vert_rounded,
                            color: EduColors.textPrimary, size: 20),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: EduSpacing.s5),

                // ── Scrollable content ───────────────────────────────────
                Expanded(
                  child: SelectionArea(
                    onSelectionChanged: (selection) {
                      final text = selection?.plainText ?? '';
                      _onTextSelected(text);
                    },
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          padding: EduSpacing.pagePadding,
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              // Meta
                              Row(
                                children: [
                                  const Icon(Icons.schedule_rounded,
                                      size: 14, color: EduColors.textSecondary),
                                  const SizedBox(width: 4),
                                  Text('${widget.note.readMinutes} min read',
                                      style: tt.labelMedium),
                                  const SizedBox(width: EduSpacing.s4),
                                  const Icon(Icons.calendar_today_outlined,
                                      size: 14, color: EduColors.textSecondary),
                                  const SizedBox(width: 4),
                                  Text(widget.note.createdAt, style: tt.labelMedium),
                                ],
                              ),
                              const SizedBox(height: EduSpacing.s4),

                              // Title
                              Text(widget.note.title, style: tt.displaySmall),
                              const SizedBox(height: EduSpacing.s6),

                              // Select-to-highlight hint
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: EduColors.primaryLight.withValues(alpha: 0.6),
                                  borderRadius: EduRadius.borderMd,
                                  border: Border.all(
                                    color: EduColors.primary.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.tips_and_updates_outlined,
                                        size: 16, color: EduColors.primary),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Select any text to mark it, get an AI explanation, visualise it, or save a note.',
                                        style: tt.labelLarge?.copyWith(
                                            color: EduColors.primary),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: EduSpacing.s6),

                              // Body — render markdown headings inline
                              ..._buildBody(widget.note.body, tt),

                              const SizedBox(height: 120),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── AI action bar ────────────────────────────────────────
                AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  child: _showAiBar
                      ? Padding(
                          padding: const EdgeInsets.only(
                              bottom: EduSpacing.s4, top: EduSpacing.s2),
                          child: AiActionBar(
                            selectedText: _selectedText,
                            onAction: _onAiAction,
                            visible: _showAiBar,
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

  List<Widget> _buildBody(String body, TextTheme tt) {
    final lines = body.split('\n');
    final widgets = <Widget>[];
    for (final line in lines) {
      if (line.startsWith('## ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: EduSpacing.s5, bottom: EduSpacing.s2),
          child: Text(line.substring(3), style: tt.headlineSmall),
        ));
      } else if (line.startsWith('- **')) {
        // Bold bullet
        final inner = line.substring(2);
        final parts = inner.split('**');
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: EduSpacing.s2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 6, right: 8),
                child: Container(
                  width: 5, height: 5,
                  decoration: BoxDecoration(
                    color: EduColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Expanded(
                child: Text.rich(TextSpan(children: [
                  if (parts.isNotEmpty)
                    TextSpan(
                      text: parts[0],
                      style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  if (parts.length > 1)
                    TextSpan(text: parts[1], style: tt.bodyLarge),
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
              Padding(
                padding: const EdgeInsets.only(top: 8, right: 8),
                child: Container(
                  width: 4, height: 4,
                  decoration: BoxDecoration(
                    color: EduColors.textSecondary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Expanded(child: Text(line.substring(2), style: tt.bodyLarge)),
            ],
          ),
        ));
      } else if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: EduSpacing.s2));
      } else {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: EduSpacing.s3),
          child: Text(line, style: tt.bodyLarge),
        ));
      }
    }
    return widgets;
  }
}
