import 'dart:async';
import 'dart:convert';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../l10n/app_localizations.dart';
import '../models/launch_paper.dart';
import 'digest_service.dart';
import 'settings_manager.dart';

/// Reads the notification that launched the app, if there was one.
typedef LaunchMessageReader = Future<LaunchPaper?> Function();

/// Every digest push on Android lands in this channel, app open or not: the
/// manifest names it as Firebase's default channel.
const digestChannelId = 'paper_digest';

/// High importance is what gives a banner; Firebase's own fallback channel is
/// default importance and only shows an icon. The name and description are what
/// Android settings list, in the user's language as of this process start.
AndroidNotificationChannel _digestChannel() {
  final l10n = lookupAppLocalizations(Locale(SettingsManager().userLanguage));
  return AndroidNotificationChannel(
    digestChannelId,
    l10n.digestSettingsDailyDigest,
    description: l10n.digestSettingsDailyDigestHint,
    importance: Importance.high,
  );
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background messages handled silently — tap opens app via onMessageOpenedApp
}

class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();
  PushNotificationService._internal();
  factory PushNotificationService() => _instance;

  /// Carries everything the payload knew, so the screen can render real content
  /// while the record is still in flight.
  static void Function(LaunchPaper paper)? onPaperOpen;

  bool _handlersRegistered = false;
  bool _launchMessageConsumed = false;

  final _local = FlutterLocalNotificationsPlugin();
  Future<void>? _localReady;

  /// Android shows nothing for a push that arrives while the app is open, so the
  /// app posts it itself. iOS already presents it (see
  /// setForegroundNotificationPresentationOptions in [init]) and posting it here
  /// too would show it twice.
  bool get _postsPushesWhileOpen =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

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
    // A notification the app posted itself while open, tapped after the app was
    // closed, is not read here: initialize() hands that tap to [openFromPayload]
    // already, and reading getNotificationAppLaunchDetails as well opened the
    // paper twice (seen on the Motorola, 2026-11-12).
    final message = await FirebaseMessaging.instance.getInitialMessage();
    if (message == null) return null;
    return _toLaunchPaper(message);
  }

  LaunchPaper? _toLaunchPaper(RemoteMessage message) =>
      LaunchPaper.fromPushData(
        message.data,
        notificationTitle: message.notification?.title,
      );

  LaunchPaper? _paperFromPayload(String? payload) {
    if (payload == null || payload.isEmpty) return null;
    try {
      return LaunchPaper.fromPushData(
          (jsonDecode(payload) as Map).cast<String, dynamic>());
    } catch (e) {
      debugPrint('[FCM] unreadable notification payload: $e');
      return null;
    }
  }

  Future<void> _ensureLocal() => _localReady ??= _initLocal();

  Future<void> _initLocal() async {
    try {
      await _local.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('ic_stat_nanosolve'),
        ),
        onDidReceiveNotificationResponse: (response) =>
            openFromPayload(response.payload),
      );
      await _local
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_digestChannel());
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack,
          reason: 'PushNotificationService local notifications init failed');
    }
  }

  /// A tap on a notification the app posted while open. Nothing opens until
  /// the user taps.
  @visibleForTesting
  void openFromPayload(String? payload) {
    final paper = _paperFromPayload(payload);
    if (paper != null) onPaperOpen?.call(paper);
  }

  /// Posts a push that arrived while the app was open, with the same title and
  /// text the system would have shown had the app been closed.
  @visibleForTesting
  Future<void> showWhileOpen(RemoteMessage message) async {
    final paper = _toLaunchPaper(message);
    if (paper == null) return;
    await _ensureLocal();
    final body = message.notification?.body ?? paper.perex;
    final channel = _digestChannel();
    await _local.show(
      id: paper.id.hashCode,
      title: message.notification?.title ?? paper.title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(body ?? ''),
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

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
      if (_postsPushesWhileOpen) {
        unawaited(_ensureLocal());
        FirebaseMessaging.onMessage.listen((msg) {
          debugPrint('[FCM] onMessage while open: ${msg.data['paper_id']}');
          unawaited(showWhileOpen(msg));
        });
      }
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
