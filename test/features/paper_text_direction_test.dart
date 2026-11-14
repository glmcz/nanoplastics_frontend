import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/models/digest_paper.dart';
import 'package:nanoplastics_app/screens/paper_detail_screen.dart';
import 'package:nanoplastics_app/screens/vault_screen.dart';
import 'package:nanoplastics_app/services/digest_service.dart';

import '../helpers/fake_digest_service.dart';
import '../helpers/settings_test_helper.dart';
import '../helpers/test_app.dart';

// Paper text is English. Laid out right-to-left in the Arabic UI, a title
// ending in "Chain." was drawn as ".Chain" with the period at the front.
const _paper = DigestPaper(
  id: 'p1',
  title: 'Nanoplastics enter the rice food chain.',
  perex: 'Radiolabeled nanoplastics accumulated in rice grains.',
  labels: [],
  matchedKeywords: [],
  sourceUrl: 'https://doi.org/10.1000/example',
  authors: 'Chen Y, Zheng N',
  journal: 'Environmental science & technology',
  source: 'pubmed',
);

TextDirection? _directionOf(WidgetTester tester, String text) =>
    tester.widget<Text>(find.text(text)).textDirection;

void main() {
  late FakeDigestService digest;

  setUp(() async {
    await setupServiceLocator({'email': 'reader@example.com'});
    digest = FakeDigestService()..papers = [_paper];
    DigestService.overrideForTesting(digest);
  });

  tearDown(() => DigestService.overrideForTesting(null));

  testWidgets('paper detail keeps English text left-to-right in Arabic',
      (tester) async {
    await tester.pumpWidget(buildTestableWidget(
        const PaperDetailScreen(paper: _paper),
        locale: const Locale('ar')));
    await tester.pumpAndSettle();

    expect(_directionOf(tester, _paper.title), TextDirection.ltr);
    expect(_directionOf(tester, _paper.perex!), TextDirection.ltr);
  });

  testWidgets('vault cards keep English text left-to-right in Arabic',
      (tester) async {
    await tester.pumpWidget(
        buildTestableWidget(const VaultScreen(), locale: const Locale('ar')));
    await tester.pumpAndSettle();

    expect(_directionOf(tester, _paper.title), TextDirection.ltr);
    expect(_directionOf(tester, _paper.perex!), TextDirection.ltr);
  });
}
