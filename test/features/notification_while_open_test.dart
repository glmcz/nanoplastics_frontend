// Android-only path: posting a push that arrives while the app is open.
@TestOn('vm')
library;

import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/models/launch_paper.dart';
import 'package:nanoplastics_app/services/push_notification_service.dart';
import 'package:nanoplastics_app/services/settings_manager.dart';
import '../helpers/settings_test_helper.dart';

const _channel = MethodChannel('dexterous.com/flutter/local_notifications');

const _push = RemoteMessage(
  notification: RemoteNotification(
    title: 'Neurotoxicity of microplastics in zebrafish',
    body: 'Fibres harmed neurodevelopment more than spheres.',
  ),
  data: {
    'paper_id': '60e7c550-6533-4535-9556-6f7003f775c0',
    'type': 'digest',
    'title': 'Neurotoxicity of microplastics in zebrafish',
    'perex': 'Fibres harmed neurodevelopment more than spheres.',
  },
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final calls = <MethodCall>[];
  // Never cleared: plugin setup happens once per process, in whichever test runs first.
  final everyCall = <MethodCall>[];
  final opened = <LaunchPaper>[];

  setUpAll(() async {
    await setupServiceLocator();
    await SettingsManager().setUserLanguage('cs');
    AndroidFlutterLocalNotificationsPlugin.registerWith();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (call) async {
      calls.add(call);
      everyCall.add(call);
      return call.method == 'initialize' ? true : null;
    });
  });

  setUp(() {
    calls.clear();
    opened.clear();
    PushNotificationService.onPaperOpen = opened.add;
  });

  tearDown(() => PushNotificationService.onPaperOpen = null);

  Map<Object?, Object?> shown() =>
      calls.singleWhere((c) => c.method == 'show').arguments as Map;

  test('a push that arrives while open is posted, and opens nothing by itself',
      () async {
    await PushNotificationService().showWhileOpen(_push);

    final args = shown();
    expect(args['title'], 'Neurotoxicity of microplastics in zebrafish');
    expect(args['body'], 'Fibres harmed neurodevelopment more than spheres.');
    final android = (args['platformSpecifics'] as Map)['channelId'];
    expect(android, digestChannelId);
    expect(opened, isEmpty, reason: 'only a tap may open the paper');
  });

  test('tapping the posted notification opens its paper with the payload',
      () async {
    await PushNotificationService().showWhileOpen(_push);

    PushNotificationService().openFromPayload(shown()['payload'] as String);

    expect(opened.single.id, '60e7c550-6533-4535-9556-6f7003f775c0');
    expect(opened.single.title, 'Neurotoxicity of microplastics in zebrafish');
    expect(opened.single.perex,
        'Fibres harmed neurodevelopment more than spheres.');
  });

  test('the digest channel is created at high importance', () async {
    await PushNotificationService().showWhileOpen(_push);

    final created = everyCall
        .singleWhere((c) => c.method == 'createNotificationChannel')
        .arguments as Map;
    expect(created['id'], 'paper_digest',
        reason: 'AndroidManifest.xml names this id as the FCM default channel');
    expect(created['importance'], Importance.high.value);
    expect(created['name'], 'Denní přehled',
        reason: 'Android settings list the channel in the user\'s language');
  });

  test('a push without a paper id posts nothing', () async {
    await PushNotificationService()
        .showWhileOpen(const RemoteMessage(data: {'type': 'digest'}));

    expect(calls.where((c) => c.method == 'show'), isEmpty);
  });

  test('an unreadable payload opens nothing', () {
    PushNotificationService().openFromPayload('not json');
    PushNotificationService().openFromPayload(jsonEncode({'type': 'digest'}));

    expect(opened, isEmpty);
  });
}
