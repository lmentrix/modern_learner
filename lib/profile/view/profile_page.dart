import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/auth/service/auth_service.dart';
import 'package:modern_learner_production/bloc/global_bloc.dart';
import 'package:modern_learner_production/profile/repo/streak_calculation.dart';
import 'package:modern_learner_production/profile/section/learning_activity_section.dart';
import 'package:modern_learner_production/profile/section/profile_header_section.dart';
import 'package:modern_learner_production/profile/section/settings_section.dart';
import 'package:modern_learner_production/profile/view/streak_calendar.dart';
import 'package:modern_learner_production/theme/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  static const _sectionCount = 3;
  static const _staggerMs = 130;
  static const _durationMs = 400;

  late final List<AnimationController> _ctrls;
  late final List<Animation<double>> _fades;
  late final List<Animation<Offset>> _slides;
  late final StreakCalculation _streakCalculation;
  Timer? _activitySyncTimer;
  int? _realOnlineStreak;
  bool _isSyncingStreak = false;
  bool _hasShownStreakCalendar = false;
  final List<bool> _started = List.filled(_sectionCount, false);

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
    _streakCalculation = StreakCalculation(Supabase.instance.client);
    _fetchLearningActivity();
    _startActivityMonitoring();
    _showStreakCalendarOnEntry();
    _launch();
  }

  String? get _userId => Supabase.instance.client.auth.currentUser?.id;

  void _fetchLearningActivity() {
    final userId = _userId;
    if (userId != null) {
      context.read<GlobalBloc>().add(LearningActivity(userId));
    }
  }

  void _startActivityMonitoring() {
    final userId = _userId;
    if (userId == null) return;

    context.read<GlobalBloc>().add(StartLearningActivityMonitoring(userId));
    _activitySyncTimer?.cancel();
    _activitySyncTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      context.read<GlobalBloc>().add(SyncLearningActivity(userId));
      _syncRealOnlineStreak(userId);
    });
  }

  Future<void> _syncRealOnlineStreak(String userId) async {
    if (_isSyncingStreak) return;
    _isSyncingStreak = true;
    try {
      final streak = await _streakCalculation.syncOnlineDayAndFetchStreak(
        userId: userId,
      );
      if (!mounted) return;
      setState(() => _realOnlineStreak = streak);
    } catch (error) {
      debugPrint('Failed to sync online streak: $error');
    } finally {
      _isSyncingStreak = false;
    }
  }

  void _showStreakCalendarOnEntry() {
    if (_hasShownStreakCalendar) return;
    _hasShownStreakCalendar = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userId = _userId;
      if (!mounted || userId == null) return;

      final streak = await showGeneralDialog<int>(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'Close streak calendar',
        barrierColor: Colors.black.withValues(alpha: 0.24),
        transitionDuration: const Duration(milliseconds: 260),
        pageBuilder: (dialogContext, _, _) {
          return StreakCalendarPage(userId: userId);
        },
      );
      if (!mounted || streak == null) return;
      setState(() => _realOnlineStreak = streak);
      context.read<GlobalBloc>().add(LearningActivity(userId));
    });
  }

  void _stopActivityMonitoring() {
    _activitySyncTimer?.cancel();
    _activitySyncTimer = null;
    final userId = _userId;
    if (userId != null) {
      context.read<GlobalBloc>().add(
        SyncLearningActivity(userId, stopTracking: true),
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startActivityMonitoring();
      return;
    }
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      _stopActivityMonitoring();
    }
  }

  void _launch() {
    for (var i = 0; i < _sectionCount; i++) {
      Future.delayed(Duration(milliseconds: _staggerMs * i), () {
        if (!mounted) return;
        setState(() => _started[i] = true);
        _ctrls[i].forward();
      });
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    WidgetsBinding.instance
      ..removeObserver(this)
      ..addObserver(this);
    _startActivityMonitoring();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopActivityMonitoring();
    for (final c in _ctrls) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Sign out?',
          style: GoogleFonts.caveat(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: EduColors.textPrimary,
          ),
        ),
        content: Text(
          'You will need to sign in again to continue.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: EduColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: EduColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Sign out',
              style: GoogleFonts.inter(
                color: const Color(0xFFDC2626),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await AuthService().signOut();
    }
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
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  EduSpacing.s6,
                  EduSpacing.s4,
                  EduSpacing.s6,
                  0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Profile',
                          style: GoogleFonts.caveat(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: EduColors.textPrimary,
                            height: 1.1,
                          ),
                        ),
                        CustomPaint(
                          painter: _PageTitleUnderline(),
                          size: const Size(80, 6),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _IconBtn(
                          icon: Icons.notifications_none_rounded,
                          onTap: () {},
                        ),
                        const SizedBox(width: EduSpacing.s2),
                        _IconBtn(icon: Icons.edit_outlined, onTap: () {}),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: EduSpacing.s6)),

          SliverToBoxAdapter(
            child: BlocBuilder<GlobalBloc, GlobalState>(
              builder: (context, state) {
                if (state case GlobalLoaded loaded) {
                  final initials = loaded.displayName.isNotEmpty
                      ? loaded.displayName
                            .split(' ')
                            .where((w) => w.isNotEmpty)
                            .map((w) => w[0])
                            .take(2)
                            .join()
                            .toUpperCase()
                      : '?';

                  return ProfileHeaderSection(
                    animate: _started[0],
                    level: loaded.level ?? 0,
                    xp: loaded.xp ?? 0,
                    xpGoal: loaded.xpGoal ?? 0,
                    streak: _realOnlineStreak ?? loaded.streak ?? 0,
                    lessonsCompleted: loaded.lessons ?? 0,
                    hoursStudied: loaded.hours ?? 0,
                    notesCount: loaded.notes ?? 0,
                    filesCount: loaded.files ?? 0,
                    displayName: loaded.displayName,
                    avatarInitials: initials,
                    joinedDate: loaded.joinDate ?? '',
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: EduSpacing.s8)),

          SliverToBoxAdapter(
            child: BlocBuilder<GlobalBloc, GlobalState>(
              builder: (context, state) {
                final loaded = state is GlobalLoaded ? state : null;

                return _wrap(
                  1,
                  LearningActivitySection(
                    animate: _started[1],
                    bestWeekDays: loaded?.bestWeekDays ?? 0,
                    thisWeekDays: loaded?.thisWeekDays ?? 0,
                    totalActiveDays: loaded?.totalActiveDays ?? 0,
                    activityDays: loaded?.activityDays ?? const [],
                    weeksTracked: loaded?.weeksTracked ?? 0,
                    todayActiveSeconds: loaded?.todayActiveSeconds ?? 0,
                    isTracking: loaded?.isActivityTracking ?? false,
                  ),
                );
              },
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: EduSpacing.s8)),

          SliverToBoxAdapter(
            child: _wrap(
              2,
              SettingsSection(animate: _started[2], onSignOut: _confirmSignOut),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _PageTitleUnderline extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = EduColors.primary.withValues(alpha: 0.65)
      ..strokeWidth = 2.3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height * 0.55)
        ..quadraticBezierTo(
          size.width * 0.32,
          size.height * 0.05,
          size.width * 0.68,
          size.height * 0.80,
        )
        ..lineTo(size.width, size.height * 0.30),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(1.5, size.height * 0.95)
        ..quadraticBezierTo(
          size.width * 0.38,
          size.height * 0.50,
          size.width * 0.72,
          size.height * 1.0,
        )
        ..lineTo(size.width, size.height * 0.70),
      paint
        ..color = EduColors.primary.withValues(alpha: 0.18)
        ..strokeWidth = 1.4,
    );
    // star decoration
    final cx = size.width + 8.0;
    final cy = size.height * 0.45;
    const r = 4.5;
    const inner = r * 0.42;
    final path = Path();
    for (var i = 0; i < 5; i++) {
      final oa = -math.pi / 2 + i * 2 * math.pi / 5;
      final ia = oa + math.pi / 5;
      final px = cx + r * math.cos(oa);
      final py = cy + r * math.sin(oa);
      final ix = cx + inner * math.cos(ia);
      final iy = cy + inner * math.sin(ia);
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
  bool shouldRepaint(_PageTitleUnderline old) => false;
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: EduColors.surface,
        shape: BoxShape.circle,
        boxShadow: EduColors.shadowCard,
      ),
      child: Icon(icon, color: EduColors.textPrimary, size: 20),
    ),
  );
}
