import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:modern_learner_production/core/models/progress_course_selection.dart';

class UserCoursesService {
  const UserCoursesService({
    required SharedPreferences sharedPreferences,
    required String userId,
  }) : _sharedPreferences = sharedPreferences,
       _userId = userId;

  static const _storageKeyPrefix = 'local_progress_courses';

  final SharedPreferences _sharedPreferences;
  final String _userId;

  String get _storageKey => '${_storageKeyPrefix}_$_userId';

  Future<List<ProgressCourseSelection>> fetchCourses() async {
    return _readCourses();
  }

  Future<void> upsertCourse(ProgressCourseSelection course) async {
    final courses = await _readCourses();
    final index = courses.indexWhere((saved) => _matches(saved, course));

    if (index >= 0) {
      courses[index] = course;
    } else {
      courses.insert(0, course);
    }

    await _writeCourses(courses);
  }

  Future<void> deleteCourse(ProgressCourseSelection course) async {
    final courses = await _readCourses();
    courses.removeWhere((saved) => _matches(saved, course));
    await _writeCourses(courses);
  }

  Future<void> deleteAllCourses() async {
    await _sharedPreferences.remove(_storageKey);
  }

  Future<List<ProgressCourseSelection>> _readCourses() async {
    final raw = _sharedPreferences.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return [];
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(_courseFromJson)
        .toList(growable: true);
  }

  Future<void> _writeCourses(List<ProgressCourseSelection> courses) async {
    final payload = courses.map(_courseToJson).toList(growable: false);
    await _sharedPreferences.setString(_storageKey, jsonEncode(payload));
  }

  Map<String, dynamic> _courseToJson(ProgressCourseSelection course) {
    return {
      'title': course.title,
      'topic': course.topic,
      'roadmapLanguage': course.roadmapLanguage,
      'level': course.level,
      'nativeLanguage': course.nativeLanguage,
      'roadmapJson': course.roadmapJson,
      'roadmapGenerated': course.roadmapGenerated,
      'courseType': course.courseType.name,
    };
  }

  ProgressCourseSelection _courseFromJson(Map<String, dynamic> json) {
    return ProgressCourseSelection(
      title: json['title'] as String? ?? '',
      topic: json['topic'] as String? ?? '',
      roadmapLanguage: json['roadmapLanguage'] as String? ?? '',
      level: json['level'] as String? ?? '',
      nativeLanguage: json['nativeLanguage'] as String? ?? '',
      roadmapJson: json['roadmapJson'] is Map
          ? Map<String, dynamic>.from(json['roadmapJson'] as Map)
          : null,
      roadmapGenerated: json['roadmapGenerated'] as bool? ?? false,
      courseType: _courseTypeFromName(json['courseType'] as String?),
    );
  }

  ProgressCourseType _courseTypeFromName(String? name) {
    return ProgressCourseType.values.firstWhere(
      (value) => value.name == name,
      orElse: () => ProgressCourseType.school,
    );
  }

  bool _matches(ProgressCourseSelection left, ProgressCourseSelection right) {
    return left.title == right.title &&
        left.topic == right.topic &&
        left.level == right.level &&
        left.nativeLanguage == right.nativeLanguage;
  }
}
