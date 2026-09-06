import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'digest_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background messages handled silently — tap opens app via onMessageOpenedApp
}

class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();
  PushNotificationService._internal();
  factory PushNotificationService() => _instance;

  // Navigator key set by caller (main.dart) so we can navigate from handler
  static void Function(String paperId)? onPaperOpen;

  bool _handlersRegistered = false;

  /// Register message listeners immediately on startup — must run before runApp
  /// so onMessageOpenedApp events are not missed when app resumes from background.
  void registerHandlers() {
    if (kIsWeb || _handlersRegistered) return;
    try {
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);
      FirebaseMessaging.onMessageOpenedApp.listen((msg) {
        debugPrint('[FCM] onMessageOpenedApp: ${msg.data}');
        _handleMessage(msg);
      });
      FirebaseMessaging.onMessage.listen(_handleMessage);
      _handlersRegistered = true;
      debugPrint('[FCM] handlers registered');
    } catch (e, stack) {
      // Visible in Crashlytics console even on builds with no debugger attached
      // (debugPrint alone was silently hiding this failure in production).
      FirebaseCrashlytics.instance.recordError(
        e,
        stack,
        reason: 'PushNotificationService.registerHandlers failed',
      );
    }
  }

  Future<void> init() async {
    if (kIsWeb) return;
    if (DigestService().getKeywords().isEmpty) return;

    try {
      registerHandlers();

      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      debugPrint('[FCM] Permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        await _registerToken();
      }

      // Tap on notification that launched app from terminated state
      final initial = await FirebaseMessaging.instance.getInitialMessage();
      if (initial != null) {
        debugPrint('[FCM] getInitialMessage: ${initial.data}');
        _handleMessage(initial);
      }
    } catch (e) {
      debugPrint('[FCM] init error: $e');
    }
  }

  Future<void> _registerToken() async {
    try {
      final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      debugPrint('[APNs] Raw token: $apnsToken');

      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        debugPrint('[FCM] Device token: $token');
        await DigestService().updateFcmToken(token);
      }
      // Refresh token when FCM rotates it
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        DigestService().updateFcmToken(newToken);
      });
    } catch (e) {
      debugPrint('[FCM] token error: $e');
    }
  }

  void _handleMessage(RemoteMessage message) {
    final paperId = message.data['paper_id'] as String?;
    if (paperId != null) {
      onPaperOpen?.call(paperId);
    }
  }

  @visibleForTesting
  static void simulateIncoming(String paperId) {
    onPaperOpen?.call(paperId);
  }

  static bool get isSupported => !kIsWeb;
}
