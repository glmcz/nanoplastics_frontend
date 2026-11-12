import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nanoplastics_app/main.dart';
import 'package:nanoplastics_app/services/digest_service.dart';
import 'package:nanoplastics_app/services/service_locator.dart';
import 'package:nanoplastics_app/services/settings_manager.dart';

import 'backend_guard.dart';

const _testEmail = 'integration-test@nanosolve.org';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Vault Real Integration Tests', () {
    final List<String> addedPaperIds = [];

    setUpAll(() async {
      // Full init — real SharedPreferences + all singletons including _updateService
      await SettingsManager.init();
      await ServiceLocator().initialize();
      await SettingsManager().setEmail(_testEmail);
      // Real SharedPreferences, so a freshly installed build opens on
      // onboarding and the settings icon this test taps does not exist yet.
      await SettingsManager().setOnboardingShown(true);
      await DigestService().syncUser();
    });

    tearDownAll(() async {
      for (final id in addedPaperIds) {
        await Future.delayed(writePace);
        await DigestService().removeFromTresor(id);
      }
    });

    testWidgets('Insert papers and open vault', (tester) async {
      // Here, not in setUpAll: the driver only sees failures inside a test.
      await expectBackendHealthy();
      // Fetch + insert before showing UI
      final papers = await DigestService().fetchLatest(since: DateTime(2020));
      debugPrint('[TEST] Papers fetched: ${papers.length}');

      final toInsert = papers.take(3).toList();
      for (final paper in toInsert) {
        // Idempotent: a previous run may have left this paper in the tresor,
        // where addToTresor returns false and the row is already there.
        await Future.delayed(writePace);
        await DigestService().removeFromTresor(paper.id);
        await Future.delayed(writePace);
        final ok = await DigestService().addToTresor(paper.id);
        debugPrint('[TEST] addToTresor(${paper.id}) => $ok');
        if (ok) addedPaperIds.add(paper.id);
      }
      debugPrint('[TEST] Inserted: ${addedPaperIds.length}');
      expect(addedPaperIds, hasLength(toInsert.length),
          reason:
              'the vault refused a paper; a 429 here means writePace is too short');

      // Show full running app — visible on emulator screen
      await tester.pumpWidget(const RestartableApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to vault via real UI
      final settingsBtn = find.byIcon(Icons.settings);
      if (settingsBtn.evaluate().isNotEmpty) {
        await tester.tap(settingsBtn.first);
      } else {
        await tester.tap(find.byIcon(Icons.settings_outlined).first);
      }
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.text('My Vault'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final firstAdded = papers.firstWhere((p) => p.id == addedPaperIds.first);
      expect(find.text(firstAdded.title), findsWidgets);
      expect(find.byType(ListView), findsOneWidget);
    });
  });
}
