import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:modern_learner_production/auth/view/auth_page.dart';
import 'package:modern_learner_production/bottom_nav/bottom_navbar.dart';
import 'package:modern_learner_production/home/view/home_page.dart';
import 'package:modern_learner_production/profile/view/profile_page.dart';
import 'package:modern_learner_production/progress/view/progress_page.dart';
import 'package:modern_learner_production/study/view/study_page.dart';
import 'package:modern_learner_production/voice/view/voice_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── Route names ────────────────────────────────────────────────────────────

abstract final class AppRoutes {
  static const auth = '/auth';
  static const home = '/';
  static const study = '/study';
  static const mic = '/mic';
  static const progress = '/progress';
  static const profile = '/profile';
}

// ── Auth-state listenable (drives GoRouter refresh on sign-in / sign-out) ──

class _AuthStateListenable extends ChangeNotifier {
  _AuthStateListenable() {
    _sub = Supabase.instance.client.auth.onAuthStateChange.listen(
      (_) => notifyListeners(),
    );
  }
  late final StreamSubscription<AuthState> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

// ── Shell with AppBottomNavBar ─────────────────────────────────────────────

class _AppShell extends StatelessWidget {
  const _AppShell({required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}

// ── Router ─────────────────────────────────────────────────────────────────

final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  debugLogDiagnostics: true,
  refreshListenable: _AuthStateListenable(),
  redirect: (context, state) {
    final session = Supabase.instance.client.auth.currentSession;
    final authenticated = session != null;
    final goingToAuth = state.matchedLocation == AppRoutes.auth;

    if (!authenticated && !goingToAuth) return AppRoutes.auth;
    if (authenticated && goingToAuth) return AppRoutes.home;
    return null;
  },
  routes: [
    // Auth route — lives outside the shell (no bottom nav bar)
    GoRoute(path: AppRoutes.auth, builder: (_, _) => const AuthPage()),

    // Main shell with bottom nav
    StatefulShellRoute.indexedStack(
      builder: (_, _, shell) => _AppShell(navigationShell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: AppRoutes.home, builder: (_, _) => const HomePage()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.study,
              builder: (_, _) => const StudyPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: AppRoutes.mic, builder: (_, _) => const VoicePage()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.progress,
              builder: (_, _) => const ProgressPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.profile,
              builder: (_, _) => const ProfilePage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
