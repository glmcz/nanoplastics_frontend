import 'footprint_coefficients.dart';
import 'footprint_types.dart';

/// One student's day, as answered. Defaults are a starting point, not an
/// answer: [touched] records which chapters they actually engaged with.
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

  /// What the student guessed would be biggest, asked before chapter one.
  /// Comparing the guess to the answer is what turns a surprising number from
  /// something read into something learned.
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

  /// A plausible Gulf student, so no screen is ever empty.
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
        syntheticIndoorShare: syntheticIndoorShare ?? this.syntheticIndoorShare,
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

  /// Tolerant on purpose: a stored answer from an older build must not crash
  /// the screen, so an unknown enum name falls back to the default.
  static FootprintInput fromJson(Map<String, dynamic> j) {
    T pick<T extends Enum>(List<T> values, Object? name, T fallback) {
      if (name is! String) return fallback;
      for (final v in values) {
        if (v.name == name) return v;
      }
      return fallback;
    }

    final d = FootprintInput.gulfDefault();
    return FootprintInput(
      waterSource: pick(WaterSource.values, j['waterSource'], d.waterSource),
      waterBottlesPerDay:
          (j['waterBottlesPerDay'] as int?) ?? d.waterBottlesPerDay,
      bottleStorage:
          pick(BottleStorage.values, j['bottleStorage'], d.bottleStorage),
      plasticContainerMealsPerWeek:
          (j['plasticContainerMealsPerWeek'] as int?) ??
              d.plasticContainerMealsPerWeek,
      microwaveMealsPerWeek:
          (j['microwaveMealsPerWeek'] as int?) ?? d.microwaveMealsPerWeek,
      teaBagType: pick(TeaBagType.values, j['teaBagType'], d.teaBagType),
      teaCupsPerDay: (j['teaCupsPerDay'] as int?) ?? d.teaCupsPerDay,
      takeawayCupsPerWeek:
          (j['takeawayCupsPerWeek'] as int?) ?? d.takeawayCupsPerWeek,
      syntheticIndoorShare: pick(SyntheticShare.values,
          j['syntheticIndoorShare'], d.syntheticIndoorShare),
      indoorHoursPerDay:
          (j['indoorHoursPerDay'] as int?) ?? d.indoorHoursPerDay,
      seafoodMealsPerWeek:
          (j['seafoodMealsPerWeek'] as int?) ?? d.seafoodMealsPerWeek,
      seafoodForm: pick(SeafoodForm.values, j['seafoodForm'], d.seafoodForm),
      cuttingBoard:
          pick(CuttingBoard.values, j['cuttingBoard'], d.cuttingBoard),
      dustyHoursPerWeek:
          (j['dustyHoursPerWeek'] as int?) ?? d.dustyHoursPerWeek,
      touched: ((j['touched'] as List?) ?? const [])
          .map((n) => pick(ChapterKey.values, n, ChapterKey.water))
          .toSet(),
      prediction: j['prediction'] == null
          ? null
          : pick(Habit.values, j['prediction'], Habit.bottledWater),
    );
  }
}

/// One habit's estimated yearly exposure, carrying everything needed to show
/// it honestly: the band, the instrument, its floor, and the caveats.
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

/// Deliberately exposes no grand total and no percentage. Summing counts
/// across families would rank habits by which lab owned the better
/// microscope. Mass is the only fair cross-family comparison.
class FootprintResult {
  final FootprintInput input;
  final List<HabitEstimate> habits;

  const FootprintResult(this.input, this.habits);

  List<HabitEstimate> byFamily(Family f) =>
      habits.where((h) => h.family == f).toList()
        ..sort((a, b) => b.particlesPerYear.compareTo(a.particlesPerYear));

  /// The comparable ordering: mass does not depend on how small the
  /// instrument could see.
  List<HabitEstimate> get habitsWithMass =>
      habits.where((h) => (h.massMgPerYear ?? 0) > 0).toList()
        ..sort((a, b) => b.massMgPerYear!.compareTo(a.massMgPerYear!));

  int get touchedCount => input.touched.length;

  static const Map<Habit, ChapterKey> _chapterOf = {
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

  /// Largest by count, restricted to chapters the student actually answered.
  /// A student who tapped Next seven times gets no headline rather than
  /// somebody else's day presented as their own.
  Habit? get headlineHabit {
    final answered = habits
        .where((h) => input.touched.contains(_chapterOf[h.habit]))
        .toList()
      ..sort((a, b) => b.particlesPerYear.compareTo(a.particlesPerYear));
    return answered.isEmpty ? null : answered.first.habit;
  }

  /// Applies the first swap listed for that habit. Never "stop doing it".
  /// The storage row is a multiplier, so its swap lands on bottled water.
  FootprintResult withChange(Habit habit) {
    final swaps = coefficientFor(habit).swaps;
    if (swaps.isEmpty) return this;
    final factor = swaps.first.factor;
    final target = habit == Habit.bottleStorage ? Habit.bottledWater : habit;
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

/// Assumption, not a finding: no study reports indoor counts by how much of
/// the room is synthetic. Named on the bar wherever it is used.
double _shareFactor(SyntheticShare s) => switch (s) {
      SyntheticShare.little => 0.6,
      SyntheticShare.some => 0.9,
      SyntheticShare.most => 1.2,
      SyntheticShare.all => 1.4,
    };

FootprintResult estimate(FootprintInput i) {
  final out = <HabitEstimate>[];

  HabitEstimate build(Habit h, double count, {List<Tag> extraTags = const []}) {
    final c = coefficientFor(h);
    return HabitEstimate(
      habit: h,
      family: c.family,
      particlesPerYear: count,
      low: count * c.lowFactor,
      high: count * c.highFactor,
      method: c.method,
      sizeFloorNm: c.sizeFloorNm,
      tags: [...c.tags, ...extraTags],
      source: c.source,
      massMgPerYear:
          c.massMgPerParticle == null ? null : count * c.massMgPerParticle!,
    );
  }

  // Water. Only small bottles have a published sub-micron count. The 20 L
  // cooler jug has never been counted at nano scale, so it is an open
  // question rather than a zero.
  final storageMultiplier =
      i.bottleStorage == BottleStorage.carOrSun ? 9.3 : 1.0;
  if (i.waterSource == WaterSource.smallBottles) {
    final litres = i.waterBottlesPerDay * 0.5 * _daysPerYear;
    out.add(build(
      Habit.bottledWater,
      litres * coefficientFor(Habit.bottledWater).perUnit * storageMultiplier,
    ));
  } else {
    out.add(build(
      Habit.bottledWater,
      0,
      extraTags: i.waterSource == WaterSource.coolerJug
          ? const [Tag.unknown]
          : const [],
    ));
  }
  // The storage row is a multiplier on the row above, so it has no count of
  // its own; it exists so the swap and the tag have somewhere to live.
  out.add(build(Habit.bottleStorage, 0));

  // Lunch. Only the meals actually heated release at this rate.
  final heated = i.microwaveMealsPerWeek
      .clamp(0, i.plasticContainerMealsPerWeek)
      .toDouble();
  out.add(build(
    Habit.microwaveMeals,
    heated * _weeksPerYear * coefficientFor(Habit.microwaveMeals).perUnit,
  ));

  // Tea. Only the silky pyramid bag is plastic.
  final bags =
      i.teaBagType == TeaBagType.pyramid ? i.teaCupsPerDay * _daysPerYear : 0.0;
  out.add(build(Habit.teaBags, bags * coefficientFor(Habit.teaBags).perUnit));

  // Cups, counted twice at two floors by the same study, shown as two bars.
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
        : 0,
  ));

  // Home and outside.
  final cubicMetres = 16.8 * (i.indoorHoursPerDay / 24);
  out.add(build(
    Habit.syntheticIndoor,
    cubicMetres *
        coefficientFor(Habit.syntheticIndoor).perUnit *
        _shareFactor(i.syntheticIndoorShare) *
        _daysPerYear,
  ));
  out.add(build(
    Habit.dustDays,
    i.dustyHoursPerWeek *
        _weeksPerYear *
        coefficientFor(Habit.dustDays).perUnit,
  ));

  return FootprintResult(i, out);
}
