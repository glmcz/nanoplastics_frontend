import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/features/footprint/chapters.dart';
import 'package:nanoplastics_app/features/footprint/footprint_types.dart';

void main() {
  test('there are seven chapters, one per ChapterKey, in story order', () {
    expect(kChapters, hasLength(7));
    expect(kChapters.map((c) => c.key).toList(), ChapterKey.values);
  });

  test('every chapter names a scene, a why, and at least one control', () {
    for (final c in kChapters) {
      expect(c.sceneKey, isNotEmpty, reason: '${c.key} scene');
      expect(c.whyKey, isNotEmpty, reason: '${c.key} why');
      expect(c.controls, isNotEmpty, reason: '${c.key} controls');
      for (final ctrl in c.controls) {
        expect(ctrl.questionKey, isNotEmpty, reason: '${c.key} question');
      }
    }
  });

  test('water is first, because it teaches heat before anything else', () {
    expect(kChapters.first.key, ChapterKey.water);
    expect(kChapters.first.controls, hasLength(3));
  });

  test('every chip control lists an option key per enum value', () {
    for (final c in kChapters) {
      for (final ctrl in c.controls.where((x) => x.kind == ControlKind.chips)) {
        expect(ctrl.optionKeys, isNotEmpty, reason: '${ctrl.field} options');
      }
    }
  });

  test('every slider has a unit so a screen reader can announce it', () {
    for (final c in kChapters) {
      for (final ctrl
          in c.controls.where((x) => x.kind == ControlKind.slider)) {
        expect(ctrl.unitKey, isNotNull, reason: '${ctrl.field} unit');
        expect(ctrl.max, greaterThan(ctrl.min), reason: '${ctrl.field} range');
      }
    }
  });

  test('every habit maps to an allowed category key', () {
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

  test('no two controls share a field name', () {
    final fields = [
      for (final c in kChapters)
        for (final ctrl in c.controls) ctrl.field,
    ];
    expect(fields.toSet(), hasLength(fields.length));
  });
}
