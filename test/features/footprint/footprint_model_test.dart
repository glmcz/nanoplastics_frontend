import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/features/footprint/footprint_types.dart';
import 'package:nanoplastics_app/features/footprint/footprint_coefficients.dart';
import 'package:nanoplastics_app/features/footprint/footprint_model.dart';

void main() {
  group('estimate', () {
    test('an empty day produces zero in every family', () {
      final r = estimate(FootprintInput.empty());
      for (final f in Family.values) {
        expect(
          r.byFamily(f).fold<double>(0, (a, h) => a + h.particlesPerYear),
          0,
          reason: 'family $f should be zero',
        );
      }
    });

    test('default profile: microwaved lunch box leads family 1 by count', () {
      final r = estimate(FootprintInput.gulfDefault());
      final f1 = r.byFamily(Family.swallowedSubMicron);
      expect(f1.first.habit, Habit.microwaveMeals);
      expect(f1.first.particlesPerYear, closeTo(3.29e13, 0.05e13));
    });

    test('default profile: cutting board leads everything by mass', () {
      final r = estimate(FootprintInput.gulfDefault());
      final byMass = r.habitsWithMass;
      expect(byMass.first.habit, Habit.cuttingBoard);
      // Count order and mass order disagree — that reversal is the feature.
      expect(
        r.byFamily(Family.swallowedSubMicron).first.habit,
        isNot(byMass.first.habit),
      );
    });

    test('a bottle kept in the car multiplies the bottled-water count by 9.3',
        () {
      final cool = FootprintInput.gulfDefault()
          .copyWith(bottleStorage: BottleStorage.fridge);
      final hot = FootprintInput.gulfDefault()
          .copyWith(bottleStorage: BottleStorage.carOrSun);
      double water(FootprintResult r) => r
          .byFamily(Family.swallowedSubMicron)
          .firstWhere((h) => h.habit == Habit.bottledWater)
          .particlesPerYear;
      expect(water(estimate(hot)) / water(estimate(cool)), closeTo(9.3, 0.01));
    });

    test('the cooler jug has no published count and contributes nothing', () {
      final jug = FootprintInput.gulfDefault()
          .copyWith(waterSource: WaterSource.coolerJug);
      final h = estimate(jug)
          .byFamily(Family.swallowedSubMicron)
          .firstWhere((x) => x.habit == Habit.bottledWater);
      expect(h.particlesPerYear, 0);
      expect(h.tags, contains(Tag.unknown));
    });

    test('withChange reduces exactly the chosen habit and nothing else', () {
      final before = estimate(FootprintInput.gulfDefault());
      final after = before.withChange(Habit.bottleStorage);
      for (final f in Family.values) {
        for (final h in before.byFamily(f)) {
          final now = after
              .byFamily(f)
              .firstWhere((x) => x.habit == h.habit)
              .particlesPerYear;
          if (h.habit == Habit.bottledWater) {
            expect(now, lessThan(h.particlesPerYear));
          } else {
            expect(now, h.particlesPerYear);
          }
        }
      }
    });

    test('untouched chapters are excluded from the headline', () {
      final input =
          FootprintInput.gulfDefault().copyWith(touched: {ChapterKey.water});
      final r = estimate(input);
      expect(r.touchedCount, 1);
      expect(r.headlineHabit, Habit.bottledWater);
    });

    test('the result exposes no grand total and no percentage', () {
      final r = estimate(FootprintInput.gulfDefault());
      expect(r.toString(), isNot(contains('%')));
    });
  });

  group('kCoefficients', () {
    test('every row has a source, a method, a floor and a tag', () {
      for (final c in kCoefficients) {
        expect(c.source, isNotEmpty, reason: '${c.habit} source');
        expect(c.tags, isNotEmpty, reason: '${c.habit} tags');
        expect(c.sizeFloorNm, greaterThan(0), reason: '${c.habit} floor');
      }
    });

    test('every habit maps to one of the twelve allowed category keys', () {
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
      for (final c in kCoefficients) {
        expect(allowed, contains(c.categoryKey), reason: '${c.habit}');
      }
    });

    test('every habit in the enum has exactly one coefficient row', () {
      for (final h in Habit.values) {
        expect(kCoefficients.where((c) => c.habit == h), hasLength(1),
            reason: '$h');
      }
    });
  });
}
