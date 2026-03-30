import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/app/presentation/widgets/main_layout.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/progress/presentation/pages/progress_page.dart';

abstract final class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    routes: [
      // 使用 ShellRoute 确保底部导航栏只有一个实例
      ShellRoute(
        builder: (context, state, child) {
          // 根据当前路径确定选中的标签
          int currentIndex = 0;
          if (state.matchedLocation == '/progress') {
            currentIndex = 3;
          }
          return MainLayout(
            child: child,
            currentIndex: currentIndex,
          );
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomePage(),
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
