import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/models/launch_paper.dart';
import 'package:nanoplastics_app/services/digest_service.dart';
import 'package:nanoplastics_app/services/paper_open_router.dart';
import 'package:nanoplastics_app/services/pending_paper_open.dart';
import 'package:nanoplastics_app/services/push_notification_service.dart';
import '../helpers/fake_digest_service.dart';
import '../helpers/settings_test_helper.dart';

void main() {
  group('cold launch from a notification tap', () {
    late FakeDigestService fakeDigest;
    final opened = <String>[];

    setUp(() async {
      await setupServiceLocator();
      fakeDigest = FakeDigestService();
      DigestService.overrideForTesting(fakeDigest);
      opened.clear();
      PushNotificationService.onPaperOpen = (paper) => opened.add(paper.id);
      PushNotificationService().resetLaunchMessageForTesting();
      PendingPaperOpen.instance.take();
    });

    tearDown(() {
      DigestService.overrideForTesting(null);
      PushNotificationService.onPaperOpen = null;
      PushNotificationService.launchMessageReaderOverride = null;
      PushNotificationService().resetLaunchMessageForTesting();
    });

    // The gate that used to sit above getInitialMessage() meant a user who had
    // never saved a keyword got no navigation at all from a cold tap.
    test('launch message is read even when the user has no keywords', () async {
      expect(fakeDigest.getKeywords(), isEmpty, reason: 'the condition itself');
      PushNotificationService.launchMessageReaderOverride =
          () async => const LaunchPaper('paper_abc', 'A title');

      await PushNotificationService().consumeLaunchMessage();

      expect(opened, ['paper_abc']);
    });

    test('launch message is consumed once, not on every call', () async {
      PushNotificationService.launchMessageReaderOverride =
          () async => const LaunchPaper('paper_abc', null);

      await PushNotificationService().consumeLaunchMessage();
      await PushNotificationService().consumeLaunchMessage();

      expect(opened, ['paper_abc']);
    });

    test('no launch message means no navigation', () async {
      PushNotificationService.launchMessageReaderOverride = () async => null;

      await PushNotificationService().consumeLaunchMessage();

      expect(opened, isEmpty);
    });

    test('a reader that throws does not take the app down', () async {
      PushNotificationService.launchMessageReaderOverride =
          () async => throw StateError('firebase not ready');

      await PushNotificationService().consumeLaunchMessage();

      expect(opened, isEmpty);
    });
  });

  group('routing a tap that arrives before the navigator exists', () {
    setUp(() => PendingPaperOpen.instance.take());
    tearDown(() => PendingPaperOpen.instance.take());

    test('no navigator yet — the tap is stashed, not dropped', () {
      routePaperOpen(const LaunchPaper('paper_1', 'Title'), null);

      final pending = PendingPaperOpen.instance.take();
      expect(pending?.id, 'paper_1');
      expect(pending?.title, 'Title');
    });

    test('taking a pending tap clears it, so it opens once', () {
      routePaperOpen(const LaunchPaper('paper_1', null), null);

      expect(PendingPaperOpen.instance.take()?.id, 'paper_1');
      expect(PendingPaperOpen.instance.take(), isNull);
    });

    test('the last tap wins when two arrive before the first frame', () {
      routePaperOpen(const LaunchPaper('paper_1', null), null);
      routePaperOpen(const LaunchPaper('paper_2', null), null);

      expect(PendingPaperOpen.instance.take()?.id, 'paper_2');
      expect(PendingPaperOpen.instance.take(), isNull);
    });

    testWidgets('navigator already mounted — pushes now, stashes nothing',
        (tester) async {
      final navKey = GlobalKey<NavigatorState>();
      final observer = _PushSpy();
      await tester.pumpWidget(MaterialApp(
        navigatorKey: navKey,
        navigatorObservers: [observer],
        home: const Scaffold(body: Text('home')),
      ));

      // Counted as a delta: MaterialApp's own home route is a push too.
      final before = observer.pushes;

      // Deliberately not pumped afterwards: the route is asserted from the
      // observer rather than by building PaperLoaderScreen, which would start
      // a real fetch. didPush fires synchronously on push.
      routePaperOpen(const LaunchPaper('paper_1', 'Straight through'),
          navKey.currentState);

      expect(observer.pushes - before, 1);
      expect(PendingPaperOpen.instance.take(), isNull);
    });
  });
}

/// Counts pushes so a route can be asserted without building its widget.
class _PushSpy extends NavigatorObserver {
  int pushes = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushes++;
    super.didPush(route, previousRoute);
  }
}
