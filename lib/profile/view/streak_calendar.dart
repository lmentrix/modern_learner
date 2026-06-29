import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/profile/bloc/streak_calendar_bloc.dart';
import 'package:modern_learner_production/profile/model/streak_calendar.dart';
import 'package:modern_learner_production/profile/service/streak_calender.dart';
import 'package:modern_learner_production/theme/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StreakCalendarPage extends StatefulWidget {
  const StreakCalendarPage({super.key, required this.userId});

  final String userId;

  @override
  State<StreakCalendarPage> createState() => _StreakCalendarPageState();
}

class _StreakCalendarPageState extends State<StreakCalendarPage>
    with TickerProviderStateMixin {
  late final AnimationController _entryCtrl;
  late final AnimationController _fireCtrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _fireCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _fade = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));
    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _fireCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StreakCalendarBloc(
        service: StreakCalenderService(Supabase.instance.client),
      )..add(LoadStreakCalendar(userId: widget.userId)),
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = math.min(constraints.maxWidth - 32, 440.0);
              return Center(
                child: Material(
                  color: Colors.transparent,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: width,
                      maxHeight: constraints.maxHeight - 48,
                    ),
                    child: CustomPaint(
                      painter: _SketchPanelPainter(),
                      child: ClipRRect(
                        borderRadius: EduRadius.borderXl,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: EduColors.surface,
                            borderRadius: EduRadius.borderXl,
                            boxShadow: EduColors.shadowRaised,
                          ),
                          child:
                              BlocConsumer<
                                StreakCalendarBloc,
                                StreakCalendarState
                              >(
                                listener: (context, state) {
                                  if (state is StreakCalendarLoaded &&
                                      state.igniteLogo) {
                                    _fireCtrl
                                      ..reset()
                                      ..repeat();
                                  }
                                },
                                builder: (context, state) {
                                  return switch (state) {
                                    StreakCalendarLoading() ||
                                    StreakCalendarInitial() =>
                                      const _LoadingView(),
                                    StreakCalendarFailure(:final message) =>
                                      _FailureView(message: message),
                                    StreakCalendarLoaded() => _LoadedCalendar(
                                      state: state,
                                      userId: widget.userId,
                                      fireAnimation: _fireCtrl,
                                    ),
                                  };
                                },
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LoadedCalendar extends StatelessWidget {
  const _LoadedCalendar({
    required this.state,
    required this.userId,
    required this.fireAnimation,
  });

  final StreakCalendarLoaded state;
  final String userId;
  final Animation<double> fireAnimation;

  @override
  Widget build(BuildContext context) {
    final month = state.month;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CalendarHeader(
            month: month,
            ignite: state.igniteLogo,
            animation: fireAnimation,
          ),
          const SizedBox(height: EduSpacing.s5),
          _MonthControls(month: month.visibleMonth, userId: userId),
          const SizedBox(height: EduSpacing.s4),
          const _WeekdayRow(),
          const SizedBox(height: EduSpacing.s2),
          _CalendarGrid(
            days: month.days,
            selectedDay: state.selectedDay,
            isRefreshing: state.isRefreshing,
          ),
          const SizedBox(height: EduSpacing.s4),
          _SelectedDayPanel(day: state.selectedDay),
          const SizedBox(height: EduSpacing.s4),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(month.currentStreak),
              child: Text(
                'Keep learning',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader({
    required this.month,
    required this.ignite,
    required this.animation,
  });

  final StreakCalendarMonth month;
  final bool ignite;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedBuilder(
          animation: animation,
          builder: (context, _) => CustomPaint(
            painter: _FireBadgePainter(
              progress: animation.value,
              intense: ignite,
            ),
            child: const SizedBox(width: 72, height: 72),
          ),
        ),
        const SizedBox(width: EduSpacing.s4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${month.currentStreak}-day streak',
                style: GoogleFonts.caveat(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: EduColors.textPrimary,
                  height: 1,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                ignite
                    ? 'New streak lit today'
                    : '${month.activeDaysThisMonth} active days this month',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: ignite ? EduColors.star : EduColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MonthControls extends StatelessWidget {
  const _MonthControls({required this.month, required this.userId});

  final DateTime month;
  final String userId;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _RoundIconButton(
          icon: Icons.chevron_left_rounded,
          onTap: () => context.read<StreakCalendarBloc>().add(
            ChangeStreakCalendarMonth(userId: userId, monthDelta: -1),
          ),
        ),
        Expanded(
          child: Text(
            '${_monthNames[month.month - 1]} ${month.year}',
            textAlign: TextAlign.center,
            style: GoogleFonts.caveat(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: EduColors.textPrimary,
            ),
          ),
        ),
        _RoundIconButton(
          icon: Icons.chevron_right_rounded,
          onTap: () => context.read<StreakCalendarBloc>().add(
            ChangeStreakCalendarMonth(userId: userId, monthDelta: 1),
          ),
        ),
      ],
    );
  }
}

class _WeekdayRow extends StatelessWidget {
  const _WeekdayRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const ['M', 'T', 'W', 'T', 'F', 'S', 'S']
          .map(
            (day) => Expanded(
              child: Text(
                day,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: EduColors.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.days,
    required this.selectedDay,
    required this.isRefreshing,
  });

  final List<StreakCalendarDay> days;
  final StreakCalendarDay? selectedDay;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isRefreshing ? 0.45 : 1,
      duration: const Duration(milliseconds: 180),
      child: GridView.builder(
        itemCount: days.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          mainAxisSpacing: 7,
          crossAxisSpacing: 7,
          childAspectRatio: 0.92,
        ),
        itemBuilder: (context, index) {
          final day = days[index];
          final selected =
              selectedDay != null && _sameDate(selectedDay!.date, day.date);
          return _CalendarDayCell(day: day, selected: selected);
        },
      ),
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
  const _CalendarDayCell({required this.day, required this.selected});

  final StreakCalendarDay day;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          context.read<StreakCalendarBloc>().add(SelectStreakCalendarDay(day)),
      child: AnimatedScale(
        scale: selected ? 1.06 : 1,
        duration: const Duration(milliseconds: 170),
        curve: Curves.easeOut,
        child: CustomPaint(
          painter: _DayCellPainter(day: day, selected: selected),
          child: Center(
            child: Text(
              '${day.date.day}',
              style: GoogleFonts.caveat(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: day.isInMonth
                    ? EduColors.textPrimary
                    : EduColors.textSecondary.withValues(alpha: 0.45),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectedDayPanel extends StatelessWidget {
  const _SelectedDayPanel({required this.day});

  final StreakCalendarDay? day;

  @override
  Widget build(BuildContext context) {
    final selected = day;
    final title = selected == null
        ? 'Pick a day'
        : '${_monthNames[selected.date.month - 1]} ${selected.date.day}';
    final detail = selected == null
        ? 'Tap any calendar day to inspect its online streak activity.'
        : selected.isActive
        ? '${_minutesLabel(selected.activeSeconds)} online across ${selected.sessionsCount} session${selected.sessionsCount == 1 ? '' : 's'}.'
        : 'No online learning time recorded for this day.';

    return CustomPaint(
      painter: _MiniSketchPainter(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: EduColors.bg.withValues(alpha: 0.72),
          borderRadius: EduRadius.borderLg,
        ),
        child: Row(
          children: [
            Icon(
              selected?.isActive == true
                  ? Icons.local_fire_department_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected?.isActive == true
                  ? EduColors.star
                  : EduColors.textSecondary,
              size: 22,
            ),
            const SizedBox(width: EduSpacing.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.caveat(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: EduColors.textPrimary,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    detail,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: EduColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 360,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _FailureView extends StatelessWidget {
  const _FailureView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626)),
          const SizedBox(height: EduSpacing.s3),
          Text(
            'Could not load streak calendar',
            style: GoogleFonts.caveat(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: EduColors.textPrimary,
            ),
          ),
          const SizedBox(height: EduSpacing.s2),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: EduColors.textSecondary,
            ),
          ),
          const SizedBox(height: EduSpacing.s4),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: EduColors.primaryLight.withValues(alpha: 0.7),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: EduColors.textPrimary),
      ),
    );
  }
}

class _SketchPanelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = EduColors.primary.withValues(alpha: 0.28)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final rect = Rect.fromLTWH(5, 5, size.width - 10, size.height - 10);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, EduRadius.xl), paint);
    canvas.drawPath(
      Path()
        ..moveTo(28, 6)
        ..quadraticBezierTo(size.width * 0.52, 0, size.width - 28, 7),
      paint..color = EduColors.star.withValues(alpha: 0.24),
    );
  }

  @override
  bool shouldRepaint(_SketchPanelPainter oldDelegate) => false;
}

class _DayCellPainter extends CustomPainter {
  const _DayCellPainter({required this.day, required this.selected});

  final StreakCalendarDay day;
  final bool selected;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.42;
    final fill = switch (day.intensity) {
      0 =>
        day.isToday
            ? EduColors.primaryLight.withValues(alpha: 0.35)
            : EduColors.bg.withValues(alpha: day.isInMonth ? 0.72 : 0.28),
      1 => const Color(0xFFFFF1A8),
      2 => const Color(0xFFFDE68A),
      _ => const Color(0xFFFFC56E),
    };
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = fill
        ..style = PaintingStyle.fill,
    );

    final stroke = Paint()
      ..color =
          (selected
                  ? EduColors.textPrimary
                  : day.isStreakDay
                  ? EduColors.star
                  : EduColors.textSecondary)
              .withValues(alpha: selected || day.isStreakDay ? 0.72 : 0.18)
      ..strokeWidth = selected ? 2.2 : 1.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center.translate(0.4, -0.2), radius: radius),
      -math.pi * 0.7,
      math.pi * (selected ? 1.85 : 1.55),
      false,
      stroke,
    );
    if (day.isStreakDay) {
      canvas.drawCircle(
        Offset(size.width - 8, 8),
        2.5,
        Paint()
          ..color = EduColors.star
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(_DayCellPainter oldDelegate) =>
      oldDelegate.day != day || oldDelegate.selected != selected;
}

class _MiniSketchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(14, 4)
        ..quadraticBezierTo(size.width * 0.45, -2, size.width - 14, 5)
        ..moveTo(14, size.height - 4)
        ..quadraticBezierTo(
          size.width * 0.58,
          size.height + 1,
          size.width - 12,
          size.height - 5,
        ),
      Paint()
        ..color = EduColors.primary.withValues(alpha: 0.18)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_MiniSketchPainter oldDelegate) => false;
}

class _FireBadgePainter extends CustomPainter {
  const _FireBadgePainter({required this.progress, required this.intense});

  final double progress;
  final bool intense;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final pulse = math.sin(progress * math.pi * 2);
    final glow = Paint()
      ..color = EduColors.star.withValues(alpha: intense ? 0.28 : 0.14)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 30 + pulse * 2, glow);

    final sketch = Paint()
      ..color = EduColors.textPrimary.withValues(alpha: 0.76)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: 31),
      -0.6,
      math.pi * 1.72,
      false,
      sketch..color = EduColors.textPrimary.withValues(alpha: 0.16),
    );

    final flicker = intense ? math.sin(progress * math.pi * 6) * 1.4 : 0.0;
    final outer = Path()
      ..moveTo(36, 54)
      ..cubicTo(23, 49, 18, 38, 24, 28)
      ..cubicTo(27, 23, 29, 18, 28.7, 11)
      ..cubicTo(38 + flicker, 17, 42, 24, 41, 31)
      ..cubicTo(46, 28, 49, 23, 50, 18)
      ..cubicTo(59, 31, 54, 49, 36, 54)
      ..close();
    final inner = Path()
      ..moveTo(36, 48)
      ..cubicTo(29, 44, 29, 37, 33, 32)
      ..cubicTo(35, 29, 36, 26, 36, 22)
      ..cubicTo(44, 30, 45, 40, 36, 48)
      ..close();

    canvas.drawPath(
      outer,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFC857), Color(0xFFFF7A45)],
        ).createShader(const Rect.fromLTWH(16, 10, 42, 46))
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      inner,
      Paint()
        ..color = const Color(0xFFFFF1A8).withValues(alpha: 0.92)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      outer,
      sketch..color = EduColors.textPrimary.withValues(alpha: 0.72),
    );
    canvas.drawPath(
      inner,
      sketch
        ..color = EduColors.textPrimary.withValues(alpha: 0.22)
        ..strokeWidth = 1.3,
    );

    if (intense) {
      final emberPaint = Paint()
        ..color = const Color(0xFFFF7A45).withValues(alpha: 0.34)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(18, 18 + progress * 18), 1.6, emberPaint);
      canvas.drawCircle(Offset(57, 24 + pulse * 8), 1.2, emberPaint);
    }
  }

  @override
  bool shouldRepaint(_FireBadgePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.intense != intense;
}

const _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

bool _sameDate(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String _minutesLabel(int seconds) {
  if (seconds < 60) return '$seconds sec';
  final minutes = (seconds / 60).round();
  return '$minutes min';
}
