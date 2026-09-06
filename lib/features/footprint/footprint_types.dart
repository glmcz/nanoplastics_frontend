/// Types for the nanoplastic footprint calculator.
///
/// Pure Dart on purpose: the model must be testable without a widget tree.
library;

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
/// Rows in different families are never summed: most of the difference
/// between them is the microscope, not the plastic.
enum Family { swallowedSubMicron, swallowedMicron, breathed }

enum Method { srs, nta, sem, fluorescence, ftir, visual, gravimetric }

/// How much weight a number carries. Defined once here and asserted by the
/// coefficient-table test, so a row cannot invent its own confidence level.
enum Tag {
  /// Counted and chemically identified as plastic, no published challenge.
  measured,

  /// Counted without per-particle polymer identification, so the count may
  /// include oligomers, salts or fillers.
  countedNotIdentified,

  /// A measured value scaled by an assumption the source did not make.
  extrapolated,

  /// A published comment, letter or regulator assessment challenges it.
  disputed,

  /// Nobody has measured this. Shown as an open question, never as a zero.
  unknown,
}

enum WaterSource { smallBottles, coolerJug, tapOrFilter }

enum BottleStorage { fridge, room, carOrSun }

enum TeaBagType { paper, pyramid, looseLeaf }

enum SeafoodForm { fillet, whole }

enum CuttingBoard { plastic, wood, unknown }

enum SyntheticShare { little, some, most, all }

enum ChapterKey { water, lunch, tea, cups, home, dinner, outside }

/// One concrete swap a student could make, with the factor it applies to its
/// habit. Never phrased as "stop"; always a substitution.
class Swap {
  final String labelKey;
  final double factor;

  /// True when the purchase belongs to the household rather than the student.
  /// Most students in this region live with family and do not buy the
  /// kitchenware.
  final bool household;

  const Swap(this.labelKey, this.factor, {this.household = false});
}
