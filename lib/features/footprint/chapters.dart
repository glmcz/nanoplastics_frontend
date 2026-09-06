import 'footprint_coefficients.dart';
import 'footprint_types.dart';

enum ControlKind { slider, chips }

/// One question on a chapter page. `field` names the [FootprintInput] property
/// it writes, so the story screen stays generic and adding a question is a
/// data change rather than a widget change.
class ControlSpec {
  final String field;
  final String questionKey;
  final ControlKind kind;
  final int min;
  final int max;

  /// Required for sliders: a screen reader announces "3 bottles", not "37%".
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

/// Seven chapters of one ordinary day, in the order a Gulf student lives it.
///
/// Data, not code, so that if the funnel says seven is too many, cutting one
/// is a list edit rather than a screen rewrite.
const List<Chapter> kChapters = [
  Chapter(ChapterKey.water, 'footprintSceneWater', 'footprintWhyWater', [
    ControlSpec(
      field: 'waterSource',
      questionKey: 'footprintQWaterSource',
      kind: ControlKind.chips,
      optionKeys: [
        'footprintOptSmallBottles',
        'footprintOptCoolerJug',
        'footprintOptTapOrFilter',
      ],
    ),
    ControlSpec(
      field: 'waterBottlesPerDay',
      questionKey: 'footprintQWaterAmount',
      kind: ControlKind.slider,
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
        'footprintOptCarOrSun',
      ],
    ),
  ]),
  Chapter(ChapterKey.lunch, 'footprintSceneLunch', 'footprintWhyLunch', [
    ControlSpec(
      field: 'plasticContainerMealsPerWeek',
      questionKey: 'footprintQContainerMeals',
      kind: ControlKind.slider,
      max: 21,
      unitKey: 'footprintUnitMealsWeek',
    ),
    ControlSpec(
      field: 'microwaveMealsPerWeek',
      questionKey: 'footprintQMicrowaveMeals',
      kind: ControlKind.slider,
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
        'footprintOptLooseLeaf',
      ],
    ),
    ControlSpec(
      field: 'teaCupsPerDay',
      questionKey: 'footprintQTeaCups',
      kind: ControlKind.slider,
      max: 6,
      unitKey: 'footprintUnitCupsDay',
    ),
  ]),
  Chapter(ChapterKey.cups, 'footprintSceneCups', 'footprintWhyCups', [
    ControlSpec(
      field: 'takeawayCupsPerWeek',
      questionKey: 'footprintQTakeawayCups',
      kind: ControlKind.slider,
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
        'footprintOptAll',
      ],
    ),
    ControlSpec(
      field: 'indoorHoursPerDay',
      questionKey: 'footprintQIndoorHours',
      kind: ControlKind.slider,
      max: 24,
      unitKey: 'footprintUnitHoursDay',
    ),
  ]),
  Chapter(ChapterKey.dinner, 'footprintSceneDinner', 'footprintWhyDinner', [
    ControlSpec(
      field: 'seafoodMealsPerWeek',
      questionKey: 'footprintQSeafood',
      kind: ControlKind.slider,
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
        'footprintOptBoardUnknown',
      ],
    ),
  ]),
  Chapter(ChapterKey.outside, 'footprintSceneOutside', 'footprintWhyOutside', [
    ControlSpec(
      field: 'dustyHoursPerWeek',
      questionKey: 'footprintQDustyHours',
      kind: ControlKind.slider,
      max: 20,
      unitKey: 'footprintUnitHoursWeek',
    ),
  ]),
];

/// The database constrains `ideas.category` to twelve keys (migration 002).
/// An idea sent from this tool must carry one of them or the insert fails.
String categoryKeyFor(Habit h) => coefficientFor(h).categoryKey;
