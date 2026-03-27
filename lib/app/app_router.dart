import 'package:go_router/go_router.dart';

import '../features/home/presentation/pages/home_page.dart';

abstract final class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
    ],
  );
}
