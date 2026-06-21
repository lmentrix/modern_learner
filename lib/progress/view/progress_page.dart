import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/bloc/global_bloc.dart';
import 'package:modern_learner_production/progress/bloc/skill_tree_bloc.dart';
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
        .map(
          (c) => Tween<Offset>(
            begin: const Offset(0, 0.05),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: c, curve: Curves.easeOut)),
        )
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
    for (final c in _entranceCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _wrap(int i, Widget child) => FadeTransition(
    opacity: _fades[i],
    child: SlideTransition(position: _slides[i], child: child),
  );

  @override
  Widget build(BuildContext context) {
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
                  EduSpacing.s6,
                  EduSpacing.s5,
                  EduSpacing.s6,
                  EduSpacing.s5,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Progress',
                            style: GoogleFonts.caveat(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: EduColors.textPrimary,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          CustomPaint(
                            painter: _PageTitleUnderlinePainter(),
                            size: const Size(110, 6),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Your learning journey so far.',
                            style: GoogleFonts.caveat(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: EduColors.textSecondary,
                            ),
                          ),
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
                      child: const Icon(
                        Icons.share_outlined,
                        color: EduColors.textPrimary,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── XP card ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _wrap(
              0,
              BlocBuilder<GlobalBloc, GlobalState>(
                builder: (context, state) {
                  if (state case GlobalLoaded loaded) {
                    return ProgressHeaderSection(
                      animate: _started[0],
                      xp: loaded.xp ?? 0,
                      xpGoal: loaded.xpGoal ?? 0,
                      level: loaded.level ?? 0,
                      lessonsCompleted: loaded.lessons ?? 0,
                      hoursStudied: loaded.hours ?? 0,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: EduSpacing.s8)),

          // ── Skill tree ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _wrap(
              1,
              BlocBuilder<GlobalBloc, GlobalState>(
                builder: (ctx, globalState) {
                  if (globalState is! GlobalLoaded) {
                    return const SizedBox.shrink();
                  }
                  return BlocProvider(
                    create: (_) => SkillTreeBloc()..add(const FetchSkillTree()),
                    child: _SkillTreeRoot(
                      globalLoaded: globalState,
                      animate: _started[1],
                    ),
                  );
                },
              ),
            ),
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

class _SkillTreeRoot extends StatefulWidget {
  const _SkillTreeRoot({required this.globalLoaded, required this.animate});

  final GlobalLoaded globalLoaded;
  final bool animate;

  @override
  State<_SkillTreeRoot> createState() => _SkillTreeRootState();
}

class _SkillTreeRootState extends State<_SkillTreeRoot> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final gs = widget.globalLoaded;
      context.read<SkillTreeBloc>().add(
        EvaluateRequirements(
          gs.xp ?? 0,
          gs.level ?? 0,
          gs.lessons ?? 0,
          gs.hours ?? 0,
          gs.notes ?? 0,
          gs.files ?? 0,
          gs.streak ?? 0,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GlobalBloc, GlobalState>(
      listener: (context, state) {
        if (state is GlobalLoaded) {
          context.read<SkillTreeBloc>().add(
            EvaluateRequirements(
              state.xp ?? 0,
              state.level ?? 0,
              state.lessons ?? 0,
              state.hours ?? 0,
              state.notes ?? 0,
              state.files ?? 0,
              state.streak ?? 0,
            ),
          );
        }
      },
      child: BlocBuilder<SkillTreeBloc, SkillTreeState>(
        builder: (context, state) {
          if (state is SkillTreeLoaded) {
            return SkillTreeSection(
              animate: widget.animate,
              nodes: state.nodes,
              unlockedCount: state.unlockedCount,
              totalNodes: state.totalNodes,
            );
          }
          if (state is SkillTreeLoading) {
            return const SizedBox(
              height: 400,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ── Hand-drawn underline for page title ───────────────────────────────────────

class _PageTitleUnderlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final ul = Paint()
      ..color = EduColors.primary.withValues(alpha: 0.70)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    // Main wobble stroke
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height * 0.5)
        ..quadraticBezierTo(
          size.width * 0.32,
          size.height * 0.0,
          size.width * 0.68,
          size.height * 0.8,
        )
        ..lineTo(size.width, size.height * 0.3),
      ul,
    );
    // Shadow line
    canvas.drawPath(
      Path()
        ..moveTo(1.5, size.height * 0.9)
        ..quadraticBezierTo(
          size.width * 0.38,
          size.height * 0.4,
          size.width * 0.72,
          size.height * 1.0,
        )
        ..lineTo(size.width, size.height * 0.65),
      ul
        ..color = EduColors.primary.withValues(alpha: 0.20)
        ..strokeWidth = 1.5,
    );

    // Tiny decorative star at the end
    final cx = size.width + 8;
    final cy = size.height * 0.4;
    const r = 4.5;
    final inner = r * 0.42;
    final path = Path();
    for (var i = 0; i < 5; i++) {
      final outerAngle = -math.pi / 2 + i * 2 * math.pi / 5;
      final innerAngle = outerAngle + math.pi / 5;
      final px = cx + r * math.cos(outerAngle);
      final py = cy + r * math.sin(outerAngle);
      final ix = cx + inner * math.cos(innerAngle);
      final iy = cy + inner * math.sin(innerAngle);
      i == 0 ? path.moveTo(px, py) : path.lineTo(px, py);
      path.lineTo(ix, iy);
    }
    path.close();
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFF59E0B).withValues(alpha: 0.75)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_PageTitleUnderlinePainter old) => false;
}
