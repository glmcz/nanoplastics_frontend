import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nanoplastics_app/features/footprint/chapters.dart';
import 'package:nanoplastics_app/features/footprint/footprint_model.dart';
import 'package:nanoplastics_app/features/footprint/footprint_types.dart';
import 'package:nanoplastics_app/services/api_service.dart';
import 'package:nanoplastics_app/services/service_locator.dart';
import 'package:nanoplastics_app/widgets/footprint/footprint_doors.dart';
import '../../helpers/responsive_test_helper.dart';
import '../../helpers/settings_test_helper.dart';
import '../../helpers/test_app.dart';

FootprintResult result() => estimate(
      FootprintInput.gulfDefault().copyWith(touched: ChapterKey.values.toSet()),
    );

Future<void> show(WidgetTester t, {Locale locale = const Locale('en')}) async {
  // Wrapped in a scroll view because that is how the result screen hosts it;
  // testing it unscrolled would test a layout the app never renders.
  await t.pumpWidget(buildTestableWidget(
      SingleChildScrollView(child: FootprintDoors(result: result())),
      locale: locale,
      disableAnimations: true));
  await t.pumpAndSettle();
}

void main() {
  setUp(() async => await setupServiceLocator());

  testWidgets('all three doors are present', (t) async {
    await show(t);
    for (final d in ['change', 'study', 'help']) {
      expect(find.byKey(Key('door-$d')), findsOneWidget);
    }
  });

  testWidgets('the study door gives a path, not only a reading list',
      (t) async {
    await show(t);
    await t.tap(find.byKey(const Key('door-study')));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('study-start-here')), findsOneWidget);
    expect(find.byKey(const Key('study-regional')), findsOneWidget);
    expect(find.byKey(const Key('study-open-questions')), findsOneWidget);
  });

  testWidgets('every open question carries a size and a first step', (t) async {
    await show(t);
    await t.tap(find.byKey(const Key('door-study')));
    await t.pumpAndSettle();
    for (final q in kOpenQuestions) {
      expect(find.byKey(Key('question-size-${q.id}')), findsOneWidget);
      expect(find.byKey(Key('question-next-${q.id}')), findsOneWidget);
    }
  });

  testWidgets('the help door shows consent before any network call', (t) async {
    var posted = false;
    ApiService().client = MockClient((req) async {
      posted = true;
      return http.Response('{"success":true}', 200);
    });
    await show(t);
    await t.tap(find.byKey(const Key('door-help')));
    await t.pumpAndSettle();
    await t.enterText(find.byKey(const Key('help-idea-field')),
        'A wooden board instead of a plastic one');
    await t.tap(find.byKey(const Key('help-send')));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('consent-sheet')), findsOneWidget);
    expect(posted, isFalse, reason: 'nothing may leave the device yet');
  });

  testWidgets('confirm stays disabled until the required boxes are ticked',
      (t) async {
    await show(t);
    await t.tap(find.byKey(const Key('door-help')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('help-send')));
    await t.pumpAndSettle();
    final before =
        t.widget<ElevatedButton>(find.byKey(const Key('consent-confirm')));
    expect(before.onPressed, isNull);

    for (final k in ['consent-storage', 'consent-scoring', 'consent-age']) {
      await t.tap(find.byKey(Key(k)));
      await t.pumpAndSettle();
    }
    final after =
        t.widget<ElevatedButton>(find.byKey(const Key('consent-confirm')));
    expect(after.onPressed, isNotNull);
  });

  testWidgets('habit context is optional and is omitted when unticked',
      (t) async {
    late String body;
    var sent = false;
    // The mock has to live on the instance the locator hands out, not on a
    // fresh ApiService that nothing will call.
    final api = ApiService()
      ..client = MockClient((req) async {
        sent = true;
        body = req.body;
        return http.Response('{"success":true}', 200);
      });
    ServiceLocator().overrideApiServiceForTesting(api);
    await show(t);
    await t.tap(find.byKey(const Key('door-help')));
    await t.pumpAndSettle();
    await t.enterText(
        find.byKey(const Key('help-idea-field')), 'A wooden board please');
    await t.tap(find.byKey(const Key('help-send')));
    await t.pumpAndSettle();
    for (final k in ['consent-storage', 'consent-scoring', 'consent-age']) {
      await t.tap(find.byKey(Key(k)));
      await t.pumpAndSettle();
    }
    await t.tap(find.byKey(const Key('consent-confirm')));
    await t.pumpAndSettle();
    expect(sent, isTrue, reason: 'the send must actually reach the client');
    expect(body, isNot(contains('largest_by_count')),
        reason: 'the habit-context box was left unticked');
  });

  test('submitIdea puts the context on the wire as a multipart field',
      () async {
    late String body;
    final api = ApiService()
      ..client = MockClient((req) async {
        body = req.body;
        return http.Response('{"success":true}', 200);
      });
    await api.submitIdea(
      description: 'A wooden board instead of a plastic one',
      category: 'human_entry',
      context: {'source': 'footprint', 'largest_by_count': 'microwaveMeals'},
    );
    expect(body, contains('name="context"'));
    final start = body.indexOf('{', body.indexOf('name="context"'));
    final json =
        jsonDecode(body.substring(start, body.indexOf('}', start) + 1));
    expect(json['source'], 'footprint');
  });

  test('the category sent is one the database accepts', () {
    const allowed = {
      'human_central',
      'human_detox',
      'human_vitality',
      'human_reproduction',
      'human_entry',
      'human_ways_of_destruction',
      'planet_ocean',
      'planet_atmosphere',
      'planet_bio',
      'planet_magnetic',
      'planet_entry',
      'planet_physical',
    };
    for (final h in Habit.values) {
      expect(allowed, contains(categoryKeyFor(h)), reason: '$h');
    }
  });

  for (final device in kAllDevices) {
    for (final locale in const [Locale('en'), Locale('ar')]) {
      testWidgets('doors fit $device in ${locale.languageCode}', (t) async {
        setScreenSize(t, device);
        await show(t, locale: locale);
        expect(find.byKey(const Key('door-help')), findsOneWidget);
      });
    }
  }
}
