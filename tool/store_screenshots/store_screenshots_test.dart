// Store screenshots for Google Play and the App Store, rendered from the real
// app screens with real fonts, in every app language.
//
//   SHOT_LOCALES=en,cs,es,fr,ru flutter test tool/store_screenshots/store_screenshots_test.dart
//   SHOT_LOCALES=ar flutter test tool/store_screenshots/store_screenshots_test.dart
//
// Arabic runs on its own: Roboto has no Arabic glyphs and the test engine
// ignores font fallback, so that run draws everything with Arial instead.
// macOS only, for the system fonts.
//
// Output: build/store_screenshots/<target>/<lang>/NN_<shot>.png
// Lives under tool/, not test/, so CI never runs it.
//
// papers.json holds real papers from the live digest feed (2026-11-14), so the
// screenshots show what a user actually receives.
//
// overrideForTesting is meant for tests, and this file is one: it lives under
// tool/ only to stay out of the CI test run.
// ignore_for_file: invalid_use_of_visible_for_testing_member
@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/config/app_theme.dart';
import 'package:nanoplastics_app/l10n/app_localizations.dart';
import 'package:nanoplastics_app/l10n_web/web_localizations.dart';
import 'package:nanoplastics_app/models/digest_paper.dart';
import 'package:nanoplastics_app/screens/digest_settings_screen.dart';
import 'package:nanoplastics_app/screens/main_screen.dart';
import 'package:nanoplastics_app/screens/paper_detail_screen.dart';
import 'package:nanoplastics_app/screens/vault_screen.dart';
import 'package:nanoplastics_app/services/digest_service.dart';

import '../../test/helpers/fake_digest_service.dart';
import '../../test/helpers/real_fonts.dart';
import '../../test/helpers/settings_test_helper.dart';

const _bgDeep = Color(0xFF021018);
const _bgOcean = Color(0xFF0A3A4A);
const _accent = Color(0xFF6DF5D8);
const _textMain = Color(0xFFF0FDF9);
const _textSoft = Color(0xFFB9DCD4);

/// [canvas] is the screenshot in logical pixels; times [ratio] it is the PNG
/// size the store asks for. [phone] is the screen the app lays itself out on.
class _Target {
  final String name;
  final Size canvas;
  final double ratio;
  final Size phone;
  final bool ios;
  final double topInset;
  final double bottomInset;

  const _Target(this.name, this.canvas, this.ratio, this.phone,
      {required this.ios, required this.topInset, required this.bottomInset});
}

const _targets = [
  // App Store 6.9" iPhone: 1320 x 2868
  _Target('appstore_iphone_6.9', Size(440, 956), 3, Size(402, 874),
      ios: true, topInset: 62, bottomInset: 34),
  // App Store 13" iPad: 2064 x 2752
  // The app is drawn at iPad Air size, then scaled up: at full 13" width its
  // text would be too small to read in a store listing.
  _Target('appstore_ipad_13', Size(1032, 1376), 2, Size(820, 1180),
      ios: true, topInset: 24, bottomInset: 20),
  // Google Play phone: 1080 x 2160 (2:1, the tallest Play accepts)
  _Target('play_phone', Size(360, 720), 3, Size(393, 873),
      ios: false, topInset: 32, bottomInset: 24),
];

class _DigestFake extends FakeDigestService {
  @override
  List<String> getKeywords() =>
      ['charge', 'nanoplastics', 'zeta potential', 'microplastics'];
}

typedef _Caption = ({String title, String subtitle});

class _Shot {
  final String name;
  final _Caption Function(AppLocalizations l10n) caption;
  final Widget Function() screen;
  final bool notification;
  const _Shot(this.name, this.caption, this.screen,
      {this.notification = false});
}

late List<DigestPaper> _papers;

final _shots = [
  _Shot(
    'digest',
    (l) => (title: l.landingHeroTitle, subtitle: l.landingDigestSubtitle),
    () => PaperDetailScreen(paper: _papers[0]),
    notification: true,
  ),
  _Shot(
    'your_hour',
    (l) => (title: l.landingDigestTimeTitle, subtitle: l.landingDigestTimeDesc),
    () => const DigestSettingsScreen(),
  ),
  _Shot(
    'vault',
    (l) =>
        (title: l.landingDigestVaultTitle, subtitle: l.landingDigestVaultDesc),
    () => const VaultScreen(),
  ),
  _Shot(
    'explore',
    (l) => (
      title: l.landingCategoriesTitle,
      subtitle: l.landingWhyFeatureStructuredDesc
    ),
    () => const MainScreen(),
  ),
];

final _locales = AppLocalizations.supportedLocales
    .where((l) => (Platform.environment['SHOT_LOCALES'] ?? 'en,cs,es,fr,ru')
        .split(',')
        .contains(l.languageCode))
    .toList();

Future<void> _loadSystemFont(String family, List<String> files) async {
  final loader = FontLoader(family);
  for (final file in files) {
    final bytes =
        File('/System/Library/Fonts/Supplemental/$file').readAsBytesSync();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}

Future<void> _loadMaterialIcons() async {
  final root = Platform.environment['FLUTTER_ROOT'];
  final bytes =
      File('$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf')
          .readAsBytesSync();
  await (FontLoader('MaterialIcons')
        ..addFont(Future.value(ByteData.sublistView(bytes))))
      .load();
}

void main() {
  setUpAll(() async {
    // The first font registered under a family wins, so Arabic must never
    // see Roboto at all.
    if (_locales.any((l) => l.languageCode == 'ar')) {
      for (final family in ['SF Pro', 'Montserrat', 'Roboto']) {
        await _loadSystemFont(family, ['Arial.ttf', 'Arial Bold.ttf']);
      }
      await _loadMaterialIcons();
    } else {
      await loadRealFonts();
    }
    await _loadSystemFont('monospace', ['Courier New.ttf']);
    final raw = File('tool/store_screenshots/papers.json').readAsStringSync();
    _papers = (jsonDecode(raw) as List)
        .cast<Map<String, dynamic>>()
        .map(DigestPaper.fromJson)
        .toList();
  });

  for (final target in _targets) {
    for (final locale in _locales) {
      for (final (i, shot) in _shots.indexed) {
        testWidgets('${target.name} ${locale.languageCode} ${shot.name}',
            (tester) async {
          await _prepare(tester, target);
          final l10n = await AppLocalizations.delegate.load(locale);
          final key = GlobalKey();
          await tester.pumpWidget(RepaintBoundary(
            key: key,
            child: _Frame(
              target: target,
              locale: locale,
              caption: shot.caption(l10n),
              notification: shot.notification
                  ? (
                      title: l10n.landingDigestPreviewTitle,
                      body: _papers[0].title,
                      now: l10n.landingDigestPreviewNow,
                    )
                  : null,
              app: _app(locale, shot.screen()),
            ),
          ));
          await _settle(tester);
          await _capture(
            tester,
            key,
            'build/store_screenshots/${target.name}/${locale.languageCode}/'
            '${(i + 1).toString().padLeft(2, '0')}_${shot.name}.png',
            target.ratio,
          );
        });
      }
    }
  }

  // Google Play feature graphic: 1024 x 500
  for (final locale in _locales) {
    testWidgets('play_feature_graphic ${locale.languageCode}', (tester) async {
      const target = _Target('play_feature', Size(1024, 500), 1, Size.zero,
          ios: false, topInset: 0, bottomInset: 0);
      await _prepare(tester, target);
      final l10n = await AppLocalizations.delegate.load(locale);
      final key = GlobalKey();
      await tester.pumpWidget(RepaintBoundary(
        key: key,
        child: _FeatureGraphic(locale: locale, l10n: l10n, paper: _papers[0]),
      ));
      await _settle(tester);
      await _capture(
          tester,
          key,
          'build/store_screenshots/play_feature_graphic/'
          '${locale.languageCode}.png',
          1);
    });
  }
}

Future<void> _prepare(WidgetTester tester, _Target target) async {
  tester.view.physicalSize = target.canvas * target.ratio;
  tester.view.devicePixelRatio = target.ratio;
  addTearDown(tester.view.reset);

  await setupServiceLocator(
      {'email': 'reader@example.com', 'onboarding_shown': true});
  final digest = _DigestFake()
    ..papers = _papers.sublist(1)
    ..preferences = (
      enabled: true,
      digestHour: 7,
      emailEnabled: true,
      monthlyEnabled: true,
    );
  DigestService.overrideForTesting(digest);
  addTearDown(() => DigestService.overrideForTesting(null));
}

/// Lets futures resolve and asset images decode; test frames alone never
/// finish an image load, which would leave blank backgrounds.
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.runAsync(() async {
    final images = find.byType(Image).evaluate().toList();
    for (final element in images) {
      await precacheImage((element.widget as Image).image, element);
    }
    for (final element in find.byType(DecoratedBox).evaluate()) {
      final decoration = (element.widget as DecoratedBox).decoration;
      if (decoration is BoxDecoration && decoration.image != null) {
        await precacheImage(decoration.image!.image, element);
      }
    }
  });
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _capture(
    WidgetTester tester, GlobalKey key, String path, double ratio) async {
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: ratio);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File(path)
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

const _delegates = [
  AppLocalizations.delegate,
  WebLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

Widget _app(Locale locale, Widget home) => MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: locale,
      localizationsDelegates: _delegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.darkTheme,
      home: home,
    );

typedef _Notification = ({String title, String body, String now});

class _Frame extends StatelessWidget {
  final _Target target;
  final Locale locale;
  final _Caption caption;
  final _Notification? notification;
  final Widget app;

  const _Frame({
    required this.target,
    required this.locale,
    required this.caption,
    required this.notification,
    required this.app,
  });

  @override
  Widget build(BuildContext context) {
    final scale = target.canvas.width / 440;
    final tablet = target.canvas.width > 700;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: locale,
      localizationsDelegates: _delegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Material(
        type: MaterialType.transparency,
        child: _frameBody(scale, tablet),
      ),
    );
  }

  Widget _frameBody(double scale, bool tablet) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_bgOcean, _bgDeep, Color(0xFF01080D)],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(22 * scale, 34 * scale, 22 * scale, 0),
        child: Column(
          children: [
            Text(
              caption.title.replaceAll('\n', ' '),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Roboto',
                color: _textMain,
                fontSize: (tablet ? 26 : 30) * scale,
                fontWeight: FontWeight.w800,
                height: 1.12,
                letterSpacing: -0.4,
              ),
            ),
            SizedBox(height: 10 * scale),
            Text(
              caption.subtitle,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Roboto',
                color: _textSoft,
                fontSize: (tablet ? 12.5 : 14.5) * scale,
                height: 1.4,
              ),
            ),
            SizedBox(height: 22 * scale),
            // Full width, running off the bottom edge: the screen stays large
            // enough to read and a short screen leaves no empty band.
            Expanded(
              child: ClipRect(
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.topCenter,
                  child: _Device(
                    target: target,
                    notification: notification,
                    child: app,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Device extends StatelessWidget {
  final _Target target;
  final _Notification? notification;
  final Widget child;

  const _Device({
    required this.target,
    required this.notification,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final size = target.phone;
    final tablet = size.width > 700;
    final radius = tablet ? 36.0 : (target.ios ? 56.0 : 40.0);
    const bezel = 12.0;

    return Container(
      padding: const EdgeInsets.all(bezel),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0F14),
        borderRadius: BorderRadius.circular(radius + bezel),
        border: Border.all(color: const Color(0xFF3A4654), width: 2),
        boxShadow: [
          BoxShadow(
            color: _accent.withValues(alpha: 0.18),
            blurRadius: 60,
            spreadRadius: 4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: SizedBox.fromSize(
          size: size,
          child: MediaQuery(
            data: MediaQueryData(
              size: size,
              devicePixelRatio: 3,
              padding: EdgeInsets.only(
                  top: target.topInset, bottom: target.bottomInset),
              viewPadding: EdgeInsets.only(
                  top: target.topInset, bottom: target.bottomInset),
            ),
            child: Stack(
              children: [
                Positioned.fill(child: child),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: target.topInset,
                  child: _StatusBar(ios: target.ios, tablet: tablet),
                ),
                if (target.ios && !tablet)
                  Positioned(
                    bottom: 9,
                    left: size.width / 2 - 70,
                    child: Container(
                      width: 140,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                if (notification != null)
                  Positioned(
                    top: target.topInset + 6,
                    left: 10,
                    right: 10,
                    child: _NotificationBanner(notification: notification!),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  final bool ios;
  final bool tablet;
  const _StatusBar({required this.ios, required this.tablet});

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      fontFamily: 'Roboto',
      color: Colors.white,
      fontSize: 15,
      fontWeight: FontWeight.w600,
    );
    final icons = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.signal_cellular_alt, size: 16, color: Colors.white),
        const SizedBox(width: 5),
        const Icon(Icons.wifi, size: 16, color: Colors.white),
        const SizedBox(width: 5),
        Icon(ios ? Icons.battery_full : Icons.battery_full_rounded,
            size: 18, color: Colors.white),
      ],
    );

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          if (ios && !tablet)
            Align(
              alignment: const Alignment(0, 0.15),
              child: Container(
                width: 124,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ios ? 34 : 18),
            child: Row(
              children: [
                const Text('7:30', style: style),
                const Spacer(),
                icons,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationBanner extends StatelessWidget {
  final _Notification notification;
  const _NotificationBanner({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xF2E9EEF2),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: _bgDeep,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset('assets/images/app_logo.png'),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: DefaultTextStyle(
              style: const TextStyle(
                  fontFamily: 'Roboto', color: Color(0xFF0B1520)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ),
                      Text(
                        notification.now,
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF5B6670)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notification.body,
                    textDirection: TextDirection.ltr,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, height: 1.3),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureGraphic extends StatelessWidget {
  final Locale locale;
  final AppLocalizations l10n;
  final DigestPaper paper;
  const _FeatureGraphic(
      {required this.locale, required this.l10n, required this.paper});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: locale,
      localizationsDelegates: _delegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Material(
        type: MaterialType.transparency,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_bgOcean, _bgDeep],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 40),
            child: Row(
              children: [
                Expanded(
                  flex: 11,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/app_logo.png', height: 56),
                      const SizedBox(height: 22),
                      Text(
                        l10n.landingHeroTitle,
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          color: _textMain,
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        l10n.landingBadgePlatforms,
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          color: _accent,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  flex: 9,
                  child: Center(
                    child: _NotificationBanner(
                      notification: (
                        title: l10n.landingDigestPreviewTitle,
                        body: paper.title,
                        now: l10n.landingDigestPreviewNow,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
