import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/models/digest_paper.dart';
import 'package:nanoplastics_app/screens/vault_screen.dart';
import 'package:nanoplastics_app/services/digest_service.dart';
import '../helpers/test_app.dart';
import '../helpers/settings_test_helper.dart';
import '../helpers/fake_digest_service.dart';

void main() {
  group('VaultScreen — list rendering', () {
    late FakeDigestService fakeDigest;

    setUp(() async {
      await setupServiceLocator({'email': 'test@example.com'});
      fakeDigest = FakeDigestService();
      DigestService.overrideForTesting(fakeDigest);
    });

    tearDown(() {
      DigestService.overrideForTesting(null);
    });

    testWidgets('renders 25 saved papers', (tester) async {
      fakeDigest.papers = List.generate(
        25,
        (i) => DigestPaper(
          id: 'paper_$i',
          title: 'Paper Title $i',
          labels: [],
          matchedKeywords: [],
          sourceUrl: 'https://example.com/$i',
          authors: 'Author $i',
          source: 'Journal',
          category: i % 2 == 0 ? 'human' : 'planet',
        ),
      );

      await tester.pumpWidget(buildTestableWidget(const VaultScreen()));
      await tester.pumpAndSettle();

      // First and last paper titles should be visible
      expect(find.text('Paper Title 0'), findsOneWidget);
      expect(find.text('Paper Title 24'),
          findsNothing); // Not visible until scrolled

      // Scroll to end — last paper should appear
      await tester.drag(find.byType(VaultScreen), const Offset(0, -5000));
      await tester.pumpAndSettle();
      expect(find.text('Paper Title 24'), findsWidgets);
    });

    testWidgets('shows empty state when no papers saved', (tester) async {
      fakeDigest.papers = [];

      await tester.pumpWidget(buildTestableWidget(const VaultScreen()));
      await tester.pumpAndSettle();

      // Empty state text should be visible
      expect(find.text('Vault is empty'), findsOneWidget);
    });

    testWidgets('delete button appears on each paper card', (tester) async {
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

      // Delete button (close icon) should be visible
      expect(find.byIcon(Icons.close), findsWidgets);
    });
  });
}
