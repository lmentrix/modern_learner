import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:modern_learner_production/bottom_nav/bottom_navbar.dart';
import 'package:modern_learner_production/home/view/home_page.dart';
import 'package:modern_learner_production/profile/view/profile_page.dart';
import 'package:modern_learner_production/progress/view/progress_page.dart';
import 'package:modern_learner_production/study/view/study_page.dart';

// ── Route names ────────────────────────────────────────────────────────────
abstract final class AppRoutes {
  static const home = '/';
  static const study = '/study';
  static const mic = '/mic';
  static const progress = '/progress';
  static const profile = '/profile';
}

// ── Placeholder screens ────────────────────────────────────────────────────
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Text(label, style: Theme.of(context).textTheme.headlineMedium),
        ),
      );
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
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (_, __, shell) => _AppShell(navigationShell: shell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (_, __) => const HomePage(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: AppRoutes.study,
            builder: (_, __) => const StudyPage(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: AppRoutes.mic,
            builder: (_, __) => const _PlaceholderScreen(label: 'Mic'),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: AppRoutes.progress,
            builder: (_, __) => const ProgressPage(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: AppRoutes.profile,
            builder: (_, __) => const ProfilePage(),
          ),
        ]),
      ],
    ),
  ],
);
