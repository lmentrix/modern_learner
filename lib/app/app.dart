import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:modern_learner_production/core/di/injection.dart';
import 'package:modern_learner_production/core/router/app_router.dart';
import 'package:modern_learner_production/core/theme/app_theme.dart';
import 'package:modern_learner_production/features/home/presentation/bloc/achievement_bloc.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide the singleton AchievementBloc at the root so it is accessible
    // from both shell routes (MainLayout) and full-screen routes.
    return BlocProvider<AchievementBloc>.value(
      value: getIt<AchievementBloc>(),
      child: MaterialApp.router(
        title: 'Modern Learner',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        themeMode: ThemeMode.dark,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
