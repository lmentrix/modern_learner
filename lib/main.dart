import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:modern_learner_production/app/app.dart';
import 'package:modern_learner_production/core/constants/api_constants.dart';
import 'package:modern_learner_production/core/di/injection.dart'
    show configureDependencies, getIt;
import 'package:modern_learner_production/features/profile/service/learning_activity_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: ApiConstants.supabaseUrl,
    anonKey: ApiConstants.supabasePublishableKey,
  );

  await configureDependencies();
  await getIt.allReady();
  LearningActivityService.instance.startMonitoring();

  runApp(const App());
}
