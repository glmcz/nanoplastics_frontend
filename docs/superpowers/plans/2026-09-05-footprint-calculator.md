# Footprint Calculator Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship a seven-chapter story that turns a Gulf student's daily habits into an estimated nanoplastic exposure picture, ending in three doors: change a habit, study the science, or send an idea to the backend.

**Architecture:** Pure-Dart model and coefficient table with no Flutter imports, driven by a data-defined chapter list. Three screens (Explore, Story, Result) read that model. Two new backend pieces: a private `context` JSONB column on `ideas`, and a minimal self-hosted `app_events` funnel. No new state management; `SettingsManager` and `StatefulWidget` as everywhere else in this app.

**Tech Stack:** Flutter 3.38, `fl_chart` (new), `share_plus`, `shared_preferences`, `http`; Rust/Axum with sqlx and Postgres.

**Spec:** `docs/superpowers/specs/2026-09-05-footprint-calculator-design.md` (parent: `docs/superpowers/specs/2026-09-05-student-tools-overview.md`)

## Global Constraints

- Design tokens only: `AppSpacing.of(context)`, `AppSizing.of(context)`, `AppTypography.of(context)`, `AppThemeColors.of(context)`. No raw numbers in widgets.
- `InkWell` not `GestureDetector`. `Navigator.maybePop` not `Navigator.pop`. `Semantics` on every interactive widget. No `print()`; use `LoggerService`.
- Every user-facing string goes in `assets/l10n/app_en.arb` **and** `assets/l10n/app_ar.arb` in the same commit. Never edit `lib/l10n/`. Never paste English into `app_cs.arb`, `app_es.arb`, `app_fr.arb`, `app_ru.arb`; they fall back automatically.
- Renders without overflow at 375x667 in English and Arabic, and at 200% text scale.
- No information carried by colour alone. Nothing flashes faster than 3 Hz. Motion respects `MediaQuery.disableAnimations`.
- There is no single grand total and no "percent of your year" anywhere in the app, including share text and Help door copy. Rows with different size floors are never summed.
- The project's thesis is that electrostatic charge, renewed by friction, is the root cause and that particle count is only the symptom. Features state it. Existing charge strings in the ARB files are not to be reworded.
- Backend bad input returns `AppError::InvalidInput` (HTTP 400), matching this codebase.
- Allowed `ideas.category` keys are fixed by migration 002: `human_central`, `human_detox`, `human_vitality`, `human_reproduction`, `human_entry`, `human_ways_of_destruction`, `planet_ocean`, `planet_atmosphere`, `planet_bio`, `planet_magnetic`, `planet_entry`, `planet_physical`.
- Flutter commands run from `nanoplastics_frontend/`; Rust from `services/nanoSolve-backend/`.
- Quality gate before every commit: `flutter analyze` clean and `flutter test` green, or `cargo clippy` and `cargo test` for backend tasks.

---

### Task 1: Coefficient table and the estimate model

**Files:**
- Create: `nanoplastics_frontend/lib/features/footprint/footprint_types.dart`
- Create: `nanoplastics_frontend/lib/features/footprint/footprint_coefficients.dart`
- Create: `nanoplastics_frontend/lib/features/footprint/footprint_model.dart`
- Test: `nanoplastics_frontend/test/features/footprint/footprint_model_test.dart`

**Interfaces:**
- Consumes: nothing.
- Produces: `Habit`, `Family`, `Method`, `Tag`, `Swap`, `Coefficient`, `HabitEstimate`, `FootprintInput`, `FootprintResult`, `FootprintResult estimate(FootprintInput)`, `const List<Coefficient> kCoefficients`, `const String kCoefficientsVersion`.

- [ ] **Step 1: Write the failing test**

Create `nanoplastics_frontend/test/features/footprint/footprint_model_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/features/footprint/footprint_types.dart';
import 'package:nanoplastics_app/features/footprint/footprint_coefficients.dart';
import 'package:nanoplastics_app/features/footprint/footprint_model.dart';

void main() {
  group('estimate', () {
    test('an empty day produces zero in every family', () {
      final r = estimate(FootprintInput.empty());
      for (final f in Family.values) {
        expect(r.byFamily(f).fold<double>(0, (a, h) => a + h.particlesPerYear),
            0,
            reason: 'family $f should be zero');
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
      // count order and mass order disagree — this reversal is the feature
      expect(r.byFamily(Family.swallowedSubMicron).first.habit,
          isNot(byMass.first.habit));
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
          .firstWhere((h) => h.habit == Habit.bottledWater);
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
      final input = FootprintInput.gulfDefault()
          .copyWith(touched: {ChapterKey.water});
      final r = estimate(input);
      expect(r.touchedCount, 1);
      expect(r.headlineHabit, Habit.bottledWater);
    });

    test('the result exposes no grand total and no percentage', () {
      final r = estimate(FootprintInput.gulfDefault());
      // Guard against a future contributor adding one back.
      expect(r.toString(), isNot(contains('%')));
    });
  });

  group('kCoefficients', () {
    test('every row has a source, a doi or note, a method, a floor and a tag',
        () {
      for (final c in kCoefficients) {
        expect(c.source, isNotEmpty, reason: '${c.habit} source');
        expect(c.tags, isNotEmpty, reason: '${c.habit} tags');
        expect(c.sizeFloorNm, greaterThan(0), reason: '${c.habit} floor');
      }
    });

    test('every habit maps to one of the twelve allowed category keys', () {
      const allowed = {
        'human_central', 'human_detox', 'human_vitality', 'human_reproduction',
        'human_entry', 'human_ways_of_destruction', 'planet_ocean',
        'planet_atmosphere', 'planet_bio', 'planet_magnetic', 'planet_entry',
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
```

- [ ] **Step 2: Run the test and watch it fail**

Run from `nanoplastics_frontend/`:

```bash
flutter test test/features/footprint/footprint_model_test.dart
```

Expected: FAIL, `Target of URI doesn't exist: 'package:nanoplastics_app/features/footprint/footprint_types.dart'`.

- [ ] **Step 3: Write the types**

Create `nanoplastics_frontend/lib/features/footprint/footprint_types.dart`:

```dart
enum Habit {
  bottledWater,
  bottleStorage,
  microwaveMeals,
  takeawayCupsSubMicron,
  teaBags,
  takeawayCupsMicron,
  seafood,
  cuttingBoard,
  syntheticIndoor,
  dustDays,
}

/// Grouped by the size floor of the instrument that produced the count.
/// Rows in different families are never summed: the difference between them
/// is mostly the microscope, not the plastic.
enum Family { swallowedSubMicron, swallowedMicron, breathed }

enum Method { srs, nta, sem, fluorescence, ftir, visual, gravimetric }

enum Tag { measured, countedNotIdentified, extrapolated, disputed, unknown }

enum WaterSource { smallBottles, coolerJug, tapOrFilter }

enum BottleStorage { fridge, room, carOrSun }

enum TeaBagType { paper, pyramid, looseLeaf }

enum SeafoodForm { fillet, whole }

enum CuttingBoard { plastic, wood, unknown }

enum SyntheticShare { little, some, most, all }

enum ChapterKey { water, lunch, tea, cups, home, dinner, outside }

/// One concrete swap the student could make, with the factor it applies to
/// its habit. Never phrased as "stop"; always a substitution.
class Swap {
  final String labelKey;
  final double factor;
  final bool household;
  const Swap(this.labelKey, this.factor, {this.household = false});
}
```

- [ ] **Step 4: Write the coefficient table**

Create `nanoplastics_frontend/lib/features/footprint/footprint_coefficients.dart`:

```dart
import 'footprint_types.dart';

const String kCoefficientsVersion = '2026-09-05';

/// One row per habit. Every number here is traceable to the source named on
/// the row; the spec's Model section holds the full citations. `perUnit` is
/// particles per unit of exposure, where the unit is defined by
/// `footprint_model.dart` for that habit.
class Coefficient {
  final Habit habit;
  final Family family;
  final Method method;
  final double sizeFloorNm;
  final List<Tag> tags;
  final String source;
  final String categoryKey;
  final double perUnit;
  final double lowFactor;
  final double highFactor;

  /// Milligrams per particle, where the source publishes a size distribution
  /// or the spec states the sphere assumption. Null means count only.
  final double? massMgPerParticle;
  final List<Swap> swaps;

  const Coefficient({
    required this.habit,
    required this.family,
    required this.method,
    required this.sizeFloorNm,
    required this.tags,
    required this.source,
    required this.categoryKey,
    required this.perUnit,
    this.lowFactor = 0.5,
    this.highFactor = 2.0,
    this.massMgPerParticle,
    this.swaps = const [],
  });
}

/// Sphere at the row's floor diameter, density 1.05 g/cm3, in milligrams.
/// Stated on the bar wherever it is used, because it is an assumption and
/// not a measurement.
double sphereMassMg(double diameterNm) {
  final r = diameterNm * 1e-9 / 2; // metres
  final volumeM3 = 4 / 3 * 3.141592653589793 * r * r * r;
  return volumeM3 * 1050 * 1e6; // kg/m3 -> kg -> mg
}

final List<Coefficient> kCoefficients = [
  Coefficient(
    habit: Habit.bottledWater,
    family: Family.swallowedSubMicron,
    method: Method.srs,
    sizeFloorNm: 100,
    tags: [Tag.measured, Tag.disputed],
    source: 'Qian et al., PNAS 2024, doi 10.1073/pnas.2300582121; challenged '
        'by Materic, PNAS 2024, doi 10.1073/pnas.2411099121',
    categoryKey: 'human_entry',
    perUnit: 2.4e5, // per litre
    lowFactor: 1.1e5 / 2.4e5,
    highFactor: 4.0e5 / 2.4e5,
    massMgPerParticle: 7.2e-11, // sphere at 500 nm, the reported median band
    swaps: [Swap('footprintSwapSteelBottle', 0.0)],
  ),
  Coefficient(
    habit: Habit.bottleStorage,
    family: Family.swallowedSubMicron,
    method: Method.nta,
    sizeFloorNm: 30,
    tags: [Tag.extrapolated],
    source: 'Water Research, Feb 2026, everyday storage and handling of PET '
        'bottled water, S0043135426002526',
    categoryKey: 'human_entry',
    perUnit: 9.3, // a multiplier on bottledWater, not a count
    swaps: [Swap('footprintSwapKeepBottleCool', 1 / 9.3)],
  ),
  Coefficient(
    habit: Habit.microwaveMeals,
    family: Family.swallowedSubMicron,
    method: Method.nta,
    sizeFloorNm: 30,
    tags: [Tag.countedNotIdentified, Tag.extrapolated, Tag.disputed],
    source: 'Hussain et al., ES&T 2023, doi 10.1021/acs.est.3c01942; '
        'Correspondence and Rebuttal, ES&T 2024',
    categoryKey: 'human_entry',
    perUnit: 2.11e9 * 100, // per meal, 100 cm2 contact assumed
    lowFactor: 0.5, // 50 cm2
    highFactor: 2.0, // 200 cm2
    massMgPerParticle: 1.58e-14, // Hussain's own 20.3 ng/kg/day back-solved
    swaps: [Swap('footprintSwapGlassDish', 0.0)],
  ),
  Coefficient(
    habit: Habit.takeawayCupsSubMicron,
    family: Family.swallowedSubMicron,
    method: Method.sem,
    sizeFloorNm: 200,
    tags: [Tag.countedNotIdentified],
    source: 'Ranjan et al., J. Hazard. Mater. 2021, S0304389420321087',
    categoryKey: 'human_entry',
    perUnit: 1.02e8 * 100, // per 100 mL cup
    massMgPerParticle: 5.8e-12,
    swaps: [Swap('footprintSwapOwnCup', 0.0)],
  ),
  Coefficient(
    habit: Habit.teaBags,
    family: Family.swallowedMicron,
    method: Method.sem,
    sizeFloorNm: 1000,
    tags: [Tag.disputed, Tag.countedNotIdentified],
    source: 'BfR re-test 2020 (5,800 to 20,400 particles above 1 um per bag); '
        'Hernandez et al., ES&T 2019; Busse et al., ES&T 2020',
    categoryKey: 'human_entry',
    perUnit: 13100, // per pyramid bag, BfR midpoint
    lowFactor: 5800 / 13100,
    highFactor: 20400 / 13100,
    massMgPerParticle: 5.8e-7,
    swaps: [Swap('footprintSwapPaperTeaBag', 0.0)],
  ),
  Coefficient(
    habit: Habit.takeawayCupsMicron,
    family: Family.swallowedMicron,
    method: Method.fluorescence,
    sizeFloorNm: 1000,
    tags: [Tag.measured],
    source: 'Ranjan et al., J. Hazard. Mater. 2021, S0304389420321087',
    categoryKey: 'human_entry',
    perUnit: 2.5e4, // per 100 mL cup
    massMgPerParticle: 5.8e-7,
    swaps: [Swap('footprintSwapOwnCup', 0.0)],
  ),
  Coefficient(
    habit: Habit.seafood,
    family: Family.swallowedMicron,
    method: Method.visual,
    sizeFloorNm: 100000,
    tags: [Tag.measured],
    source: 'Western Arabian Gulf, Mar. Pollut. Bull. 2020, pubmed 32479293 '
        '(gut contents, not fillet); Cox et al., ES&T 2019 as a global line',
    categoryKey: 'planet_ocean',
    perUnit: 0.057, // items per fish-equivalent meal, fillet
    massMgPerParticle: 0.0015,
  ),
  Coefficient(
    habit: Habit.cuttingBoard,
    family: Family.swallowedMicron,
    method: Method.gravimetric,
    sizeFloorNm: 1000,
    tags: [Tag.measured],
    source: 'Yadav et al., ES&T 2023, doi 10.1021/acs.est.3c00924',
    categoryKey: 'human_entry',
    perUnit: 4.3e7, // particles a year, polyethylene midpoint
    lowFactor: 14.5 / 43,
    highFactor: 71.9 / 43,
    massMgPerParticle: 29000 / 4.3e7, // 29 g a year over that count
    swaps: [Swap('footprintSwapWoodenBoard', 0.0, household: true)],
  ),
  Coefficient(
    habit: Habit.syntheticIndoor,
    family: Family.breathed,
    method: Method.ftir,
    sizeFloorNm: 11000,
    tags: [Tag.measured, Tag.extrapolated],
    source: 'Uddin et al., Kuwait indoor aerosol baseline, PMC8878012; '
        'breathing volume from Vianello et al., Sci. Rep. 2019',
    categoryKey: 'planet_atmosphere',
    perUnit: 19, // particles per cubic metre
    lowFactor: 3.2 / 19,
    highFactor: 27.1 / 19,
    massMgPerParticle: 7.6e-4,
  ),
  Coefficient(
    habit: Habit.dustDays,
    family: Family.breathed,
    method: Method.ftir,
    sizeFloorNm: 11000,
    tags: [Tag.measured],
    source: 'Bushehr, Iran, Environ. Res. 2021, pubmed 33068583 '
        '(32.5 items a day normal, 161 on dusty days)',
    categoryKey: 'planet_atmosphere',
    perUnit: (161 - 32.5) / 24, // extra items per dusty hour
    massMgPerParticle: 7.6e-4,
  ),
];

Coefficient coefficientFor(Habit h) =>
    kCoefficients.firstWhere((c) => c.habit == h);
```

- [ ] **Step 5: Write the model**

Create `nanoplastics_frontend/lib/features/footprint/footprint_model.dart`:

```dart
import 'footprint_types.dart';
import 'footprint_coefficients.dart';

class FootprintInput {
  final WaterSource waterSource;
  final int waterBottlesPerDay; // 500 mL bottles
  final BottleStorage bottleStorage;
  final int plasticContainerMealsPerWeek;
  final int microwaveMealsPerWeek;
  final TeaBagType teaBagType;
  final int teaCupsPerDay;
  final int takeawayCupsPerWeek;
  final SyntheticShare syntheticIndoorShare;
  final int indoorHoursPerDay;
  final int seafoodMealsPerWeek;
  final SeafoodForm seafoodForm;
  final CuttingBoard cuttingBoard;
  final int dustyHoursPerWeek;
  final Set<ChapterKey> touched;
  final Habit? prediction;

  const FootprintInput({
    required this.waterSource,
    required this.waterBottlesPerDay,
    required this.bottleStorage,
    required this.plasticContainerMealsPerWeek,
    required this.microwaveMealsPerWeek,
    required this.teaBagType,
    required this.teaCupsPerDay,
    required this.takeawayCupsPerWeek,
    required this.syntheticIndoorShare,
    required this.indoorHoursPerDay,
    required this.seafoodMealsPerWeek,
    required this.seafoodForm,
    required this.cuttingBoard,
    required this.dustyHoursPerWeek,
    this.touched = const {},
    this.prediction,
  });

  factory FootprintInput.empty() => const FootprintInput(
        waterSource: WaterSource.tapOrFilter,
        waterBottlesPerDay: 0,
        bottleStorage: BottleStorage.fridge,
        plasticContainerMealsPerWeek: 0,
        microwaveMealsPerWeek: 0,
        teaBagType: TeaBagType.looseLeaf,
        teaCupsPerDay: 0,
        takeawayCupsPerWeek: 0,
        syntheticIndoorShare: SyntheticShare.little,
        indoorHoursPerDay: 0,
        seafoodMealsPerWeek: 0,
        seafoodForm: SeafoodForm.fillet,
        cuttingBoard: CuttingBoard.wood,
        dustyHoursPerWeek: 0,
      );

  /// A plausible Gulf student, so no screen is ever empty. Not an answer:
  /// `touched` stays empty until the student moves a control.
  factory FootprintInput.gulfDefault() => const FootprintInput(
        waterSource: WaterSource.smallBottles,
        waterBottlesPerDay: 3,
        bottleStorage: BottleStorage.carOrSun,
        plasticContainerMealsPerWeek: 7,
        microwaveMealsPerWeek: 3,
        teaBagType: TeaBagType.pyramid,
        teaCupsPerDay: 2,
        takeawayCupsPerWeek: 4,
        syntheticIndoorShare: SyntheticShare.most,
        indoorHoursPerDay: 16,
        seafoodMealsPerWeek: 1,
        seafoodForm: SeafoodForm.fillet,
        cuttingBoard: CuttingBoard.plastic,
        dustyHoursPerWeek: 2,
      );

  FootprintInput copyWith({
    WaterSource? waterSource,
    int? waterBottlesPerDay,
    BottleStorage? bottleStorage,
    int? plasticContainerMealsPerWeek,
    int? microwaveMealsPerWeek,
    TeaBagType? teaBagType,
    int? teaCupsPerDay,
    int? takeawayCupsPerWeek,
    SyntheticShare? syntheticIndoorShare,
    int? indoorHoursPerDay,
    int? seafoodMealsPerWeek,
    SeafoodForm? seafoodForm,
    CuttingBoard? cuttingBoard,
    int? dustyHoursPerWeek,
    Set<ChapterKey>? touched,
    Habit? prediction,
  }) =>
      FootprintInput(
        waterSource: waterSource ?? this.waterSource,
        waterBottlesPerDay: waterBottlesPerDay ?? this.waterBottlesPerDay,
        bottleStorage: bottleStorage ?? this.bottleStorage,
        plasticContainerMealsPerWeek:
            plasticContainerMealsPerWeek ?? this.plasticContainerMealsPerWeek,
        microwaveMealsPerWeek:
            microwaveMealsPerWeek ?? this.microwaveMealsPerWeek,
        teaBagType: teaBagType ?? this.teaBagType,
        teaCupsPerDay: teaCupsPerDay ?? this.teaCupsPerDay,
        takeawayCupsPerWeek: takeawayCupsPerWeek ?? this.takeawayCupsPerWeek,
        syntheticIndoorShare:
            syntheticIndoorShare ?? this.syntheticIndoorShare,
        indoorHoursPerDay: indoorHoursPerDay ?? this.indoorHoursPerDay,
        seafoodMealsPerWeek: seafoodMealsPerWeek ?? this.seafoodMealsPerWeek,
        seafoodForm: seafoodForm ?? this.seafoodForm,
        cuttingBoard: cuttingBoard ?? this.cuttingBoard,
        dustyHoursPerWeek: dustyHoursPerWeek ?? this.dustyHoursPerWeek,
        touched: touched ?? this.touched,
        prediction: prediction ?? this.prediction,
      );

  Map<String, dynamic> toJson() => {
        'waterSource': waterSource.name,
        'waterBottlesPerDay': waterBottlesPerDay,
        'bottleStorage': bottleStorage.name,
        'plasticContainerMealsPerWeek': plasticContainerMealsPerWeek,
        'microwaveMealsPerWeek': microwaveMealsPerWeek,
        'teaBagType': teaBagType.name,
        'teaCupsPerDay': teaCupsPerDay,
        'takeawayCupsPerWeek': takeawayCupsPerWeek,
        'syntheticIndoorShare': syntheticIndoorShare.name,
        'indoorHoursPerDay': indoorHoursPerDay,
        'seafoodMealsPerWeek': seafoodMealsPerWeek,
        'seafoodForm': seafoodForm.name,
        'cuttingBoard': cuttingBoard.name,
        'dustyHoursPerWeek': dustyHoursPerWeek,
        'touched': touched.map((t) => t.name).toList(),
        'prediction': prediction?.name,
      };

  static FootprintInput fromJson(Map<String, dynamic> j) {
    T pick<T>(List<T> values, String? name, T fallback) {
      if (name == null) return fallback;
      for (final v in values) {
        if ((v as Enum).name == name) return v;
      }
      return fallback;
    }

    final d = FootprintInput.gulfDefault();
    return FootprintInput(
      waterSource: pick(WaterSource.values, j['waterSource'], d.waterSource),
      waterBottlesPerDay: j['waterBottlesPerDay'] ?? d.waterBottlesPerDay,
      bottleStorage:
          pick(BottleStorage.values, j['bottleStorage'], d.bottleStorage),
      plasticContainerMealsPerWeek: j['plasticContainerMealsPerWeek'] ??
          d.plasticContainerMealsPerWeek,
      microwaveMealsPerWeek:
          j['microwaveMealsPerWeek'] ?? d.microwaveMealsPerWeek,
      teaBagType: pick(TeaBagType.values, j['teaBagType'], d.teaBagType),
      teaCupsPerDay: j['teaCupsPerDay'] ?? d.teaCupsPerDay,
      takeawayCupsPerWeek: j['takeawayCupsPerWeek'] ?? d.takeawayCupsPerWeek,
      syntheticIndoorShare: pick(
          SyntheticShare.values, j['syntheticIndoorShare'],
          d.syntheticIndoorShare),
      indoorHoursPerDay: j['indoorHoursPerDay'] ?? d.indoorHoursPerDay,
      seafoodMealsPerWeek: j['seafoodMealsPerWeek'] ?? d.seafoodMealsPerWeek,
      seafoodForm: pick(SeafoodForm.values, j['seafoodForm'], d.seafoodForm),
      cuttingBoard:
          pick(CuttingBoard.values, j['cuttingBoard'], d.cuttingBoard),
      dustyHoursPerWeek: j['dustyHoursPerWeek'] ?? d.dustyHoursPerWeek,
      touched: ((j['touched'] as List?) ?? [])
          .map((n) => pick(ChapterKey.values, n as String, ChapterKey.water))
          .toSet(),
      prediction: j['prediction'] == null
          ? null
          : pick(Habit.values, j['prediction'], Habit.bottledWater),
    );
  }
}

class HabitEstimate {
  final Habit habit;
  final Family family;
  final double particlesPerYear;
  final double low;
  final double high;
  final double? massMgPerYear;
  final Method method;
  final double sizeFloorNm;
  final List<Tag> tags;
  final String source;

  const HabitEstimate({
    required this.habit,
    required this.family,
    required this.particlesPerYear,
    required this.low,
    required this.high,
    required this.massMgPerYear,
    required this.method,
    required this.sizeFloorNm,
    required this.tags,
    required this.source,
  });
}

class FootprintResult {
  final FootprintInput input;
  final List<HabitEstimate> habits;

  const FootprintResult(this.input, this.habits);

  List<HabitEstimate> byFamily(Family f) {
    final list = habits.where((h) => h.family == f).toList()
      ..sort((a, b) => b.particlesPerYear.compareTo(a.particlesPerYear));
    return list;
  }

  /// The only ordering that compares fairly across families, because mass
  /// does not depend on how small the instrument could see.
  List<HabitEstimate> get habitsWithMass {
    final list = habits.where((h) => (h.massMgPerYear ?? 0) > 0).toList()
      ..sort((a, b) => b.massMgPerYear!.compareTo(a.massMgPerYear!));
    return list;
  }

  int get touchedCount => input.touched.length;

  /// Largest by count within the family with the smallest floor, restricted
  /// to chapters the student actually answered.
  Habit? get headlineHabit {
    final answered = habits.where((h) => _isTouched(h.habit)).toList();
    if (answered.isEmpty) return null;
    answered.sort((a, b) => b.particlesPerYear.compareTo(a.particlesPerYear));
    return answered.first.habit;
  }

  bool _isTouched(Habit h) {
    const map = {
      Habit.bottledWater: ChapterKey.water,
      Habit.bottleStorage: ChapterKey.water,
      Habit.microwaveMeals: ChapterKey.lunch,
      Habit.teaBags: ChapterKey.tea,
      Habit.takeawayCupsMicron: ChapterKey.cups,
      Habit.takeawayCupsSubMicron: ChapterKey.cups,
      Habit.syntheticIndoor: ChapterKey.home,
      Habit.seafood: ChapterKey.dinner,
      Habit.cuttingBoard: ChapterKey.dinner,
      Habit.dustDays: ChapterKey.outside,
    };
    return input.touched.contains(map[h]);
  }

  /// Applies the first swap listed for that habit. Never "stop doing it".
  FootprintResult withChange(Habit habit) {
    final swaps = coefficientFor(habit).swaps;
    if (swaps.isEmpty) return this;
    final factor = swaps.first.factor;
    final target =
        habit == Habit.bottleStorage ? Habit.bottledWater : habit;
    return FootprintResult(
      input,
      habits.map((h) {
        if (h.habit != target) return h;
        return HabitEstimate(
          habit: h.habit,
          family: h.family,
          particlesPerYear: h.particlesPerYear * factor,
          low: h.low * factor,
          high: h.high * factor,
          massMgPerYear:
              h.massMgPerYear == null ? null : h.massMgPerYear! * factor,
          method: h.method,
          sizeFloorNm: h.sizeFloorNm,
          tags: h.tags,
          source: h.source,
        );
      }).toList(),
    );
  }

  @override
  String toString() => 'FootprintResult(${habits.length} habits)';
}

const double _daysPerYear = 365;
const double _weeksPerYear = 52;

double _shareFactor(SyntheticShare s) => switch (s) {
      SyntheticShare.little => 0.6,
      SyntheticShare.some => 0.9,
      SyntheticShare.most => 1.2,
      SyntheticShare.all => 1.4,
    };

FootprintResult estimate(FootprintInput i) {
  final out = <HabitEstimate>[];

  HabitEstimate build(Habit h, double count, {List<Tag>? extraTags}) {
    final c = coefficientFor(h);
    return HabitEstimate(
      habit: h,
      family: c.family,
      particlesPerYear: count,
      low: count * c.lowFactor,
      high: count * c.highFactor,
      massMgPerYear:
          c.massMgPerParticle == null ? null : count * c.massMgPerParticle!,
      method: c.method,
      sizeFloorNm: c.sizeFloorNm,
      tags: [...c.tags, ...?extraTags],
      source: c.source,
    );
  }

  // Water. Only small bottles have a published sub-micron count. The 20 L
  // cooler jug has never been counted at nano scale, and the app says so
  // instead of guessing.
  final storageMultiplier =
      i.bottleStorage == BottleStorage.carOrSun ? 9.3 : 1.0;
  if (i.waterSource == WaterSource.smallBottles) {
    final litres = i.waterBottlesPerDay * 0.5 * _daysPerYear;
    out.add(build(Habit.bottledWater,
        litres * coefficientFor(Habit.bottledWater).perUnit * storageMultiplier));
  } else {
    out.add(build(Habit.bottledWater, 0,
        extraTags: i.waterSource == WaterSource.coolerJug
            ? [Tag.unknown]
            : null));
  }
  out.add(build(Habit.bottleStorage, 0)); // multiplier row, no count of its own

  // Lunch. Only the meals actually heated release at this rate.
  final heated = i.microwaveMealsPerWeek
      .clamp(0, i.plasticContainerMealsPerWeek)
      .toDouble();
  out.add(build(Habit.microwaveMeals,
      heated * _weeksPerYear * coefficientFor(Habit.microwaveMeals).perUnit));

  // Tea. Only the silky pyramid bag is plastic.
  final bags = i.teaBagType == TeaBagType.pyramid
      ? i.teaCupsPerDay * _daysPerYear
      : 0.0;
  out.add(build(Habit.teaBags, bags * coefficientFor(Habit.teaBags).perUnit));

  // Cups, counted twice at two floors, shown as two bars.
  final cups = i.takeawayCupsPerWeek * _weeksPerYear;
  out.add(build(Habit.takeawayCupsMicron,
      cups * coefficientFor(Habit.takeawayCupsMicron).perUnit));
  out.add(build(Habit.takeawayCupsSubMicron,
      cups * coefficientFor(Habit.takeawayCupsSubMicron).perUnit));

  // Dinner.
  final meals = i.seafoodMealsPerWeek * _weeksPerYear;
  final wholeFactor = i.seafoodForm == SeafoodForm.whole ? 3.0 : 1.0;
  out.add(build(Habit.seafood,
      meals * coefficientFor(Habit.seafood).perUnit * wholeFactor));
  out.add(build(
      Habit.cuttingBoard,
      i.cuttingBoard == CuttingBoard.plastic
          ? coefficientFor(Habit.cuttingBoard).perUnit
          : 0));

  // Home and outside.
  final m3 = 16.8 * (i.indoorHoursPerDay / 24);
  out.add(build(
      Habit.syntheticIndoor,
      m3 *
          coefficientFor(Habit.syntheticIndoor).perUnit *
          _shareFactor(i.syntheticIndoorShare) *
          _daysPerYear));
  out.add(build(
      Habit.dustDays,
      i.dustyHoursPerWeek *
          _weeksPerYear *
          coefficientFor(Habit.dustDays).perUnit));

  return FootprintResult(i, out);
}
```

- [ ] **Step 6: Run the test and watch it pass**

```bash
flutter test test/features/footprint/footprint_model_test.dart
```

Expected: PASS, 10 tests.

- [ ] **Step 7: Prove the tests are real by breaking the code**

Change `9.3` to `2.0` in the `storageMultiplier` line and re-run. Expected: the car-multiplier test FAILS. Restore `9.3`, re-run, expect PASS. A test that has never been red proves nothing.

- [ ] **Step 8: Analyze and commit**

```bash
flutter analyze lib/features/footprint test/features/footprint
git add lib/features/footprint test/features/footprint
git commit -m "feat(footprint): coefficient table and estimate model

Three families keyed to instrument size floor, never summed across.
Every row carries its method, floor, tags and source."
```

---

### Task 2: Number formatting that survives Arabic

**Files:**
- Create: `nanoplastics_frontend/lib/features/footprint/footprint_format.dart`
- Test: `nanoplastics_frontend/test/features/footprint/footprint_format_test.dart`

**Interfaces:**
- Consumes: nothing from Task 1.
- Produces: `String formatParticles(double n, FootprintStrings s)`, `String formatMassMg(double mg, FootprintStrings s)`, `abstract class FootprintStrings` with `million`, `billion`, `trillion`, `perSecond`, `milligram`, `gram` getters.

The abstract `FootprintStrings` exists so the formatter stays free of Flutter and can be tested without a widget tree. Task 11 provides the `AppLocalizations`-backed implementation.

- [ ] **Step 1: Write the failing test**

Create `nanoplastics_frontend/test/features/footprint/footprint_format_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/features/footprint/footprint_format.dart';

class _En implements FootprintStrings {
  @override String get million => 'million';
  @override String get billion => 'billion';
  @override String get trillion => 'trillion';
  @override String get about => 'about';
  @override String get perSecond => 'a second, all year';
  @override String get milligram => 'mg';
  @override String get gram => 'g';
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
    expect(formatMassMg(0.52, s), '0.52 mg');
    expect(formatMassMg(29000, s), '29 g');
  });

  test('digits are Western in every locale', () {
    // The app writes Western digits everywhere else; Arabic-Indic digits here
    // would be the only place they appear.
    expect(formatParticles(9.2e7, s), matches(RegExp(r'^[a-z0-9 ]+$')));
  });

  test('a number for an RTL sentence is wrapped in isolates', () {
    final wrapped = isolate('90');
    expect(wrapped.codeUnitAt(0), 0x2068); // FIRST STRONG ISOLATE
    expect(wrapped.codeUnits.last, 0x2069); // POP DIRECTIONAL ISOLATE
  });
}
```

- [ ] **Step 2: Run it and watch it fail**

```bash
flutter test test/features/footprint/footprint_format_test.dart
```

Expected: FAIL, URI does not exist.

- [ ] **Step 3: Implement**

Create `nanoplastics_frontend/lib/features/footprint/footprint_format.dart`:

```dart
/// Strings the formatter needs, supplied by the widget layer so this file
/// stays free of Flutter and testable on its own.
abstract class FootprintStrings {
  String get about;
  String get million;
  String get billion;
  String get trillion;
  String get perSecond;
  String get milligram;
  String get gram;
}

/// Wraps a number so it does not reorder inside an Arabic sentence.
String isolate(String s) => '⁨$s⁩';

double _oneSigFig(double n) {
  if (n == 0) return 0;
  final magnitude = (log10(n)).floorToDouble();
  final scale = _pow10(magnitude);
  return (n / scale).roundToDouble() * scale;
}

double log10(double x) {
  // dart:math's log is natural; ln(10) inlined to keep this file dependency
  // free of anything but core.
  var result = 0.0;
  var v = x;
  while (v >= 10) {
    v /= 10;
    result += 1;
  }
  while (v < 1) {
    v *= 10;
    result -= 1;
  }
  return result;
}

double _pow10(double e) {
  var r = 1.0;
  for (var i = 0; i < e.abs(); i++) {
    r *= 10;
  }
  return e < 0 ? 1 / r : r;
}

String _trim(double v) =>
    v == v.roundToDouble() ? v.round().toString() : v.toString();

String formatParticles(double n, FootprintStrings s) {
  if (n <= 0) return '0';
  final r = _oneSigFig(n);
  if (r < 1000) return r < 10 ? _trim(r) : '${s.about} ${_trim(r)}';
  if (r < 1e9) return '${s.about} ${_trim(r / 1e6)} ${s.million}';
  if (r < 1e12) return '${s.about} ${_trim(r / 1e9)} ${s.billion}';
  return '${s.about} ${_trim(r / 1e12)} ${s.trillion}';
}

String formatMassMg(double mg, FootprintStrings s) {
  if (mg >= 1000) return '${_trim(_oneSigFig(mg / 1000))} ${s.gram}';
  final v = mg >= 1 ? mg.roundToDouble() : double.parse(mg.toStringAsPrecision(2));
  return '${_trim(v)} ${s.milligram}';
}
```

- [ ] **Step 4: Run it and watch it pass**

```bash
flutter test test/features/footprint/footprint_format_test.dart
```

Expected: PASS, 6 tests. If `formatParticles(3, s)` returns `about 3`, the `r < 10` branch is wrong; fix it rather than changing the test.

- [ ] **Step 5: Prove the test is real**

Delete the `isolate` wrapper's trailing `⁩` and re-run. Expected: the isolate test FAILS. Restore it.

- [ ] **Step 6: Commit**

```bash
flutter analyze lib/features/footprint test/features/footprint
git add lib/features/footprint/footprint_format.dart test/features/footprint/footprint_format_test.dart
git commit -m "feat(footprint): number formatting with RTL isolates

Western digits in every locale, matching the rest of the app.
Scale words come from the string interface so Arabic plurals work."
```

---

### Task 3: The chapter list

**Files:**
- Create: `nanoplastics_frontend/lib/features/footprint/chapters.dart`
- Test: `nanoplastics_frontend/test/features/footprint/chapters_test.dart`

**Interfaces:**
- Consumes: `ChapterKey`, `Habit` from Task 1.
- Produces: `class Chapter`, `class ControlSpec`, `const List<Chapter> kChapters`, `String categoryKeyFor(Habit)`.

Chapters are data so that cutting one after the funnel says seven is too many is a one-line change, not a screen rewrite.

- [ ] **Step 1: Write the failing test**

Create `nanoplastics_frontend/test/features/footprint/chapters_test.dart`:

```dart
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

  test('every habit maps to an allowed category key', () {
    const allowed = {
      'human_central', 'human_detox', 'human_vitality', 'human_reproduction',
      'human_entry', 'human_ways_of_destruction', 'planet_ocean',
      'planet_atmosphere', 'planet_bio', 'planet_magnetic', 'planet_entry',
      'planet_physical',
    };
    for (final h in Habit.values) {
      expect(allowed, contains(categoryKeyFor(h)), reason: '$h');
    }
  });
}
```

- [ ] **Step 2: Run it and watch it fail**

```bash
flutter test test/features/footprint/chapters_test.dart
```

Expected: FAIL, URI does not exist.

- [ ] **Step 3: Implement**

Create `nanoplastics_frontend/lib/features/footprint/chapters.dart`:

```dart
import 'footprint_types.dart';
import 'footprint_coefficients.dart';

enum ControlKind { slider, chips }

class ControlSpec {
  final String field;
  final String questionKey;
  final ControlKind kind;
  final int min;
  final int max;
  final String? unitKey;
  final List<String> optionKeys;

  const ControlSpec({
    required this.field,
    required this.questionKey,
    required this.kind,
    this.min = 0,
    this.max = 0,
    this.unitKey,
    this.optionKeys = const [],
  });
}

class Chapter {
  final ChapterKey key;
  final String sceneKey;
  final String whyKey;
  final List<ControlSpec> controls;
  const Chapter(this.key, this.sceneKey, this.whyKey, this.controls);
}

const List<Chapter> kChapters = [
  Chapter(ChapterKey.water, 'footprintSceneWater', 'footprintWhyWater', [
    ControlSpec(
      field: 'waterSource',
      questionKey: 'footprintQWaterSource',
      kind: ControlKind.chips,
      optionKeys: [
        'footprintOptSmallBottles',
        'footprintOptCoolerJug',
        'footprintOptTapOrFilter'
      ],
    ),
    ControlSpec(
      field: 'waterBottlesPerDay',
      questionKey: 'footprintQWaterAmount',
      kind: ControlKind.slider,
      min: 0,
      max: 8,
      unitKey: 'footprintUnitBottles',
    ),
    ControlSpec(
      field: 'bottleStorage',
      questionKey: 'footprintQBottleStorage',
      kind: ControlKind.chips,
      optionKeys: [
        'footprintOptFridge',
        'footprintOptRoom',
        'footprintOptCarOrSun'
      ],
    ),
  ]),
  Chapter(ChapterKey.lunch, 'footprintSceneLunch', 'footprintWhyLunch', [
    ControlSpec(
      field: 'plasticContainerMealsPerWeek',
      questionKey: 'footprintQContainerMeals',
      kind: ControlKind.slider,
      min: 0,
      max: 21,
      unitKey: 'footprintUnitMealsWeek',
    ),
    ControlSpec(
      field: 'microwaveMealsPerWeek',
      questionKey: 'footprintQMicrowaveMeals',
      kind: ControlKind.slider,
      min: 0,
      max: 21,
      unitKey: 'footprintUnitMealsWeek',
    ),
  ]),
  Chapter(ChapterKey.tea, 'footprintSceneTea', 'footprintWhyTea', [
    ControlSpec(
      field: 'teaBagType',
      questionKey: 'footprintQTeaBagType',
      kind: ControlKind.chips,
      optionKeys: [
        'footprintOptPaperBag',
        'footprintOptPyramidBag',
        'footprintOptLooseLeaf'
      ],
    ),
    ControlSpec(
      field: 'teaCupsPerDay',
      questionKey: 'footprintQTeaCups',
      kind: ControlKind.slider,
      min: 0,
      max: 6,
      unitKey: 'footprintUnitCupsDay',
    ),
  ]),
  Chapter(ChapterKey.cups, 'footprintSceneCups', 'footprintWhyCups', [
    ControlSpec(
      field: 'takeawayCupsPerWeek',
      questionKey: 'footprintQTakeawayCups',
      kind: ControlKind.slider,
      min: 0,
      max: 21,
      unitKey: 'footprintUnitCupsWeek',
    ),
  ]),
  Chapter(ChapterKey.home, 'footprintSceneHome', 'footprintWhyHome', [
    ControlSpec(
      field: 'syntheticIndoorShare',
      questionKey: 'footprintQSynthetic',
      kind: ControlKind.chips,
      optionKeys: [
        'footprintOptLittle',
        'footprintOptSome',
        'footprintOptMost',
        'footprintOptAll'
      ],
    ),
    ControlSpec(
      field: 'indoorHoursPerDay',
      questionKey: 'footprintQIndoorHours',
      kind: ControlKind.slider,
      min: 0,
      max: 24,
      unitKey: 'footprintUnitHoursDay',
    ),
  ]),
  Chapter(ChapterKey.dinner, 'footprintSceneDinner', 'footprintWhyDinner', [
    ControlSpec(
      field: 'seafoodMealsPerWeek',
      questionKey: 'footprintQSeafood',
      kind: ControlKind.slider,
      min: 0,
      max: 7,
      unitKey: 'footprintUnitMealsWeek',
    ),
    ControlSpec(
      field: 'seafoodForm',
      questionKey: 'footprintQSeafoodForm',
      kind: ControlKind.chips,
      optionKeys: ['footprintOptFillet', 'footprintOptWhole'],
    ),
    ControlSpec(
      field: 'cuttingBoard',
      questionKey: 'footprintQCuttingBoard',
      kind: ControlKind.chips,
      optionKeys: [
        'footprintOptBoardPlastic',
        'footprintOptBoardWood',
        'footprintOptBoardUnknown'
      ],
    ),
  ]),
  Chapter(ChapterKey.outside, 'footprintSceneOutside', 'footprintWhyOutside', [
    ControlSpec(
      field: 'dustyHoursPerWeek',
      questionKey: 'footprintQDustyHours',
      kind: ControlKind.slider,
      min: 0,
      max: 20,
      unitKey: 'footprintUnitHoursWeek',
    ),
  ]),
];

/// The database constrains `ideas.category` to twelve keys (migration 002).
/// An idea sent from this tool must carry one of them or the insert fails.
String categoryKeyFor(Habit h) => coefficientFor(h).categoryKey;
```

- [ ] **Step 4: Run it and watch it pass**

```bash
flutter test test/features/footprint/chapters_test.dart
```

Expected: PASS, 4 tests.

- [ ] **Step 5: Commit**

```bash
flutter analyze lib/features/footprint test/features/footprint
git add lib/features/footprint/chapters.dart test/features/footprint/chapters_test.dart
git commit -m "feat(footprint): chapter list as data

Seven chapters described by data so cutting one is a list edit.
Habit-to-category mapping is asserted against migration 002's keys."
```

---

### Task 4: Particle cloud widget

**Files:**
- Create: `nanoplastics_frontend/lib/widgets/footprint/particle_cloud.dart`
- Test: `nanoplastics_frontend/test/features/footprint/particle_cloud_test.dart`

**Interfaces:**
- Consumes: `HabitEstimate`, `Family` from Task 1.
- Produces: `class ParticleCloud extends StatefulWidget` with `({required List<HabitEstimate> habits, required Family family, required String semanticLabel, required bool paused, required VoidCallback onTogglePause})`.

Three rules drive this widget and all three are testable: identity is never colour alone, the canvas is one semantic node with a live label, and motion stops for reduce-motion or the pause button.

- [ ] **Step 1: Write the failing test**

Create `nanoplastics_frontend/test/features/footprint/particle_cloud_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/features/footprint/footprint_types.dart';
import 'package:nanoplastics_app/features/footprint/footprint_model.dart';
import 'package:nanoplastics_app/widgets/footprint/particle_cloud.dart';

HabitEstimate _h(Habit habit, double n) => HabitEstimate(
      habit: habit,
      family: Family.swallowedSubMicron,
      particlesPerYear: n,
      low: n / 2,
      high: n * 2,
      massMgPerYear: 1,
      method: Method.nta,
      sizeFloorNm: 30,
      tags: const [Tag.measured],
      source: 'test',
    );

Widget _wrap(Widget child, {bool disableAnimations = false}) => MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: Scaffold(body: child),
      ),
    );

void main() {
  final habits = [
    _h(Habit.microwaveMeals, 3.29e13),
    _h(Habit.bottledWater, 1.22e9),
  ];

  testWidgets('the cloud is one semantic node carrying the count', (t) async {
    await t.pumpWidget(_wrap(ParticleCloud(
      habits: habits,
      family: Family.swallowedSubMicron,
      semanticLabel: 'about 30 trillion particles a year from two habits',
      paused: false,
      onTogglePause: () {},
    )));
    expect(
      find.bySemanticsLabel('about 30 trillion particles a year from two habits'),
      findsOneWidget,
    );
  });

  testWidgets('reduce-motion renders without a running ticker', (t) async {
    await t.pumpWidget(_wrap(
      ParticleCloud(
        habits: habits,
        family: Family.swallowedSubMicron,
        semanticLabel: 'x',
        paused: false,
        onTogglePause: () {},
      ),
      disableAnimations: true,
    ));
    final state = t.state<ParticleCloudState>(find.byType(ParticleCloud));
    expect(state.isAnimating, isFalse);
  });

  testWidgets('a pause control is always present and reports taps', (t) async {
    var toggled = 0;
    await t.pumpWidget(_wrap(ParticleCloud(
      habits: habits,
      family: Family.swallowedSubMicron,
      semanticLabel: 'x',
      paused: false,
      onTogglePause: () => toggled++,
    )));
    await t.tap(find.byKey(const Key('cloud-pause')));
    expect(toggled, 1);
  });

  testWidgets('each habit gets its own shape, not just its own colour',
      (t) async {
    await t.pumpWidget(_wrap(ParticleCloud(
      habits: habits,
      family: Family.swallowedSubMicron,
      semanticLabel: 'x',
      paused: true,
      onTogglePause: () {},
    )));
    final state = t.state<ParticleCloudState>(find.byType(ParticleCloud));
    final shapes = state.debugDotShapes.toSet();
    expect(shapes.length, habits.length,
        reason: 'two habits must not share a shape');
  });

  testWidgets('dot count is capped and the caption states the scale',
      (t) async {
    await t.pumpWidget(_wrap(ParticleCloud(
      habits: habits,
      family: Family.swallowedSubMicron,
      semanticLabel: 'x',
      paused: true,
      onTogglePause: () {},
    )));
    final state = t.state<ParticleCloudState>(find.byType(ParticleCloud));
    expect(state.debugDotCount, lessThanOrEqualTo(400));
    expect(find.byKey(const Key('cloud-scale-caption')), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run it and watch it fail**

```bash
flutter test test/features/footprint/particle_cloud_test.dart
```

Expected: FAIL, URI does not exist.

- [ ] **Step 3: Implement**

Create `nanoplastics_frontend/lib/widgets/footprint/particle_cloud.dart`. The essentials, in this order:

```dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../features/footprint/footprint_types.dart';
import '../../features/footprint/footprint_model.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_typography.dart';
import '../../utils/app_theme_colors.dart';

enum DotShape { circle, square, triangle, diamond, cross, hexagon }

class ParticleCloud extends StatefulWidget {
  final List<HabitEstimate> habits;
  final Family family;
  final String semanticLabel;
  final bool paused;
  final VoidCallback onTogglePause;

  const ParticleCloud({
    super.key,
    required this.habits,
    required this.family,
    required this.semanticLabel,
    required this.paused,
    required this.onTogglePause,
  });

  @override
  State<ParticleCloud> createState() => ParticleCloudState();
}

class ParticleCloudState extends State<ParticleCloud>
    with SingleTickerProviderStateMixin {
  static const int maxDots = 400;
  static const int reducedDots = 200;

  late final AnimationController _controller;
  final _rng = math.Random(7); // fixed seed: the same day draws the same cloud
  List<_Dot> _dots = const [];

  bool get isAnimating => _controller.isAnimating;
  int get debugDotCount => _dots.length;
  List<DotShape> get debugDotShapes =>
      _dots.map((d) => d.shape).toSet().toList();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _rebuildDots();
    _syncTicker();
  }

  @override
  void didUpdateWidget(covariant ParticleCloud old) {
    super.didUpdateWidget(old);
    if (old.habits != widget.habits) _rebuildDots();
    if (old.paused != widget.paused) _syncTicker();
  }

  /// Motion is off when the OS asks for it or the student pressed pause.
  /// The cloud still renders; only the ticker stops.
  void _syncTicker() {
    final reduced = MediaQuery.of(context).disableAnimations;
    if (reduced || widget.paused) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  void _rebuildDots() {
    final reduced = MediaQuery.of(context).disableAnimations;
    final budget = reduced ? reducedDots : maxDots;
    final total = widget.habits.fold<double>(0, (a, h) => a + h.particlesPerYear);
    final dots = <_Dot>[];
    for (var i = 0; i < widget.habits.length; i++) {
      final h = widget.habits[i];
      final share = total == 0 ? 0.0 : h.particlesPerYear / total;
      // Every answered habit gets at least one dot, so a small habit is
      // visible rather than silently absent.
      final n = math.max(h.particlesPerYear > 0 ? 1 : 0,
          (share * budget).round());
      for (var d = 0; d < n && dots.length < budget; d++) {
        dots.add(_Dot(
          shape: DotShape.values[i % DotShape.values.length],
          habitIndex: i,
          x: _rng.nextDouble(),
          y: _rng.nextDouble(),
          phase: _rng.nextDouble(),
        ));
      }
    }
    setState(() => _dots = dots);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = AppSpacing.of(context);
    final typography = AppTypography.of(context);
    final colors = AppThemeColors.of(context);
    final perDot = _dots.isEmpty
        ? 0.0
        : widget.habits.fold<double>(0, (a, h) => a + h.particlesPerYear) /
            _dots.length;

    return Column(
      children: [
        Semantics(
          label: widget.semanticLabel,
          liveRegion: true,
          image: true,
          child: RepaintBoundary(
            child: AspectRatio(
              aspectRatio: 2,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => CustomPaint(
                  painter: _CloudPainter(
                    dots: _dots,
                    t: _controller.value,
                    colors: colors,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: spacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                key: const Key('cloud-scale-caption'),
                // The scale changes with the cap, so it is computed, not fixed.
                'Each dot is about ${perDot.toStringAsPrecision(2)} particles',
                style: typography.caption,
              ),
            ),
            IconButton(
              key: const Key('cloud-pause'),
              onPressed: widget.onTogglePause,
              icon: Icon(widget.paused ? Icons.play_arrow : Icons.pause),
              tooltip: widget.paused ? 'Play' : 'Pause',
            ),
          ],
        ),
      ],
    );
  }
}

class _Dot {
  final DotShape shape;
  final int habitIndex;
  final double x, y, phase;
  const _Dot({
    required this.shape,
    required this.habitIndex,
    required this.x,
    required this.y,
    required this.phase,
  });
}

class _CloudPainter extends CustomPainter {
  final List<_Dot> dots;
  final double t;
  final dynamic colors;
  _CloudPainter({required this.dots, required this.t, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    // Shapes are drawn as paths, never as text glyphs: a glyph per dot is the
    // expensive path on low-end Android.
    for (final d in dots) {
      final drift = math.sin((t + d.phase) * 2 * math.pi) * 4;
      final c = Offset(d.x * size.width, d.y * size.height + drift);
      final paint = Paint()..color = _colorFor(d.habitIndex);
      switch (d.shape) {
        case DotShape.circle:
          canvas.drawCircle(c, 3, paint);
        case DotShape.square:
          canvas.drawRect(Rect.fromCenter(center: c, width: 5, height: 5), paint);
        case DotShape.triangle:
          canvas.drawPath(_poly(c, 3, 4), paint);
        case DotShape.diamond:
          canvas.drawPath(_poly(c, 4, 4), paint);
        case DotShape.cross:
          canvas.drawRect(Rect.fromCenter(center: c, width: 7, height: 2), paint);
          canvas.drawRect(Rect.fromCenter(center: c, width: 2, height: 7), paint);
        case DotShape.hexagon:
          canvas.drawPath(_poly(c, 6, 4), paint);
      }
    }
  }

  Path _poly(Offset c, int sides, double r) {
    final p = Path();
    for (var i = 0; i < sides; i++) {
      final a = -math.pi / 2 + i * 2 * math.pi / sides;
      final pt = Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a));
      i == 0 ? p.moveTo(pt.dx, pt.dy) : p.lineTo(pt.dx, pt.dy);
    }
    return p..close();
  }

  Color _colorFor(int i) => const [
        Color(0xFF4FC3F7),
        Color(0xFFFFB74D),
        Color(0xFFAED581),
        Color(0xFFBA68C8),
        Color(0xFFE57373),
        Color(0xFF4DB6AC),
      ][i % 6];

  @override
  bool shouldRepaint(covariant _CloudPainter old) =>
      old.t != t || old.dots != dots;
}
```

- [ ] **Step 4: Run it and watch it pass**

```bash
flutter test test/features/footprint/particle_cloud_test.dart
```

Expected: PASS, 5 tests.

- [ ] **Step 5: Prove the reduce-motion test is real**

Delete the `if (reduced || widget.paused)` branch in `_syncTicker` so it always repeats, and re-run. Expected: the reduce-motion test FAILS. Restore.

- [ ] **Step 6: Commit**

```bash
flutter analyze lib/widgets/footprint test/features/footprint
git add lib/widgets/footprint/particle_cloud.dart test/features/footprint/particle_cloud_test.dart
git commit -m "feat(footprint): particle cloud with shape-coded habits

Shape, not colour, identifies a habit. One semantic live region.
Ticker stops for reduce-motion and for the pause control."
```

---

### Task 5: Backend — private `context` column on ideas

**Files:**
- Create: `services/nanoSolve-backend/migrations/048_ideas_context.sql`
- Modify: `services/nanoSolve-backend/src/handlers.rs` (the `match field.name()` block in `submit_idea`, and the INSERT)
- Test: `services/nanoSolve-backend/tests/ideas_context.rs`

**Interfaces:**
- Consumes: nothing.
- Produces: `ideas.context JSONB NULL`, accepted as a multipart field named `context` on `POST /api/ideas`.

The column must never appear in a public response. `models::Idea` is selected with `SELECT *` and serialised straight out of `GET /api/ideas`, so adding a field there would publish every student's habits. It is written here and read only by the evaluator (Task 6).

- [ ] **Step 1: Write the failing test**

Create `services/nanoSolve-backend/tests/ideas_context.rs`:

```rust
//! The context column carries a student's habits. It must reach the
//! evaluator and never reach a public response.

use serde_json::Value;

fn public_idea_json() -> Value {
    // Serialise the public model the list endpoint returns and assert the
    // shape, without needing a database.
    let idea = nanosolve_backend::models::Idea {
        id: uuid::Uuid::nil(),
        nick_name: None,
        email: None,
        description: "test".into(),
        abstract_text: None,
        category: Some("human_entry".into()),
        storage_path: "".into(),
        attachment_count: 0,
        created_at: chrono::Utc::now(),
        updated_at: chrono::Utc::now(),
        status: "new".into(),
        evaluation_status: "not_started".into(),
        impact_score: None,
        impact_tier: None,
        score_confidence: None,
        score_reasoning: None,
        evaluated_at: None,
    };
    serde_json::to_value(idea).unwrap()
}

#[test]
fn public_idea_model_has_no_context_field() {
    let v = public_idea_json();
    assert!(
        v.get("context").is_none(),
        "context must never be serialised into a public idea response"
    );
}

#[test]
fn context_payload_over_limit_is_rejected() {
    let big = "x".repeat(17 * 1024);
    assert!(
        nanosolve_backend::handlers::validate_context(&big).is_err(),
        "a context over 16 KB must be rejected"
    );
}

#[test]
fn context_must_be_valid_json_object() {
    assert!(nanosolve_backend::handlers::validate_context("not json").is_err());
    assert!(nanosolve_backend::handlers::validate_context("[1,2,3]").is_err());
    assert!(nanosolve_backend::handlers::validate_context(
        r#"{"source":"footprint"}"#
    )
    .is_ok());
}
```

- [ ] **Step 2: Run it and watch it fail**

Run from `services/nanoSolve-backend/`:

```bash
cargo test --test ideas_context
```

Expected: FAIL to compile, `cannot find function validate_context`.

- [ ] **Step 3: Write the migration**

Create `services/nanoSolve-backend/migrations/048_ideas_context.sql`:

```sql
-- Context behind an idea: which feature produced it and the numbers the
-- student saw. Private. Never returned by a public endpoint; see
-- tests/ideas_context.rs. Read by the evaluator so a score can account for
-- what prompted the idea.
ALTER TABLE ideas ADD COLUMN IF NOT EXISTS context JSONB;

COMMENT ON COLUMN ideas.context IS
  'Private submission context (source feature, habit answers). Not public.';
```

- [ ] **Step 4: Add the validator and the multipart arm**

In `services/nanoSolve-backend/src/handlers.rs`, add near the top:

```rust
/// Accepts a submission context: a JSON object, at most 16 KB.
/// Returns the parsed value so the caller binds a real JSONB, not a string.
pub fn validate_context(raw: &str) -> Result<serde_json::Value, AppError> {
    const MAX: usize = 16 * 1024;
    if raw.len() > MAX {
        return Err(AppError::InvalidInput("context too large".into()));
    }
    let v: serde_json::Value = serde_json::from_str(raw)
        .map_err(|_| AppError::InvalidInput("context is not valid JSON".into()))?;
    if !v.is_object() {
        return Err(AppError::InvalidInput("context must be an object".into()));
    }
    Ok(v)
}
```

In the `match field.name()` block of `submit_idea`, beside the existing
`Some("category")` arm:

```rust
Some("context") => {
    let raw = field.text().await?;
    context = Some(validate_context(&raw)?);
}
```

Declare `let mut context: Option<serde_json::Value> = None;` with the other
field bindings, and add the column to the INSERT. The column is `NOT NULL`
nowhere, so bind the Option directly:

```rust
// ... existing INSERT gains one column and one bind
"INSERT INTO ideas (nick_name, email, description, category, storage_path, \
  attachment_count, context) VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING id"
```

```rust
.bind(&context)
```

- [ ] **Step 5: Run the test and watch it pass**

```bash
cargo test --test ideas_context
```

Expected: PASS, 3 tests.

- [ ] **Step 6: Prove the exposure test is real**

Temporarily add `pub context: Option<serde_json::Value>,` to `models::Idea` and re-run. Expected: `public_idea_model_has_no_context_field` FAILS. Remove the field again and re-run.

- [ ] **Step 7: Apply the migration and check the endpoints by hand**

```bash
sqlx migrate run
cargo run &
curl -s -X POST http://localhost:3000/api/ideas \
  -F 'description=A wooden board instead of plastic in the kitchen' \
  -F 'category=human_entry' \
  -F 'context={"source":"footprint","largest_by_mass":"cuttingBoard"}' | jq
curl -s http://localhost:3000/api/ideas | jq '.ideas[0] | keys'
```

Expected: the submission succeeds, and the second command's key list contains no `context`.

- [ ] **Step 8: Commit**

```bash
cargo clippy -- -D warnings && cargo test
git add migrations/048_ideas_context.sql src/handlers.rs tests/ideas_context.rs
git commit -m "feat(ideas): private context column for submission provenance

Records which feature and which numbers produced an idea, so the corpus
keeps the why. Deliberately absent from models::Idea, which is serialised
straight into the public list and detail responses."
```

---

### Task 6: Backend — the evaluator reads the context

**Files:**
- Modify: `services/nanoSolve-backend/src/evaluation/scorer.rs`
- Modify: `services/nanoSolve-backend/src/evaluation/mod.rs` (the query that already loads `category`)
- Test: `services/nanoSolve-backend/tests/ideas_context.rs` (extend)

**Interfaces:**
- Consumes: `ideas.context` from Task 5.
- Produces: `pub fn render_context(v: &serde_json::Value) -> String`.

A column nothing reads is decoration. This is the task that makes the field earn its place.

- [ ] **Step 1: Write the failing test**

Append to `services/nanoSolve-backend/tests/ideas_context.rs`:

```rust
#[test]
fn render_context_summarises_a_footprint_submission() {
    let v = serde_json::json!({
        "source": "footprint",
        "largest_by_count": "microwaveMeals",
        "largest_by_mass": "cuttingBoard",
        "prediction": "bottledWater",
        "touched": 6
    });
    let s = nanosolve_backend::evaluation::scorer::render_context(&v);
    assert!(s.contains("footprint"));
    assert!(s.contains("microwaveMeals"));
    assert!(s.contains("cuttingBoard"));
    // Raw JSON in a prompt wastes tokens and invites injection; render prose.
    assert!(!s.contains('{'));
}

#[test]
fn render_context_of_an_empty_object_is_empty() {
    let s = nanosolve_backend::evaluation::scorer::render_context(
        &serde_json::json!({}),
    );
    assert!(s.trim().is_empty());
}
```

- [ ] **Step 2: Run it and watch it fail**

```bash
cargo test --test ideas_context
```

Expected: FAIL to compile, `cannot find function render_context`.

- [ ] **Step 3: Implement**

In `services/nanoSolve-backend/src/evaluation/scorer.rs`:

```rust
/// Turns a submission context into one prose line for the scoring prompt.
/// Only known keys are rendered, so a client cannot inject instructions by
/// inventing fields.
pub fn render_context(v: &serde_json::Value) -> String {
    let get = |k: &str| v.get(k).and_then(|x| x.as_str()).unwrap_or("");
    let source = get("source");
    if source.is_empty() {
        return String::new();
    }
    let mut parts = vec![format!("Submitted from the {source} tool.")];
    let by_count = get("largest_by_count");
    if !by_count.is_empty() {
        parts.push(format!(
            "Their largest habit by particle count was {by_count}."
        ));
    }
    let by_mass = get("largest_by_mass");
    if !by_mass.is_empty() {
        parts.push(format!("By mass it was {by_mass}."));
    }
    let predicted = get("prediction");
    if !predicted.is_empty() && predicted != by_count {
        parts.push(format!(
            "They had guessed {predicted}, so the result surprised them."
        ));
    }
    parts.join(" ")
}
```

Then in the function that builds the user message for an idea, load the column
alongside the category and append the rendered line:

```rust
let context: Option<serde_json::Value> =
    sqlx::query_scalar("SELECT context FROM ideas WHERE id = $1")
        .bind(idea_id)
        .fetch_one(db)
        .await?;
if let Some(c) = context {
    let line = render_context(&c);
    if !line.is_empty() {
        user_message.push_str("\n\nSubmission context: ");
        user_message.push_str(&line);
    }
}
```

- [ ] **Step 4: Run the test and watch it pass**

```bash
cargo test --test ideas_context
```

Expected: PASS, 5 tests.

- [ ] **Step 5: Commit**

```bash
cargo clippy -- -D warnings && cargo test
git add src/evaluation/scorer.rs src/evaluation/mod.rs tests/ideas_context.rs
git commit -m "feat(evaluation): scorer reads submission context

Renders only known keys into one prose line, so a client cannot inject
prompt text by inventing fields."
```

---

### Task 7: Backend — the usage event endpoint

**Files:**
- Create: `services/nanoSolve-backend/migrations/049_app_events.sql`
- Create: `services/nanoSolve-backend/src/events.rs`
- Modify: `services/nanoSolve-backend/src/lib.rs` (declare the module, merge the router)
- Test: `services/nanoSolve-backend/tests/app_events.rs`

**Interfaces:**
- Consumes: nothing.
- Produces: `POST /api/events`, `pub fn router() -> Router<Arc<AppState>>`, `pub const ALLOWED_EVENTS: [&str; 12]`, `pub fn validate_batch(&[EventIn]) -> Result<(), AppError>`.

Self-hosted rather than Firebase Analytics: the backend is already inside the trust boundary, the payload can be kept free of personal data, and it keeps working where Google services do not.

- [ ] **Step 1: Write the failing test**

Create `services/nanoSolve-backend/tests/app_events.rs`:

```rust
use nanosolve_backend::events::{validate_batch, EventIn, ALLOWED_EVENTS};

fn ev(name: &str) -> EventIn {
    EventIn {
        install_id: "3f2504e0-4f89-11d3-9a0c-0305e82c3301".into(),
        name: name.into(),
        locale: "ar".into(),
        platform: "android".into(),
        props: serde_json::json!({}),
    }
}

#[test]
fn a_known_event_is_accepted() {
    assert!(validate_batch(&[ev("footprint_result")]).is_ok());
}

#[test]
fn an_unknown_event_name_is_rejected() {
    assert!(validate_batch(&[ev("something_invented")]).is_err());
}

#[test]
fn a_batch_over_fifty_is_rejected() {
    let batch: Vec<EventIn> = (0..51).map(|_| ev("footprint_result")).collect();
    assert!(validate_batch(&batch).is_err());
}

#[test]
fn an_install_id_that_is_not_a_uuid_is_rejected() {
    let mut e = ev("footprint_result");
    e.install_id = "martin@example.com".into();
    assert!(
        validate_batch(&[e]).is_err(),
        "the install id must be an opaque uuid, never anything identifying"
    );
}

#[test]
fn the_dictionary_matches_the_spec() {
    for name in [
        "explore_opened",
        "footprint_started",
        "footprint_chapter",
        "footprint_abandoned",
        "footprint_result",
        "footprint_view_toggled",
        "footprint_door",
        "footprint_commitment",
        "footprint_explained",
        "footprint_shared",
        "idea_sent",
        "footprint_return",
    ] {
        assert!(ALLOWED_EVENTS.contains(&name), "{name} missing");
    }
}
```

- [ ] **Step 2: Run it and watch it fail**

```bash
cargo test --test app_events
```

Expected: FAIL to compile, `unresolved import nanosolve_backend::events`.

- [ ] **Step 3: Write the migration**

Create `services/nanoSolve-backend/migrations/049_app_events.sql`:

```sql
-- Usage funnel. No personal data: install_id is a random uuid generated on
-- the device and dies when app data is cleared. Rows older than 180 days are
-- deleted; the retention period is stated in the privacy policy.
CREATE TABLE IF NOT EXISTS app_events (
    id          BIGSERIAL PRIMARY KEY,
    install_id  UUID        NOT NULL,
    name        TEXT        NOT NULL,
    at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    locale      TEXT        NOT NULL,
    platform    TEXT        NOT NULL,
    props       JSONB       NOT NULL DEFAULT '{}'::jsonb
);

CREATE INDEX IF NOT EXISTS app_events_at_idx ON app_events (at);
CREATE INDEX IF NOT EXISTS app_events_name_at_idx ON app_events (name, at);
```

- [ ] **Step 4: Implement the module**

Create `services/nanoSolve-backend/src/events.rs`:

```rust
use std::sync::Arc;

use axum::{extract::State, routing::post, Json, Router};
use serde::Deserialize;

use crate::{error::AppError, AppState};

/// The full event dictionary. An unknown name is rejected so this table
/// cannot become a dumping ground for free text.
pub const ALLOWED_EVENTS: [&str; 12] = [
    "explore_opened",
    "footprint_started",
    "footprint_chapter",
    "footprint_abandoned",
    "footprint_result",
    "footprint_view_toggled",
    "footprint_door",
    "footprint_commitment",
    "footprint_explained",
    "footprint_shared",
    "idea_sent",
    "footprint_return",
];

const MAX_BATCH: usize = 50;

#[derive(Debug, Deserialize)]
pub struct EventIn {
    pub install_id: String,
    pub name: String,
    pub locale: String,
    pub platform: String,
    #[serde(default)]
    pub props: serde_json::Value,
}

pub fn validate_batch(batch: &[EventIn]) -> Result<(), AppError> {
    if batch.is_empty() || batch.len() > MAX_BATCH {
        return Err(AppError::InvalidInput(format!(
            "batch must hold 1 to {MAX_BATCH} events"
        )));
    }
    for e in batch {
        if !ALLOWED_EVENTS.contains(&e.name.as_str()) {
            return Err(AppError::InvalidInput(format!(
                "unknown event name: {}",
                e.name
            )));
        }
        if uuid::Uuid::parse_str(&e.install_id).is_err() {
            return Err(AppError::InvalidInput("install_id must be a uuid".into()));
        }
        if e.locale.len() > 8 || e.platform.len() > 16 {
            return Err(AppError::InvalidInput("locale or platform too long".into()));
        }
    }
    Ok(())
}

async fn post_events(
    State(state): State<Arc<AppState>>,
    Json(batch): Json<Vec<EventIn>>,
) -> Result<Json<serde_json::Value>, AppError> {
    validate_batch(&batch)?;
    for e in &batch {
        sqlx::query(
            "INSERT INTO app_events (install_id, name, locale, platform, props) \
             VALUES ($1::uuid, $2, $3, $4, $5)",
        )
        .bind(&e.install_id)
        .bind(&e.name)
        .bind(&e.locale)
        .bind(&e.platform)
        .bind(&e.props)
        .execute(&state.db)
        .await?;
    }
    Ok(Json(serde_json::json!({ "accepted": batch.len() })))
}

pub fn router() -> Router<Arc<AppState>> {
    Router::new().route("/api/events", post(post_events))
}
```

In `services/nanoSolve-backend/src/lib.rs`, add `pub mod events;` beside the
other module declarations and `.merge(events::router())` in the
`rate_limited` router, next to `.merge(digest::router())`.

- [ ] **Step 5: Run the test and watch it pass**

```bash
cargo test --test app_events
```

Expected: PASS, 5 tests.

- [ ] **Step 6: Prove the tests are real**

Remove the `ALLOWED_EVENTS.contains` check and re-run. Expected: the unknown-name test FAILS. Restore.

- [ ] **Step 7: Apply and try it**

```bash
sqlx migrate run
cargo run &
curl -s -X POST http://localhost:3000/api/events -H 'content-type: application/json' \
  -d '[{"install_id":"3f2504e0-4f89-11d3-9a0c-0305e82c3301","name":"footprint_result","locale":"ar","platform":"android","props":{"mode":"story"}}]'
curl -s -X POST http://localhost:3000/api/events -H 'content-type: application/json' \
  -d '[{"install_id":"3f2504e0-4f89-11d3-9a0c-0305e82c3301","name":"nope","locale":"ar","platform":"android","props":{}}]' -i | head -1
```

Expected: the first returns `{"accepted":1}`, the second returns `HTTP/1.1 400 Bad Request`.

- [ ] **Step 8: Add the retention delete**

Add to `049_app_events.sql` a comment naming the retention rule, and add the
delete to the existing scheduled maintenance path used by the other services
(`x_queue_scheduler_state` is the pattern in this codebase):

```sql
DELETE FROM app_events WHERE at < now() - INTERVAL '180 days';
```

- [ ] **Step 9: Commit**

```bash
cargo clippy -- -D warnings && cargo test
git add migrations/049_app_events.sql src/events.rs src/lib.rs tests/app_events.rs
git commit -m "feat(events): self-hosted usage funnel

Fixed event dictionary, uuid-only install id, batch cap, 180-day retention.
Self-hosted rather than Firebase so it keeps working where Google does not."
```

---

### Task 8: Client event service and its off switch

**Files:**
- Create: `nanoplastics_frontend/lib/services/event_service.dart`
- Modify: `nanoplastics_frontend/lib/services/managers/app_preferences_manager.dart`
- Modify: `nanoplastics_frontend/lib/services/settings_manager.dart`
- Test: `nanoplastics_frontend/test/features/footprint/event_service_test.dart`

**Interfaces:**
- Consumes: `POST /api/events` from Task 7.
- Produces: `EventService` with `void log(String name, {Map<String, Object?> props})`, `Future<void> flush()`, `@visibleForTesting http.Client client`, and `SettingsManager.usageStatisticsEnabled` / `setUsageStatisticsEnabled(bool)` / `installId`.

- [ ] **Step 1: Write the failing test**

Create `nanoplastics_frontend/test/features/footprint/event_service_test.dart`:

```dart
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nanoplastics_app/services/event_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('queued events are posted as one batch', () async {
    late String body;
    final service = EventService()
      ..client = MockClient((req) async {
        body = req.body;
        return http.Response('{"accepted":2}', 200);
      });
    await service.init(enabled: true);
    service.log('footprint_started', props: {'mode': 'story'});
    service.log('footprint_result', props: {'mode': 'story'});
    await service.flush();

    final sent = jsonDecode(body) as List;
    expect(sent, hasLength(2));
    expect(sent.first['name'], 'footprint_started');
    expect(sent.first['install_id'], isNotEmpty);
  });

  test('nothing is queued or sent when usage statistics are off', () async {
    var called = false;
    final service = EventService()
      ..client = MockClient((req) async {
        called = true;
        return http.Response('{}', 200);
      });
    await service.init(enabled: false);
    service.log('footprint_started');
    await service.flush();
    expect(called, isFalse);
    expect(service.debugQueueLength, 0);
  });

  test('the install id is a uuid and is stable across restarts', () async {
    final a = EventService();
    await a.init(enabled: true);
    final first = a.installId;
    final b = EventService();
    await b.init(enabled: true);
    expect(b.installId, first);
    expect(
      RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$')
          .hasMatch(first),
      isTrue,
    );
  });

  test('a failed flush drops the batch instead of growing it', () async {
    final service = EventService()
      ..client = MockClient((req) async => http.Response('boom', 500));
    await service.init(enabled: true);
    service.log('footprint_result');
    await service.flush();
    expect(service.debugQueueLength, 0);
  });
}
```

- [ ] **Step 2: Run it and watch it fail**

```bash
flutter test test/features/footprint/event_service_test.dart
```

Expected: FAIL, URI does not exist.

- [ ] **Step 3: Implement**

Create `nanoplastics_frontend/lib/services/event_service.dart`:

```dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../config/backend_config.dart';
import 'logger_service.dart';

/// Usage funnel. Carries no personal data: `install_id` is a random uuid made
/// on this device and lost when app data is cleared.
class EventService {
  static const _installIdKey = 'install_id';
  static const _maxBatch = 50;

  @visibleForTesting
  http.Client client = http.Client();

  bool _enabled = false;
  String _installId = '';
  final List<Map<String, Object?>> _queue = [];

  String get installId => _installId;
  int get debugQueueLength => _queue.length;

  Future<void> init({required bool enabled}) async {
    _enabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_installIdKey);
    if (id == null || id.isEmpty) {
      id = const Uuid().v4();
      await prefs.setString(_installIdKey, id);
    }
    _installId = id;
  }

  void setEnabled(bool value) {
    _enabled = value;
    if (!value) _queue.clear();
  }

  void log(String name, {Map<String, Object?> props = const {}}) {
    if (!_enabled) return;
    if (_queue.length >= _maxBatch) return;
    _queue.add({
      'install_id': _installId,
      'name': name,
      'locale': WidgetsBinding.instance.platformDispatcher.locale.languageCode,
      'platform': defaultTargetPlatform.name,
      'props': props,
    });
  }

  /// Best effort. A failure drops the batch rather than growing a queue that
  /// would eventually post a month of stale events at once.
  Future<void> flush() async {
    if (!_enabled || _queue.isEmpty) return;
    final batch = List<Map<String, Object?>>.from(_queue);
    _queue.clear();
    try {
      await client
          .post(
            Uri.parse('${BackendConfig.getBaseUrl()}/api/events'),
            headers: const {'content-type': 'application/json'},
            body: jsonEncode(batch),
          )
          .timeout(const Duration(seconds: 8));
    } catch (e) {
      LoggerService().logWarning('event flush failed: $e');
    }
  }
}
```

In `app_preferences_manager.dart`, following the existing getter and setter
pattern used by `hasShownOnboarding`:

```dart
static const String _usageStatisticsKey = 'usage_statistics_enabled';

bool get usageStatisticsEnabled =>
    _prefs.getBool(_usageStatisticsKey) ?? true;

Future<void> setUsageStatisticsEnabled(bool value) async {
  await _prefs.setBool(_usageStatisticsKey, value);
}
```

Expose both through `SettingsManager` the way the other preferences are
delegated.

- [ ] **Step 4: Run the test and watch it pass**

```bash
flutter test test/features/footprint/event_service_test.dart
```

Expected: PASS, 4 tests.

- [ ] **Step 5: Prove the off switch test is real**

Delete the `if (!_enabled) return;` line from `log` and re-run. Expected: the off-switch test FAILS. Restore it.

- [ ] **Step 6: Commit**

```bash
flutter analyze lib/services test/features/footprint
git add lib/services/event_service.dart lib/services/managers/app_preferences_manager.dart lib/services/settings_manager.dart test/features/footprint/event_service_test.dart
git commit -m "feat(events): client funnel with a real off switch

Random install id, batch post, failures dropped rather than accumulated.
Off means nothing is queued, not merely nothing is sent."
```

---

### Task 9: Explore screen, hub centre entry, first-run routing

**Files:**
- Create: `nanoplastics_frontend/lib/screens/explore_screen.dart`
- Modify: `nanoplastics_frontend/lib/screens/main_screen.dart`
- Modify: `nanoplastics_frontend/lib/services/managers/app_preferences_manager.dart`
- Modify: `nanoplastics_frontend/assets/l10n/app_en.arb`, `nanoplastics_frontend/assets/l10n/app_ar.arb`
- Test: `nanoplastics_frontend/test/features/footprint/explore_screen_test.dart`

**Interfaces:**
- Consumes: `EventService` from Task 8.
- Produces: `ExploreScreen`, `SettingsManager.hasSeenExplore` / `setExploreSeen(bool)`.

The hub is a fixed 2x2 quadrant and its `HubButtonPosition` enum has exactly four values. Do not add a fifth. The Explore entry is a separate centre button drawn between the quadrants.

- [ ] **Step 1: Write the failing test**

Create `nanoplastics_frontend/test/features/footprint/explore_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/screens/explore_screen.dart';
import '../../helpers/test_app.dart';
import '../../helpers/settings_test_helper.dart';

void main() {
  setUp(() async => await setupTestSettings());

  testWidgets('the Explore screen lists the footprint card', (t) async {
    await t.pumpWidget(testApp(const ExploreScreen()));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('explore-card-footprint')), findsOneWidget);
  });

  testWidgets('renders at 375x667 without overflow', (t) async {
    t.view.physicalSize = const Size(375, 667);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.reset);
    await t.pumpWidget(testApp(const ExploreScreen()));
    await t.pumpAndSettle();
    expect(tester_takeException(), isNull);
  });

  testWidgets('renders in Arabic without overflow', (t) async {
    t.view.physicalSize = const Size(375, 667);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.reset);
    await t.pumpWidget(testApp(const ExploreScreen(), locale: const Locale('ar')));
    await t.pumpAndSettle();
    expect(find.byType(Directionality), findsWidgets);
  });

  testWidgets('the footprint card is a labelled, tappable Semantics node',
      (t) async {
    await t.pumpWidget(testApp(const ExploreScreen()));
    await t.pumpAndSettle();
    final node = t.getSemantics(find.byKey(const Key('explore-card-footprint')));
    expect(node.label, isNotEmpty);
    expect(node.hasAction(SemanticsAction.tap), isTrue);
  });
}

Object? tester_takeException() => null; // overflow surfaces as a pump failure
```

- [ ] **Step 2: Run it and watch it fail**

```bash
flutter test test/features/footprint/explore_screen_test.dart
```

Expected: FAIL, URI does not exist. If `test/helpers/test_app.dart` has no `locale` parameter, add one that wraps the child in a `MaterialApp` with `AppLocalizations.delegate` and the given locale; the existing helper already builds the localisation delegates.

- [ ] **Step 3: Add the strings**

In `assets/l10n/app_en.arb`:

```json
"exploreTitle": "Explore",
"exploreSubtitle": "Tools that show the problem in your own day",
"exploreFootprintTitle": "Your plastic year",
"exploreFootprintHook": "How much plastic is in your year?",
"exploreSkip": "Not now"
```

In `assets/l10n/app_ar.arb`, the same keys with Arabic values:

```json
"exploreTitle": "استكشف",
"exploreSubtitle": "أدوات تُظهر المشكلة في يومك أنت",
"exploreFootprintTitle": "سنتك البلاستيكية",
"exploreFootprintHook": "كم من البلاستيك يمرّ في سنتك؟",
"exploreSkip": "ليس الآن"
```

Then:

```bash
flutter gen-l10n
```

Do not add these keys to `app_cs.arb`, `app_es.arb`, `app_fr.arb` or
`app_ru.arb`. Add one line per key to `docs/l10n-queue.md` instead.

- [ ] **Step 4: Write the screen and the hub entry**

Create `explore_screen.dart` as a `StatefulWidget` following the structure of
`solvers_leaderboard_screen.dart`: `ScreenHeader`, a scrolling `Column` of
cards built with `CategoryCard`, all sizes from `AppSpacing` and `AppSizing`.
Each card is wrapped in `Semantics(button: true, label: ...)` and uses
`InkWell`. Give the footprint card `key: const Key('explore-card-footprint')`.
On open, call `ServiceLocator().eventService.log('explore_opened', props: {'first_run': firstRun})`.

In `main_screen.dart`, add a centre button between the four `HubButton`
quadrants. Do not touch `HubButtonPosition`. Place it in the existing `Stack`
that lays out the quadrants, centred, sized from `AppSizing`, wrapped in
`Semantics(button: true)`, opening `ExploreScreen` with `Navigator.push`.

Add the first-run routing in `main_screen.dart`'s `initState`, using
`addPostFrameCallback` because it navigates:

```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  if (!mounted) return;
  if (!SettingsManager().hasSeenExplore) {
    SettingsManager().setExploreSeen(true);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ExploreScreen(firstRun: true)),
    );
  }
});
```

Add `hasSeenExplore` and `setExploreSeen` to `app_preferences_manager.dart`
following the `hasShownOnboarding` pattern.

- [ ] **Step 5: Run the tests and watch them pass**

```bash
flutter test test/features/footprint/explore_screen_test.dart
flutter test
```

Expected: the new file passes, and the whole suite stays green. If
`test/responsive/screen_overflow_test.dart` enumerates screens, add
`ExploreScreen` to it.

- [ ] **Step 6: Commit**

```bash
flutter analyze
git add lib/screens/explore_screen.dart lib/screens/main_screen.dart lib/services/managers/app_preferences_manager.dart assets/l10n/app_en.arb assets/l10n/app_ar.arb test/features/footprint/explore_screen_test.dart
git commit -m "feat(explore): tools screen with hub centre entry

Centre button keeps the 2x2 quadrant geometry intact. First run routes
here once so a new install finds the tools instead of guessing."
```

---

### Task 10: Story screen

**Files:**
- Create: `nanoplastics_frontend/lib/screens/footprint/footprint_story_screen.dart`
- Create: `nanoplastics_frontend/lib/widgets/footprint/chapter_page.dart`
- Modify: `nanoplastics_frontend/assets/l10n/app_en.arb`, `nanoplastics_frontend/assets/l10n/app_ar.arb`
- Test: `nanoplastics_frontend/test/features/footprint/story_screen_test.dart`

**Interfaces:**
- Consumes: `kChapters`, `FootprintInput`, `estimate`, `ParticleCloud`, `EventService`.
- Produces: `FootprintStoryScreen`, which pushes `FootprintResultScreen` (Task 12) with the finished `FootprintInput`.

Two decisions here are not style preferences and must not be "simplified" later. The `PageView` uses `NeverScrollableScrollPhysics`, and the cloud lives above the `PageView` rather than inside a page.

- [ ] **Step 1: Write the failing test**

Create `nanoplastics_frontend/test/features/footprint/story_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/features/footprint/chapters.dart';
import 'package:nanoplastics_app/screens/footprint/footprint_story_screen.dart';
import 'package:nanoplastics_app/widgets/footprint/particle_cloud.dart';
import '../../helpers/test_app.dart';
import '../../helpers/settings_test_helper.dart';

void main() {
  setUp(() async => await setupTestSettings());

  testWidgets('the story opens on an intro with a start and a skip', (t) async {
    await t.pumpWidget(testApp(const FootprintStoryScreen()));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('story-start')), findsOneWidget);
    expect(find.byKey(const Key('story-skip')), findsOneWidget);
  });

  testWidgets('paging is by button, never by swipe', (t) async {
    await t.pumpWidget(testApp(const FootprintStoryScreen()));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('story-start')));
    await t.pumpAndSettle();

    final view = t.widget<PageView>(find.byType(PageView));
    expect(view.physics, isA<NeverScrollableScrollPhysics>(),
        reason:
            'the app installs a right-edge back gesture for RTL that would '
            'eat a forward swipe, and sliders fight a horizontal PageView');
  });

  testWidgets('there is exactly one cloud, above the pages', (t) async {
    await t.pumpWidget(testApp(const FootprintStoryScreen()));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('story-start')));
    await t.pumpAndSettle();
    expect(find.byType(ParticleCloud), findsOneWidget);
  });

  testWidgets('moving a control marks the chapter as touched', (t) async {
    await t.pumpWidget(testApp(const FootprintStoryScreen()));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('story-start')));
    await t.pumpAndSettle();

    final state = t.state<FootprintStoryScreenState>(
        find.byType(FootprintStoryScreen));
    expect(state.input.touched, isEmpty);
    await t.tap(find.byKey(const Key('chip-waterSource-1')));
    await t.pumpAndSettle();
    expect(state.input.touched, isNotEmpty);
  });

  testWidgets('accepting the default also counts as an answer', (t) async {
    await t.pumpWidget(testApp(const FootprintStoryScreen()));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('story-start')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('confirm-default-water')));
    await t.pumpAndSettle();
    final state = t.state<FootprintStoryScreenState>(
        find.byType(FootprintStoryScreen));
    expect(state.input.touched, isNotEmpty);
  });

  testWidgets('every chapter renders at 375x667 in English and Arabic',
      (t) async {
    t.view.physicalSize = const Size(375, 667);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.reset);
    for (final locale in [const Locale('en'), const Locale('ar')]) {
      await t.pumpWidget(testApp(const FootprintStoryScreen(), locale: locale));
      await t.pumpAndSettle();
      await t.tap(find.byKey(const Key('story-start')));
      await t.pumpAndSettle();
      for (var i = 0; i < kChapters.length - 1; i++) {
        await t.tap(find.byKey(const Key('story-next')));
        await t.pumpAndSettle();
      }
    }
  });

  testWidgets('every chapter renders at 200 percent text scale', (t) async {
    t.view.physicalSize = const Size(375, 667);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.reset);
    await t.pumpWidget(testApp(
      const FootprintStoryScreen(),
      textScaleFactor: 2.0,
    ));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('story-start')));
    await t.pumpAndSettle();
    for (var i = 0; i < kChapters.length - 1; i++) {
      await t.tap(find.byKey(const Key('story-next')));
      await t.pumpAndSettle();
    }
  });
}
```

- [ ] **Step 2: Run it and watch it fail**

```bash
flutter test test/features/footprint/story_screen_test.dart
```

Expected: FAIL, URI does not exist. Add a `textScaleFactor` parameter to
`test/helpers/test_app.dart` that wraps the child in a `MediaQuery` with
`textScaler: TextScaler.linear(factor)`.

- [ ] **Step 3: Add the strings**

Add to `app_en.arb` and `app_ar.arb`, in the same commit: `footprintIntroTitle`,
`footprintIntroBody`, `footprintStart`, `footprintSkipStory`, `footprintNext`,
`footprintBack`, `footprintConfirmDefault`, `footprintPredictQuestion`, and
one `footprintScene*` / `footprintWhy*` / `footprintQ*` / `footprintOpt*` /
`footprintUnit*` key for every string named in `chapters.dart`. The intro body
in English is:

```json
"footprintIntroBody": "Nanoplastics are plastic pieces smaller than a bacterium. You cannot see them. Let us walk through one of your days and count them.",
"footprintIntroReassurance": "None of this is your fault. The plastic was chosen for you."
```

Run `flutter gen-l10n`. Add every new key to `docs/l10n-queue.md`.

- [ ] **Step 4: Write `chapter_page.dart`**

A `StatelessWidget` taking a `Chapter`, the current `FootprintInput`, and
`onChanged(FootprintInput)`. It renders the scene line, then one control per
`ControlSpec`:

- `ControlKind.slider` becomes a `Slider` with
  `semanticFormatterCallback: (v) => '${v.round()} ${l10n(unitKey)}'` so a
  screen reader announces bottles and meals rather than percentages. Key it
  `Key('slider-${spec.field}')`.
- `ControlKind.chips` becomes a `Wrap` of `ChoiceChip`s, each keyed
  `Key('chip-${spec.field}-$index')` and wrapped in
  `Semantics(button: true, selected: isSelected)`.

Below the controls, a `TextButton` keyed `Key('confirm-default-${chapter.key.name}')`
with the label `footprintConfirmDefault`, so accepting a default is one tap and
still counts as an answer. Below that, the why line, shown expanded on first
read and collapsed to a tappable summary afterwards, keyed per chapter in
`SettingsManager`.

Every size comes from `AppSpacing` / `AppSizing`; every text style from
`AppTypography`. The page body is a `SingleChildScrollView` so 200% text scale
scrolls instead of clipping.

- [ ] **Step 5: Write `footprint_story_screen.dart`**

```dart
class FootprintStoryScreen extends StatefulWidget {
  const FootprintStoryScreen({super.key});
  @override
  State<FootprintStoryScreen> createState() => FootprintStoryScreenState();
}

class FootprintStoryScreenState extends State<FootprintStoryScreen> {
  final _controller = PageController();
  FootprintInput input = FootprintInput.gulfDefault();
  bool _started = false;
  bool _cloudPaused = false;
  int _index = 0;

  void _touch(ChapterKey key) =>
      setState(() => input = input.copyWith(touched: {...input.touched, key}));

  void _next() {
    final events = ServiceLocator().eventService;
    if (_index == kChapters.length - 1) {
      events.log('footprint_result',
          props: {'mode': 'story', 'touched_count': input.touched.length});
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => FootprintResultScreen(input: input),
      ));
      return;
    }
    setState(() => _index++);
    _controller.animateToPage(_index,
        duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    events.log('footprint_chapter',
        props: {'index': _index, 'touched': input.touched.length});
  }
  // build(): Column of [ParticleCloud(...), progress dots,
  //   Expanded(PageView(physics: NeverScrollableScrollPhysics(), ...)),
  //   Row(Back, Next)]
}
```

The cloud is built once, above the `PageView`, from
`estimate(input).byFamily(Family.swallowedSubMicron)`, so a page change never
animates two clouds. On leaving without reaching the result, log
`footprint_abandoned` with the index from `dispose`.

- [ ] **Step 6: Run the tests and watch them pass**

```bash
flutter test test/features/footprint/story_screen_test.dart
```

Expected: PASS, 7 tests.

- [ ] **Step 7: Prove the physics test is real**

Change the `PageView` to `physics: const PageScrollPhysics()` and re-run.
Expected: the paging test FAILS. Restore `NeverScrollableScrollPhysics`.

- [ ] **Step 8: Commit**

```bash
flutter analyze && flutter test
git add lib/screens/footprint lib/widgets/footprint/chapter_page.dart assets/l10n/app_en.arb assets/l10n/app_ar.arb test/features/footprint/story_screen_test.dart docs/l10n-queue.md
git commit -m "feat(footprint): seven-chapter story screen

Button paging, not swipe: the RTL edge-back overlay in main.dart eats a
forward swipe and sliders fight a horizontal PageView. One cloud above the
pages. Defaults are not answers until confirmed."
```

---

### Task 11: Breakdown chart with count and weight

**Files:**
- Create: `nanoplastics_frontend/lib/widgets/footprint/habit_bar_chart.dart`
- Modify: `nanoplastics_frontend/pubspec.yaml`
- Test: `nanoplastics_frontend/test/features/footprint/habit_bar_chart_test.dart`

**Interfaces:**
- Consumes: `FootprintResult`, `HabitEstimate`.
- Produces: `HabitBarChart({required FootprintResult result, required BarMode mode, required ValueChanged<BarMode> onModeChanged})`, `enum BarMode { count, weight }`.

Habit values span nine orders of magnitude. On a linear axis every bar but one is a hairline, so lengths are `log10`. Switching to weight reorders the bars, and that reversal is the point of the panel.

- [ ] **Step 1: Add the dependency**

In `pubspec.yaml`, under `dependencies`, after `qr_flutter`:

```yaml
  fl_chart: ^0.69.0
```

```bash
flutter pub get
```

- [ ] **Step 2: Write the failing test**

Create `nanoplastics_frontend/test/features/footprint/habit_bar_chart_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/features/footprint/footprint_model.dart';
import 'package:nanoplastics_app/features/footprint/footprint_types.dart';
import 'package:nanoplastics_app/widgets/footprint/habit_bar_chart.dart';
import '../../helpers/test_app.dart';

void main() {
  final result = estimate(FootprintInput.gulfDefault());

  testWidgets('count mode leads with the microwaved lunch box', (t) async {
    await t.pumpWidget(testApp(HabitBarChart(
      result: result,
      mode: BarMode.count,
      onModeChanged: (_) {},
    )));
    await t.pumpAndSettle();
    final state = t.state<HabitBarChartState>(find.byType(HabitBarChart));
    expect(state.orderedHabits.first, Habit.microwaveMeals);
  });

  testWidgets('weight mode leads with the cutting board', (t) async {
    await t.pumpWidget(testApp(HabitBarChart(
      result: result,
      mode: BarMode.weight,
      onModeChanged: (_) {},
    )));
    await t.pumpAndSettle();
    final state = t.state<HabitBarChartState>(find.byType(HabitBarChart));
    expect(state.orderedHabits.first, Habit.cuttingBoard);
  });

  testWidgets('bar lengths are logarithmic, so nothing is a hairline',
      (t) async {
    await t.pumpWidget(testApp(HabitBarChart(
      result: result,
      mode: BarMode.count,
      onModeChanged: (_) {},
    )));
    await t.pumpAndSettle();
    final state = t.state<HabitBarChartState>(find.byType(HabitBarChart));
    final lengths = state.debugBarLengths;
    final smallest = lengths.where((l) => l > 0).reduce((a, b) => a < b ? a : b);
    final largest = lengths.reduce((a, b) => a > b ? a : b);
    // Linear would put this ratio near 1e-9.
    expect(smallest / largest, greaterThan(0.05));
  });

  testWidgets('every bar carries an icon and a text label, not just a colour',
      (t) async {
    await t.pumpWidget(testApp(HabitBarChart(
      result: result,
      mode: BarMode.count,
      onModeChanged: (_) {},
    )));
    await t.pumpAndSettle();
    final state = t.state<HabitBarChartState>(find.byType(HabitBarChart));
    for (final h in state.orderedHabits) {
      expect(find.byKey(Key('bar-label-${h.name}')), findsOneWidget);
      expect(find.byKey(Key('bar-icon-${h.name}')), findsOneWidget);
    }
  });

  testWidgets('each bar states its method and floor', (t) async {
    await t.pumpWidget(testApp(HabitBarChart(
      result: result,
      mode: BarMode.count,
      onModeChanged: (_) {},
    )));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('bar-tag-microwaveMeals')), findsOneWidget);
  });

  testWidgets('the mode toggle reports the mode the student chose', (t) async {
    BarMode? chosen;
    await t.pumpWidget(testApp(HabitBarChart(
      result: result,
      mode: BarMode.count,
      onModeChanged: (m) => chosen = m,
    )));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('bar-mode-weight')));
    expect(chosen, BarMode.weight);
  });

  testWidgets('renders in Arabic with an explicit Directionality', (t) async {
    await t.pumpWidget(testApp(
      HabitBarChart(
        result: result,
        mode: BarMode.count,
        onModeChanged: (_) {},
      ),
      locale: const Locale('ar'),
    ));
    await t.pumpAndSettle();
    expect(find.byType(Directionality), findsWidgets);
  });
}
```

- [ ] **Step 3: Run it and watch it fail**

```bash
flutter test test/features/footprint/habit_bar_chart_test.dart
```

Expected: FAIL, URI does not exist.

- [ ] **Step 4: Implement**

Create `habit_bar_chart.dart`. The parts that matter:

```dart
enum BarMode { count, weight }

class HabitBarChartState extends State<HabitBarChart> {
  List<Habit> get orderedHabits => _rows.map((r) => r.habit).toList();
  List<double> get debugBarLengths => _rows.map(_lengthOf).toList();

  List<HabitEstimate> get _rows => widget.mode == BarMode.count
      ? [
          for (final f in Family.values) ...widget.result.byFamily(f),
        ].where((h) => h.particlesPerYear > 0).toList()
      : widget.result.habitsWithMass;

  /// Values here span nine orders of magnitude. A linear axis would draw
  /// every bar but one as a hairline, so lengths are log10 of the value,
  /// normalised to the largest. The axis says so in words.
  double _lengthOf(HabitEstimate h) {
    final v = widget.mode == BarMode.count
        ? h.particlesPerYear
        : (h.massMgPerYear ?? 0);
    if (v <= 0) return 0;
    final maxV = _rows
        .map((r) => widget.mode == BarMode.count
            ? r.particlesPerYear
            : (r.massMgPerYear ?? 0))
        .reduce((a, b) => a > b ? a : b);
    final lo = 1.0; // one particle, or one milligram
    return (math.log(v) - math.log(lo)) / (math.log(maxV) - math.log(lo));
  }
}
```

Sorting in count mode is within a family, and the family header names its
floor. Each row is: `Icon` keyed `bar-icon-<habit>`, `Text` keyed
`bar-label-<habit>`, the bar itself, and a tag line keyed `bar-tag-<habit>`
reading for example "counted from 30 nm, not identified, disputed". Tapping a
row opens a sheet with `HabitEstimate.source`.

Above the chart sits a two-button toggle keyed `bar-mode-count` and
`bar-mode-weight`, and beneath it the fixed caption: "A bigger bar can mean a
better microscope, not more plastic. Switch to weight to compare fairly."

Wrap the `fl_chart` widget in an explicit `Directionality` taken from the
ambient locale, because the chart draws its own axis.

- [ ] **Step 5: Run the tests and watch them pass**

```bash
flutter test test/features/footprint/habit_bar_chart_test.dart
```

Expected: PASS, 7 tests.

- [ ] **Step 6: Prove the log-scale test is real**

Replace `_lengthOf` with the linear `v / maxV` and re-run. Expected: the
logarithmic test FAILS with a ratio near 1e-9. Restore.

- [ ] **Step 7: Commit**

```bash
flutter analyze && flutter test
git add pubspec.yaml pubspec.lock lib/widgets/footprint/habit_bar_chart.dart test/features/footprint/habit_bar_chart_test.dart
git commit -m "feat(footprint): breakdown chart on a log scale

Nine orders of magnitude need a log axis. Count and weight orders differ,
and the toggle makes that reversal the lesson rather than a footnote."
```

---

### Task 12: Result screen, panels 0 to 2

**Files:**
- Create: `nanoplastics_frontend/lib/screens/footprint/footprint_result_screen.dart`
- Create: `nanoplastics_frontend/lib/features/footprint/footprint_strings_l10n.dart`
- Modify: `nanoplastics_frontend/assets/l10n/app_en.arb`, `nanoplastics_frontend/assets/l10n/app_ar.arb`
- Test: `nanoplastics_frontend/test/features/footprint/result_screen_test.dart`

**Interfaces:**
- Consumes: `FootprintResult`, `HabitBarChart`, `ParticleCloud`, `formatParticles`.
- Produces: `FootprintResultScreen({required FootprintInput input})`, `class L10nFootprintStrings implements FootprintStrings`.

- [ ] **Step 1: Write the failing test**

Create `nanoplastics_frontend/test/features/footprint/result_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/features/footprint/footprint_model.dart';
import 'package:nanoplastics_app/features/footprint/footprint_types.dart';
import 'package:nanoplastics_app/screens/footprint/footprint_result_screen.dart';
import 'package:nanoplastics_app/widgets/footprint/particle_cloud.dart';
import '../../helpers/test_app.dart';
import '../../helpers/settings_test_helper.dart';

void main() {
  setUp(() async => await setupTestSettings());

  FootprintInput answered() => FootprintInput.gulfDefault()
      .copyWith(touched: ChapterKey.values.toSet(), prediction: Habit.bottledWater);

  testWidgets('the headline resolves the prediction against the answer',
      (t) async {
    await t.pumpWidget(testApp(FootprintResultScreen(input: answered())));
    await t.pumpAndSettle();
    final headline = t.widget<Text>(find.byKey(const Key('result-headline')));
    expect(headline.data, isNotNull);
    expect(find.byKey(const Key('result-prediction')), findsOneWidget);
  });

  testWidgets('one cloud per family, each captioned with its floor', (t) async {
    await t.pumpWidget(testApp(FootprintResultScreen(input: answered())));
    await t.pumpAndSettle();
    expect(find.byType(ParticleCloud), findsNWidgets(Family.values.length));
    expect(find.byKey(const Key('floor-caption-swallowedSubMicron')),
        findsOneWidget);
  });

  testWidgets('the open question about breathed nano sits between the clouds',
      (t) async {
    await t.pumpWidget(testApp(FootprintResultScreen(input: answered())));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('result-open-question')), findsOneWidget);
  });

  testWidgets('no grand total and no percentage appear anywhere', (t) async {
    await t.pumpWidget(testApp(FootprintResultScreen(input: answered())));
    await t.pumpAndSettle();
    final texts = t
        .widgetList<Text>(find.byType(Text))
        .map((w) => w.data ?? '')
        .join(' ');
    expect(texts, isNot(contains('%')));
    expect(texts.toLowerCase(), isNot(contains('total')));
  });

  testWidgets('unanswered chapters are shown as unanswered, not as answers',
      (t) async {
    final partial = FootprintInput.gulfDefault()
        .copyWith(touched: {ChapterKey.water});
    await t.pumpWidget(testApp(FootprintResultScreen(input: partial)));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('result-touched-count')), findsOneWidget);
    final label = t.widget<Text>(find.byKey(const Key('result-touched-count')));
    expect(label.data, contains('1'));
  });

  testWidgets('renders at 375x667 and at 200 percent text scale', (t) async {
    t.view.physicalSize = const Size(375, 667);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.reset);
    await t.pumpWidget(testApp(FootprintResultScreen(input: answered())));
    await t.pumpAndSettle();
    await t.pumpWidget(testApp(
      FootprintResultScreen(input: answered()),
      textScaleFactor: 2.0,
    ));
    await t.pumpAndSettle();
  });
}
```

- [ ] **Step 2: Run it and watch it fail**

```bash
flutter test test/features/footprint/result_screen_test.dart
```

Expected: FAIL, URI does not exist.

- [ ] **Step 3: Add the strings**

New keys in `app_en.arb` and `app_ar.arb`: `footprintResultTitle`,
`footprintHeadlineTemplate`, `footprintPredictionRight`,
`footprintPredictionWrong`, `footprintTouchedCount`, `footprintFloorCaption`,
`footprintOpenQuestionAir`, `footprintMethodCaption`, `footprintAbout`,
`footprintMillion`, `footprintBillion`, `footprintTrillion`,
`footprintPerSecond`, `footprintMilligram`, `footprintGram`, and the habit
name keys `footprintHabit<Name>`.

`footprintHeadlineTemplate` in English:

```json
"footprintHeadlineTemplate": "Your biggest single source is {habit}, at {count} particles a year. By weight it is {massHabit}.",
"@footprintHeadlineTemplate": {
  "placeholders": {
    "habit": {"type": "String"},
    "count": {"type": "String"},
    "massHabit": {"type": "String"}
  }
},
"footprintOpenQuestionAir": "Nobody has counted the smallest particles in the air you breathe. That is an open research question."
```

Run `flutter gen-l10n`.

- [ ] **Step 4: Implement the strings adapter**

Create `footprint_strings_l10n.dart`:

```dart
import '../../l10n/app_localizations.dart';
import 'footprint_format.dart';

class L10nFootprintStrings implements FootprintStrings {
  final AppLocalizations l;
  const L10nFootprintStrings(this.l);
  @override String get about => l.footprintAbout;
  @override String get million => l.footprintMillion;
  @override String get billion => l.footprintBillion;
  @override String get trillion => l.footprintTrillion;
  @override String get perSecond => l.footprintPerSecond;
  @override String get milligram => l.footprintMilligram;
  @override String get gram => l.footprintGram;
}
```

- [ ] **Step 5: Implement panels 0 to 2**

`FootprintResultScreen` is a `StatefulWidget` holding `BarMode mode` and
`bool cloudPaused`. Its body is a `ListView` of panels:

- Panel 0, keyed `result-headline` and `result-prediction`: the headline
  sentence built from `result.headlineHabit` and
  `result.habitsWithMass.first.habit`, formatted through
  `formatParticles(..., L10nFootprintStrings(l10n))`, plus
  `result-touched-count` reading "You answered 6 of 7". Numbers inside Arabic
  sentences go through `isolate()`.
- Panel 1: one `ParticleCloud` per `Family` with a `floor-caption-<family>`
  under each, and `result-open-question` between the swallowed clouds and the
  breathed one.
- Panel 2: `HabitBarChart` with `mode` and `onModeChanged`, logging
  `footprint_view_toggled`.

No panel computes a sum across families and none renders a percent sign.

- [ ] **Step 6: Run the tests and watch them pass**

```bash
flutter test test/features/footprint/result_screen_test.dart
```

Expected: PASS, 6 tests.

- [ ] **Step 7: Prove the no-total test is real**

Add a temporary `Text('Total: 100%')` to panel 0 and re-run. Expected: the
no-total test FAILS. Remove it.

- [ ] **Step 8: Commit**

```bash
flutter analyze && flutter test
git add lib/screens/footprint/footprint_result_screen.dart lib/features/footprint/footprint_strings_l10n.dart assets/l10n/app_en.arb assets/l10n/app_ar.arb test/features/footprint/result_screen_test.dart docs/l10n-queue.md
git commit -m "feat(footprint): result headline, clouds and breakdown

One cloud per counting family, each captioned with its size floor.
A test fails the build if a grand total or a percentage comes back."
```

---

### Task 13: Panels 3 to 5 — swap, commitment, charge, say it back

**Files:**
- Modify: `nanoplastics_frontend/lib/screens/footprint/footprint_result_screen.dart`
- Create: `nanoplastics_frontend/lib/widgets/footprint/charge_panel.dart`
- Modify: `nanoplastics_frontend/lib/services/managers/app_preferences_manager.dart`
- Modify: `nanoplastics_frontend/assets/l10n/app_en.arb`, `nanoplastics_frontend/assets/l10n/app_ar.arb`
- Test: `nanoplastics_frontend/test/features/footprint/result_actions_test.dart`

**Interfaces:**
- Consumes: `FootprintResult.withChange`, `Swap`, `EventService`.
- Produces: `ChargePanel`, `SettingsManager.footprintCommitment` / `setFootprintCommitment(String, DateTime)`.

Panel 3 is what the literature says converts a number into a behaviour. Panel 5 is what turns reading into learning. Neither is decoration.

- [ ] **Step 1: Write the failing test**

Create `nanoplastics_frontend/test/features/footprint/result_actions_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/features/footprint/footprint_model.dart';
import 'package:nanoplastics_app/features/footprint/footprint_types.dart';
import 'package:nanoplastics_app/screens/footprint/footprint_result_screen.dart';
import 'package:nanoplastics_app/services/settings_manager.dart';
import 'package:nanoplastics_app/widgets/footprint/charge_panel.dart';
import '../../helpers/test_app.dart';
import '../../helpers/settings_test_helper.dart';

FootprintInput answered() =>
    FootprintInput.gulfDefault().copyWith(touched: ChapterKey.values.toSet());

void main() {
  setUp(() async => await setupTestSettings());

  testWidgets('the swap panel offers a substitution, never "stop"', (t) async {
    await t.pumpWidget(testApp(FootprintResultScreen(input: answered())));
    await t.pumpAndSettle();
    await t.dragUntilVisible(find.byKey(const Key('panel-swap')),
        find.byType(ListView), const Offset(0, -300));
    final texts = t
        .widgetList<Text>(find.descendant(
            of: find.byKey(const Key('panel-swap')), matching: find.byType(Text)))
        .map((w) => (w.data ?? '').toLowerCase())
        .join(' ');
    expect(texts, isNot(contains('stop ')));
    expect(texts, contains('could'));
  });

  testWidgets('swaps are split into yours and your household\'s', (t) async {
    await t.pumpWidget(testApp(FootprintResultScreen(input: answered())));
    await t.pumpAndSettle();
    await t.dragUntilVisible(find.byKey(const Key('panel-swap')),
        find.byType(ListView), const Offset(0, -300));
    expect(find.byKey(const Key('swaps-yours')), findsOneWidget);
    expect(find.byKey(const Key('swaps-household')), findsOneWidget);
  });

  testWidgets('a commitment is stored with a when and a where', (t) async {
    await t.pumpWidget(testApp(FootprintResultScreen(input: answered())));
    await t.pumpAndSettle();
    await t.dragUntilVisible(find.byKey(const Key('commitment-field')),
        find.byType(ListView), const Offset(0, -300));
    await t.enterText(find.byKey(const Key('commitment-field')),
        'When I take lunch from the fridge, I will move it to a glass dish');
    await t.tap(find.byKey(const Key('commitment-save')));
    await t.pumpAndSettle();
    expect(SettingsManager().footprintCommitment, contains('glass dish'));
  });

  testWidgets('the charge panel has three states and a manual control',
      (t) async {
    await t.pumpWidget(testApp(FootprintResultScreen(input: answered())));
    await t.pumpAndSettle();
    await t.dragUntilVisible(find.byType(ChargePanel), find.byType(ListView),
        const Offset(0, -300));
    final state = t.state<ChargePanelState>(find.byType(ChargePanel));
    expect(state.stageCount, 3);
    await t.tap(find.byKey(const Key('charge-next')));
    await t.pumpAndSettle();
    expect(state.stage, 1);
  });

  testWidgets('the charge panel separates what is known from what is not',
      (t) async {
    await t.pumpWidget(testApp(FootprintResultScreen(input: answered())));
    await t.pumpAndSettle();
    await t.dragUntilVisible(find.byKey(const Key('charge-known')),
        find.byType(ListView), const Offset(0, -300));
    expect(find.byKey(const Key('charge-known')), findsOneWidget);
    expect(find.byKey(const Key('charge-not-known')), findsOneWidget);
  });

  testWidgets('say-it-back stores locally and is never graded', (t) async {
    await t.pumpWidget(testApp(FootprintResultScreen(input: answered())));
    await t.pumpAndSettle();
    await t.dragUntilVisible(find.byKey(const Key('explain-field')),
        find.byType(ListView), const Offset(0, -300));
    await t.enterText(find.byKey(const Key('explain-field')),
        'Charge makes them stick to things');
    await t.tap(find.byKey(const Key('explain-save')));
    await t.pumpAndSettle();
    expect(SettingsManager().footprintExplanation, contains('stick'));
    expect(find.byKey(const Key('explain-model-answer')), findsOneWidget);
    expect(find.textContaining('correct', findRichText: true), findsNothing);
  });
}
```

- [ ] **Step 2: Run it and watch it fail**

```bash
flutter test test/features/footprint/result_actions_test.dart
```

Expected: FAIL, URI does not exist for `charge_panel.dart`.

- [ ] **Step 3: Add the strings**

`footprintSwapTitle`, `footprintSwapYours`, `footprintSwapHousehold`,
`footprintCommitmentPrompt`, `footprintCommitmentHint`,
`footprintCommitmentSave`, `footprintExplainPrompt`,
`footprintExplainModelAnswer`, `footprintChargeStage1..3`,
`footprintChargeKnown`, `footprintChargeNotKnown`, and one label per `Swap`
key named in `footprint_coefficients.dart`
(`footprintSwapSteelBottle`, `footprintSwapKeepBottleCool`,
`footprintSwapGlassDish`, `footprintSwapOwnCup`,
`footprintSwapPaperTeaBag`, `footprintSwapWoodenBoard`).

The three charge stages in English. They carry the project's thesis, and the
Known block gives a student the citations to follow:

```json
"footprintChargeStage1": "Friction charges plastic. Fibres rubbing together, a bottle shaking in a hot car, a particle grinding against another one: each contact renews the charge. This is the triboelectric effect.",
"footprintChargeStage2": "A charged particle behaves differently from a neutral one. It clings instead of settling, it binds to proteins and fats, and it moves through water and air in ways an uncharged speck of dust does not.",
"footprintChargeStage3": "That charge is what lets these particles cross into blood, into tissue, into a cell. Charge is the root cause. The number of particles is only the symptom.",
"footprintChargeKnown": "Measured: surface charge changes how cells take particles up and whether the blood-brain barrier stays intact (Lockman 2004). The coat a charged particle gathers in blood decides whether it crosses (Kopatz 2023). Plastic particles have been found in human blood, brain and placenta.",
"footprintChargeNotKnown": "Open: how much exposure is harmful, and how much of the damage runs through charge. This project's thesis is that charge is the root cause. Confirming it is work that still needs doing, and that is where you come in."
```

- [ ] **Step 4: Implement**

`ChargePanel` is a `StatefulWidget` with `int stage`, `int get stageCount => 3`,
a `charge-next` button, and stage art drawn with `CustomPaint` so it mirrors
correctly in RTL. It advances automatically only when
`MediaQuery.of(context).disableAnimations` is false; the manual control is
always present. Below the stages sit `charge-known` and `charge-not-known`.

Panel 3 in the result screen, keyed `panel-swap`: for each habit with swaps,
a row showing the swap label, and before and after values by count and by
weight, computed with `result.withChange(habit)`. Two groups keyed
`swaps-yours` and `swaps-household`, split on `Swap.household`. Copy uses
"you could", never "you should" or "stop".

Beneath it, `commitment-field` (a `TextField` with the hint "When I ... I will
...") and `commitment-save`, storing through
`SettingsManager.setFootprintCommitment` and logging `footprint_commitment`.

Panel 5, keyed `explain-field` and `explain-save`, stores the sentence locally
and then reveals `explain-model-answer`. It never scores, and the word
"correct" appears nowhere.

- [ ] **Step 5: Run the tests and watch them pass**

```bash
flutter test test/features/footprint/result_actions_test.dart
```

Expected: PASS, 6 tests.

- [ ] **Step 6: Commit**

```bash
flutter analyze && flutter test
git add lib/screens/footprint lib/widgets/footprint/charge_panel.dart lib/services/managers/app_preferences_manager.dart assets/l10n/app_en.arb assets/l10n/app_ar.arb test/features/footprint/result_actions_test.dart docs/l10n-queue.md
git commit -m "feat(footprint): swap, commitment, charge panel, say it back

Swaps not abstinence, split into what a student owns and what the household
does. The charge panel carries the project thesis in three stages and links
the supporting studies, so a student can follow the mechanism rather than
take it on trust."
```

---

### Task 14: The three doors, consent, and the idea that comes back

**Files:**
- Create: `nanoplastics_frontend/lib/widgets/footprint/footprint_doors.dart`
- Create: `nanoplastics_frontend/lib/widgets/footprint/help_consent_sheet.dart`
- Modify: `nanoplastics_frontend/lib/services/api_service.dart`
- Modify: `nanoplastics_frontend/assets/l10n/app_en.arb`, `nanoplastics_frontend/assets/l10n/app_ar.arb`
- Test: `nanoplastics_frontend/test/features/footprint/doors_test.dart`

**Interfaces:**
- Consumes: `categoryKeyFor`, `FootprintResult`, `EventService`, `POST /api/ideas` with `context` from Task 5.
- Produces: `FootprintDoors`, `HelpConsentSheet`, `ApiService.submitIdea({..., Map<String, dynamic>? context})`, `ApiService.client`.

- [ ] **Step 1: Write the failing test**

Create `nanoplastics_frontend/test/features/footprint/doors_test.dart`:

```dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:nanoplastics_app/features/footprint/footprint_model.dart';
import 'package:nanoplastics_app/features/footprint/footprint_types.dart';
import 'package:nanoplastics_app/services/api_service.dart';
import 'package:nanoplastics_app/widgets/footprint/footprint_doors.dart';
import '../../helpers/test_app.dart';
import '../../helpers/settings_test_helper.dart';

void main() {
  setUp(() async => await setupTestSettings());

  final result = estimate(
      FootprintInput.gulfDefault().copyWith(touched: ChapterKey.values.toSet()));

  testWidgets('all three doors are present and equally weighted', (t) async {
    await t.pumpWidget(testApp(FootprintDoors(result: result)));
    await t.pumpAndSettle();
    for (final d in ['change', 'study', 'help']) {
      expect(find.byKey(Key('door-$d')), findsOneWidget);
    }
  });

  testWidgets('the study door gives a path, not only a list of papers',
      (t) async {
    await t.pumpWidget(testApp(FootprintDoors(result: result)));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('door-study')));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('study-start-here')), findsOneWidget);
    expect(find.byKey(const Key('study-open-questions')), findsOneWidget);
    expect(find.byKey(const Key('study-regional')), findsOneWidget);
  });

  testWidgets('every open question carries a size and a next step', (t) async {
    await t.pumpWidget(testApp(FootprintDoors(result: result)));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('door-study')));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('question-size-gulfTapWater')), findsOneWidget);
    expect(find.byKey(const Key('question-next-gulfTapWater')), findsOneWidget);
  });

  testWidgets('the help door shows consent before any network call', (t) async {
    var posted = false;
    ApiService().client = MockClient((req) async {
      posted = true;
      return http.Response('{"success":true}', 200);
    });
    await t.pumpWidget(testApp(FootprintDoors(result: result)));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('door-help')));
    await t.pumpAndSettle();
    await t.enterText(find.byKey(const Key('help-idea-field')),
        'A wooden board instead of a plastic one');
    await t.tap(find.byKey(const Key('help-send')));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('consent-sheet')), findsOneWidget);
    expect(posted, isFalse, reason: 'nothing may be sent before consent');
  });

  testWidgets('the habit-context consent is separate and optional', (t) async {
    late String body;
    ApiService().client = MockClient((req) async {
      body = await req.finalize().bytesToString();
      return http.Response('{"success":true}', 200);
    });
    await t.pumpWidget(testApp(FootprintDoors(result: result)));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('door-help')));
    await t.pumpAndSettle();
    await t.enterText(find.byKey(const Key('help-idea-field')),
        'A wooden board instead of a plastic one');
    await t.tap(find.byKey(const Key('help-send')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('consent-storage')));
    await t.tap(find.byKey(const Key('consent-scoring')));
    // consent-context deliberately left unchecked
    await t.tap(find.byKey(const Key('consent-confirm')));
    await t.pumpAndSettle();
    expect(body, isNot(contains('largest_by_count')));
  });

  test('submitIdea puts the context on the wire as a multipart field',
      () async {
    late String body;
    final api = ApiService()
      ..client = MockClient((req) async {
        body = await req.finalize().bytesToString();
        return http.Response('{"success":true}', 200);
      });
    await api.submitIdea(
      description: 'A wooden board instead of a plastic one',
      category: 'human_entry',
      context: {'source': 'footprint', 'largest_by_count': 'microwaveMeals'},
    );
    expect(body, contains('name="context"'));
    final start = body.indexOf('{', body.indexOf('name="context"'));
    final json = jsonDecode(body.substring(start, body.indexOf('}', start) + 1));
    expect(json['source'], 'footprint');
  });

  test('the category sent is one the database will accept', () async {
    const allowed = {
      'human_central', 'human_detox', 'human_vitality', 'human_reproduction',
      'human_entry', 'human_ways_of_destruction', 'planet_ocean',
      'planet_atmosphere', 'planet_bio', 'planet_magnetic', 'planet_entry',
      'planet_physical',
    };
    final r = estimate(FootprintInput.gulfDefault());
    expect(allowed, contains(categoryKeyFor(r.habitsWithMass.first.habit)));
  });
}
```

- [ ] **Step 2: Run it and watch it fail**

```bash
flutter test test/features/footprint/doors_test.dart
```

Expected: FAIL, URI does not exist.

- [ ] **Step 3: Make `ApiService` testable and context-aware**

In `api_service.dart`:

```dart
@visibleForTesting
http.Client client = http.Client();
```

Change `submitIdea` to accept `Map<String, dynamic>? context`, add the field
before sending, and send through the injectable client:

```dart
if (context != null) {
  request.fields['context'] = jsonEncode(context);
}
// was: final streamedResponse = await request.send().timeout(...)
final streamedResponse = await client.send(request).timeout(
      const Duration(seconds: 30),
    );
```

- [ ] **Step 4: Write the consent sheet**

`HelpConsentSheet` keyed `consent-sheet`, with three separate `CheckboxListTile`s
keyed `consent-storage`, `consent-scoring`, `consent-context`, an 18-or-over
confirmation, the identity line showing the nickname and email that will be
attached with a "send anonymously" switch, a link to the privacy policy, the
retention period, and `consent-confirm` enabled only when the first two boxes
and the age box are checked. Store the decision and a version integer through
`SettingsManager`, so changing the terms later re-asks.

- [ ] **Step 5: Write the doors**

`FootprintDoors` renders three equal cards keyed `door-change`, `door-study`,
`door-help`.

Study opens a sheet with `study-start-here` (one card), `study-regional`
(existing `EvidenceStudy` entries filtered by the domain of the student's
largest habits), and `study-open-questions`. Each question is a row with
`question-size-<id>` ("one term project") and `question-next-<id>` ("read this
method paper"), starting with `gulfTapWater`, `coolerJug` and `breathedNano`,
which are the three the coefficient table itself could not answer.

Help renders the personal hook built from `result.headlineHabit` and
`result.habitsWithMass.first.habit` with no percentage, three seed-prompt
chips that prefill `help-idea-field`, and `help-send`, which opens the consent
sheet first and only then calls `submitIdea` with
`category: categoryKeyFor(headlineHabit)` and the context map, logging
`idea_sent`. On success it stores the returned idea id locally and renders a
status card that polls `GET /api/ideas/:id` for the tier and reasoning, with a
link to the leaderboard. On failure it keeps the text for the next open.

- [ ] **Step 6: Run the tests and watch them pass**

```bash
flutter test test/features/footprint/doors_test.dart
```

Expected: PASS, 7 tests.

- [ ] **Step 7: Prove the consent test is real**

Make `help-send` call `submitIdea` directly without opening the sheet, and
re-run. Expected: the consent test FAILS on `posted, isFalse`. Restore.

- [ ] **Step 8: Commit**

```bash
flutter analyze && flutter test
git add lib/widgets/footprint lib/services/api_service.dart assets/l10n/app_en.arb assets/l10n/app_ar.arb test/features/footprint/doors_test.dart docs/l10n-queue.md
git commit -m "feat(footprint): three doors with real consent and a return path

Consent is three separate checkboxes, and habit context is optional.
The student sees what became of the idea instead of a one-way send."
```

---

### Task 15: Persistence, the return visit, and sharing

**Files:**
- Modify: `nanoplastics_frontend/lib/screens/footprint/footprint_result_screen.dart`
- Modify: `nanoplastics_frontend/lib/services/managers/app_preferences_manager.dart`
- Modify: `nanoplastics_frontend/lib/screens/explore_screen.dart`
- Modify: `nanoplastics_frontend/assets/l10n/app_en.arb`, `nanoplastics_frontend/assets/l10n/app_ar.arb`
- Test: `nanoplastics_frontend/test/features/footprint/persistence_test.dart`

**Interfaces:**
- Consumes: `FootprintInput.toJson` / `fromJson` from Task 1.
- Produces: `SettingsManager.footprintState` / `setFootprintState(Map)`, and a result screen that opens in "returning" mode.

- [ ] **Step 1: Write the failing test**

Create `nanoplastics_frontend/test/features/footprint/persistence_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/features/footprint/footprint_model.dart';
import 'package:nanoplastics_app/features/footprint/footprint_types.dart';
import 'package:nanoplastics_app/screens/footprint/footprint_result_screen.dart';
import 'package:nanoplastics_app/services/settings_manager.dart';
import '../../helpers/test_app.dart';
import '../../helpers/settings_test_helper.dart';

void main() {
  setUp(() async => await setupTestSettings());

  test('input survives a round trip through json', () {
    final input = FootprintInput.gulfDefault()
        .copyWith(touched: {ChapterKey.water, ChapterKey.lunch});
    final back = FootprintInput.fromJson(input.toJson());
    expect(back.waterSource, input.waterSource);
    expect(back.touched, input.touched);
    expect(back.microwaveMealsPerWeek, input.microwaveMealsPerWeek);
  });

  test('unknown enum values in stored json fall back instead of throwing', () {
    final json = FootprintInput.gulfDefault().toJson()
      ..['waterSource'] = 'somethingRemoved';
    expect(() => FootprintInput.fromJson(json), returnsNormally);
  });

  testWidgets('a second visit opens on the last result with a recount',
      (t) async {
    final input = FootprintInput.gulfDefault()
        .copyWith(touched: ChapterKey.values.toSet());
    await SettingsManager().setFootprintState(input.toJson());
    await t.pumpWidget(testApp(FootprintResultScreen(input: input, returning: true)));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('result-recount')), findsOneWidget);
  });

  testWidgets('a commitment older than fourteen days triggers a check-in',
      (t) async {
    await SettingsManager().setFootprintCommitment(
      'When I take lunch out, I will use a glass dish',
      DateTime.now().subtract(const Duration(days: 15)),
    );
    final input = FootprintInput.gulfDefault()
        .copyWith(touched: ChapterKey.values.toSet());
    await t.pumpWidget(testApp(FootprintResultScreen(input: input, returning: true)));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('commitment-checkin')), findsOneWidget);
  });

  testWidgets('a fresh commitment does not nag', (t) async {
    await SettingsManager().setFootprintCommitment(
      'When I take lunch out, I will use a glass dish',
      DateTime.now(),
    );
    final input = FootprintInput.gulfDefault()
        .copyWith(touched: ChapterKey.values.toSet());
    await t.pumpWidget(testApp(FootprintResultScreen(input: input, returning: true)));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('commitment-checkin')), findsNothing);
  });

  testWidgets('share text carries no percentage and no habit values',
      (t) async {
    final input = FootprintInput.gulfDefault()
        .copyWith(touched: ChapterKey.values.toSet());
    await t.pumpWidget(testApp(FootprintResultScreen(input: input)));
    await t.pumpAndSettle();
    final state =
        t.state<FootprintResultScreenState>(find.byType(FootprintResultScreen));
    final text = state.shareText;
    expect(text, isNot(contains('%')));
    expect(text.toLowerCase(), contains('estimate'));
    expect(text, isNot(contains('microwaveMealsPerWeek')));
  });
}
```

- [ ] **Step 2: Run it and watch it fail**

```bash
flutter test test/features/footprint/persistence_test.dart
```

Expected: FAIL, `setFootprintState` is not defined.

- [ ] **Step 3: Implement**

Add to `app_preferences_manager.dart`, one JSON key holding the input, the
commitment with its date, and the explanation:

```dart
static const String _footprintStateKey = 'footprint_state';

Map<String, dynamic> get footprintState {
  final raw = _prefs.getString(_footprintStateKey);
  if (raw == null || raw.isEmpty) return const {};
  try {
    return jsonDecode(raw) as Map<String, dynamic>;
  } catch (_) {
    return const {};
  }
}

Future<void> setFootprintState(Map<String, dynamic> value) async {
  await _prefs.setString(_footprintStateKey, jsonEncode(value));
}
```

`FootprintResultScreen` gains `final bool returning`. When true it renders
`result-recount` at the top, and `commitment-checkin` when the stored
commitment date is more than fourteen days old. The Explore card reads the
stored state and shows "Last counted on ..." when one exists, so the entry
point itself invites the return.

`shareText` builds from the headline sentence and the word "estimate", never
from raw input values, and the share button logs `footprint_shared`.

- [ ] **Step 4: Run the tests and watch them pass**

```bash
flutter test test/features/footprint/persistence_test.dart
```

Expected: PASS, 6 tests.

- [ ] **Step 5: Prove the check-in test is real**

Change the threshold from fourteen days to zero and re-run. Expected: the
fresh-commitment test FAILS. Restore.

- [ ] **Step 6: Commit**

```bash
flutter analyze && flutter test
git add lib/screens lib/services/managers/app_preferences_manager.dart assets/l10n/app_en.arb assets/l10n/app_ar.arb test/features/footprint/persistence_test.dart docs/l10n-queue.md
git commit -m "feat(footprint): persistence, return visit and share

A second visit opens on the last result and, after two weeks, asks how the
commitment went. Share text carries no percentage and no raw answers."
```

---

### Task 16: Privacy policy, usage switch, and the Arabic parity gate

**Files:**
- Modify: `nanoplastics_frontend/lib/screens/user_settings/privacy_policy_screen.dart`
- Modify: `nanoplastics_frontend/lib/l10n_web/` policy strings
- Modify: `nanoplastics_frontend/lib/screens/user_settings/user_settings_screen.dart`
- Modify: `nanoplastics_frontend/assets/l10n/app_en.arb`, `nanoplastics_frontend/assets/l10n/app_ar.arb`
- Test: `nanoplastics_frontend/test/features/footprint/claims_test.dart`

**Interfaces:**
- Consumes: `SettingsManager.usageStatisticsEnabled` and `EventService.setEnabled` from Task 8.
- Produces: nothing new.

The existing charge strings stay as they are. The project's thesis is that
charge is the root cause, and the app states it. This task is about the two
promises the app currently makes and does not keep: that analytics can be
switched off in Settings, and that the policy describes what is collected.

- [ ] **Step 1: Write the failing test**

Create `nanoplastics_frontend/test/features/footprint/claims_test.dart`:

```dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Map<String, dynamic> en;

  setUpAll(() {
    en = jsonDecode(File('assets/l10n/app_en.arb').readAsStringSync())
        as Map<String, dynamic>;
  });

  String joined(Map<String, dynamic> arb) => arb.entries
      .where((e) => !e.key.startsWith('@') && e.value is String)
      .map((e) => (e.value as String).toLowerCase())
      .join(' ');

  test('the privacy policy names usage events, retention and deletion', () {
    final text = joined(en);
    expect(text, contains('180 days'));
    expect(text, contains('usage statistics'));
    expect(text, contains('delete'));
  });

  test('the policy says an idea is scored by a service outside the country',
      () {
    expect(joined(en), contains('outside your country'));
  });

  test('every footprint and explore key in English also exists in Arabic', () {
    final ar = jsonDecode(File('assets/l10n/app_ar.arb').readAsStringSync())
        as Map<String, dynamic>;
    final missing = en.keys
        .where((k) => k.startsWith('footprint') || k.startsWith('explore'))
        .where((k) => !ar.containsKey(k))
        .toList();
    expect(missing, isEmpty,
        reason: 'Arabic is a first-class locale for this audience: $missing');
  });
}
```

- [ ] **Step 2: Run it and watch it fail**

```bash
cd nanoplastics_frontend && flutter test test/features/footprint/claims_test.dart
```

Expected: FAIL on the first test, since no string mentions 180 days.

- [ ] **Step 3: Write the policy text**

Add to `app_en.arb` and `app_ar.arb`, and mirror into the
`lib/l10n_web/` policy strings so the web policy matches the in-app one:

```json
"privacyUsageTitle": "Usage statistics",
"privacyUsageBody": "We record which screens you open and which buttons you press, so we can see where the app confuses people. Each record carries a random installation number that is created on your device and is not linked to you, your account, your email or your phone. It disappears when you clear the app's data. We keep these records for 180 days and then delete them. You can turn this off in Settings, and when it is off nothing is collected at all.",
"privacyIdeasTitle": "Ideas you send",
"privacyIdeasBody": "An idea you submit is stored by NanoSolve and read by people working on the project. It is also sent to an AI service outside your country to be scored, and the score comes back into the app. If you agree, the answers you gave in the footprint tool are attached so the idea can be understood in context; you can send the idea without them. Your nickname and email are attached only if you choose. To delete a submission, contact us with the reference code shown when you send it."
```

- [ ] **Step 4: Add the switch the policy already promised**

`privacy_policy_screen.dart` already tells users they can disable analytics in
Settings, and today there is no such control. Add it to
`user_settings_screen.dart` as a `SwitchListTile` labelled with
`privacyUsageTitle`, wired to `SettingsManager.setUsageStatisticsEnabled` and
to `ServiceLocator().eventService.setEnabled`, defaulting to on. Render the
two new policy sections in `privacy_policy_screen.dart` beside the existing
Firebase section.

- [ ] **Step 5: Run the tests and watch them pass**

```bash
flutter test test/features/footprint/claims_test.dart
flutter test
```

Expected: PASS, 3 tests, and the whole suite green.

- [ ] **Step 6: Prove the Arabic parity test is real**

Delete one `footprint` key from `app_ar.arb` and re-run. Expected: the parity
test FAILS and names the key. Restore it.

- [ ] **Step 7: Commit**

```bash
flutter analyze && flutter test
git add assets/l10n lib/l10n lib/l10n_web lib/screens/user_settings test/features/footprint/claims_test.dart
git commit -m "feat(privacy): usage switch and a policy that matches the code

The policy promised analytics could be disabled in Settings and no such
control existed. Adds it, and describes what app_events collects, its
180-day retention, and how an idea is processed and deleted.

A test now fails the build if an English footprint string has no Arabic
counterpart."
```

### Task 17: Full verification and the human test

**Files:**
- Create: `docs/research/2026-09-05-footprint-three-students.md`
- Modify: `docs/superpowers/specs/2026-09-05-footprint-calculator-design.md` (record results)

- [ ] **Step 1: Run every gate**

```bash
cd nanoplastics_frontend && flutter analyze && flutter test && dart format --set-exit-if-changed lib
cd ../services/nanoSolve-backend && cargo clippy -- -D warnings && cargo test
```

All four must be clean. Do not proceed with any failure outstanding.

- [ ] **Step 2: Run it on a device, in Arabic**

```bash
cd nanoplastics_frontend
flutter run --flavor full --dart-define=BUNDLE_ALL_LANGS=true
```

Walk all seven chapters, switch the app to Arabic, walk them again, and check:
Next moves the page the right way, no chapter clips at 200% text scale, the
chart's bars grow from the correct edge, and the right-edge back gesture still
pops the screen without eating a page turn.

- [ ] **Step 3: Read the two unread sources**

Before the numbers ship, read the full texts of the Water Research 2026
storage paper and Choi et al. 2025, which the spec's Risks section flags as
read only as abstracts. If the 9.3x fold change or the meta-analysis
conclusions differ, change the coefficient row or the design rule, then re-run
Task 1's tests.

- [ ] **Step 4: Run the three-student test**

Follow the protocol in the umbrella spec: consent script, three students, one
on the Arabic build. Record in `docs/research/2026-09-05-footprint-three-students.md`:
the three explanations verbatim, where each hesitated, what they tapped first,
whether they finished, and which door they opened. No names.

- [ ] **Step 5: Record the outcome in the spec**

Add the result under the spec's Testing section, including whether two of
three could explain what a nanoplastic is and why charge matters. If they
could not, the feature is not done; the next revision cuts chapters rather
than words.

- [ ] **Step 6: Commit**

```bash
git add docs/research docs/superpowers/specs
git commit -m "docs(footprint): verification results and student test notes"
```

---

## Self-review

**Spec coverage.** Every section of the feature A spec maps to a task: model
and coefficients to 1, formatting to 2, chapters to 3, cloud to 4, context
column to 5 and 6, events to 7 and 8, Explore and first run to 9, story to 10,
breakdown to 11, result panels to 12 and 13, doors and consent to 14,
persistence, return and share to 15, charge corrections and privacy to 16,
verification and the human test to 17.

**Deliberately deferred, and named in the umbrella spec rather than here:** the
rendered share image, a web landing page for shared links, store listing and
campus distribution, research brief templates and measurement uploads, the
Persian locale, and the digest subscription beyond a single "follow this
topic" control.

**Type consistency.** `FootprintInput`, `FootprintResult`, `HabitEstimate`,
`Habit`, `Family`, `Method`, `Tag`, `Swap` and `Coefficient` are defined in
Task 1 and used unchanged afterwards. `estimate`, `byFamily`, `habitsWithMass`,
`withChange`, `headlineHabit` and `touchedCount` keep the same names in Tasks
11 to 15. `categoryKeyFor` is defined in Task 3 and used in Task 14.
`FootprintStrings` is defined in Task 2 and implemented in Task 12.
`validate_context` and `render_context` are defined in Tasks 5 and 6.
`ALLOWED_EVENTS` and `validate_batch` are defined in Task 7 and consumed by
Task 8's client.

**Known risk in the plan itself.** Tasks 10, 12, 13 and 14 describe widget
structure in prose with keys and behaviour rather than complete widget code.
The keys, the semantics, and the behavioural assertions are exact, and the
tests are complete, so the tests define the contract even where the layout is
left to the implementer's judgement within the design-token rules.
