import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../models/launch_paper.dart';
import 'digest_service.dart';

/// Reads the notification that launched the app, if there was one.
typedef LaunchMessageReader = Future<LaunchPaper?> Function();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background messages handled silently — tap opens app via onMessageOpenedApp
}

class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();
  PushNotificationService._internal();
  factory PushNotificationService() => _instance;

  // Navigator key set by caller (main.dart) so we can navigate from handler.
  /// Carries everything the payload knew, so the screen can render real content
  /// while the record is still in flight.
  static void Function(LaunchPaper paper)? onPaperOpen;

  bool _handlersRegistered = false;
  bool _launchMessageConsumed = false;

  /// Swapped in tests so the launch path can be exercised without Firebase.
  @visibleForTesting
  static LaunchMessageReader? launchMessageReaderOverride;

  @visibleForTesting
  void resetLaunchMessageForTesting() => _launchMessageConsumed = false;

  /// Reads the tap that launched the app and navigates.
  ///
  /// Called before `runApp`, not from [init]. It used to be the last statement
  /// of [init], which runs three seconds after startup and behind a permission
  /// prompt, an APNs token fetch, an FCM token fetch and a network POST — so a
  /// cold tap did not learn which paper it was for until all of that finished.
  /// It also sat below the keyword check at the top of [init], so a user who
  /// had saved no keywords got no navigation at all.
  Future<void> consumeLaunchMessage() async {
    if (kIsWeb || _launchMessageConsumed) return;
    _launchMessageConsumed = true;
    try {
      final read = launchMessageReaderOverride ?? _readInitialMessage;
      final paper = await read();
      if (paper != null) {
        debugPrint('[FCM] launch message: ${paper.id}');
        onPaperOpen?.call(paper);
      }
    } catch (e) {
      debugPrint('[FCM] launch message error: $e');
    }
  }

  Future<LaunchPaper?> _readInitialMessage() async {
    final message = await FirebaseMessaging.instance.getInitialMessage();
    if (message == null) return null;
    return _toLaunchPaper(message);
  }

  LaunchPaper? _toLaunchPaper(RemoteMessage message) =>
      LaunchPaper.fromPushData(
        message.data,
        notificationTitle: message.notification?.title,
      );

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

      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        await _registerToken();
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
    final paper = _toLaunchPaper(message);
    if (paper != null) onPaperOpen?.call(paper);
  }

  @visibleForTesting
  static void simulateIncoming(String paperId, {String? title, String? perex}) {
    onPaperOpen?.call(LaunchPaper(paperId, title, perex: perex));
  }

  static bool get isSupported => !kIsWeb;
}
