// Renders a mobile screen from a push payload; push does not exist on web
// and the Chrome platform has no dart:io for the fetch the screen starts.
@TestOn('vm')
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/models/launch_paper.dart';
import 'package:nanoplastics_app/screens/paper_loader_screen.dart';

void main() {
  group('reading a push payload', () {
    test('title and perex are taken from the data map', () {
      final paper = LaunchPaper.fromPushData({
        'paper_id': 'abc',
        'type': 'digest',
        'title': 'Electrocoagulation of nanoplastics',
        'perex': 'Aluminium electrodes removed 175 nm polystyrene.',
      });

      expect(paper?.id, 'abc');
      expect(paper?.title, 'Electrocoagulation of nanoplastics');
      expect(paper?.perex, 'Aluminium electrodes removed 175 nm polystyrene.');
    });

    test('a payload with no paper is not a launch', () {
      expect(LaunchPaper.fromPushData({'type': 'digest'}), isNull);
      expect(LaunchPaper.fromPushData({'paper_id': ''}), isNull);
    });

    // Older builds of the backend send no title in data. The notification
    // block still has one, so the screen is not left blank.
    test('falls back to the notification title when data has none', () {
      final paper = LaunchPaper.fromPushData(
        {'paper_id': 'abc'},
        notificationTitle: 'From the notification',
      );

      expect(paper?.title, 'From the notification');
      expect(paper?.perex, isNull);
    });
  });

  testWidgets('the loader draws the payload perex before any fetch returns',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: PaperLoaderScreen(
        paperId: 'abc',
        previewTitle: 'Electrocoagulation of nanoplastics',
        previewPerex: 'Aluminium electrodes removed 175 nm polystyrene.',
      ),
    ));
    await tester.pump();

    expect(find.text('Electrocoagulation of nanoplastics'), findsOneWidget);
    expect(
      find.text('Aluminium electrodes removed 175 nm polystyrene.'),
      findsOneWidget,
    );
  });
}
