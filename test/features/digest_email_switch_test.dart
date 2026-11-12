import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/screens/digest_settings_screen.dart';
import 'package:nanoplastics_app/services/digest_service.dart';
import '../helpers/fake_digest_service.dart';
import '../helpers/settings_test_helper.dart';
import '../helpers/test_app.dart';

void main() {
  late FakeDigestService fakeDigest;

  setUp(() async {
    await setupServiceLocator({'email': 'test@example.com'});
    fakeDigest = FakeDigestService();
    DigestService.overrideForTesting(fakeDigest);
  });

  tearDown(() => DigestService.overrideForTesting(null));

  SwitchListTile emailSwitch(WidgetTester tester) =>
      tester.widget(find.ancestor(
        of: find.text('Also send by email'),
        matching: find.byType(SwitchListTile),
      ));

  testWidgets('email is off for a user who never turned it on', (tester) async {
    await tester.pumpWidget(buildTestableWidget(const DigestSettingsScreen()));
    await tester.pumpAndSettle();

    expect(emailSwitch(tester).value, isFalse);
  });

  testWidgets('turning email on is what gets saved', (tester) async {
    fakeDigest.preferences =
        (enabled: true, digestHour: 9, emailEnabled: false);
    await tester.pumpWidget(buildTestableWidget(const DigestSettingsScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Also send by email'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(fakeDigest.savedEmailEnabled, isTrue);
  });

  testWidgets('email cannot be turned on while the daily digest is off',
      (tester) async {
    fakeDigest.preferences =
        (enabled: false, digestHour: 9, emailEnabled: false);
    await tester.pumpWidget(buildTestableWidget(const DigestSettingsScreen()));
    await tester.pumpAndSettle();

    expect(emailSwitch(tester).onChanged, isNull);
  });
}
