import 'package:flutter/material.dart';
import 'package:modern_learner_production/progress/section/achievements_section.dart';
import 'package:modern_learner_production/progress/section/progress_header_section.dart';
import 'package:modern_learner_production/progress/section/saved_notes_section.dart';
import 'package:modern_learner_production/progress/section/skill_tree_section.dart';
import 'package:modern_learner_production/theme/theme.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage>
    with TickerProviderStateMixin {
  static const _sectionCount = 4;
  static const _staggerMs = 110;
  static const _durationMs = 400;

  late final List<AnimationController> _entranceCtrls;
  late final List<Animation<double>> _fades;
  late final List<Animation<Offset>> _slides;
  final List<bool> _started = List.filled(_sectionCount, false);

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
              begin: const Offset(0, 0.05),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: c, curve: Curves.easeOut)))
        .toList();
    _launch();
  }

  void _launch() {
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
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: EduColors.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Page header ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  EduSpacing.s6, EduSpacing.s5, EduSpacing.s6, EduSpacing.s5,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Progress', style: tt.displaySmall),
                          Text('Your learning journey so far.',
                              style: tt.bodyMedium),
                        ],
                      ),
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: EduColors.surface,
                        shape: BoxShape.circle,
                        boxShadow: EduColors.shadowCard,
                      ),
                      child: const Icon(Icons.share_outlined,
                          color: EduColors.textPrimary, size: 20),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── XP card ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _wrap(0, ProgressHeaderSection(animate: _started[0])),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: EduSpacing.s8)),

          // ── Skill tree ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _wrap(1, SkillTreeSection(animate: _started[1])),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: EduSpacing.s8)),

          // ── Achievements ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _wrap(2, AchievementsSection(animate: _started[2])),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: EduSpacing.s8)),

          // ── Saved notes ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _wrap(3, SavedNotesSection(animate: _started[3])),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
