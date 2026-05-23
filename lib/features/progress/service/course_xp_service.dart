import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CourseXpData {
  const CourseXpData({
    this.exerciseXp = 0,
    this.exercisesCompleted = 0,
    this.chaptersUnlocked = 1,
  });

  factory CourseXpData.fromJson(Map<String, dynamic> json) {
    return CourseXpData(
      exerciseXp: (json['exerciseXp'] as num?)?.toInt() ?? 0,
      exercisesCompleted: (json['exercisesCompleted'] as num?)?.toInt() ?? 0,
      chaptersUnlocked: (json['chaptersUnlocked'] as num?)?.toInt() ?? 1,
    );
  }

  final int exerciseXp;
  final int exercisesCompleted;
  final int chaptersUnlocked;

  CourseXpData copyWith({
    int? exerciseXp,
    int? exercisesCompleted,
    int? chaptersUnlocked,
  }) {
    return CourseXpData(
      exerciseXp: exerciseXp ?? this.exerciseXp,
      exercisesCompleted: exercisesCompleted ?? this.exercisesCompleted,
      chaptersUnlocked: chaptersUnlocked ?? this.chaptersUnlocked,
    );
  }

  Map<String, dynamic> toJson() => {
    'exerciseXp': exerciseXp,
    'exercisesCompleted': exercisesCompleted,
    'chaptersUnlocked': chaptersUnlocked,
  };
}

class CourseXpService {
  CourseXpService._();
  static final CourseXpService instance = CourseXpService._();

  static const String _prefsKey = 'course_xp_data';

  SharedPreferences? _prefs;
  final Map<String, ValueNotifier<CourseXpData>> _notifiers = {};

  final ValueNotifier<int> totalExerciseXp = ValueNotifier(0);

  void inject(SharedPreferences prefs) {
    _prefs = prefs;
    _load();
  }

  void _load() {
    final raw = _prefs?.getString(_prefsKey);
    if (raw == null) return;

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      for (final entry in map.entries) {
        final data = CourseXpData.fromJson(entry.value as Map<String, dynamic>);
        _notifiers.putIfAbsent(entry.key, () => ValueNotifier(data)).value =
            data;
      }
      _recalcTotal();
    } catch (_) {}
  }

  int _readIntOrDefault(int Function() read, int fallback) {
    try {
      return read();
    } catch (_) {
      return fallback;
    }
  }

  CourseXpData _normalized(CourseXpData data) {
    return CourseXpData(
      exerciseXp: _readIntOrDefault(() => data.exerciseXp, 0),
      exercisesCompleted: _readIntOrDefault(() => data.exercisesCompleted, 0),
      chaptersUnlocked: _readIntOrDefault(() => data.chaptersUnlocked, 1),
    );
  }

  bool _needsNormalization(CourseXpData data) {
    try {
      data.exerciseXp;
      data.exercisesCompleted;
      data.chaptersUnlocked;
      return false;
    } catch (_) {
      return true;
    }
  }

  CourseXpData _valueFor(String courseKey) {
    final notifier = notifierFor(courseKey);
    return _normalized(notifier.value);
  }

  void _recalcTotal() {
    totalExerciseXp.value = _notifiers.values.fold(
      0,
      (sum, n) => sum + _normalized(n.value).exerciseXp,
    );
  }

  ValueNotifier<CourseXpData> notifierFor(String courseKey) {
    final notifier = _notifiers.putIfAbsent(
      courseKey,
      () => ValueNotifier(const CourseXpData()),
    );
    if (_needsNormalization(notifier.value)) {
      notifier.value = _normalized(notifier.value);
      _persist();
    }
    return notifier;
  }

  CourseXpData dataFor(String courseKey) {
    return _valueFor(courseKey);
  }

  void resetCourse(String courseKey) {
    notifierFor(courseKey).value = const CourseXpData();
    _recalcTotal();
    _persist();
  }

  void updateUnlockedLimit(String courseKey, int limit) {
    final notifier = notifierFor(courseKey);
    final data = _normalized(notifier.value);
    if (limit <= data.chaptersUnlocked) return;
    notifier.value = data.copyWith(chaptersUnlocked: limit);
    _persist();
  }

  void addXp(String courseKey, int amount) {
    final notifier = notifierFor(courseKey);
    final data = _normalized(notifier.value);
    notifier.value = data.copyWith(
      exerciseXp: data.exerciseXp + amount,
      exercisesCompleted: data.exercisesCompleted + 1,
    );
    _recalcTotal();
    _persist();
  }

  Future<void> _persist() async {
    final map = <String, dynamic>{};
    for (final entry in _notifiers.entries) {
      map[entry.key] = _normalized(entry.value.value).toJson();
    }
    await _prefs?.setString(_prefsKey, jsonEncode(map));
  }
}
