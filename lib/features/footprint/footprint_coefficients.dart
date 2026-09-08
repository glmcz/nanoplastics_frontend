import 'footprint_types.dart';

/// Bumped whenever a number below changes, and stored with every submitted
/// idea so a result can be traced back to the table that produced it.
const String kCoefficientsVersion = '2026-09-05';

/// One row per habit. Every number is traceable to the source named on the
/// row; the spec's Model section carries the full citations and the reasoning
/// behind each tag.
class Coefficient {
  final Habit habit;
  final Family family;
  final Method method;

  /// Smallest particle the source's instrument could see. Two rows with
  /// different floors are not comparable, which is why families exist.
  final double sizeFloorNm;

  final List<Tag> tags;
  final String source;
  final String categoryKey;

  /// Particles per unit of exposure. The unit is defined per habit by
  /// [estimate] in footprint_model.dart.
  final double perUnit;

  final double lowFactor;
  final double highFactor;

  /// Milligrams per particle, where the source publishes a size distribution
  /// or the spec states the sphere assumption. Null means count only.
  final double? massMgPerParticle;

  /// Localisation key naming who published the challenge, for rows tagged
  /// [Tag.disputed]. Required for those rows and asserted by a test.
  ///
  /// A collective label like "researchers disagree" implies independent
  /// replication that usually has not happened: one paper gets challenged
  /// once, and every later mention repeats the original. Naming the single
  /// specific challenge is both true and checkable by a student.
  final String? challengedByKey;

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
    this.challengedByKey,
    this.swaps = const [],
  });
}

/// Sphere at the given diameter, density 1.05 g/cm3, in milligrams.
/// This is an assumption, not a measurement, and the bar that uses it says so.
double sphereMassMg(double diameterNm) {
  final r = diameterNm * 1e-9 / 2;
  final volumeM3 = 4 / 3 * 3.141592653589793 * r * r * r;
  return volumeM3 * 1050 * 1e6;
}

const List<Coefficient> kCoefficients = [
  Coefficient(
    habit: Habit.bottledWater,
    family: Family.swallowedSubMicron,
    method: Method.srs,
    sizeFloorNm: 100,
    tags: [Tag.measured, Tag.disputed],
    source: 'Qian et al., PNAS 2024, doi 10.1073/pnas.2300582121. Challenged '
        'by Materic, PNAS 2024, doi 10.1073/pnas.2411099121, which argues the '
        'samples sat below the procedural blank; Qian replied, '
        'doi 10.1073/pnas.2415874121.',
    categoryKey: 'human_entry',
    perUnit: 2.4e5, // particles per litre
    lowFactor: 1.1e5 / 2.4e5,
    highFactor: 4.0e5 / 2.4e5,
    massMgPerParticle: 7.2e-11, // sphere at 500 nm, the reported median band
    challengedByKey: 'footprintChallengerPnasLetter',
    swaps: [Swap('footprintSwapSteelBottle', 0.0)],
  ),
  Coefficient(
    habit: Habit.bottleStorage,
    family: Family.swallowedSubMicron,
    method: Method.nta,
    sizeFloorNm: 30,
    tags: [Tag.extrapolated],
    source: 'Water Research, Feb 2026, everyday storage and handling of PET '
        'bottled water, S0043135426002526. Lab simulation at 60 C with '
        'shaking, not a measured car.',
    categoryKey: 'human_entry',
    perUnit: 9.3, // a multiplier on bottledWater, not a count of its own
    swaps: [Swap('footprintSwapKeepBottleCool', 1 / 9.3)],
  ),
  Coefficient(
    habit: Habit.microwaveMeals,
    family: Family.swallowedSubMicron,
    method: Method.nta,
    sizeFloorNm: 30,
    tags: [Tag.countedNotIdentified, Tag.extrapolated, Tag.disputed],
    source: 'Hussain et al., ES&T 2023, doi 10.1021/acs.est.3c01942. '
        '2.11e9 nanoparticles per square centimetre in three minutes; '
        '100 square centimetres of food contact assumed. Correspondence and '
        'Rebuttal, ES&T 2024.',
    categoryKey: 'human_entry',
    perUnit: 2.11e9 * 100, // per heated meal
    lowFactor: 0.5, // 50 cm2
    highFactor: 2.0, // 200 cm2
    massMgPerParticle: 1.58e-14, // back-solved from Hussain's 20.3 ng/kg/day
    challengedByKey: 'footprintChallengerEstComment',
    swaps: [Swap('footprintSwapGlassDish', 0.0)],
  ),
  Coefficient(
    habit: Habit.takeawayCupsSubMicron,
    family: Family.swallowedSubMicron,
    method: Method.sem,
    sizeFloorNm: 200,
    tags: [Tag.countedNotIdentified],
    source: 'Ranjan et al., J. Hazard. Mater. 2021, S0304389420321087. '
        'Sub-micron count by electron microscopy, no per-particle polymer '
        'identification.',
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
    source: 'BfR assessment 2020 re-tested Hernandez et al., ES&T 2019 and '
        'found 5,800 to 20,400 particles above 1 micrometre per bag, '
        'concluding the sub-micron population was precipitated oligomers. '
        'No confirmed nano count exists.',
    categoryKey: 'human_entry',
    perUnit: 13100, // per pyramid bag, BfR midpoint
    lowFactor: 5800 / 13100,
    highFactor: 20400 / 13100,
    massMgPerParticle: 5.8e-7,
    challengedByKey: 'footprintChallengerBfr',
    swaps: [Swap('footprintSwapPaperTeaBag', 0.0)],
  ),
  Coefficient(
    habit: Habit.takeawayCupsMicron,
    family: Family.swallowedMicron,
    method: Method.fluorescence,
    sizeFloorNm: 1000,
    tags: [Tag.measured],
    source: 'Ranjan et al., J. Hazard. Mater. 2021, S0304389420321087. '
        '25,000 micron-sized particles per 100 mL cup in 15 minutes.',
    categoryKey: 'human_entry',
    perUnit: 2.5e4,
    massMgPerParticle: 5.8e-7,
    swaps: [Swap('footprintSwapOwnCup', 0.0)],
  ),
  Coefficient(
    habit: Habit.seafood,
    family: Family.swallowedMicron,
    method: Method.visual,
    sizeFloorNm: 100000,
    tags: [Tag.measured],
    source: 'Western Arabian Gulf, Mar. Pollut. Bull. 2020, pubmed 32479293: '
        '0.057 items per fish, gut contents rather than fillet, fibres '
        'excluded. Cox et al., ES&T 2019 is shown only as a global line.',
    categoryKey: 'planet_ocean',
    perUnit: 0.057, // items per meal
    massMgPerParticle: 0.0015,
  ),
  Coefficient(
    habit: Habit.cuttingBoard,
    family: Family.swallowedMicron,
    method: Method.gravimetric,
    sizeFloorNm: 1000,
    tags: [Tag.measured],
    source: 'Yadav et al., ES&T 2023, doi 10.1021/acs.est.3c00924: '
        '14.5 to 71.9 million particles and 7.4 to 50.7 grams a year from a '
        'polyethylene board.',
    categoryKey: 'human_entry',
    perUnit: 4.3e7, // particles a year, polyethylene midpoint
    lowFactor: 14.5 / 43,
    highFactor: 71.9 / 43,
    massMgPerParticle: 29000 / 4.3e7, // 29 grams a year spread over that count
    swaps: [Swap('footprintSwapWoodenBoard', 0.0, household: true)],
  ),
  Coefficient(
    habit: Habit.syntheticIndoor,
    family: Family.breathed,
    method: Method.ftir,
    sizeFloorNm: 11000,
    tags: [Tag.measured, Tag.extrapolated],
    source: 'Uddin et al., Kuwait indoor aerosol baseline, PMC8878012: '
        '3.2 to 27.1 particles per cubic metre, 10.8 to 27.1 in carpeted '
        'flats. Breathing volume 16.8 cubic metres a day at light activity '
        'from Vianello et al., Sci. Rep. 2019. The scaling by synthetic '
        'share is an assumption; no study reports counts that way.',
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
    source: 'Bushehr, Iran, Environ. Res. 2021, pubmed 33068583: adults '
        'inhale 32.5 items a day normally and 161 on dusty days.',
    categoryKey: 'planet_atmosphere',
    perUnit: (161 - 32.5) / 24, // extra items per dusty hour
    massMgPerParticle: 7.6e-4,
  ),
];

Coefficient coefficientFor(Habit h) =>
    kCoefficients.firstWhere((c) => c.habit == h);
