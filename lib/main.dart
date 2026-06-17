import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:modern_learner_production/global_bloc/bloc/global_bloc.dart';
import 'package:modern_learner_production/global_bloc/service/user_stats_service.dart';
import 'package:modern_learner_production/router/router.dart';
import 'package:modern_learner_production/theme/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['PUBLISHABLE_KEY']!,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final statsService = UserStatsService(Supabase.instance.client);

    return BlocProvider(
      create: (_) {
        final bloc = GlobalBloc(statsService: statsService);
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) {
          bloc.add(FetchUserStats(userId: session.user.id));
        }
        return bloc;
      },
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
