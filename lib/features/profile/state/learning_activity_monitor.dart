import 'package:flutter/foundation.dart';
import 'package:modern_learner_production/features/profile/data/learning_activity_summary.dart';
import 'package:modern_learner_production/features/profile/service/learning_activity_service.dart';
import 'package:modern_learner_production/features/profile/service/streak_service.dart';

class LearningActivityMonitorState {
  const LearningActivityMonitorState({
    required this.summary,
    this.isLoading = false,
    this.error,
  });

  factory LearningActivityMonitorState.initial() {
    return LearningActivityMonitorState(
      summary: LearningActivitySummary.emptyForCurrentWeek(),
    );
  }

  final LearningActivitySummary summary;
  final bool isLoading;
  final Object? error;

  int get currentStreakDays => StreakService.instance.currentStreak.value;

  String get bestDayFormatted =>
      LearningActivitySummary.formatMinutes(summary.bestDayMinutes);

  LearningActivityMonitorState copyWith({
    LearningActivitySummary? summary,
    bool? isLoading,
    Object? error,
    bool clearError = false,
  }) {
    return LearningActivityMonitorState(
      summary: summary ?? this.summary,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class LearningActivityMonitor {
  LearningActivityMonitor._();

  static final LearningActivityMonitor instance = LearningActivityMonitor._();

  final ValueNotifier<LearningActivityMonitorState> state =
      ValueNotifier<LearningActivityMonitorState>(
        LearningActivityMonitorState.initial(),
      );

  int _requestToken = 0;

  Future<void> refresh() async {
    final token = ++_requestToken;
    state.value = state.value.copyWith(isLoading: true, clearError: true);

    try {
      await LearningActivityService.instance.flushPending();
      final results = await Future.wait([
        LearningActivityService.instance.fetchCurrentWeek(),
        StreakService.instance.fetchAndUpdate(),
      ]);
      if (token != _requestToken) return;

      state.value = LearningActivityMonitorState(
        summary: results[0] as LearningActivitySummary,
      );
    } catch (error) {
      if (token != _requestToken) return;

      state.value = state.value.copyWith(isLoading: false, error: error);
    }
  }
}
