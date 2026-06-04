import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:modern_learner_production/features/achievement/data/achievemenet_data.dart';
import 'package:modern_learner_production/features/achievement/model/achievement_model.dart';
import 'package:modern_learner_production/features/achievement/service/achievement_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CourseXpData {
  const CourseXpData({
    this.exerciseXp = 0,
    this.exercisesCompleted = 0,
    this.chaptersUnlocked = 1,
    this.subcontentCompleted = const {},
    this.subcontentTotals = const {},
  });

  factory CourseXpData.fromJson(Map<String, dynamic> json) {
    return CourseXpData(
      exerciseXp: (json['exerciseXp'] as num?)?.toInt() ?? 0,
      exercisesCompleted: (json['exercisesCompleted'] as num?)?.toInt() ?? 0,
      chaptersUnlocked: (json['chaptersUnlocked'] as num?)?.toInt() ?? 1,
      subcontentCompleted: _intMapFromJson(json['subcontentCompleted']),
      subcontentTotals: _intMapFromJson(json['subcontentTotals']),
    );
  }

  final int exerciseXp;
  final int exercisesCompleted;
  final int chaptersUnlocked;

  /// Completed subcontent count per chapter — key: "ch{chapterNumber}".
  final Map<String, int> subcontentCompleted;

  /// Total subcontent count per chapter — key: "ch{chapterNumber}".
  final Map<String, int> subcontentTotals;

  /// Fractional progress (0.0–1.0) for [chapterNumber] based on subcontent.
  double subcontentProgressFor(int chapterNumber) {
    final key = 'ch$chapterNumber';
    final total = subcontentTotals[key] ?? 0;
    if (total == 0) return 0.0;
    return ((subcontentCompleted[key] ?? 0) / total).clamp(0.0, 1.0);
  }

  CourseXpData copyWith({
    int? exerciseXp,
    int? exercisesCompleted,
    int? chaptersUnlocked,
    Map<String, int>? subcontentCompleted,
    Map<String, int>? subcontentTotals,
  }) {
    return CourseXpData(
      exerciseXp: exerciseXp ?? this.exerciseXp,
      exercisesCompleted: exercisesCompleted ?? this.exercisesCompleted,
      chaptersUnlocked: chaptersUnlocked ?? this.chaptersUnlocked,
      subcontentCompleted: subcontentCompleted ?? this.subcontentCompleted,
      subcontentTotals: subcontentTotals ?? this.subcontentTotals,
    );
  }

  Map<String, dynamic> toJson() => {
    'exerciseXp': exerciseXp,
    'exercisesCompleted': exercisesCompleted,
    'chaptersUnlocked': chaptersUnlocked,
    'subcontentCompleted': subcontentCompleted,
    'subcontentTotals': subcontentTotals,
  };

  static Map<String, int> _intMapFromJson(dynamic raw) {
    if (raw is Map) {
      return {
        for (final e in raw.entries)
          e.key.toString(): (e.value as num?)?.toInt() ?? 0,
      };
    }
    return const {};
  }
}

class CourseXpService {
  CourseXpService._();
  static final CourseXpService instance = CourseXpService._();

  static const String _prefsKeyPrefix = 'course_xp_data';

  SharedPreferences? _prefs;
  String _userId = '';
  final Map<String, ValueNotifier<CourseXpData>> _notifiers = {};

  final ValueNotifier<int> totalExerciseXp = ValueNotifier(0);

  /// Increments every time [inject] is called so listeners always rebuild on
  /// user switch, even when [totalExerciseXp] stays at 0.
  final ValueNotifier<int> version = ValueNotifier(0);

  String get _prefsKey => '${_prefsKeyPrefix}_$_userId';

  Future<void> ensureInitializedForCurrentUser() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null || userId.isEmpty) return;
    if (_prefs != null && _userId == userId) return;
    final prefs = await SharedPreferences.getInstance();
    inject(prefs, userId: userId);
  }

  void inject(SharedPreferences prefs, {required String userId}) {
    _prefs = prefs;
    _userId = userId;
    _notifiers.clear();
    totalExerciseXp.value = 0;
    version.value++;
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
      subcontentCompleted: _readMapOrDefault(() => data.subcontentCompleted),
      subcontentTotals: _readMapOrDefault(() => data.subcontentTotals),
    );
  }

  bool _needsNormalization(CourseXpData data) {
    try {
      data.exerciseXp;
      data.exercisesCompleted;
      data.chaptersUnlocked;
      data.subcontentCompleted;
      data.subcontentTotals;
      return false;
    } catch (_) {
      return true;
    }
  }

  Map<String, int> _readMapOrDefault(Map<String, int>? Function() read) {
    try {
      return read() ?? const {};
    } catch (_) {
      return const {};
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

  Map<String, ValueNotifier<CourseXpData>> get courseNotifiers =>
      Map.unmodifiable(_notifiers);

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

  void removeCourse(String courseKey) {
    _notifiers.remove(courseKey)?.dispose();
    _courseIdByKey.remove(courseKey);
    _recalcTotal();
    _persist();
  }

  void updateUnlockedLimit(String courseKey, int limit) {
    final notifier = notifierFor(courseKey);
    final data = _normalized(notifier.value);
    if (limit <= data.chaptersUnlocked) return;
    notifier.value = data.copyWith(chaptersUnlocked: limit);
    _persist();
    _syncToSupabase();
  }

  void updateSubcontentProgress(
    String courseKey,
    int chapterNumber,
    int completed,
    int total,
  ) {
    final chKey = 'ch$chapterNumber';
    final notifier = notifierFor(courseKey);
    final data = _normalized(notifier.value);
    notifier.value = data.copyWith(
      subcontentCompleted: {...data.subcontentCompleted, chKey: completed},
      subcontentTotals: {...data.subcontentTotals, chKey: total},
    );
    _persist();
    _syncToSupabase();
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
    _syncToSupabase();
  }

  /// Public entry-point: call once on profile load to backfill any existing data.
  Future<void> syncToSupabase() => _syncToSupabase();

  Future<void> restoreFromSupabase() async {
    if (_userId.isEmpty) return;
    try {
      final rows = await AchievementService().getCourseXp(userId: _userId);
      var changed = false;
      for (final row in rows) {
        final subcontentCompleted = CourseXpData._intMapFromJson(
          row.metadata['subcontent_completed'],
        );
        final subcontentTotals = CourseXpData._intMapFromJson(
          row.metadata['subcontent_totals'],
        );
        final data = CourseXpData(
          exerciseXp: row.exerciseXp,
          exercisesCompleted: row.exercisesCompleted,
          chaptersUnlocked: row.chaptersUnlocked,
          subcontentCompleted: subcontentCompleted,
          subcontentTotals: subcontentTotals,
        );
        _notifiers.putIfAbsent(row.courseKey, () => ValueNotifier(data)).value =
            data;
        final courseId = row.courseId;
        if (courseId != null) {
          _courseIdByKey[row.courseKey] = courseId;
        }
        changed = true;
      }
      if (changed) {
        _recalcTotal();
        await _persist();
      }
    } catch (_) {}
  }

  final Map<String, String> _courseIdByKey = {};

  void setCourseId(String courseKey, String courseId) {
    _courseIdByKey[courseKey] = courseId;
  }

  Future<void> _syncToSupabase() async {
    if (_userId.isEmpty) return;
    try {
      final service = AchievementService();
      final courseXpList = _notifiers.entries
          .where((e) => _courseIdByKey[e.key] != null)
          .map((e) {
            final d = _normalized(e.value.value);
            return ProfileCourseXpModel(
              userId: _userId,
              courseKey: e.key,
              courseId: _courseIdByKey[e.key],
              exerciseXp: d.exerciseXp,
              exercisesCompleted: d.exercisesCompleted,
              chaptersUnlocked: d.chaptersUnlocked,
              metadata: {
                if (d.subcontentCompleted.isNotEmpty)
                  'subcontent_completed': d.subcontentCompleted,
                if (d.subcontentTotals.isNotEmpty)
                  'subcontent_totals': d.subcontentTotals,
              },
            );
          })
          .toList();

      final definitions = AchievementCatalogue.all
          .asMap()
          .entries
          .map(
            (e) => AchievementDefinitionModel.fromAchievement(
              achievement: e.value,
              sortOrder: e.key,
            ),
          )
          .toList();

      await service.syncProfileSnapshot(
        userId: _userId,
        definitions: definitions,
        courseXp: courseXpList,
      );
    } catch (_) {}
  }

  Future<void> _persist() async {
    final map = <String, dynamic>{};
    for (final entry in _notifiers.entries) {
      map[entry.key] = _normalized(entry.value.value).toJson();
    }
    await _prefs?.setString(_prefsKey, jsonEncode(map));
  }
}
