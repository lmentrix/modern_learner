import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:modern_learner_production/app/app.dart';
import 'package:modern_learner_production/core/constants/api_constants.dart';
import 'package:modern_learner_production/core/profile/local_profile_service.dart';
import 'package:modern_learner_production/features/cache/generation_cache.dart';
import 'package:modern_learner_production/features/profile/service/learning_activity_service.dart';
import 'package:modern_learner_production/features/progress/service/progress_preload_service.dart';
import 'package:modern_learner_production/features/push_notification/service/push_notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final pushNotificationService = PushNotificationService(
  FirebaseMessaging.instance,
  Logger(),
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('Flutter error: ${details.exception}');
    debugPrintStack(stackTrace: details.stack);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Uncaught platform error: $error');
    debugPrintStack(stackTrace: stack);
    return false;
  };

  await dotenv.load(fileName: '.env');

  await Firebase.initializeApp();

  await Supabase.initialize(
    url: ApiConstants.supabaseUrl,
    anonKey: ApiConstants.supabasePublishableKey,
  );

  await LocalProfileService.instance.init();
  LearningActivityService.instance.startMonitoring();
  await pushNotificationService.initialize();

  // Pre-warm the generation cache so the first chapter tap is instant.
  unawaited(GenerationCache.warmUp());

  // Pre-load roadmap + chapter subcontent from DB so the progress page renders
  // without a skeleton on first visit.
  unawaited(ProgressPreloadService.instance.preload());

  runApp(const App());
}
