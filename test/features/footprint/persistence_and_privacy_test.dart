import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/features/footprint/footprint_model.dart';
import 'package:nanoplastics_app/features/footprint/footprint_types.dart';
import 'package:nanoplastics_app/screens/explore_screen.dart';
import 'package:nanoplastics_app/screens/footprint/footprint_result_screen.dart';
import 'package:nanoplastics_app/screens/footprint/footprint_story_screen.dart';
import 'package:nanoplastics_app/services/service_locator.dart';
import 'package:nanoplastics_app/services/settings_manager.dart';
import '../../helpers/settings_test_helper.dart';
import '../../helpers/test_app.dart';

FootprintInput answered() =>
    FootprintInput.gulfDefault().copyWith(touched: ChapterKey.values.toSet());

void main() {
  setUp(() async => await setupServiceLocator());

  group('persistence', () {
    test('input survives a round trip through json', () {
      final input = FootprintInput.gulfDefault()
          .copyWith(touched: {ChapterKey.water, ChapterKey.lunch});
      final back = FootprintInput.fromJson(input.toJson());
      expect(back.waterSource, input.waterSource);
      expect(back.touched, input.touched);
      expect(back.microwaveMealsPerWeek, input.microwaveMealsPerWeek);
      expect(back.cuttingBoard, input.cuttingBoard);
    });

    test('an enum removed in a later build falls back instead of throwing', () {
      final json = FootprintInput.gulfDefault().toJson()
        ..['waterSource'] = 'somethingRemoved';
      expect(() => FootprintInput.fromJson(json), returnsNormally);
      expect(FootprintInput.fromJson(json).waterSource,
          FootprintInput.gulfDefault().waterSource);
    });

    testWidgets('opening the result saves it for next time', (t) async {
      await t.pumpWidget(buildTestableWidget(
          FootprintResultScreen(input: answered()),
          disableAnimations: true));
      await t.pumpAndSettle();
      expect(SettingsManager().footprintState['input'], isNotNull);
      expect(SettingsManager().footprintState['saved_at'], isNotNull);
    });

    testWidgets('a first visit to Explore starts the story', (t) async {
      await t.pumpWidget(
          buildTestableWidget(const ExploreScreen(), disableAnimations: true));
      await t.pumpAndSettle();
      await t.tap(find.byKey(const Key('explore-card-footprint')));
      await t.pumpAndSettle();
      expect(find.byType(FootprintStoryScreen), findsOneWidget);
    });

    testWidgets('a return visit opens the last result with a recount',
        (t) async {
      await SettingsManager().setFootprintState({
        'input': answered().toJson(),
        'saved_at': DateTime.now().toIso8601String(),
      });
      await t.pumpWidget(
          buildTestableWidget(const ExploreScreen(), disableAnimations: true));
      await t.pumpAndSettle();
      await t.tap(find.byKey(const Key('explore-card-footprint')));
      await t.pumpAndSettle();
      expect(find.byType(FootprintResultScreen), findsOneWidget);
      expect(find.byKey(const Key('result-recount')), findsOneWidget);
    });

    testWidgets('a commitment older than two weeks asks how it went',
        (t) async {
      await SettingsManager().setFootprintState({
        'input': answered().toJson(),
        'commitment': 'When I take lunch out, I will use a glass dish',
        'commitment_at':
            DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
      });
      await t.pumpWidget(buildTestableWidget(
          FootprintResultScreen(input: answered(), returning: true),
          disableAnimations: true));
      await t.pumpAndSettle();
      expect(find.byKey(const Key('commitment-checkin')), findsOneWidget);
    });

    testWidgets('a fresh commitment does not nag', (t) async {
      await SettingsManager().setFootprintState({
        'input': answered().toJson(),
        'commitment': 'When I take lunch out, I will use a glass dish',
        'commitment_at': DateTime.now().toIso8601String(),
      });
      await t.pumpWidget(buildTestableWidget(
          FootprintResultScreen(input: answered(), returning: true),
          disableAnimations: true));
      await t.pumpAndSettle();
      expect(find.byKey(const Key('commitment-checkin')), findsNothing);
    });
  });

  group('privacy', () {
    test('the analytics switch actually stops collection', () async {
      final events = ServiceLocator().eventService;
      events.setEnabled(true);
      events.log('footprint_result');
      expect(events.debugQueueLength, 1);

      events.setEnabled(false);
      expect(events.debugQueueLength, 0,
          reason: 'off must discard what was already queued');
      events.log('footprint_result');
      expect(events.debugQueueLength, 0);
    });

    test('the policy names usage events, retention and deletion', () {
      final source =
          File('lib/screens/user_settings/privacy_policy_screen.dart')
              .readAsStringSync()
              .toLowerCase();
      expect(source, contains('180 days'));
      expect(source, contains('usage statistics'));
      expect(source, contains('outside your country'));
      expect(source, contains('delete a submission'));
    });

    test('every footprint and explore key exists in Arabic', () {
      final en = jsonDecode(File('assets/l10n/app_en.arb').readAsStringSync())
          as Map<String, dynamic>;
      final ar = jsonDecode(File('assets/l10n/app_ar.arb').readAsStringSync())
          as Map<String, dynamic>;
      final missing = en.keys
          .where((k) => k.startsWith('footprint') || k.startsWith('explore'))
          .where((k) => !ar.containsKey(k))
          .toList();
      expect(missing, isEmpty,
          reason: 'Arabic is a first-class locale for this audience: $missing');
    });

    test(
        'the other four locales are left to fall back, not filled with English',
        () {
      final en = jsonDecode(File('assets/l10n/app_en.arb').readAsStringSync())
          as Map<String, dynamic>;
      for (final code in ['cs', 'es', 'fr', 'ru']) {
        final other =
            jsonDecode(File('assets/l10n/app_$code.arb').readAsStringSync())
                as Map<String, dynamic>;
        final englishCopies = en.keys
            .where((k) => k.startsWith('footprint'))
            .where((k) => other[k] == en[k])
            .toList();
        expect(englishCopies, isEmpty,
            reason: 'pasting English into $code hides the translation queue');
      }
    });
  });
}
