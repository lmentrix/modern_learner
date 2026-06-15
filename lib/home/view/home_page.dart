import 'package:flutter/material.dart';
import 'package:modern_learner_production/home/section/empty_notes_section.dart';
import 'package:modern_learner_production/home/section/header_section.dart';
import 'package:modern_learner_production/home/section/leaderboard_section.dart';
import 'package:modern_learner_production/home/section/quick_stats_section.dart';
import 'package:modern_learner_production/home/section/walking_scene_section.dart';
import 'package:modern_learner_production/theme/theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  // ── Entrance stagger ──────────────────────────────────────────────────────
  static const _sectionCount = 4;
  static const _staggerMs    = 120;
  static const _durationMs   = 420;

  late final List<AnimationController> _ctrls;
  late final List<Animation<double>>   _fades;
  late final List<Animation<Offset>>   _slides;
  final List<bool> _started = List.filled(_sectionCount, false);

  // ── Pull-to-refresh state ─────────────────────────────────────────────────

  /// Full height of the walking scene card (px).
  static const _sceneFullH = 192.0;

  /// Pull distance that unlocks a refresh.
  static const _threshold = 88.0;

  /// Maximum pull distance we track (clamped here so the card doesn't grow
  /// taller than _sceneFullH).
  static const _maxPull = 120.0;

  /// Raw pull offset 0 → _maxPull.  Drives the AnimatedContainer height.
  double _pullOffset = 0;

  bool _isRefreshing = false;

  /// While true the AnimatedContainer uses Duration.zero (instant tracking).
  /// While false it uses _collapseDuration (smooth snap-back / open).
  bool _isDragging = false;

  static const _collapseDuration = Duration(milliseconds: 280);

  // ── Computed scene height ─────────────────────────────────────────────────

  double get _sceneH =>
      (_pullOffset / _maxPull * _sceneFullH).clamp(0.0, _sceneFullH);

  // ── Init / dispose ────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    _ctrls = List.generate(
      _sectionCount,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: _durationMs),
      ),
    );
    _fades = _ctrls
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut))
        .toList();
    _slides = _ctrls
        .map(
          (c) => Tween<Offset>(
            begin: const Offset(0, 0.06),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: c, curve: Curves.easeOut)),
        )
        .toList();

    _launchEntrance();
  }

  void _launchEntrance() {
    for (var i = 0; i < _sectionCount; i++) {
      Future.delayed(Duration(milliseconds: _staggerMs * i), () {
        if (!mounted) return;
        setState(() => _started[i] = true);
        _ctrls[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls) { c.dispose(); }
    super.dispose();
  }

  // ── Scroll handler ────────────────────────────────────────────────────────

  bool _onScrollNotification(ScrollNotification n) {
    if (_isRefreshing) return false;

    if (n is ScrollStartNotification) {
      setState(() => _isDragging = true);
    }

    if (n is ScrollUpdateNotification) {
      final px = n.metrics.pixels;
      if (px < 0) {
        setState(() {
          _isDragging = true;
          _pullOffset  = (-px).clamp(0.0, _maxPull);
        });
      } else if (!_isDragging && _pullOffset > 0) {
        // Snapped back to normal scroll without releasing — reset immediately.
        setState(() => _pullOffset = 0);
      }
    }

    if (n is ScrollEndNotification) {
      // 1) Disable instant-tracking so the AnimatedContainer can animate.
      setState(() => _isDragging = false);

      if (_pullOffset >= _threshold) {
        _doRefresh();
      } else if (_pullOffset > 0) {
        // 2) Defer the height-to-0 change by one frame so the AnimatedContainer
        //    picks up _isDragging=false before the height target changes.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_isRefreshing) setState(() => _pullOffset = 0);
        });
      }
    }

    return false;
  }

  Future<void> _doRefresh() async {
    setState(() {
      _isRefreshing = true;
      _pullOffset   = _maxPull; // hold scene fully open during refresh
    });

    // Replace with a real data reload.
    await Future.delayed(const Duration(milliseconds: 1600));

    if (!mounted) return;
    setState(() => _isRefreshing = false);

    // Collapse after the isRefreshing=false rebuild lands.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _pullOffset = 0);
    });
  }

  // ── Entrance animation helper ─────────────────────────────────────────────

  Widget _wrap(int index, Widget child) => FadeTransition(
        opacity: _fades[index],
        child: SlideTransition(position: _slides[index], child: child),
      );

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EduColors.bg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Walking scene card ─────────────────────────────────────────
          // Lives in the normal layout flow — no Stack, no Positioned.
          // AnimatedContainer grows/shrinks as _sceneH changes.
          // duration=0 while finger is down (instant tracking),
          // duration=280ms after release (smooth snap-back or snap-open).
          AnimatedContainer(
            duration: _isDragging ? Duration.zero : _collapseDuration,
            curve: Curves.easeOut,
            height: _sceneH,
            // Clip prevents the WalkingSceneSection from overflowing
            // while the container is animating to/from 0.
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(),
            child: WalkingSceneSection(isRefreshing: _isRefreshing),
          ),

          // ── Scrollable content ─────────────────────────────────────────
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: _onScrollNotification,
              child: CustomScrollView(
                // AlwaysScrollableScrollPhysics fires ScrollUpdate with
                // negative pixels when the user over-pulls at the top,
                // even on Android.
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: _wrap(
                      0,
                      SafeArea(
                        bottom: false,
                        child: HeaderSection(animate: _started[0]),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(
                      child: SizedBox(height: EduSpacing.s8)),

                  SliverToBoxAdapter(
                    child: _wrap(1, QuickStatsSection(animate: _started[1])),
                  ),

                  const SliverToBoxAdapter(
                      child: SizedBox(height: EduSpacing.s8)),

                  SliverToBoxAdapter(
                    child: _wrap(2, LeaderboardSection(animate: _started[2])),
                  ),

                  const SliverToBoxAdapter(
                      child: SizedBox(height: EduSpacing.s8)),

                  SliverToBoxAdapter(
                    child: _wrap(3, const EmptyNotesSection()),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
