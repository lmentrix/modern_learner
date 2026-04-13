import 'package:flutter/material.dart';

import 'package:modern_learner_production/core/theme/app_theme.dart';
import 'package:modern_learner_production/core/router/app_router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Modern Learner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: AppRouter.router,
    );
  }
}
