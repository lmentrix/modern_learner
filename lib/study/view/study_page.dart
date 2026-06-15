import 'package:flutter/material.dart';
import 'package:modern_learner_production/study/model/study_models.dart';
import 'package:modern_learner_production/study/section/note_reader_section.dart';
import 'package:modern_learner_production/study/section/notes_list_section.dart';
import 'package:modern_learner_production/theme/theme.dart';

class StudyPage extends StatefulWidget {
  const StudyPage({super.key});

  @override
  State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> with TickerProviderStateMixin {
  static const _sectionCount = 2;
  static const _staggerMs = 120;
  static const _durationMs = 420;

  late final List<AnimationController> _entranceCtrls;
  late final List<Animation<double>> _fades;
  late final List<Animation<Offset>> _slides;
  final List<bool> _started = List.filled(_sectionCount, false);

  StudyNote? _openNote;

  @override
  void initState() {
    super.initState();
    _entranceCtrls = List.generate(
      _sectionCount,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: _durationMs),
      ),
    );
    _fades = _entranceCtrls
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut))
        .toList();
    _slides = _entranceCtrls
        .map((c) => Tween<Offset>(
              begin: const Offset(0, 0.06),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: c, curve: Curves.easeOut)))
        .toList();
    _launchEntrance();
  }

  void _launchEntrance() {
    for (var i = 0; i < _sectionCount; i++) {
      Future.delayed(Duration(milliseconds: _staggerMs * i), () {
        if (!mounted) return;
        setState(() => _started[i] = true);
        _entranceCtrls[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (final c in _entranceCtrls) { c.dispose(); }
    super.dispose();
  }

  Widget _wrap(int i, Widget child) => FadeTransition(
        opacity: _fades[i],
        child: SlideTransition(position: _slides[i], child: child),
      );

  @override
  Widget build(BuildContext context) {
    if (_openNote != null) {
      return NoteReaderSection(
        note: _openNote!,
        onClose: () => setState(() => _openNote = null),
      );
    }

    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: EduColors.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _wrap(
              0,
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    EduSpacing.s6, EduSpacing.s5, EduSpacing.s6, EduSpacing.s4,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Study', style: tt.displaySmall),
                                Text('Pick up where you left off.', style: tt.bodyMedium),
                              ],
                            ),
                          ),
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              color: EduColors.surface,
                              shape: BoxShape.circle,
                              boxShadow: EduColors.shadowCard,
                            ),
                            child: const Icon(Icons.search_rounded,
                                color: EduColors.textPrimary, size: 22),
                          ),
                        ],
                      ),
                      const SizedBox(height: EduSpacing.s5),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: ['All', 'ML', 'Philosophy', 'Biology']
                              .asMap()
                              .entries
                              .map((e) => Padding(
                                    padding: EdgeInsets.only(
                                        right: e.key < 3 ? EduSpacing.s2 : 0),
                                    child: _FilterChip(label: e.value, selected: e.key == 0),
                                  ))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: EduSpacing.s2)),

          SliverToBoxAdapter(
            child: _wrap(
              1,
              NotesListSection(
                animate: _started[1],
                onNoteTap: (note) => setState(() => _openNote = note),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? EduColors.primary : EduColors.surface,
        borderRadius: EduRadius.borderPill,
        boxShadow: selected ? EduColors.shadowFloat : EduColors.shadowCard,
      ),
      child: Text(
        label,
        style: tt.labelLarge?.copyWith(
          color: selected ? EduColors.textInverse : EduColors.textSecondary,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }
}
