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
import 'package:modern_learner_production/features/home/view/pages/home_page.dart';
import 'package:modern_learner_production/features/home/view/pages/view_profile_page.dart';
import 'package:modern_learner_production/features/profile/view/pages/profile_page.dart';
import 'package:modern_learner_production/features/progress/service/request/exercise_request.dart';
import 'package:modern_learner_production/features/progress/view/chapter_exercise_page.dart';
import 'package:modern_learner_production/features/progress/view/progress_page.dart';
import 'package:modern_learner_production/features/subscription/view/subscription_page.dart';

abstract final class Routes {
  static const home = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const explore = '/explore';
  static const progress = '/progress';
  static const profile = '/profile';

  static const viewProfile = '/view-profile';
  static const learningSubjectDetail = '/learning-subject-detail';
  static const createCourse = '/create-course';
  static const chapterExercise = '/chapter-exercise';
  static const subscriptionSuccess = '/subscription/success';
  static const subscriptionCancel = '/subscription/cancel';

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
        path: Routes.learningSubjectDetail,
        parentNavigatorKey: _rootNavigatorKey,
        redirect: (context, state) =>
            state.extra is! LearningSubject ? Routes.explore : null,
        pageBuilder: (context, state) => _slideUp(
          state.pageKey,
          LearningSubjectDetailPage(subject: state.extra as LearningSubject),
        ),
      ),
      GoRoute(
        path: Routes.createCourse,
        parentNavigatorKey: _rootNavigatorKey,
        redirect: (context, state) =>
            state.extra is! CreateCourseArgs ? Routes.explore : null,
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
        pageBuilder: (context, state) {
          final args = state.extra;
          return _slideUp(
            state.pageKey,
            args is ChapterExercisePageArgs
                ? ChapterExercisePage(args: args)
                : const _AutoPopPage(),
          );
        },
      ),

      // ── Shell (bottom nav) ──────────────────────────────────────────────────
      GoRoute(
        path: Routes.subscriptionSuccess,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            _slideUp(state.pageKey, const SubscriptionPage()),
      ),
      GoRoute(
        path: Routes.subscriptionCancel,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            _slideUp(state.pageKey, const SubscriptionPage()),
      ),
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

/// Shown when the exercise route is built without valid args (e.g. after a
/// hot reload that loses navigation state). Pops itself on the next frame so
/// the user lands back on the previous screen without seeing anything.
class _AutoPopPage extends StatefulWidget {
  const _AutoPopPage();

  @override
  State<_AutoPopPage> createState() => _AutoPopPageState();
}

class _AutoPopPageState extends State<_AutoPopPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && context.canPop()) context.pop();
    });
  }

  @override
  Widget build(BuildContext context) =>
      const Scaffold(backgroundColor: Color(0xFF0C0E17));
}
