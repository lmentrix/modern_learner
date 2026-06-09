import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logger/logger.dart';
import 'package:modern_learner_production/features/push_notification/service/push_notification_service.dart';

final pushNotificationService = PushNotificationService(
  FirebaseMessaging.instance,
  Logger(),
);
