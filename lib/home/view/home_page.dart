import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modern_learner_production/bloc/global_bloc.dart';
import 'package:modern_learner_production/home/model/home_models.dart';
import 'package:modern_learner_production/home/section/empty_notes_section.dart';
import 'package:modern_learner_production/home/section/header_section.dart';
import 'package:modern_learner_production/home/section/leaderboard_section.dart';
import 'package:modern_learner_production/home/section/quick_stats_section.dart';
import 'package:modern_learner_production/home/section/walking_scene_section.dart';
import 'package:modern_learner_production/theme/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  static const _sectionCount = 4;
  static const _staggerMs = 120;
  static const _durationMs = 420;

  late final List<AnimationController> _ctrls;
  late final List<Animation<double>> _fades;
  late final List<Animation<Offset>> _slides;
  final List<bool> _started = List.filled(_sectionCount, false);

  static const _sceneFullH = 192.0;
  static const _threshold = 88.0;
  static const _maxPull = 120.0;

  double _pullOffset = 0;
  bool _isRefreshing = false;
  bool _isDragging = false;

  static const _collapseDuration = Duration(milliseconds: 280);

  double get _sceneH =>
      (_pullOffset / _maxPull * _sceneFullH).clamp(0.0, _sceneFullH);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

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

    _fetchStats();
    _launchEntrance();
  }

  void _fetchStats() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      context.read<GlobalBloc>().add(FetchGlobalStats(userId));
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<GlobalBloc>().add(RefreshGlobalStats());
    }
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
    WidgetsBinding.instance.removeObserver(this);
    for (final c in _ctrls) {
      c.dispose();
    }
    super.dispose();
  }

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
          _pullOffset = (-px).clamp(0.0, _maxPull);
        });
      } else if (!_isDragging && _pullOffset > 0) {
        setState(() => _pullOffset = 0);
      }
    }

    if (n is ScrollEndNotification) {
      setState(() => _isDragging = false);

      if (_pullOffset >= _threshold) {
        _doRefresh();
      } else if (_pullOffset > 0) {
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
      _pullOffset = _maxPull;
    });

    context.read<GlobalBloc>().add(RefreshGlobalStats());

    await context.read<GlobalBloc>().stream.firstWhere(
      (s) => s is GlobalLoaded || s is GlobalError,
    );

    if (!mounted) return;
    setState(() => _isRefreshing = false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _pullOffset = 0);
    });
  }

  Widget _wrap(int index, Widget child) => FadeTransition(
    opacity: _fades[index],
    child: SlideTransition(position: _slides[index], child: child),
  );

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GlobalBloc, GlobalState>(
      listener: (context, state) {
        if (state is GlobalError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: const Color(0xFFDC2626),
            ),
          );
        }
        if (state is GlobalLoaded) {
          context.read<GlobalBloc>().add(SaveGlobalStats());
        }
      },
      builder: (context, state) {
        final loaded = state is GlobalLoaded ? state : null;

        return Scaffold(
          backgroundColor: EduColors.bg,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AnimatedContainer(
                duration: _isDragging ? Duration.zero : _collapseDuration,
                curve: Curves.easeOut,
                height: _sceneH,
                clipBehavior: Clip.hardEdge,
                decoration: const BoxDecoration(),
                child: WalkingSceneSection(isRefreshing: _isRefreshing),
              ),

              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: _onScrollNotification,
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    slivers: [
                      SliverToBoxAdapter(
                        child: _wrap(
                          0,
                          SafeArea(
                            bottom: false,
                            child: HeaderSection(
                              animate: _started[0],
                              displayName: loaded?.displayName ?? '',
                              streak: loaded?.streak ?? 0,
                              xp: loaded?.xp ?? 0,
                              xpGoal: loaded?.xpGoal ?? 0,
                            ),
                          ),
                        ),
                      ),

                      const SliverToBoxAdapter(
                        child: SizedBox(height: EduSpacing.s8),
                      ),

                      SliverToBoxAdapter(
                        child: _wrap(
                          1,
                          QuickStatsSection(
                            animate: _started[1],
                            stats: [
                              QuickStat(
                                label: 'Lessons',
                                value: '${loaded?.lessons ?? 0}',
                                unit: 'completed',
                                iconData: 0xe80c,
                                cardColor: 0xFFBBF0D9,
                              ),
                              QuickStat(
                                label: 'Hours',
                                value: '${loaded?.hours ?? 0}',
                                unit: 'this month',
                                iconData: 0xe40c,
                                cardColor: 0xFFFDE68A,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SliverToBoxAdapter(
                        child: SizedBox(height: EduSpacing.s8),
                      ),

                      SliverToBoxAdapter(
                        child: _wrap(
                          2,
                          LeaderboardSection(animate: _started[2]),
                        ),
                      ),

                      const SliverToBoxAdapter(
                        child: SizedBox(height: EduSpacing.s8),
                      ),

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
      },
    );
  }
}
