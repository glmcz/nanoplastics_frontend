import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/features/footprint/footprint_format.dart';

class _En implements FootprintStrings {
  @override
  String get about => 'about';
  @override
  String get million => 'million';
  @override
  String get billion => 'billion';
  @override
  String get trillion => 'trillion';
  @override
  String get perSecond => 'a second, all year';
  @override
  String get milligram => 'mg';
  @override
  String get gram => 'g';
}

void main() {
  final s = _En();

  test('rounds to one significant figure with a scale word', () {
    expect(formatParticles(9.2e7, s), 'about 90 million');
    expect(formatParticles(3.29e13, s), 'about 30 trillion');
    expect(formatParticles(1.22e9, s), 'about 1 billion');
  });

  test('small counts are shown exactly, with no scale word', () {
    expect(formatParticles(3, s), '3');
    expect(formatParticles(557, s), 'about 600');
  });

  test('zero is zero, not "about 0"', () {
    expect(formatParticles(0, s), '0');
  });

  test('mass switches to grams above a thousand milligrams', () {
    // One significant figure, like the counts. The cutting-board source
    // reports 7.4 to 50.7 grams a year, so "29 g" would be false precision.
    expect(formatMassMg(0.52, s), '0.5 mg');
    expect(formatMassMg(0.088, s), '0.09 mg');
    expect(formatMassMg(29000, s), '30 g');
  });

  test('digits are Western in every locale', () {
    // Arabic-Indic digits here would be the only place in the app they appear.
    expect(formatParticles(9.2e7, s), matches(RegExp(r'^[a-z0-9 ]+$')));
  });

  test('a number for an RTL sentence is wrapped in isolates', () {
    final wrapped = isolate('90');
    expect(wrapped.codeUnitAt(0), 0x2068); // FIRST STRONG ISOLATE
    expect(wrapped.codeUnits.last, 0x2069); // POP DIRECTIONAL ISOLATE
  });
}
