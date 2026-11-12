import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nanoplastics_app/main.dart';
import 'package:nanoplastics_app/services/digest_service.dart';
import 'package:nanoplastics_app/services/push_notification_service.dart';
import 'package:nanoplastics_app/services/service_locator.dart';
import 'package:nanoplastics_app/services/settings_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'backend_guard.dart';

const _testEmail = 'integration-test-notifications@nanosolve.org';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Vault — push notification simulation', () {
    final List<String> addedPaperIds = [];

    setUpAll(() async {
      await SettingsManager.init();
      await ServiceLocator().initialize();
      await SettingsManager().setEmail(_testEmail);
      await DigestService().syncUser();

      // Skip onboarding + advisor tour so app opens directly on main screen
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_shown', true);
      await prefs.setBool('advisor_tour_shown', true);
    });

    tearDownAll(() async {
      for (final id in addedPaperIds) {
        await Future.delayed(writePace);
        await DigestService().removeFromTresor(id);
      }
    });

    testWidgets('Simulate 6 FCM notifications → vault', (tester) async {
      // Here, not in setUpAll: the driver only sees failures inside a test.
      await expectBackendHealthy();
      // Fetch papers from API
      final papers = await DigestService().fetchLatest(since: DateTime(2020));
      debugPrint('[TEST] Papers fetched: ${papers.length}');
      expect(papers, isNotEmpty, reason: 'digest feed returned no papers');

      // Register notification callback
      PushNotificationService.onPaperOpen = (paper) async {
        final ok = await DigestService().addToTresor(paper.id);
        debugPrint('[TEST] onPaperOpen(${paper.id}) → addToTresor => $ok');
      };

      // Simulate 6 incoming notifications
      final paperIdsToSimulate = papers.take(6).map((p) => p.id).toList();
      debugPrint(
          '[TEST] Simulating ${paperIdsToSimulate.length} notifications');

      for (final id in paperIdsToSimulate) {
        PushNotificationService.simulateIncoming(id);
        await Future.delayed(writePace);
      }

      // Query backend to get actual tresor state
      final tresorIds = await DigestService().getTresorIds();
      debugPrint('[TEST] Tresor after simulation: ${tresorIds.length}');

      for (final id in paperIdsToSimulate) {
        if (tresorIds.contains(id)) {
          addedPaperIds.add(id);
        }
      }
      expect(addedPaperIds, hasLength(paperIdsToSimulate.length),
          reason: 'a simulated notification did not reach the vault');

      // Show running app
      await tester.pumpWidget(const RestartableApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to vault
      final settingsBtn = find.byIcon(Icons.settings);
      if (settingsBtn.evaluate().isNotEmpty) {
        await tester.tap(settingsBtn.first);
      } else {
        await tester.tap(find.byIcon(Icons.settings_outlined).first);
      }
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.text('My Vault'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      debugPrint('[TEST] Verifying ${addedPaperIds.length} papers in vault UI');
      expect(find.byType(ListView), findsOneWidget);
      final firstPaper = papers.firstWhere((p) => addedPaperIds.contains(p.id));
      expect(find.text(firstPaper.title), findsWidgets);

      // Cleanup
      PushNotificationService.onPaperOpen = null;
    });
  });
}
