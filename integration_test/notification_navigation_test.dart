import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nanoplastics_app/main.dart' as app;
import 'package:nanoplastics_app/screens/paper_loader_screen.dart';
import 'package:nanoplastics_app/services/push_notification_service.dart';

/// Drives the notification tap on a real device, which is the one path that
/// cannot be exercised in a widget test: it depends on the navigator that
/// main() wires up, and on the payload arriving before the first frame.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const title = 'Electrocoagulation of polystyrene nanoplastics';
  const perex = 'Aluminium electrodes removed 175 nm polystyrene from '
      'simulated urban treated wastewater by sweep flocculation.';

  testWidgets('a tapped notification opens the paper screen with its payload',
      (tester) async {
    app.main();
    // main() awaits settings, Firebase and the service locator before runApp.
    await tester.pumpAndSettle(const Duration(seconds: 15));

    PushNotificationService.simulateIncoming(
      '00000000-0000-0000-0000-000000000001',
      title: title,
      perex: perex,
    );
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(find.byType(PaperLoaderScreen), findsOneWidget);
    // Drawn from the payload, with no completed fetch behind it.
    expect(find.text(title), findsOneWidget);
    expect(find.text(perex), findsOneWidget);
  });

  testWidgets('back from the paper screen returns to where the user was',
      (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 15));

    PushNotificationService.simulateIncoming(
        '00000000-0000-0000-0000-000000000001',
        title: title,
        perex: perex);
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(PaperLoaderScreen), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(find.byType(PaperLoaderScreen), findsNothing);
  });
}
