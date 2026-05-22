import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:modern_learner_production/core/models/progress_course_selection.dart';
import 'package:modern_learner_production/core/router/go_router_refresh_stream.dart';
import 'package:modern_learner_production/features/app/presentation/widgets/main_layout.dart';
import 'package:modern_learner_production/features/auth/service/auth_service.dart';
import 'package:modern_learner_production/features/auth/view/pages/login_page.dart';
import 'package:modern_learner_production/features/auth/view/pages/signup_page.dart';
import 'package:modern_learner_production/features/explore/data/create_course_args.dart';
import 'package:modern_learner_production/features/explore/domain/entities/learning_subject.dart';
import 'package:modern_learner_production/features/explore/view/pages/create_course_page.dart';
import 'package:modern_learner_production/features/explore/view/pages/explore_page.dart';
import 'package:modern_learner_production/features/explore/view/pages/learning_subject_detail_page.dart';
import 'package:modern_learner_production/features/home/data/achievement_entity.dart';
import 'package:modern_learner_production/features/home/view/pages/achievements_detail.dart';
import 'package:modern_learner_production/features/home/view/pages/achievements_page.dart';
import 'package:modern_learner_production/features/home/view/pages/home_page.dart';
import 'package:modern_learner_production/features/home/view/pages/view_profile_page.dart';
import 'package:modern_learner_production/features/profile/view/pages/profile_page.dart';
import 'package:modern_learner_production/features/progress/service/request/exercise_request.dart';
import 'package:modern_learner_production/features/progress/view/chapter_exercise_page.dart';
import 'package:modern_learner_production/features/progress/view/progress_page.dart';

abstract final class Routes {
  static const home = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const explore = '/explore';
  static const progress = '/progress';
  static const profile = '/profile';

  static const viewProfile = '/view-profile';
  static const achievements = '/achievements';
  static const achievementDetail = '/achievement-detail';
  static const learningSubjectDetail = '/learning-subject-detail';
  static const createCourse = '/create-course';
  static const chapterExercise = '/chapter-exercise';

  static const _publicRoutes = {login, signup};
  static bool isPublic(String location) => _publicRoutes.contains(location);
}

abstract final class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final _refreshListenable = GoRouterRefreshStream(
    AuthService.instance.authStateChanges,
  );

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: Routes.home,
    debugLogDiagnostics: false,
    refreshListenable: _refreshListenable,
    redirect: (context, state) {
      final isAuthenticated = AuthService.instance.isAuthenticated;
      final isPublic = Routes.isPublic(state.matchedLocation);

      if (!isAuthenticated && !isPublic) return Routes.login;
      if (isAuthenticated && isPublic) return Routes.home;
      return null;
    },
    routes: [
      // ── Auth ────────────────────────────────────────────────────────────────
      GoRoute(
        path: Routes.login,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: Routes.signup,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SignupPage(),
      ),

      // ── Full-screen overlays ─────────────────────────────────────────────────
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
      GoRoute(
        path: Routes.createCourse,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final args = state.extra as CreateCourseArgs;
          return _slideUp(
            state.pageKey,
            CreateCoursePage(subject: args.subject, topic: args.topic),
          );
        },
      ),
      GoRoute(
        path: Routes.chapterExercise,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => _slideUp(
          state.pageKey,
          ChapterExercisePage(args: state.extra as ChapterExercisePageArgs),
        ),
      ),

      // ── Shell (bottom nav) ──────────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) {
          var idx = 0;
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
            builder: (context, state) => ProgressViewPage(
              initialCourseSelection: state.extra is ProgressCourseSelection
                  ? state.extra as ProgressCourseSelection
                  : null,
            ),
          ),
        ],
      ),
    ],
  );

  static CustomTransitionPage<void> _slideUp(LocalKey key, Widget child) =>
      CustomTransitionPage<void>(
        key: key,
        child: child,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            ),
      );
}
