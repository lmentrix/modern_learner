import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'app_router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Wrap with MultiBlocProvider once top-level BLoCs are added.
    // Example:
    //   return MultiBlocProvider(
    //     providers: [BlocProvider(create: (_) => getIt<AuthBloc>())],
    //     child: _router,
    //   );
    return MaterialApp.router(
      title: 'Modern Learner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: AppRouter.router,
    );
  }
}
