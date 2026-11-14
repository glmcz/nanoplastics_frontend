// Reads Roboto from the Flutter SDK with dart:io, which Chrome can't.
@TestOn('vm')
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/config/store_links.dart';
import 'package:nanoplastics_app/l10n/app_localizations.dart';
import 'package:nanoplastics_app/screens/web/web_landing_screen.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../helpers/real_fonts.dart';
import '../helpers/settings_test_helper.dart';
import '../helpers/test_app.dart';

const _phone = Size(375, 812);
const _tablet = Size(820, 1180);
const _desktop = Size(1440, 900);

Future<void> _pumpLanding(WidgetTester tester, Size size, Locale locale) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
      buildTestableWidget(const WebLandingScreen(), locale: locale));
  await tester.pump();
}

// QrImageView keeps its data private; the landing page labels each code with
// the URL it encodes, which is also what a screen reader announces.
List<String> _qrData(WidgetTester tester) => tester
    .widgetList<QrImageView>(find.byType(QrImageView, skipOffstage: false))
    .map((qr) => qr.semanticsLabel)
    .toList();

void main() {
  setUpAll(loadRealFonts);
  setUp(() => setupServiceLocator());

  for (final size in [_phone, _tablet, _desktop]) {
    for (final locale in AppLocalizations.supportedLocales) {
      testWidgets('lays out at ${size.width.toInt()} wide in $locale',
          (tester) async {
        await _pumpLanding(tester, size, locale);
        await tester.scrollUntilVisible(
          find.text(AppLocalizations.of(
                  tester.element(find.byType(WebLandingScreen)))!
              .landingFooterCopyright),
          600,
          scrollable: find.byType(Scrollable).first,
        );
      });
    }
  }

  testWidgets('desktop QR codes open the App Store and Google Play',
      (tester) async {
    await _pumpLanding(tester, _desktop, const Locale('en'));
    expect(_qrData(tester), [StoreLinks.appStore, StoreLinks.playStore]);
  });

  // Nobody can scan a code on the phone that shows it, but a phone visitor
  // must still reach both stores.
  testWidgets('phones get store buttons instead of QR codes', (tester) async {
    await _pumpLanding(tester, _phone, const Locale('en'));
    expect(_qrData(tester), isEmpty);
    expect(find.text('App Store', skipOffstage: false), findsWidgets);
    expect(find.text('Google Play', skipOffstage: false), findsWidgets);
  });

  testWidgets('the daily digest leads the page', (tester) async {
    await _pumpLanding(tester, _desktop, const Locale('en'));
    final l10n =
        AppLocalizations.of(tester.element(find.byType(WebLandingScreen)))!;
    expect(find.text(l10n.landingHeroTitle), findsOneWidget);
    expect(find.text(l10n.landingDigestTitle, skipOffstage: false),
        findsOneWidget);
  });
}
