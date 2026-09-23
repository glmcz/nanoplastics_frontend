import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nanoplastics_app/config/backend_config.dart';
import 'package:nanoplastics_app/main.dart';
import 'package:nanoplastics_app/services/digest_service.dart';
import 'package:nanoplastics_app/services/service_locator.dart';
import 'package:nanoplastics_app/services/settings_manager.dart';
import 'package:http/http.dart' as http;

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

      debugPrint('[TEST] Backend: ${BackendConfig.getBaseUrl()}');

      try {
        final resp = await http
            .get(Uri.parse('${BackendConfig.getBaseUrl()}/health'))
            .timeout(const Duration(seconds: 10));
        debugPrint('[TEST] Health: ${resp.statusCode}');
      } catch (e) {
        debugPrint('[TEST] Health FAILED: $e');
      }

      try {
        final url =
            '${BackendConfig.getBaseUrl()}/api/digest/latest?since=2020-01-01';
        final resp =
            await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
        debugPrint('[TEST] digest/latest status: ${resp.statusCode}');
        final body = resp.body;
        debugPrint(
            '[TEST] digest/latest body: ${body.substring(0, body.length.clamp(0, 400))}');
      } catch (e) {
        debugPrint('[TEST] digest/latest FAILED: $e');
      }
    });

    tearDownAll(() async {
      for (final id in addedPaperIds) {
        await DigestService().removeFromTresor(id);
      }
    });

    testWidgets('Insert papers and open vault', (tester) async {
      // Fetch + insert before showing UI
      final papers = await DigestService().fetchLatest(since: DateTime(2020));
      debugPrint('[TEST] Papers fetched: ${papers.length}');

      for (final paper in papers.take(5)) {
        // Idempotent: a previous run may have left this paper in the tresor,
        // where addToTresor returns false and the row is already there.
        await DigestService().removeFromTresor(paper.id);
        final ok = await DigestService().addToTresor(paper.id);
        debugPrint('[TEST] addToTresor(${paper.id}) => $ok');
        if (ok) addedPaperIds.add(paper.id);
      }
      debugPrint('[TEST] Inserted: ${addedPaperIds.length}');

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

      if (addedPaperIds.isNotEmpty) {
        expect(find.text(papers.first.title), findsWidgets);
        expect(find.byType(ListView), findsOneWidget);
      } else {
        debugPrint('[TEST] No papers inserted — checking empty state');
        expect(find.byIcon(Icons.lock_outline), findsWidgets);
      }
    });
  });
}
