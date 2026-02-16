// Basic Flutter widget smoke test.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nanoplastics_app/main.dart';
import 'helpers/settings_test_helper.dart';

void main() {
  setUp(() async {
    await setupServiceLocator({'onboarding_shown': true});
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NanoSolveHiveApp());

    // Verify that the app loads
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
