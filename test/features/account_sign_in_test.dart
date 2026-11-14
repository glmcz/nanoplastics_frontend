import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/l10n/app_localizations.dart';
import 'package:nanoplastics_app/models/digest_paper.dart';
import 'package:nanoplastics_app/screens/user_settings/user_profile.dart';
import 'package:nanoplastics_app/screens/vault_screen.dart';
import 'package:nanoplastics_app/services/digest_service.dart';
import 'package:nanoplastics_app/services/extended_tour_service.dart';
import 'package:nanoplastics_app/widgets/vault_setup.dart';
import 'package:nanoplastics_app/services/settings_manager.dart';

import '../helpers/fake_digest_service.dart';
import '../helpers/settings_test_helper.dart';
import '../helpers/test_app.dart';

const _paper = DigestPaper(
  id: 'p1',
  title: 'Nanoplastics enter the rice food chain',
  perex: 'Radiolabeled nanoplastics accumulated in rice grains.',
  labels: [],
  matchedKeywords: [],
  sourceUrl: 'https://doi.org/10.1000/example',
  authors: 'Chen Y',
  source: 'pubmed',
);

late AppLocalizations l10n;

final tourKeys = ExtendedTourKeys(
  logoKey: GlobalKey(),
  categoryGridKey: GlobalKey(),
  humanButtonKey: GlobalKey(),
  planetButtonKey: GlobalKey(),
  humanPlanetRowKey: GlobalKey(),
  sourcesButtonKey: GlobalKey(),
  resultsButtonKey: GlobalKey(),
  centerKnobKey: GlobalKey(),
);

void main() {
  late FakeDigestService digest;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  setUp(() async {
    await setupServiceLocator({'email': 'reader@example.com'});
    digest = FakeDigestService()..papers = [_paper];
    DigestService.overrideForTesting(digest);
  });

  tearDown(() => DigestService.overrideForTesting(null));

  // The Vault is the user's own: before the email is confirmed it must not
  // show anyone's papers, only the way to confirm.
  Future<void> registerThroughTheSheet(WidgetTester tester) async {
    await tester.tap(find.text(l10n.accountSendCode));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '123456');
    await tester.tap(find.text(l10n.accountConfirm));
    await tester.pumpAndSettle();
  }

  const digestOn = (
    enabled: true,
    digestHour: 7,
    emailEnabled: false,
    monthlyEnabled: false,
  );

  testWidgets('the vault asks for the email code before showing papers',
      (tester) async {
    digest
      ..signedIn = false
      ..preferences = digestOn;
    await tester.pumpWidget(buildTestableWidget(const VaultScreen()));
    await tester.pumpAndSettle();

    expect(find.text(_paper.title), findsNothing);
    await tester.tap(find.text(l10n.accountGateButton));
    await tester.pumpAndSettle();
    await registerThroughTheSheet(tester);

    expect(find.text(_paper.title), findsOneWidget);
  });

  // Registering from the Vault used to end on an empty Vault; with the digest
  // off, the next useful step is choosing when the daily paper comes.
  testWidgets(
      'registering from the vault with the digest off opens its settings',
      (tester) async {
    digest.signedIn = false;
    await tester.pumpWidget(buildTestableWidget(const VaultScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.accountGateButton));
    await tester.pumpAndSettle();
    await registerThroughTheSheet(tester);

    expect(find.text(l10n.digestSettingsTitle), findsOneWidget);
  });

  // The tour's "Set up now": register, then land where the user can act.
  testWidgets('vault setup registers, then opens the digest settings',
      (tester) async {
    digest.signedIn = false;
    await tester.pumpWidget(buildTestableWidget(Builder(
      builder: (context) => TextButton(
        onPressed: () => openVaultSetup(context),
        child: const Text('go'),
      ),
    )));
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    await registerThroughTheSheet(tester);

    expect(digest.signedIn, isTrue);
    expect(find.text(l10n.digestSettingsTitle), findsOneWidget);
  });

  testWidgets(
      'vault setup for a registered user with the digest on opens the vault',
      (tester) async {
    digest.preferences = digestOn;
    await tester.pumpWidget(buildTestableWidget(Builder(
      builder: (context) => TextButton(
        onPressed: () => openVaultSetup(context),
        child: const Text('go'),
      ),
    )));
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();

    expect(find.text(_paper.title), findsOneWidget);
  });

  // Users who finished the tour before the Vault step existed get that step
  // once; nobody sees anything twice.
  testWidgets('the vault intro is due once, also after the old tour',
      (tester) async {
    await setupServiceLocator({
      'email': 'reader@example.com',
      'advisor_tour_shown': true,
    });
    expect(SettingsManager().hasShownVaultIntro, isFalse);

    await tester.pumpWidget(buildTestableWidget(Builder(
      builder: (context) => TextButton(
        onPressed: () => ExtendedTourService.showIfNeeded(context, tourKeys),
        child: const Text('tour'),
      ),
    )));
    await tester.tap(find.text('tour'));
    await tester.pumpAndSettle();

    expect(SettingsManager().hasShownAdvisorTour, isTrue);
    expect(SettingsManager().hasShownVaultIntro, isTrue);
  });

  testWidgets('a wrong code keeps the sheet open and says so', (tester) async {
    digest
      ..signedIn = false
      ..codeAccepted = false;
    await tester.pumpWidget(buildTestableWidget(const VaultScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.accountGateButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.accountSendCode));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '000000');
    await tester.tap(find.text(l10n.accountConfirm));
    await tester.pumpAndSettle();

    expect(find.text(l10n.accountErrorWrongCode), findsOneWidget);
    expect(find.text(_paper.title), findsNothing);
  });

  // The refresh after a removal passed an arrow returning a Future to
  // setState, which Flutter rejects, so the removed paper stayed on screen.
  testWidgets('removing a paper from the vault takes it off the list',
      (tester) async {
    await tester.pumpWidget(buildTestableWidget(const VaultScreen()));
    await tester.pumpAndSettle();
    expect(find.text(_paper.title), findsOneWidget);

    digest.papers = [];
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(digest.removedFromTresor, [_paper.id]);
    expect(find.text(_paper.title), findsNothing);
  });

  Future<void> deleteThroughTheUi(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(buildTestableWidget(const UserProfileScreen()));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(l10n.profileDeleteAccount));
    await tester.tap(find.text(l10n.profileDeleteAccount));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.profileDeleteConfirmAction));
    await tester.pumpAndSettle();
  }

  // Delete used to clear only the phone; email, keywords and push token stayed
  // on the server.
  testWidgets('deleting the account erases it on the server, then here',
      (tester) async {
    await deleteThroughTheUi(tester);

    expect(digest.deleteCalls, 1);
    expect(SettingsManager().email, isEmpty);
  });

  testWidgets('if the server refuses, nothing is deleted and the user is told',
      (tester) async {
    digest.deleteSucceeds = false;
    await deleteThroughTheUi(tester);

    expect(digest.deleteCalls, 1);
    expect(SettingsManager().email, 'reader@example.com');
    expect(find.text(l10n.accountDeleteFailed), findsOneWidget);
  });
}
