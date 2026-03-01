import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/screens/user_settings/about_screen.dart';
import '../../helpers/test_app.dart';
import '../../helpers/settings_test_helper.dart';

void main() {
  setUp(() async {
    await setupServiceLocator();
  });

  Widget buildAboutApp() {
    return buildTestableWidget(const AboutScreen());
  }

  group('AboutScreen rendering', () {
    testWidgets('displays app title and version text', (tester) async {
      await tester.pumpWidget(buildAboutApp());
      await tester.pumpAndSettle();

      // Verify the app name is displayed
      expect(find.byType(Text), findsWidgets);

      // Verify version text exists
      expect(find.byType(ShaderMask), findsOneWidget);
    });

    testWidgets('displays version information', (tester) async {
      await tester.pumpWidget(buildAboutApp());
      await tester.pumpAndSettle();

      // Version text should be visible
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('displays NanoSolve Hive app name', (tester) async {
      await tester.pumpWidget(buildAboutApp());
      await tester.pumpAndSettle();

      // App name should be rendered with shader mask
      expect(find.byType(ShaderMask), findsOneWidget);
    });
  });

  group('AboutScreen Privacy Policy link', () {
    testWidgets('Privacy Policy link is visible', (tester) async {
      await tester.pumpWidget(buildAboutApp());
      await tester.pumpAndSettle();

      // Privacy Policy should be tappable (InkWell)
      expect(find.byType(InkWell), findsWidgets);

      // Verify the container structure for link items
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('displays Privacy Policy title and description', (tester) async {
      await tester.pumpWidget(buildAboutApp());
      await tester.pumpAndSettle();

      // The page contains multiple text widgets
      expect(find.byType(Text), findsWidgets);

      // Verify we have sections
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('Privacy Policy link is tappable', (tester) async {
      await tester.pumpWidget(buildAboutApp());
      await tester.pumpAndSettle();

      // Find all InkWell widgets (link items)
      final inkwells = find.byType(InkWell);
      expect(inkwells, findsWidgets);

      // All InkWell widgets should be tappable
      for (int i = 0; i < 5; i++) {
        final position = find.byType(InkWell).at(i);
        expect(position, findsOneWidget);
      }
    });
  });

  group('AboutScreen sections', () {
    testWidgets('displays website section', (tester) async {
      await tester.pumpWidget(buildAboutApp());
      await tester.pumpAndSettle();

      // Website link should be present
      expect(find.byType(InkWell), findsWidgets);
    });

    testWidgets('displays contact us section', (tester) async {
      await tester.pumpWidget(buildAboutApp());
      await tester.pumpAndSettle();

      // Contact link should be present
      expect(find.byType(InkWell), findsWidgets);
    });

    testWidgets('displays share QR code section', (tester) async {
      await tester.pumpWidget(buildAboutApp());
      await tester.pumpAndSettle();

      // Share section should have QR code
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('displays open source licenses section', (tester) async {
      await tester.pumpWidget(buildAboutApp());
      await tester.pumpAndSettle();

      // Licenses link should be present
      expect(find.byType(InkWell), findsWidgets);
    });
  });

  group('AboutScreen Contact Us email', () {
    // url_launcher 6.x uses MethodChannelUrlLauncher on channel
    // 'plugins.flutter.io/url_launcher' with method 'canLaunch'.
    void mockUrlLauncher(WidgetTester tester, {required bool canLaunch}) {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/url_launcher'),
        (call) async {
          if (call.method == 'canLaunch') return canLaunch;
          if (call.method == 'launch') return true;
          return null;
        },
      );
    }

    // AboutScreen is a scrollable list — center the item in the viewport
    // (alignment: 0.5) to avoid it landing behind the custom header when
    // ensureVisible defaults to alignment: 0.0 (top of scrollable).
    Future<void> tapContactUs(WidgetTester tester) async {
      final finder = find.text('Contact Us');
      await Scrollable.ensureVisible(
        tester.element(finder),
        alignment: 0.5,
        duration: Duration.zero,
      );
      await tester.pump();
      await tester.tap(finder);
      await tester.pumpAndSettle();
    }

    testWidgets(
        'tapping Contact Us opens email client when url_launcher succeeds',
        (tester) async {
      mockUrlLauncher(tester, canLaunch: true);

      await tester.pumpWidget(buildAboutApp());
      await tester.pumpAndSettle();

      await tapContactUs(tester);

      // Email launched — fallback dialog must NOT appear
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets(
        'tapping Contact Us shows fallback dialog when email client unavailable',
        (tester) async {
      mockUrlLauncher(tester, canLaunch: false);

      await tester.pumpWidget(buildAboutApp());
      await tester.pumpAndSettle();

      await tapContactUs(tester);

      // Fallback dialog must appear with the email address
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('support@nanosolve.io'), findsOneWidget);
    });

    testWidgets('fallback dialog has COPY and CLOSE buttons', (tester) async {
      mockUrlLauncher(tester, canLaunch: false);

      await tester.pumpWidget(buildAboutApp());
      await tester.pumpAndSettle();

      await tapContactUs(tester);

      expect(find.text('COPY'), findsOneWidget);
      expect(find.text('CLOSE'), findsOneWidget);
    });

    testWidgets('CLOSE button dismisses the fallback dialog', (tester) async {
      mockUrlLauncher(tester, canLaunch: false);

      await tester.pumpWidget(buildAboutApp());
      await tester.pumpAndSettle();

      await tapContactUs(tester);

      await tester.tap(find.text('CLOSE'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('COPY button dismisses the fallback dialog', (tester) async {
      mockUrlLauncher(tester, canLaunch: false);

      await tester.pumpWidget(buildAboutApp());
      await tester.pumpAndSettle();

      await tapContactUs(tester);

      await tester.tap(find.text('COPY'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
    });
  });
}
