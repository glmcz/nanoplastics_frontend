import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/features/footprint/footprint_coefficients.dart';
import 'package:nanoplastics_app/features/footprint/footprint_types.dart';

void main() {
  group('a challenged number must say who challenged it', () {
    test('every disputed row names its challenger', () {
      for (final c
          in kCoefficients.where((c) => c.tags.contains(Tag.disputed))) {
        expect(
          c.challengedByKey,
          isNotNull,
          reason: '${c.habit} is tagged disputed but names nobody. '
              '"Researchers disagree" implies independent replication that '
              'usually has not happened: one paper is challenged once and '
              'everyone else repeats it. Name the challenge or drop the tag.',
        );
        expect(c.challengedByKey, isNotEmpty, reason: '${c.habit}');
      }
    });

    test('a row that names a challenger is actually tagged disputed', () {
      for (final c in kCoefficients.where((c) => c.challengedByKey != null)) {
        expect(c.tags, contains(Tag.disputed), reason: '${c.habit}');
      }
    });

    test('all three known disputes are still recorded', () {
      final disputed = kCoefficients
          .where((c) => c.tags.contains(Tag.disputed))
          .map((c) => c.habit)
          .toSet();
      expect(disputed, contains(Habit.bottledWater));
      expect(disputed, contains(Habit.microwaveMeals));
      expect(disputed, contains(Habit.teaBags));
    });
  });
}
