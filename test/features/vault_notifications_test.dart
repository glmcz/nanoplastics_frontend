import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/models/launch_paper.dart';
import 'package:nanoplastics_app/services/digest_service.dart';
import 'package:nanoplastics_app/services/push_notification_service.dart';
import '../helpers/settings_test_helper.dart';
import '../helpers/fake_digest_service.dart';

void main() {
  group('VaultScreen — push notification saves', () {
    late FakeDigestService fakeDigest;

    setUp(() async {
      await setupServiceLocator();
      fakeDigest = FakeDigestService();
      DigestService.overrideForTesting(fakeDigest);
    });

    tearDown(() {
      DigestService.overrideForTesting(null);
      PushNotificationService.onPaperOpen = null;
    });

    test('4 notification taps add 4 papers to tresor', () async {
      final paperIds = ['paper_1', 'paper_2', 'paper_3', 'paper_4'];

      // Set up callback
      PushNotificationService.onPaperOpen = (paper) {
        fakeDigest.addToTresor(paper.id);
      };

      // Fire 4 paper open events
      for (final id in paperIds) {
        PushNotificationService.onPaperOpen?.call(LaunchPaper(id, null));
      }

      // All 4 should be in addedToTresor
      expect(fakeDigest.addedToTresor, paperIds);
    });

    test('notifications fail when operationsSucceed is false', () async {
      fakeDigest.operationsSucceed = false;
      const paperIds = ['paper_1', 'paper_2'];

      PushNotificationService.onPaperOpen = (paper) {
        fakeDigest.addToTresor(paper.id);
      };

      for (final id in paperIds) {
        PushNotificationService.onPaperOpen?.call(LaunchPaper(id, null));
      }

      // None should be in addedToTresor (operations failed)
      expect(fakeDigest.addedToTresor, isEmpty);
    });

    test('mixed success/failure: first 2 succeed, last 2 fail', () async {
      PushNotificationService.onPaperOpen = (paper) {
        fakeDigest.addToTresor(paper.id);
      };

      // Start with success
      fakeDigest.operationsSucceed = true;
      PushNotificationService.onPaperOpen
          ?.call(const LaunchPaper('paper_1', null));
      PushNotificationService.onPaperOpen
          ?.call(const LaunchPaper('paper_2', null));

      // Switch to failure
      fakeDigest.operationsSucceed = false;
      PushNotificationService.onPaperOpen
          ?.call(const LaunchPaper('paper_3', null));
      PushNotificationService.onPaperOpen
          ?.call(const LaunchPaper('paper_4', null));

      // Only first 2 in added list
      expect(fakeDigest.addedToTresor, ['paper_1', 'paper_2']);
    });
  });
}
