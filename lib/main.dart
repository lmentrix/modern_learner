import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:modern_learner_production/global_bloc/bloc/global_bloc.dart';
import 'package:modern_learner_production/router/router.dart';
import 'package:modern_learner_production/theme/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GlobalBloc(),
      child: MaterialApp.router(
        title: 'Modern Learner',
        debugShowCheckedModeBanner: false,
        theme: EduTheme.light,
        themeMode: ThemeMode.light,
        routerConfig: appRouter,
      ),
    );
  }
}
