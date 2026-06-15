import 'package:flutter/material.dart';
import 'package:modern_learner_production/study/data/study_data.dart';
import 'package:modern_learner_production/study/model/study_models.dart';
import 'package:modern_learner_production/study/widgets/note_card.dart';
import 'package:modern_learner_production/theme/theme.dart';

class NotesListSection extends StatefulWidget {
  const NotesListSection({
    super.key,
    required this.animate,
    required this.onNoteTap,
  });

  final bool animate;
  final ValueChanged<StudyNote> onNoteTap;

  @override
  State<NotesListSection> createState() => _NotesListSectionState();
}

class _NotesListSectionState extends State<NotesListSection>
    with TickerProviderStateMixin {
  late final List<AnimationController> _ctrls;
  late final List<Animation<double>> _fades;
  late final List<Animation<Offset>> _slides;

  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(
      mockNotes.length,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );
    _fades = _ctrls
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut))
        .toList();
    _slides = _ctrls
        .map((c) => Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
            .animate(CurvedAnimation(parent: c, curve: Curves.easeOut)))
        .toList();

    if (widget.animate) _stagger();
  }

  void _stagger() {
    for (var i = 0; i < _ctrls.length; i++) {
      Future.delayed(Duration(milliseconds: 100 * i), () {
        if (mounted) _ctrls[i].forward();
      });
    }
  }

  @override
  void didUpdateWidget(NotesListSection old) {
    super.didUpdateWidget(old);
    if (!old.animate && widget.animate) _stagger();
  }

  @override
  void dispose() {
    for (final c in _ctrls) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EduSpacing.pagePadding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('My Notes', style: tt.headlineSmall),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: EduColors.primaryLight,
                  borderRadius: EduRadius.borderPill,
                ),
                child: Text(
                  '${mockNotes.length} notes',
                  style: tt.labelLarge?.copyWith(color: EduColors.primary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: EduSpacing.s4),
        ...List.generate(mockNotes.length, (i) {
          final note = mockNotes[i];
          return FadeTransition(
            opacity: _fades[i],
            child: SlideTransition(
              position: _slides[i],
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  EduSpacing.s6, 0, EduSpacing.s6, EduSpacing.s4,
                ),
                child: NoteCard(note: note, onTap: () => widget.onNoteTap(note)),
              ),
            ),
          );
        }),
      ],
    );
  }
}
