import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:modern_learner_production/features/app/presentation/widgets/main_layout.dart';
import 'package:modern_learner_production/features/explore/domain/entities/learning_subject.dart';
import 'package:modern_learner_production/features/explore/presentation/pages/explore_page.dart';
import 'package:modern_learner_production/features/explore/presentation/pages/learning_subject_detail_page.dart';
import 'package:modern_learner_production/features/home/domain/entities/achievement_entity.dart';
import 'package:modern_learner_production/features/home/presentation/pages/achievements_detail.dart';
import 'package:modern_learner_production/features/home/presentation/pages/achievements_page.dart';
import 'package:modern_learner_production/features/home/presentation/pages/home_page.dart';
import 'package:modern_learner_production/features/home/presentation/pages/view_profile_page.dart';
import 'package:modern_learner_production/features/profile/presentation/pages/profile_page.dart';
import 'package:modern_learner_production/features/progress/domain/entities/progress_course_selection.dart';
import 'package:modern_learner_production/features/progress/presentation/pages/progress_page.dart';

// ── Route paths ──────────────────────────────────────────────────────────────

abstract final class Routes {
  // Shell (bottom nav)
  static const home = '/';
  static const explore = '/explore';
  static const progress = '/progress';
  static const profile = '/profile';

  // Full-screen (no bottom nav)
  static const viewProfile = '/view-profile';
  static const achievements = '/achievements';
  static const achievementDetail = '/achievement-detail';
  static const learningSubjectDetail = '/learning-subject-detail';
}

// ── Router ───────────────────────────────────────────────────────────────────

abstract final class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: Routes.home,
    debugLogDiagnostics: false,
    routes: [
      // ── Full-screen (no bottom nav) ────────────────────────────────────────
      GoRoute(
        path: Routes.viewProfile,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            _slideUp(state.pageKey, const ViewProfilePage()),
      ),
      GoRoute(
        path: Routes.achievements,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            _slideUp(state.pageKey, const AchievementsPage()),
      ),
      GoRoute(
        path: Routes.achievementDetail,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => _slideUp(
          state.pageKey,
          AchievementsDetailPage(achievement: state.extra as AchievementEntity),
        ),
      ),
      GoRoute(
        path: Routes.learningSubjectDetail,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => _slideUp(
          state.pageKey,
          LearningSubjectDetailPage(subject: state.extra as LearningSubject),
        ),
      ),

      // ── Shell (bottom nav) ────────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) {
          int idx = 0;
          if (state.matchedLocation == Routes.explore) idx = 1;
          if (state.matchedLocation == Routes.progress) idx = 3;
          if (state.matchedLocation == Routes.profile) idx = 4;
          return MainLayout(currentIndex: idx, child: child);
        },
        routes: [
          GoRoute(
            path: Routes.home,
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: Routes.explore,
            builder: (context, state) => const ExplorePage(),
          ),
          GoRoute(
            path: Routes.profile,
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: Routes.progress,
            builder: (context, state) => ProgressPage(
              initialCourseSelection: state.extra is ProgressCourseSelection
                  ? state.extra as ProgressCourseSelection
                  : null,
            ),
          ),
        ],
      ),
    ],
  );

  static CustomTransitionPage<void> _slideUp(
    LocalKey key,
    Widget child,
  ) => CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
              .animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
          child: child,
        ),
  );
}
