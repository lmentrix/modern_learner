import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:modern_learner_production/core/supabase/supabase_service.dart';
import 'package:modern_learner_production/features/progress/domain/entities/progress_course_selection.dart';
import 'package:modern_learner_production/features/progress/service/user_courses_service.dart';

/// Holds courses created from the Explore page and mirrors them to Supabase.
///
/// [courses] drives the Home page UI via [ValueNotifier]. All write operations
/// are optimistically applied to [courses] first, then persisted via
/// [UserCoursesService]. Automatically loads/clears on auth state changes.
class ExploreCoursesService {
  ExploreCoursesService._() {
    SupabaseService.authStateChanges.listen(_onAuthStateChange);
  }

  static final ExploreCoursesService instance = ExploreCoursesService._();

  void _onAuthStateChange(AuthState authState) {
    switch (authState.event) {
      case AuthChangeEvent.signedIn:
      case AuthChangeEvent.initialSession:
        loadCourses();
      case AuthChangeEvent.signedOut:
        courses.value = const [];
      default:
        break;
    }
  }

  final ValueNotifier<List<ProgressCourseSelection>> courses =
      ValueNotifier(const []);

  /// Injected after DI is ready. Safe to call before injection — Supabase
  /// operations simply no-op when [_remote] is null.
  UserCoursesService? _remote;

  void injectRemote(UserCoursesService service) => _remote = service;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Loads persisted courses from Supabase. Call once when the user is ready.
  Future<void> loadCourses() async {
    final fetched = await _remote?.fetchCourses() ?? [];
    if (fetched.isNotEmpty) courses.value = fetched;
  }

  Future<void> addCourse(ProgressCourseSelection course) async {
    final current = courses.value;
    final duplicate = current.any(
      (c) => c.title == course.title && c.topic == course.topic,
    );
    if (duplicate) return;

    courses.value = [course, ...current]; // optimistic
    await _remote?.upsertCourse(course);
  }

  Future<void> removeCourse(ProgressCourseSelection course) async {
    courses.value =
        courses.value.where((c) => c != course).toList(growable: false);
    await _remote?.deleteCourse(course);
  }
}
