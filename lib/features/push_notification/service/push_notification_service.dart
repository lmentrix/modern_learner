import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/push_notification_model.dart';

/// Top-level background handler — must be a bare top-level function.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is already initialised in main(); no re-init needed here.
  Logger().i('[FCM] Background message: ${message.messageId}');
}

class PushNotificationService {
  PushNotificationService(this._messaging, this._logger);

  final FirebaseMessaging _messaging;
  final Logger _logger;

  final _localNotifications = FlutterLocalNotificationsPlugin();
  static const _channelId = 'course_created';
  static const _channelName = 'Course Created';
  int _notificationId = 0;
  bool _localReady = false;

  /// The resolved FCM registration token. Null until [initialize] completes.
  String? get token => _token;
  String? _token;

  /// Emits every foreground notification.
  Stream<PushNotificationModel> get onMessage =>
      FirebaseMessaging.onMessage.map(_fromRemoteMessage);

  /// Emits when the user taps a notification that was in the background.
  Stream<PushNotificationModel> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp.map(_fromRemoteMessage);

  // ---------------------------------------------------------------------------
  // Bootstrap
  // ---------------------------------------------------------------------------

  /// Call once after [Firebase.initializeApp()] in main / app bootstrap.
  Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    if (Platform.isAndroid) {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    await _initLocalNotifications();
    await _requestPermission();
    await _resolveToken();
    _listenTokenRefresh();
  }

  Future<void> _initLocalNotifications() async {
    try {
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const initSettings = InitializationSettings(android: androidSettings);
      await _localNotifications.initialize(initSettings);

      if (Platform.isAndroid) {
        await _localNotifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.createNotificationChannel(
              const AndroidNotificationChannel(
                _channelId,
                _channelName,
                importance: Importance.high,
              ),
            );
      }
      _localReady = true;
    } catch (e, st) {
      _logger.w(
        '[FCM] Local notifications init failed',
        error: e,
        stackTrace: st,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Course notifications
  // ---------------------------------------------------------------------------

  /// Shows a local notification when an achievement is unlocked.
  Future<void> notifyAchievementUnlocked({
    required String emoji,
    required String title,
    required String description,
  }) async {
    if (!_localReady) {
      _logger.w(
        '[FCM] Local notifications not ready — skipping achievement notification',
      );
      return;
    }
    try {
      const androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: 'Notifies when a new course is created',
        importance: Importance.max,
        priority: Priority.high,
      );
      const details = NotificationDetails(android: androidDetails);

      await _localNotifications.show(
        _notificationId++,
        '$emoji Achievement Unlocked!',
        '$title — $description',
        details,
      );
      _logger.i('[FCM] Achievement notification shown: $title');
    } catch (e, st) {
      _logger.w(
        '[FCM] Failed to show achievement notification',
        error: e,
        stackTrace: st,
      );
    }
  }

  /// Shows a local notification confirming a new voice lesson was created.
  Future<void> notifyNewVoiceLesson({
    required String language,
    required String difficulty,
  }) async {
    if (!_localReady) {
      _logger.w(
        '[FCM] Local notifications not ready — skipping voice lesson notification',
      );
      return;
    }
    try {
      const androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: 'Notifies when a new course is created',
        importance: Importance.high,
        priority: Priority.high,
      );
      const details = NotificationDetails(android: androidDetails);

      await _localNotifications.show(
        _notificationId++,
        '🎙️ Voice Lesson Created!',
        '$language · $difficulty is ready. Start speaking now.',
        details,
      );
      _logger.i(
        '[FCM] Local notification shown for new voice lesson: $language',
      );
    } catch (e, st) {
      _logger.w(
        '[FCM] Failed to show voice lesson notification',
        error: e,
        stackTrace: st,
      );
    }
  }

  /// Shows a local notification confirming a new course was created.
  Future<void> notifyNewCourse({
    required String title,
    required String topic,
  }) async {
    if (!_localReady) {
      _logger.w(
        '[FCM] Local notifications not ready — skipping course notification',
      );
      return;
    }
    try {
      const androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: 'Notifies when a new course is created',
        importance: Importance.high,
        priority: Priority.high,
      );
      const details = NotificationDetails(android: androidDetails);

      await _localNotifications.show(
        _notificationId++,
        '🎓 Course Created!',
        '$title · $topic is ready. Start learning now.',
        details,
      );
      _logger.i('[FCM] Local notification shown for new course: $title');
    } catch (e, st) {
      _logger.w(
        '[FCM] Failed to show course notification',
        error: e,
        stackTrace: st,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Permission
  // ---------------------------------------------------------------------------

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    _logger.i('[FCM] Permission: ${settings.authorizationStatus.name}');
  }

  // ---------------------------------------------------------------------------
  // Token — resolve once, persist to Supabase profiles, refresh on rotation
  // ---------------------------------------------------------------------------

  Future<void> _resolveToken() async {
    try {
      _token = await _messaging.getToken();
      _logger.i('[FCM] Token: $_token');
      await _persistToken(_token);
    } catch (e, st) {
      _logger.e('[FCM] Failed to get token', error: e, stackTrace: st);
    }
  }

  void _listenTokenRefresh() {
    _messaging.onTokenRefresh.listen((newToken) async {
      _token = newToken;
      _logger.i('[FCM] Token refreshed: $newToken');
      await _persistToken(newToken);
    });
  }

  /// Upserts the FCM token into the authenticated user's `profiles` row.
  Future<void> _persistToken(String? token) async {
    if (token == null) return;

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      _logger.w('[FCM] No authenticated user — skipping token persist');
      return;
    }

    try {
      await Supabase.instance.client
          .from('profiles')
          .update({'fcm_token': token})
          .eq('id', userId);
      _logger.i('[FCM] Token saved to Supabase profiles');
    } catch (e, st) {
      _logger.e('[FCM] Failed to persist token', error: e, stackTrace: st);
    }
  }

  // ---------------------------------------------------------------------------
  // Call after sign-in so the token is saved for the newly authenticated user
  // ---------------------------------------------------------------------------

  /// Re-saves the current token for a freshly signed-in user.
  /// Call this right after a successful Supabase sign-in.
  Future<void> onUserSignedIn() async {
    await _persistToken(_token ?? await _messaging.getToken());
  }

  /// Clears the FCM token from `profiles` on sign-out so stale tokens are not
  /// used to send notifications after the user logs out.
  Future<void> onUserSignedOut() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    try {
      await Supabase.instance.client
          .from('profiles')
          .update({'fcm_token': null})
          .eq('id', userId);
      _logger.i('[FCM] Token cleared from Supabase profiles');
    } catch (e, st) {
      _logger.e('[FCM] Failed to clear token', error: e, stackTrace: st);
    }
  }

  // ---------------------------------------------------------------------------
  // Terminated-state notification
  // ---------------------------------------------------------------------------

  /// Returns the notification that launched the app from a terminated state,
  /// or null if the app was opened normally.
  Future<PushNotificationModel?> getInitialMessage() async {
    final message = await _messaging.getInitialMessage();
    return message == null ? null : _fromRemoteMessage(message);
  }

  // ---------------------------------------------------------------------------
  // Topic subscriptions
  // ---------------------------------------------------------------------------

  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    _logger.i('[FCM] Subscribed to: $topic');
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    _logger.i('[FCM] Unsubscribed from: $topic');
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  PushNotificationModel _fromRemoteMessage(RemoteMessage message) {
    return PushNotificationModel(
      title: message.notification?.title ?? '',
      body: message.notification?.body ?? '',
      data: message.data,
      imageUrl:
          message.notification?.android?.imageUrl ??
          message.notification?.apple?.imageUrl,
      notificationId: message.messageId,
      channelId: message.notification?.android?.channelId,
    );
  }

  @visibleForTesting
  PushNotificationModel fromRemoteMessageForTest(RemoteMessage m) =>
      _fromRemoteMessage(m);
}
