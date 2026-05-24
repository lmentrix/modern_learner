import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:modern_learner_production/core/supabase/supabase_service.dart';
import 'package:modern_learner_production/features/profile/data/learning_activity_summary.dart';
import 'package:modern_learner_production/features/profile/data/profile_activity_day.dart';

const _table = 'learning_activity_days';

class LearningActivityService with WidgetsBindingObserver {
  LearningActivityService._();

  static final instance = LearningActivityService._();
  static const idleTimeout = Duration(minutes: 5);
  static const maxCollectableSegment = Duration(seconds: 90);

  final Map<String, int> _pendingSecondsByDate = {};
  StreamSubscription<dynamic>? _authSubscription;
  Timer? _flushTimer;
  DateTime? _lastTick;
  DateTime? _lastInteractionAt;
  int _activeSessionCount = 0;
  bool _isMonitoring = false;
  bool _isFlushing = false;
  bool _isAppActive = true;

  bool get isLearningSessionActive => _activeSessionCount > 0;

  void startMonitoring() {
    if (_isMonitoring) return;

    _isMonitoring = true;
    _isAppActive = true;
    _lastTick = null;
    _authSubscription = supabase.auth.onAuthStateChange.listen((_) {
      _pendingSecondsByDate.clear();
      _lastTick = _canCollect ? DateTime.now() : null;
      _lastInteractionAt = _canCollect ? DateTime.now() : null;
    });
    WidgetsBinding.instance.addObserver(this);
    _flushTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => unawaited(flushPending()),
    );
  }

  Future<void> stopMonitoring() async {
    if (!_isMonitoring) return;

    _collectElapsed(DateTime.now());
    _flushTimer?.cancel();
    _flushTimer = null;
    await _authSubscription?.cancel();
    _authSubscription = null;
    WidgetsBinding.instance.removeObserver(this);
    _isMonitoring = false;
    await flushPending();
  }

  void beginLearningSession() {
    _activeSessionCount++;
    markInteraction();
    _lastTick ??= _canCollect ? DateTime.now() : null;
  }

  Future<void> endLearningSession() async {
    if (_activeSessionCount <= 0) return;

    _collectElapsed(DateTime.now());
    _activeSessionCount--;
    if (_activeSessionCount == 0) {
      _lastTick = null;
      _lastInteractionAt = null;
      await flushPending();
    }
  }

  void markInteraction() {
    if (!_canCollect) return;

    final now = DateTime.now();
    _lastInteractionAt = now;
    _lastTick ??= now;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _isAppActive = true;
        _lastTick = _canCollect ? DateTime.now() : null;
        _lastInteractionAt = _canCollect ? DateTime.now() : null;
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _collectElapsed(DateTime.now());
        unawaited(flushPending());
        _isAppActive = false;
        _lastTick = null;
        break;
    }
  }

  Future<void> flushPending() async {
    if (_isFlushing) return;

    _collectElapsed(DateTime.now());
    if (_currentUserId == null) {
      _pendingSecondsByDate.clear();
      _lastTick = null;
      return;
    }
    if (_pendingSecondsByDate.isEmpty) return;

    _isFlushing = true;
    final snapshot = Map<String, int>.from(_pendingSecondsByDate);

    try {
      for (final entry in snapshot.entries) {
        if (entry.value <= 0) continue;

        await supabase.rpc(
          'record_learning_activity_seconds',
          params: {
            'p_activity_date': entry.key,
            'p_active_seconds': entry.value,
          },
        );

        final currentPending = _pendingSecondsByDate[entry.key] ?? 0;
        final remaining = currentPending - entry.value;
        if (remaining > 0) {
          _pendingSecondsByDate[entry.key] = remaining;
        } else {
          _pendingSecondsByDate.remove(entry.key);
        }
      }
    } finally {
      _isFlushing = false;
    }
  }

  Future<LearningActivitySummary> fetchCurrentWeek({DateTime? now}) async {
    final current = now ?? DateTime.now();
    final weekStart = DateTime(
      current.year,
      current.month,
      current.day,
    ).subtract(Duration(days: current.weekday - DateTime.monday));
    final weekEnd = weekStart.add(const Duration(days: 6));

    final baseDays = {
      for (var index = 0; index < 7; index++)
        _dateKey(weekStart.add(Duration(days: index))): ProfileActivityDay(
          label: LearningActivitySummary.weekdayLabel(
            weekStart.add(Duration(days: index)),
          ),
          minutes: 0,
          date: weekStart.add(Duration(days: index)),
        ),
    };

    final userId = _currentUserId;
    if (userId == null) {
      return LearningActivitySummary(
        days: baseDays.values.toList(growable: false),
        todayIndex: current.weekday - DateTime.monday,
      );
    }

    final rows = await supabase
        .from(_table)
        .select('activity_date, active_seconds')
        .eq('user_id', userId)
        .gte('activity_date', _dateKey(weekStart))
        .lte('activity_date', _dateKey(weekEnd))
        .order('activity_date');

    for (final row in rows) {
      final dateKey = row['activity_date'] as String?;
      if (dateKey == null || !baseDays.containsKey(dateKey)) continue;

      final date = DateTime.tryParse(dateKey);
      final seconds = (row['active_seconds'] as num?)?.toInt() ?? 0;
      baseDays[dateKey] = ProfileActivityDay(
        label: date == null
            ? baseDays[dateKey]!.label
            : LearningActivitySummary.weekdayLabel(date),
        minutes: (seconds / 60).round(),
        date: date ?? baseDays[dateKey]!.date,
      );
    }

    return LearningActivitySummary(
      days: baseDays.values.toList(growable: false),
      todayIndex: current.weekday - DateTime.monday,
    );
  }

  void _collectElapsed(DateTime now) {
    final start = _lastTick;
    if (start == null || !now.isAfter(start) || !_canCollect) return;

    final lastInteraction = _lastInteractionAt;
    if (lastInteraction == null ||
        now.difference(lastInteraction) > idleTimeout) {
      _lastTick = null;
      return;
    }

    final collectUntil = now.difference(start) > maxCollectableSegment
        ? start.add(maxCollectableSegment)
        : now;

    var cursor = start;
    while (cursor.isBefore(collectUntil)) {
      final nextDay = DateTime(cursor.year, cursor.month, cursor.day + 1);
      final segmentEnd = nextDay.isBefore(collectUntil)
          ? nextDay
          : collectUntil;
      final seconds = segmentEnd.difference(cursor).inSeconds;

      if (seconds > 0) {
        final key = _dateKey(cursor);
        _pendingSecondsByDate[key] =
            (_pendingSecondsByDate[key] ?? 0) + seconds;
      }

      cursor = segmentEnd;
    }

    _lastTick = now;
  }

  bool get _canCollect =>
      _isAppActive && _activeSessionCount > 0 && _currentUserId != null;

  String? get _currentUserId => supabase.auth.currentUser?.id;

  static String _dateKey(DateTime date) {
    final local = DateTime(date.year, date.month, date.day);
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }
}
