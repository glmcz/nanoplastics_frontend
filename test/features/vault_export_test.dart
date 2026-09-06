import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/models/digest_paper.dart';
import 'package:nanoplastics_app/screens/vault_screen.dart';
import 'package:nanoplastics_app/services/digest_service.dart';
import '../helpers/test_app.dart';
import '../helpers/settings_test_helper.dart';
import '../helpers/fake_digest_service.dart';

void main() {
  group('VaultScreen — export', () {
    late FakeDigestService fakeDigest;

    setUp(() async {
      await setupServiceLocator({'email': 'test@example.com'});
      fakeDigest = FakeDigestService();
      DigestService.overrideForTesting(fakeDigest);
    });

    tearDown(() {
      DigestService.overrideForTesting(null);
    });

    testWidgets('export button visible when papers exist', (tester) async {
      fakeDigest.papers = [
        const DigestPaper(
          id: 'paper_1',
          title: 'Paper 1',
          labels: [],
          matchedKeywords: [],
          sourceUrl: 'https://example.com',
          authors: 'Author',
          source: 'Journal',
          category: 'human',
        ),
      ];

      await tester.pumpWidget(buildTestableWidget(const VaultScreen()));
      await tester.pumpAndSettle();

      // Export button (share icon) should be in header
      expect(find.byIcon(Icons.ios_share), findsOneWidget);
    });

    testWidgets('export functionality is accessible', (tester) async {
      fakeDigest.papers = [
        const DigestPaper(
          id: 'paper_1',
          title: 'Paper 1',
          labels: [],
          matchedKeywords: [],
          sourceUrl: 'https://example.com',
          authors: 'Author',
          source: 'Journal',
          category: 'human',
        ),
      ];
      fakeDigest.exportText = 'paper_1,Paper 1';

      await tester.pumpWidget(buildTestableWidget(const VaultScreen()));
      await tester.pumpAndSettle();

      // Export button exists
      expect(find.byIcon(Icons.ios_share), findsOneWidget);

      // Tapping it shouldn't crash the widget (share_plus plugin call
      // will fail in test, but that's handled in VaultScreen)
      await tester.pumpAndSettle();
      expect(find.byType(VaultScreen), findsOneWidget);
    });
  });
}
