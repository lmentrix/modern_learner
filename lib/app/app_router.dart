import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:modern_learner_production/features/app/presentation/widgets/main_layout.dart';
import 'package:modern_learner_production/features/auth/presentation/pages/email_confirmation_page.dart';
import 'package:modern_learner_production/features/auth/presentation/pages/login_page.dart';
import 'package:modern_learner_production/features/auth/presentation/pages/register_page.dart';
import 'package:modern_learner_production/features/explore/presentation/pages/explore_page.dart';
import 'package:modern_learner_production/features/home/presentation/pages/home_page.dart';
import 'package:modern_learner_production/features/profile/presentation/pages/profile_page.dart';
import 'package:modern_learner_production/features/progress/presentation/pages/progress_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract final class AppRouter {
  static final _authNotifier = _AuthChangeNotifier();

  static final router = GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: false,
    refreshListenable: _authNotifier,
    redirect: (context, state) {
      final isSignedIn =
          Supabase.instance.client.auth.currentSession != null;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/email-confirm';

      if (!isSignedIn && !isAuthRoute) return '/login';
      if (isSignedIn && isAuthRoute) return '/';
      return null;
    },
    routes: [
      // ── Auth routes (no shell / bottom nav) ──────────────────────────────
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/email-confirm',
        builder: (context, state) => EmailConfirmationPage(
          email: state.extra as String? ?? '',
        ),
      ),

      // ── App routes (with bottom nav shell) ───────────────────────────────
      ShellRoute(
        builder: (context, state, child) {
          int currentIndex = 0;
          if (state.matchedLocation == '/explore') currentIndex = 1;
          if (state.matchedLocation == '/progress') currentIndex = 3;
          if (state.matchedLocation == '/profile') currentIndex = 4;
          return MainLayout(currentIndex: currentIndex, child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: '/explore',
            builder: (context, state) => const ExplorePage(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: '/progress',
            builder: (context, state) => const ProgressPage(),
          ),
        ],
      ),
    ],
  );
}

/// Notifies the router whenever the Supabase auth state changes so the
/// redirect logic reruns automatically after sign-in / sign-out.
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier() {
    Supabase.instance.client.auth.onAuthStateChange.listen((_) {
      notifyListeners();
    });
  }
}
